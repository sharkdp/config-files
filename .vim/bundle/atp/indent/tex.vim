" Title:	vim indent file for tex files.
" Author: 	David Munger (mungerd@gmail.com)
" Maintainer:	Marcin Szamotulski
" Note:		This file is a part of Automatic Tex Plugin for Vim.
" Language:	tex
" Last Change:

if exists("b:did_indent") || ( exists("g:atp_indent") && !g:atp_indent )
    finish
endif

let b:did_indent = 1

setlocal indentexpr=LatexBox_TexIndent()
setlocal indentkeys==\end,=\item,),],},o,O,0\\,!^F 

let s:itemize_envs = ['itemize', 'enumerate', 'description']

" indent on \left( and on \(, but not on (
" indent on \left[ and on \[, but not on [
" indent on \left\{ and on \{, and on {
let s:open_pat = '\\begin\>\|\%(\\left\s*\)\=\\\=[{]\|\%(\\left\s*\|\\\)[[(]'
let s:close_pat = '\\end\>\|\%(\\right\s*\)\=\\\=[}]\|\%(\\right\s*\|\\\)[])]'


" Compute Level {{{
function! s:ComputeLevel(lnum_prev, open_pat, close_pat)

	let n = 0

	let line_prev = getline(a:lnum_prev)

	" strip comments
	let line_prev = substitute(line_prev, '\\\@<!%.*', '', 'g')

	" find unmatched opening patterns on previous line
	let n += len(substitute(substitute(line_prev, a:open_pat, "\n", 'g'), "[^\n]", '', 'g'))
	let n -= len(substitute(substitute(line_prev, a:close_pat, "\n", 'g'), "[^\n]", '', 'g'))

	" reduce indentation if current line starts with a closing pattern
	if getline(v:lnum) =~ '^\s*\%(' . a:close_pat . '\)'
		let n -= 1
	endif

	" compensate indentation if previous line starts with a closing pattern
	if line_prev =~ '^\s*\%(' . a:close_pat . '\)'
		let n += 1
	endif

	return n
endfunction
" }}}

" TexIndent {{{
function! LatexBox_TexIndent()

	let lnum_prev = prevnonblank(v:lnum - 1)

	if lnum_prev == 0
		return 0
	endif

	let n = 0

	let n += s:ComputeLevel(lnum_prev, s:open_pat, s:close_pat)

	let n += s:ComputeLevel(lnum_prev, '\\begin{\%(' . join(s:itemize_envs, '\|') . '\)}', 
		    \ '\\end{\%(' . join(s:itemize_envs, '\|') . '\)}')

	" less shift for lines starting with \item
	let item_here = getline(v:lnum) =~ '^\s*\\item'
	let item_above = getline(lnum_prev) =~ '^\s*\\item'
	if !item_here && item_above
		let n += 1
	elseif item_here && !item_above
		let n -= 1
	endif

	return indent(lnum_prev) + n * &sw
endfunction
" }}}

" vim:fdm=marker:tw=85:ff=unix:noet:ts=8:sw=4:fdc=1
