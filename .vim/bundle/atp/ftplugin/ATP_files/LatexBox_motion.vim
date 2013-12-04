" Language:	tex
" Author:	David Mnuger (latexbox vim plugin)
" Maintainer:	Marcin Szamotulski
" Note:		This file is a part of Automatic Tex Plugin for Vim.
" Language:	tex
" Last Change:

" Some things is enough to source once
let s:sourced = exists("s:sourced") ? 1 : 0

if !s:sourced || g:atp_reload_functions
" HasSyntax {{{
" s:HasSyntax(syntaxName, [line], [col])
function! s:HasSyntax(syntaxName, ...)
	let line	= a:0 >= 1 ? a:1 : line('.')
	let col		= a:0 >= 2 ? a:2 : col('.')
	return index(map(synstack(line, col), 'synIDattr(v:val, "name") == "' . a:syntaxName . '"'), 1) >= 0
endfunction
" }}}

" Search and Skip Comments {{{
" s:SearchAndSkipComments(pattern, [flags], [stopline])
function! s:SearchAndSkipComments(pat, ...)
	let flags	= a:0 >= 1 ? a:1 : ''
	let stopline	= a:0 >= 2 ? a:2 : 0
	let saved_pos 	= getpos('.')

	" search once
	let ret = search(a:pat, flags, stopline)

	if ret
		" do not match at current position if inside comment
		let flags = substitute(flags, 'c', '', 'g')

		" keep searching while in comment
		while LatexBox_InComment()
			let ret = search(a:pat, flags, stopline)
			if !ret
				break
			endif
		endwhile
	endif

	if !ret
		" if no match found, restore position
		call setpos('.', saved_pos)
	endif

	return ret
endfunction
" }}}

