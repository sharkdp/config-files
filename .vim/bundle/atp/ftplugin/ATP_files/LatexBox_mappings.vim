" Author:	David Mungerd
" Maintainer:	Marcin Szamotulski
" Note:		This file is a part of Automatic Tex Plugin for Vim.
" Language:	tex
" Last Change:

let s:loaded = ( !exists("s:loaded") ? 1 : s:loaded+1 )

" begin/end pairs {{{
nmap <buffer> <silent> %    <Plug>LatexBox_JumpToMatch
nmap <buffer> <silent> g%   <Plug>LatexBox_BackJumpToMatch
xmap <buffer> <silent> %    <Plug>LatexBox_JumpToMatch
omap <buffer> <silent> <expr> % ( matchstr(getline("."), '^.*\%'.(col(".")+1).'c\\\=\w*\ze') =~ '\\\(begin\\|end\)$' ? ":<C-U>normal V%<CR>" : ":<C-U>normal v%<CR>" )
xmap <buffer> <silent> g% <Plug>LatexBox_BackJumpToMatch
vmap <buffer> <silent> ie <Plug>LatexBox_SelectCurrentEnvInner
vmap <buffer> <silent> iE <Plug>LatexBox_SelectCurrentEnVInner
vmap <buffer> <silent> ae <Plug>LatexBox_SelectCurrentEnvOuter
omap <buffer> <silent> ie :normal vie<CR>
omap <buffer> <silent> ae :normal vae<CR>
vmap <buffer> <silent> im <Plug>LatexBox_SelectInlineMathInner
vmap <buffer> <silent> am <Plug>LatexBox_SelectInlineMathOuter
omap <buffer> <silent> im :normal vim<CR>
omap <buffer> <silent> am :normal vam<CR>
" }}}

" text objects {{{
fun! <sid>Omap_Wrapper(map)
    " if 'clipboard' contains autoselect, 
    " this hack restores the "* value.
    let star_reg = @*
    let s = getpos("'<")
    let e = getpos("'>")
    exe ":normal v".v:count1.a:map
    call setpos("'<", s)
    call setpos("'>", e)
    let @* = star_reg
endfun

vmap <buffer> <silent> i( <Plug>LatexBox_SelectBracketInner_1
omap <buffer> <silent> i( :<C-U>call <sid>Omap_Wrapper("i(")<CR>
vmap <buffer> <silent> a( <Plug>LatexBox_SelectBracketOuter_1
omap <buffer> <silent> a( :<C-U>call <sid>Omap_Wrapper("a(")<CR>
vmap <buffer> <silent> ib <Plug>LatexBox_SelectBracketInner_1
omap <buffer> <silent> ib :<C-U>call <sid>Omap_Wrapper("i(")<CR>
vmap <buffer> <silent> ab <Plug>LatexBox_SelectBracketOuter_1
omap <buffer> <silent> ab :<C-U>call <sid>Omap_Wrapper("a(")<CR>
vmap <buffer> <silent> i) <Plug>LatexBox_SelectBracketInner_1
omap <buffer> <silent> i) :<C-U>call <sid>Omap_Wrapper("i)")<CR>
vmap <buffer> <silent> a) <Plug>LatexBox_SelectBracketOuter_1
omap <buffer> <silent> a) :<C-U>call <sid>Omap_Wrapper("a)")<CR>

vmap <buffer> <silent> i{ <Plug>LatexBox_SelectBracketInner_2
omap <buffer> <silent> i{ :<C-U>call <sid>Omap_Wrapper("i{")<CR>
vmap <buffer> <silent> a{ <Plug>LatexBox_SelectBracketOuter_2
omap <buffer> <silent> a{ :<C-U>call <sid>Omap_Wrapper("a{")<CR>
vmap <buffer> <silent> i} <Plug>LatexBox_SelectBracketInner_2
omap <buffer> <silent> i} :<C-U>call <sid>Omap_Wrapper("i}")<CR>
vmap <buffer> <silent> a} <Plug>LatexBox_SelectBracketOuter_2
omap <buffer> <silent> a} :<C-U>call <sid>Omap_Wrapper("a}")<CR>

vmap <buffer> <silent> i[ <Plug>LatexBox_SelectBracketInner_3
omap <buffer> <silent> i[ :<C-U>call <sid>Omap_Wrapper("i[")<CR>
vmap <buffer> <silent> a[ <Plug>LatexBox_SelectBracketOuter_3
omap <buffer> <silent> a[ :<C-U>call <sid>Omap_Wrapper("a[")<CR>
vmap <buffer> <silent> i] <Plug>LatexBox_SelectBracketInner_3
omap <buffer> <silent> i] :<C-U>call <sid>Omap_Wrapper("i]")<CR>
vmap <buffer> <silent> a] <Plug>LatexBox_SelectBracketOuter_3
omap <buffer> <silent> a] :<C-U>call <sid>Omap_Wrapper("a]")<CR>
" }}}
