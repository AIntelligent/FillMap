program fillmap2;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  WinApi.Windows,
  System.Math,
  System.SysUtils;

//
// veteran
// 25-08-2023
//

//
// Harita Doldurma Algoritmas�
// ===========================
//
// Problem: Ba�lang��ta verilen mxn boyutlu ve varsay�landa bir desene sahip harita veriliyor.
// Haritan�n e� par�alara b�l�nerek, her par�an�n rastgele se�ilen ve bo� bir noktadan ba�layarak-
// bo�luklar�n�n e� zamans�z (asynch) ve paralel (multi task) �ekilde doldurulmas� istenmektedir.
//
// Kural: e�er bir nokta "varsay�lan" de�er ile doluysa o nokta ge�ilmeli ve do�ru yol bulunarak -
// bo�luk doldurulmaya devam edilmelidir.
//
// Ba�lang�� deseni:
// -----------------
//
//   0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9
// 0   � � �                         �       �   � � �   �     �
// 1 � �         � �       �           �
// 2       �                 �     �           �           �   �
// 3 � �   � �             � �         �
// 4   � �                     �   �     �     �   �
// 5       �     �       �   �   � �   � �             �       �
// 6   �   �   �   � �       �       �       �     � �   �
// 7     � �     �                   �   � �       �           �
// 8         �       �     �   �   � �           �         �
// 9   �     � � �   �     �   �                           � �
// 0 �     � �     � � �                     � �             �
// 1 � �   �       �     �         �             �
// 2                               � �     � �       �
// 3   �     �     � � �     � � �       �     �       �   �
// 4 �             �     �       �     � �       �
// 5 � �   �       �   �     �                 �
// 6         �     � �           �               �   �   �   �
// 7   � �         �           �         �   �   �             �
// 8 �                   �                     �           �
// 9                       �   �     �   �                   �
// 0   �         �   � �   �             �   �
// 1   �     �       �       �                           �
// 2   � �     �   � �               � �     �
// 3           �   �   �       �         �   �       �     � �
// 4         � �             �     � �       �   � �
// 5     �     �       �     �         �       �
// 6                       �   � �           �
// 7       �       �         �   �           � �         � �
// 8         �         �     � �       �       �           �
// 9     �         � �   �                 �   � �       �   �
//
// Sonu�:
// ------
//
// B�l�m: 0 Alan: (L: 0, T: 0)-(R:14, B:14) Ba�lang��: (y:12, x: 0)
// B�l�m: 1 Alan: (L:15, T: 0)-(R:29, B:14) Ba�lang��: (y:12, x:17)
// B�l�m: 2 Alan: (L: 0, T:15)-(R:14, B:29) Ba�lang��: (y:21, x: 0)
// B�l�m: 3 Alan: (L:15, T:15)-(R:29, B:29) Ba�lang��: (y:26, x:28)
//
//   0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9
// 0   � � � @ @ @ @ @ @ @ @ @ @ @ @ � @ @ @ � @ � � � @ � @ @ �
// 1 � � @ @ @ @ � � @ @ @ � @ @ @ @ @ � @ @ @ @ @ @ @ @ @ @ @ @
// 2 @ @ @ � @ @ @ @ @ @ @ @ � @ @ � @ @ @ @ @ � @ @ @ @ @ � @ �
// 3 � � @ � � @ @ @ @ @ @ � � @ @ @ @ � @ @ @ @ @ @ @ @ @ @ @ @
// 4 @ � � @ @ @ @ @ @ @ @ @ @ � @ � @ @ � @ @ � @ � @ @ @ @ @ @
// 5 @ @ @ � @ @ � @ @ @ � @ � @ � � @ � � @ @ @ @ @ @ � @ @ @ �
// 6 @ � @ � @ �   � � @ @ @ � @ @   � @ @ @ � @ @ � � @ � @ @ @
// 7 @ @ � � @ @ � @ @ @ @ @ @ @ @   � @ � � @ @ @ � @ @ @ @ @ �
// 8 @ @ @ @ � @ @ @ � @ @ � @ � @ � � @ @ @ @ @ � @ @ @ @ � @ @
// 9 @ � @ @ � � � @ � @ @ � @ � @ @ @ @ @ @ @ @ @ @ @ @ @ � � @
// 0 � @ @ � � @ @ � � � @ @ @ @ @ @ @ @ @ @ � � @ @ @ @ @ @ � @
// 1 � � @ � @ @ @ � @ @ � @ @ @ @ � @ @ @ @ @ @ � @ @ @ @ @ @ @
// 2[@]@ @ @ @ @ @ @ @ @ @ @ @ @ @ � �[@]@ � � @ @ @ � @ @ @ @ @
// 3 @ � @ @ � @ @ � � � @ @ � � � @ @ @ �     � @ @ @ � @ � @ @
// 4 � @ @ @ @ @ @ �     � @ @ @ � @ @ � �       � @ @ @ @ @ @ @
// 5 � � @ � @ @ @ �   � @ @ � @ @ @ @ @ @ @ @ � @ @ @ @ @ @ @ @
// 6 @ @ @ @ � @ @ � � @ @ @ @ @ � @ @ @ @ @ @ @ � @ � @ � @ � @
// 7 @ � � @ @ @ @ � @ @ @ @ @ � @ @ @ @ � @ � @ � @ @ @ @ @ @ �
// 8 � @ @ @ @ @ @ @ @ @ � @ @ @ @ @ @ @ @ @ @ � @ @ @ @ @ � @ @
// 9 @ @ @ @ @ @ @ @ @ @ @ � @ � @ @ � @ � @ @ @ @ @ @ @ @ @ � @
// 0 @ � @ @ @ @ � @ � � @ � @ @ @ @ @ @ � @ � @ @ @ @ @ @ @ @ @
// 1[@]� @ @ � @ @ @ � @ @ @ � @ @ @ @ @ @ @ @ @ @ @ @ @ � @ @ @
// 2 @ � � @ @ � @ � � @ @ @ @ @ @ @ � � @ @ � @ @ @ @ @ @ @ @ @
// 3 @ @ @ @ @ � @ � @ � @ @ @ � @ @ @ @ � @ � @ @ @ � @ @ � � @
// 4 @ @ @ @ � � @ @ @ @ @ @ � @ @ � � @ @ @ � @ � � @ @ @ @ @ @
// 5 @ @ � @ @ � @ @ @ � @ @ � @ @ @ @ � @ @ @ � @ @ @ @ @ @ @ @
// 6 @ @ @ @ @ @ @ @ @ @ @ �   � � @ @ @ @ @ � @ @ @ @ @ @ @[@]@
// 7 @ @ @ � @ @ @ � @ @ @ @ �   � @ @ @ @ @ � � @ @ @ @ � � @ @
// 8 @ @ @ @ � @ @ @ @ � @ @ � � @ @ @ � @ @ @ � @ @ @ @ @ � @ @
// 9 @ @ � @ @ @ @ � �   � @ @ @ @ @ @ @ @ � @ � � @ @ @ �   � @
//
// Not: Her b�l�m�n ba�lang�� konumu "[ ]" i�erisinde belirtilmi�tir.
//

