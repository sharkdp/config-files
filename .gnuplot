set macros

set style line 1 linecolor rgb '#0033CC' linetype 1 linewidth 2
set style line 2 linecolor rgb '#00CC00' linetype 1 linewidth 2
set style line 3 linecolor rgb '#FF6600' linetype 1 linewidth 2
set style line 4 linecolor rgb '#FF0000' linetype 1 linewidth 2
set style line 5 linecolor rgb '#660099' linetype 1 linewidth 2
set style line 6 linecolor rgb '#009999' linetype 1 linewidth 2
set style line 7 linecolor rgb '#000000' linetype 1 linewidth 2
set style line 8 linecolor rgb '#888888' linetype 1 linewidth 2

set style line 11 linecolor rgb '#5c86ff' linetype 1 linewidth 2
set style line 21 linecolor rgb '#001c6f' linetype 1 linewidth 2
set style line 12 linecolor rgb '#00ff00' linetype 1 linewidth 2
set style line 22 linecolor rgb '#006a00' linetype 1 linewidth 2

set style line 15 linecolor rgb '#bb00dd' linetype 1 linewidth 2

set style line 31 linecolor rgb '#0033CC' linetype 2 linewidth 1
set style line 32 linecolor rgb '#00CC00' linetype 2 linewidth 1
set style line 33 linecolor rgb '#FF6600' linetype 2 linewidth 1
set style line 34 linecolor rgb '#FF0000' linetype 2 linewidth 1
set style line 37 linecolor rgb '#000000' linetype 2 linewidth 1
set style line 38 linecolor rgb '#888888' linetype 2 linewidth 1

BLUE = "ls 1"
GREEN = "ls 2"
ORANGE = "ls 3"
RED = "ls 4"
MAGENTA = "ls 5"
CYAN = "ls 6"
BLACK = "ls 7"
GRAY = "ls 8"

###### lighter / darker variants
LBLUE = "ls 11"
DBLUE = "ls 21"

LGREEN = "ls 12"
DGREEN = "ls 22"

LMAGENTA = "ls 15"

###### dashed
DBLUE = "ls 31"
DGREEN = "ls 32"
DORANGE = "ls 33"
DRED = "ls 34"
DBLACK = "ls 37"
DGRAY = "ls 38"

########################################################################

###### Palette by two hue values
h1 = 60/360.0
h2 = 227/360.0

HUE = "set palette model HSV functions (1-gray)*(h2-h1)+h1, 1, 0.78"

###### Matlab-style palette
MATLAB = "set palette defined (0  0.0 0.0 0.5, \
                   1  0.0 0.0 1.0, \
                   2  0.0 0.5 1.0, \
                   3  0.0 1.0 1.0, \
                   4  0.5 1.0 0.5, \
                   5  1.0 1.0 0.0, \
                   6  1.0 0.5 0.0, \
                   7  1.0 0.0 0.0, \
                   8  0.5 0.0 0.0 )"

###### Mathematica - like palette
MATHEMATICA = "set palette model HSV functions 180.0/256, (108.0-108*gray)/256, (80+140*gray)/256"

###### Rainbow
RAINBOW = "set palette rgbformulae 33,13,10"

###### Matlab 'Hot'-like palette
HOT = "set palette rgbformulae 34,35,36"

###### Ocean
OCEAN = "set palette rgbformulae 23,28,3"

###### Printable on b/w
BW = "set palette rgbformulae 30,31,32"

###### Violet - Green
VIOLETGREEN = "set palette defined (0 'royalblue',1 'magenta',3 'yellow',5 'green')"

###### Blue - Green
BLUEGREEN = "set palette defined (0 0 .2 .8, 1 0 0.8 0)"

###### Blue - Red
BLUERED = "set palette defined (0 0 .2 .8, 1 1 0 0)"

WXT = "set terminal wxt size 600,400 enhanced font 'Verdana,10' persist"
PNG = "set terminal pngcairo size 600,400 enhanced font 'Verdana,10'"
PDF = "set terminal pdfcairo size 4,3 enhanced font 'Verdana,10'"
SVG = "set terminal svg size 600,400 fname 'Verdana, Helvetica, Arial, sans-serif' fsize 10"
EPS = "set terminal postscript eps size 15,10 enhanced color font 'Helvetica,40' linewidth 5"
TEX = "set terminal epslatex size 4,3 standalone color colortext 10"
