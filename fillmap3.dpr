program fillmap3;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils;

//
// veteran
// 26-08-2023
//
// Copyright (c) 2023 veteran
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
//

//
// Harita Doldurma Algoritması
// ===========================
//
// Problem: Başlangıçta verilen mxn boyutlu ve varsayılanda bir desene sahip harita veriliyor.
// Bu harita üzerinde, rastgele seçilen ve boş olan bir noktadan başlayarak boşlukların -
// doldurulmasý istenmektedir.
//
// Kural: eğer bir nokta "varsayılan" deðer ile doluysa o nokta geçilmeli ve doğru yol bulunarak -
// boşluk doldurulmaya devam edilmelidir.
//
//
// Başlangıç deseni:
// -----------------
//
// Harita ebatı (mxn):         20x20
// Harita toplam hücre sayısı: 400
// Doluluk oranı:              %37.125
// Doldurulan hücre sayısı:    149
// Doldurulmayan hücre sayısı: 251
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
// Başlangıç konum (y, x): 15, 13
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

  // Boşluğu doldurmak için istenen karakter.
  FILL_VALUE       = Ord('@');

type
  TDirection = (Left, Top, Right, Bottom);

  CMap = class;

  CCell = class
  private var
    m_objOwner : CMap;
    m_iY, m_iX : Integer;
    m_iValue : Byte;
  private
    function GetIsDefault() : Boolean; inline;
    function GetIsForbidden() : Boolean; inline;
    function GetNeighbour( const inDirection : TDirection ) : CCell;
  public
    constructor Create( const inOwner : CMap; const inY, inX : Integer );
  public
    property IsDefault : Boolean read GetIsDefault;
    property IsForbidden : Boolean read GetIsForbidden;
    property Neighbour[ const inDirection : TDirection ] : CCell read GetNeighbour; default;
    property Owner : CMap read m_objOwner;
    property Y : Integer read m_iY;
    property X : Integer read m_iX;
    property Value : Byte read m_iValue write m_iValue;
  end;

  CMap = class
  private var
    m_iVerticalLimit,
    m_iHorizontalLimit : Integer;
    m_arrDatum : array of array of CCell;
  private
    function Get( const inY, inX : Integer ) : Byte; inline;
    procedure &Set( const inY, inX : Integer; const inValue : Byte ); inline;
    function GetLength() : Integer;
  public
    constructor Create( const inVerticalLimit : Integer = VERTICAL_LIMIT; const inHorizontalLimit : Integer = HORIZONTAL_LIMIT );
    destructor Destroy(); override;
    procedure Make( const inFillRatio : Single = 0.25 );
    procedure Display();
    procedure Fill();
  public
    property Length : Integer read GetLength;
    property VerticalLimit : Integer read m_iVerticalLimit;
    property HorizontalLimit : Integer read m_iHorizontalLimit;
    property Datum[ const inY, inX : Integer ] : Byte read Get write &Set; default;
  end;

{$REGION ' CCell '}

// Private

function CCell.GetIsDefault() : Boolean;
begin
  Result := Owner[ Y, X ] = DEFAULT_VALUE;
end;

function CCell.GetIsForbidden() : Boolean;
begin
  Result := IsDefault or (Owner[ Y, X ] = FILL_VALUE);
end;

function CCell.GetNeighbour( const inDirection : TDirection ) : CCell;
var
  _y, _x : Integer;
begin
  _y := Y;
  _x := X;

  case (inDirection) of
    (Left   ): _x := Pred(_x);
    (Top    ): _y := Pred(_y);
    (Right  ): _x := Succ(_x);
    (Bottom ): _y := Succ(_y);
  end;

  if (((_y >= 0) and (_y < Owner.VerticalLimit)) and ((_x >= 0) and (_x < Owner.HorizontalLimit))) then
    Result := Owner.m_arrDatum[ _y, _x ]
  else
    Result := nil;
end;

// Public

constructor CCell.Create( const inOwner : CMap; const inY, inX : Integer );
begin
  m_objOwner := inOwner;

  m_iY := inY;
  m_iX := inX;

  m_iValue := 0;
