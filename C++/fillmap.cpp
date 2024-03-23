//
// fillmap.cpp
//
// Author:
//       Hakan Emre Kartal <hek@nula.com.tr>
//
// Copyright (c) 2023 Hakan Emre Kartal
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
#include <stdio.h>
#include <strings.h>
#include <stdlib.h>
#include <conio.h>
#include <time.h>

#define VERTICAL_LIMIT        20
#define HORIZONTAL_LIMIT      20

#define LINE_LENGTH           (HORIZONTAL_LIMIT * 2)
#define DATA_LENGTH           (3)

#define DEFAULT_VALUE         '.'
#define FILL_VALUE            '@'

#define DEFAULT_VALUE_RATIO   0.35f

#define __validate_top(y)((y) >= (0))
#define __validate_bottom(y)((y) < (VERTICAL_LIMIT))

#define __validate_left(x)((x) >= (0))
#define __validate_right(x)((x) < (HORIZONTAL_LIMIT))

#define __validate_row(y)(__validate_top((y)) && __validate_bottom((y)))
#define __validate_column(x)(__validate_left((x)) && __validate_right((x)))

#define __is_forbidden(v)(((v) == DEFAULT_VALUE) || ((v) == FILL_VALUE))

typedef \
   char map_t[ VERTICAL_LIMIT ][ HORIZONTAL_LIMIT ];

enum direction_t : int
{
   LEFT,
   TOP,
   RIGHT,
   BOTTOM
};

struct dot_t
{

   int   y,
         x;

public:

   dot_t( int inY, int inX )
   {
      y = inY;
      x = inX;
   }

   bool moveto( const direction_t inDirection, dot_t &outNew ) const
   {
      int
         _y = (y),
         _x = (x);
      bool
         l_bResult = false;

      switch (inDirection)
      {
         case direction_t::LEFT:
            l_bResult = __validate_left(--_x);
            break;

         case direction_t::TOP:
            l_bResult = __validate_top(--_y);
            break;

         case direction_t::RIGHT:
            l_bResult = __validate_right(++_x);
            break;

         case direction_t::BOTTOM:
            l_bResult = __validate_bottom(++_y);
            break;
      }

      if (l_bResult)
      {
         outNew = dot_t( _y, _x );
      }

      return l_bResult;
   }
};

char *_concat( char *inTarget, const char *inSource )
{
   return (strlen( inTarget ) == 0) ? strcpy( inTarget, inSource ) : strcat( strcat( inTarget, " " ), inSource );
}

void display( const map_t inMap )
{
   char
      V;
   int
      y, x;
   char
      l_strLine[ LINE_LENGTH ] = { 0 },
      l_strData[ DATA_LENGTH ] = { 0, 0, 0 };

   for (x = 0; x < HORIZONTAL_LIMIT; x++)
   {
      _concat( l_strLine, itoa( x % 10, &l_strData[ 0 ], 10 ) );
   }

   printf( "  %s\r\n", l_strLine );

   for (y = 0; y < VERTICAL_LIMIT; y++)
   {
      l_strLine[ 0 ] = '\x0';

      for (x = 0; x < HORIZONTAL_LIMIT; x++)
      {
         _concat( &l_strLine[ 0 ], &(l_strData[ 0 ] = (((V = inMap[ y ][ x ]) != '\0') ? (V) : ('\x20'))) );
      }

      printf( "%d %s\r\n", y % 10, l_strLine );
   }
}

void start( map_t& ioMap )
{
   int
      l_iEntryCount = (int)((VERTICAL_LIMIT * HORIZONTAL_LIMIT) * DEFAULT_VALUE_RATIO),
      i, y, x;

   srand( time( NULL ) );

   for (i = 0; i < l_iEntryCount; i++)
   {
      do
      {
         y = rand() % VERTICAL_LIMIT;
         x = rand() % HORIZONTAL_LIMIT;
      }
      while (__is_forbidden(ioMap[ y ][ x ]));

      ioMap[ y ][ x ] = DEFAULT_VALUE;
   }
}

void find_and_fill( map_t &ioMap, dot_t inDot )
{
   if (__is_forbidden(ioMap[ inDot.y ][ inDot.x ]))
   {
      return;
   }

   ioMap[ inDot.y ][ inDot.x ] = FILL_VALUE;

   dot_t
      l_varDot = dot_t( -1, -1 );

   for (int l_iDirection = direction_t::LEFT; l_iDirection <= direction_t::BOTTOM; l_iDirection++)
   {
      if (inDot.moveto( (direction_t)l_iDirection, l_varDot ))
      {
         find_and_fill( ioMap, l_varDot );
      }
   }
}

void fill( map_t& ioMap )
{
   int
      y, x;

   srand( time( NULL ) );

   do
   {
      y = rand() % VERTICAL_LIMIT;
      x = rand() % HORIZONTAL_LIMIT;
   }
   while (ioMap[ y ][ x ] == DEFAULT_VALUE);

   printf( "\r\nBaslangic konum (y, x): %d, %d\r\n\r\n", y, x );

   find_and_fill( ioMap, dot_t( y, x ) );
}

int main()
{
   map_t
      l_arrMap;

   memset( &l_arrMap[ 0 ][ 0 ], 0, sizeof(map_t) );

   start( l_arrMap );

   display( l_arrMap );

   fill( l_arrMap );

   display( l_arrMap );
}
