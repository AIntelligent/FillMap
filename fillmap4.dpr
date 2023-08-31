program fillmap4;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils;

//
// veteran
// 30-08-2023
//

//
// Harita Doldurma Algoritmasý
// ===========================
//
// Problem: Baþlangýçta verilen mxn boyutlu ve varsayýlanda bir desene sahip harita veriliyor.
// Bu harita üzerinde, rastgele seçilen ve boþ olan bir noktadan baþlayarak boþluklarýn -
// doldurulmasý istenmektedir.
//
// Kural: Eðer bir nokta "varsayýlan" deðer ile doluysa o nokta geçilmeli ve doðru yol bulunarak -
// boþluk doldurulmaya devam edilmelidir.
//
// Baþlangýç deseni:
// -----------------
//
// Harita ebatý (mxn):         20x20
// Harita toplam hücre sayýsý: 400
// Doluluk oraný:              %37.125
// Doldurulan hücre sayýsý:    149
// Doldurulmayan hücre sayýsý: 251
//
//   0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9
// 0     · · · ·   ·   ·       · ·     · ·
// 1 · ·       ·     ·   ·   · ·     ·
// 2     ·     · · ·       ·     ·     ·
// 3     ·       · · · · · · · · · · · ·
// 4       ·     ·               · ·     ·
// 5 ·           · · ·       ·   · · ·
// 6       ·     · · ·                 ·   ·
// 7       ·   ·   · · ·           ·   ·
// 8       ·       ·     ·     ·           ·
// 9 · ·       ·     · · · · ·           ·
// 0 · ·   ·     · ·   · ·                 ·
// 1 ·   ·         ·           · · · ·
// 2 ·     ·             ·   ·     · · · ·
// 3             ·   · ·           · ·   ·
// 4 ·   · · ·   · ·   · · · · · ·
// 5           · ·       ·           ·     ·
// 6       ·   ·       · · ·   ·   · ·   ·
// 7                 ·               ·
// 8   ·     ·             ·     ·     ·   ·
// 9 · ·   ·             ·       ·   · · ·
//
// Sonuç:
// -----------------
//
// Baþlangýç konum (y, x): 15, 13
//
//   0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9
// 0     · · · ·   ·   ·       · ·     · · @
// 1 · · @ @ @ ·     ·   ·   · ·     · @ @ @
// 2 @ @ · @ @ · · ·       ·     ·     · @ @
// 3 @ @ · @ @ @ · · · · · · · · · · · · @ @
// 4 @ @ @ · @ @ · @ @ @ @ @ @ @ · · @ @ · @
// 5 · @ @ @ @ @ · · · @ @ @ · @ · · · @ @ @
// 6 @ @ @ · @ @ · · · @ @ @ @ @ @ @ @ · @ ·
// 7 @ @ @ · @ · @ · · · @ @ @ @ @ · @ · @ @
// 8 @ @ @ · @ @ @ ·     · @ @ · @ @ @ @ @ ·
// 9 · · @ @ @ · @ @ · · · · · @ @ @ @ @ ·
// 0 · · @ · @ @ · · @ · · @ @ @ @ @ @ @ @ ·
// 1 · @ · @ @ @ @ · @ @ @ @ @ · · · · @ @ @
// 2 · @ @ · @ @ @ @ @ @ · @ · @ @ · · · · @
// 3 @ @ @ @ @ @ · @ · · @ @ @ @ @ · · @ · @
// 4 · @ · · · @ · · @ · · · · · · @ @ @ @ @
// 5 @ @ @ @ @ · · @ @ @ · @ @[@]@ @ · @ @ ·
// 6 @ @ @ · @ · @ @ @ · · · @ · @ · · @ · @
// 7 @ @ @ @ @ @ @ @ · @ @ @ @ @ @ @ · @ @ @
// 8 @ · @ @ · @ @ @ @ @ @ · @ @ · @ @ · @ ·
// 9 · · @ · @ @ @ @ @ @ · @ @ @ · @ · · ·
//

const
  HORIZONTAL_LIMIT = 20;
  VERTICAL_LIMIT   = 20;

const
  // Deseni ifade eden karakter.
  DEFAULT_VALUE    = Ord('·');

  // Boþluðu doldurmak için istenen karakter.
  FILL_VALUE       = Ord('@');

type
  TDirection = (Left, Top, Right, Bottom);

  PCell = ^TCell;
  TCell = packed record
  public var
    Neighbours : array[ TDirection ] of PCell;
    Value : Byte;
  end;

  PMap = ^TMap;
  TMap = array[ 0..(VERTICAL_LIMIT - 1), 0..(HORIZONTAL_LIMIT - 1) ] of PCell;


{$REGION ' Cell Tools '}

function Create( inValue : Byte ) : PCell; overload;
begin
  New( Result );

  FillChar( Result^, SizeOf(TCell), 0 );

  Result^.Value := inValue;
end;

procedure Destroy( var ioCellPtr : PCell ); overload;
var
  l_ptrCell : PCell;
begin
  l_ptrCell := ioCellPtr;
  ioCellPtr := nil;

  Dispose( l_ptrCell );
end;

function IsDefault( const inCellPtr : PCell ) : Boolean;
begin
  Result := inCellPtr^.Value = DEFAULT_VALUE;
end;

function IsForbidden( const inCellPtr : PCell ) : Boolean;
begin
  Result := IsDefault( inCellPtr ) or (inCellPtr^.Value = FILL_VALUE);
