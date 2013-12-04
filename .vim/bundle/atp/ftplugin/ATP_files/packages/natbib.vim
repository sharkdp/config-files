" This file is a part of ATP.
" Author: Marcin Szamotulski
" Based On: cite 2010/09/10

" Todo: move \cite completion here and add it dor \shorcites{} command.
let g:atp_natbib_options = [
	    \ 'round', 'square', 'curly', 'angle', 'semicolon', 'colon', 'comma', 'comma', 'authoryear',
	    \ 'numbers', 'super', 'sort', 'sort&compress', 'compress', 'longnamesfirst', 'sectionbib', 
	    \ 'nonamebreak', 'merge', 'elide', 'mcite'
	    \ ]

" This is not working:
let g:atp_natbib_commands = [
	    \ '\citet', '\citep', '\citet*', '\citep*', '\citealt', '\citealp', '\citetext', '\citenum',
	    \ '\citeauthor', '\citeauthor*', '\citeyear', '\Citealt', '\Citealp', '\Citeauthor', 
	    \ '\defcitealias', '\citetalias', '\citepalias', '\setcitestyle{', '\bibpunct{',
	    \ '\citestyle{', '\bibsection', '\bibpreambule', '\bibfont', '\citenumfont', '\bibnumfmt',
	    \ '\bibhang', '\bibsep', '\citeindextrue', '\citeindexfalse', '\shortcites{', '\citestyle{'
	    \ ]
let g:atp_natbib_command_values = {
	    \ '\\setcitestyle\s*{\%(\%([^}]\|{[^}]*}\)*,\)\=$' : ['authoryear', 'numbers', 'super',
						\ 'square', 'open={', 'colse={', 'semicolon',
						\ 'comma', 'citesep={', 'aysep={', 'yysep={',
						\ 'notesep={'
						\ ],
	    \ '\\citestyle{$' : [ 'plain', 'plainnat', 'agu', 'egu', 'agms', 'dcu', 'kulwer', 'cospar', 'nature']
	    \ }
