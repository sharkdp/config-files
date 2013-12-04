" This file is a part of ATP.
" Written by Marcin Szamotulski <atp-list@lists.sourceforge.net>
let g:atp_hyperref_commands=[ '\hypersetup{', '\hypertarget{', '\url{', '\nolinkurl{', '\hyperbaseurl{', 
	\ '\hyperdef{', '\hyperref', '\hyperlink{', '\phantomsection', '\autoref{', '\autopageref{', 
	\ '\ref*{', '\autoref*{', '\autopageref*{', '\pdfstringdef{', '\pdfbookmark', 
	\ '\curretnpdfbookmark{', '\subpdfbookmark{', '\subpdfbookmark{', '\belowpdfbookmark{',
	\ '\texorpdfstring{', '\hypercalcbp', '\Acrobatmenu{', 
	\ '\textField', '\CheckBox', '\ChoiceMenu', '\PushButton', '\Submit', '\Reset',
	\ '\LayoutTextField', '\LayoutChoiceField', '\LayoutCheckField', '\MakeRadioField{', 
	\ '\MakeCheckField{', '\MakeTextField{', '\MakeChoiceField{', '\MakeButtonField{' ]
let g:atp_hyperref_options=['4=', 'a4paper', 'a5paper', 'anchorcolor=', 'b5paper', 'backref=', 'baseurl={',
	\ 'bookmarks=', 'bookmarksnumbered=', 'bookmarksopen=', 'bookmarksopenlevel=', 'bookmarkstype=',
	\ 'breaklinks=', 'citebordercolor=', 'citecolor=', 'colorlinks=', 'debug=', 'draft', 'dvipdf', 
	\ 'dvipdfm', 'dvips', 'dvipsone', 'dviwindo', 'executivepaper', 'extension=', 'filebordercolor=',
	\ 'filecolor=', 'frenchlinks=', 'hyperfigures=', 'hyperindex=', 'hypertex', 'hypertexnames=', 'implicit=',
	\ 'latex2html', 'legalpaper', 'letterpaper', 'linkbordercolor=', 'linkcolor=', 'linktocpage=',
	\ 'menubordercolor=', 'menucolor=', 'naturalnames', 'nesting=', 'pageanchor=', 'pagebackref=',
	\ 'pagebordercolor=', 'pagecolor=', 'pdfauthor={', 'pdfborder=', 'pdfcenterwindow=', 'pdfcreator={',
	\ 'pdffitwindow', 'pdfhighlight=', 'pdfkeywords={', 'pdfmenubar=', 'pdfnewwindow=', 'pdfpagelabels=',
	\ 'pdfpagelayout=', 'pdfpagemode=', 'pdfpagescrop=', 'pdfpagetransition=', 'pdfproducer={', 'pdfstartpage={',
	\ 'pdfstartview={', 'pdfsubject={', 'pdftex', 'pdftitle={', 'pdftoolbar=', 'pdfusetitle=', 'pdfview',
	\ 'pdfwindowui=', 'plainpages=', 'ps2pdf', 'raiselinks=', 'runbordercolor', 'tex4ht', 'textures',
	\ 'unicode=', 'urlbordercolor=', 'urlcolor=', 'verbose=', 'vtex', 'allcolors=', 'allbordercolors=', 'nativepdf=',
	\ 'pdfdisplaydoctitle=', 'pdfmark=', 'setpagesize=']
let g:atp_hyperref_options_values={
	\ '\%(anchor\|cite\%(border\)\=\|file\|link\%(border\)\=\|page\%(border\)\=\|url\|menu\)color\>' : 'GetColors',
	\ 'all\%(border\)\=colors\>' : 'GetColors',
	\ '\%(colorlinks\|frenchlinks\|hidelinks\|hyperfigures\|pagebackref\|hyperindex\|plainpages\|linktocpage\|breaklinks\|bookmarks\%\(open\|numbered\)\=\|naturalnames\|nativepdf\|nesting\|CJKbookmarks\|pdfcenterwindow\|pdfmark\|pdfdisplaydoctitle\|pdffitwindow\|pdfnewwindow\|unicode\|verbose\)\>' : [ 'true', 'false' ],
	\ '\%(bookmarks\|pageanchor\|hyperfootnotes\|pdfmenubar\|pdfpagelabels\|pdftoolbar\|pdfwindowui\|setpagesize\)\>' : [ 'false', 'true' ]
	\ }
