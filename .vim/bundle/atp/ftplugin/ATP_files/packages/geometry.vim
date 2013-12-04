" This file was based on geometry.pdf 2010/09/12 v5.6
" Maintained by Marcin Szamotulski <atp-list@lists.sourceforge.net>
let g:atp_geometry_options=[
    \ 'verbose', 'landscape', 'portrait', 'twoside',
    \ 'includemp', 'reversemp', 'reversemarginpar', 'nohead', 'nofoot', 'noheadfoot',
    \ 'dvips', 'pdftex', 'vtex', 'truedimen', 'reset', 
    \ 'a0paper', 'a1paper', 'a2paper', 'a3paper', 'a4paper', 'a5paper', 'a6paper', 
    \ 'b0paper', 'b1paper', 'b2paper', 'b3paper', 'b4paper', 'b5paper', 'b6paper', 
    \ 'c0paper', 'c1paper', 'c2paper', 'c3paper', 'c4paper', 'c5paper', 'c6paper', 
    \ 'b0j', 'b1j', 'b2j', 'b3j', 'b4j', 'b5j', 'b6j',
    \ 'ansiapaper', 'ansibpaper', 'ansibpaper', 'ansicpaper', 'ansidpaper', 'ansiepaper',
    \ 'letterpaper', 'executivepaper', 'legalpaper', 
    \ 'paper=', 'papername=', 'paperwidth=', 'paperheight=', 'width=', 'totalwidth=',
    \ 'height=', 'totalheight=', 'left=', 'lmargin=', 'inner', 'right=', 'rmargin=', 'outer',
    \ 'top=', 'tmargin=', 'bottom=', 'bmargin=', 'hscale=', 'vscale=',
    \ 'textwidth=', 'textheight=', 'marginparwidth=', 'marginpar=', 'marginparsep=', 'headheight=',
    \ 'head=', 'headsep=', 'footskip=', 'hoffset=', 'voffset=', 'twosideshift=',
    \ 'mag=', 'columnsep=', 'footnotesep=', 'papersize={', 'total={',
    \ 'body={', 'text={', 'scale={', 'hmargin={', 'vmargin={', 'margin={',
    \ 'offset={', 'hdivide={', 'vdivide={', 'divide={', 'screen', 'layout=',
    \ 'layoutwidth=', 'layoutheight=', 'layouthoffset=', 'layoutvoffset=', 'layoutoffset={',
    \ 'layoutsize=', 'lines', 'includehead', 'includefoot', 'includeheadfoot', 'includeall', 
    \ 'ignorehead', 'ignorefoot', 'ignoreheadfoot', 'ignoreall', 'heightrounded',
    \ 'hmarginratio', 'vmarginratio', 'marginratio', 'ratio', 'hcentering', 'vcentering', 
    \ 'centering', 'nomarginpar', 'twocolumn', 'onecolumn', 'driver=', 'showcrop', 'showframe',
    \ 'assymetric', 'bindingoffset', 'pass'
    \ ]
let g:atp_geometry_options_values = {
    \ '\%(layout\|paper\|papername\)\>' : [ 
	\ 'a0paper', 'a1paper', 'a2paper', 'a3paper', 'a4paper', 'a5paper', 'a6paper',
	\ 'b0paper', 'b1paper', 'b2paper', 'b3paper', 'b4paper', 'b5paper', 'b6paper', 
	\ 'c0paper', 'c1paper', 'c2paper', 'c3paper', 'c4paper', 'c5paper', 'c6paper', 
	\ 'b0j', 'b1j', 'b2j', 'b3j', 'b4j', 'b5j', 'b6j',
	\ 'ansiapaper', 'ansibpaper', 'ansibpaper', 'ansicpaper', 'ansidpaper', 'ansiepaper',
	\ 'letterpaper', 'executivepaper', 'legalpaper'],
    \ 'driver\>' : [ 'dvips', 'dvipdfm', 'pdftex', 'vtex', 'xetex', 'auto', 'none' ] 
    \ } 
let g:atp_geometry_commands=[
    \ '\geometry{', '\newgeometry{', '\savegeometry{', '\restoregeometry', '\loadgeometry{',
    \ ]
