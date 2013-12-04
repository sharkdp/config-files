" Author:      Marcin Szamotulski	
" Descriptiion:	These are various editting tools used in ATP.
" Note:	       This file is a part of Automatic Tex Plugin for Vim.
" Language:    tex
" Last Change: Wed Nov 07, 2012 at 23:02:22  +0000

let s:sourced 	= exists("s:sourced") ? 1 : 0
"{{{ ATP_strlen()
" This function is used to measure lenght of a string using :Align, :TexAlign
" commads. See help file of AlignPlugin for g:Align_xstrlen variable.
function! ATP_strlen(x)
    if v:version < 703 || !&conceallevel 
	return strlen(substitute(a:x, '.\Z', 'x', 'g'))
    endif
    let x=a:x
    let hide = ( &conceallevel < 3 ? ' ' : '' )
    " The hide character has to be a non-word character, otherwise for
    " example: \otimes\bigcap -> \otimesx and '\\otimes\>' will not match.
    let greek=[ 
	    \ '\\alpha', '\\beta', '\\gamma', '\\delta', '\\epsilon', '\\varepsilon',
	    \ '\\zeta', '\\eta', '\\theta', '\\vartheta', '\\kappa', '\\lambda', '\\mu',
	    \ '\\nu', '\\xi', '\\pi', '\\varpi', '\\rho', '\\varrho', '\\sigma',
	    \ '\\varsigma', '\\tau', '\\upsilon', '\\phi', '\\varphi', '\\chi', '\\psi', '\\omega',
	    \ '\\Gamma', '\\Delta', '\\Theta', '\\Lambda', '\\Xi', '\\Pi', '\\Sigma',
	    \ '\\Upsilon', '\\Phi', '\\Psi', '\\Omega']
    if &enc == 'utf-8' && g:tex_conceal =~# 'g'
	for gletter in greek
	    let x = substitute(x, gletter, hide, 'g')
	endfor
    endif
