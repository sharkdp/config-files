" This file is a part of ATP.
" Author: Marcin Szamotulski
" Based On: cite 2010/09/10

let g:atp_cite_options 	= [
	    \ 'nobreaks', 'superscript', 'ref', 'nospace', 'space',
	    \ 'nosort', 'sort', 'nomove', 'move', 'noadjust', 'adjust',
	    \ 'nocompress', 'compress', 'biblabel'
	    \ ]
let g:atp_pacakge_cite_commands = [
	    \ '\citen', '\citenum', '\citeform{', '\citepunct{', '\citeleft{',
	    \ '\citeright{', '\citemid{', '\citedash{', '\OverciteFont',
	    \ '\citeonline', '\citepunctpenalty', 
	    \ '\citemidpenalty', '\citeprepenalty', '\CiteMoveChars',
	    \ ]

if atplib#search#SearchPackage('cite')
    syn region texRefZone         matchgroup=texStatement start="\\citen\([tp]\*\=\)\={"   keepend end="}\|%stopzone\>"  contains=texComment,texDelimiter
    syn region texRefZone         matchgroup=texStatement start="\\citenum\([tp]\*\=\)\={"   keepend end="}\|%stopzone\>"  contains=texComment,texDelimiter
    syn region texRefZone         matchgroup=texStatement start="\\citeonline\([tp]\*\=\)\={"   keepend end="}\|%stopzone\>"  contains=texComment,texDelimiter
endif
