" Title:       Vim filetype plugin file
" Author:      Marcin Szamotulski
" Email:       mszamot [AT] gmail [DOT] com
" Mailing List: atp-vim-list [AT] lists.sourceforge.net
" Language:    bib
" Last Change: Sun Sep 18, 2011 at 11:42  +0100
" Copyright Statement: 
" 	  This file is part of Automatic Tex Plugin for Vim.
"
"     Automatic Tex Plugin for Vim is free software: you can redistribute it
"     and/or modify it under the terms of the GNU General Public License as
"     published by the Free Software Foundation, either version 3 of the
"     License, or (at your option) any later version.
" 
"     Automatic Tex Plugin for Vim is distributed in the hope that it will be
"     useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
"     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
"     General Public License for more details.
" 
"     You should have received a copy of the GNU General Public License along
"     with Automatic Tex Plugin for Vim.  If not, see <http://www.gnu.org/licenses/>.
"
"     This licence applies to all files shipped with Automatic Tex Plugin.

call atplib#ReadATPRC()
if !exists("g:atp_vmap_bracket_leader")
    let g:atp_vmap_bracket_leader = '\'
endif

" Variables:
" {{{ bib fields
if !exists("g:atpbib_pathseparator")
    if has("win16") || has("win32") || has("win64") || has("win95")
	let g:atpbib_pathseparator = "\\"
    else
	let g:atpbib_pathseparator = "/"
    endif 
endif
" if !exists("g:atpbib_WgetOutputFile")
"     let tmpname = tempname()
"     let g:atpbib_WgetOutputFile = tmpname . g:atpbib_pathseparator . "amsref.html"
" endif
" if !exists("g:atpbib_wget")
"     let g:atpbib_wget="wget -O " . g:atpbib_WgetOutputFile
" endif
if !exists("g:atpbib_WgetOutputFile")
    let g:atpbib_WgetOutputFile = "amsref.html"
endif
if !exists("g:atpbib_wget")
    let g:atpbib_wget="wget"
endif
if !exists("g:atpbib_Article")
    let g:atpbib_Article = [ '@article{',
		\ '	Author	= {},',
		\ '	Title	= {},',
		\ '	Journal	= {},',
		\ '	Year	= {},', 
		\ '}' ]
endif
nmap <buffer> <LocalLeader>a	:call append(line("."), g:atpbib_Article)<CR>
if !exists("g:atpbib_Book")
    let g:atpbib_Book = [ '@book{' ,
		\ '	Author     	= {},',
		\ '	Title      	= {},',
		\ '	Publisher  	= {},',
		\ '	Year       	= {},', 
		\ '}' ]
endif
if !exists("g:atpbib_Booklet")
    let g:atpbib_Booklet = [ '@booklet{' ,
		\ '	Title      	= {},', 
		\ '}' ]
endif
if !exists("g:atpbib_Conference")
    let g:atpbib_Conference = [ '@conference{' ,
		\ '	Author     	= {},',
		\ '	Title      	= {},',
		\ '	Booktitle  	= {},',
		\ '	Publisher  	= {},',
		\ '	Year       	= {},',
		\ '}' ]
endif
if !exists("g:atpbib_InBook")
    let g:atpbib_InBook = [ '@inbook{' ,
		\ '	Author     	= {},',
		\ '	Title      	= {},',
		\ '	Chapter    	= {},',
		\ '	Publisher  	= {},',
		\ '	Year       	= {},',
		\ '}' ]
endif
if !exists("g:atpbib_InCollection")
    let g:atpbib_InCollection = [ '@incollection{' ,
		\ '	Author     	= {},',
		\ '	Title      	= {},',
		\ '	Booktitle  	= {},',
		\ '	Publisher  	= {},',
		\ '	Year       	= {},',
		\ '}' ]
endif
if !exists("g:atpbib_InProceedings")
    let g:atpbib_InProceedings = [ '@inproceedings{' ,
		\ '	Author     	= {},',
		\ '	Title      	= {},',
		\ '	Booktitle  	= {},',
		\ '	Publisher  	= {},',
		\ '	Year       	= {},',
		\ '}' ]
endif
if !exists("g:atpbib_Manual")
    let g:atpbib_Manual = [ '@manual{' ,
		\ '	Title      	= {},',
		\ '}' ]
