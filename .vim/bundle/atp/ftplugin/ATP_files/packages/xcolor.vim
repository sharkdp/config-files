" This file is a part of ATP.
" Written by Marcin Szamotulski.

"This variable is a dictionary { 'package' : 'option' } which loads xcolor
"package, when option is empty means that the package is always loading.
"Both 'package' and 'option' are vim patterns.
let g:atp_xcolor_loading={ '\%(tikz\|pgf\|color\)' : '' } 

let g:atp_xcolor_options=[
	    \ 'dvips', 'xdvi', 'dvipdf', 'dvipdfm', 'dvipdfmx',
	    \ 'pdftex', 'dvipsone', 'dviwindo', 'emtex', 'dviwin',
	    \ 'pxtexps', 'pctexwin', 'pctexhp', 'pxtex32', 'truetex',
	    \ 'tcidvi', 'vtex', 'oztex', 'textrues', 'xetex',
	    \ 'monochrome', 
	    \ 'natural', 'rgb', 'cmy', 'cmyk', 'hsb', 'gray',
	    \ 'RGB', 'HTML', 'HSB', 'Gray',
	    \ 'dvipsnames', 'dvipsnames*', 'svgnames', 'svgnames*',
	    \ 'x11names', 'x11names*',
	    \ 'table', 'fixpdftex', 'hyperref',
	    \ 'prologue', 'kernelfbox', 'xcdraw', 'noxcdraw', 'fixinclude',
	    \ 'showerrors', 'hideerrors', 'debugshow'
	    \ ]

" These are obsolete options:
" 	    \ 'pst', 'override', 'usenames', 'nodvipsnames'
let g:atp_xcolor_commands=[
	    \ '\GetGinDriver', '\GinDriver', '\xcolorcmd',
	    \ '\rangeHsb',  '\rangeRGB', '\rangeHSB', '\rangeGray',
	    \ '\selectcolormodel{', '\ifconvertcolorsD', '\ifconvertcolorsU',
	    \ '\definecolor', '\providecolor{', '\colorlet{', '\definecolorset{',
	    \ '\providecolorset{', '\definecolorserites{', '\definecolors{',
	    \ '\providecolors{', '\DefineNamedColor{', '\preparecolor{',
	    \ '\preparecolorset{', '\ifdeinfecolors', '\xglobal', '\color{',
	    \ '\textcolor{', '\pagecolor{', '\colorbox{', '\fcolorbox{', 
	    \ '\boxframe', '\testcolor{', '\blendcolors', '\colormask', '\maskcolors{',
	    \ '\maskcolorstrue', '\ifmaskcolors', '\resetcolorseries{',
	    \ '\colorseriescycle{', '\rowcolors{', '\showrowcolors',
	    \ '\hiderowcolors', '\rownum', '\extractcolorspecs', '\tracingcolors',
	    \ 'convertcolorspecs{'
	    \ ]
let color_models = [ 'natural', 'rgb', 'cmy', 'cmyk', 'hsb', 'gray',
	    \ 'RGB', 'HTML', 'HSB', 'Gray', 'Hsb', 'tHsb', 'wave' ]
let g:atp_xcolor_command_values={
	    \ '\%(\\\%(text\|page\)\?color{\|\\colorbox{\|\\fcolorbox{\|\\fcolorbox{[^}]*}{\|\\testcolor{\|\\maskcolors\%(\[[^\]]*\]\|\\rowcolors\(\[[^\]]*\]\)\?{[^}]*}{\%([^}]*}{\)\?\)\?{\|color=\)$' : 'GetColors',
	    \ '\%(\\selectcolormodel\s*{\|\\maskcolors\[\|\\convertcolorspec{\)$' : color_models
	    \ }

