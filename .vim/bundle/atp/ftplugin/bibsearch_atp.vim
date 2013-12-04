" Vim filetype plugin file
" Language:	tex
" Maintainer:	Marcin Szamotulski
" Last Change: Mon Oct 10, 2011 at 21:21:49  +0100
" Note:		This file is a part of Automatic Tex Plugin for Vim.

"
" {{{ Load Once
if exists("b:did_ftplugin") | finish | endif
let b:did_ftplugin = 1
" }}}

" Status Line:
function! ATPBibStatus() "{{{
    return substitute(expand("%"),"___","","g")
endfunction
setlocal statusline=%{ATPBibStatus()}
" }}}

" Maps:
" {{{ MAPS AND COMMANDS 
if !exists("no_plugin_maps") && !exists("no_atp_bibsearch_maps")
    map <buffer> <silent> c :<C-U>call <SID>BibYank(v:register,v:count)<CR>
    map <buffer> <silent> y :<C-U>call <SID>BibYank(v:register,v:count)<CR>
    map <buffer> <silent> p :<C-U>call <SID>BibPaste('p',v:count)<CR>
    map <buffer> <silent> P :<C-U>call <SID>BibPaste('P',v:count)<CR>
    map <buffer> <silent> q :hide<CR>
    command! -buffer -count -register -nargs=* Yank 	:call <SID>BibYank(<q-reg>,<q-count>)
    command! -buffer -count -nargs=* Paste 	:call <SID>BibPaste('p', <q-count>)
endif
" }}}

" Functions:
function! <SID>BibYank(register, which)" {{{
    " Yank selection to register
    let g:register = a:register
    let bibkey =  get(b:ListOfBibKeys, a:which, 'no_key') 
    if bibkey == 'no_key'
	echomsg "[ATP:] Did you specify the entry?"
	return
    endif
    let choice=substitute(strpart(bibkey, stridx(bibkey,'{')+1), ',', '', '')
    if a:register == 'a'
	let @a=choice
    elseif a:register == 'b'
	let @b=choice
    elseif a:register == 'c'
	let @c=choice
    elseif a:register == 'd'
	let @d=choice
    elseif a:register == 'e'
	let @e=choice
    elseif a:register == 'f'
	let @f=choice
    elseif a:register == 'g'
	let @g=choice
    elseif a:register == 'h'
	let @h=choice
    elseif a:register == 'i'
	let @i=choice
    elseif a:register == 'j'
	let @j=choice
    elseif a:register == 'k'
	let @k=choice
    elseif a:register == 'l'
	let @l=choice
    elseif a:register == 'm'
	let @m=choice
    elseif a:register == 'n'
	let @n=choice
    elseif a:register == 'o'
	let @o=choice
    elseif a:register == 'p'
	let @p=choice
    elseif a:register == 'q'
	let @q=choice
    elseif a:register == 'r'
	let @r=choice
    elseif a:register == 's'
	let @s=choice
    elseif a:register == 't'
	let @t=choice
    elseif a:register == 'u'
	let @u=choice
    elseif a:register == 'v'
	let @v=choice
    elseif a:register == 'w'
	let @w=choice
    elseif a:register == 'x'
	let @x=choice
    elseif a:register == 'y'
	let @y=choice
    elseif a:register == 'z'
	let @z=choice
    elseif a:register == '*'
	let @*=choice
    elseif a:register == '+'
	let @+=choice
    elseif a:register == '-'
	let @-=choice
    elseif a:register == '"'
	let @"=choice
    elseif a:register == ''
	if index(split(&cb, ','), 'unnamed') != -1
	    let @* = choice
	endif
	if index(split(&cb, ','), 'unnamedplus') != -1
	    let @+ = choice
	endif
    else
	let @" = choice
    endif
endfunction "}}}
function! <SID>BibPaste(command,...) "{{{
    if a:0 == 0 || a:0 == 1 && a:1 == 0
	let which	= input("Which entry? ( {Number}<Enter>, or <Enter> for none ) ")
	redraw
    else
	let which	= a:1
    endif
    if which == ""
	return
    endif
    let start	= stridx(b:ListOfBibKeys[which],'{')+1
    let choice	= substitute(strpart(b:ListOfBibKeys[which], start), ',\s*$', '', '')
    let @"	= choice

    " Goto right buffer
    let winbufnr = bufwinnr(b:BufNr)
    if winbufnr != -1
	exe "normal ".winbufnr."w"
    else
	if bufexist(b:BufNr)
	    exe "normal buffer ".winbufnr
	else
	    echohl WarningMsg 
	    echo "Buffer was deleted"
	    echohl None
	    return
	endif
    endif

    let LineNr 	= line(".")
    let ColNr 	= col(".") 
    if a:command ==# 'P'
	let ColNr -= 1
    endif
    call setline(LineNr, strpart(getline(LineNr), 0, ColNr) . choice . strpart(getline(LineNr), ColNr))
    call cursor(LineNr, len(strpart(getline(LineNr), 0, ColNr) . choice)+1)
    return
endfunction "}}}
" vim:fdm=marker:tw=85:ff=unix:noet:ts=8:sw=4:fdc=1