"     let g:x_1 = x
    let s:texMathList=[
        \ '|', 'angle', 'approx', 'ast', 'asymp', 'backepsilon', 'backsimeq', 'barwedge', 'because',
        \ 'between', 'bigcap', 'bigcup', 'bigodot', 'bigoplus', 'bigotimes', 'bigsqcup', 'bigtriangledown', 'bigvee',
        \ 'bigwedge', 'blacksquare', 'bot', 'boxdot', 'boxminus', 'boxplus', 'boxtimes', 'bumpeq', 'Bumpeq',
        \ 'cap', 'Cap', 'cdots', 'cdot', 'circ', 'circeq', 'circlearrowleft', 'circlearrowright', 'circledast',
        \ 'circledcirc', 'complement', 'cong', 'coprod', 'cup', 'Cup', 'curlyeqprec', 'curlyeqsucc', 'curlyvee',
        \ 'curlywedge', 'dashv', 'diamond', 'div', 'doteqdot', 'doteq', 'dotplus', 'dotsb', 'dotsc',
        \ 'dotsi', 'dotso', 'dots', 'doublebarwedge', 'downarrow', 'Downarrow', 'emptyset', 'eqcirc', 'eqsim',
        \ 'eqslantgtr', 'eqslantless', 'equiv', 'exists', 'fallingdotseq', 'forall', 'ge', 'geq', 'geqq',
        \ 'gets', 'gneqq', 'gtrdot', 'gtreqless', 'gtrless', 'gtrsim', 'hookleftarrow', 'hookrightarrow', 'iiint',
        \ 'iint', 'Im', 'in', 'infty', 'int', 'lceil', 'ldots', 'leftarrow', 'left\\{',
        \ 'Leftarrow', 'leftarrowtail', 'Leftrightarrow', 
	\ 'leftrightsquigarrow', 'leftthreetimes', 'leqq', 
        \ 'leq', 'lessdot', 'lesseqgtr', 'lesssim', 'le', 'lfloor', 'lmoustache', 'lneqq', 'ltimes', 'mapsto',
        \ 'measuredangle', 'mid', 'mp', 'nabla', 'ncong', 'nearrow', 'neg', 'neq',
        \ 'nexists', 'ne', 'ngeqq', 'ngeq', 'ngtr', 'ni', 'nleftarrow', 'nLeftarrow', 'nLeftrightarrow', 'nleqq',
        \ 'nleq', 'nless', 'nmid', 'notin', 'nprec', 'nrightarrow', 'nRightarrow', 'nsim', 'nsucc',
        \ 'ntriangleleft', 'ntrianglelefteq', 'ntrianglerighteq', 'ntriangleright', 'nvdash', 'nvDash', 'nVdash', 'nwarrow', 'odot',
        \ 'oint', 'ominus', 'oplus', 'oslash', 'otimes', 'owns', 'partial', 'perp', 'pitchfork',
        \ 'pm', 'precapprox', 'preccurlyeq', 'preceq', 'precnapprox', 'precneqq', 'precsim', 'prec', 'prod',
        \ 'propto', 'rceil', 'Re', 'rfloor', 'Rightarrow', 'rightarrowtail', 'rightarrow', 'right\\}',
        \ 'subseteqq', 'subseteq', 'subsetneqq', 'subsetneq', 'subset', 'Subset', 'succapprox', 'succcurlyeq',
        \ 'succeqq', 'succnapprox', 'succneq', 'succsim', 'succ', 'sum', 'Supset', 'supseteqq', 'supseteq', 'supsetneqq',
        \ 'supsetneq', 'surd', 'swarrow', 'therefore', 'times', 'top', 'to', 'trianglelefteq', 'triangleleft',
        \ 'triangleq', 'triangleright', 'trianglerighteq', 'twoheadleftarrow', 'twoheadrightarrow', 'uparrow', 'Uparrow', 'updownarrow', 'Updownarrow',
        \ 'varnothing', 'vartriangle', 'vdash', 'vDash', 'Vdash', 'vdots', 'veebar', 'vee', 'Vvdash',
        \ 'wedge', 'wr', 'gg', 'll', 'backslash', 'langle', 'lbrace', 'lgroup', 'rangle', 'rbrace',
	\ ]
  let s:texMathDelimList=[
     \ '<', '>', '(', ')', '\[', ']', '\\{', 
     \ '\\}', '|', '\\|', '\\backslash', '\\downarrow', '\\Downarrow', '\\langle', '\\lbrace', 
     \ '\\lceil', '\\lfloor', '\\lgroup', '\\lmoustache', '\\rangle', '\\rbrace', '\\rceil', 
     \ '\\rfloor', '\\rgroup', '\\rmoustache', '\\uparrow', '\\Uparrow', '\\updownarrow', '\\Updownarrow']
    if g:tex_conceal =~# 'm'
	for symb in s:texMathList
	    let x=substitute(x, '\C\\'.symb.'\>', hide, 'g')
	    " The pattern must end with '\>', since there are commands with
	    " the same begining, for example \le and \left, etc...
	endfor
	for symb in s:texMathDelimList
	    let x=substitute(x, '\\[Bb]igg\=[lr]\>'.symb, hide, 'g') 
	endfor
	let x=substitute(x, '\\\%(left\|right\)\>', '', 'g')
    endif
"     let g:x_2 = x
    if &enc == 'utf-8' && g:tex_conceal =~# 's'
	let x=substitute(x, '\\\@<![_^]\%({.\)\=', '', 'g')
    endif