" This function will be run by TabCompletion (atplib#complete#TabCompletion() in
" autoloac/atplib.vim) to get the color names.
function! GetColors()
    " Colors which always are defined:
    if exists("b:atp_LocalColors")
	let colors=b:atp_LocalColors
    else
	let colors=[]
    endif
    let colors=extend(colors,[ 'red', 'green', 'blue', 'cyan', 'magenta', 'yellow', 'black', 'gray', 'white', 'darkgray', 'lightgray', 'brown', 'lime', 'olive', 'orange', 'pink', 'purple', 'teal', 'violet' ])
    let line=getline(atplib#search#SearchPackage('xcolor'))
    if line =~ '\\usepackage\[[^\]]*\<dvipsnames\*\?\>'
	let add_colors = [
		    \	'Apricot',        'Cyan',        'Mahogany',     'ProcessBlue', 'SpringGreen',
		    \	'Aquamarine',     'Dandelion',   'Maroon',       'Purple',      'Tan',
		    \	'Bittersweet',    'DarkOrchid',  'Melon',        'RawSienna',   'TealBlue',
		    \	'Black',          'Emerald',     'MidnightBlue', 'Red',         'Thistle',
		    \	'Blue',           'ForestGreen', 'Mulberry',     'RedOrange',   'Turquoise',
		    \	'BlueGreen',      'Fuchsia',     'NavyBlue',     'RedViolet',   'Violet',
		    \	'BlueViolet',     'Goldenrod',   'OliveGreen',   'Rhodamine',   'VioletRed',
		    \	'BrickRed',       'Gray',        'Orange',       'RoyalBlue',   'White',
		    \	'Brown',          'Green',       'OrangeRed',    'RoyalPurple', 'WildStrawberry',
		    \	'BurntOrange',    'GreenYellow', 'Orchid',       'RubineRed',   'Yellow',
		    \	'CadetBlue',      'JungleGreen', 'Peach',        'Salmon',      'YellowGreen',
		    \	'CarnationPink',  'Lavender',    'Periwinkle',   'SeaGreen',    'YellowOrange',
		    \	'Cerulean',       'LimeGreen',   'PineGreen',    'Sepia',
		    \	'CornflowerBlue', 'Magenta',     'Plum',         'SkyBlue',
		    \ ]
    elseif line =~ '\\usepackage\[[^\]]*\<svgnames\*\?\>'
	let add_colors = [
		    \	'AliceBlue',      'DarkKhaki',      'Green',                'LightSlateGrey',
		    \	'AntiqueWhite',   'DarkMagenta',    'GreenYellow',          'LightSteelBlue',
		    \	'Aqua',           'DarkOliveGreen', 'Grey',                 'LightYellow',
		    \	'Aquamarine',     'DarkOrange',     'Honeydew',             'Lime',
		    \	'Azure',          'DarkOrchid',     'HotPink',              'LimeGreen',
		    \	'Beige',          'DarkRed',        'IndianRed',            'Linen',
		    \	'Bisque',         'DarkSalmon',     'Indigo',               'Magenta',
		    \	'Black',          'DarkSeaGreen',   'Ivory',                'Maroon',
		    \	'BlanchedAlmond', 'DarkSlateBlue',  'Khaki',                'MediumAquamarine',
		    \	'Blue',           'DarkSlateGray',  'Lavender',             'MediumBlue',
		    \	'BlueViolet',     'DarkSlateGrey',  'LavenderBlush',        'MediumOrchid',
		    \	'Brown',          'DarkTurquoise',  'LawnGreen',            'MediumPurple',
		    \	'BurlyWood',      'DarkViolet',     'LemonChiffon',         'MediumSeaGreen',
		    \	'CadetBlue',      'DeepPink',       'LightBlue',            'MediumSlateBlue',
		    \	'Chartreuse',     'DeepSkyBlue',    'LightCoral',           'MediumSpringGreen',
		    \	'Chocolate',      'DimGray',        'LightCyan',            'MediumTurquoise',
		    \	'Coral',          'DimGrey',        'LightGoldenrod',       'MediumVioletRed',
		    \	'CornflowerBlue', 'DodgerBlue',     'LightGoldenrodYellow', 'MidnightBlue',
		    \	'Cornsilk',       'FireBrick',      'LightGray',            'MintCream',
		    \	'Crimson',        'FloralWhite',    'LightGreen',           'MistyRose',
		    \	'Cyan',           'ForestGreen',    'LightGrey',            'Moccasin',
		    \	'DarkBlue',       'Fuchsia',        'LightPink',            'NavajoWhite',
		    \	'DarkCyan',       'Gainsboro',      'LightSalmon',          'Navy',
		    \	'DarkGoldenrod',  'GhostWhite',     'LightSeaGreen',        'NavyBlue',
		    \	'DarkGray',       'Gold',           'LightSkyBlue',         'OldLace',
		    \	'DarkGreen',      'Goldenrod',      'LightSlateBlue',       'Olive',
		    \	'DarkGrey',       'Gray',           'LightSlateGray',       'OliveDrab',
		    \	'Orange',        'Plum',        'Sienna',      'Thistle',
		    \	'OrangeRed',     'PowderBlue',  'Silver',      'Tomato',
		    \	'Orchid',        'Purple',      'SkyBlue',     'Turquoise',
		    \	'PaleGoldenrod', 'Red',         'SlateBlue',   'Violet',
		    \	'PaleGreen',     'RosyBrown',   'SlateGray',   'VioletRed',
		    \	'PaleTurquoise', 'RoyalBlue',   'SlateGrey',   'Wheat',
		    \	'PaleVioletRed', 'SaddleBrown', 'Snow',        'White',
		    \	'PapayaWhip',    'Salmon',      'SpringGreen', 'WhiteSmoke',
		    \	'PeachPuff',     'SandyBrown',  'SteelBlue',   'Yellow',
		    \	'Peru',          'SeaGreen',    'Tan',         'YellowGreen',
		    \	'Pink',          'Seashell',    'Teal',
		    \ ]
    elseif line =~ '\\usepackage\[[^\]]*\<x11names\*\?\>'
	let add_colors = [
		    \	'AntiqueWhite1', 'Chocolate3',      'DeepPink1',    'IndianRed3',
		    \ 	'AntiqueWhite2', 'Chocolate4',      'DeepPink2',    'IndianRed4',
		    \	'AntiqueWhite3', 'Coral1',          'DeepPink3',    'Ivory1',
		    \	'AntiqueWhite4', 'Coral2',          'DeepPink4',    'Ivory2',
		    \	'Aquamarine1',   'Coral3',          'DeepSkyBlue1', 'Ivory3',
		    \	'Aquamarine2',   'Coral4',          'DeepSkyBlue2', 'Ivory4',
		    \	'Aquamarine3',   'Cornsilk1',       'DeepSkyBlue3', 'Khaki1',
		    \	'Aquamarine4',   'Cornsilk2',       'DeepSkyBlue4', 'Khaki2',
		    \	'Azure1',        'Cornsilk3',       'DodgerBlue1',  'Khaki3',
		    \	'Azure2',        'Cornsilk4',       'DodgerBlue2',  'Khaki4',
		    \	'Azure3',        'Cyan1',           'DodgerBlue3',  'LavenderBlush1',
		    \	'Azure4',        'Cyan2',           'DodgerBlue4',  'LavenderBlush2',
		    \	'Bisque1',       'Cyan3',           'Firebrick1',   'LavenderBlush3',
		    \	'Bisque2',       'Cyan4',           'Firebrick2',   'LavenderBlush4',
		    \	'Bisque3',       'DarkGoldenrod1',  'Firebrick3',   'LemonChiffon1',
		    \	'Bisque4',       'DarkGoldenrod2',  'Firebrick4',   'LemonChiffon2',
		    \	'Blue1',         'DarkGoldenrod3',  'Gold1',        'LemonChiffon3',
		    \	'Blue2',         'DarkGoldenrod4',  'Gold2',        'LemonChiffon4',
		    \	'Blue3',         'DarkOliveGreen1', 'Gold3',        'LightBlue1',
		    \	'Blue4',         'DarkOliveGreen2', 'Gold4',        'LightBlue2',
		    \	'Brown1',        'DarkOliveGreen3', 'Goldenrod1',   'LightBlue3',
		    \	'Brown2',        'DarkOliveGreen4', 'Goldenrod2',   'LightBlue4',
		    \	'Brown3',        'DarkOrange1',     'Goldenrod3',   'LightCyan1',
		    \	'Brown4',        'DarkOrange2',     'Goldenrod4',   'LightCyan2',
		    \	'Burlywood1',    'DarkOrange3',     'Green1',       'LightCyan3',
		    \	'Burlywood2',    'DarkOrange4',     'Green2',       'LightCyan4',
		    \	'Burlywood3',    'DarkOrchid1',     'Green3',       'LightGoldenrod1',
		    \	'Burlywood4',    'DarkOrchid2',     'Green4',       'LightGoldenrod2',
		    \	'CadetBlue1',    'DarkOrchid3',     'Honeydew1',    'LightGoldenrod3',
		    \	'CadetBlue2',    'DarkOrchid4',     'Honeydew2',    'LightGoldenrod4',
		    \	'CadetBlue3',    'DarkSeaGreen1',   'Honeydew3',    'LightPink1',
		    \	'CadetBlue4',    'DarkSeaGreen2',   'Honeydew4',    'LightPink2',
		    \	'Chartreuse1',   'DarkSeaGreen3',   'HotPink1',     'LightPink3',
		    \	'Chartreuse2',   'DarkSeaGreen4',   'HotPink2',     'LightPink4',
		    \	'Chartreuse3',   'DarkSlateGray1',  'HotPink3',     'LightSalmon1',
		    \	'Chartreuse4',   'DarkSlateGray2',  'HotPink4',     'LightSalmon2',
		    \	'Chocolate1',    'DarkSlateGray3',  'IndianRed1',   'LightSalmon3',
		    \	'Chocolate2',    'DarkSlateGray4',  'IndianRed2',   'LightSalmon4',
		    \	'ghtSkyBlue1',   'Orange3',        'RosyBrown1',   'SpringGreen3',
		    \	'LightSkyBlue2',   'Orange4',        'RosyBrown2',   'SpringGreen4',
		    \	'LightSkyBlue3',   'OrangeRed1',     'RosyBrown3',   'SteelBlue1',
		    \	'LightSkyBlue4',   'OrangeRed2',     'RosyBrown4',   'SteelBlue2',
		    \	'LightSteelBlue1', 'OrangeRed3',     'RoyalBlue1',   'SteelBlue3',
		    \	'LightSteelBlue2', 'OrangeRed4',     'RoyalBlue2',   'SteelBlue4',
		    \	'LightSteelBlue3', 'Orchid1',        'RoyalBlue3',   'Tan1',
		    \	'LightSteelBlue4', 'Orchid2',        'RoyalBlue4',   'Tan2',
		    \	'LightYellow1',    'Orchid3',        'Salmon1',      'Tan3',
		    \	'LightYellow2',    'Orchid4',        'Salmon2',      'Tan4',
		    \	'LightYellow3',    'PaleGreen1',     'Salmon3',      'Thistle1',
		    \	'LightYellow4',    'PaleGreen2',     'Salmon4',      'Thistle2',
		    \	'Magenta1',        'PaleGreen3',     'SeaGreen1',    'Thistle3',
		    \	'Magenta2',        'PaleGreen4',     'SeaGreen2',    'Thistle4',
		    \	'Magenta3',        'PaleTurquoise1', 'SeaGreen3',    'Tomato1',
		    \	'Magenta4',        'PaleTurquoise2', 'SeaGreen4',    'Tomato2',
		    \	'Maroon1',         'PaleTurquoise3', 'Seashell1',    'Tomato3',
		    \	'Maroon2',         'PaleTurquoise4', 'Seashell2',    'Tomato4',
		    \	'Maroon3',         'PaleVioletRed1', 'Seashell3',    'Turquoise1',
		    \	'Maroon4',         'PaleVioletRed2', 'Seashell4',    'Turquoise2',
		    \	'MediumOrchid1',   'PaleVioletRed3', 'Sienna1',      'Turquoise3',
		    \	'MediumOrchid2',   'PaleVioletRed4', 'Sienna2',      'Turquoise4',
		    \	'MediumOrchid3',   'PeachPuff1',     'Sienna3',      'VioletRed1',
		    \	'MediumOrchid4',   'PeachPuff2',     'Sienna4',      'VioletRed2',
		    \	'MediumPurple1',   'PeachPuff3',     'SkyBlue1',     'VioletRed3',
		    \	'MediumPurple2',   'PeachPuff4',     'SkyBlue2',     'VioletRed4',
		    \	'MediumPurple3',   'Pink1',          'SkyBlue3',     'Wheat1',
		    \	'MediumPurple4',   'Pink2',          'SkyBlue4',     'Wheat2',
		    \	'MistyRose1',      'Pink3',          'SlateBlue1',   'Wheat3',
		    \	'MistyRose2',      'Pink4',          'SlateBlue2',   'Wheat4',
		    \	'MistyRose3',      'Plum1',          'SlateBlue3',   'Yellow1',
		    \	'MistyRose4',      'Plum2',          'SlateBlue4',   'Yellow2',
		    \	'NavajoWhite1',    'Plum3',          'SlateGray1',   'Yellow3',
		    \	'NavajoWhite2',    'Plum4',          'SlateGray2',   'Yellow4',
		    \	'NavajoWhite3',    'Purple1',        'SlateGray3',   'Gray0',
		    \	'NavajoWhite4',    'Purple2',        'SlateGray4',   'Green0',
		    \	'OliveDrab1',      'Purple3',        'Snow1',        'Grey0',
		    \	'OliveDrab2',      'Purple4',        'Snow2',        'Maroon0',
		    \	'OliveDrab3',      'Red1',           'Snow3',        'Purple0',
		    \ 	'OliveDrab4',      'Red2',           'Snow4',
		    \ 	'Orange1',         'Red3',           'SpringGreen1',
		    \ 	'Orange2',         'Red4',           'SpringGreen2'
		    \ ]
    else
	let add_colors=[]
    endif
    call extend(colors, add_colors)
    return colors
endfunction
