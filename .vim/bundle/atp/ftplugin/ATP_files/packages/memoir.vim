" This file is a part of ATP.
" Written by Marcin Szamotulski <atp-list@lists.sourceforge.net>

let g:atp_memoir_options = [
	    \ '9pt', '10pt', '11pt', '12pt', '14pt', '17pt', '20pt', '25pt',
	    \ '30pt', '36pt', '48pt', '60pt', 'extrafontsizes',
	    \ 'a6paper', 'a5paper', 'a4paper', 'a3paper', 
	    \ 'b6paper', 'b5paper', 'b4paper', 'b3paper',
	    \ 'mcrownvopaper', 'mlargecrownvopaper', 'mdemyvopaper', 'msmallroyalvopaper',
	    \ 'latterpaper', 'landscape', 'dbillpaper', 'statementpaper', 'executivepaper',
	    \ 'oldpaper', 'legalpaper', 'ledgerpaper', 'broadsheatpaper',
	    \ 'pottvopaper', 'crownvopaper', 'postvopaper', 'largecrownvopaper', 'largepostvopaper',
	    \ 'smalldemyvopaper', 'demyvopaper', 'mediumvopaper', 'smallroyalpaper', 'royalpaper',
	    \ 'superroyalpaper', 'imperialvopaper',
	    \ 'twoside', 'oneside', 'onecolumn', 'openright', 'openleft', 'openany', 'final', 'draft',
	    \ 'ms', 'showtrims', 'leqno', 'fleqn', 'openbib', 'article', 'oldfontcommands' 
	    \ ]

let g:atp_memoir_commands = [
	    \ '\stockheight', '\trimtop', '\trimedge', '\stockwidth',
	    \ '\spinemargin', '\foremargin', '\uppermargin', '\headmargin',
	    \ '\typeoutlayout', '\typeoutstandardlayout', '\settypeoutlayoutunit{',
	    \ '\fixpdflayout', '\fixdvipslayout', '\medievalpage', '\isopage',
	    \ '\semiisopage',
	    \ '\contentsname', '\listfigurename', 'listtablename'
	    \ ]
let g:atp_memoir_command_values = {
	    \ '\\\%(this\)\=pagestyle\s*{' : [ 'cleared', 'chapter', 'titlingpagestyle' ]
	    \ }
" Additional commands which seems to be rare and thus not included by default.
" Uncomment this line to get them.
" call extend(g:atp_memoir_commands, [
" 	    \ '\setstocksize{', '\settrimmedsize{', '\settypeblocksize{', '\setlrmarigins{', 
" 	    \ '\setlrmarginsandblock{', '\setbinding{', '\setulmargins{', '\setulmarginsandblock{', 
" 	    \ '\setcolsepandrule{', '\setheadfoot{', '\setheaderspaces{',
" 	    \ '\setmarginnotes{', '\checkandfixthelayout', '\checkthelayout',
" 	    \ '\fixthelayout', '\setxlvchars', '\setlxvchars'
" 	    \ ] )
