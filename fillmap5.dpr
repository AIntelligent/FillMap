program fillmap5;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils;

//
// veteran
// 11-09-2023
//

//
// Harita Doldurma Algoritmas�
// ===========================
//
// Problem: Ba�lang��ta verilen mxn boyutlu ve varsay�landa bir desene sahip harita veriliyor.
// Bu harita �zerinde, rastgele se�ilen ve bo� olan bir noktadan ba�layarak bo�luklar�n -
// doldurulmas� istenmektedir.
//
// Kural: E�er bir nokta "varsay�lan" de�er ile doluysa o nokta ge�ilmeli ve do�ru yol bulunarak -
// bo�luk doldurulmaya devam edilmelidir.
//
// Ba�lang�� deseni:
// -----------------
//
//   0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9
// 0     � �                     �     �
// 1   � �   �                 � �
// 2   �           �           � � �   �
// 3     �             �         � �   �
// 4   � �           � �         � �   �
// 5           �     �           �
// 6   �   �             �                 �
// 7     �             � �   �   �   �
// 8                 � �   �   �   �
// 9           �           �       � �     �
// 0   � �             � �     � �
// 1         �     � �           � �
// 2       �                 �             �
// 3           �         � �     �   �
// 4                   �     �     �     �
// 5 �             �     �
// 6     �           �         �     �
// 7                         �           � �
// 8   �   � �             �   �   �     � �
// 9   � � �       � � �           �     � �
//
// Sonu�:
// ------
//
// Ba�lang�� konum (y, x): 13, 8
//
//   0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9
// 0 @ @ � � @ @ @ @ @ @ @ @ @ @ � @ @ � @ @
// 1 @ � � @ � @ @ @ @ @ @ @ @ � � @ @ @ @ @
// 2 @ � @ @ @ @ @ � @ @ @ @ @ � � � @ � @ @
// 3 @ @ � @ @ @ @ @ @ � @ @ @ @ � � @ � @ @
// 4 @ � � @ @ @ @ @ � � @ @ @ @ � � @ � @ @
// 5 @ @ @ @ @ � @ @ � @ @ @ @ @ � @ @ @ @ @
// 6 @ � @ � @ @ @ @ @ @ � @ @ @ @ @ @ @ @ �
// 7 @ @ � @ @ @ @ @ @ � � @ � @ � @ � @ @ @
// 8 @ @ @ @ @ @ @ @ � � @ � @ � @ � @ @ @ @
// 9 @ @ @ @ @ � @ @ @ @ @ � @ @ @ � � @ @ �
// 0 @ � � @ @ @ @ @ @ � � @ @ � � @ @ @ @ @
// 1 @ @ @ @ � @ @ � � @ @ @ @ @ � � @ @ @ @
// 2 @ @ @ � @ @ @ @ @ @ @ @ � @ @ @ @ @ @ �
// 3 @ @ @ @ @ � @ @ @ @ � � @ @ � @ � @ @ @
// 4 @ @ @ @ @ @ @ @ @ � @ @ � @ @ � @ @ � @
// 5 � @ @ @ @ @ @ � @ @ � @ @ @ @ @ @ @ @ @
// 6 @ @ � @ @ @ @ @ � @ @ @ @ � @ @ � @ @ @
// 7 @ @ @ @ @ @ @ @ @ @ @ @ � @ @ @ @ @ � �
// 8 @ � @ � � @ @ @ @ @ @ � @ � @ � @ @ � �
// 9 @ � � � @ @ @ � � � @ @ @ @ @ � @ @ � �
//

const
  HORIZONTAL_LIMIT  = 20;
  VERTICAL_LIMIT    = 20;
  MAP_LENGTH        = VERTICAL_LIMIT * HORIZONTAL_LIMIT;

const
  // Deseni ifade eden karakter.
  DEFAULT_VALUE     = Ord('�');

  // Bo�lu�u doldurmak i�in istenen karakter.
  FILL_VALUE        = Ord('@');

