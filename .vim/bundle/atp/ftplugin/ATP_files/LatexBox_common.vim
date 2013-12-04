" Author:	   David Munger (latexbox vim plugin)
" Description: LaTeX Box common functions
" Maintainer:  Marcin Szamotulski
" Note:		   This file is a part of Automatic Tex Plugin for Vim.
" Language:    tex
" Last Change: Mon Nov 26, 2012 at 00:36:33  +0000

let s:sourced = exists("s:sourced") ? 1 : 0
" Settings {{{

" Compilation {{{

" g:vim_program {{{
if !exists('g:vim_program')
    " On MacOs this might be set to 
    " '/Applications/MacVim.app/Contents/MacOS/Vim -g'
    let g:vim_program = v:progname
endif
" }}}

if !exists('g:LatexBox_latexmk_options')
	let g:LatexBox_latexmk_options = ''
endif
if !exists('g:LatexBox_output_type')
	let g:LatexBox_output_type = 'pdf'
endif
if !exists('g:LatexBox_viewer')
	let g:LatexBox_viewer = b:atp_Viewer
endif
if !exists('g:LatexBox_autojump')
	let g:LatexBox_autojump = 0
endif
" }}}

" }}}

" Filename utilities {{{
"
function! LatexBox_GetMainTexFile()
	return atplib#FullPath(b:atp_MainFile)
endfunction

" Return the directory of the main tex file
function! LatexBox_GetTexRoot()
	return fnamemodify(atplib#FullPath(b:atp_MainFile), ':h')
endfunction

function! LatexBox_GetTexBasename(with_dir)
	if a:with_dir
		return fnamemodify(atplib#FullPath(b:atp_MainFile), ':r') 
	else
		return fnamemodify(b:atp_MainFile, ':t:r')
	endif
endfunction

function! LatexBox_GetAuxFile()
	return LatexBox_GetTexBasename(1) . '.aux'
endfunction

function! LatexBox_GetLogFile()
	return LatexBox_GetTexBasename(1) . '.log'
endfunction

function! LatexBox_GetOutputFile()
	return LatexBox_GetTexBasename(1) . '.' . g:LatexBox_output_type
endfunction
" }}}

" In Comment {{{
" LatexBox_InComment([line], [col])
" return true if inside comment
function! LatexBox_InComment(...)
	let line	= a:0 >= 1 ? a:1 : line('.')
	let col		= a:0 >= 2 ? a:2 : col('.')
	return synIDattr(synID(line("."), col("."), 0), "name") =~# '^texComment'
endfunction
" }}}

" Get Current Environment {{{
" LatexBox_GetCurrentEnvironment([with_pos])
" Returns:
" - environment													if with_pos is not given
" - [envirnoment, lnum_begin, cnum_begin, lnum_end, cnum_end]	if with_pos is nonzero
function! LatexBox_GetCurrentEnvironment(...)

	if a:0 > 0
		let with_pos = a:1
	else
		let with_pos = 0
	endif

	if atplib#complete#CheckSyntaxGroups(['texMathZoneV'])
	    let begin_pat 	= '\\\@<!\\('
	    let end_pat		= '\\\@<!\\)'
	elseif atplib#complete#CheckSyntaxGroups(['texMathZoneW'])
	    let begin_pat 	= '\\\@<!\\\['
	    let end_pat		= '\\\@<!\\\]'
	else
	    let begin_pat = '\C\\begin\_\s*{[^}]*}'
	    let end_pat = '\C\\end\_\s*{[^}]*}'
	endif
	let saved_pos = getpos('.')

	" move to the left until on a backslash
	" getpos(".") in visual mode returns getpos("'<") this makes a problem
	" here, simple change of mode here doesn't help, because mode() returns
	" 'n' here.  
	let [bufnum, lnum, cnum, off] = getpos('.')
	let line = getline(lnum)
	while cnum > 1 && line[cnum - 1] != '\'
		let cnum -= 1
	endwhile
	call cursor(lnum, cnum)

	" match begin/end pairs but skip comments
	let flags = 'bnW'
	if strpart(getline('.'), col('.') - 1) =~ '^\%(' . begin_pat . '\)'
		let flags .= 'c'
	endif
	let [lnum1, cnum1] = searchpairpos(begin_pat, '', end_pat, flags, 'LatexBox_InComment()')

	let env = ''

	if lnum1

		let line = strpart(getline(lnum1), cnum1 - 1)

		if empty(env)
			let env = matchstr(line, '^\C\\begin\_\s*{\zs[^}]*\ze}')
		endif
		if empty(env)
			let env = matchstr(line, '^\\\[')
		endif
		if empty(env)
			let env = matchstr(line, '^\\(')
		endif

	endif

	if with_pos == 1

		let flags = 'nW'
		if !(lnum1 == lnum && cnum1 == cnum)
			let flags .= 'c'
		endif

		let [lnum2, cnum2] = searchpairpos(begin_pat, '', end_pat, flags, 'LatexBox_InComment()')
		call setpos('.', saved_pos)
		return [env, lnum1, cnum1, lnum2, cnum2]
	else
		call setpos('.', saved_pos)
		return env
	endif


endfunction
" }}}
" vim:fdm=marker:ff=unix:noet:ts=4:sw=4