"     let g:x_3 = x
    if &enc == 'utf-8' && g:tex_conceal =~# 'a'
	for accent in [
		    \ '\\[`''\^"~kruv]{\=[aA]}\=\>',
		    \ '\\[`''\^"~kruv]{\=[aA]}\=\>',
		    \ '\\[`\^.cv]{\=[cC]}\=\>',
		    \ '\\[v]{\=[dD]}\=\>',
		    \ '\\[`''\^"~.ckuv]{\=[eE]}\=\>',
		    \ '\\[`.cu]{\=[gG]}\=\>',
		    \ '\\[`''\^"~.u]{\=[iI]}\=\>',
		    \ '\\[''\^"cv]{\=[lL]}\=\>',
		    \ '\\[''~cv]{\=[nN]}\=\>',
		    \ '\\[`''\^"~.Hku]{\=[oO]}\=\>',
		    \ '\\[''cv]{\=[rR]}\=\>',
		    \ '\\[''\^cv]{\=[sS]}\=\>',
		    \ '\\[''cv]{\=[tT]}\=\>',
		    \ '\\[`''\^"~Hru]{\=[uU]}\=\>',
		    \ '\\[\^]{\=[wW]}\=\>',
		    \ '\\[`''\^"~]{\=[yY]}\=\>',
		    \ '\\[''.v]{\=[zZ]}\=\>',
		    \ '\\[`''\^"~.cHkruv]{\=[aA]}\=\>',
		    \ '\\[`''\^"~.u]{\=\\i}\=\>',
		    \ '\\AA\>', '\\[oO]\>', '\\AE\>', '\\ae\>', '\\OE\>', '\\ss\>' ]
	    let x=substitute(x, accent, hide, 'g')
	endfor
    endif
    " Add custom concealed symbols.
"     let g:x_4 = x
    let x=substitute(x,'.','x','g')
"     let g:x=x
    return strlen(x)