endif
if !exists("g:atpbib_MastersThesis")
    let g:atpbib_MastersThesis = [ '@mastersthesis{' ,
		\ '	Author     	= {},',
		\ '	Title      	= {},',
		\ '	School     	= {},',
		\ '	Year       	= {},',
		\ '}' ]
endif
if !exists("g:atpbib_Misc")
    let g:atpbib_Misc = [ '@misc{',
		\ '	Title      	= {},',
		\ '}' ]
endif
if !exists("g:atpbib_PhDThesis")
    let g:atpbib_PhDThesis = [ '@phdthesis{' ,
		\ '	Author     	= {},',
		\ '	Title      	= {},',
		\ '	School     	= {},',
		\ '	Year       	= {},',
		\ '}' ]
endif
if !exists("g:atpbib_Proceedings")
    let g:atpbib_Proceedings = [ '@proceedings{' ,
		\ '	Title      	= {},',
		\ '	Year       	= {},', 
		\ '}' ]
endif
if !exists("g:atpbib_TechReport")
    let g:atpbib_TechReport = [ '@TechReport{' ,
		\ '	Author     	= {},',
		\ '	Title      	= {},',
		\ '	Institution	= {},',
		\ '	Year       	= {},', 
		\ '}' ]
endif
if !exists("g:atpbib_Unpublished")
    let g:atpbib_Unpublished = [ '@unpublished{',
		\ '	Author     	= {},',
		\ '	Title      	= {},',
		\ '	Note       	= {},',
		\ '}' ]
endif
" }}}

" AMSRef:
" {{{ <SID>AMSRef
try
function! <SID>GetAMSRef(what)
    let what = substitute(a:what, '\s\+', ' ',	'g') 
    let what = substitute(what, '%',	'%25',	'g')
    let what = substitute(what, ',',	'%2C',	'g') 
    let what = substitute(what, ':',	'%3A',	'g')
    let what = substitute(what, ';',	'%3B',	'g')
    let what = substitute(what, '/',	'%2F',	'g')
    let what = substitute(what, '?',	'%3F',	'g')
    let what = substitute(what, '+',	'%2B',	'g')
    let what = substitute(what, '=',	'%3D',	'g')
    let what = substitute(what, '#',	'%23',	'g')
    let what = substitute(what, '\$',	'%24',	'g')
    let what = substitute(what, '&',	'%26',	'g')
    let what = substitute(what, '@',	'%40',	'g')
    let what = substitute(what, ' ',	'+',	'g')


    " Get data from AMS web site.
    let atpbib_WgetOutputFile = tempname()
    let URLquery_path = split(globpath(&rtp, 'ftplugin/ATP_files/url_query.py'), "\n")[0]
    let url="http://www.ams.org/mathscinet-mref?ref=".what."&dataType=bibtex"
    let cmd=g:atp_Python." ".URLquery_path." ".shellescape(url)." ".shellescape(atpbib_WgetOutputFile)
    call system(cmd)
    let loclist = getloclist(0)

    try
	exe '1lvimgrep /\CNo Unique Match Found/j ' . fnameescape(atpbib_WgetOutputFile)
    catch /E480/
    endtry
    if len(getloclist(0))
	echohl WarningMsg
	echomsg "[ATP:] No Unique Match Found"
	echohl None
	return [0]
    endif
    let pattern = '@\%(article\|book\%(let\)\=\|conference\|inbook\|incollection\|\%(in\)\=proceedings\|manual\|masterthesis\|misc\|phdthesis\|techreport\|unpublished\)\s*{\|^\s*\%(ADDRESS\|ANNOTE\|AUTHOR\|BOOKTITLE\|CHAPTER\|CROSSREF\|EDITION\|EDITOR\|HOWPUBLISHED\|INSTITUTION\|JOURNAL\|KEY\|MONTH\|NOTE\|NUMBER\|ORGANIZATION\|PAGES\|PUBLISHER\|SCHOOL\|SERIES\|TITLE\|TYPE\|VOLUME\|YEAR\|MRCLASS\|MRNUMBER\|MRREVIEWER\)\s*=\s*.*$'
    try 
	exe 'lvimgrep /'.pattern.'/j ' . fnameescape(atpbib_WgetOutputFile)
    catch /E480:/
    endtry
    let data = getloclist(0)
    call setloclist(0, loclist)
    if !len(data) 
	echohl WarningMsg
	echomsg "[ATP:] nothing found."
	echohl None
	return [0]
    endif

    let type_pattern= '@\%(article\|book\%(let\)\=\|conference\|inbook\|incollection\|\%(in\)\=proceedings\|manual\|masterthesis\|misc\|phdthesis\|techreport\|unpublished\)\>'
    let bdata		= filter(copy(data), "v:val['text'] =~ type_pattern")
    let blinenumbers	= map(copy(bdata), 'v:val["lnum"]')
    let begin		= max(blinenumbers)
    let linenumbers	= map(copy(data), 'v:val["lnum"]')
    let end		= max(linenumbers)

    let bufnr = bufnr(atpbib_WgetOutputFile)
    " To use getbufline() buffer must be loaded. It is enough to use :buffer
    " command because vimgrep loads buffer and then unloads it. 
    execute "buffer " . bufnr
    let bibdata	= getbufline(bufnr, begin, end)
    execute "bdelete " . bufnr 
    let type = matchstr(bibdata[0], '@\%(article\|book\%(let\)\=\|conference\|inbook\|incollection\|\%(in\)\=proceedings\|manual\|masterthesis\|misc\|phdthesis\|techreport\|unpublished\)\ze\s*\%("\|{\|(\)')