const
  VERTICAL_LIMIT            = 30;
  HORIZONTAL_LIMIT          = 30;

const
  // Deseni ifade eden karakter.
  DEFAULT_VALUE             = Ord('�');

  // Bo�lu�u doldurmak i�in istenen karakter.
  FILL_VALUE                = Ord('@');

const
  VERTICAL_SECTION_COUNT    = 2;
  HORIZONTAL_SECTION_COUNT  = 2;
  SECTION_COUNT             = (VERTICAL_SECTION_COUNT * HORIZONTAL_SECTION_COUNT);

type
  PMap = ^TMap;
  TMap = packed array[ 0..(VERTICAL_LIMIT - 1), 0..(HORIZONTAL_LIMIT - 1) ] of Byte;

  TDirection = (Left, Top, Right, Bottom);

  TRange = packed record
  public var
    L, T,
    W, H : Integer;
  private
    function GetR() : Integer;
    function GetB() : Integer;
  public
    constructor Create( const inL, inT, inW, inH : Integer );
    function ToString () : string;
  public
    property R : Integer read GetR;
    property B : Integer read GetB;
  end;

  TDot = packed record
  public var
    y, x  : Integer;
  public var
    Range : TRange;
  public
    constructor Create    ( const inY, inX    : Integer;
                            const inRange   : TRange   );

    function    Move      ( const inDirection : TDirection;
                            var outNew        : TDot        ) : Boolean;

    function    ToString  () : string;
  end;

  TRangeHelper = record helper for TRange
    function DotInSection( const inDot : TDot ) : Boolean;
  end;

{$REGION ' TRange '}

// Private

function TRange.GetR() : Integer;
begin
  Result := L + W - 1;
end;

function TRange.GetB() : Integer;
begin
  Result := T + H - 1;
end;

// Public

constructor TRange.Create( const inL, inT, inW, inH : Integer );
begin
  L := inL;
  T := inT;

  W := inW;
  H := inH;
end;