" begin/end pairs {{{
"
" s:JumpToMatch(mode, [backward])
" - search backwards if backward is given and nonzero
" - search forward otherwise
"
function! LaTeXBox_JumpToMatch(mode, ...)

	let backward = (a:0>=1 ? a:1 : 0)
	let setmark = (a:0>=2 ? a:2 : 1)

	" add current position to the jump-list (see :help jump-motions)
	if setmark
	    normal! m`
	endif

	let sflags = backward ? 'cbW' : 'cW'

	" selection is lost upon function call, reselect
	if a:mode == 'v'
		normal! gv
	endif

	if getline(line("."))[:(col(".")-1)] =~ '\\\%(begin\|end\)\s*{[^}]*$' && getline(line("."))[(col(".")-1)] != '{'
	    call search('\\\%(begin\|end\)', 'b', line("."))
	endif

	" open/close pairs (dollars signs are treated apart)
	let open_pats 		= ['\\begin\>', '{', '\[', '(', '\\left\>', '\\lceil\>', '\\lgroup\>', '\\lfloor', '\\langle']
	let close_pats 		= ['\\end\>', '}', '\]', ')', '\\right\>', '\\rceil', '\\rgroup\>', '\\rfloor', '\\rangle']
	let dollar_pat 		= '\\\@<!\$'
	let two_dollar_pat 	= '\\\@<!\$\$'

	let saved_pos = getpos('.')
	let beg_of_line  = strpart(getline('.'), 0, searchpos('\>', 'n')[1]-1)

	" move to the left until not on alphabetic characters
	call search('\A', 'cbW', line('.'))
	if getline('.')[col('.')-1]=~'}\|\]\|)' && col('.') < saved_pos[2]
	    normal! l
	endif

	let zonex=s:HasSyntax('texMathZoneX', line("."), col(".")) || s:HasSyntax('texMathZoneX', line('.'), max([1, col(".")-1])) 
	let zoney=s:HasSyntax('texMathZoneY', line("."), col("."))  

	let stopline = ( g:atp_VimCompatible || g:atp_VimCompatible =~? '\<yes\>' ? line('.') : 0 )
	" go to next opening/closing pattern on same line (depends on
	" g:atp_VimCompatible)
	if expand("<cWORD>") !~? '\\item'
	    if !s:HasSyntax('texSectionModifier', line('.'), col('.'))
		let pos = !s:SearchAndSkipComments(
					\	'\m\C\%(' . join(open_pats + close_pats + [dollar_pat], '\|') . '\)',
					\	sflags, stopline)
	    else
		let pos = !s:SearchAndSkipComments(
					\	'\m\C\%(' . join(open_pats + close_pats, '\|') . '\)',
					\	sflags, stopline)
	    endif
	    " THE line('.') above blocks it from working not just in one line
	    " (especially with \begin:\end which might be in different lines).
	    if pos
		    " abort if no match or if match is inside a comment
		    call setpos('.', saved_pos)
		    return
	    endif
	endif

	let rest_of_line = strpart(getline('.'), col('.') - 1)

	" match for '$' pairs
	if rest_of_line =~ '^\$' && beg_of_line !~ '\C\\item$' && !s:HasSyntax('texSectionModifier', line('.'), col('.'))

		" check if next character is in inline math
		let zonex+=s:HasSyntax('texMathZoneX', line("."), col(".")) 
		let zoney+=s:HasSyntax('texMathZoneY', line("."), col(".")) || s:HasSyntax('texMathZoneY', line('.'), max([1, col(".")-1])) 
		let [lnum, cnum] = searchpos('.', 'nW')

		if zonex
		    if lnum && s:HasSyntax('texMathZoneX', lnum, cnum)
			    call s:SearchAndSkipComments(dollar_pat, 'W')
		    else
			    call s:SearchAndSkipComments(dollar_pat, 'bW')
		    endif
		elseif zoney
		    if lnum && s:HasSyntax('texMathZoneY', lnum, cnum)
			    call s:SearchAndSkipComments(two_dollar_pat, 'W')
		    else
			    call s:SearchAndSkipComments(two_dollar_pat, 'bW')
		    endif
		endif
	else

	" match other pairs
	for i in range(len(open_pats))
		let open_pat = open_pats[i]
		let close_pat = close_pats[i]
		let mid_pat = ( open_pat  == '\\begin\>' ? '\C\\item\>' : '' )

		if mid_pat != "" && beg_of_line =~ '\C\%(' . mid_pat . '\)$'
		    " if on mid pattern
		    call search('\C'.mid_pat, 'Wbc', line("."))
		    call searchpair('\C'.open_pat, mid_pat, '\C'.close_pat, 'W'.(backward ? 'b' : ''), 'LatexBox_InComment()')
		    break
		elseif rest_of_line =~ '^\C\%(' . open_pat . '\)'
		    " if on opening pattern, go to closing pattern
		    call searchpair('\C'.open_pat, 
				\ (!backward && (saved_pos[1] == line('.') && saved_pos[2] >= col('.')) ? mid_pat : ''),
				\ '\C'.close_pat, 'W', 'LatexBox_InComment()')
		    break
		elseif rest_of_line =~ '^\C\%(' . close_pat . '\)'
		    " if on closing pattern, go to opening pattern
		    call searchpair('\C'.open_pat, (!backward ? '' : mid_pat), '\C'.close_pat, 'Wb', 'LatexBox_InComment()')
		    break
		endif

	endfor
    endif

endfunction

nnoremap <silent> <Plug>LatexBox_JumpToMatch		:call LaTeXBox_JumpToMatch('n')<CR>
vnoremap <silent> <Plug>LatexBox_JumpToMatch 		:<C-U>call LaTeXBox_JumpToMatch('v')<CR>
nnoremap <silent> <Plug>LatexBox_BackJumpToMatch 	:call LaTeXBox_JumpToMatch('n', 1)<CR>
vnoremap <silent> <Plug>LatexBox_BackJumpToMatch 	:<C-U>call LaTeXBox_JumpToMatch('v', 1)<CR>
" }}}

" select inline math {{{
" s:SelectInlineMath(seltype)
" where seltype is either 'inner' or 'outer'
function! s:SelectInlineMath(seltype)

    	let saved_pos		= getpos('.')

	let synstack		= map(synstack(line("."),col(".")), 'synIDattr(v:val, "name")')

	if len(filter(synstack, "v:val =~ '^texMathZone[A-L]S\\?'"))
	    call s:SelectCurrentEnv(a:seltype)
	    return
	endif

	let ZoneX_pat_O 	= '\\\@<!\$'
	let ZoneX_pat_C 	= '\\\@<!\$'
	let ZoneY_pat_O 	= '\\\@<!\$\$'
	let ZoneY_pat_C 	= a:seltype == 'inner' ? '\\\@<!\$\$' 	: '\\\@<!\$\$'
	let ZoneV_pat_O		= '\\\@<!\\('
	let ZoneV_pat_C		= a:seltype == 'inner' ? '\\\@<!\\)' 	: '\\\@<!\\\zs)' 
	let ZoneW_pat_O		= '\\\@<!\\\['
	let ZoneW_pat_C		= a:seltype == 'inner' ? '\\\@<!\\\]'	: '\\\@<!\\\zs\]'

	if 	( s:HasSyntax('texMathZoneV', line("."), max([1,col(".")-1])) ||
		\ s:HasSyntax('texMathZoneW', line("."), max([1,col(".")-1])) ||
		\ s:HasSyntax('texMathZoneX', line("."), max([1,col(".")-1])) ||
		\ s:HasSyntax('texMathZoneY', line("."), max([1,col(".")-1])) && b:atp_TexFlavor == 'plaintex' )  && 
		\ col(".") > 1
	    normal! h
	elseif 	( s:HasSyntax('texMathZoneV', line("."), max([1,col(".")-2])) ||
		\ s:HasSyntax('texMathZoneW', line("."), max([1,col(".")-2])) ||
		\ s:HasSyntax('texMathZoneY', line("."), max([1,col(".")-2])) && b:atp_TexFlavor == 'plaintex' )  && 
		\ col(".") > 2
	    normal! 2h
	endif

	let return 		= 1 
	let math_zones		= ( b:atp_TexFlavor == 'plaintex' ? [ 'V', 'W', 'X', 'Y'] : [ 'V', 'W', 'X'] )
	for L in math_zones
	    if s:HasSyntax('texMathZone'. L, line(".")) ||
			\ s:HasSyntax('texMathZone'. L, line("."), max([1, col(".")-1]))
		    call s:SearchAndSkipComments(Zone{L}_pat_O, 'cbW')
		    let zone 	= L
		    let return 	= 0
	    endif
	endfor


	if return
	    call cursor(saved_pos[1], saved_pos[2])
	    return
	endif

	if a:seltype == 'inner'
	    if zone =~ '^V\|W$' || zone == 'Y' && b:atp_TexFlavor == 'plaintex'
		normal! 2l
	    elseif zone == 'X'
		normal! l
	    endif
	    if getline(".")[col(".")-1] == ' ' && !g:atp_SelectInlineMath_withSpace
		normal! w
	    endif
	endif

	if visualmode() ==# 'V'
		normal! V
	else
		normal! v
	endif

	call s:SearchAndSkipComments(Zone{zone}_pat_C, 'W')

	if a:seltype == 'inner'
	    if getline(".")[col(".")-2] == ' ' && !g:atp_SelectInlineMath_withSpace
		normal! ge
	    else
		if col(".") > 1
		    call cursor(line("."),col(".")-1)
		else
		    call cursor(line(".")-1, len(getline(line(".")-1)))
		endif
	    endif
	endif

	if a:seltype == 'outer' && zone == 'Y'
	    call cursor(line("."),col(".")+1)
	endif
endfunction


vnoremap <silent> <Plug>LatexBox_SelectInlineMathInner :<C-U>call <SID>SelectInlineMath('inner')<CR>
vnoremap <silent> <Plug>LatexBox_SelectInlineMathOuter :<C-U>call <SID>SelectInlineMath('outer')<CR>
" }}}

" {{{ select bracket
function! <SID>SelectBracket(count, inner, bracket, bracket_dict, bracket_sizes)
    " a:bracket an opening bracket which is a key in a:bracket_dict
    " a:bracet_dict a dictionary of bracket pairs { '(' : ')', '\langle' : '\rangle', ... }
    " a:bracket_sizes a dictionary of matching bracket sizes { '\bigl' : '\bigr', ... }.
    "
    " implementation detail: (the \{:\} is treated as {:} with a size '\'.

    for key in keys(a:bracket_sizes)
	let idx = stridx(getline(line("."))[(col(".")-len(key)):(col(".")+len(key)-2)], key)
	if idx != -1
	    call cursor(line("."), col(".")+idx+len(key))
	    break
	endif
    endfor
    let idx = stridx(getline(line("."))[(col(".")-len(a:bracket)):(col(".")+len(a:bracket)-2)], a:bracket)
    if idx != -1
	" Note: add 'c' flag if the cursor is over the opening bracket.
	call cursor(line("."), col(".")+idx+len(a:bracket)-1)
	let flag = 'cbW'
    else
	let flag = 'bW'
    endif
    let begin_pos = searchpairpos(escape(a:bracket, '[]\'), '', escape(a:bracket_dict[a:bracket], '[]\'), flag)
    if a:count > 1
	for i in range(a:count-1)
	    let begin_pos = searchpairpos(escape(a:bracket, '[]\'), '', escape(a:bracket_dict[a:bracket], '[]\'), 'bW')
	endfor
    endif
    if !begin_pos[0]
	let begin_pos=searchpos(escape(a:bracket, '[]\'), 'Wc', line('.'))
    endif

    if !begin_pos[0]
	return
    endif

    let matches = matchlist(getline(line("."))[0:col(".")-2], '\(\\\w*\)\(\s*\)$')
    let o_size = get(matches, 1, '')
    let o_space = get(matches, 2, '')
    if index(keys(a:bracket_sizes), o_size) != -1
	let b_len = len(o_size)+len(o_space)
    else
	let b_len = 0
    endif
    " \{:
    if o_size == "\\"
	let matches = matchlist(getline(line("."))[0:col(".")-3], '\(\\\w*\)\(\s*\)$')
	let o_size = get(matches, 1, '')
	let o_space = get(matches, 2, '')
	if index(keys(a:bracket_sizes), o_size) != -1
	    let b_len += len(o_size)+len(o_space)
	endif
    endif

    if a:inner == 'inner'
	if col(".")+len(a:bracket) <= len(getline(line(".")))
	    call cursor(line("."), col(".")+len(a:bracket))
	else
	    call cursor(line(".")+1, 1)
	endif
    else
	if o_size != ""
	    let s_pos = [line("."), col(".")]
	    call cursor(line("."), col(".")-b_len)
	endif
    endif
    let begin_pos  = [ line("."), col(".") ]

    if exists("s_pos")
	call cursor(s_pos)
    endif

    let b_pos = [ line("."), col(".") ]

    let end_pos = searchpairpos(escape(a:bracket, '[]\'), '', escape(a:bracket_dict[a:bracket], '[]\'), 'nW')
    call cursor(end_pos)

    let matches = matchlist(getline(line("."))[0:col(".")-2], '\(\\\w*\)\(\s*\)$')
    let c_size = get(matches, 1, '')
    let c_space = get(matches, 2, '')
    if index(values(a:bracket_sizes), c_size) != -1
	let e_len = len(c_size)+len(c_space)
    else
	let e_len = 0
    endif
    " \}:
    if c_size == "\\"
	let matches = matchlist(getline(line("."))[0:col(".")-3], '\(\\\w*\)\(\s*\)$')
	let c_size = get(matches, 1, '')
	let c_space = get(matches, 2, '')
	if index(values(a:bracket_sizes), c_size) != -1
	    let e_len += len(c_size)+len(c_space)
	endif
    endif

    if a:inner == 'inner'
	if end_pos[1] > e_len+len(a:bracket_dict[a:bracket])
	    let end_pos[1] -= e_len+len(a:bracket_dict[a:bracket])
	else
	    let end_pos = [line(".")-1, len(getline(line(".")-1))]
	endif
    endif

    call cursor(begin_pos)
    if visualmode() ==# 'V'
	normal! V
    else
	normal! v
    endif
    call cursor(end_pos)

endfunction
let g:atp_bracket_dict_ = { '(' : ')', '{' : '}', '[' : ']', '\lceil' : '\rceil', '\lfloor' : '\rfloor', '\langle' : '\rangle', '\lgroup' : '\rgroup', '<' : '>', '\begin' : '\end' }
vnoremap <silent> <Plug>LatexBox_SelectBracketInner_1 :<C-U>call <SID>SelectBracket(v:count1, 'inner', '(', g:atp_bracket_dict_, g:atp_sizes_of_brackets)<CR>
vnoremap <silent> <Plug>LatexBox_SelectBracketOuter_1 :<C-U>call <SID>SelectBracket(v:count1, 'outer', '(', g:atp_bracket_dict_, g:atp_sizes_of_brackets)<CR>
vnoremap <silent> <Plug>LatexBox_SelectBracketInner_2 :<C-U>call <SID>SelectBracket(v:count1, 'inner', '{', g:atp_bracket_dict_, g:atp_sizes_of_brackets)<CR>
vnoremap <silent> <Plug>LatexBox_SelectBracketOuter_2 :<C-U>call <SID>SelectBracket(v:count1, 'outer', '{', g:atp_bracket_dict_, g:atp_sizes_of_brackets)<CR>
vnoremap <silent> <Plug>LatexBox_SelectBracketInner_3 :<C-U>call <SID>SelectBracket(v:count1, 'inner', '[', g:atp_bracket_dict_, g:atp_sizes_of_brackets)<CR>
vnoremap <silent> <Plug>LatexBox_SelectBracketOuter_3 :<C-U>call <SID>SelectBracket(v:count1, 'outer', '[', g:atp_bracket_dict_, g:atp_sizes_of_brackets)<CR>
" }}}

" {{{ select syntax
" syntax groups 'texDocZone' and 'texSectionZone' need to be synchronized
" before ':syntax sync fromstart' which is quite slow. It is better to provide
" other method of doing this. (If s:SelectSyntax is not syncing the syntax
" then the behaviour is unpredictable).
function! s:SelectSyntax(syntax)

    " mark the current position
    normal! m'

    let synstack	= map(synstack(line("."),col(".")), 'synIDattr(v:val, "name")')
    " there are better method for texDocZone and texSectionZone: 
    call filter(synstack, "v:val != 'texDocZone' && v:val != 'texSectionZone'")
    if  synstack == []
	return

    endif

    if a:syntax == 'inner'

	let len		= len(synstack)
	let syntax	= synstack[max([0, len-1])]

    elseif a:syntax == 'outer'
	let syntax	= synstack[0]

    else
	let syntax	= a:syntax

    endif

    let save_ww		= &l:ww
    set ww		+=b,l
    let save_pos	= getpos(".")	 


    if !count(map(synstack(line("."),col(".")), 'synIDattr(v:val, "name")'), syntax)
	return

    endif

    while count(map(synstack(line("."),col(".")), 'synIDattr(v:val, "name")'), syntax)
	normal! h
	" for some syntax groups do not move to previous line
	if col(".") == 1 && count(['texStatement', 'texTypeSize'], syntax)
	    keepjumps normal! h
	    break
	endif

    endwhile

    " begin offset
    if getpos(".")[2] < len(getline("."))
	call cursor(line("."),col(".")+1)

    else
	call cursor(line(".")+1, 1)

    endif

    if visualmode() ==# 'V'
	normal! V

    else
	normal! v

    endif

    call cursor(save_pos[1], save_pos[2]) 
    while count(map(synstack(line("."),max([1, min([col("."), len(getline("."))])])), 'synIDattr(v:val, "name")'), syntax) || len(getline(".")) == 0 
	keepjumps normal! l
	" for some syntax groups do not move to next line
	if col(".") == len(getline(".")) && count(['texStatement', 'texTypeSize'], syntax)
	    keepjumps normal! l
	    break
	endif
    endwhile

    " end offset
    if len(getline(".")) == 0
	call cursor(line(".")-1,len(getline(line(".")-1)))
    endif
    if count(['texParen', 'texLength', 'Delimiter', 'texStatement', 'texTypeSize', 'texRefZone', 'texSectionMarker', 'texTypeStyle'], syntax)
	if col(".") > 1
	    call cursor(line("."),col(".")-1)

	else
	    call cursor(line(".")-1,len(getline(line(".")-1)))

	endif
    elseif count(['texMathZoneV', 'texMathZoneW', 'texMathZoneY'], syntax)
	    call cursor(line("."),col(".")+1)

    endif

    let &l:ww	= save_ww
endfunction
" }}}

" select current environment {{{
function! s:SelectCurrentEnv(seltype)
	let [env, lnum, cnum, lnum2, cnum2] = LatexBox_GetCurrentEnvironment(1)
	call cursor(lnum, cnum)
	if a:seltype == 'inner'
		if env =~ '^\'
			call search('\\.\_\s*\S', 'eW')
		else
		    if lnum2 <= lnum+2
			call search('}\%(\s*{[^}]*}\)\?\%(\s*\\\%(label\|index\|hypertartet\s*{[^}]*}\)\s*{[^}]*}\)\{0,3}\%(\_\s*\[\_[^]]*\]\)\?\_s*\S', 'eW')
		    else
			call search('}\%(\s*{[^}]*}\)\?\%(\s*\\\%(label\|index\|hypertartet\s*{[^}]*}\)\s*{[^}]*}\)\{0,3}\%(\_\s*\[\_[^]]*\]\)\?\(\s*\n\)\?.', 'eW')
		    endif
		endif
	else
	    " This might depend on the vim settings.
	    if getline(lnum)[:(cnum-2)] =~ '^\s*$'
		call cursor(lnum, 1)
	    endif
	endif
	if visualmode() ==# 'V'
		normal! V
	else
		normal! v
	endif
	call cursor(lnum2, cnum2)
	if a:seltype == 'inner'
		call search('\S\s*\n\?', 'ebW')
	else
		if env =~ '^\'
			normal! l
		else
			call search('}', 'eW')
		endif
	endif
endfunction

function! s:SelectCurrentEnV()
	call s:SelectCurrentEnv('inner')
	execute 'normal o'
	call s:JumpToMatch('n', 1)
	execute 'normal o'
endfunction

" }}}

" Jump to the next braces {{{
"
function! LatexBox_JumpToNextBraces(backward)
	let flags = ''
	if a:backward
		normal h
		let flags .= 'b'
	else
		let flags .= 'c'
	endif
	if search('[][}{]', flags) > 0
		normal l
	endif
	let prev = strpart(getline('.'), col('.') - 2, 1)
	let next = strpart(getline('.'), col('.') - 1, 1)
	if next =~ '[]}]' && prev !~ '[][{}]'
		return "\<Right>"
	else
		return ''
	endif
endfunction
" }}}

" Highlight Matching Pair {{{
" TODO: Redefine NoMatchParen and DoMatchParen functions to handle
" s:HighlightMatchingPair function.
" TODO: do not match for \begin{document}:\end{document}
" 	or limit matches to the window (anyway it is done every time the
" 	cursor moves).
" 	winheight(0)			returns window height
" 	winsaveview()['topline'] 	returns the top line
function! <SID>HighlightMatchingPair()

	if !g:atp_HighlightMatchingPair
	    return
	endif

	2match none

	if LatexBox_InComment()
		return
	endif

" 	let open_pats 		= ['\\begin\>\ze\%(\s*{\s*document\s*}\)\@!', '\\left\>', '\c\\bigg\=\>\%((\|{\|\\{\|\[\)' ]
" 	let close_pats 		= ['\\end\>\ze\%(\s*{\s*document\s*}\)\@!', '\\right\>', '\c\\bigg\=\>\%()\|}\|\\}\|\]\)' ]
	let open_pats 		= ['\\begin\>\ze', '\\left\>', '\c\\bigg\=l\=\>\%((\|{\|\\{\|\[\)', '\\lceil\>', '\\lgroup\>', '\\lfloor', '\\langle' ]
	let close_pats 		= ['\\end\>\ze', '\\right\>', '\c\\bigg\=r\=\>\%()\|}\|\\}\|\]\)', '\\rceil', '\\rgroup\>', '\\rfloor', '\\rangle']
	let dollar_pat 		= '\\\@<!\$'
	let two_dollar_pat 	= '\\\@<!\$\$'

	let saved_pos = getpos('.')

	if getline('.')[col('.') - 1] == '$' && !s:HasSyntax('texSectionModifier', line('.'), col('.'))

	   if strpart(getline('.'), col('.') - 2, 1) == '\'
		   return
	   endif

		" match $-pairs
		let lnum = line('.')
		let cnum = col('.')

		" check if next or previous character is \$
		let two_dollars = ( getline('.')[col('.') - 2] == '$' ? 'p' : 
			    			\ ( getline('.')[col('.') ] == '$' ? 'n' : '0' ) )

		if two_dollars == '0' || b:atp_TexFlavor == 'tex'

		    " check if next character is in inline math
		    let [lnum2, cnum2] = searchpos('.', 'nW')
		    if lnum2 && s:HasSyntax('texMathZoneX', lnum2, cnum2)
			    call s:SearchAndSkipComments(dollar_pat, 'W')
		    else
			    call s:SearchAndSkipComments(dollar_pat, 'bW')
		    endif

		    execute '2match MatchParen /\%(\%' . lnum . 'l\%' . cnum . 'c\$'
					    \	. '\|\%' . line('.') . 'l\%' . col('.') . 'c\$\)/'

		elseif b:atp_TexFlavor == 'plaintex'
		    
		    " check if next character is in inline math
		    if two_dollars == 'n'
			call cursor(line('.'), col('.')+1)
		    endif
		    " position of the openning \$\$
		    let cnum = col('.')-1
		    let [lnum2, cnum2] = searchpos( '.' , 'nW')
		    if lnum2 && s:HasSyntax('texMathZoneY', lnum2, cnum2)
			    call s:SearchAndSkipComments(two_dollar_pat, 'W')
		    else
			" searching backward needs the cursor to be placed
			" before closing $$.
			if col(".") - 2 >= 1
			    call cursor(line("."), col(".")-2)
			else
			    call cursor(line(".")-1, 1) 
			    call cursor(line("."), col("$"))
			endif
			call s:SearchAndSkipComments(two_dollar_pat, 'bW')
		    endif
		    let cnum_e	= cnum+1
		    let cnum_E	= col('.')
		    let cnum_Ee	= cnum_E+1
		    execute '2match MatchParen /\%(\%' . lnum . 'l\%' . cnum . 'c\$'
					    \	. '\|\%' . lnum . 'l\%' . cnum_e . 'c\$'
					    \	. '\|\%' . line('.') . 'l\%' . cnum_E . 'c\$'
					    \	. '\|\%' . line('.') . 'l\%' . cnum_Ee . 'c\$\)/'

		endif

	else
		" match other pairs

		" find first non-alpha character to the left on the same line
		let [lnum, cnum] = searchpos('\A', 'cbW', line('.'))
		if strpart(getline(lnum), 0, cnum)  =~ '\\\%(begin\|end\){[^}]*}\=$'
		    let [lnum, cnum] = searchpos('\\', 'cbW', line('.'))
		endif

		let delim = matchstr(getline(lnum), '^\m\(' . join(open_pats + close_pats, '\|') . '\)', cnum - 1)

		if empty(delim)
			call setpos('.', saved_pos)
			return
		endif

		for i in range(len(open_pats))
			let open_pat = open_pats[i]
			let close_pat = close_pats[i]

			if delim =~# '^' . open_pat
				" if on opening pattern, go to closing pattern
				let stop_line=winheight(0)+winsaveview()['topline']
				call searchpair('\C' . open_pat, '', '\C' . close_pat, 'W', 'LatexBox_InComment()', stop_line)
				execute '2match MatchParen /\%(\%' . lnum . 'l\%' . cnum . 'c' . open_pats[i]
							\	. '\|\%' . line('.') . 'l\%' . col('.') . 'c' . close_pats[i] . '\)/'
				break
			elseif delim =~# '^' . close_pat
				" if on closing pattern, go to opening pattern
				let stop_line=winsaveview()['topline']
				if close_pat =~ '\\end'
				    call searchpair('\C\\begin\>', '', '\C\\end\>\zs'  , 'bW', 'LatexBox_InComment()', stop_line)
				else
				    call searchpair('\C' . open_pat, '', '\C' . close_pat, 'bW', 'LatexBox_InComment()', stop_line)
				endif
				execute '2match MatchParen /\%(\%' . line('.') . 'l\%' . col('.') . 'c' . open_pats[i]
							\	. '\|\%' . lnum . 'l\%' . cnum . 'c' . close_pats[i] . '\)/'
				break
			endif
		endfor
	endif

	call setpos('.', saved_pos)
endfunction
" }}}

" select current paragraph {{{
function! s:InnerSearchPos(begin, line, col, run)
        let cline 	= line(".")
	let ccol	= col(".") 
	call cursor(a:line, a:col)
	if a:begin == 1
	    let flag = 'bnW' . (a:run == 1 ? 'c' : '')
" Note: sometimes it is better is it stops before \\begin some times not,
" maybe it is better to decide for which environment names to stop
" (theorem, ... but not align [mathematical ones]). The same about end few
" lines ahead.
	    let pattern = '\%(^\s*$' . 
			\ '\|\\begin\>\s*{' .
			\ '\|\\\@<!\\\[' . 
			\ '\|\\\@<!\\\]\s*$' . 
			\ '\|^[^%]*\%(\ze\\par\>' . 
				\ '\|\ze\\newline\>' . 
				\ '\|\\end\s*{[^}]*}\s*\zs' . 
				\ '\)' . 
			\ '\|\\item\%(\s*\[[^\]]*\]\)\=' . 
			\ '\|\\\%(part\*\=' . 
				\ '\|chapter\*\=' .
				\ '\|section\*\=' . 
				\ '\|subsection\*\=' . 
				\ '\|subsubsection\*\=' . 
				\ '\|paragraph\*\=' . 
				\ '\|subparagraph\*\=\)\s*\%(\[[^]]*\]\)\=\s*{[^}]*}\s*\%({[^}]*}\)\=' . 
			\ '\|\\opening{[^}]*}' .
			\ '\|\\closing{' .
			\ '\|\\\@<!\$\$\s*$' . 
			\ '\|\\\\\*\=' . 
			\ '\|\\\%(small\|med\|big\)skip' .
			\ '\|\%^\|\%$' . 
			\ '\|^\s*%\)'
	    let [ line, column ] = searchpos(pattern, flag)
" 	    if getline(line) =~ '^\s*%'
" 		let [ line, column ] = [ line+1, 1 ]
" 	    endif
	else
	    let pattern = '\%(^\s*$' . 
			\ '\|\\\@<!\\\]\zs' .
			\ '\|\%(^\s\+\)\=\\end\>\s*{' .
			\ '\|^[^%]*\%(' . 
				\ '\zs\%(^\s\+\)\=\\par\>' .
				\ '\|\zs\(^\s\+\)\=\\newline\>' . 
				\ '\|\%(^\s\+\)\=\\begin\s*{[^}]*}\s*\%(\[[^]]*\]\)\=\)' . 
			\ '\|\%(^\%(\s\|%\)\+\)\=\\item' . 
			\ '\|\%(^\s\+\)\=\\\%(part\*\=' . 
				\ '\|chapter\*\=' . 
				\ '\|section\*\=' . 
				\ '\|subsection\*\=' . 
				\ '\|subsubsection\*\=' . 
				\ '\|paragraph\*\=' . 
				\ '\|subparagraph\*\=\){\(\n\|[^}]\)*}\s*\%(\[[^]]*\]\)\=\s*\%({^}]*}\)\=' . 
			\ '\|\\opening{[^}]*}' .
			\ '\|\\closing{' .
			\ '\|^\s*\\\@<!\\\[' . 
			\ '\|^\s*\\\@<!\$\$' . 
			\ '\|\\\\\*\=' .
			\ '\|\\\%(small\|med\|big\)skip' .
			\ '\|\%^\|\%$\|^\s*\\\@<!%\)'
	    let [ line, column ] = searchpos(pattern, 'nW')
" 	    if getline(line) =~ '^\s*\\\@<!%'
" 		let [ line, column ] = [ line-1, len(getline(line-1))-1 ]
" 	    endif
	endif
	call cursor(cline, ccol)
	return [ line, column ] 
endfunction
if g:atp_debugSelectCurrentParagraph
    command! EchoInnerBegin :echo s:InnerSearchPos(1, line("."), col("."), 1)
    command! EchoInnerEnd :echo s:InnerSearchPos(0, line("."), col("."), 1)
endif


function! s:SelectCurrentParagraph(seltype) 
    if a:seltype == "inner"
	    if getline(line(".")) =~ '^\s*\\\@<!%'
	    call SelectComment()
	    return
	endif
	" inner type ends and start with \[:\] if \[ is at the begining of
	" line (possibly with white spaces) and \] is at the end of line
	" (possibly with white spaces, aswell).
	" This can cause some asymetry. So I prefer the simpler solution: \[:\]
	" alwasy ends inner paragraph. But how I use tex it is 'gantz egal'
	" but this solution can make a difference for some users, so I keep
	" the first way.
	"
	" Find begin position (iterate over math zones).
	let true = 1
	let [ bline, bcol, eline, ecol ] = copy([ line("."), col("."), line("."), col(".") ])
	let i =1
	if g:atp_debugSelectCurrentParagraph
	    call atplib#Log("SelectCurrentParagraph.log", "", "init")
	    call atplib#Log("SelectCurrentParagraph.log", " B pos:" . string([line("."), col(".")]) . " e-pos:" . string([bline, bcol])) 
	endif
	while true
	    let [ bline, bcol ] = s:InnerSearchPos(1, bline, bcol, i)
	    let true = atplib#complete#CheckSyntaxGroups(g:atp_MathZones, bline, bcol) && strpart(getline(bline), bcol-1) !~ '^\\\[\|^\\begin\>'
	    if g:atp_debugSelectCurrentParagraph
		call atplib#Log("SelectCurrentParagraph.log",i . ") " . string([bline, bcol]) . " pos:" . string([line("."), col(".")]) . " true: " . true)
	    endif
	    let i+=1
	endwhile
	if g:atp_debugSelectCurrentParagraph
	    let [ g:bline0, g:bcol0]	= deepcopy([ bline, bcol])
	    let bline_str = strpart(getline(bline), bcol-1)
	    call atplib#Log("SelectCurrentParagraph.log", "[bline, bcol]=".string([ bline, bcol]))
	    call atplib#Log("SelectCurrentParagraph.log", "getline(bline)=".getline(bline))
	    call atplib#Log("SelectCurrentParagraph.log", "bline condition=".(getline(bline) !~ '^\s*$' && getline(bline) !~ '\\begin\s*{\s*\(equation\|align\|inlinemath\|dispayedmath\)\s*}' && bline_str !~ '^\%(\\\[\|\\item\>\|\\begin\>\)'))
	endif
	" Move to the end of match
	let [ cline, ccolumn ] = [ line("."), col(".") ]
	call cursor(bline, bcol)
	let bline_str 		= strpart(getline(bline), bcol-1)
	if getline(bline) =~ '^\s*%'
	   let bline 		= search('^\s*%\@!')
	   let bcol		= 1
	   let no_motion   	= 1
	elseif getline(bline) !~ '^\s*$' && bline_str !~ '^\%(\\\[\|\\item\>\)'
	    let pattern = '\%(^\s*$' . 
			\ '\|^[^%]*\%(\\\zepar\>' . 
			    \ '\|\\\zenewline\>' . 
			    \ '\|\\end\s*{[^}]*}\s*' . 
			    \ '\|\\begin\%(\s*{[^}]*}\)\{1,2}\s*'.
				\ '\%(\[[^]]*\]\|{[^}]*}\)\{0,2}\s*'.
				\ '\%(\%(\\\%(label\|index\|hypertarget\s*{[^}]*}\)\s*{[^}]*}\)\s*\%(\\footnote\s*\%(\n' . 
					\ '\|[^}]\)*}\)\=' . 
				    \ '\|\s*\%(\\footnote\s*\%(\n' . 
				\ '\|[^}]\)*}\)\%(\s*\\\%(label\|index\|hypertarget\s*{[^}]*}\s*\)\s*{[^}]*}\)\=\)\{0,3}\)' . 
			\ '\|\\item\%(\s*\[[^\]]*\]\)\=' . 
			\ '\|\\\%(part\*\=' . 
			\ '\|chapter\*\=' . 
			\ '\|section\*\=' . 
			\ '\|subsection\*\=' . 
			\ '\|subsubsection\*\=' . 
			\ '\|paragraph\*\=' . 
			\ '\|subparagraph\*\=\)\s*\%(\[[^]]*\]\)\=\s*{[^}]*}\s*\%({[^}]*}\)\=\%(\s*\\\%(label\|hypertarget\s*{[^}]*}\)\s*{[^}]*}\)\{,2}' . 
			\ '\|\\opening{[^}]*}' .
			\ '\|\\closing{' .
			\ '\|\\\@<!\\\]\s*$' . 
			\ '\|\\\@<!\$\$\s*$' . 
			\ '\|\\\\\*\=\%(\[\d\+\w\+\]\)\=' .
			\ '\|\\\%(small\|med\|big\)skip\)'
	    let [ bline, bcol ] = searchpos(pattern, 'ecnW')
	elseif bline_str =~ '^\\item\>\|^\\begin\>' && bcol > 1
	    let bcol -= 1 
	endif
	if g:atp_debugSelectCurrentParagraph
	    call atplib#Log("SelectCurrentParagraph.log",' [bline, bcol]=' . string([bline, bcol]) . " len bline=".len(getline(bline)))
	endif

	" Find end position (iterate over math zones).
	call cursor(bline, len(line(bline)))
	if strpart(getline(bline), bcol-1) =~ '\\begin\>'
	    let [ eline, ecol ] = s:InnerSearchPos(0, bline, len(getline(bline)), 1)
	else
	    let [ eline, ecol ] = s:InnerSearchPos(0, bline, bcol, 1)
	endif
	if g:atp_debugSelectCurrentParagraph
	    call atplib#Log("SelectCurrentParagraph.log", "eline=".eline." ecol=".ecol)
	endif
	let line = strpart(getline(eline), ecol-1)
	let true = atplib#complete#CheckSyntaxGroups(g:atp_MathZones, eline, ecol) && line !~ '^\s*\\\]\|^\s*\\end\>\|^\s*\\begin\>'
	let i = 2
	if g:atp_debugSelectCurrentParagraph
	    call atplib#Log("SelectCurrentParagraph.log", " E pos:" . string([line("."), col(".")]) . " e-pos:" . string([eline, ecol]) . " true: " . true)
	endif
	while true
	    let line	= strpart(getline(eline), ecol-1)
	    if g:atp_debugSelectCurrentParagraph
		call atplib#Log("SelectCurrentParagraph.log", i . ") E line=" . line)
	    endif
	    if line =~ '^\\\@<!\%(\\)\|\\\]\|\\\[\|\\\@<!\$\$\)'
		if g:atp_debugSelectCurrentParagraph
		    call atplib#Log("SelectCurrentParagraph.log", i . ") E line break " . eline . " line=" . line)
		endif
		break
	    endif
	    let [ eline, ecol ] = s:InnerSearchPos(0, eline, ecol, i)
	    let true = atplib#complete#CheckSyntaxGroups(g:atp_MathZones, eline, ecol) && line !~ '^\s*\\\]\|^\s*\\end\>\|^\s*\\begin\>'
	    if g:atp_debugSelectCurrentParagraph
		call atplib#Log("SelectCurrentParagraph.log", i . ") " . string([eline, ecol]) . " pos:" . string([line("."), col(".")]) . " true: " . true)
	    endif
	    let i+=1
	endwhile
	if line !~ '\\end\>'
	    let emove	= ""
	endif
    else
	let [ bline, bcol ] = searchpos('^\s*$\|^[^%]*\zs\\par\>\|\\begin\s*{\s*\%(document\|letter\)\s*}', 'bcnW')
	let [ eline, ecol ] = searchpos('^\s*$\|^[^%]*\zs\\par\>\|\\end\s*{\s*\%(document\|letter\)\s*}\zs', 'nW')
    endif
    
    if g:atp_debugSelectCurrentParagraph
	let [ g:bline, g:bcol]	= deepcopy([ bline, bcol])
	let [ g:eline, g:ecol]	= deepcopy([ eline, ecol])
	call atplib#Log("SelectCurrentParagraph.log", "[bline, bcol]=".string([ bline, bcol]))
	call atplib#Log("SelectCurrentParagraph.log", "[eline, ecol]=".string([ eline, ecol]))
    endif

    let bline_str = strpart(getline(bline), bcol-1)
    let eline_str = strpart(getline(eline), 0, ecol)
    let eeline_str  = strpart(getline(eline), ecol-1)

    if g:atp_debugSelectCurrentParagraph
	let g:bline_str = bline_str
	let g:eline_str = eline_str
	let g:eeline_str = eeline_str
	call atplib#Log("SelectCurrentParagraph.log", "bline_str=".bline_str)
	call atplib#Log("SelectCurrentParagraph.log", "eline_str=".eline_str)
	call atplib#Log("SelectCurrentParagraph.log", "eeline_str=".eeline_str)
    endif

    if getline(bline) =~ '\\par\>\|\\newline\>\|\\begin\s*{\s*\%(document\|letter\)\s*}' || bline_str =~ '^\%(\\\[\|\\item\>\)' || exists("no_motion")
	" move to the beginning of \par
	let bmove	= ''
    else
	" or to the begining of line 
	let bmove 	=  "w"
    endif

    let whichwrap = &whichwrap

    if getline(eline) =~ '\\par\>'
	let emove	= 'gE'
    elseif eline_str  =~ '\\@<!\\\]'
	let emove	= ''
    elseif eeline_str =~ '^\s*\\end\s*{\s*\%(align\%(at\)\=\|equation\|display\%(ed\)\=math'
		\ . '\|array\|eqnarray\|inlinemath\|math\)\*\=\s*}'
	let emove	= 'E'
    elseif eeline_str =~ '^\\closing\>'
	let emove	= 'ge'
    else
	let emove	= 'h'
	set whichwrap+=h
	" This used to be 'ge' as well.
    endif

    if g:atp_debugSelectCurrentParagraph
	let g:bmove = bmove
	let g:emove = emove
	call atplib#Log("SelectCurrentParagraph.log", "bmove=".bmove." emove=".emove)
    endif

    call cursor(bline, bcol)
    if !empty(bmove)
	execute "normal " . bmove
    endif

    if mode() !~ 'v'  
	if visualmode() ==# 'V'
		normal! V
	else
		normal! v
	endif
    endif

    call cursor(eline, ecol)
    if !empty(emove)
	execute "normal " . emove
    endif
    let &whichwrap=whichwrap
endfunction
" }}}

" {{{ select comment
" This only works with lines which begin with the comment sign '%'.
function! SelectComment()
    if getline(".") !~ '^\s*%'
	return
    endif
    call search('^\(\s*%.*\n\)\@<!\zs\(\s*%\)', "cbW")
    if visualmode() ==# 'V'
	    normal! V
    else
	    normal! v
    endif
    call search('\%(^\s*%.*\zs\n\)\%(^\s*%\)\@!', "cW")
endfunction

" {{{ select group
function! SelectEnvironment(name)
    call search('\\begin\s*{\s*'.a:name.'\s*}', "cbW")
"     if visualmode() ==# 'V'
	    normal! V
"     else
" 	    normal! v
"     endif
    call search('\\end\s*{\s*'.a:name.'\s*}', "cW")
endfunction
" }}}

" {{{ LatexBox_HighlightPairs augroup
    augroup LatexBox_HighlightPairs 
      " Replace all matchparen autocommands
      au!
      au! CursorMoved *.tex call s:HighlightMatchingPair()
    augroup END 

" Highlight bold and italic, by M. Szamotulski
" (to add: optionaly only in gui) 
" this function should do that for every \texbf on the screen
" {{{
" THIS IS TOO SLOW:
function! HighlightEmphText()

     let saved_pos	= getpos('.')
     
     let top_line	= winsaveview()['topline']
     let end_line	= top_line + winheight(0)

     call cursor(top_line, 1)

     keepjumps let [start_lnum, start_cnum] = searchpos('\\\%(textbf{\|bf\)\zs', 'W', end_line)
     let [lnum, cnum] = copy([ start_lnum, start_cnum])

     " if there are no matches, return. 
     if [ lnum, cnum] == [0, 0]
	 return
     endif

     while start_lnum <= end_line && [lnum, cnum] != [0, 0]
     
	 let [lnum, cnum] = copy([ start_lnum, start_cnum])

	 if [lnum, cnum] == [ 0, 0]
	     keepjumps call setpos( '.', saved_pos)
	     return
	 endif

	 while s:HasSyntax('texMatcher', lnum, cnum)
	     if cnum < len(getline(lnum))
		 let cnum += 1
	     else
		 let lnum += 1
		 let cnum  = 1
	     endif
	 endwhile

	 if cnum == 1
	     let stop_lnum = lnum-1
	     let stop_cnum = len(getline(stop_lnum))
	 else
	     let stop_lnum = lnum
	     let stop_cnum = cnum
	 endif


	 let start_lnum 	-= 1
	 let start_cnum		-= 1
	 let stop_lnum  	+= 1

	 call matchadd( 'textBold', '\%>' . start_lnum . 'l\%>' . start_cnum . 'c' . '\%<' . stop_lnum . 'l\%<' . stop_cnum . 'c')

	 let [start_lnum, start_cnum] = searchpos('\\\%(textbf{\|bf\)\zs', 'W', end_line)

     endwhile

     keepjumps call setpos( '.', saved_pos)

"      return [start_lnum, start_cnum, stop_lnum, stop_cnum]
 endfunction
" the 2match function can be run once:
" call s:HighlightEmphText()
"     augroup HighlightEmphText
"       " Replace all matchparen autocommands
"       autocmd CursorMoved *.tex call HighlightEmphText()
"     augroup END
" }}}
endif

" Mappings:
vnoremap <silent> <buffer> <Plug>SelectInnerSyntax 	<ESC>:<C-U>call <SID>SelectSyntax('inner')<CR>
vnoremap <silent> <buffer> <Plug>SelectOuterSyntax 	<ESC>:<C-U>call <SID>SelectSyntax('outer')<CR>
vnoremap <silent> <Plug>LatexBox_SelectCurrentEnvInner 	:<C-U>call <SID>SelectCurrentEnv('inner')<CR>
vnoremap <silent> <Plug>LatexBox_SelectCurrentEnVInner 	:<C-U>call <SID>SelectCurrentEnV()<CR>
vnoremap <silent> <Plug>LatexBox_SelectCurrentEnvOuter 	:<C-U>call <SID>SelectCurrentEnv('outer')<CR>
vnoremap <silent> <Plug>ATP_SelectCurrentParagraphInner :<C-U>call <SID>SelectCurrentParagraph('inner')<CR>
vnoremap <silent> <Plug>ATP_SelectCurrentParagraphOuter :<C-U>call <SID>SelectCurrentParagraph('outer')<CR>
vmap <silent><buffer> <Plug>vSelectComment 		:<C-U>call SelectComment()<CR>
nmap <silent><buffer> <Plug>SelectFrameEnvironment	:call SelectEnvironment('frame')<CR>
" vmap <silent><buffer> <Plug>vSelectFrameEnvironment	:<C-U>call <SID>SelectEnvironment('frame')<CR>
"}}}