"     Suggest Key:
    let bibkey = input("Provide a key (Enter for the AMS bibkey): ")
    if !empty(bibkey)
	let bibdata[0] = type . '{' . bibkey . ','
    else
	let bibdata[0] = substitute(matchstr(bibdata[0], '@\w*.*$'), '\(@\w*\)\(\s*\)', '\1', '')
    endif
    call add(bibdata, "}")

    "Go to begin of next entry or end of last entry
    let line = NEntry('nW')
    if line == line(".")
	call EntryEnd("")
    else
	call cursor(line(".")-1,1)
    endif

    "Append the bibdata:
    if getline(line('$')) !~ '^\s*$' 
	let bibdata = extend([''], bibdata)
    endif
    let bibdata = extend(bibdata, [''])
    call append(line('.'), bibdata)
    let g:atp_bibdata = bibdata

    call delete(atpbib_WgetOutputFile)
    return bibdata
endfunction
catch /E127/
endtry

command! -buffer -nargs=1 AMSRef    call <SID>GetAMSRef(<q-args>)
"}}}

" JMotion:
function! <SID>JMotion(flag) " {{{
    let pattern = '\%(\%(address\|annote\|author\|booktitle\|chapter\|crossref\|edition\|editor\|howpublished\|institution\|journal\|key\|month\|note\|number\|organization\|pages\|publisher\|school\|series\|title\|type\|volume\|year\|mrclass\|mrnumber\|mrreviewer\)\s*=\s.\zs\|@\w*\%({\|"\|(\|''\)\zs\)'
    call search(pattern, a:flag)
endfunction "}}}

" NEntry:
function! NEntry(flag,...) "{{{
    let keepjumps = ( a:0 >= 1 ? a:1 : "" )
    let pattern = '@\%(article\|book\%(let\)\=\|conference\|inbook\|incollection\|\%(in\)\=proceedings\|manual\|masterthesis\|misc\|phdthesis\|techreport\|unpublished\)'
"     let g:cmd = keepjumps . " call search(".pattern.",".a:flag.")" 
    keepjumps call search(pattern, a:flag)
    return line(".")
endfunction "}}}
 
" EntryEnd:
function! EntryEnd(flag) "{{{
    call NEntry("bc", "keepjumps")
    if a:flag =~# 'b'
	call NEntry("b", "keepjumps")
    endif
    keepjumps call search('\%({\|(\|"\|''\)')
    normal %
    return line(".")
endfunction "}}}

" Wrap:
"{{{
command! -buffer -nargs=* -complete=custom,atplib#various#BibWrapSelection_compl -range Wrap			:call atplib#various#WrapSelection(<f-args>)
if !hasmapto(":Wrap { } begin<cr>", 'v')
    execute "vnoremap <silent> <buffer> ".g:atp_vmap_bracket_leader."{ 	:Wrap { } begin<CR>"
endif
if !hasmapto(":Wrap { } end<cr>", 'v')
    execute "vnoremap <silent> <buffer> ".g:atp_vmap_bracket_leader."}	:Wrap { } end<CR>"
endif
if !hasmapto(":Wrap < > begin<cr>", 'v')
    execute "vnoremap <silent> <buffer> ".g:atp_vmap_bracket_leader."< 	:Wrap < > begin<CR>"
