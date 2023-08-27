program fillmap;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils;

//
// veteran
// 25-08-2023
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
// Problem: Baþlangıçta verilen mxn boyutlu ve varsayılanda bir desene sahip harita veriliyor.
// Haritanın eş parçalara bölünerek, her parçanın rastgele seçilen ve boş bir noktadan başlayarak-
// boşluklarının eş zamansız (asynch) ve paralel (multi task) şekilde doldurulması istenmektedir.
//
// Kural: eğer bir nokta "varsayılan" deer ile doluysa o nokta geçilmeli ve doğru yol bulunarak -
// boşluk doldurulmaya devam edilmelidir.
//
// Başlangıç deseni:
// -----------------
//
//   0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9
// 0     · ·                     ·     ·
// 1   · ·   ·                 · ·
// 2   ·           ·           · · ·   ·
// 3     ·             ·         · ·   ·
// 4   · ·           · ·         · ·   ·
// 5           ·     ·           ·
// 6   ·   ·             ·                 ·
// 7     ·             · ·   ·   ·   ·
// 8                 · ·   ·   ·   ·
// 9           ·           ·       · ·     ·
// 0   · ·             · ·     · ·
// 1         ·     · ·           · ·
// 2       ·                 ·             ·
// 3           ·         · ·     ·   ·
// 4                   ·     ·     ·     ·
// 5 ·             ·     ·
// 6     ·           ·         ·     ·
// 7                         ·           · ·
// 8   ·   · ·             ·   ·   ·     · ·
// 9   · · ·       · · ·           ·     · ·
//
// Sonuç:
// ------
//
// Başlangıç konum (y, x): 13, 8
//
//   0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9
// 0 @ @ · · @ @ @ @ @ @ @ @ @ @ · @ @ · @ @
// 1 @ · · @ · @ @ @ @ @ @ @ @ · · @ @ @ @ @
// 2 @ · @ @ @ @ @ · @ @ @ @ @ · · · @ · @ @
// 3 @ @ · @ @ @ @ @ @ · @ @ @ @ · · @ · @ @
// 4 @ · · @ @ @ @ @ · · @ @ @ @ · · @ · @ @
// 5 @ @ @ @ @ · @ @ · @ @ @ @ @ · @ @ @ @ @
// 6 @ · @ · @ @ @ @ @ @ · @ @ @ @ @ @ @ @ ·
// 7 @ @ · @ @ @ @ @ @ · · @ · @ · @ · @ @ @
// 8 @ @ @ @ @ @ @ @ · · @ · @ · @ · @ @ @ @
// 9 @ @ @ @ @ · @ @ @ @ @ · @ @ @ · · @ @ ·
// 0 @ · · @ @ @ @ @ @ · · @ @ · · @ @ @ @ @
// 1 @ @ @ @ · @ @ · · @ @ @ @ @ · · @ @ @ @
// 2 @ @ @ · @ @ @ @ @ @ @ @ · @ @ @ @ @ @ ·
// 3 @ @ @ @ @ · @ @ @ @ · · @ @ · @ · @ @ @
// 4 @ @ @ @ @ @ @ @ @ · @ @ · @ @ · @ @ · @
// 5 · @ @ @ @ @ @ · @ @ · @ @ @ @ @ @ @ @ @
// 6 @ @ · @ @ @ @ @ · @ @ @ @ · @ @ · @ @ @
// 7 @ @ @ @ @ @ @ @ @ @ @ @ · @ @ @ @ @ · ·
// 8 @ · @ · · @ @ @ @ @ @ · @ · @ · @ @ · ·
// 9 @ · · · @ @ @ · · · @ @ @ @ @ · @ @ · ·
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
  TMap = packed array[ 0..(VERTICAL_LIMIT - 1), 0..(HORIZONTAL_LIMIT - 1) ] of Byte;

  TDirection = (Left, Top, Right, Bottom);

  TDot = packed record
  public var
    y,
    x : Integer;
  public
    constructor Create( const inY, inX    : Integer );

    function    Move  ( const inDirection : TDirection;
                        var outNew        : TDot ) : Boolean;
  end;

{$REGION ' TDot '}

// Public

constructor TDot.Create( const inY, inX : Integer );
begin
  y := inY;
  x := inX;
end;

function TDot.Move( const inDirection : TDirection; var outNew : TDot ) : Boolean;
var
  _y, _x : Integer;
begin
  _y := y;
  _x := x;

  case (inDirection) of
    (Left   ): _x := Pred( _x );
    (Top    ): _y := Pred( _y );
    (Right  ): _x := Succ( _x );
    (Bottom ): _y := Succ( _y );
  end;

  if (((_y >= 0) and (_y < VERTICAL_LIMIT)) and ((_x >= 0) and (_x < HORIZONTAL_LIMIT))) then
    begin
      outNew := TDot.Create( _y, _x );
      Result := True;
    end
  else
    Result := False;
end;

{$ENDREGION}

procedure Display( const inBitmap : TMap );
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
      V := inBitmap[ y, x ];

      if (V <> 0) then
        l_strData := Chr(V)
      else
        l_strData := ' ';

      _Concat;
    end;

    WriteLn( y mod 10, ' ', l_strLine );
  end;
end;

procedure Start( var ioBitmap : TMap );
var
  l_iEntryCount,
  i, y, x : Integer;
begin
  FillChar( ioBitmap, SizeOf(TMap), 0 );

  Randomize();

  l_iEntryCount := Round( (VERTICAL_LIMIT * HORIZONTAL_LIMIT) * 0.25 );


  for i := 0 to (l_iEntryCount - 1) do
  begin
    repeat
      y := Random( VERTICAL_LIMIT );
      x := Random( HORIZONTAL_LIMIT );
    until (ioBitmap[ y, x ] <> DEFAULT_VALUE);

    ioBitmap[ y, x ] := DEFAULT_VALUE;
  end;
end;

procedure Fill( var ioBitmap : TMap );

  procedure _FindAndFill( const inDot : TDot );

    function __Set : Boolean;
    begin
      with (inDot) do
        if (not (ioBitmap[ y, x ] in [ DEFAULT_VALUE, FILL_VALUE ])) then
          begin
            ioBitmap[ y, x ] := FILL_VALUE;
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
        l_varDot := inDot;

        if (l_varDot.Move( l_enmDirection, l_varDot )) then
          _FindAndFill( l_varDot );
      end;
  end;

var
  y, x : Integer;

begin
  Randomize();

  repeat
    y := Random( VERTICAL_LIMIT );
    x := Random( HORIZONTAL_LIMIT );
  until (ioBitmap[ y, x ] <> DEFAULT_VALUE);

  WriteLn;
  WriteLn( 'Baþlangýç konum (y, x): ', y, ', ', x );
  WriteLn;

  _FindAndFill( TDot.Create( y, x ) );
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