function TRange.ToString () : string;
begin
  Result := Format( '(L:%2d, T:%2d)-(R:%2d, B:%2d)', [ L, T, R, B ] );
end;

{$ENDREGION}

{$REGION ' TRangeHelper '}

function TRangeHelper.DotInSection( const inDot : TDot ) : Boolean;
begin
  Result := (inDot.y >= T) and (inDot.y <= B) and (inDot.x >= L) and (inDot.x <= R);
end;

{$ENDREGION}

{$REGION ' TDot '}

// Public

constructor TDot.Create( const inY, inX : Integer; const inRange : TRange );
begin
  y     := inY;
  x     := inX;

  Range := inRange;
end;

function TDot.Move( const inDirection : TDirection; var outNew : TDot ) : Boolean;
var
  _y, _x : Integer;
  l_varDot : TDot;
begin
  _y := y;
  _x := x;

  case (inDirection) of
    (Left   ): _x := Pred( _x );
    (Top    ): _y := Pred( _y );
    (Right  ): _x := Succ( _x );
    (Bottom ): _y := Succ( _y );
  end;

  l_varDot := TDot.Create( _y, _x, Range );

  if (Range.DotInSection( l_varDot )) then
    begin
      outNew := l_varDot;
      Result := True;
    end
  else
    Result := False;
end;

function TDot.ToString() : string;
begin
  Result := Format( '(y:%2d, x:%2d)', [ y, x ] );
end;

{$ENDREGION}

procedure Display( const inMap : TMap );
var
  V : Byte;
  y, x : Integer;
  l_strLine, l_strData : string;

  procedure _Concat;
  begin
    if (string.IsNullOrEmpty( l_strLine )) then
      l_strLine := l_strData
    else
      l_strLine := l_strLine + ' ' + l_strData;
  end;

begin

  l_strLine := string.Empty;

  for x := 0 to HORIZONTAL_LIMIT - 1 do
  begin
    l_strData := IntToStr( x mod 10 );
    _Concat;
  end;

  WriteLn( '':2, l_strLine );

  for y := 0 to VERTICAL_LIMIT - 1 do
  begin
    l_strLine := string.Empty;

    for x := 0 to HORIZONTAL_LIMIT - 1 do
    begin
      V := inMap[ y, x ];

      if (V <> 0) then
        l_strData := Chr(V)
      else
        l_strData := ' ';

      _Concat;
    end;

    WriteLn( y mod 10, ' ', l_strLine );
  end;
end;

procedure Start( var ioMap : TMap );
var
  l_iEntryCount,
  i, y, x : Integer;
begin
  FillChar( ioMap, SizeOf(TMap), 0 );

  Randomize();

  l_iEntryCount := Round( (VERTICAL_LIMIT * HORIZONTAL_LIMIT) * 0.25 );

  for i := 0 to (l_iEntryCount - 1) do
  begin
    repeat
      y := Random( VERTICAL_LIMIT );
      x := Random( HORIZONTAL_LIMIT );
    until (ioMap[ y, x ] <> DEFAULT_VALUE);

    ioMap[ y, x ] := DEFAULT_VALUE;
  end;
end;

function IsForbidden( const inMap : TMap; const inDot : TDot ) : Boolean;
begin
  with (inDot) do
    Result := inMap[ y, x ] in [ DEFAULT_VALUE, FILL_VALUE ];
end;

procedure Fill( var ioMap : TMap );
type
  PContext = ^TContext;
  TContext = packed record
  public var
    Index           : Integer;
    MapPtr          : PMap;
    Range           : TRange;
    Start           : TDot;
    CriticalSection : PRTLCriticalSection;
  end;

var
  l_ptrCriticalSection : PRTLCriticalSection;

  function Worker( const inContextPtr : PContext ) : LRESULT; stdcall;

    procedure _FindAndFill( const inDot : TDot );

      function __Set : Boolean;
      begin
        if (not IsForbidden( inContextPtr^.MapPtr^, inDot )) then
          begin
            with (inContextPtr^), (inDot) do
              MapPtr^[ y, x ] := FILL_VALUE;

            Result := True
          end
        else
          Result := False;
      end;

    var
      l_enmDirection : TDirection;
      l_varDot       : TDot;
    begin
      if (__Set) then
        for l_enmDirection in [ Left..Bottom ] do
        begin
          l_varDot := inDot;

          if (l_varDot.Move( l_enmDirection, l_varDot )) then
            _FindAndFill( l_varDot );
        end;
    end;

  begin
    _FindAndFill( inContextPtr^.Start );

    (*
     * !!! Dikkat !!!
     * Konsol ekran�na ��kt�lama e� zamans�z (asynch) i�lemler i�in uygun de�ildir.
     * Bu nedenle e� zamanlama zorlanmal�d�r.
     *
     * Bkz: https://learn.microsoft.com/en-us/windows/win32/api/synchapi/nf-synchapi-entercriticalsection
     *)
    EnterCriticalSection( inContextPtr^.CriticalSection^ );

    WriteLn( '>>> ', inContextPtr^.Index, '. ', GetCurrentThreadId():6, ' tamamland�.' );

    LeaveCriticalSection( inContextPtr^.CriticalSection^ );

    Result := ERROR_SUCCESS;
  end;

