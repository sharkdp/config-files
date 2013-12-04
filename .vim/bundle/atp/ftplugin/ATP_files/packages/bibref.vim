" This file is a part of ATP.
" Written by M.Szamotulski.
" Based On: bibref package documentation 1995/09/28.
" :MakeLatex is not intergrated with makeindex command (using the arguments of
" \newindex commmand supplied with this package).

let g:atp_bibref_commands	= [
	    \ '\newindex{', '\makeindex', '\printindex', '\index', '\shortindexingon', '\shortindexingoff',
	    \ '\proofmodefalse', '\proofmodetrue', '\indexproofstyle{', '\disableindex', '\renewindex{'
	    \ ]
