" Author:	Marcin Szamotulski
" Description:  This file provides searching tools of ATP.
" Note:		This file is a part of Automatic Tex Plugin for Vim.
" Language:	tex
" Last Change:

let s:sourced 	= exists("s:sourced") ? 1 : 0
 
" Functions:
" Find all names of locally defined commands, colors and environments. 
" Used by the completion function.
" {{{ LocalCommands
function! LocalCommands(write, ...)
    let time=reltime()
    let pattern = a:0 >= 1 && a:1 != '' ? a:1 : '\\def\>\|\\newcommand\>\|\\newenvironment\|\\newtheorem\|\\definecolor\|'
		\ . '\\Declare\%(RobustCommand\|FixedFont\|TextFontCommand\|MathVersion\|SymbolFontAlphabet'
			    \ . '\|MathSymbol\|MathDelimiter\|MathAccent\|MathRadical\|MathOperator\)'
		\ . '\|\\SetMathAlphabet\>'
    let bang	= a:0 >= 2 ? a:2 : '' 

    if has("python") && ( !exists("g:atp_no_python") || g:atp_no_python == 0 )
	call atplib#search#LocalCommands_py(a:write, '' , bang)
    else
	call atplib#search#LocalCommands_vim(pattern, bang)
    endif
    if !(exists("g:atp_no_local_abbreviations") && g:atp_no_local_abbreviations == 1)
	call atplib#search#LocalAbbreviations()
    endif
    let g:time_LocalCommands=reltimestr(reltime(time))
endfunction
" }}}

try " <SID>GlobalDefi (interface) {{{
function! <SID>GlobalDefi()
    exe "normal! m`"
    let word = atplib#TexKeyword()
    call atplib#search#GlobalDefi(word)
endfunction
catch /E127/
endtry "}}}
function! <SID>DsearchMap(bang) " {{{
    let word = substitute(atplib#TexKeyword(), '\', '\\\\', 'g')
    call atplib#search#Dsearch(a:bang, word)
    wincmd p
endfunction " }}}

" BibSearch:
"{{{ variables
let g:bibentries=['article', 'book', 'booklet', 'conference', 'inbook', 'incollection', 'inproceedings', 'manual', 'mastertheosis', 'misc', 'phdthesis', 'proceedings', 'techreport', 'unpublished']

let g:bibmatchgroup		='String'
let g:defaultbibflags		= 'tabejsyu'
let g:defaultallbibflags	= 'tabejfsvnyPNSohiuHcp'
let b:lastbibflags		= g:defaultbibflags	" Set the lastflags variable to the default value on the startup.
let g:bibflagsdict=atplib#bibsearch#bibflagsdict
" These two variables were s:... but I switched to atplib ...
let g:bibflagslist		= keys(g:bibflagsdict)
let g:bibflagsstring		= join(g:bibflagslist,'')
let g:kwflagsdict={ 	  '@a' : '@article', 	
	    		\ '@b' : '@book\%(let\)\@<!', 
			\ '@B' : '@booklet', 	
			\ '@c' : '@in\%(collection\|book\)', 
			\ '@m' : '@misc', 	
			\ '@M' : '@manual', 
			\ '@p' : '@\%(conference\)\|\%(\%(in\)\?proceedings\)', 
			\ '@t' : '@\%(\%(master)\|\%(phd\)\)thesis', 
			\ '@T' : '@techreport', 
			\ '@u' : '@unpublished' }    

"}}}

" Maps:
nnoremap <silent> <Plug>BibSearchLast :call atplib#search#BibSearch("", b:atp_LastBibPattern, b:atp_LastBibFlags)<CR>
nnoremap <silent> gD :call <SID>GlobalDefi()<CR>
nnoremap <buffer> <silent> [d    :call <SID>DsearchMap("")<CR>
nnoremap <buffer> <silent> [D    :call <SID>DsearchMap("!")<CR>

" Commands And Highlightgs:
" {{{
command! -buffer -bang -complete=customlist,atplib#search#SearchHistCompletion -nargs=* S 	:call atplib#search#Search(<q-bang>, <q-args>) | let v:searchforward = ( atplib#search#GetSearchArgs(<q-args>, 'bceswWx')[1] =~# 'x' ? v:searchforward :  ( atplib#search#GetSearchArgs(<q-args>, 'bceswWx')[1] =~# 'b' ? 0 : 1 ) )
nnoremap <buffer> <silent> <Plug>RecursiveSearchn	:exe "S /".@/."/x".(v:searchforward ? "" : "b")<CR>
nnoremap <buffer> <silent> <Plug>RecursiveSearchN	:exe "S /".@/."/x".(v:searchforward ? "b" : "")<CR>

if g:atp_mapNn
" These two maps behaves now like n (N): after forward search n (N) acts as forward (backward), after
" backward search n acts as backward (forward, respectively).

    nnoremap <buffer> <silent> n		<Plug>RecursiveSearchn
    nnoremap <buffer> <silent> N		<Plug>RecursiveSearchN

    " Note: the final step if the mapps n and N are made is in atplib#search#LoadHistory 
endif

command! -buffer -bang 		LocalCommands					:call LocalCommands(1, "", <q-bang>)
command! -buffer -bang -nargs=* -complete=customlist,DsearchComp Dsearch	:call atplib#search#Dsearch(<q-bang>, <q-args>)
command! -buffer -nargs=? -complete=customlist,atplib#OnOffComp ToggleNn	:call atplib#search#ATP_ToggleNn(0,<f-args>)
command! -buffer -bang -nargs=* BibSearch					:call atplib#search#BibSearch(<q-bang>, <q-args>)

" Search map:
command! -buffer -bang -nargs=? Map	:call atplib#helpfunctions#MapSearch(<q-bang>,<q-args>, '')
command! -buffer -bang -nargs=? Nmap	:call atplib#helpfunctions#MapSearch(<q-bang>,<q-args>, 'n')
command! -buffer -bang -nargs=? Imap	:call atplib#helpfunctions#MapSearch(<q-bang>,<q-args>, 'i')
command! -buffer -bang -nargs=? Cmap	:call atplib#helpfunctions#MapSearch(<q-bang>,<q-args>, 'c')
command! -buffer -bang -nargs=? Vmap	:call atplib#helpfunctions#MapSearch(<q-bang>,<q-args>, 'v')
command! -buffer -bang -nargs=? Smap	:call atplib#helpfunctions#MapSearch(<q-bang>,<q-args>, 's')
command! -buffer -bang -nargs=? Omap	:call atplib#helpfunctions#MapSearch(<q-bang>,<q-args>, 'o')
command! -buffer -bang -nargs=? Lmap	:call atplib#helpfunctions#MapSearch(<q-bang>,<q-args>, 'l')
" Hilighlting:
hi link BibResultsFileNames 	Title	
hi link BibResultEntry		ModeMsg
hi link BibResultsMatch		WarningMsg
hi link BibResultsGeneral	Normal

hi link Chapter 		Normal	
hi link Section			Normal
hi link Subsection		Normal
hi link Subsubsection		Normal
hi link CurrentSection		WarningMsg
"}}}
" vim:fdm=marker:tw=85:ff=unix:noet:ts=8:sw=4:fdc=1
