" This file is a part of ATP.
" Author: Marcin Szamotulski

let g:atp_stmaryrd_options = [
	    \ 'only', 'mapsfrom', 'Mapsto', 'Mapsfrom',
	    \ 'longarrownot', 'Longarrownot', 'arrownot', 'Arrownot',
	    \ 'longmapsto', 'Longmapsto', 'longmapsfrom', 'Longmapsfrom'
	    \ ]
let g:atp_stmaryrd_math_commands = [
	    \ '\Ydown',        '\Yleft',        '\Yright',
	    \ '\Yup',          '\baro',         '\bbslash',
	    \ '\binampersand', '\bindnasrepma', '\boxast',
	    \ '\boxbar',       '\boxbox',       '\boxbslash',
	    \ '\boxcircle',    '\boxdot',       '\boxempty',
	    \ '\boxslash',            '\curlyveedownarrow', '\curlyveeuparrow',
	    \ '\curlywedgedownarrow', '\curlywedgeuparrow', '\fatbslash',
	    \ '\fatsemi',             '\fatslash',          '\interleave',
	    \ '\leftslice',           '\merge',             '\minuso',
	    \ '\moo',                 '\nplus',             '\obar',
	    \ '\oblong',              '\obslash',           '\ogreaterthan',
	    \ '\olessthan',           '\ovee',              '\owedge',
	    \ '\rightslice',          '\sslash',            '\talloblong',
	    \ '\varbigcirc',          '\varcurlyvee',       '\varcurlywedge',
	    \ '\varoast',             '\varobar',           '\varobslash',
	    \ '\varocircle',          '\varodot',           '\varogreaterthan',
	    \ '\varolessthan',        '\varominus',         '\varoplus',
	    \ '\varoslash',           '\varotimes',         '\varovee',
	    \ '\varowedge',           '\vartimes',
	    \ '\bigbox',        	    	'\bigcurlyvee',     '\bigcurlywedge',
	    \ '\biginterleave', 		'\bignplus',        '\bigparallel',
	    \ '\bigsqcap',      		'\bigtriangledown', '\bigtriangleup',
	    \ '\inplus',                '\niplus',       '\ntrianglelefteqslant',
	    \ '\ntrianglerighteqslant', '\subsetplus',   '\subsetpluseq',
	    \ '\supsetplus',            '\supsetpluseq', '\trianglelefteqslant',
	    \ '\trianglerighteqslant',
	    \ '\Longmapsfrom',            '\Longmapsto',         '\Mapsfrom',
	    \ '\Mapsto',                  '\leftarrowtriangle',  '\leftrightarroweq',
	    \ '\leftrightarrowtriangle',  '\lightning',          '\longmapsfrom',
	    \ '\mapsfrom',                '\nnearrow',           '\nnwarrow',
	    \ '\rightarrowtriangle',      '\rrparenthesis',      '\shortdownarrow',
	    \ '\shortleftarrow',          '\shortrightarrow',    '\shortuparrow',
	    \ '\ssearrow',                '\sswarrow',
	    \ '\Lbag',          '\Rbag',    '\lbag',
	    \ '\llbracket',     '\llceil',  '\llfloor',
	    \ '\llparenthesis', '\rbag',    '\rrbracket',
	    \ '\rrceil',        '\rrfloor',
	    \ '\Arrownot', '\Mapsfromchar', '\Mapstochar',
	    \ '\arrownot', '\mapsfromchar',
	    \ ]
if atplib#search#SearchPackage('amssymb')
    call extend(g:atp_stmaryrd_math_commands, [ '\oast', '\ocircle' ])
endif

