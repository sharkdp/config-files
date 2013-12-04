" This file is based on package file of latex-suite written by
" Andreas Wagner <Andreas dot Wagner at em dot uni-frankfurt dot de>
" adapted to ATP by Marcin Szamotulski <atp-list@lists.sourceforge.net>
let g:atp_biblatex_options=[
    \ 'style=', 'citestyle=', 'bibstyle=', 'natbib=', 'sorting=', 'sortlos=',
    \ 'sortcites=', 'maxnames=', 'minnames=', 'maxitems=', 'minitems=', 'autocite=',
    \ 'autopunct=', 'babel=', 'block=', 'hyperref=', 'backref=', 'indexing=',
    \ 'loadfiles=', 'refsection=', 'refsegment=', 'citereset=', 'abbreviate=', 'date=',
    \ 'urldate=', 'defernums=', 'punctfont=', 'arxiv=', 'backend=', 'mincrossrefs=',
    \ 'bibencoding=', 'useauthor=', 'useeditor=', 'usetranslator=', 'useprefix=', 'skipbib=',
    \ 'skiplos=', 'skiplab=', 'dataonly=', 'pagetracker=', 'citetracker=', 'ibidtracker=',
    \ 'idemtracker=', 'opcittracker=', 'loccittracker=', 'firstinits=', 'terseinits=', 'labelalpha=',
    \ 'labelnumber=', 'labelyear=', 'singletitle=', 'uniquename=', 'openbib' ] 

" This is get using g:atp_package_dict.ScanPackage
let options = ['debug', 'backend', 'loadfiles', 'mincrossrefs', 'texencoding',
	    \ 'bibencoding', 'safeinputenc', 'sorting', 'sortcase', 'sortupper',
	    \ 'sortlocale', 'sortlos', 'maxnames', 'minnames', 'maxnames', 'minnames',
	    \ 'maxnames', 'minnames', 'maxbibnames', 'minbibnames', 'maxbibnames',
	    \ 'minbibnames', 'maxbibnames', 'minbibnames', 'maxcitenames', 'mincitenames',
	    \ 'maxcitenames', 'mincitenames', 'maxcitenames', 'mincitenames', 'maxitems',
	    \ 'minitems', 'maxitems', 'minitems', 'maxitems', 'minitems', 'maxalphanames',
	    \ 'minalphanames', 'maxalphanames', 'minalphanames', 'maxline', 'terseinits',
	    \ 'firstinits', 'abbreviate', 'dateabbrev', 'language', 'clearlang', 'babel',
	    \ 'indexing', 'indexing', 'indexing', 'sortcites', 'hyperref', 'backref',
	    \ 'backrefsetstyle', 'block', 'pagetracker', 'citecounter', 'citetracker',
	    \ 'ibidtracker', 'idemtracker', 'opcittracker', 'loccittracker', 'parentracker',
	    \ 'maxparens', 'date', 'urldate', 'eventdate', 'origdate', 'alldates',
	    \ 'datezeros', 'autocite', 'notetype', 'autopunct', 'punctfont', 'labelnumber',
	    \ 'labelnumber', 'labelalpha', 'labelalpha', 'labelyear', 'labelyear',
	    \ 'uniquelist', 'uniquelist', 'uniquename', 'uniquename', 'singletitle',
	    \ 'singletitle', 'defernumbers', 'refsection', 'refsegment', 'citereset',
	    \ 'bibwarn', 'useprefix', 'useprefix', 'useprefix', 'useauthor', 'useauthor',
	    \ 'useauthor', 'useeditor', 'useeditor', 'useeditor', 'usetranslator',
	    \ 'usetranslator', 'usetranslator', 'skipbib', 'skipbib', 'skiplos', 'skiplos',
	    \ 'skiplab', 'skiplab', 'dataonly', 'dataonly']