endif
if !hasmapto(":Wrap < > end<cr>", 'v')
    execute "vnoremap <silent> <buffer> ".g:atp_vmap_bracket_leader."> 	:Wrap < > end<CR>"
endif
if !hasmapto(":Wrap ( ) begin<cr>", 'v')
    execute "vnoremap <silent> <buffer> ".g:atp_vmap_bracket_leader."( 	:Wrap ( ) begin<CR>"
endif
if !hasmapto(":Wrap ( ) end<cr>", 'v')
    execute "vnoremap <silent> <buffer> ".g:atp_vmap_bracket_leader.") 	:Wrap ( ) end<CR>"
endif
if !hasmapto(":Wrap [ ] begin<cr>", 'v')
    execute "vnoremap <silent> <buffer> ".g:atp_vmap_bracket_leader."[ 	:Wrap [ ] begin<CR>"
endif
if !hasmapto(":Wrap [ ] end<cr>", 'v')
    execute "vnoremap <silent> <buffer> ".g:atp_vmap_bracket_leader."] 	:Wrap [ ] end<CR>"
endif
"}}}

" Maps:
" {{{
nmap <buffer> <silent> ]]	:call NEntry("")<CR>
nmap <buffer> <silent> }	:call NEntry("")<CR>zz
nmap <buffer> <silent> [[	:call NEntry("b")<CR>
nmap <buffer> <silent> {	:call NEntry("b")<CR>zz

nmap <buffer> <silent> ][	:call EntryEnd("")<CR>
nmap <buffer> <silent> []	:call EntryEnd("b")<CR>

nmap <buffer> <c-j> 	:call <SID>JMotion("")<CR>
nmap <buffer> <c-k>	:call <SID>JMotion("b")<CR>	
imap <buffer> <c-j>	<Esc>l:call <SID>JMotion("")<CR>i
imap <buffer> <c-k>	<Esc>l:call <SID>JMotion("b")<CR>i

nnoremap <buffer> <silent> <F1>		:call system("texdoc bibtex")<CR>

nnoremap <buffer> <LocalLeader>a	:call append(line("."), g:atpbib_Article)<CR>:call <SID>JMotion("")<CR>
nnoremap <buffer> <LocalLeader>b	:call append(line("."), g:atpbib_Book)<CR>:call <SID>JMotion("")<CR>
nnoremap <buffer> <LocalLeader>bo	:call append(line("."), g:atpbib_Book)<CR>:call <SID>JMotion("")<CR>
nnoremap <buffer> <LocalLeader>c	:call append(line("."), g:atpbib_InProceedings)<CR>:call <SID>JMotion("")<CR>
nnoremap <buffer> <LocalLeader>bl	:call append(line("."), g:atpbib_Booklet)<CR>:call <SID>JMotion("")<CR>
nnoremap <buffer> <LocalLeader>ib	:call append(line("."), g:atpbib_InBook)<CR>:call <SID>JMotion("")<CR>
nnoremap <buffer> <LocalLeader>ic	:call append(line("."), g:atpbib_InCollection)<CR>:call <SID>JMotion("")<CR>
nnoremap <buffer> <LocalLeader>ma	:call append(line("."), g:atpbib_Manual)<CR>:call <SID>JMotion("")<CR>
nnoremap <buffer> <LocalLeader>mt	:call append(line("."), g:atpbib_MasterThesis)<CR>:call <SID>JMotion("")<CR>
nnoremap <buffer> <LocalLeader>mi	:call append(line("."), g:atpbib_Misc)<CR>:call <SID>JMotion("")<CR>
nnoremap <buffer> <LocalLeader>phd	:call append(line("."), g:atpbib_PhDThesis)<CR>:call <SID>JMotion("")<CR>
nnoremap <buffer> <LocalLeader>pr	:call append(line("."), g:atpbib_Proceedings)<CR>:call <SID>JMotion("")<CR>
nnoremap <buffer> <LocalLeader>tr	:call append(line("."), g:atpbib_TechReport)<CR>:call <SID>JMotion("")<CR>
nnoremap <buffer> <LocalLeader>un	:call append(line("."), g:atpbib_Unpublished)<CR>:call <SID>JMotion("")<CR>
" }}}
" vim:fdm=marker:tw=78:ff=unix:noet:ts=8:sw=4:fdc=1