end;

function GetNeighbour( const inCellPtr : PCell; const inDirection : TDirection ) : PCell;
begin
  Result := inCellPtr^.Neighbours[ inDirection ];
end;

{$ENDREGION}

{$REGION ' Map Tools '}

function Create() : PMap; overload;
var
  y, x,
  _y, _x : Integer;
  l_enmDirection : TDirection;
  l_ptrNeighbour : PCell;
begin
  GetMem( Result, VERTICAL_LIMIT * HORIZONTAL_LIMIT * SizeOf(PCell) );

  for y := 0 to (VERTICAL_LIMIT - 1) do
    for x := 0 to (HORIZONTAL_LIMIT - 1) do
      Result^[ y, x ] := Create( 0 );

  for y := 0 to (VERTICAL_LIMIT - 1) do
    for x := 0 to (HORIZONTAL_LIMIT - 1) do
      for l_enmDirection := Low(TDirection) to High(TDirection) do
      begin
        _y := y;
        _x := x;

        case (l_enmDirection) of
          (Left   ): Dec(_x);
          (Top    ): Dec(_y);
          (Right  ): Inc(_x);
          (Bottom ): Inc(_y);
        end;

        if (((_y >= 0) and (VERTICAL_LIMIT > _y)) and ((_x >= 0) and (HORIZONTAL_LIMIT > _x))) then
          l_ptrNeighbour := Result^[ _y, _x ]
        else
          l_ptrNeighbour := nil;

        Result^[ y, x ]^.Neighbours[ l_enmDirection ] := l_ptrNeighbour;
      end;
end;

procedure Destroy( var ioMapPtr : PMap ); overload;
var
  y, x : Integer;
  l_ptrMap : PMap;
begin
  l_ptrMap := ioMapPtr;
  ioMapPtr := nil;

  for y := 0 to (VERTICAL_LIMIT - 1) do
    for x := 0 to (HORIZONTAL_LIMIT - 1) do
      Destroy( l_ptrMap^[ y, x ] );

  FreeMem( l_ptrMap );
end;

procedure Make( ioMapPtr : PMap; inFillRatio : Single = 0.37125 );
var
  y, x, i,
  l_iFillCount : Integer;
begin
  WriteLn;

  l_iFillCount := Round( (VERTICAL_LIMIT * HORIZONTAL_LIMIT) * inFillRatio );

  WriteLn( 'Harita ebatý (mxn):         ', VERTICAL_LIMIT, 'x', HORIZONTAL_LIMIT );
  WriteLn( 'Harita toplam hücre sayýsý: ', VERTICAL_LIMIT * HORIZONTAL_LIMIT );
  WriteLn( 'Doluluk oraný (%):          ', (inFillRatio * 100.0):0:3 );
  WriteLn( 'Doldurulan hücre sayýsý:    ', l_iFillCount );
  WriteLn( 'Doldurulmayan hücre sayýsý: ', ((VERTICAL_LIMIT * HORIZONTAL_LIMIT) - l_iFillCount) );

  WriteLn;

  Randomize();

  for i := 0 to (l_iFillCount - 1) do
  begin
    repeat
      y := Random( VERTICAL_LIMIT   );
      x := Random( HORIZONTAL_LIMIT );
    until (not IsForbidden( ioMapPtr^[ y, x ] ));

    ioMapPtr^[ y, x ].Value := DEFAULT_VALUE;
  end;
end;

procedure Display( const inMapPtr : PMap );
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
      V := inMapPtr^[ y, x ]^.Value;

      if (V <> 0) then
        l_strData := Chr(V)
      else
        l_strData := ' ';

      _Concat;
    end;

    WriteLn( y mod 10, ' ', l_strLine );
  end;
end;

procedure Fill( ioMapPtr : PMap );

  procedure _FindAndFill( ioCellPtr : PCell );

    function __Set : Boolean;
    begin
      if (not IsForbidden( ioCellPtr )) then
        begin
          ioCellPtr^.Value := FILL_VALUE;
          Result := True;
        end
      else
        Result := False;
    end;

  var
    l_ptrNeighbour : PCell;
    l_enmDirection : TDirection;
  begin
    if (__Set) then
      for l_enmDirection := Low(TDirection) to High(TDirection) do
      begin
        l_ptrNeighbour := ioCellPtr^.Neighbours[ l_enmDirection ];

        if (l_ptrNeighbour <> nil) then
          _FindAndFill( l_ptrNeighbour );
      end;
  end;

var
  y, x : Integer;

begin
  Randomize();

  repeat

    y := Random( VERTICAL_LIMIT );
    x := Random( HORIZONTAL_LIMIT );

  until (not IsDefault( ioMapPtr^[ y, x ] ));

  WriteLn;
  WriteLn( 'Baþlangýç konum (y, x): ', y, ', ', x );
  WriteLn;

  _FindAndFill( ioMapPtr^[ y, x ] );
end;

{$ENDREGION}

var
  l_ptrMap : PMap;

begin
  try

    l_ptrMap := Create();
    try

      Make( l_ptrMap );

      Display( l_ptrMap );

      Fill( l_ptrMap );

      Display( l_ptrMap );

    finally

      Destroy( l_ptrMap );

    end;

  except

    on l_objException : Exception do
      WriteLn( l_objException.ClassName(), ': ', l_objException.Message );

  end;

  ReadLn;
end.
