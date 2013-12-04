" This file is a part of ATP.
" Written by Marcin Szamotulski
let g:atp_ntheorem_options	= [
	    \ 'thmmarks', 'amsmath', 'thref' 
	    \ ]
let g:atp_ntheorem_commands	= [ 
	    \ '\newtheorem{', '\renewtheorem{',
	    \ '\theorempreskipamount{', '\theorempostskipamount{',
	    \ '\theoremstyle{', '\theoremheadfont{', '\theorembodyfont{',
	    \ '\theoremseparator{', '\theoremprework{', '\theorempostwork{',
	    \ '\theoremindent{', '\theoremnumbering{', '\theoremsymbol{',
	    \ '\theoremclass{', '\newframedtheorem{', '\newshadedtheorem{',
	    \ '\shadecolor{', '\listtheorems{', '\theoremlisttype{',
	    \ '\addtheoremline{', '\addtotheoremline{', '\newtheoremstyle{',
	    \ '\qed', '\qedsymbol', '\NoEndMark', '\TheoremSymbol', '\thref'
	    \ ]
let s:colors = ( exists("b:atp_LocalColors") ? b:atp_LocalColors : [] )
let g:atp_ntheorem_command_values = {
	    \ '\\theoremstyle{' : [ 'plain', 'break', 'change', 'changebreak', 'margin',
				\ 'marginbreak', 'nonumberplain', 'nonumberbreak', 'empty' ],
	    \ '\\shadecolor{' : s:colors, 
	    \ '\\theoremlisttype{' : [ 'all', 'allname', 'opt', 'optname' ]
	    \ }