end;

{$ENDREGION}

{$REGION ' CMap '}

// Private

function CMap.Get( const inY, inX : Integer ) : Byte;
begin
  Result := m_arrDatum[ inY, inX ].Value;
end;

procedure CMap.&Set( const inY, inX : Integer; const inValue : Byte );
begin
  m_arrDatum[ inY, inX ].Value := inValue;
end;

function CMap.GetLength() : Integer;
begin
  Result := m_iVerticalLimit * m_iHorizontalLimit;
end;

// Public

constructor CMap.Create( const inVerticalLimit, inHorizontalLimit : Integer );
var
  y, x : Integer;
begin
  m_iVerticalLimit := inVerticalLimit;
  m_iHorizontalLimit := inHorizontalLimit;

  SetLength( m_arrDatum, m_iVerticalLimit, m_iHorizontalLimit );

  for y := 0 to (VerticalLimit - 1) do
    for x := 0 to (HorizontalLimit - 1) do
      m_arrDatum[ y, x ] := CCell.Create( Self, y, x );
end;

destructor CMap.Destroy();
var
  y, x : Integer;
begin
  for y := 0 to (VerticalLimit - 1) do
    for x := 0 to (HorizontalLimit - 1) do
      FreeAndNil( m_arrDatum[ y, x ] );

  inherited Destroy();
end;

procedure CMap.Make( const inFillRatio : Single );
var
  i, l_iFillCount,
  y, x : Integer;
begin
  WriteLn;

  l_iFillCount := Round( Length * inFillRatio );

  WriteLn( 'Harita ebatı (mxn):         ', VerticalLimit, 'x', HorizontalLimit );
  WriteLn( 'Harita toplam hücre sayısı: ', Length );
  WriteLn( 'Doluluk oranı (%):          ', (inFillRatio * 100.0):0:3 );
  WriteLn( 'Doldurulan hücre sayısı:    ', l_iFillCount );
  WriteLn( 'Doldurulmayan hücre sayısı: ', (Length - l_iFillCount) );

  WriteLn;

  Randomize();

  for i := 0 to l_iFillCount - 1 do
  begin
    repeat

      y := Random( m_iVerticalLimit );
      x := Random( m_iHorizontalLimit );

    until (Self[ y, x ] <> DEFAULT_VALUE);

    Self[ y, x ] := DEFAULT_VALUE;
  end;
end;

procedure CMap.Display();
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
      V := Self[ y, x ];

      if (V <> 0) then
        l_strData := Chr(V)
      else
        l_strData := ' ';

      _Concat;
    end;

    WriteLn( y mod 10, ' ', l_strLine );
  end;
end;

procedure CMap.Fill();

  procedure _FindAndFill( const inData : CCell );

    function __Set : Boolean;
    begin
      if (not inData.IsForbidden) then
        begin
          inData.Value := FILL_VALUE;
          Result := True;
        end
      else
        Result := False;
    end;

  var
    l_objNeighbour : CCell;
    l_enmDirection : TDirection;
  begin
    if (__Set) then
      for l_enmDirection in [ Left..Bottom ] do
      begin
        l_objNeighbour := inData[ l_enmDirection ];

        if (l_objNeighbour <> nil) then
          _FindAndFill( l_objNeighbour );
      end;
  end;

var
  y, x : Integer;

begin
  Randomize();

  repeat
    y := Random( VERTICAL_LIMIT );
    x := Random( HORIZONTAL_LIMIT );
  until (not m_arrDatum[ y, x ].IsDefault);

  WriteLn;
  WriteLn( 'Başlangıç konum (y, x): ', y, ', ', x );
  WriteLn;

  _FindAndFill( m_arrDatum[ y, x ] );
end;

{$ENDREGION}

begin
  try

    with CMap.Create() do
    begin
      Make();

      Display();

      Fill();

      Display();
    end;

  except

    on l_objException : Exception do
      WriteLn( l_objException.ClassName(), ': ', l_objException.Message );

  end;

  ReadLn;
end.
