" This file is a part of ATP.
" Written by Marcin Szamotulski
" based on cancel.sty v2.1
let g:atp_cancel_options 	= [
	    \ 'samesize', 'smaller', 'Smaller'
	    \ ]
let g:atp_cancel_commands	= [
	    \ '\cancel{', '\cancelto{', '\bcancel{', '\xcancel{',
	    \ ]
" let colors= ( exists("b:atp_LocalColors") ? b:atp_LocalColors : [] )
" these should be color commands \blue rather than just a color - I should
" check this.
" let g:atp_cancel_command_values={
" 	    \ '\\CancelColor' : colors
" 	    \ }