endfunction
"}}}
" {{{ InsertItem()
" ToDo: indent
function! InsertItem()
    let begin_line	= searchpair( '\\begin\s*{\s*\%(enumerate\|itemize\|thebibliography\)\s*}', '', '\\end\s*{\s*\%(enumerate\|itemize\|thebibliography\)\s*}', 'bnW')
    let saved_pos	= getpos(".")
    call cursor(line("."), 1)

    if g:atp_debugInsertItem
	let g:debugInsertItem_redir= "redir! > ".g:atp_TempDir."/InsertItem.log"
	exe "redir! > ".g:atp_TempDir."/InsertItem.log"
    endif

    if getline(begin_line) =~ '\\begin\s*{\s*thebibliography\s*}'
	call cursor(saved_pos[1], saved_pos[2])
	let col = ( col(".") == 1 ? 0 : col("."))
	let new_line	= strpart(getline("."), 0, col) . '\bibitem' . strpart(getline("."), col)
	call setline(line("."), new_line)

	" Indent the line:
	if &l:indentexpr != ""
	    let v:lnum=saved_pos[1]
	    execute "let indent = " . &l:indentexpr
	    let i 	= 1
	    let ind 	= ""
	    while i <= indent
		let ind	.= " "
		let i	+= 1
	    endwhile
	else
	    indent	= -1
	    ind 	=  matchstr(getline("."), '^\s*')
	endif
	let indent_old = len(matchstr(getline("."), '^\s*'))
	call setline(line("."), ind . substitute(getline("."), '^\s*', '', ''))
	let a=(saved_pos[2]==1 ? -1 : 0 )
	let saved_pos[2]	+= len('\bibitem') + indent - indent_old + a
	call cursor(saved_pos[1], saved_pos[2])

	if g:atp_debugInsertItem
	    let g:InsertIntem_return = 0
	    silent echo "0] return"
	    redir END
	endif
	return
    endif

    " This will work with \item [[1]], but not with \item [1]]
    let [ bline, bcol]	= searchpos('\\item\s*\zs\[', 'b', begin_line) 
    if bline == 0
	call cursor(saved_pos[1], saved_pos[2])
	let col= (col(".") == 1 ? 0 : col("."))
	if search('\\item\>', 'nb', begin_line)
	    let new_line	= strpart(getline("."), 0, col) . '\item '. strpart(getline("."), col)
	else
	    let new_line	= strpart(getline("."), 0, col) . '\item'. strpart(getline("."), col)
	endif
	call setline(line("."), new_line)

	" Indent the line:
	if &l:indentexpr != ""
	    let v:lnum=saved_pos[1]
	    execute "let indent = " . &l:indentexpr
	    let i 	= 1
	    let ind 	= repeat(" ", indent)
	else
	    let indent	= -1
	    let ind 	=  matchstr(getline("."), '^\s*')
	endif
	if g:atp_debugInsertItem
	    silent echo "1] indent=".len(ind)
	endif
	call setline(line("."), ind . substitute(getline("."), '^\s*', '', ''))

	" Set the cursor position
	let saved_pos[2]	+= len('\item') + indent
	keepjumps call setpos(".", saved_pos)

	if g:atp_debugInsertItem
	    let g:debugInsertItem_return = 1
	    silent echo "1] return"
	    redir END
	endif
	return ""
    endif
    let [ eline, ecol]	= searchpairpos('\[', '', '\]', 'nr', '', line("."))
    if eline != bline
	if g:atp_debugInsertItem
	    let g:debugInsertItem_return = 2
	    silent echo "2] return"
	    redir END
	endif
	return ""
    endif

    let item		= strpart(getline("."), bcol, ecol - bcol - 1)
    let bpat		= '(\|{\|\['
    let epat		= ')\|}\|\]\|\.'
    let number		= matchstr(item, '\d\+')
    let subNr		= matchstr(item, '\d\+\zs\a\ze')
    let space		= matchstr(getline("."), '\\item\zs\s*\ze\[')
    if nr2char(number) != "" && subNr == "" 
	let new_item	= substitute(item, number, number + 1, '')
	if g:atp_debugInsertItem
	    silent echo "(1) new_item=".new_item
	endif
    elseif item =~ '\%('.bpat.'\)\=\s*\%(i\|ii\|iii\|iv\|v\|vi\|vii\|viii\|ix\)\%('.epat.'\)\=$'
	let numbers	= [ 'i', 'ii', 'iii', 'iv', 'v', 'vi', 'vii', 'viii', 'ix', 'x' ]
	let roman	= matchstr(item, '\%('.bpat.'\)\=\s*\zs\w\+\ze\s*\%('.epat.'\)\=$')
	let new_roman	= get(numbers, index(numbers, roman) + 1, 'xi') 
	let new_item	= substitute(item,  '^\%('.bpat.'\)\=\s*\zs\a\+\ze\s*\%('.epat.'\)\=$', new_roman, 'g') 
	if g:atp_debugInsertItem
	    silent echo "(2) new_item=".new_item
	endif
    elseif nr2char(number) != "" && subNr != ""
	let alphabet 	= [ 'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'w', 'x', 'y', 'z' ] 
	let char	= matchstr(item, '^\%('.bpat.'\)\=\s*\d\+\zs\a\ze\s*\%('.epat.'\)\=$')
	let new_char	= get(alphabet, index(alphabet, char) + 1, 'z')
	let new_item	= substitute(item, '^\%('.bpat.'\)\=\s*\d\+\zs\a\ze\s*\%('.epat.'\)\=$', new_char, 'g')
	if g:atp_debugInsertItem
	    silent echo "(3) new_item=".new_item
	endif
    elseif item =~ '\%('.bpat.'\)\=\s*\w\s*\%('.epat.'\)\='
	let alphabet 	= [ 'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'w', 'x', 'y', 'z' ] 
	let char	= matchstr(item, '^\%('.bpat.'\)\=\s*\zs\w\ze\s*\%('.epat.'\)\=$')
	let new_char	= get(alphabet, index(alphabet, char) + 1, 'a')
	let new_item	= substitute(item, '^\%('.bpat.'\)\=\s*\zs\w\ze\s*\%('.epat.'\)\=$', new_char, 'g')
	if g:atp_debugInsertItem
	    silent echo "(4) new_item=".new_item
	endif
    else
	let new_item	= item
	if g:atp_debugInsertItem
	    silent echo "(5) new_item=".item
	endif
    endif

    keepjumps call setpos(".", saved_pos)

    let col = (col(".")==1 ? 0 : col("."))
    let new_line	= strpart(getline("."), 0, col) . '\item' . space . '[' . new_item . '] ' . strpart(getline("."), col)
    if g:atp_debugInsertItem
	silent echo "new_line=".new_line
    endif
    call setline(line("."), new_line)

    " Indent the line:
    if &l:indentexpr != ""
	let v:lnum=saved_pos[1]
	execute "let indent = " . &l:indentexpr
	let i 	= 1
	let ind 	= ""
	while i <= indent
	    let ind	.= " "
	    let i	+= 1
	endwhile
    else
	ind 	= matchstr(getline("."), '^\s*')
    endif
    if g:atp_debugInsertItem
	silent echo "indent=".len(ind)
    endif
    let indent_old = len(matchstr(getline("."), '^\s*'))
    call setline(line("."), ind . substitute(getline("."), '^\s*', '', ''))

    " Set the cursor position
    let saved_pos[2]	+= len('\item' . space . '[' . new_item . ']') + indent - indent_old
    keepjumps call setpos(".", saved_pos)


    if g:atp_debugInsertItem
	let g:debugInsertItem_return = 3
	silent echo "3] return"
	redir END
    endif
    return ""
endfunction
" }}}
" InsertEnvironment() {{{ 
function! <SID>InsertEnvironment(bang,env_name)
    if a:bang == ""
	if getline(".") =~ '^\s*$'
	    delete _
	endif
	call append(line("."), ['\begin{'.a:env_name.'}', '\end{'.a:env_name.'}']) 
	normal! j$
    else
	let line=getline(".")[:col(".")-1]."\\begin{".a:env_name."}\\end{".a:env_name."}".getline(".")[col("."):]
	call setline(line("."), line)
	call search('\\end', '', line("."))
    endif
endfunction "}}}
"{{{ Variables
if !exists("g:atp_no_toggle_environments")
    let g:atp_no_toggle_environments=[ 'document', 'tikzpicture', 'picture']
endif
if !exists("g:atp_toggle_environment_1")
    let g:atp_toggle_environment_1=[ 'center', 'flushleft', 'flushright', 'minipage' ]
endif
if !exists("g:atp_toggle_environment_2")
    let g:atp_toggle_environment_2=[ 'enumerate', 'itemize', 'list', 'description' ]
endif
if !exists("g:atp_toggle_environment_3")
    let g:atp_toggle_environment_3=[ 'quotation', 'quote', 'verse' ]
endif
if !exists("g:atp_toggle_environment_4")
    let g:atp_toggle_environment_4=[ 'theorem', 'proposition', 'lemma' ]
endif
if !exists("g:atp_toggle_environment_5")
    let g:atp_toggle_environment_5=[ 'corollary', 'remark', 'note' ]
endif
if !exists("g:atp_toggle_environment_6")
    let g:atp_toggle_environment_6=[  'equation', 'align', 'array', 'alignat', 'gather', 'flalign', 'multline'  ]
endif
if !exists("g:atp_toggle_environment_7")
    let g:atp_toggle_environment_7=[ 'smallmatrix', 'pmatrix', 'bmatrix', 'Bmatrix', 'vmatrix' ]
endif
if !exists("g:atp_toggle_environment_8")
    let g:atp_toggle_environment_8=[ 'tabbing', 'tabular']
endif
if !exists("g:atp_toggle_labels")
    let g:atp_toggle_labels=1
endif
"}}}
" ToDo notes
" {{{ ToDo
"
" TODO if the file was not found ask to make one.
function! ToDo(keyword, stop, bang, ...)

    if a:0 == 0
	let bufname	= bufname("%")
    else
	let bufname	= a:1
    endif

    let b_pat	= ( a:bang == "!" ? '' : '^\s*' )

    " read the buffer
    let texfile	= getbufline(bufname, 1, "$")

    " find ToDos
    let todo = {}
    let nr=1
    for line in texfile
	if line =~ b_pat.'%\s*' . a:keyword 
	    call extend(todo, { nr : line }) 
	endif
	let nr += 1
    endfor

    " Show ToDos
    echohl atp_Todo
    if len(keys(todo)) == 0
	echomsg "[ATP:] list for ".b_pat."'%\s*" . a:keyword . "' in '" . bufname . "' is empty."
	return
    endif
    echomsg "[ATP:] list for ".b_pat."'%\s*" . a:keyword . "' in '" . bufname . "':"
    let sortedkeys=sort(keys(todo), "atplib#CompareNumbers")
    for key in sortedkeys
	" echo the todo line.
	echo key . " " . substitute(substitute(todo[key],'%','',''),'\t',' ','g')
	let true	= 1
	let a		= 1
	let linenr	= key
	" show all comment lines right below the found todo line.
	while true && texfile[linenr] !~ b_pat.'%\s*\c\<todo\>' 
	    let linenr=key+a-1
	    if texfile[linenr] =~ b_pat.'\s*%' && texfile[linenr] !~ a:stop
		" make space of length equal to len(linenr)
		let space=""
		let j=0
		while j < len(linenr)
		    let space=space . " " 
		    let j+=1
		endwhile
		echo space . " " . substitute(substitute(texfile[linenr],'%','',''),'\t',' ','g')
	    else
		let true = 0
	    endif
	    let a += 1
	endwhile
    endfor
    echohl None
endfunction
" }}}

" COMMANDS AND MAPS:
" Maps: "{{{1
nmap 	<buffer> <silent>	<Plug>Unwrap		:call atplib#various#Unwrap()<CR>
nmap 	<buffer> <silent> 	<Plug>Dictionary	:call atplib#various#Dictionary(expand("<cword>"))<CR>
map 	<buffer> 		<Plug>CommentLines	:call atplib#various#Comment(1)<CR>
map 	<buffer> 		<Plug>UnCommentLines 	:call atplib#various#Comment(0)<CR>
vmap 	<buffer> 		<Plug>WrapSelection	:<C-U>call atplib#various#WrapSelection('')<CR>i
vmap	<buffer> <silent> 	<Plug>WrapEnvironment	:<C-U>call atplib#various#WrapEnvironment('', 1)<CR>
vmap 	<buffer> 	<Plug>InteligentWrapSelection	:<C-U>call atplib#various#InteligentWrapSelection('')<CR>i
nmap 				<Plug>TexAlign		:call atplib#various#TexAlign(( g:atp_TexAlign_join_lines ? "!" : "" ),1,1)<CR>
vmap 				<Plug>vTexAlign		:<C-U>call atplib#various#TexAlign(( g:atp_TexAlign_join_lines ? "!" : "" ), getpos("'<")[1],getpos("'>")[1])<CR>
nnoremap 			<Plug>Replace		:call atplib#various#Replace()<CR>
nnoremap <silent> <buffer> 	<Plug>ToggleStar	:call atplib#various#ToggleStar()<CR>
nnoremap <silent> <buffer> 	<Plug>ToggleEnvForward	:call atplib#various#ToggleEnvironment(0, 1)<CR>
nnoremap <silent> <buffer> 	<Plug>ToggleEnvBackward	:call atplib#various#ToggleEnvironment(0, -1)<CR>
nnoremap <silent> <buffer> 	<Plug>ChangeEnv		:call atplib#various#ToggleEnvironment(1)<CR>
nnoremap <silent> <buffer> 	<Plug>TexDoc		:TexDoc 
" Commands: "{{{1
command! -nargs=1 -bang -complete=customlist,atplib#various#EnvCompletion InsertEnv :call <SID>InsertEnvironment(<q-bang>,<q-args>)
command! -nargs=? -bang -complete=file  Open call atplib#tools#Open(<q-bang>, g:atp_LibraryPath, g:atp_OpenTypeDict, <q-args>)
command! -buffer Unwrap						:call atplib#various#Unwrap()
command! -buffer -nargs=1 -complete=custom,atplib#various#Complete_Dictionary Dictionary :call atplib#various#Dictionary(<f-args>)
command! -buffer -nargs=* SetUpdateTime				:call atplib#various#UpdateTime(<f-args>)
command! -buffer -nargs=* -complete=file Wdiff			:call atplib#various#Wdiff(<f-args>)
command! -buffer -nargs=* -complete=custom,atplib#various#WrapSelection_compl -range Wrap :call atplib#various#WrapSelection(<f-args>)
command! -buffer -nargs=? -complete=customlist,atplib#various#EnvCompletion -range WrapEnvironment :call atplib#various#WrapEnvironment(<f-args>)
command! -buffer -nargs=? -range IWrap				:call atplib#various#InteligentWrapSelection(<args>)
command! -buffer -bang -range TexAlign				:call atplib#various#TexAlign(<q-bang>, <line1>, <line2>)
command! -buffer ToggleStar					:call atplib#various#ToggleStar()<CR>
command! -buffer -nargs=? ToggleEnv	   			:call atplib#various#ToggleEnvironment(0, <f-args>)
command! -buffer -nargs=* -complete=customlist,atplib#various#EnvCompletion ChangeEnv				:call atplib#various#ToggleEnvironment(1, <f-args>)
command! -buffer -nargs=1 ChangeLabel				:call atplib#various#ChangeLabel(<q-args>)
command! -buffer -bang 	Delete					:call atplib#various#Delete(<q-bang>)
nmap <silent> <buffer>	 <Plug>Delete				:call atplib#various#Delete("")<CR>
command! -buffer OpenLog					:call atplib#various#OpenLog()
nnoremap <silent> <buffer> <Plug>OpenLog			:call atplib#various#OpenLog()<CR>
command! -buffer PdfFonts					:call atplib#various#PdfFonts()
nnoremap <silent> <buffer> <Plug>PdfFonts			:call atplib#various#PdfFonts()<CR>
command! -complete=custom,atplib#various#Complete_lpr  -buffer -nargs=* SshPrint 	:call atplib#various#SshPrint("", <f-args>)
command! -complete=custom,atplib#various#CompleteLocal_lpr  -buffer -nargs=* Lpr	:call atplib#various#Lpr(<f-args>)
nnoremap <buffer> 	<Plug>SshPrint				:SshPrint 
command! -buffer 	Lpstat					:call atplib#various#Lpstat()
nnoremap <silent> <buffer> <Plug>Lpstat				:call atplib#various#Lpstat()<CR>
command! -buffer 	ListPrinters				:echo atplib#various#ListPrinters("", "", "")
" List Packages:
command! -buffer 	ShowPackages				:let b:atp_PackageList = atplib#search#GrepPackageList() | echo join(b:atp_PackageList, "\n")
if &l:cpoptions =~# 'B'
    command! -buffer -nargs=? -complete=buffer -bang ToDo	:call ToDo('\c\<to\s*do\s*\>','\s*%\s*$\|\s*%\c.*\<note\>',<q-bang>, <f-args>)
    command! -buffer -nargs=? -complete=buffer -bang Note	:call ToDo('\c\<note\s*\>','\s*%\s*$\|\s*%\c.*\<to\s*do\>', <q-bang>, <f-args>)
else
    command! -buffer -nargs=? -complete=buffer ToDo		:call ToDo('\\c\\<to\\s*do>','\\s*%\\s*$\\|\\s*%\\c.*\\<note\\>',<f-args>)
    command! -buffer -nargs=? -complete=buffer Note		:call ToDo('\\c\\<note\\>','\\s*%\\s*$\\|\\s*%\\c.*\\<to\\s*do\\>',<f-args>)
endif
command! -buffer ReloadATP					:call atplib#various#ReloadATP("!")
command! -bang -buffer -nargs=1 AMSRef				:call atplib#various#AMSRef(<q-bang>, <q-args>)
command! -buffer	Preamble				:call atplib#various#Preamble()
command! -range  -bang	WordCount				:call atplib#various#ShowWordCount(<q-bang>,[<q-line1>,<q-line2>])
if has("unix") && g:atp_atpdev
    command! -nargs=? -complete=custom,atplib#various#DebugPrintComp DebugPrint	:call atplib#various#DebugPrint(<q-args>)
endif 
nnoremap <silent> <buffer> <Plug>FormatLines			:call atplib#various#FormatLines()<CR>
" vim:fdm=marker:tw=85:ff=unix:noet:ts=8:sw=4:fdc=1