type
  PMap = ^TMap;
  TMap = packed array[ 0..0 ] of Byte;

  TDirection = (Left, Top, Right, Bottom);

  TDot = packed record
    y, x : Integer;
  end;

var
  MapPtr : PMap;
  Dot : TDot;

{$REGION ' TMap '}

procedure CreateMap();
begin
  GetMem( MapPtr, MAP_LENGTH );
  FillChar( MapPtr^, MAP_LENGTH, 0 );
end;

function MapDotToIndex : Integer;
begin
  Result := ((Dot.y * HORIZONTAL_LIMIT) + Dot.x);
end;

procedure DestroyMap;
var
  l_ptrMap : PMap;
begin
  l_ptrMap := MapPtr;
  MapPtr := nil;

  FreeMem( l_ptrMap );
end;

{$ENDREGION}

{$REGION ' TDot '}

procedure CreateDot( const inY, inX : Integer );
begin
  Dot.y := inY;
  Dot.x := inX;
end;

function MoveDot( const inDirection : TDirection ) : Boolean;
var
  _y, _x : Integer;
begin
  _y := Dot.y;
  _x := Dot.x;

  case (inDirection) of
    (Left   ):
      begin
        _x := Pred( _x );
        Result := (_x >= 0);
      end;
    (Top    ):
      begin
        _y := Pred( _y );
        Result := (_y >= 0);
      end;
    (Right  ):
      begin
        _x := Succ( _x );
        Result := (HORIZONTAL_LIMIT > _x);
      end;
    (Bottom ):
      begin
        _y := Succ( _y );
        Result := (VERTICAL_LIMIT > _y);
      end;
  else
    Result := False;
  end;

  if (Result) then
    CreateDot( _y, _x );
end;

{$ENDREGION}

procedure Display;
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
      CreateDot( y, x );
      V := MapPtr^[ MapDotToIndex ];

      if (V <> 0) then
        l_strData := Chr(V)
      else
        l_strData := ' ';

      _Concat;
    end;

    WriteLn( y mod 10, ' ', l_strLine );
  end;
end;

procedure Start;
var
  l_iEntryCount,
  i, y, x : Integer;
begin
  CreateMap;

  Randomize();

  l_iEntryCount := Round( (VERTICAL_LIMIT * HORIZONTAL_LIMIT) * 0.25 );

  for i := 0 to (l_iEntryCount - 1) do
  begin
    repeat
      y := Random( VERTICAL_LIMIT );
      x := Random( HORIZONTAL_LIMIT );
      CreateDot( y, x );
    until (MapPtr^[ MapDotToIndex ] <> DEFAULT_VALUE);

    MapPtr^[ MapDotToIndex ] := DEFAULT_VALUE;
  end;
end;

procedure Fill;

  procedure _FindAndFill;

    function __Set : Boolean;
    begin
      if (not (MapPtr^[ MapDotToIndex ] in [ DEFAULT_VALUE, FILL_VALUE ])) then
        begin
          MapPtr^[ MapDotToIndex ] := FILL_VALUE;
          Result := True
        end
      else
        Result := False;
    end;

  var
    l_varDot : TDot;
    l_enmDirection : TDirection;
  begin
    if (__Set) then
      for l_enmDirection in [ Left..Bottom ] do
      begin
        l_varDot := Dot;

        if (MoveDot( l_enmDirection )) then
          _FindAndFill;

        Dot := l_varDot;
      end;
  end;

var
  y, x : Integer;

begin
  Randomize();

  repeat
    y := Random( VERTICAL_LIMIT );
    x := Random( HORIZONTAL_LIMIT );
    CreateDot( y, x );
  until (MapPtr^[ MapDotToIndex ] <> DEFAULT_VALUE);

  WriteLn;
  WriteLn( 'Ba�lang�� konum (y, x): ', y, ', ', x );
  WriteLn;

  _FindAndFill;
end;

begin
  Start;

  Display;

  Fill;

  Display;

  DestroyMap;

  ReadLn;
end.