var
  y, x : Integer;

  l_arrSection : array[ 0..(SECTION_COUNT - 1) ] of PContext;
  l_arrThreads : array[ 0..(SECTION_COUNT - 1) ] of THandle;

  procedure _MakeSection;
  var
    i, V, H : Integer;
    l_uiThreadId : Cardinal;

    function __MakeStart( const inRange : TRange ) : TDot;
    var
      y, x : Integer;
    begin
      Randomize();

      repeat

        y := RandomRange( inRange.T, inRange.B );
        x := RandomRange( inRange.L, inRange.R );

        Result := TDot.Create( y, x, inRange );

      until (not IsForbidden( ioMap, Result ));
    end;

  begin
    i := ((y * HORIZONTAL_SECTION_COUNT) + x);

    V := (VERTICAL_LIMIT div VERTICAL_SECTION_COUNT);
    H := (HORIZONTAL_LIMIT div HORIZONTAL_SECTION_COUNT);

    New( l_arrSection[ i ] );

    with l_arrSection[ i ]^ do
    begin
      Index           := i;

      MapPtr          := Addr( ioMap );

      Range           := TRange.Create( x * H, y * V, H, V );

      Start           := __MakeStart( Range );

      CriticalSection := l_ptrCriticalSection;

      WriteLn( 'B�l�m:', i:2, ' Alan: ', Range.ToString(), ' Ba�lang��: ', Start.ToString() );
    end;

    (*
     * !!! Not !!!
     * ��lemlerin paralel e�-zamans�z (async) yap�labilmesi i�in yeni i� par�ac�klar�na ihtiya� vard�r.
     * A�a��da her bir b�l�m�n e�-zamans�z (async) i�lenebilmesi i�in birer i� par�ac��� olu�turuluyor.
     *
     * Bkz: https://learn.microsoft.com/en-us/windows/win32/api/processthreadsapi/nf-processthreadsapi-createthread
     *)
    l_arrThreads[ i ] := CreateThread( nil, 0, @Worker, l_arrSection[ i ], CREATE_SUSPENDED, l_uiThreadId );
  end;

  procedure _Run;
  var
    i : Integer;
  begin
    (*
     * �� par�ac�klar� ba�lat�l�yor.
     *
     *)
    for i := 0 to (SECTION_COUNT - 1) do ResumeThread( l_arrThreads[ i ] );

    (*
     * !!! Not !!!
     * Her b�l�m i�in olu�turulan i� par�ac�klar�n�n hepsinin g�revini bitirmesini -
     * beklemeliyiz ki aksi halde sonu�lar hatal� olacakt�r. A�a��daki kodlar -
     * b�t�n i� par�ac�klar� g�revini tamamlayana kadar program ak���n� bekletecektir.
     *
     * Bkz: https://learn.microsoft.com/en-us/windows/win32/api/synchapi/nf-synchapi-waitformultipleobjects
     *)
    WaitForMultipleObjects( SECTION_COUNT, @l_arrThreads[ 0 ], True, INFINITE );

    for i := 0 to (SECTION_COUNT - 1) do Dispose( l_arrSection[ i ] );
  end;

begin
  New( l_ptrCriticalSection );
  InitializeCriticalSection( l_ptrCriticalSection^ );
  try
    WriteLn;

    for y := 0 to (VERTICAL_SECTION_COUNT - 1) do
      for x := 0 to (HORIZONTAL_SECTION_COUNT - 1) do
        _MakeSection;

    WriteLn;

    _Run;

    WriteLn;
  finally
    DeleteCriticalSection( l_ptrCriticalSection^ );
    Dispose( l_ptrCriticalSection );
  end;
end;

var
  Map : TMap;

begin
  try

    Start( Map );

    Display( Map );

    Fill( Map );

    Display( Map );

  except

    on l_objException : Exception do
      WriteLn( l_objException.ClassName(), ': ', l_objException.Message );

  end;

  ReadLn;
end.
