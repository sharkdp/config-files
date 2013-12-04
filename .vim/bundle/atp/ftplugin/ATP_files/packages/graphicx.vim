" This file is a part of ATP.
" Written by Marcin Szamotulski <atp-list@lists.sourceforge.net>

let g:atp_graphicx_options=['xdvi', 'dvipdf',
	\ 'dvipdfm', 'pdftex', 'dvipsone', 'dviwindo', 'emtex', 'dviwin', 'oztex',
	\ 'textures', 'pctexps', 'pctexwin', 'pctexhp', 'pctex32', 'truetex', 'tcidvi',
	\ 'vtex', 'debugshow', 'draft', 'final', 'hiderotate', 'hiresbb',
	\ 'hidescale', 'unknownkeysallowed', 'unknownkeyserror']
let g:atp_graphicx_commands=[
	\ '\rotatebox{', '\scalebox{', '\resizebox{', '\includegraphics{', '\DeclareGraphicsExtensions{',
	\ '\DeclareGraphicsRule{'
	\ ]
let g:atp_graphicx_command_optional_values = {
	    \ '\\includegraphics\>' : ['bb', 'bbllx', 'bblly', 'bburx', 'bbury', 'natwidth', 'natheight',
		    \ 'hiresbb', 'viewport', 'trim', 'angle', 'origin', 'width', 'height', 'totalheight',
		    \ 'keepaspectratio', 'scale', 'clip', 'draft', 'type', 'ext', 'read', 'command'],
	    \ }
