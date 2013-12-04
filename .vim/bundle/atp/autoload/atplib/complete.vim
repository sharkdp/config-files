" Title: 	Vim library for ATP filetype plugin.
" Author:	Marcin Szamotulski
" Email:	mszamot [AT] gmail [DOT] com
" Note:		This file is a part of Automatic Tex Plugin for Vim.
" URL:		https://launchpad.net/automatictexplugin
" Language:	tex


" Check If Closed:
" This functions checks if an environment is closed/opened.
" atplib#complete#CheckClosed {{{1
" check if last bpat is closed.
" starting from the current line, limits the number of
" lines to search. It returns 0 if the environment is not closed or the line
" number where it is closed (an env is cannot be closed in 0 line)

" ToDo: the two function should only check not commented lines!
"
" Method 0 makes mistakes if the pattern is \begin:\end, if
" \begin{env_name}:\end{env_names} rather no (unless there are nested
" environments in the same name.
" Method 1 doesn't make mistakes and thus is preferable.
" after testing I shall remove method 0
" Method 2 doesn't makes less mistakes than method 1 (which makes them :/) but it is only for
" brackets, returns >0 if the bracket is closed 0 if it is not. 
try
function! atplib#complete#CheckClosed(bpat, epat, line, col, limit,...)

"     NOTE: THIS IS MUCH FASTER !!! or SLOWER !!! ???            
"
"     let l:pos_saved=getpos(".") 
"     let l:cline=line(".")
"     if a:line != l:cline
" 	let l:col=len(getline(a:line))
" 	keepjumps call setpos(".",[0,a:line,l:col,0])
"     endif
"     let l:line=searchpair(a:bpat,'',a:epat,'nWr','',max([(a:line+a:limit),1]))
"     if a:line != l:cline
" 	keepjumps call setpos(".",l:pos_saved)
"     endif
"     return l:line

    let time = reltime()

    let l:method 		= ( a:0 >= 1 ? a:1 : 0 )
    let saved_pos		= getpos(".")
"     let l:count_method		= ( a:0 >= 2 ? a:2 : 1 )
    let l:len			= len(getbufline(bufname("%"),1,'$'))
    let l:nr			= a:line
    let cline			= line(".")

    if a:limit == "$" || a:limit == "-1"
	let l:limit=l:len-a:line
    else
	let l:limit=a:limit
    endif
    if g:atp_debugCheckClosed
	let g:saved_pos	= getpos(".")
	let g:nr	= a:line
	let g:bpat 	= a:bpat
	let g:limit	= l:limit
    endif


    if g:atp_debugCheckClosed == 1
	call atplib#Log("CheckClosed.log","", "init")
    endif

    if l:method==0 " {{{2
	while l:nr <= a:line+l:limit
	    let l:line=getline(l:nr)
	    " Remove comments:
	    let l:line=substitute(l:line, '\(\\\@<!\|\\\@<!\%(\\\\\)*\)\zs%.*', '', '')
	    if l:nr == a:line
		if strpart(l:line,getpos(".")[2]-1) =~ '\%(' . a:bpat . '.*\)\@<!' . a:epat
		    let g:time_CheckClosed=reltimestr(reltime(time))
		    return l:nr
		endif
	    else
		if l:line =~ '\%(' . a:epat . '.*\)\@<!' . a:bpat
		    let g:time_CheckClosed=reltimestr(reltime(time))
		    return 0
		elseif l:line =~ '\%(' . a:bpat . '.*\)\@<!' . a:epat 
		    let g:time_CheckClosed=reltimestr(reltime(time))
		    return l:nr
		endif
	    endif
	    let l:nr+=1
	endwhile

    elseif l:method==1 " {{{2

	let l:bpat_count	=0
	let l:epat_count	=0
	let l:begin_line	=getline(a:line)
	let l:begin_line_nr	=line(a:line)
	while l:nr <= a:line+l:limit
	    let l:line		=getline(l:nr)
	    if l:nr == a:line+l:limit
		let l:col	=match(l:line, '^.*'.a:epat.'\zs')
		if l:col != -1
		    let l:line	=strpart(l:line,0, l:col+1)
		endif
	    endif
	    let l:bpat_count+=atplib#count(l:line,a:bpat, 1)
	    let l:epat_count+=atplib#count(l:line,a:epat, 1)
	    if g:atp_debugCheckClosed
		call atplib#Log("CheckClosed.log", l:nr." l:bpat_count=".l:bpat_count." l:epat_count=".l:epat_count)
	    endif
	    if (l:bpat_count+1) == l:epat_count
		let g:time_CheckClosed=reltimestr(reltime(time))
		return l:nr
	    elseif l:bpat_count == l:epat_count && l:begin_line =~ a:bpat
		let g:time_CheckClosed=reltimestr(reltime(time))
		return l:nr
	    endif 
	    let l:nr+=1
	endwhile
	let g:time_CheckClosed=reltimestr(reltime(time))
	return 0

    elseif l:method==2 " {{{2
	" This is a special method for brackets.

	let l:bpat_count	=0
	let l:epat_count	=0
	let l:begin_line	= getline(a:line)
	let l:begin_line_nr	= line(a:line)


	" Find number of closed brackets which are opened before the a:line
	call cursor(a:line, 1)
	let l:closed_before_count = -1
	while line(".") < saved_pos[1] || line(".") == saved_pos[1] && col(".") <= saved_pos[2]
	    let test = searchpair(a:bpat, '', a:epat, 'W', '', saved_pos[1])
	    let l:closed_before_count += 1
	    if test == 0
		break
	    endif
	endwhile
	call cursor(saved_pos[1], saved_pos[2])
	if g:atp_debugCheckClosed
	    call atplib#Log("CheckClosed.log", "l:closed_before_count=".l:closed_before_count)
	    let g:nr_cc 	= l:nr
	    let g:line_cc 	= a:line
	    let g:limit_cc 	= l:limit
	endif
	while l:nr <= a:line+l:limit
	    let l:line		= getline(l:nr)
	    if l:nr == a:line+l:limit
		if g:atp_debugCheckClosed
		    call atplib#Log("CheckClosed.log", 'x1')
		endif
		let l:col	= match(l:line, '^.*'.a:epat.'\zs')
		if l:col != -1
		    let l:line	= strpart(l:line,0, l:col+1)
		endif
	    elseif l:nr == a:line
		let saved_pos 	= getpos(".")
		if g:atp_debugCheckClosed
		    call atplib#Log("CheckClosed.log", 'x2')
		    let g:epat = a:epat
		    let g:ps = getpos(".")
		endif
		call cursor(l:nr, 1)
		let l:col = 1
		" The following motion should go out any opened bracket which
		" is starts before a:line. It is far from perfect!
		" Indeed, it omits opened brackets!
" 		let [ nl, nc ] 	= searchpos('.*'.a:epat.'\zs', 'cn', cline)
" 		if nl != 0
" 		    let [l:nr, l:col] = [ nl, nc ]
" 		else
" 		    let [l:nr, l:col] = [ l:nr, 1 ]
" 		endif
		let l:line	= strpart(getline(l:nr), l:col-1)
	    endif
	    if l:nr == saved_pos[1]
		let cline	= strpart(getline(l:nr), 0, saved_pos[2]-1)
		if g:atp_debugCheckClosed 
		    let g:cline = cline
		endif
		let cpos_bpat_count = l:bpat_count+atplib#count(cline,a:bpat, 1)
		" (above we add 1 for the open one that we are checking)
		let cpos_epat_count = l:epat_count+atplib#count(cline,a:epat, 1)
		if g:atp_debugCheckClosed
		    call atplib#Log("CheckClosed.log", ">> cline=".cline."> cpos_bpat_count=".cpos_bpat_count." cpos_epat_count=".cpos_epat_count)
		endif
	    endif
	    " Strip comments:
	    let comment_match = match(l:line, '\%(\\\\\|\\\@<!\)%')
	    if comment_match != -1
		let l:line = strpart(l:line, 0, comment_match)
	    endif
	    call cursor(saved_pos[1], saved_pos[2])
	    let l:bpat_count+=atplib#count(l:line,a:bpat, 1)
	    let l:epat_count+=atplib#count(l:line,a:epat, 1)
	    let cond = l:epat_count - l:closed_before_count - l:bpat_count >= 0
	    if g:atp_debugCheckClosed
		call atplib#Log("CheckClosed.log", l:nr." l:bpat_count=".l:bpat_count." l:epat_count=".l:epat_count." ".l:line)
		if l:nr == saved_pos[1]
		    call atplib#Log("CheckClosed.log", l:nr." l:closed_before_count=".l:closed_before_count)
		endif
		if l:nr >= saved_pos[1]
		    call atplib#Log("CheckClosed.log", "cond (closed-opened)=".cond." value=".(l:epat_count - l:closed_before_count - l:bpat_count))
		endif	
	    endif
	    if l:nr >= saved_pos[1] && cond
		let g:time_CheckClosed=reltimestr(reltime(time))
		if g:atp_debugCheckClosed
		    let g:return = l:nr
		endif
		return l:nr
	    endif
	    let l:nr+=1
	endwhile
	let g:time_CheckClosed=reltimestr(reltime(time))
	return 0

    elseif l:method==3 " {{{2
	" This is a special method for brackets.
	" But it is too slow!

" 	silent echomsg "***************"
	let saved_pos 	= getpos(".")
	call cursor(a:line, a:col)
	let c_pos	= [a:line, a:col]
	let line	= a:line
" 	silent echomsg "a:line=".a:line." c_pos=".string(c_pos)." a:limit=".a:limit." cond=".string(a:line-c_pos[0] <= a:limit)
	while a:line-c_pos[0] <= a:limit
	    let pos=searchpairpos(a:bpat, '', a:epat, 'b')
" 	    silent echomsg string(pos)
	    if pos == [0, 0]
" 		silent echomsg "C1"
		call cursor(saved_pos[1], saved_pos[2])
		let g:time_CheckClosed=reltimestr(reltime(time))
		return c_pos[0]
	    endif
	    if pos == c_pos
" 		silent echomsg "C2"
		call cursor(saved_pos[1], saved_pos[2])
		let g:time_CheckClosed=reltimestr(reltime(time))
		return 0
	    endif
	    if atplib#CompareCoordinates(c_pos, pos)
" 		silent echomsg "C3"
		call cursor(saved_pos[1], saved_pos[2])
		let g:time_CheckClosed=reltimestr(reltime(time))
		return 0
	    endif
	    let c_pos = copy(pos)
	endwhile
" 	silent echomsg "C4"
	call cursor(saved_pos[1], saved_pos[2])
	let g:time_CheckClosed=reltimestr(reltime(time))
	return 1
    endif
endfunction
catch /E127:/
endtry
" }}}1
" {{{1 atplib#complete#CheckClosed_math
" This functions makes a test if in line math is closed. This works well with
" \(:\) and \[:\] but not yet with $:$ and $$:$$.  
" a:mathZone	= texMathZoneV or texMathZoneW or texMathZoneX or texMathZoneY
" The function return 1 if the mathZone is to be closed (i.e. it is not closed).
function! atplib#complete#CheckClosed_math(mathZone)
    let time 		= reltime()
    let synstack	= map(synstack(line("."), max([1, col(".")-1])), "synIDattr( v:val, 'name')")
    let check		= 0
    let patterns 	= { 
		\ 'texMathZoneV' : [ '\\\@<!\\(', 	'\\\@<!\\)' 	], 
		\ 'texMathZoneW' : [ '\\\@<!\\\[', 	'\\\@<!\\\]'	]}
    " Limit the search to the first \par or a blank line, if not then search
    " until the end of document:
    let stop_line	= search('\\par\|^\s*$', 'nW') - 1
    let stop_line	= ( stop_line == -1 ? line('$') : stop_line )

    " \(:\), \[:\], $:$ and $$:$$ do not accept blank lines, thus we can limit
    " searching/counting.
    
    " For \(:\) and \[:\] we use searchpair function to test if it is closed or
    " not.
    if (a:mathZone == 'texMathZoneV' || a:mathZone == 'texMathZoneW') && atplib#complete#CheckSyntaxGroups(['texMathZoneV', 'texMathZoneW'])
	if index(synstack, a:mathZone) != -1
	    let condition = searchpair( patterns[a:mathZone][0], '', patterns[a:mathZone][1], 'cnW', '', stop_line)
	    let check 	  = ( !condition ? 1 : check )
	else
	    let check	  = 0
	endif

    " $:$ and $$:$$ we are counting $ untill blank line or \par
    " to test if it is closed or not, 
    " then we return the number of $ modulo 2.
    elseif ( a:mathZone == 'texMathZoneX' || a:mathZone == 'texMathZoneY' ) && atplib#complete#CheckSyntaxGroups(['texMathZoneX', 'texMathZoneY'])
	let saved_pos	= getpos(".")
	let line	= line(".")	
	let l:count	= 0
	" count \$ if it is under the cursor
	if search('\\\@<!\$', 'Wc', stop_line)
	    let l:count += 1
	endif
	while line <= stop_line && line != 0
	    keepjumps let line	= search('\\\@<!\$', 'W', stop_line)
	    let l:count += 1
	endwhile
	keepjumps call setpos(".", saved_pos)
	let check	= l:count%2
    endif

    let g:time_CheckClosed_math=reltimestr(reltime(time))
    return check
endfunction
" atplib#complete#CheckClosed_syntax {{{1
" This function checks if a syntax group ends.
" Returns 1 if the syntax group doesn't ends before a:limit_line, a:limit_col line (last character is included).
"
" Note, this function is slower than atplib#complete#CheckClosed_math, which is designed
" for texMathZone[VWXY]. (call synstack(...) inside atplib#complete#CheckSyntaxGroups()
" is slow) - thus it is not used anymore.
function! atplib#complete#CheckClosed_syntax(syntax,limit_line, limit_col)
    let time		= reltime()
"     let whichwrap	= &whichwrap
"     setl whichwrap+=l
    let line		= line(".")
    let col		= col(".")
    let test		= atplib#complete#CheckSyntaxGroups(a:syntax)
    while ( line(".") < a:limit_line || line(".") == a:limit_line && col(".") <= a:limit_col ) && test
	normal! W
	let test	= atplib#complete#CheckSyntaxGroups(a:syntax)
    endwhile
    call cursor(line, col)
"     let &whichwrap	= whichwrap
    let g:time_CheckClosed_syntax=reltimestr(reltime(time))
    return test
endfunction
" }}}1
" atplib#complete#CheckOpened {{{1
" Usage: By default (a:0 == 0 || a:1 == 0 ) it returns line number where the
" environment is opened if the environment is opened and is not closed (for
" completion), else it returns 0. However, if a:1 == 1 it returns line number
" where the environment is opened, if we are inside an environment (it is
" opened and closed below the starting line or not closed at all), it if a:1
" = 2, it just check if env is opened without looking if it is closed (
" cursor position is important).
" a:1 == 0 first non closed
" a:1 == 2 first non closed by counting.

" this function doesn't check if sth is opened in lines which begins with '\\def\>'
" (some times one wants to have a command which opens an environment.

" Todo: write a faster function using searchpairpos() which returns correct
" values.
function! atplib#complete#CheckOpened(bpat,epat,line,limit)


"     this is almost good:    
"     let l:line=searchpair(a:bpat,'',a:epat,'bnWr','',max([(a:line-a:limit),1]))
"     return l:line

    let l:len=len(getbufline(bufname("%"),1,'$'))
    let l:nr=a:line

    if a:limit == "^" || a:limit == "-1"
	let l:limit=a:line-1
    else
	let l:limit=a:limit
    endif

    while l:nr >= a:line-l:limit && l:nr >= 1
	let l:line=getline(l:nr)
	    if l:nr == a:line
		    if substitute(strpart(l:line,0,getpos(".")[2]), a:bpat . '.\{-}' . a:epat,'','g')
				\ =~ a:bpat
			return l:nr
		    endif
	    else
" 		if l:check_mode == 0
" 		    if substitute(l:line, a:bpat . '.\{-}' . a:epat,'','g')
" 				\ =~ a:bpat
" 			" check if it is closed up to the place where we start. (There
" 			" is no need to check after, it will be checked anyway
" 			" b a serrate call in atplib#complete#TabCompletion.
" 			if !atplib#complete#CheckClosed(a:bpat,a:epat,l:nr,0,a:limit,0)
" 				" LAST CHANGE 1->0 above
" " 				let b:cifo_return=2 . " " . l:nr 
" 			    return l:nr
" 			endif
" 		    endif
" 		elseif l:check_mode == 1
		    if substitute(l:line, a:bpat . '.\{-}' . a:epat,'','g')
				\ =~ '\%(\\def\|\%(re\)\?newcommand\)\@<!' . a:bpat
			let l:check=atplib#complete#CheckClosed(a:bpat,a:epat,l:nr,0,a:limit,1)
			" if env is not closed or is closed after a:line
			if  l:check == 0 || l:check >= a:line
" 				let b:cifo_return=2 . " " . l:nr 
			    return l:nr
			endif
		    endif
" 		endif
	    endif
	let l:nr-=1
    endwhile
    return 0 
endfunction
" }}}1
" {{{1 atplib#complete#CheckSyntaxGroups
" This functions returns one if one of the environment given in the list
" a:zones is present in they syntax stack at line a:1 and column a:0.
" a:zones =	a list of zones
" a:1	  = 	line nr (default: current cursor line)
" a:2     =	column nr (default: column before the current cursor position)
" The function doesn't make any checks if the line and column supplied are
" valid /synstack() function returns 0 rather than [] in such a case/.
function! atplib#complete#CheckSyntaxGroups(zones,...)
    let line		= a:0 >= 1 ? a:1 : line(".")
    let col		= a:0 >= 2 ? a:2 : col(".")-1
    let col		= max([1, col])
    let zones		= copy(a:zones)

    let synstack_raw 	= synstack(line, col)
    if type(synstack_raw) != 3
	unlet synstack_raw
	return 0
    endif

    let synstack	= map(synstack_raw, 'synIDattr(v:val, "name")') 

    return max(map(zones, "count(synstack, v:val)"))
endfunction
" atplib#complete#CopyIndentation {{{1
function! atplib#complete#CopyIndentation(line)
    let raw_indent	= split(a:line,'\s\zs')
    let indent		= ""
    for char in raw_indent
	if char =~ '^\%(\s\|\t\)'
	    let indent.=char
	else
	    break
	endif
    endfor
    return indent
endfunction
"}}}1

" Close Environments And Brackets:
" atplib#complete#CloseLastEnvironment {{{1
" a:1 = i	(append before, so the cursor will  be after - the dafult)  
" 	a	(append after)
" a:2 = math 		the pairs \(:\), $:$, \[:\] or $$:$$ (if filetype is
" 						plaintex or b:atp_TexFlavor="plaintex")
" 	environment
" 			by the way, treating the math pairs together is very fast. 
" a:3 = environment name (if present and non zero sets a:2 = environment)	
" 	if one wants to find an environment name it must be 0 or "" or not
" 	given at all.
" a:4 = line and column number (in a vim list) where environment is opened
" a:5 = return only (only return the closing code (implemented only for a:2="math") 
" ToDo: Ad a highlight to messages!!! AND MAKE IT NOT DISAPPEAR SOME HOW?
" (redrawing doesn't help) CHECK lazyredraw. 
" Note: this function tries to not double the checks what to close if it is
" given in the arguments, and find only the information that is not given
" (possibly all the information as all arguments can be omitted).
function! atplib#complete#CloseLastEnvironment(...)

    let time = reltime()

    let l:com	= a:0 >= 1 ? a:1 : 'i'
    let l:close = a:0 >= 2 && a:2 != "" ? a:2 : 0
    if a:0 >= 3
	let l:env_name	= ( a:3 == "" ? 0 : a:3 )
	let l:close 	= ( a:3 != '' ? "environment" : l:close )
    else
	let l:env_name 	= 0
    endif
    let l:bpos_env	= ( a:0 >= 4 ? a:4 : [0, 0] )
    let return_only	= ( a:0 >= 5 ? a:5 : 0 )

    if g:atp_debugCloseLastEnvironment
	call atplib#Log('CloseLastEnvironment.log', '', 'init')
	let g:CLEargs 	= string(l:com) . " " . string(l:close) . " " . string(l:env_name) . " " . string(l:bpos_env)
	silent echo "args=".g:CLEargs
	let g:close 	= l:close
	let g:env_name	= l:env_name
	let g:bpos_env	= l:bpos_env
	call atplib#Log('CloseLastEnvironment.log', 'ARGS = '.g:CLEargs)
    endif

"   {{{2 find the begining line of environment to close (if we are closing
"   an environment)
    if l:env_name == 0 && ( l:close == "environment" || l:close == 0 ) && l:close != "math"

	let filter 	= 'strpart(getline(''.''), 0, col(''.'') - 1) =~ ''\\\@<!%'''

	" Check if and environment is opened (\begin:\end):
	" This is the slow part :( 0.4s)
	" Find the begining line if it was not given.
	if l:bpos_env == [0, 0]
	    " Find line where the environment is opened and not closed:
	    let l:bpos_env		= searchpairpos('\\begin\s*{', '', '\\end\s*{', 'bnW', 'searchpair("\\\\begin\s*{\s*".matchstr(getline("."),"\\\\begin\s*{\\zs[^}]*\\ze\}"), "", "\\\\end\s*{\s*".matchstr(getline("."), "\\\\begin\s*{\\zs[^}]*\\ze}"), "nW", "", "line(".")+g:atp_completion_limits[2]")',max([ 1, (line(".")-g:atp_completion_limits[2])]))
	endif

	let l:env_name		= matchstr(strpart(getline(l:bpos_env[0]),l:bpos_env[1]-1), '\\begin\s*{\s*\zs[^}]*\ze*\s*}')

    " if a:3 (environment name) was given:
    elseif l:env_name != "0" && l:close == "environment" 

	let l:bpos_env	= searchpairpos('\\begin\s*{'.l:env_name.'}', '', '\\end\s*{'.l:env_name.'}', 'bnW', '',max([1,(line(".")-g:atp_completion_limits[2])]))

    endif
"   }}}2
"   {{{2 if a:2 was not given (l:close = 0) we have to check math modes as
"   well.
    if ( l:close == "0" || l:close == "math" ) && l:bpos_env == [0, 0] 

	let stopline 		= search('^\s*$\|\\par\>', 'bnW')

	" Check if one of \(:\), \[:\], $:$, $$:$$ is opened using syntax
	" file. If it is fined the starting position.

	let synstack		= map(synstack(line("."),max([1, col(".")-1])), 'synIDattr(v:val, "name")')
	if g:atp_debugCloseLastEnvironment
	    let g:synstackCLE	= deepcopy(synstack)
	    let g:openCLE	= getline(".")[col(".")-1] . getline(".")[col(".")]
	    call atplib#Log('CloseLastEnvironment.log', "g:openCLE=".string(g:openCLE))
	    call atplib#Log('CloseLastEnvironment.log', 'synstack='.string(synstack))
	endif
	let bound_1		= getline(".")[col(".")-1] . getline(".")[col(".")] =~ '^\\\%((\|)\)$'
	let math_1		= (index(synstack, 'texMathZoneV') != -1 && !bound_1 ? 1  : 0 )   
	    if math_1
		if l:bpos_env == [0, 0]
		    let bpos_math_1	= searchpos('\%(\%(\\\)\@<!\\\)\@<!\\(', 'bnW', stopline)
		else
		    let bpos_math_1	= l:bpos_env
		endif
		let l:begin_line= bpos_math_1[0]
		let math_mode	= "texMathZoneV"
	    endif
	" the \[:\] pair:
	let bound_2		= matchstr(getline("."), ".", col(".")-1) . matchstr(getline("."), ".", col(".")) =~ '^\\\%(\[\|\]\)$'
	let math_2		= (index(synstack, 'texMathZoneW') != -1 && !bound_2 ? 1  : 0 )   
	    if math_2
		if l:bpos_env == [0, 0]
		    let bpos_math_2	= searchpos('\%(\%(\\\)\@<!\\\)\@<!\\[', 'bnW', stopline)
		else
		    let bpos_math_2	= l:bpos_env
		endif
		let l:begin_line= bpos_math_2[0]
		let math_mode	= "texMathZoneW"
	    endif
	" the $:$ pair:
	let bound_3		= matchstr(getline("."), ".", col(".")-1) =~ '^\$$'
	let math_3		= (index(synstack, 'texMathZoneX') != -1 && !bound_3 ? 1  : 0 )   
	    if math_3
		if l:bpos_env == [0, 0]
		    let bpos_math_3	= searchpos('\%(\%(\\\)\@<!\\\)\@<!\$\{1,1}', 'bnW', stopline)
		else
		    let bpos_math_3	= l:bpos_env
		endif
		let l:begin_line= bpos_math_3[0]
		let math_mode	= "texMathZoneX"
	    endif
	" the $$:$$ pair:
	let bound_4		= matchstr(getline("."), ".", col(".")-1) . matchstr(getline("."), ".", col(".")) =~ '^\$\$$'
	let math_4		= (index(synstack, 'texMathZoneY') != -1 && !bound_4 ? 1  : 0 )   
	    if math_4
		if l:bpos_env == [0, 0]
		    let bpos_math_4	= searchpos('\%(\%(\\\)\@<!\\\)\@<!\$\{2,2}', 'bnW', stopline)
		else
		    let bpos_math_4	= l:bpos_env
		endif
		let l:begin_line= bpos_math_4[0]
		let math_mode	= "texMathZoneY"
	    endif
	if g:atp_debugCloseLastEnvironment
	    let g:math 	= []
	    let g:bound = []
	    for i in [1,2,3,4]
		let g:begin_line = ( exists("begin_line") ? begin_line : 0 )
		let g:bound_{i} = bound_{i}
		call add(g:bound, bound_{i})
		let g:math_{i} = math_{i}
		call add(g:math, math_{i})
	    endfor
	    call atplib#Log('CloseLastEnvironment.log', "g:begin_line=".g:begin_line)
	    call atplib#Log('CloseLastEnvironment.log', "g:bound=".string(g:bound))
	    call atplib#Log('CloseLastEnvironment.log', "g:math=".string(g:math))
	    call atplib#Log('CloseLastEnvironment.log', "math_mode=".( exists("math_mode") ? math_mode : "None" ))
	endif
    elseif ( l:close == "0" || l:close == "math" )
	let string = matchstr(getline(l:bpos_env[0]), ".", l:bpos_env[1]-2) . matchstr(getline(l:bpos_env[0]), ".", l:bpos_env[1]-1) . matchstr(getline(l:bpos_env[0]), ".", l:bpos_env[1])
	let stop_line = search('\\par\|^\s*$\|\\\%(begin\|end\)\s*{', 'n')
	let [ math_1, math_2, math_3, math_4 ] = [ 0, 0, 0, 0 ]
	let saved_pos		= getpos(".")
	if string =~ '\\\@<!\\('
	    call cursor(l:bpos_env) 
	    " Check if closed:
	    let math_1 		= searchpair('\\(', '', '\\)', 'n', '', stop_line)
	    if !math_1
		let math_mode	= "texMathZoneV"
	    endif
	elseif string =~ '\\\@<!\\\['
	    call cursor(l:bpos_env) 
	    " Check if closed:
	    let math_2 		= searchpair('\\\[', '', '\\\]', 'n', '', stop_line)
	    if !math_2
		let math_mode	= "texMathZoneW"
	    endif
	elseif string =~ '\%(\\\|\$\)\@<!\$\$\@!'
	    " Check if closed: 	not implemented
	    let math_3 		= 0
	    let math_mode	= "texMathZoneX"
	elseif string =~ '\\\@<!\$\$'
	    " Check if closed: 	not implemented
	    let math_4 		= 0
	    let math_mode	= "texMathZoneY"
	endif
	call cursor([ saved_pos[1], saved_pos[2] ]) 
	if g:atp_debugCloseLastEnvironment
	    if exists("math_mode")
		let g:math_mode  	= math_mode
		call atplib#Log('CloseLastEnvironment.log', "math_mode=".math_mode)
	    endif
	    let g:math 	= []
	    let g:string = string
	    for i in [1,2,3,4]
		let g:begin_line = ( exists("begin_line") ? begin_line : 0 )
		let g:math_{i} = math_{i}
		call add(g:math, math_{i})
	    endfor
	    call atplib#Log('CloseLastEnvironment.log', "g:begin_line".g:begin_line)
	    call atplib#Log('CloseLastEnvironment.log', "g:math=".string(g:math))
	endif
	if exists("math_mode")
	    let l:begin_line 	= l:bpos_env[0]
	    if g:atp_debugCloseLastEnvironment
		call atplib#Log('CloseLastEnvironment.log', "math_mode=".math_mode)
		call atplib#Log('CloseLastEnvironment.log', "l:begin_line=".l:begin_line)
	    endif
	else
	    if g:atp_debugCloseLastEnvironment
		call atplib#Log('CloseLastEnvironment.log', "Given coordinates are closed.")
		redir END
	    endif
	    let g:time_CloseLastEnvironment = reltimestr(reltime(time))
	    return ''
	endif
    endif
"}}}2
"{{{2 set l:close if a:1 was not given.
if a:0 <= 1
" 	let l:begin_line=max([ l:begin_line_env, l:begin_line_imath, l:begin_line_dmath ])
    " now we can set what to close:
    " the synstack never contains two of the math zones: texMathZoneV,
    " texMathZoneW, texMathZoneX, texMathZoneY.
    if math_1 + math_2 + math_3 + math_4 >= 1
	let l:close = 'math'
    elseif l:env_name
	let l:close = 'environment'
    else
	if g:atp_debugCloseLastEnvironment
	    call atplib#Log('CloseLastEnvironment.log', "return: l:env_name=".string(l:env_name)." && math_1+...+math_4=".string(math_1+math_2+math_3+math_4))
	endif
	let g:time_CloseLastEnvironment = reltimestr(reltime(time))
	return ''
    endif
endif
if g:atp_debugCloseLastEnvironment
    let g:close = l:close
    call atplib#Log('CloseLastEnvironment.log', 'l:close='.l:close)
    call atplib#Log('CloseLastEnvironment.log', 'l:env_name='.l:env_name)
endif
let l:env=l:env_name
"}}}2

if l:close == "0" || l:close == 'math' && !exists("begin_line")
    if g:atp_debugCloseLastEnvironment
	call atplib#Log('CloseLastEnvironment.log', 'there was nothing to close')
    endif
    let g:time_CloseLastEnvironment = reltimestr(reltime(time))
    return ''
endif
if ( &filetype != "plaintex" && b:atp_TexFlavor != "plaintex" && exists("math_4") && math_4 )
    echohl ErrorMsg
    echomsg "[ATP:] $$:$$ in LaTeX are deprecated (this breaks some LaTeX packages)" 
    echomsg "       You can set b:atp_TexFlavor = 'plaintex', and ATP will ignore this. "
    echohl None
    if g:atp_debugCloseLastEnvironment
	call atplib#Log('CloseLastEnvironment.log', "return A")
    endif
    let g:time_CloseLastEnvironment = reltimestr(reltime(time))
    return  ''
endif
if l:env_name =~ '^\s*document\s*$'
    if g:atp_debugCloseLastEnvironment
	call atplib#Log('CloseLastEnvironment.log', "return B")
    endif
    let g:time_CloseLastEnvironment = reltimestr(reltime(time))
    return ''
endif
let l:cline	= getline(".")
let l:pos	= getpos(".")
if l:close == "math"
    let l:line	= getline(l:begin_line)
elseif l:close == "environment"
    let l:line	= getline(l:bpos_env[0])
endif

    if g:atp_debugCloseLastEnvironment
	let g:line = ( exists("l:line") ? l:line : 0 )
	call atplib#Log('CloseLastEnvironment.log', "g:line=".g:line)
    endif

" Copy the indentation of what we are closing.
let l:eindent=atplib#complete#CopyIndentation(l:line)
"{{{2 close environment
    if l:close == 'environment'
	" Info message
	redraw
	" echomsg "[ATP:] closing " . l:env_name . " from line " . l:bpos_env[0]

	" Rules:
	" env & \[ \]: close in the same line 
	" unless it starts in a serrate line,
	" \( \): close in the same line. 
	"{{{3 close environment in the same line
	if l:line != "" && l:line !~ '^\s*\%(\$\|\$\$\|[^\\]\\%(\|\\\@<!\\\[\)\?\s*\\begin\s*{[^}]*}\s*\%((.*)\s*\|{.*}\s*\|\[.*\]\s*\)\{,3}\%(\s*\\label\s*{[^}]*}\s*\|\s*\\hypertarget\s*{[^}]*}\s*{[^}]*}\s*\)\{0,2}$'
	    " I use \[.*\] instead of \[[^\]*\] which doesn't work with nested
	    " \[:\] the same for {:} and (:).
" 	    	This pattern matches:
" 	    		^ $
" 	    		^ $$
" 	    		^ \(
" 	    		^ \[
" 	    		^ (one of above or space) \begin { env_name } ( args1 ) [ args2 ] { args3 } \label {label} \hypertarget {} {}
" 	    		There are at most 3 args of any type with any order \label and \hypertarget are matched optionaly.
" 	    		Any of these have to be followd by white space up to end of line.
	    "
	    " The line above cannot contain "\|^\s*$" pattern! Then the
	    " algorithm for placing the \end in right place is not called.
	    "
	    " 		    THIS WILL BE NEEDED LATER!
" 		    \ (l:close == 'display_math' 	&& l:line !~ '^\s*[^\\]\\\[\s*$') ||
" 		    \ (l:close == 'inline_math' 	&& (l:line !~ '^\s*[^\\]\\(\s*$' || l:begin_line == line("."))) ||
" 		    \ (l:close == 'dolar_math' 		&& l:cline =~ '\$')

	    " the above condition matches for the situations when we have to
	    " complete in the same line in four cases:
	    " l:close == environment, display_math, inline_math or
	    " dolar_math. 

	    " do not complete environments which starts in a definition.
" let b:cle_debug= (getline(l:begin_line) =~ '\\def\|\%(re\)\?newcommand') . " " . (l:begin_line != line("."))
" 	    if getline(l:begin_line) =~ '\\def\|\%(re\)\?newcommand' && l:begin_line != line(".")
"  		let b:cle_return="def"
" 		return b:cle_return
" 	    endif
	    if index(g:atp_no_complete, l:env) == '-1' &&
		\ !atplib#complete#CheckClosed('\%(%.*\)\@<!\\begin\s*{' . l:env,'\%(%.*\)\@<!\\end\s*{' . l:env,line("."),col("."),g:atp_completion_limits[2])
		if l:com == 'a'  
		    call setline(line("."), strpart(l:cline,0,getpos(".")[2]) . '\end{'.l:env.'}' . strpart(l:cline,getpos(".")[2]))
		    let l:pos=getpos(".")
		    let l:pos[2]=len(strpart(l:cline,0,getpos(".")[2]) . '\end{'.l:env.'}')+1
		    keepjumps call setpos(".",l:pos)
		elseif l:cline =~ '^\s*$'
		    call setline(line("."), l:eindent . '\end{'.l:env.'}' . strpart(l:cline,getpos(".")[2]-1))
		    let l:pos=getpos(".")
		    let l:pos[2]=len(strpart(l:cline,0,getpos(".")[2]-1) . '\end{'.l:env.'}')+1
		    keepjumps call setpos(".",l:pos)
		else
		    call setline(line("."), strpart(l:cline,0,getpos(".")[2]-1) . '\end{'.l:env.'}' . strpart(l:cline,getpos(".")[2]-1))
		    let l:pos=getpos(".")
		    let l:pos[2]=len(strpart(l:cline,0,getpos(".")[2]-1) . '\end{'.l:env.'}')+1
		    keepjumps call setpos(".",l:pos)
		endif
	    endif "}}}3
	"{{{3 close environment in a new line 
	else 

		if g:atp_debugCloseLastEnvironment
		    call atplib#Log('CloseLastEnvironment.log', 'close environment in a new line')
		endif

		" do not complete environments which starts in a definition.

		let l:error=0
		let l:prev_line_nr="-1"
		let l:cenv_lines=[]
		let l:nr=line(".")
		
		let l:line_nr=line(".")
		if g:atp_debugCloseLastEnvironment
		    call atplib#Log('CloseLastEnvironment.log', 'l:line_nr='.l:line_nr)
		endif

		" l:line_nr number of line which we complete
		" l:cenv_lines list of closed environments (we complete after
		" line number maximum of these numbers.

		let l:pos=getpos(".")
		let l:pos_saved=deepcopy(l:pos)
		if g:atp_debugCloseLastEnvironment
		    let g:pos_saved0 = copy(l:pos_saved)
		endif

		while l:line_nr >= 0
		    let [ l:line_nr, l:col_nr ]=searchpos('\%(%.*\)\@<!\\begin\s*{\zs', 'bW')
		    " match last environment openned in this line.
		    " ToDo: afterwards we can make it works for multiple openned
		    " envs.
		    let l:env_name=matchstr(getline(l:line_nr),'\%(%.*\)\@<!\\begin\s*{\zs[^}]*\ze}\%(.*\\begin\s*{[^}]*}\)\@!')
		    if g:atp_debugCloseLastEnvironment
			call atplib#Log('CloseLastEnvironment.log', 'WHILE l:env_name='.l:env_name)
		    endif
		    if index(g:atp_long_environments, l:env_name) != -1
			let l:limit=3
		    else
			let l:limit=2
		    endif
		    let l:close_line_nr=atplib#complete#CheckClosed('\%(%.*\)\@<!\\begin\s*{' . l:env_name, 
				\ '\%(%.*\)\@<!\\end\s*{' . l:env_name,
				\ l:line_nr, l:col_nr, g:atp_completion_limits[l:limit], 1)
		    if g:atp_debugCloseLastEnvironment
			call atplib#Log('CloseLastEnvironment.log', 'WHILE l:close_line_nr='.l:close_line_nr)
			call atplib#Log('CloseLastEnvironment.log', 'WHILE atplib#complete#CheckClosed args ='.l:line_nr.', '.l:col_nr.', '.g:atp_completion_limits[l:limit].', 1')
		    endif

		    if l:close_line_nr != 0
			call add(l:cenv_lines, l:close_line_nr)
		    else
			break
		    endif
		    if g:atp_debugCloseLastEnvironment
			call atplib#Log('CloseLastEnvironment.log', 'WHILE l:line_nr='.l:line_nr)
		    endif
		    let l:line_nr-=1
		endwhile

		keepjumps call setpos(".",l:pos)
			
		if getline(l:line_nr) =~ '\%(%.*\)\@<!\%(\\def\|\%(re\)\?newcommand\)' && l:line_nr != line(".")
" 		    let b:cle_return="def"
		    if g:atp_debugCloseLastEnvironment
			call atplib#Log('CloseLastEnvironmemt.log', 'return C')
		    endif
		    let g:time_CloseLastEnvironment = reltimestr(reltime(time))
		    return ''
		endif

		" get all names of environments which begin in this line
		let l:env_names=[]
		let l:line=getline(l:line_nr)
		while l:line =~ '\\begin\s*{' 
		    let l:cenv_begins = match(l:line,'\%(%.*\)\@<!\\begin{\zs[^}]*\ze}\%(.*\\begin\s{\)\@!')
		    let l:cenv_name = matchstr(l:line,'\%(%.*\)\@<!\\begin{\zs[^}]*\ze}\%(.*\\begin\s{\)\@!')
		    let l:cenv_len=len(l:cenv_name)
		    let l:line=strpart(l:line,l:cenv_begins+l:cenv_len)
		    call add(l:env_names,l:cenv_name)
		endwhile
		" thus we have a list of env names.
		
		" make a dictionary of lines where they closes. 
		" this is a list of pairs (I need the order!)
		let l:env_dict=[]

		" list of closed environments
		let l:cenv_names=[]

		if g:atp_debugCloseLastEnvironment
		    call atplib#Log('CloseLastEnvironment.log', 'l:env_names='.string(l:env_names))
		endif

		for l:uenv in l:env_names
		    let l:uline_nr=atplib#complete#CheckClosed('\%(%.*\)\@<!\\begin\s*{' . l:uenv . '}', 
				\ '\%(%.*\)\@<!\\end\s*{' . l:uenv . '}',
				\ l:line_nr, l:col_nr, g:atp_completion_limits[2])
		    call extend(l:env_dict,[ l:uenv, l:uline_nr])
		    if l:uline_nr != '0'
			call add(l:cenv_names,l:uenv)
		    endif
		endfor

		if g:atp_debugCloseLastEnvironment
		    call atplib#Log('CloseLastEnvironment.log', 'l:cenv_names='.string(l:cenv_names))
		endif
		
		" close unclosed environment

		" check if at least one of them is closed
		if len(l:cenv_names) == 0
		    let l:str=""
		    for l:uenv in l:env_names
			if index(g:atp_no_complete,l:uenv) == '-1'
			    let l:str.='\end{' . l:uenv .'}'
			endif
		    endfor
		    " l:uenv will remain the last environment name which
		    " I use!
		    " Do not append empty lines (l:str is empty if all l:uenv
		    " belongs to the g:atp_no_complete list.
		    if len(l:str) == 0
			if g:atp_debugCloseLastEnvironment
			    silent echo "return D"
			    redir END
			endif
			let g:time_CloseLastEnvironment = reltimestr(reltime(time))
			return ''
		    endif
		    let l:eindent=atplib#complete#CopyIndentation(getline(l:line_nr))
		    let l:pos=getpos(".")
		    if len(l:cenv_lines) > 0 

			let l:max=max(l:cenv_lines)
			let l:pos[1]=l:max+1
			" find the first closed item below the last closed
			" pair (below l:pos[1]). (I assume every env is in
			" a seprate line!
			let l:end=atplib#complete#CheckClosed('\%(%.*\)\@<!\\begin\s*{','\%(%.*\)\@<!\\end\s*{',
				    \ l:line_nr, l:col_nr, g:atp_completion_limits[2], 1)
			if g:atp_debugCloseLastEnvironment
			    let g:info= " l:max=".l:max." l:end=".l:end." line('.')=".line(".")." l:line_nr=".l:line_nr
			    call atplib#Log('CloseLastEnvironmemt.log', g:info)
			endif
			" if the line was found append just befor it.
			if l:end != 0 
				if line(".") <= l:max
				    if line(".") <= l:end
					call append(l:max, l:eindent . l:str)
					echomsg "[ATP:] closing " . l:env_name . " from line " . l:bpos_env[0] . " at line " . (l:end+1)
					call setpos(".",[0,l:max+1,len(l:eindent.l:str)+1,0])
				    else
					call append(l:end-1, l:eindent . l:str)
					echomsg "[ATP:] closing " . l:env_name . " from line " . l:bpos_env[0] . " at line " . (l:end+1)
					call setpos(".",[0,l:end,len(l:eindent.l:str)+1,0])
				    endif
				elseif line(".") < l:end
				    let [ lineNr, pos_lineNr ]	= getline(".") =~ '^\s*$' ? [ line(".")-1, line(".")] : [ line("."), line(".")+1 ]
				    call append(lineNr, l:eindent . l:str)
				    echomsg "[ATP:] closing " . l:env_name . " from line " . l:bpos_env[0] . " at line " . (line(".")+1)
				    call setpos(".",[0, pos_lineNr,len(l:eindent.l:str)+1,0])
				elseif line(".") >= l:end
				    call append(l:end-1, l:eindent . l:str)
				    echomsg "[ATP:] closing " . l:env_name . " from line " . l:bpos_env[0] . " at line " . l:end
				    call setpos(".",[0,l:end,len(l:eindent.l:str)+1,0])
				endif
			else
			    if line(".") >= l:max
				call append(l:pos_saved[1], l:eindent . l:str)
				keepjumps call setpos(".",l:pos_saved)
				echomsg "[ATP:] closing " . l:env_name . " from line " . l:bpos_env[0] . " at line " . (line(".")+1)
				call setpos(".",[0,l:pos_saved[1]+1,len(l:eindent.l:str)+1,0])
			    elseif line(".") < l:max
				call append(l:max, l:eindent . l:str)
				echomsg "[ATP:] closing " . l:env_name . " from line " . l:bpos_env[0] . " at line " . (l:max+1)
				call setpos(".",[0,l:max+1,len(l:eindent.l:str)+1,0])
			    endif
			endif
		    else
			let l:pos[1]=l:line_nr
			let l:pos[2]=1
			" put cursor at the end of the line where not closed \begin was
			" found
			keepjumps call setpos(".",[0,l:line_nr,len(getline(l:line_nr)),0])
			let l:cline	= getline(l:pos_saved[1])
			if g:atp_debugCloseLastEnvironment
			    let g:cline		= l:cline
			    let g:pos_saved 	= copy(l:pos_saved)
			    let g:line		= l:pos_saved[1]
			endif
			let l:iline=searchpair('\\begin{','','\\end{','nW')
			if l:iline > l:line_nr && l:iline <= l:pos_saved[1]
			    call append(l:iline-1, l:eindent . l:str)
			    echomsg "[ATP:] closing " . l:env_name . " from line " . l:bpos_env[0] . " at line " . l:iline
			    let l:pos_saved[2]+=len(l:str)
			    call setpos(".",[0,l:iline,len(l:eindent.l:str)+1,0])
			else
			    if l:cline =~ '\\begin{\%('.l:uenv.'\)\@!'
				call append(l:pos_saved[1]-1, l:eindent . l:str)
				echomsg "[ATP:] closing " . l:env_name . " from line " . l:bpos_env[0] . " at line " . l:pos_saved[1]
				let l:pos_saved[2]+=len(l:str)
				call setpos(".",[0,l:pos_saved[1],len(l:eindent.l:str)+1,0])
			    elseif l:cline =~ '^\s*$'
				call append(l:pos_saved[1]-1, l:eindent . l:str)
				echomsg "[ATP:] closing " . l:env_name . " from line " . l:bpos_env[0] . " at line " . l:pos_saved[1]
				let l:pos_saved[2]+=len(l:str)
				call setpos(".",[0,l:pos_saved[1]+1,len(l:eindent.l:str)+1,0])
			    else
				call append(l:pos_saved[1], l:eindent . l:str)
				echomsg "[ATP:] closing " . l:env_name . " from line " . l:bpos_env[0] . " at line " . (l:pos_saved[1]+1)
				" Do not move corsor if: '\begin{env_name}<Tab>'
				if l:cline !~  '\\begin\s*{\s*\%('.l:uenv.'\)\s*}'
				    let l:pos_saved[2]+=len(l:str)
				    call setpos(".",[0,l:pos_saved[1]+1,len(l:eindent.l:str)+1,0])
				else
				    call setpos(".", l:pos_saved)
				endif
			    endif
			endif 
			if g:atp_debugCloseLastEnvironment
			    silent echo "return E"
			    redir END
			endif
			let g:time_CloseLastEnvironment = reltimestr(reltime(time))
			return ''
		    endif
		else
		    if g:atp_debugCloseLastEnvironment
			silent echo "return F"
			redir END
		    endif
		    let g:time_CloseLastEnvironment = reltimestr(reltime(time))
		    return ''
		endif
		unlet! l:env_names
		unlet! l:env_dict
		unlet! l:cenv_names
		unlet! l:pos 
		unlet! l:pos_saved
" 		if getline('.') =~ '^\s*$'
" 		    exec "normal dd"
		endif
    "}}}3
    "{{{2 close math: texMathZoneV, texMathZoneW, texMathZoneX, texMathZoneY 
    else
	"{{{3 Close math in the current line
	if !return_only
	    if l:begin_line != line(".")
		echomsg "[ATP:] closing math from line " . l:begin_line
	    endif
	endif
	if 
	    \ math_mode == 'texMathZoneV' && ( l:line !~ '^\s*\\(\s*$'	|| line(".") == l:begin_line )	|| 
	    \ math_mode == 'texMathZoneW' && ( l:line !~ '^\s*\\\[\s*$' )				||
	    \ math_mode == 'texMathZoneX' && ( l:line !~ '^\s*\$\s*$' 	|| line(".") == l:begin_line ) 	||
	    \ math_mode == 'texMathZoneY' && ( l:line !~ '^\s*\$\{2,2}\s*$' )
	    if g:atp_debugCloseLastEnvironment
		call atplib#Log('CloseLastEnvironment.log', 'inline math')
	    endif
	    if math_mode == "texMathZoneW"
		if !return_only
		    if l:com == 'a' 
			if getline(l:begin_line) =~ '^\s*\\\[\s*$'
			    call append(line("."),atplib#complete#CopyIndentation(getline(l:begin_line)).'\]')
			else
			    call setline(line("."), strpart(l:cline,0,getpos(".")[2]) . '\]'. strpart(l:cline,getpos(".")[2]))
			endif
		    else
			if getline(l:begin_line) =~ '^\s*\\\[\s*$'
			    call append(line("."),atplib#complete#CopyIndentation(getline(l:begin_line)).'\]')
			else
			    call setline(line("."), strpart(l:cline,0,getpos(".")[2]-1) . '\]'. strpart(l:cline,getpos(".")[2]-1))
    " TODO: This could be optional: (but the option rather
    " should be an argument of this function rather than
    " here!
			endif
			let l:pos=getpos(".")
			let l:pos[2]+=2
			keepjumps call setpos(("."),l:pos)
			let b:cle_return="texMathZoneW"
		    endif
		else
		    let g:time_CloseLastEnvironment = reltimestr(reltime(time))
		    return '\]'
		endif
	    elseif math_mode == "texMathZoneV"
		if !return_only
		    if l:com == 'a'
			call setline(line("."), strpart(l:cline,0,getpos(".")[2]) . '\)'. strpart(l:cline,getpos(".")[2]))
		    else
			call setline(line("."), strpart(l:cline,0,getpos(".")[2]-1) . '\)'. strpart(l:cline,getpos(".")[2]-1))
			call cursor(line("."),col(".")+2)
			let b:cle_return="V"
		    endif
		else
		    let g:time_CloseLastEnvironment = reltimestr(reltime(time))
		    return '\)'
		endif
	    elseif math_mode == "texMathZoneX" 
		if !return_only
		    call setline(line("."), strpart(l:cline,0,getpos(".")[2]-1) . '$'. strpart(l:cline,getpos(".")[2]-1))
		    call cursor(line("."),col(".")+1)
		else
		    let g:time_CloseLastEnvironment = reltimestr(reltime(time))
		    return "$"
		endif
	    elseif math_mode == "texMathZoneY" 
		if !return_only
		    call setline(line("."), strpart(l:cline,0,getpos(".")[2]-1) . '$$'. strpart(l:cline,getpos(".")[2]-1))
		    call cursor(line("."),col(".")+2)
		else
		    let g:time_CloseLastEnvironment = reltimestr(reltime(time))
		    return '$$'
		endif
	    endif " }}}3
	"{{{3 Close math in a new line, preserv the indentation.
	else 	    
	    let l:eindent=atplib#complete#CopyIndentation(l:line)
	    if math_mode == 'texMathZoneW'
		if !return_only
		    let l:iline=line(".")
		    " if the current line is empty append before it.
		    if getline(".") =~ '^\s*$' && l:iline > 1
			let l:iline-=1
		    endif
		    call append(l:iline, l:eindent . '\]')
		    echomsg "[ATP:] \[ closed in line " . l:iline
		else
		    let g:time_CloseLastEnvironment = reltimestr(reltime(time))
		    return '\]'
		endif
    " 		let b:cle_return=2 . " dispalyed math " . l:iline  . " indent " . len(l:eindent) " DEBUG
	    elseif math_mode == 'texMathZoneV'
		if !return_only
		    let l:iline=line(".")
		    " if the current line is empty append before it.
		    if getline(".") =~ '^\s*$' && l:iline > 1
			let l:iline-=1
		    endif
		    call append(l:iline, l:eindent . '\)')
		    echomsg "[ATP:] \( closed in line " . l:iline
		else
		    let g:time_CloseLastEnvironment = reltimestr(reltime(time))
		    return '\)'
		endif
    " 		let b:cle_return=2 . " inline math " . l:iline . " indent " .len(l:eindent) " DEBUG
	    elseif math_mode == 'texMathZoneX'
		if !return_only
		    let l:iline=line(".")
		    " if the current line is empty append before it.
		    if getline(".") =~ '^\s*$' && l:iline > 1
			let l:iline-=1
		    endif
		    let sindent=atplib#complete#CopyIndentation(getline(search('\$', 'bnW')))
		    call append(l:iline, sindent . '$')
		    echomsg "[ATP:] $ closed in line " . l:iline
		else
		    let g:time_CloseLastEnvironment = reltimestr(reltime(time))
		    return '$'
		endif
	    elseif math_mode == 'texMathZoneY'
		if !return_only
		    let l:iline=line(".")
		    " if the current line is empty append before it.
		    if getline(".") =~ '^\s*$' && l:iline > 1
			let l:iline-=1
		    endif
		    let sindent=atplib#complete#CopyIndentation(getline(search('\$\$', 'bnW')))
		    call append(l:iline, sindent . '$$')
		    echomsg "[ATP:] $ closed in line " . l:iline
		else
		    let g:time_CloseLastEnvironment = reltimestr(reltime(time))
		    return '$$'
		endif
	    endif
	endif "}}3
    endif
    if g:atp_debugCloseLastEnvironment
	silent echo "return G"
	redir END
    endif
    "}}}2
    let g:time_CloseLastEnvironment = reltimestr(reltime(time))
    return ''
endfunction
" imap <F7> <Esc>:call atplib#CloseLastEnvironment()<CR>
" }}}1
" {{{1 atplib#complete#CheckBracket
" Returns a list [ l:open_line, l:open_col, l:open_bracket ] 
" l:open_col != 0 if any of brackets (in values(g:atp_bracket_dict) ) is
" opened and not closed. l:open_bracket is the most recent such bracket
" ([ l:open_line, l:open_col ] are its coordinates). 
"
" a:bracket_dict is a dictionary of brackets to use: 
" 	 	{ open_bracket : close_bracket } 
fun! atplib#complete#CheckBracket(bracket_dict) "{{{2
    if has("python")
	return atplib#complete#CheckBracket_py(a:bracket_dict)
    else
	return atplib#complete#CheckBracket_vim(a:bracket_dict)
    endif
endfun
fun! atplib#complete#CheckBracket_py(bracket_dict) "{{{2
let time = reltime()
let limit_line = max([1,(line(".")-g:atp_completion_limits[4])])
let pos	= getpos(".")
let begin_line = limit_line
let end_line = min([line('$'), line(".")+g:atp_completion_limits[4]])
call cursor(pos[1:2])
let e_pos = []
if !has("python")
    echoh ErrorMsg
    echom "[ATP:] compile vim with python support for closing brackets"
    echohl Normal
    return [0, 0, '']
endif
python << EOF
import vim
import atplib.check_bracket

encoding = vim.eval('&enc')
bracket_dict = {}
for (key, val) in vim.eval("g:atp_bracket_dict").items():
    bracket_dict[key.decode(encoding)] = val.decode(encoding)

begin_line = int(vim.eval("begin_line"))
end_line = int(vim.eval("end_line"))
buf = vim.current.buffer
text = ('\n'.join(buf[begin_line-1:end_line])).decode(encoding)

bpos = map(lambda i: int(i), vim.eval('getpos(".")')[1:3])
r_idx = (bpos[0]-begin_line, bpos[1]-1) # r_idx line and column starts from 0

e_idx = atplib.check_bracket.check_bracket(text, r_idx[0], r_idx[1], bracket_dict)

if hasattr(vim, 'bindeval'):
    e_pos = vim.bindeval("e_pos")
else:
    e_pos = []

if (e_idx[0], e_idx[1]) != (-1, -1):
    e_pos.extend([e_idx[0]+begin_line, e_idx[1]+1, e_idx[2]])
else:
    e_pos.extend([0,0, e_idx[2]])

if not hasattr(vim, 'bindeval'):
    import json
    vim.command("let e_pos = %s" % json.dumps(e_pos))
EOF
let g:time_CheckBracket = reltimestr(reltime(time))
let [ s:open_line, s:open_col, s:opening_bracket ] = e_pos
if getline(e_pos[0]) =~ '\\begin\s*{\s*document\s*}'
    return [0, 0, '']
else
    return e_pos
endif
endfun
fun! atplib#complete#CheckBracket_vim(bracket_dict) "{{{2

    let time		= reltime()
    let limit_line	= max([1,(line(".")-g:atp_completion_limits[4])])
    let pos		= getpos(".")
    if pos[2] == 1
	let check_pos = [0, pos[1], len(getline(line(".")-1)), 0]
    else
	let check_pos = copy(pos)
	let check_pos[2] -= 1
    endif
    call search('\S', 'bW')
    if !atplib#IsInMath()
	let begin_line	= max([search('\%(\\part\|\\chapter\|\\section\|\\subsection\|\\par\>\|^\s*$\|\\]\|\\end{\s*\%(equation\|align\|alignat\|flalign\|gather\|multline\)\*\=\s*}\)', 'bnW'), limit_line])
	let end_line	= min([search('\%(\\part\|\\chapter\|\\section\|\\subsection\|\\par\>\|^\s*$\|\\[\|\\begin{\s*\%(equation\|align\|alignat\|flalign\|gather\|multline\)\*\=\s*}\)', 'nW'), min([line('$'), line(".")+g:atp_completion_limits[4]])]) 
    else
	let begin_line	= max([search('\%(\\begin\s*{\s*\%(equation\|align\|alignat\|flalign\|gather\|multline\)\*\=\s*}\|\\(\|\$\$\|\\[\|\\par\>\|^\s*$\)', 'bnW'), limit_line])
	let end_line	= min([search('\%(\\end\s*{\s*\%(equation\|align\|alignat\|flalign\|gather\|multline\)\*\=\s*}\|\\)\|\$\$\|\\]\|\\par\>\|^\s*$\)', 'nW'), min([line('$'), line(".")+g:atp_completion_limits[4]])]) 
	if end_line == begin_line
	    let end_line += 1
	endif
    endif
    call cursor(pos[1:2])
    let length 		= end_line-begin_line


    if g:atp_debugCheckBracket
	let g:begin_line	= begin_line
	let g:end_line		= end_line
	let g:limit_line	= limit_line
	let g:length		= length
    endif
    let pos_saved 	= getpos(".")

    " Bracket sizes:
    let ket_pattern	= '\%(' . join(values(filter(copy(g:atp_sizes_of_brackets), "v:val != '\\'")), '\|') . '\)'


   " But maybe we shouldn't check if the bracket is closed sometimes one can
   " want to close closed bracket and delete the old one.
   
   let check_list = []
   if g:atp_debugCheckBracket
       call atplib#Log("CheckBracket.log","", "init")
       let g:check_list	= check_list
   endif

    "    change the position! and then: 
    "    check the flag 'r' in searchpair!!!

    "Note: this can be much faster to first to check if the line is matching
    " \({\|...<all_brackets>\)[^}...<all brackets>]*, etc., but this would not
    " break which bracket to close.
    let i=0
    let bracket_list= keys(a:bracket_dict)
    for ket in bracket_list
	let pos		= deepcopy(pos_saved)
	let pos[2]	-=1
	let time_{i}	= reltime()
	if ket != '{' && ket != '(' && ket != '['
	    if search('\\\@<!'.escape(ket,'\[]'), 'bnW', begin_line)
		let bslash = ( ket != '{' ? '\\\@<!' : '' )
		if ket != '\begin'
		    let pair_{i}	= searchpairpos(bslash.escape(ket,'\[]').'\zs','', bslash.escape(a:bracket_dict[ket], '\[]'). 
			    \ ( ket_pattern != "" ? '\|'.ket_pattern.'\.' : '' ) , 'bnW', "", begin_line)
		else
		    let pair_{i}	= searchpairpos(bslash.'\zs'.escape(ket,'\[]'),'', bslash.escape(a:bracket_dict[ket], '\[]'). 
			    \ ( ket_pattern != "" ? '\|'.ket_pattern.'\.' : '' ) , 'bnW', "", begin_line)
		endif
	    else
		let pair_{i}	= [0, 0]
	    endif
	else
" 	    This is only for brackets: (:), {:} and [:].

" 	    if search('\\\@<!'.escape(ket,'\[]'), 'bnW', limit_line)
" 	    Without this if ~17s with ~19s (100 times), when this code is used
" 	    also for '[' the time was ~16.5s with '<' : ~17s (this bracket is
" 	    not that common, at the place where I was testing it was not
" 	    appearing)
		let ob=0
		let cb=0
		for lnr in range(begin_line, line("."))
		    if lnr == line(".")
			let line_str=strpart(getline(lnr), 0, pos_saved[2]-1)
		    else
			let line_str=getline(lnr)
		    endif
		    " Remove comments:
		    let line_str	= substitute(line_str, '\(\\\@<!\|\\\@<!\%(\\\\\)*\)\zs%.*$', '', '')
		    " Remove \input[...] and \(:\), \[:\]:
		    let line_str 	= substitute(line_str, '\\input\s*\[[^\]]*\]\|\\\@<!\\\%((\|)\|\[\|\]\)', '', 'g') 
		    let line_list 	= split(line_str, '\zs')

		    let ob+=count(line_list, ket)
		    let cb+=count(line_list, a:bracket_dict[ket])
		endfor
		call cursor(limit_line, 1)
		let first_ket_pos	= searchpos(escape(ket,'\[]').'\|'.escape(a:bracket_dict[ket],'\[]'), 'cW', pos_saved[1])
		call cursor(pos_saved[1], pos_saved[2]-1)
		let first_ket		= ( first_ket_pos[1] ? getline(first_ket_pos[0])[first_ket_pos[1]-1] : '{' )

	        if g:atp_debugCheckBracket
		    call atplib#Log("CheckBracket.log",ket." ob=".ob." cb=".cb." first_ket=".first_ket." cond=".(( ob != cb && first_ket == ket ) || ( ob != cb-1 && first_ket != ket )))
		    call atplib#Log("CheckBracket.log",ket." first_ket_pos=".string(first_ket_pos))
		    call atplib#Log("CheckBracket.log",ket." pos=".string(getpos(".")))
		endif
		if ( ob != cb && first_ket == ket ) || ( ob != cb-1 && first_ket != ket )
		    let bslash = ( ket != '{' ? '\\\@<!' : '' )
		    call atplib#Log("CheckBracket.log",ket." searchpairpos args=".bslash.escape(ket,'\[]')." ".bslash.escape(a:bracket_dict[ket], '\[]'). " begin_line=".begin_line)
		    let pair_{i}	= searchpairpos(bslash.escape(ket,'\[]'),'', bslash.escape(a:bracket_dict[ket], '\[]') , 'bcnW', "", begin_line)
		else
		    let pair_{i}	= [0, 0]
		endif
	endif
	let g:time_A_{i}  = reltimestr(reltime(time_{i}))

	if g:atp_debugCheckBracket >= 2
	    echomsg escape(ket,'\[]') . " pair_".i."=".string(pair_{i}) . " limit_line=" . limit_line
	endif
	if g:atp_debugCheckBracket >= 1
	    call atplib#Log("CheckBracket.log", ket." time_A_".i."=".string(g:time_A_{i}))
	    call atplib#Log("CheckBracket.log", ket." pair_".i."=".string(pair_{i}))
	endif
	let pos[1]	= pair_{i}[0]
	let pos[2]	= pair_{i}[1]

	let no_backslash = ( i == 0 || i == 2 ? '\\\@<!' : '' )
	if i == 3
	    let g:atp_debugCheckClosed = 1
	else
	    let g:atp_debugCheckClosed = 0
	endif
	if pos[1] != 0
" 	    let check_{i} = atplib#complete#CheckClosed(no_backslash.escape(ket,'\[]'),
" 			\ '\%('.no_backslash.escape(a:bracket_dict[ket],'\[]').'\|\\\.\)', 
" 			\ max([0,pos[1]-g:atp_completion_limits[4]]), 1, 2*g:atp_completion_limits[4],2)
	    if  i == 2
		let g:atp_debugCheckClosed = 1
	    endif
	    let check_{i} = atplib#complete#CheckClosed(no_backslash.escape(ket,'\[]'),
			\ '\%('.no_backslash.escape(a:bracket_dict[ket],'\[]').'\|\\\.\)', 
			\ begin_line, 1, length, 2)
	    let g:atp_debugCheckClosed = 0
	    let check_{i} = ( check_{i} == 0 )
	else
	    let check_{i} = 0
	endif

	if g:atp_debugCheckBracket >= 1
	    call atplib#Log("CheckBracket.log", ket." check_".i."=".string(check_{i}))
	    let g:check_{i} = check_{i}
	    let g:arg_{i}=[escape(ket,'\[]'), '\%('.escape(a:bracket_dict[ket],'\[]').'\|\\\.\)', begin_line, 1, 2*g:atp_completion_limits[4],2]
	endif
	" check_dot_{i} is 1 if the bracket is closed with a dot (\right.) . 
" 	let check_dot_{i} = atplib#complete#CheckClosed('\\\@<!'.escape(ket, '\[]'), '\\\.', line("."), pos[1], g:atp_completion_limits[4], 1) == '0'
	let check_dot_{i} = 1
	if g:atp_debugCheckBracket >= 1
	    call atplib#Log("CheckBracket.log", ket." check_dot_".i."=".string(check_{i}))
	endif
	if g:atp_debugCheckBracket >= 2
	    echomsg escape(ket,'\[]') . " check_".i."=".string(check_{i}) . " check_dot_".i."=".string(check_dot_{i})
	endif
	let check_{i}	= min([check_{i}, check_dot_{i}])
	call add(check_list, [ pair_{i}[0], ((check_{i})*pair_{i}[1]), i ] ) 
	keepjumps call setpos(".",pos_saved)
	let g:time_B_{i}  = reltimestr(reltime(time_{i}))
	call atplib#Log("CheckBracket.log", ket." time_B_".i."=".string(g:time_B_{i}))
	let i+=1
    endfor
"     let g:time_CheckBracket_A=reltimestr(reltime(time))
    keepjumps call setpos(".", pos_saved)
   
    " Find opening line and column numbers
    call sort(check_list, "atplib#CompareCoordinates")
    let g:check_list = check_list
    let [ open_line, open_col, open_bracket_nr ] 	= check_list[0]
    let [ s:open_line, s:open_col, s:opening_bracket ] 	= [ open_line, open_col, bracket_list[open_bracket_nr] ]
    if g:atp_debugCheckBracket
	let [ g:open_lineCB, g:open_colCB, g:opening_bracketCB ] = [ open_line, open_col, bracket_list[open_bracket_nr] ]
	call atplib#Log("CheckBracket.log", "return:")
	call atplib#Log("CheckBracket.log", "open_line=".open_line)
	call atplib#Log("CheckBracket.log", "open_col=".open_col)
	call atplib#Log("CheckBracket.log", "opening_bracketCB=".g:opening_bracketCB)
    endif
    let g:time_CheckBracket=reltimestr(reltime(time))
"     let g:time=g:time+str2float(substitute(g:time_CheckBracket, '\.', ',', ''))
    return [ open_line, open_col, bracket_list[open_bracket_nr] ]
endf
" }}}1
" {{{1 atplib#complete#CloseLastBracket
"
" The second function closes the bracket if it was not closed. 
" (as returned by atplib#complete#CheckBracket or [ s:open_line, s:open_col, s:opening_bracket ])

" It is not used to close \(:\) and \[:\] as atplib#complete#CloseLastEnvironment has a better
" way of doing that (preserving indentation)
" a:bracket_dict is a dictionary of brackets to use: 
" 	 	{ open_bracket : close_bracket } 
" a:1 = 1 just return the bracket 
" a:2 = 0 (default), 1 when used in atplib#complete#TabCompletion 
" 			then s:open_line, s:open_col and s:opening_bracket are
" 			used to avoid running twice atplib#complete#CheckBracket():
" 			once in atplib#complete#TabCompletion and secondly in CloseLastBracket
" 			function.

function! atplib#complete#CloseLastBracket(bracket_dict, ...)

    let time = reltime()
    
    let only_return	= ( a:0 >= 1 ? a:1 : 0 )
    let tab_completion	= ( a:0 >= 2 ? a:2 : 0 )

    " {{{2 preambule
    let pattern		= ""
    let size_patterns	= []
    for size in keys(g:atp_sizes_of_brackets)
	call add(size_patterns,escape(size,'\'))
    endfor

    let pattern_b	= '\C\%('.join(size_patterns,'\|').'\)'
    let pattern_o	= '\%('.join(map(keys(a:bracket_dict),'escape(v:val,"\\[]")'),'\|').'\)'

    if g:atp_debugCloseLastBracket
	call atplib#Log("CloseLastBracket.log","","init")
	let g:pattern_b	= pattern_b
	let g:pattern_o	= pattern_o
	call atplib#Log("CloseLastBracket.log", "pattern_b=".pattern_b)
	call atplib#Log("CloseLastBracket.log", "pattern_o=".pattern_o)
    endif

    let limit_line	= max([1,(line(".")-g:atp_completion_limits[1])])
        
    let pos_saved 	= getpos(".")


   " But maybe we shouldn't check if the bracket is closed sometimes one can
   " want to close closed bracket and delete the old one.
   
    call cursor(line("."), col(".")-1)
    let [ open_line, open_col, opening_bracket ] = ( tab_completion ? 
		\ deepcopy([ s:open_line, s:open_col, s:opening_bracket ]) : atplib#complete#CheckBracket(a:bracket_dict) )
    call cursor(line("."), pos_saved[2])

    let g:time_CloseLastBracket_beforeEnv = reltimestr(reltime(time))
    " Check and Close Environment:
    for env_name in g:atp_closebracket_checkenv
	" To Do: this should check for the most recent opened environment
	let limit_line 	= exists("open_line") ? open_line : search('\\\@<!\\\[\|\\\@<!\\(\|\$', 'bn')
	let open_env 	= searchpairpos('\\begin\s*{\s*'.env_name.'\s*}', '', '\\end\s*{\s*'.env_name.'\s*}', 'bnW', '', limit_line)
	let env_name 	= matchstr(strpart(getline(open_env[0]),open_env[1]-1), '\\begin\s*{\s*\zs[^}]*\ze*\s*}')
	if open_env[0] && atplib#CompareCoordinates([(exists("open_line") ? open_line : 0),(exists("open_line") ? open_col : 0)], open_env)
	    call atplib#complete#CloseLastEnvironment('i', 'environment', env_name, open_env)
	    let g:time_CloseLastBracket =reltimestr(reltime(time))
	    return 'closeing ' . env_name . ' at ' . string(open_env) 
	endif
    endfor

   " Debug:
   if g:atp_debugCloseLastBracket
       let g:open_line	= open_line
       let g:open_col	= open_col 
       call atplib#Log("CloseLastBracket.log", "open_line=".open_line)
       call atplib#Log("CloseLastBracket.log", "open_col=".open_col)
   endif
    "}}}2
    let g:time_CloseLastBracket_beforeIf = reltimestr(reltime(time))
   if open_col 
	let line	= getline(open_line)
	let bline	= strpart(line,0,open_col-1)
	if g:atp_debugCloseLastBracket
	    let g:bline = bline
	    call atplib#Log("CloseLastBracket.log", "bline=".bline)
	endif

	" There should be a list of patterns to mach and I should check the
	" equality it is faster than useing regular expressions.
	let opening_size=matchstr(bline,'\zs'.pattern_b.'\s*\ze$')
	if opening_size =~ '^\\\s\+$'
	    let opening_size = ""
	    let space = ""
	else
	    let matchlist = matchlist(opening_size, '^\(\S*\)\(\s*\)$')
	    let opening_size = matchlist[1]
	    let space	= matchlist[2]
	endif
	let closing_size=get(g:atp_sizes_of_brackets, opening_size, "").space
	" DEBUG
	if g:atp_debugCloseLastBracket
	    call atplib#Log("CloseLastBracket.log", "opening_size=".opening_size)
	    call atplib#Log("CloseLastBracket.log", "closing_size=".closing_size)
	endif
	" Do not add closing size if it is already there.
	if get(g:atp_sizes_of_brackets, opening_size, "") != "" && 
		\ matchstr(getline("."), '^.*\ze\%'.col(".").'c') =~ escape(get(g:atp_sizes_of_brackets, opening_size, ""), '\').'\s*$' 
	    let closing_size=""
	endif
        let g:time_CloseLastBracket_A =reltimestr(reltime(time))

	if opening_size == "\\" && opening_bracket != '(' && opening_bracket != '['
	    " This is done for \right\}
	    let bbline		= strpart(bline, 0, len(bline)-1)
	    let opening_size2	= matchstr(bbline,'\zs'.pattern_b.'\s*$')
	    if opening_size2 =~ '^\\\s\+$'
		let opening_size2 = ""
		let space2 = ""
	    else
		let matchlist2 = matchlist(opening_size2, '^\(\S*\)\(\s*\)$')
		let opening_size2 = matchlist2[1]
		let space2	= matchlist2[2]
	    endif
	    let closing_size2	= get(g:atp_sizes_of_brackets,opening_size2,"")
	    let closing_size	= closing_size2.space2.closing_size
	    " Do not add closing size if it is already there.
	    if get(g:atp_sizes_of_brackets,opening_size2,"") != "" && 
		    \ matchstr(getline("."), '^.*\ze\%'.col(".").'c') =~ escape(get(g:atp_sizes_of_brackets,opening_size2,""), '\').'\s*$'
		let closing_size=get(g:atp_sizes_of_brackets,opening_size,"")
	    endif

	    " DEBUG
	    if g:atp_debugCloseLastBracket
		let g:bbline		= bbline
		let g:opening_size2	= opening_size2
		let g:closing_size2	= closing_size2
		call atplib#Log("CloseLastBracket.log", "bbline=".bbline)
		call atplib#Log("CloseLastBracket.log", "opening_size2=".opening_size2)
		call atplib#Log("CloseLastBracket.log", "closing_size2=".closing_size2)
	    endif
	endif
        let g:time_CloseLastBracket_B =reltimestr(reltime(time))
" 	if cline[1:col(".")-1] =~ g:atp

	if open_line != line(".")
	    echomsg "[ATP:] closing " . opening_size . opening_bracket . " from line " . open_line
	endif

	" DEBUG:
" 	if g:atp_debugCloseLastBracket
" 	    call atplib#Log("CloseLastBracket.log", "======")
" 	    let g:o_bra		= opening_bracket
" 	    call atplib#Log("CloseLastBracket.log", "opening_bracket=".opening_bracket)
" 	    let g:o_size	= opening_size
" 	    call atplib#Log("CloseLastBracket.log", "opening_size=".opening_size)
" 	    let g:bline		= bline
" 	    call atplib#Log("CloseLastBracket.log", "bline=".bline)
" 	    let g:line		= line
" 	    call atplib#Log("CloseLastBracket.log", "line=".line)
" 	    let g:opening_size	= opening_size
" 	    call atplib#Log("CloseLastBracket.log", "opening_size=".opening_size)
" 	    let g:closing_size	= closing_size
" 	    call atplib#Log("CloseLastBracket.log", "closing_size=".closing_size)
" 	endif

	let cline=getline(line("."))
	if mode() == 'i'
	    if !only_return
		call setline(line("."), strpart(cline, 0, getpos(".")[2]-1).
			\ closing_size.get(a:bracket_dict, opening_bracket). 
			\ strpart(cline,getpos(".")[2]-1))
	    endif
	    let l:return=closing_size.get(a:bracket_dict, opening_bracket)
	elseif mode() == 'n'
	    if !only_return
		call setline(line("."), strpart(cline,0,getpos(".")[2]).
			\ closing_size.get(a:bracket_dict,opening_bracket). 
			\ strpart(cline,getpos(".")[2]))
	    endif
	    let l:return=closing_size.get(a:bracket_dict, opening_bracket)
	endif
	let pos=getpos(".")
	let pos[2]+=len(closing_size.get(a:bracket_dict, opening_bracket))
	keepjumps call setpos(".", pos)

        let g:time_CloseLastBracket =reltimestr(reltime(time))
	return l:return
   endif
   " }}}2
endfunction
" }}}1
" {{{1 atplib#complete#GetBracket
" This function is used in atplib#complete#TabCompletion in several places.
" It combines both above atplib#complete#CloseLastEnvironment and
" atplib#complete#CloseLastBracket functions.
try
function! atplib#complete#GetBracket(append,bracket_dict,...)
    " a:1 = 0  - pass through first if (it might be checked already).
    " a:2 = atplib#complete#CheckBracket(g:atp_bracket_dict)
    " a:3 = starting position (used be omnicompletion)
    let time=reltime()
    let pos = getpos(".")
    let begParen = ( a:0 >=2 && a:2 != [] ? a:2 : atplib#complete#CheckBracket(a:bracket_dict) )
    if begParen[2] == '\begin' && begParen[1] && (!atplib#complete#CheckSyntaxGroups(['texMathZoneX', 'texMathZoneY', 'texMathZoneV', 'texMathZoneW']))
	call atplib#complete#CloseLastEnvironment(a:append, 'environment', matchstr(getline(begParen[0]), '.*\\begin{\s*\zs[^}]*\ze\s*}'), [begParen[0], begParen[1]-6])
	return ''
    endif
    let g:time_GetBrackets_A=reltimestr(reltime(time))

    if !has("python")
	call cursor(pos[1], pos[2])
	if begParen[1] != 0  || atplib#complete#CheckSyntaxGroups(['texMathZoneX', 'texMathZoneY', 'texMathZoneV', 'texMathZoneW']) || ( a:0 >= 1 && a:1 )
	    if atplib#complete#CheckSyntaxGroups(['texMathZoneV'])
		let pattern = '\\\@<!\\\zs('
		let syntax	= 'texMathZoneV'
		let limit	= g:atp_completion_limits[0]
	    elseif atplib#complete#CheckSyntaxGroups(['texMathZoneW'])
		let pattern = '\\\@<!\\\zs\['
		let syntax	= 'texMathZoneW'
		let limit	= g:atp_completion_limits[1]
	    elseif atplib#complete#CheckSyntaxGroups(['texMathZoneX'])
		let pattern = '\%(\\\|\$\)\@<!\zs\$\$\@!'
		let syntax	= 'texMathZoneX'
		let limit	= g:atp_completion_limits[0]
	    elseif atplib#complete#CheckSyntaxGroups(['texMathZoneY'])
		let pattern = '\\\@<!\$\zs\$'
		let syntax	= 'texMathZoneY'
		let limit	= g:atp_completion_limits[1]
	    else
		let pattern = ''
	    endif

	    let g:time_GetBrackets_B=reltimestr(reltime(time))
	    if !empty(pattern)
		let begMathZone = searchpos(pattern, 'bnW')
		let closed_math = atplib#complete#CheckClosed_math(syntax)
		if atplib#CompareCoordinates([ begParen[0], begParen[1] ], begMathZone) && closed_math
		    " I should close it if math is not closed.
		    let bracket = atplib#complete#CloseLastEnvironment(a:append, 'math', '', [0, 0], 1)
		elseif (begParen[0] != 0 && begParen[1] !=0) && atplib#complete#CheckSyntaxGroups(['texMathZoneV', 'texMathZoneW', 'texMathZoneX', 'texMathZoneY'], begParen[0], begParen[1]) == atplib#complete#CheckSyntaxGroups(['texMathZoneV', 'texMathZoneW', 'texMathZoneX', 'texMathZoneY'], line("."), max([1,col(".")-1]))
		    let [s:open_line, s:open_col, s:opening_bracket]=begParen
			let bracket = atplib#complete#CloseLastBracket(a:bracket_dict, 1, 1)
		    else
			let bracket = "0"
		    endif
		else
		let bracket =  atplib#complete#CloseLastBracket(a:bracket_dict, 1, 1)
	    endif
	    call setpos(".", pos)
	    let g:time_GetBrackets=reltimestr(reltime(time))
	    if bracket != "0"
		return bracket
	    else
		return ''
	    endif
	else
	    return ''
	endif
    else
	let [s:open_line, s:open_col, s:opening_bracket]=begParen
	if begParen[1] != 0
	    let bracket = atplib#complete#CloseLastBracket(a:bracket_dict, 1, 1)
	    call setpos(".", pos) " CloseLastBracket moves position.
	else
	    if atplib#complete#CheckClosed_math('texMathZoneX')
		let bracket = '$'
	    elseif atplib#complete#CheckClosed_math('texMathZoneY')
		let bracket = '$$'
	    else
		let bracket = ''
	    endif
	endif
	return bracket
    endif
    let g:time_GetBrackets=reltimestr(reltime(time))
    return ''
endfunction
catch /E127:/
endtry
"}}}1


" Completions:
" atplib#complete#TabCompletion {{{1
" This is the main TAB COMPLITION function.
"
" expert_mode = 1 (on)  gives less completions in some cases (commands,...)
" 			the matching pattern has to match at the beginning and
" 			is case sensitive. Furthermode  in expert mode, if
" 			completing a command and found less than 1 match then
" 			the function tries to close \(:\) or \[:\] (but not an
" 			environment, before doing ToDo in line 3832 there is
" 			no sense to make it).
" 			<Tab> or <F7> (if g:atp_no_tab_map=1)
" expert_mode = 0 (off) gives more matches but in some cases better ones, the
" 			string has to match somewhare and is case in
" 			sensitive, for example:
" 			\arrow<Tab> will show all the arrows definded in tex,
" 			in expert mode there would be no match (as there is no
" 			command in tex which begins with \arrow).
" 			<S-Tab> or <S-F7> (if g:atp_no_tab_map=1)
"
" Completion Modes: (this is not a complete list any more, see the
" documentation of ATP)
" 	documentclass (\documentclass)
" 	labels   (\ref,\eqref)
" 	packages (\usepackage)
" 	commands
" 	environments (\begin,\(:\),\[:\])
" 	brackets ((:),[:],{:}) preserves the size operators!
" 		Always: check first brackets then environments. Bracket
" 		funnction can call function which closes environemnts but not
" 		vice versa.
" 	bibitems (\cite\|\citep\|citet)
" 	bibfiles (\bibliography)
" 	bibstyle (\bibliographystyle)
" 	end	 (close \begin{env} with \end{env})
" 	font encoding
" 	font family
" 	font series
" 	font shape
" 
"ToDo: the completion should be only done if the completed text is different
"from what it is. But it might be as it is, there are reasons to keep this.
"
try
" Main tab completion function
function! atplib#complete#TabCompletion(expert_mode,...)

    if g:atp_debugTabCompletion
	call atplib#Log("TabCompletion.log", "", "init")
    endif

    let time=reltime()
    let atp_MainFile	= atplib#FullPath(b:atp_MainFile)
    " {{{2 Match the completed word 
    let normal_mode=0

    if a:0 >= 1
	let normal_mode=a:1
    endif

    " this specifies the default argument for atplib#complete#CloseLastEnvironment()
    " in some cases it is better to append after than before.
    let append='i'

    " Define string parts used in various completitons
    let pos		= getpos(".")
    let pos_saved	= deepcopy(pos)
    let line		= join(getbufline("%",pos[1]))
    let nchar		= strpart(line,pos[2]-1,1)
"     let rest		= strpart(line,pos[2]-1) 
    let l		= strpart(line,0,pos[2]-1)
    let n		= strridx(l,'{')
    let m		= strridx(l,',')
    let o		= strridx(l,'\')
    let s		= strridx(l,' ')
    let p		= strridx(l,'[')
    let r		= strridx(l,'=')
    let c		= match(l, '\\cite\>\(.*\\cite\>\)\@!') 
    let a		= len(l) - stridx(join(reverse(split(l, '\zs')), ''), "=")
     
    let nr=max([n,m,o,s,p])
    let color_nr=max([nr, r])

    " this matches for =...
    let abegin		= strpart(l, a-1)

    " this matches for \...
    let begin		= strpart(l,nr+1)
    let cmd_val_begin	= strpart(l,max([nr+1,r+1]))
    let color_begin	= strpart(l,color_nr+1)
    let cbegin		= strpart(l,nr)
    " and this for '\<\w*$' (beginning of last started word) -- used in
    " tikzpicture completion method 
    let tbegin		= matchstr(l,'\zs\<\w*$')
    " start with last '\'
    let obegin		= strpart(l,o)
    " start with last =
    let ebegin		= strpart(l,max([r,m,n])+1)

    " what we are trying to complete: usepackage, environment.
    let pline		= strpart(l, 0, nr)
    	" \cite[Theorem~1]{Abcd -> \cite[Theorem~] 
    let ppline		= strpart(l, c)
    	" \cite[Theorem~1]{Abcd -> \cite[Theorem~1]{ 

    let limit_line=max([1,(pos[1]-g:atp_completion_limits[1])])

    if g:atp_debugTabCompletion
	let g:nchar	= nchar
	call atplib#Log("TabCompletion.log", "nchar=".nchar)
	let g:l		= l
	call atplib#Log("TabCompletion.log", "l=".l)
	let g:n		= n
	call atplib#Log("TabCompletion.log", "n=".n)
	let g:o		= o
	call atplib#Log("TabCompletion.log", "o=".o)
	let g:s		= s
	call atplib#Log("TabCompletion.log", "s=".s)
	let g:p		= p
	call atplib#Log("TabCompletion.log", "p=".p)
	let g:a		= a
	call atplib#Log("TabCompletion.log", "a=".a)
	let g:nr	= nr
	call atplib#Log("TabCompletion.log", "nr=".nr)

	let g:line	= line    
	call atplib#Log("TabCompletion.log", "line=".line)
	let g:abegin	= abegin
	call atplib#Log("TabCompletion.log", "abegin=".abegin)
	let g:cmd_val_begin = cmd_val_begin
	call atplib#Log("TabCompletion.log", "cmd_val_begin=".cmd_val_begin)
	let g:tbegin	= tbegin
	call atplib#Log("TabCompletion.log", "tbegin=".tbegin)
	let g:cbegin	= cbegin
	call atplib#Log("TabCompletion.log", "cbegin=".cbegin)
	let g:obegin	= obegin
	call atplib#Log("TabCompletion.log", "obegin=".obegin)
	let g:begin	= begin 
	call atplib#Log("TabCompletion.log", "begin=".begin)
	let g:ebegin	= ebegin 
	call atplib#Log("TabCompletion.log", "ebegin=".ebegin)
	let g:pline	= pline
	call atplib#Log("TabCompletion.log", "pline=".pline)
	let g:ppline	= ppline
	call atplib#Log("TabCompletion.log", "ppline=".ppline)
	let g:color_begin	= color_begin
	call atplib#Log("TabCompletion.log", "color_begin=".color_begin)

	let g:limit_line= limit_line
	call atplib#Log("TabCompletion.log", "limit_line=".limit_line)
    endif


" {{{2 SET COMPLETION METHOD
    " {{{3 --------- command
    if o > n && o > s && 
	\ pline !~ '\%(input\s*{[^}]*$\|include\%(only\)\=\s*{[^}]*$\|[^\\]\\\\[^\\]$\)' &&
	\ pline !~ '\\\@<!\\$' &&
	\ begin !~ '{\|}\|,\|-\|\^\|\$\|(\|)\|&\|-\|+\|=\|#\|:\|;\|\.\|,\||\|?$' &&
	\ begin !~ '^\[\|\]\|-\|{\|}\|(\|)' &&
	\ cbegin =~ '^\\' && !normal_mode &&
	\ l !~ '\\\%(no\)\?cite[a-z]*\s*{[^}]*$' &&
	\ l !~ '\\ref\s*{\S*$' &&
	\ index(g:atp_completion_active_modes, 'commands') != -1
	" in this case we are completing a command
	" the last match are the things which for sure do not ends any
	" command. The pattern '[^\\]\\\\[^\\]$' do not matches "\" and "\\\",
	" in which case the line contains "\\" and "\\\\" ( = line ends!)
	" (here "\" is one character \ not like in magic patterns '\\')
	" but matches "" and "\\" (i.e. when completing "\" or "\\\" [end line
	" + command].
	    let g:atp_completion_method='command'
	    " DEBUG:
	    let b:comp_method='command'
	    if g:atp_debugTabCompletion
		call atplib#Log("TabCompletion.log", "b:comp_method=".b:comp_method)
	    endif
    "{{{3 --------- environment options & environment options values
    elseif (l =~ '\\begin\s*{[^}]*}\s*\[[^\]]*$' && !normal_mode) &&
		\ index(g:atp_completion_active_modes, 'environment options') != -1 
	if (l =~ '\\begin\s*{[^}]*}\s*\[[^\]]*=[^\],]*$')
	    let g:atp_completion_method='environment values of options'
	    let b:comp_method=g:atp_completion_method
	    if g:atp_debugTabCompletion
		call atplib#Log("TabCompletion.log", "b:comp_method=".b:comp_method)
	    endif
	else
	    let g:atp_completion_method='environment options'
	    let b:comp_method=g:atp_completion_method
	    if g:atp_debugTabCompletion
		call atplib#Log("TabCompletion.log", "b:comp_method=".b:comp_method)
	    endif
	endif
    "{{{3 --------- environment names
    elseif (pline =~ '\%(\\begin\|\\end\)\s*$' && begin !~ '}.*$' && !normal_mode) &&
		\ index(g:atp_completion_active_modes, 'environment names') != -1 
	    let g:atp_completion_method='environment_names'
	    " DEBUG:
	    let b:comp_method='environment_names'
	    if g:atp_debugTabCompletion
		call atplib#Log("TabCompletion.log", "b:comp_method=".b:comp_method)
	    endif
    "{{{3 --------- labels
    elseif l =~ '\\\%(eq\|page\|auto\|autopage\)\?ref\*\={[^}]*$\|\\hyperref\s*\[[^\]]*$' && !normal_mode &&
		\ index(g:atp_completion_active_modes, 'labels') != -1 
	    let g:atp_completion_method='labels'
	    " DEBUG:
	    let b:comp_method='labels'
	    if g:atp_debugTabCompletion
		call atplib#Log("TabCompletion.log", "b:comp_method=".b:comp_method)
	    endif
    "{{{3 --------- pagestyle
    elseif l =~ '\\\%(pagestyle\|thispagestyle\){[^}]*$' &&
		\ index(g:atp_completion_active_modes, 'page styles') != -1 
	let g:atp_completion_method='pagestyle'
	" DEBUG:
	let b:comp_method='pagestyle'
	if g:atp_debugTabCompletion
	    call atplib#Log("TabCompletion.log", "b:comp_method=".b:comp_method)
	endif
    "{{{3 --------- pagenumbering
    elseif l =~ '\\pagenumbering{[^}]*$' &&
		\ index(g:atp_completion_active_modes, 'page numberings') != -1 
	let g:atp_completion_method='pagenumbering'
	" DEBUG:
	let b:comp_method='pagenumbering'
	if g:atp_debugTabCompletion
	    call atplib#Log("TabCompletion.log", "b:comp_method=".b:comp_method)
	endif
    "{{{3 --------- bibitems
    elseif ppline =~ '\\\%(no\)\?[cC]ite\%(\%(al\)\?[tp]\*\?\|text\|num\|author\*\?\|year\%(par\)\?\)\?\(\s*\[[^]]*\]\s*\)\={[^}]*$' && !normal_mode &&
		\ index(g:atp_completion_active_modes, 'bibitems') != -1
	    let g:atp_completion_method='bibitems'
	    " DEBUG:
	    let b:comp_method='bibitems'
	    if g:atp_debugTabCompletion
		call atplib#Log("TabCompletion.log", "b:comp_method=".b:comp_method)
	    endif
    "{{{3 --------- tikzpicture
    elseif 
	\ !normal_mode &&
	\ ( search('\%(\\def\>.*\|\\\%(re\)\?newcommand\>.*\|%.*\)\@<!\\begin{tikzpicture}','bnW') > search('[^%]*\\end{tikzpicture}','bnW') ||
	\ !atplib#CompareCoordinates(searchpos('[^%]*\zs\\tikz{','bnw'),searchpos('}','bnw')) )
	"{{{4 ----------- tikzpicture colors
	if begin =~ '^color='
	    " This is for tikz picture color completion.
	    let g:atp_completion_method='tikzpicture colors'
	    let b:comp_method='tikzpicture colors'
	    if g:atp_debugTabCompletion
		call atplib#Log("TabCompletion.log", "b:comp_method=".b:comp_method)
	    endif
	"{{{4 ----------- tikzpicture keywords
	elseif l =~ '\%(\s\|\[\|{\|}\|,\|\.\|=\|:\)' . tbegin . '$' &&
		    \ !a:expert_mode
		let b:comp_method='tikzpicture keywords'
		if g:atp_debugTabCompletion
		    call atplib#Log("TabCompletion.log", "b:comp_method=".b:comp_method)
		endif
		let g:atp_completion_method="tikzpicture keywords"
	"{{{4 ----------- brackets
	else
	    let begParen = atplib#complete#CheckBracket(g:atp_bracket_dict)
	    let g:begParen = begParen
	    if begParen[2] != '\begin' && ( begParen[1] != 0 || atplib#complete#CheckSyntaxGroups(['texMathZoneX', 'texMathZoneY']) &&
		    \ (!normal_mode &&  index(g:atp_completion_active_modes, 'brackets') != -1 ) ||
		    \ (normal_mode && index(g:atp_completion_active_modes_normal_mode, 'brackets') != -1 ) )

		let b:comp_method='brackets tikzpicture'
		let g:atp_completion_method = 'brackets'
		let bracket=atplib#complete#GetBracket(append, g:atp_bracket_dict, 0, begParen)
		let g:time_TabCompletion=reltimestr(reltime(time))
		let move = ( !a:expert_mode ? join(map(range(len(bracket)), '"\<Left>"'), '') : '' )
		return bracket.move
	"{{{4 ----------- close environments
	    elseif (!normal_mode &&  index(g:atp_completion_active_modes, 'close environments') != '-1' ) ||
			\ (normal_mode && index(g:atp_completion_active_modes_normal_mode, 'close environments') != '-1' )
		let g:atp_completion_method='close_env'
		" DEBUG:
		let b:comp_method='close_env tikzpicture' 
		if g:atp_debugTabCompletion
		    call atplib#Log("TabCompletion.log", "b:comp_method=".b:comp_method)
		endif
	    else
		return ''
	    endif
	endif
    "{{{3 --------- package options values
    elseif l =~ '\\\%(usepackage\|RequirePackage\)\[[^\]]*=\%([^\],]*\|{\([^}]\+,\)\?[^}]*\)$' &&
		\ !( l =~ '\\\%(usepackage\|RequirePackage\)\[[^\]]*=\%(.*\]\|{.*}\),$' ) && 
		\ !normal_mode &&
		\  index(g:atp_completion_active_modes, 'package options values') != -1
	    let g:atp_completion_method='package options values'
	    let b:comp_method=g:atp_completion_method
    "{{{3 --------- package options
    elseif l =~ '\\\%(usepackage\|RequirePackage\)\[[^\]]*$' && !normal_mode &&
		\  index(g:atp_completion_active_modes, 'package options') != -1
	    let g:atp_completion_method='package options'
	    let b:comp_method=g:atp_completion_method
    "{{{3 --------- package
    elseif pline =~ '\\\%(usepackage\|RequirePackage\)\%([.*]\)\?\s*' && !normal_mode &&
		\  index(g:atp_completion_active_modes, 'package names') != -1
	    let g:atp_completion_method='package'
	    " DEBUG:
	    let b:comp_method='package'
	    if g:atp_debugTabCompletion
		call atplib#Log("TabCompletion.log", "b:comp_method=".b:comp_method)
	    endif
    "{{{3 --------- tikz libraries
    elseif pline =~ '\\usetikzlibrary\%([.*]\)\?\s*' && !normal_mode &&
		\ index(g:atp_completion_active_modes, 'tikz libraries') != -1
	    let g:atp_completion_method='tikz libraries'
	    " DEBUG:
	    let b:comp_method='tikz libraries'
	    if g:atp_debugTabCompletion
		call atplib#Log("TabCompletion.log", "b:comp_method=".b:comp_method)
	    endif
    "{{{3 --------- inputfiles
    elseif (l =~ '\\input\%([^{}]*\|\s*{[^}]*\)$'||
	  \ l =~ '\\include\s*{[^}]*$') && !normal_mode &&
	  \ index(g:atp_completion_active_modes, 'input files') != -1
	    if begin =~ 'input'
		let begin=substitute(begin,'.*\%(input\|include\%(only\)\?\)\s\?','','')
	    endif
	    let g:atp_completion_method='inputfiles'
	    " DEBUG:
	    let b:comp_method='inputfiles'
	    if g:atp_debugTabCompletion
		call atplib#Log("TabCompletion.log", "b:comp_method=".b:comp_method)
	    endif
    "{{{3 --------- includegraphics
    elseif (l =~ '\\includegraphics\s*\(\[[^\]]*\]\s*\)\?{[^}]*$') &&
		\ index(g:atp_completion_active_modes, 'includegraphics') != -1
	    let g:atp_completion_method='includegraphics'
	    " DEBUG:
	    let b:comp_method='includegraphics'
	    if g:atp_debugTabCompletion
		call atplib#Log("TabCompletion.log", "b:comp_method=".b:comp_method)
	    endif
    "{{{3 --------- bibfiles
    elseif pline =~ '\\\%(bibliography\%(style\)\@!\|addbibresource\|addglobalbib\)' && !normal_mode &&
		\ index(g:atp_completion_active_modes, 'bibfiles') != -1
	    let g:atp_completion_method='bibfiles'
	    " DEBUG:
	    let b:comp_method='bibfiles'
	    if g:atp_debugTabCompletion
		call atplib#Log("TabCompletion.log", "b:comp_method=".b:comp_method)
	    endif
    "{{{3 --------- bibstyles
    elseif pline =~ '\\bibliographystyle' && !normal_mode  &&
	 \ index(g:atp_completion_active_modes, 'bibstyles') != -1
	    let g:atp_completion_method='bibstyles'
	    let b:comp_method='bibstyles'
	    if g:atp_debugTabCompletion
		call atplib#Log("TabCompletion.log", "b:comp_method=".b:comp_method)
	    endif
    "{{{3 --------- todo & missingfigure options
    elseif obegin =~ '\\todo\[[^\]]*$' &&
		\ ( index(g:atp_completion_active_modes, 'todonotes') != -1 ) 
	    let g:atp_completion_method='todo options'
	    let b:comp_method='todo options'
	    if g:atp_debugTabCompletion
		call atplib#Log("TabCompletion.log", "b:comp_method=".b:comp_method)
	    endif
    elseif obegin =~ '\\missingfigure\[[^\]]*$' &&
		\ ( index(g:atp_completion_active_modes, 'todonotes') != -1 )
	    let g:atp_completion_method='missingfigure options'
	    let b:comp_method='missingfigure options'
	    if g:atp_debugTabCompletion
		call atplib#Log("TabCompletion.log", "b:comp_method=".b:comp_method)
	    endif

    "{{{3 --------- documentclass options
    elseif l =~ '\\documentclass\s*\[[^\]]*$' && !normal_mode  &&
	    \ index(g:atp_completion_active_modes, 'documentclass options') != -1
	    let g:atp_completion_method='documentclass options'
	    let b:comp_method=g:atp_completion_method
	    if g:atp_debugTabCompletion
		call atplib#Log("TabCompletion.log", "b:comp_method=".b:comp_method)
	    endif
    "{{{3 --------- documentclass
    elseif pline =~ '\\documentclass\>' && !normal_mode  &&
		\ index(g:atp_completion_active_modes, 'documentclass') != -1
	    let g:atp_completion_method='documentclass'
	    let b:comp_method='documentclass'
	    if g:atp_debugTabCompletion
		call atplib#Log("TabCompletion.log", "b:comp_method=".b:comp_method)
	    endif
    "{{{3 --------- font family
    elseif l =~ '\%(\\renewcommand\s*{\s*\\\%(rm\|sf\|bf\|tt\|md\|it\|sl\|sc\|up\)default\s*}\s*{\|\\usefont\s*{[^}]*}{\|\\DeclareFixedFont\s*{[^}]*}{[^}]*}{\|\\fontfamily\s*{\)[^}]*$' && !normal_mode  &&
		\ index(g:atp_completion_active_modes, 'font family') != -1
	    let g:atp_completion_method='font family'
	    let b:comp_method='font family'
	    if g:atp_debugTabCompletion
		call atplib#Log("TabCompletion.log", "b:comp_method=".b:comp_method)
	    endif
    "{{{3 --------- font series
    elseif l =~ '\%(\\usefont{[^}]*}{[^}]*}{\|\\DeclareFixedFont{[^}]*}{[^}]*}{[^}]*}{\|\\fontseries{\)[^}]*$' && 
		\ !normal_mode  &&
		\ index(g:atp_completion_active_modes, 'font series') != -1
	    let g:atp_completion_method='font series'
	    let b:comp_method='font series'
	    if g:atp_debugTabCompletion
		call atplib#Log("TabCompletion.log", "b:comp_method=".b:comp_method)
	    endif
    "{{{3 --------- font shape
    elseif l =~ '\%(\\usefont{[^}]*}{[^}]*}{[^}]*}{\|\\DeclareFixedFont{[^}]*}{[^}]*}{[^}]*}{[^}]*}{\|\\fontshape{\)[^}]*$' 
		\ && !normal_mode  &&
		\ index(g:atp_completion_active_modes, 'font shape') != -1
	    let g:atp_completion_method='font shape'
	    let b:comp_method='font shape'
	    if g:atp_debugTabCompletion
		call atplib#Log("TabCompletion.log", "b:comp_method=".b:comp_method)
	    endif
    "{{{3 --------- font encoding
    elseif l =~ '\%(\\usefont{\|\\DeclareFixedFont{[^}]*}{\|\\fontencoding{\)[^}]*$' && !normal_mode  &&
		\ index(g:atp_completion_active_modes, 'font encoding') != -1
	let g:atp_completion_method='font encoding'
	let b:comp_method='font encoding'
	if g:atp_debugTabCompletion
	    call atplib#Log("TabCompletion.log", "b:comp_method=".b:comp_method)
	endif
    "{{{3 --------- command's values of values
    elseif l =~ '\\\w\+{\%([^}]*,\)\?[^,}=]*=[^,}]*$' && !normal_mode
	let g:atp_completion_method='command values of values'
	let b:comp_method=g:atp_completion_method
	if g:atp_debugTabCompletion
	    call atplib#Log("TabCompletion.log", "b:comp_method=".b:comp_method)
	endif
    "{{{3 --------- command's values
    " this is at the end because there are many command completions done
    " before - they would not work if this would be on the top.
    elseif ((l =~ '\%(\\\w\+\%(\[\%([^\]]\|\[[^\]]*\]\)*\]\)\?\%({\%([^}]\|{\%([^}]\|{[^}]*}\)*}\)*}\)\?{\%([^}]\|{\%([^}]\|{[^}]*}\)*}\)*$\|\\renewcommand{[^}]*}{[^}]*$\)')
		\ && !normal_mode) &&
		\ index(g:atp_completion_active_modes, 'command values') != -1 
	    let g:atp_completion_method="command values"
	    " DEBUG:
	    let b:comp_method=g:atp_completion_method
	    if g:atp_debugTabCompletion
		call atplib#Log("TabCompletion.log", "b:comp_method=".b:comp_method)
	    endif
    "{{{3 --------- command's optional values
    elseif ((l =~ '\\\w\+\%({[^}]*}\)\{0,2}\[[^\]]*$' 
		\ && !normal_mode) &&
		\ index(g:atp_completion_active_modes, 'command optional values') != -1)
	    let g:atp_completion_method="command optional values"
	    "DEBUG
	    let b:comp_method=g:atp_completion_method
	    if g:atp_debugTabCompletion
		call atplib#Log("TabCompletion.log", "b:comp_method=".b:comp_method)
	    endif
    "{{{3 --------- brackets, algorithmic, abbreviations, close environments
    else
	let begParen = atplib#complete#CheckBracket(g:atp_bracket_dict)
	"{{{4 --------- abbreviations
	if l =~ '=[a-zA-Z]\+\*\=$' &&
		\ index(g:atp_completion_active_modes, 'abbreviations') != -1 &&
		\ !atplib#IsInMath() 
	    let g:atp_completion_method='abbreviations' 
	    let b:comp_method='abbreviations'
	    if g:atp_debugTabCompletion
		call atplib#Log("TabCompletion.log", "b:comp_method=".b:comp_method)
	    endif
	"{{{4 --------- brackets
	elseif begParen[2] != '\begin' && ( begParen[1] != 0 || atplib#complete#CheckSyntaxGroups(['texMathZoneX', 'texMathZoneY']) &&
		\ (!normal_mode &&  index(g:atp_completion_active_modes, 'brackets') != -1 ) ||
		\ (normal_mode && index(g:atp_completion_active_modes_normal_mode, 'brackets') != -1 ) )
	    let g:atp_completion_method = 'brackets'
	    let b:comp_method='brackets'
	    let bracket=atplib#complete#GetBracket(append, g:atp_bracket_dict, 0, begParen)
	    let g:time_TabCompletion=reltimestr(reltime(time))
	    let move = ( !a:expert_mode ? join(map(range(len(bracket)), '"\<Left>"'), '') : '' )
	    return bracket.move
	"{{{4 --------- close environments
	elseif (!normal_mode &&  index(g:atp_completion_active_modes, 'close environments') != '-1' ) ||
		    \ (normal_mode && index(g:atp_completion_active_modes_normal_mode, 'close environments') != '-1' )
	    let g:atp_completion_method='close_env'
	    " DEBUG:
	    let b:comp_method='close_env X' 
	    if g:atp_debugTabCompletion
		call atplib#Log("TabCompletion.log", "b:comp_method=".b:comp_method)
	    endif
	"{{{4 --------- algorithmic
	elseif atplib#complete#CheckBracket(g:atp_algorithmic_dict)[0] != 0 && 
		    \ atplib#complete#CheckSyntaxGroups(['texMathZoneALG']) && 
		    \ ((!normal_mode && index(g:atp_completion_active_modes, 'algorithmic' ) != -1 ) ||
		    \ (normal_mode && index(g:atp_completion_active_modes_normal_mode, 'algorithmic') != -1 ))
		let b:comp_method='algorithmic'
		if g:atp_debugTabCompletion
		    call atplib#Log("TabCompletion.log", "b:comp_method=".b:comp_method)
		endif
		call atplib#complete#CloseLastBracket(g:atp_algorithmic_dict, 0, 1)
		let g:time_TabCompletion=reltimestr(reltime(time))
		return '' 
	"}}}4
	else
	    let g:time_TabCompletion=reltimestr(reltime(time))
	    return ''
	endif
	let g:time_TabCompletion=reltimestr(reltime(time))
	"}}}3
    endif
    let b:completion_method = ( exists("g:atp_completion_method") ? g:atp_completion_method : 'g:atp_completion_method does not exists' )
"}}}2
" {{{2 close environments
    if g:atp_completion_method=='close_env'
	" Close one line math
	if !has("python") && (atplib#complete#CheckClosed_math('texMathZoneV') || 
		\ atplib#complete#CheckClosed_math('texMathZoneW') ||
		\ atplib#complete#CheckClosed_math('texMathZoneX') ||
		\ b:atp_TexFlavor == 'plaintex' && atplib#complete#CheckClosed_math('texMathZoneY'))
	    let b:tc_return = "close_env math"
	    call atplib#complete#CloseLastEnvironment(append, 'math')
	" Close environments
	else
	    let b:tc_return = "close_env environment"
	    let stopline_forward = line(".") + g:atp_completion_limits[2]
	    let stopline_backward = max([ 1, line(".") - g:atp_completion_limits[2]])

	    let line_nr=line(".")
	    let pos_saved=getpos(".")
	    while line_nr >= stopline_backward
		let [ line_nr, col_nr ] = searchpairpos('\\begin\s*{', '', '\\end\s*{', 'bW', 'strpart(getline("."), 0, col(".")-1) =~ "\\\\\\@<!%"', stopline_backward)
		if line_nr >= stopline_backward
		    let env_name = matchstr(strpart(getline(line_nr), col_nr-1), '\\begin\s*{\zs[^}]*\ze}')
		    if env_name =~# '^\s*document\s*$' 
			break
		    endif
		    let line_forward = searchpair('\\begin\s*{'.env_name.'}', '', '\\end\s*{'.env_name.'}', 
							\ 'nW', '', stopline_forward)
		    if line_forward == 0
			break
		    endif
		else
		    let line_nr = 0
		    break
		endif
	    endwhile
	    call cursor(pos_saved[1], pos_saved[2])

	    if line_nr
	    " the env_name variable might have wrong value as it is
	    " looking using '\\begin' and '\\end' this might be not enough, 
		" however the function atplib#CloseLastEnv works perfectly and this
		" should be save:

		let g:time_TabCompletion=reltimestr(reltime(time))
		if env_name !~# '^\s*document\s*$'
		    call atplib#complete#CloseLastEnvironment(append, 'environment', '', [line_nr, 0])
		    return ""
		else
		    return ""
		endif
	    endif
	endif
	let g:time_TabCompletion=reltimestr(reltime(time))
	return ""
    endif
" {{{2 SET COMPLETION LIST
    " generate the completion names
    " {{{3 ------------ ENVIRONMENT NAMES
    if g:atp_completion_method == 'environment_names'
	let end=strpart(line,pos[2]-1)

	keepjumps call setpos(".",[0,1,1,0])
	let stop_line=search('\\begin\s*{document}','cnW')
	keepjumps call setpos(".",pos_saved)

	if end !~ '\s*}'
	    let completion_list = []
" 	    if atplib#search#DocumentClass(atplib#FullPath(b:atp_MainFile)) == 'beamer'
" 		call extend(completion_list, g:atp_BeamerEnvironments)
" 	    endif
	    call extend(completion_list,deepcopy(g:atp_Environments))
	    if g:atp_local_completion
		" Make a list of local envs and commands
		if !exists("s:atp_LocalEnvironments") 
		    LocalCommands
		    let s:atp_LocalEnvironments=copy(b:atp_LocalEnvironments)
		elseif has("python") || has("python3")
		    LocalCommands
		    let s:atp_LocalEnvironments=copy(b:atp_LocalEnvironments)
		endif
		let completion_list=atplib#Extend(completion_list,s:atp_LocalEnvironments)
	    endif
	    let completion_list=atplib#Add(completion_list,'}')
	else
	    let completion_list = []
" 	    if atplib#search#DocumentClass(atplib#FullPath(b:atp_MainFile)) == 'beamer'
" 		call extend(completion_list, g:atp_BeamerEnvironments)
" 	    endif
	    call extend(completion_list,deepcopy(g:atp_Environments))
	    if g:atp_local_completion
		" Make a list of local envs and commands
		if !exists("s:atp_LocalEnvironments") 
		    LocalCommands
		    let s:atp_LocalEnvironments=copy(b:atp_LocalEnvironments)
		elseif has("python") || has("python3")
		    LocalCommands
		    let s:atp_LocalEnvironments=copy(b:atp_LocalEnvironments)
		endif
		call atplib#Extend(completion_list,s:atp_LocalEnvironments)
	    endif
	endif
	" TIKZ
	let in_tikz=searchpair('\\begin\s*{tikzpicture}','','\\end\s*{tikzpicture}','bnW',"", max([1,(line(".")-g:atp_completion_limits[2])])) || atplib#complete#CheckOpened('\\tikz{','}',line("."),g:atp_completion_limits[0])
	if in_tikz
	    if end !~ '\s*}'
		call extend(completion_list,atplib#Add(g:atp_tikz_environments,'}'))
	    else
		call extend(completion_list,g:atp_tikz_environments)
	    endif
	endif
	" AMSMATH
	if atplib#search#SearchPackage('amsmath', stop_line) || g:atp_amsmath != 0 || atplib#search#DocumentClass(atplib#FullPath(b:atp_MainFile)) =~ '^ams'
	    if end !~ '\s*}'
		call extend(completion_list,atplib#Add(g:atp_amsmath_environments,'}'),0)
	    else
		call extend(completion_list,g:atp_amsmath_environments,0)
	    endif
	endif
	" MathTools
	" moved to packages/mathtools.vim
" 	if atplib#search#SearchPackage('mathtools', stop_line)
" 	    if end !~ '\s*}'
" 		call extend(completion_list,atplib#Add(g:atp_MathTools_environments,'}'))
" 	    else
" 		call extend(completion_list,g:atp_MathTools_environments)
" 	    endif
" 	endif
	" Packages
	for package in g:atp_packages
	    if atplib#search#SearchPackage(package) && exists("g:atp_".package."_environments")
		if end !~ '\s*}'
		    call extend(completion_list,atplib#Add({'g:atp_'.package.'_environments'},'}'))
		else
		    call extend(completion_list,{'g:atp_'.package.'_environments'})
		endif
	    elseif has("python") || has("python3")
		let env_list = get(get(g:atp_package_dict.ScanPackage(package.'.sty', ['environments']) ,package.'.sty',{}) , 'environments', [])
		call extend(completion_list, env_list)
	    endif
	endfor
    " {{{3 ------------ ENVIRONMENT VALUES OF OPTIONS
    elseif g:atp_completion_method == 'environment values of options'
	let env_name = matchstr(l, '.*\\begin{\s*\zs\w\+\ze\s*}')
	let [opt_name, opt_value] = matchlist(l,  '\\begin\s*{[^}]*}\s*\[\%([^\]]*,\)\?\([^,\]]*\)=\([^\],]*\)$')[1:2]
	let completion_list=[]
	if a:expert_mode
	    let filter_cond = 'v:val =~? "^".opt_value'
	else
	    let filter_cond = 'v:val =~? opt_value'
	endif
	for package in g:atp_packages
	    if exists("g:atp_".package."_environment_options_values")
		for env_key in keys(g:atp_{package}_environment_options_values)
		    if env_name =~ env_key
			for opt_key in keys(g:atp_{package}_environment_options_values[env_key])
			    if opt_name =~ '^'.opt_key
				let obj = copy(g:atp_{package}_environment_options_values[env_key][opt_key])
				if type(obj) == 3
				    let list = obj
				else
				    let list = obj['matches']
				endif
				call extend(completion_list, filter(list, filter_cond))
				break " we can assume there is only one entry 
			    endif
			endfor
		    endif
		endfor
	    endif
	endfor
    " {{{3 ------------ ENVIRONMENT OPTIONS
    elseif g:atp_completion_method == 'environment options'
	let env_name = matchstr(l, '.*\\begin{\s*\zs\w\+\ze\s*}')
	let completion_list=[]
	for package in g:atp_packages
	    if exists("g:atp_".package."_environment_options") && 
			\ (atplib#search#SearchPackage(package) || atplib#search#DocumentClass(atplib#FullPath(b:atp_MainFile)) == package)
		for key in keys({"g:atp_".package."_environment_options"})
		    if env_name =~ key
			call extend(completion_list, {"g:atp_".package."_environment_options"}[key])
		    endif
		endfor
	    endif
	endfor
    "{{{3 ------------ PACKAGE OPTIONS VALUES
    elseif g:atp_completion_method == 'package options values'
	let package = matchstr(line, '\\\%(usepackage\|RequirePackage\)\[.*{\zs[^}]*\ze}')
	let option  = matchstr(l,'\zs\<\w\+\ze=[^=]*$')
	let completion_list=[]
	if exists("g:atp_".package."_options_values")
	   for pat in keys({"g:atp_".package."_options_values"})
	       if (option =~ '^'.pat)
		   let val={"g:atp_".package."_options_values"}[pat]
		   if type(val) == 3
		       let completion_list={"g:atp_".package."_options_values"}[pat]
		   elseif type(val) == 1
		       execute "let add=".val."()"
		       call extend(completion_list, add)
		   else
		       let completion_list = []
		   endif
		   break
	       endif
	   endfor
       else
	   let g:time_TabCompletion=reltimestr(reltime(time))
	   if g:atp_debugTabCompletion
	       call atplib#Log("TabCompletion.log", 'package options return')
	   endif
	   return ""
       endif
    "{{{3 ------------ PACKAGE OPTIONS
    elseif g:atp_completion_method == 'package options'
	let package = matchstr(line, '\\\%(usepackage\|RequirePackage\).*{\zs[^}]*\ze}')
	let options = split(matchstr(line, '\\\%(usepackage\|RequirePackage\)\[\s*\zs[^\]{]*\ze\s*[\]{]'), '\s*,\s*')
	if has("python") || has("python3")
	    let completion_list = get(get(g:atp_package_dict.ScanPackage(package.'.sty', ['options!']) ,package.'.sty',{}) , 'options', [])
	else
	    let completion_list = []
	endif
	if exists("g:atp_".package."_options")
	    " Add options which are not already present:
	    call extend(completion_list, filter(copy({"g:atp_".package."_options"}), 'index(completion_list, v:val) == -1'))
	endif
	" Note: if the completed phrase is in completion pool then we don't
	" want to remove it:
	let phrase = matchstr(l, '\\\%(usepackage\|RequirePackage\)\[\(.*,\)\?\zs.*')
	let g:phrase = phrase
	call filter(completion_list, 'index(options, v:val) == -1')
    "{{{3 ------------ PACKAGES
    elseif g:atp_completion_method == 'package'
	if exists("g:atp_LatexPackages")
	    let completion_list	= copy(g:atp_LatexPackages)
	else
	    echo "[ATP:] generating a list of packages (it might take a while) ... "
	    if g:atp_debugTabCompletion
		let debugTabCompletion_LatexPackages_TimeStart=reltime()
	    endif
	    let g:atp_LatexPackages	= atplib#search#KpsewhichGlobPath("tex", "", "*.sty")
	    let completion_list	= deepcopy(g:atp_LatexPackages)
	    if g:atp_debugTabCompletion
		let g:debugTabCompletion_LatexPackages_Time=reltimestr(reltime(debugTabCompletion_LatexPackages_TimeStart))
		call atplib#Log("TabCompletion.log", "LatexPackages Time: ".g:debugTabCompletion_LatexPackages_Time)
	    endif
	    redraw
	endif
    "{{{3 ------------ PAGESTYLE
    elseif g:atp_completion_method == 'pagestyle'
	let completion_list=copy(g:atp_pagestyles)
	if atplib#search#SearchPackage('fancyhdr')
	    call extend(completion_list, g:atp_fancyhdr_pagestyles)
	endif
    "{{{3 ------------ PAGENUMBERING
    elseif g:atp_completion_method == 'pagenumbering'
	let completion_list=copy(g:atp_pagenumbering)
    " {{{3 ------------ TIKZ LIBRARIES
    elseif g:atp_completion_method == 'tikz libraries'
	let completion_list=deepcopy(g:atp_tikz_libraries)
    " {{{3 ------------ TIKZ KEYWORDS
    elseif g:atp_completion_method == 'tikzpicture keywords'

	let completion_list=[]
	" TODO: add support for all tikz libraries 
	let tikz_libraries	= atplib#search#GrepPackageList('\\use\%(tikz\|pgf\)library\s*{')
	call map(tikz_libraries, "substitute(v:val, '\\..*$', '', '')")
	for lib in tikz_libraries  
	    if exists("g:atp_tikz_library_".lib."_keywords")
		call extend(completion_list,g:atp_tikz_library_{lib}_keywords)
	    endif   
	endfor
	call extend(completion_list, deepcopy(g:atp_tikz_keywords))
    " {{{3 ------------ TIKZ COMMANDS
    elseif g:atp_completion_method	== 'tikzpicture commands'
	let completion_list 	= []
	" if tikz is declared and we are in tikz environment.
	let tikz_libraries	= atplib#search#GrepPackageList('\\use\%(tikz\|pgf\)library\s*{')
	for lib in tikz_libraries  
	    if exists("g:atp_tikz_library_".lib."_commands")
		call extend(completion_list, g:atp_tikz_library_{lib}_commands)
	    endif   
	endfor
    " {{{3 ------------ TIKZ COLORS
    elseif g:atp_completion_method	== 'tikzpicture colors'
	let completion_list 	= copy(b:atp_LocalColors)
    " {{{3 ------------ COMMANDS
    elseif g:atp_completion_method == 'command'
	"{{{4 
	let tbegin=strpart(l,o+1)
	let completion_list=[]

	" Find end of the preambule.
	if expand("%:p") == atp_MainFile
	    " if the file is the main file
	    let saved_pos=getpos(".")
	    keepjumps call setpos(".", [0,1,1,0])
	    keepjumps let stop_line=search('\\begin\s*{document}','nW')
	    keepjumps call setpos(".", saved_pos)
	else
	    " if the file doesn't contain the preambule
	    if &filetype == 'tex'
		let saved_loclist	= getloclist(0)
		silent! execute '1lvimgrep /\\begin\s*{\s*document\s*}/j ' . fnameescape(atp_MainFile)
		let stop_line	= get(get(getloclist(0), 0, {}), 'lnum', 0)
		call setloclist(0, saved_loclist) 
	    else
		let stop_line = 0
	    endif
	endif
	 
	" Are we in the math mode?
	let math_is_opened	= atplib#IsInMath()

	" -------------------- LOCAL commands {{{4
	if g:atp_local_completion
	    " make a list of local envs and commands:
	    if !exists("b:atp_LocalCommands") 
		" This saves the file.
		call LocalCommands(1, "", "")
	    elseif has("python") || has("python3")
		" This will not save the file.
		call LocalCommands(0, "", "")
	    endif
	    call extend(completion_list, b:atp_LocalCommands)
	endif
	" {{{4 -------------------- MATH commands: amsmath, amssymb, mathtools, nicefrac, SIunits, math non expert mode.
	" if we are in math mode or if we do not check for it.
	if g:atp_no_math_command_completion != 1 &&  ( !g:atp_MathOpened || math_is_opened )
	    call extend(completion_list, g:atp_math_commands)
	    " ----------------------- amsmath && amssymb {{{5
	    " if g:atp_amsmath is set or the document class is ams...
	    if (g:atp_amsmath != 0 || atplib#search#DocumentClass(atplib#FullPath(b:atp_MainFile)) =~ '^ams')
		call extend(completion_list, g:atp_amsmath_commands)
		call extend(completion_list, g:atp_ams_negations)
		call extend(completion_list, g:atp_amsfonts)
		call extend(completion_list, g:atp_amsextra_commands)
		if a:expert_mode == 0 
		    call extend(completion_list, g:atp_ams_negations_non_expert_mode)
		endif
	    " else check if the packages are declared:
	    else
		if atplib#search#SearchPackage('amsmath', stop_line)
		    call extend(completion_list, g:atp_amsmath_commands,0)
		endif
		if atplib#search#SearchPackage('amssymb', stop_line)
		    call extend(completion_list, g:atp_ams_negations)
		    if a:expert_mode == 0 
			call extend(completion_list, g:atp_ams_negations_non_expert_mode)
		    endif
		endif
	    endif
	    call extend(completion_list, g:atp_math_commands_PRE)
	    " ----------------------- nicefrac {{{5
	    if atplib#search#SearchPackage('nicefrac', stop_line)
		call add(completion_list,"\\nicefrac{")
	    endif
	    " ----------------------- SIunits {{{5
	    if atplib#search#SearchPackage('SIunits', stop_line) && ( index(g:atp_completion_active_modes, 'SIunits') != -1 || index(g:atp_completion_active_modes, 'siunits') != -1 )
		call extend(completion_list, g:atp_siuinits)
	    endif
	    for package in g:atp_packages
		if exists("g:atp_".package."_math_commands")
		    call extend(completion_list, {"g:atp_".package."_math_commands"})
		endif
	    endfor

	    " ----------------------- math non expert mode {{{5
	    if a:expert_mode == 0
		call extend(completion_list, g:atp_math_commands_non_expert_mode)
	    endif
	endif
	" {{{4 -------------------- BEAMER commands
" 	if atplib#search#DocumentClass(atplib#FullPath(b:atp_MainFile)) == 'beamer'
" 	    call extend(completion_list, g:atp_BeamerCommands)
" 	endif
	" {{{4 -------------------- TIKZ commands
	" if tikz is declared and we are in tikz environment.
	if atplib#search#SearchPackage('\(tikz\|pgf\)')
	    let in_tikz=searchpair('\\begin\s*{tikzpicture}','','\\end\s*{tikzpicture}','bnW',"", max([1,(line(".")-g:atp_completion_limits[2])])) || atplib#complete#CheckOpened('\\tikz{','}',line("."),g:atp_completion_limits[0])

	    if in_tikz
		" find all tikz libraries at once:
		let tikz_libraries	= atplib#search#GrepPackageList('\\use\%(tikz\|pgf\)library\s*{')

		" add every set of library commands:
		for lib in tikz_libraries  
		    if exists("g:atp_tikz_library_".lib."_commands")
			call extend(completion_list, g:atp_tikz_library_{lib}_commands)
		    endif   
		endfor

		" add common tikz commands:
		call extend(completion_list, g:atp_tikz_commands)

		" if in text mode add normal commands:
		if searchpair('\\\@<!{', '', '\\\@<!}', 'bnW', "", max([ 1, (line(".")-g:atp_completion_limits[0])]))
		    call extend(completion_list, g:atp_Commands)
		endif
	    endif 
	endif
	" {{{4 -------------------- fancyhdr & makeidx Commands
"	if we are not in math mode or if we do not care about it or we are in non expert mode.
	if (!g:atp_MathOpened || !math_is_opened ) || a:expert_mode == 0
	    call extend(completion_list, g:atp_Commands)
	    " FANCYHDR
	    if atplib#search#SearchPackage('fancyhdr', stop_line)
		call extend(completion_list, g:atp_fancyhdr_commands)
	    endif
	    if atplib#search#SearchPackage('makeidx', stop_line)
		call extend(completion_list, g:atp_makeidx_commands)
	    endif
	endif
	" {{{4 -------------------- ToDoNotes package commands
	if ( index(g:atp_completion_active_modes, 'todonotes') != -1 ) && atplib#search#SearchPackage('todonotes', stop_line)
	    call extend(completion_list, g:atp_TodoNotes_commands)
	endif
	"}}}4 
   	"{{{4 -------------------- picture
	if searchpair('\\begin\s*{\s*picture\s*}','','\\end\s*{\s*picture\s*}','bnW',"", max([ 1, (line(".")-g:atp_completion_limits[2])]))
	    call extend(completion_list, g:atp_picture_commands)
	endif 
   	"{{{4 -------------------- PACKAGES
	let time = reltime()
	for package in g:atp_packages
	    if atplib#search#SearchPackage(package)
		if exists("g:atp_".package."_commands")
		    " Add commands whcih are not already present:
		    let add_completion_list = {"g:atp_".package."_commands"}
		elseif has("python") || has("python3")
		    let add_completion_list = get(get(g:atp_package_dict.ScanPackage(package.'.sty',['commands']),package.'.sty',{}), 'commands', [])
		else
		    let add_completion_list = []
		endif
		call extend(completion_list, filter(add_completion_list, 'index(completion_list, v:val) == -1'))
	    endif
	endfor
	let g:time_PackagesCommands=reltimestr(reltime(time))
   	"{{{4 -------------------- DOCUMENT CLASS
	" Todo: get document class from the main file and add
	" g:atp_package_dir.ScanPackage(documentclass.".cls", ['commands'])
	if &filetype == "tex"
	    let loclist = getloclist(0)
	    try
		exe '1lvimgrep /^\s*\\documentclass/j '.fnameescape(b:atp_MainFile)

		let documentclass = matchstr(get(getloclist(0), 0, {'text': ''})['text'], '\\documentclass\s*\[[^\]]*\]\s*{\s*\zs[^}]*\ze\s*}')
	    catch /E480/
		let documentclass = ""
	    endtry
	    call setloclist(0, loclist)
	    if !empty(documentclass)
		if has("python") || has("python3")
		    let add_completion_list = get(get(g:atp_package_dict.ScanPackage(documentclass.'.cls', ['commands']) ,package.'.sty',{}) , 'commands', [])
		else
		    let add_completion_list = []
		endif
		call filter(add_completion_list, 'index(completion_list, v:val) == -1')
		call extend(completion_list, add_completion_list)
		if exists("g:atp_".documentclass."_commands")
		    " Add commands whcih are not already present:
		    call extend(completion_list, filter(copy({"g:atp_".documentclass."_commands"}), 'index(completion_list, v:val) == -1'))
		endif
	    endif
	endif
   	"{{{4 -------------------- CLASS
	let documentclass=atplib#search#DocumentClass(atplib#FullPath(b:atp_MainFile))
	if exists("g:atp_".documentclass."_commands")
	    call extend(completion_list, {"g:atp_".documentclass."_commands"})
	endif
	" ToDo: add layout commands and many more packages. (COMMANDS FOR
	" PREAMBULE)
	"{{{4 -------------------- final stuff
	let env_name=substitute(pline,'.*\%(\\\%(begin\|end.*\){\(.\{-}\)}.*\|\\\%(\(item\)\s*\)\%(\[.*\]\)\?\s*$\)','\1\2','') 
	if env_name =~ '\\\%(\%(sub\)\?paragraph\|\%(sub\)*section\|chapter\|part\)'
	    let env_name=substitute(env_name,'.*\\\(\%(sub\)\?paragraph\|\%(sub\)*section\|chapter\|part\).*','\1','')
	endif
	let env_name=substitute(env_name,'\*$','','')
	" if the pattern did not work do not put the env name.
	" for example \item cos\lab<Tab> the pattern will not work and we do
	" not want env name. 
	if env_name == pline
	    let env_name=''
	endif

	if has_key(g:atp_shortname_dict,env_name)
	    if g:atp_shortname_dict[env_name] != 'no_short_name' && g:atp_shortname_dict[env_name] != '' 
		let short_env_name=g:atp_shortname_dict[env_name]
		let no_separator=0
	    else
		let short_env_name=''
		let no_separator=1
	    endif
	else
	    let short_env_name=''
	    let no_separator=1
	endif

" 	if index(g:atp_no_separator_list, env_name) != -1
" 	    let no_separator = 1
" 	endif

	if g:atp_env_short_names == 1
	    if no_separator == 0 && g:atp_no_separator == 0
		let short_env_name=short_env_name . g:atp_separator
	    endif
	else
	    let short_env_name=''
	endif

	call extend(completion_list, [ '\label{' . short_env_name ],0)
    " {{{3 ------------ COMMAND'S VALUES
    elseif g:atp_completion_method == 'command values'
	if l !~ '\\renewcommand{[^}]*}{[^}]*$'
" 	    let command = matchstr(l, '.*\\\w\+\%(\[\%([^\]]\|\[[^\]]*\]\)*\]\)\?\%({\%([^}]\|{\%([^}]\|{[^}]*\)*}}\)*}\)*{\ze\%([^}]\|{\%([^}]\|{[^}]*}\)*}\)*$')
	    let command = matchstr(l, '.*\\\w\+\%(\[\%([^\]]\|\[[^\]]*\]\)*\]\)\?\%({\%([^}]\|{\%([^}]\|{[^}]*\)*}}\)*}\)*{\ze\%([^}]\|{\%([^}]\|{[^}]*}\)*}\)*$')
	else
	    let command = matchstr(l, '.*\\renewcommand{\s*\zs\\\?\w*\ze\s*}')
	endif
	let completion_list = []
	let command_pat='\\\w\+[{\|\[]'
	for package in g:atp_packages
	    let test = 0
	    if exists("g:atp_".package."_loading")
		for key in keys(g:atp_{package}_loading)
		    let package_line_nr = atplib#search#SearchPackage(g:atp_{package}_loading[key])
		    if g:atp_{package}_loading[key] == "" || package_line_nr == 0
			let test = package_line_nr
		    else
			let package_line = getline(package_line_nr)
			let test = (package_line=~'\\\%(usepackage\|RequirePackage\)\[[^\]]*,\='.g:atp_{package}_loading[key].'[,\]]')
		    endif
		    if test
			break
		    endif
		endfor
	    endif

	    if exists("g:atp_".package."_command_values") && 
		\ ( 
		    \ atplib#search#SearchPackage(package) || test || 
		    \ atplib#search#DocumentClass(atplib#FullPath(b:atp_MainFile)) == package || package == "common" 
		\ )
		for key in keys({"g:atp_".package."_command_values"})
		    " uncomment this to debug in which package file there is a mistake.
		    if command =~ key
			let command_pat = key
			let val={"g:atp_".package."_command_values"}[key]
			if g:atp_debugTabCompletion
			    call atplib#Log("TabCompletion.log", 'command_pat='.command_pat." package=".package)
			    call atplib#Log("TabCompletion.log", 'val='.string(val))
			endif
			if type(val) == 3
			    call extend(completion_list, val)
			elseif type(val) == 1 && exists("*".val)
			    execute "let add=".val."()"
			    call extend(completion_list, add)
			else
			    if g:atp_debugTabCompletion
				call atplib#Log("TabCompletion.log", "command values: wrong type error")
			    endif
			endif
		    endif
		endfor
	    endif
	endfor
    " {{{3 ------------ COMMAND'S OPTIONAL VALUES
    elseif g:atp_completion_method == 'command optional values'
	let command = matchstr(l, '.*\\\w\+\ze\s*\[[^\]]*$')
	let completion_list = []
	let command_pat='\\\w\+[{\|\[]'
	for package in g:atp_packages
	    let test = 0
	    if exists("g:atp_".package."_loading")
		for key in keys(g:atp_{package}_loading)
		    let package_line_nr = atplib#search#SearchPackage(g:atp_{package}_loading[key])
		    if g:atp_{package}_loading[key] == "" || package_line_nr == 0
			let test = package_line_nr
		    else
			let package_line = getline(package_line_nr)
			let test = (package_line=~'\\\%(usepackage\|RequirePackage\)\[[^\]]*,\='.g:atp_{package}_loading[key].'[,\]]')
		    endif
		    if test
			break
		    endif
		endfor
	    endif

	    if exists("g:atp_".package."_command_optional_values") && 
		\ ( 
		    \ atplib#search#SearchPackage(package) || test || 
		    \ atplib#search#DocumentClass(atplib#FullPath(b:atp_MainFile)) == package || package == "common" 
		\ )
		for key in keys({"g:atp_".package."_command_optional_values"})
		    " uncomment this to debug in which package file there is a mistake.
		    if command =~ key
			let command_pat = key
			let val={"g:atp_".package."_command_optional_values"}[key]
			if g:atp_debugTabCompletion
			    call atplib#Log("TabCompletion.log", 'command_pat='.command_pat." package=".package)
			    call atplib#Log("TabCompletion.log", 'val='.string(val))
			endif
			if type(val) == 3
			    call extend(completion_list, val)
			elseif type(val) == 1 && exists("*".val)
			    execute "let add=".val."()"
			    call extend(completion_list, add)
			else
			    if g:atp_debugTabCompletion
				call atplib#Log("TabCompletion.log", "command values: wrong type error")
			    endif
			endif
		    endif
		endfor
	    endif
	endfor
    " {{{3 ------------ COMMAND VALUES OF VALUES
    elseif g:atp_completion_method == 'command values of values'
	let [ cmd_name, opt_name, opt_value ] = matchlist(l, '\(\\\w*\)\s*{\%([^}]*,\)\?\([^,}=]*\)=\([^,}]*\)$')[1:3]
" 	let g:cmd_name = cmd_name
" 	let g:opt_name = opt_name
" 	let g:opt_value = opt_value
	let completion_list=[]
	if a:expert_mode
	    let filter_cond = 'v:val =~? "^".opt_value'
	else
	    let filter_cond = 'v:val =~? opt_value'
	endif
	let cvov_ignore_pattern = ''
	for package in g:atp_packages
	    if exists("g:atp_".package."_command_values_dict")
		for cmd_key in keys(g:atp_{package}_command_values_dict)
		    if cmd_name =~ cmd_key
			echomsg cmd_name
			for opt_key in keys(g:atp_{package}_command_values_dict[cmd_key])
			    echomsg opt_key
			    if opt_name =~ '^'.opt_key
				echomsg opt_name
				if type(g:atp_{package}_command_values_dict[cmd_key][opt_key]) == 3
				    let matches = copy(g:atp_{package}_command_values_dict)[cmd_key][opt_key]
				else
				    let matches = copy(g:atp_{package}_command_values_dict)[cmd_key][opt_key]['matches']
				    let cvov_ignore_pattern = get(g:atp_{package}_command_values_dict[cmd_key][opt_key], 'ignore_pattern', '')
				    let match_l= matchlist(l, '\%(\\\w*\)\s*{\%([^}]*,\)\?\%([^,}=]*\)='.cvov_ignore_pattern.'\([^,}]*\)$')
				    let opt_value = match_l[1]
" 				    let g:opt_value = opt_value
				    if a:expert_mode
					let filter_cond = 'v:val =~? "^".opt_value'
				    else
					let filter_cond = 'v:val =~? cvov_ignore_pattern_.opt_value'
				    endif
				endif
				call extend(completion_list, filter(matches, filter_cond))
				break " we can assume there is only one entry 
			    endif
			endfor
		    endif
		endfor
	    endif
	endfor

    " {{{3 ------------ ABBREVIATIONS
    elseif g:atp_completion_method == 'abbreviations'
	let completion_list  = sort(copy(b:atp_LocalEnvironments), "atplib#CompareStarAfter")+[ "document","description","letter","picture","list","minipage","titlepage","thebibliography","bibliography","center","flushright","flushleft","tikzpicture","frame","itemize","enumerate","quote","quotation","verse","abstract","verbatim","figure","array","table","tabular","equation","equation*","align","align*","alignat","alignat*","gather","gather*","multline","multline*","split","flalign","flalign*","corollary","theorem","proposition","lemma","definition","proof","remark","example","exercise","note","question","notation"]
	for package in g:atp_packages
	    if exists("g:atp_".package."_environments")
		call extend(completion_list, {"g:atp_".package."_environments"})
	    endif
	endfor
	call map(completion_list, "g:atp_iabbrev_leader.v:val.g:atp_iabbrev_leader")
    " {{{3 ------------ LABELS /are done later/
    elseif g:atp_completion_method ==  'labels'
	let completion_list = []
    " {{{3 ------------ INPUTFILES
    elseif g:atp_completion_method ==  'inputfiles'
	let completion_list=[]
	call extend(completion_list, atplib#search#KpsewhichGlobPath('tex', expand(b:atp_OutDir) . ',' . g:atp_texinputs, '*.tex', ':t:r', '^\%(\/home\|\.\|.*users\)', '\%(^\\usr\|texlive\|miktex\|kpsewhich\|generic\)'))
	call sort(completion_list)
    " {{{3 ------------ TEX INCLUDEGRAPHICS
    elseif g:atp_completion_method == 'includegraphics'
	" Search for \graphicspath but only in the preamble
	let matches=atplib#search#GrepPreambule('\\graphicspath')
	if len(matches)
	    for match in matches
		let dirs = map(split(matchstr(match['text'], '\graphicspath\s*{\zs.*\ze}'), '}'), "substitute(v:val, '^\s*{', '', '')")
		call map(dirs, "substitute(v:val, '\/\/', '/**', 'g')")
	    endfor
	else
	    let dirs = [fnamemodify(atplib#FullPath(b:atp_MainFile), ":h")]
	endif
	let gr_dirs = join(dirs,',')
	let g:gr_dirs = gr_dirs
	if b:atp_TexCompiler == "latex"
	    let gr = ["*.eps", "*.EPS"]
	else
	    let gr = ["*.gif", "*jpeg", "*.jpg", "*.png", "*.pdf", "*.pdf_tex", "*.eps",
			\ "*.GIF", "*JPEG", "*.JPG", "*.PNG", "*.PDF", "*.PDF_TEX", "*.EPS"]
	endif
	let completion_list=[]
	if begin !~ '\.\(gif\|jpe\?g\|png\|pdf\|pdf_tex\|eps\)$'
	    for ext in gr
		let completion_list+=split(globpath(gr_dirs, begin.ext), "\n")
	    endfor
	else
	    let completion_list+=split(globpath(gr_dirs, begin), "\n")
	endif
	call map(completion_list, "substitute(v:val, '^\s*\.\/', '', '')")
    " {{{3 ------------ BIBFILES
    elseif g:atp_completion_method ==  'bibfiles'
	let  completion_list=[]
	call extend(completion_list, atplib#search#KpsewhichGlobPath('bib', expand(b:atp_OutDir) . ',' . g:atp_bibinputs, '*.bib', ':t:r', '^\%(\/home\|\.\|.*users\)', '\%(^\\usr\|texlive\|miktex\|kpsewhich\|generic\|miktex\)'))
	call sort(completion_list)
    " {{{3 ------------ BIBSTYLES
    elseif g:atp_completion_method == 'bibstyles'
	let completion_list=atplib#search#KpsewhichGlobPath("bst", "", "*.bst")
    "{{{3 ------------ DOCUMENTCLASS OPTIONS 
    elseif g:atp_completion_method == 'documentclass options' 
	let documentclass = matchstr(line, '\\documentclass\[[^{]*{\zs[^}]*\ze}') 
	if has("python") || has("python3") 
	    let completion_list = get(get(g:atp_package_dict.ScanPackage(documentclass.'.cls', ['options!']) ,documentclass.'.cls',{}) , 'options', [])
	else
	    let completion_list = []
	endif
	if exists("g:atp_".documentclass."_options")
	    if type({"g:atp_".documentclass."_options"}) == 3
		" Add options whcih are not already present:
		call extend(completion_list, filter(copy({"g:atp_".documentclass."_options"}), 'index(completion_list, v:val) == -1'))
	    else " it is a funcref.
		let c_list =  {"g:atp_".documentclass."_options"}.GetOptions(begin)
		let g:c_list = c_list
		call extend(completion_list, filter(c_list, 'index(completion_list, v:val) == -1'))
	    endif
	endif
    "{{{3 ------------ DOCUMENTCLASS
    elseif g:atp_completion_method == 'documentclass'
	if exists("g:atp_LatexClasses")
	    let completion_list	= copy(g:atp_LatexClasses)
	else
	    echo "[ATP:] generating a list of document classes (it might take a while) ... "
	    if g:atp_debugTabCompletion
		let debugTabCompletion_LatexClasses_TimeStart=reltime()
	    endif
	    let g:atp_LatexClasses	= atplib#search#KpsewhichGlobPath("tex", "", "*.cls")
	    if g:atp_debugTabCompletion
		let g:debugTabCompletion_LatexClasses_Time=reltimestr(reltime(debugTabCompletion_LatexClasses_TimeStart))
		call atplib#Log("TabCompletion.log", "LatexClasses Time: ".g:debugTabCompletion_LatexClasses_Time)
	    endif
	    redraw
	    let completion_list		= deepcopy(g:atp_LatexClasses)
	endif
	" \documentclass must be closed right after the name ends:
	if nchar != "}"
	    call map(completion_list,'v:val."}"')
	endif
    "{{{3 ------------ FONT FAMILY
    elseif g:atp_completion_method == 'font family'
	echo "[ATP:] searching through fd files ..."
	let time=reltime()
	let bpos=searchpos('\\selectfon\zst','bnW',line("."))[1]
	let epos=searchpos('\\selectfont','nW',line("."))[1]-1
	if epos == -1
	    let epos=len(line)
	endif
	let fline=strpart(line,bpos,epos-bpos)
	let encoding=matchstr(fline,'\\\%(usefont\|DeclareFixedFont\s*{[^}]*}\|fontencoding\)\s*{\zs[^}]*\ze}')
	if encoding == ""
	    let encoding=g:atp_font_encoding
	endif
	let completion_list=[]
	let fd_list=atplib#fontpreview#FdSearch('^'.encoding.begin)
	" The above function takes .5s to complete. The code below takes more 1s.
	for file in fd_list
            call extend(completion_list,map(atplib#fontpreview#ShowFonts(file),'matchstr(v:val,"usefont\\s*{[^}]*}\\s*{\\zs[^}]*\\ze}")'))
	endfor
" 	call filter(completion_list,'count(completion_list,v:val) == 1 ')
" 	This was taking another .8s.
	redraw
	if len(completion_list) == 0
	    echo "[ATP:] nothing found."
	endif
	let g:time_font_family=reltimestr(reltime(time))
    "{{{3 ------------ FONT SERIES
    elseif g:atp_completion_method == 'font series'
	let time=reltime()
	let bpos=searchpos('\\selectfon\zst','bnW',line("."))[1]
	let epos=searchpos('\\selectfont','nW',line("."))[1]-1
	if epos == -1
	    let epos=len(line)
	endif
	let fline=strpart(line,bpos,epos-bpos)
	let encoding=matchstr(fline,'\\\%(usefont\|DeclareFixedFont\s*{[^}]*}\|fontencoding\)\s*{\zs[^}]*\ze}')
	if encoding == ""
	    let encoding=g:atp_font_encoding
	endif
	let font_family=matchstr(fline,'\\\%(usefont\s*{[^}]*}\|DeclareFixedFont\s*{[^}]*}\s*{[^}]*}\|fontfamily\)\s*{\zs[^}]*\ze}')
	echo "[ATP:] searching through fd files ..."
	let completion_list=[]
	let fd_list=atplib#fontpreview#FdSearch(encoding.font_family)
	" The above function takes .5s to complete.
	for file in fd_list
	    call extend(completion_list, map(atplib#fontpreview#ShowFonts(file),'matchstr(v:val,"usefont{[^}]*}{[^}]*}{\\zs[^}]*\\ze}")'))
	endfor
	call filter(completion_list,'count(completion_list,v:val) == 1 ')
	redraw
    "{{{3 ------------ FONT SHAPE
    elseif g:atp_completion_method == 'font shape'
	let bpos=searchpos('\\selectfon\zst','bnW',line("."))[1]
	let epos=searchpos('\\selectfont','nW',line("."))[1]-1
	if epos == -1
	    let epos=len(line)
	endif
	let fline=strpart(line,bpos,epos-bpos)
	let encoding=matchstr(fline,'\\\%(usefont\|DeclareFixedFont\s*{[^}]*}\|fontencoding\)\s*{\zs[^}]*\ze}')
	if encoding == ""
	    let encoding=g:atp_font_encoding
	endif
	let font_family=matchstr(fline,'\\\%(usefont{[^}]*}\|DeclareFixedFont\s*{[^}]*}\s*{[^}]*}\|fontfamily\)\s*{\zs[^}]*\ze}')
	let font_series=matchstr(fline,'\\\%(usefont\s*{[^}]*}\s*{[^}]*}\|DeclareFixedFont\s*{[^}]*}\s*{[^}]*}\s*{[^}]*}\|fontseries\)\s*{\zs[^}]*\ze}')
	echo "[ATP:] searching through fd files ..."
	let completion_list=[]
	let fd_list=atplib#fontpreview#FdSearch('^'.encoding.font_family)

	for file in fd_list
	    call extend(completion_list,map(atplib#fontpreview#ShowFonts(file),'matchstr(v:val,"usefont{[^}]*}{'.font_family.'}{'.font_series.'}{\\zs[^}]*\\ze}")'))
	endfor
	call filter(completion_list,'count(completion_list,v:val) == 1 ')
	redraw
    " {{{3 ------------ FONT ENCODING
    elseif g:atp_completion_method == 'font encoding'
	let bpos=searchpos('\\selectfon\zst','bnW',line("."))[1]
	let epos=searchpos('\\selectfont','nW',line("."))[1]-1
	if epos == -1
	    let epos=len(line)
	endif
	let fline=strpart(line,bpos,epos-bpos)
	let font_family=matchstr(fline,'\\\%(usefont\s*{[^}]*}\|DeclareFixedFont\s*{[^}]*}\s*{[^}]*}\|fontfamily\)\s*{\zs[^}]*\ze}')
	if font_family != ""
	    echo "[ATP:] searching through fd files ..."
	    let fd_list=atplib#fontpreview#FdSearch(font_family)
	    let completion_list=map(copy(fd_list),'toupper(substitute(fnamemodify(v:val,":t"),"'.font_family.'.*$","",""))')
	    redraw
	else
" 	    let completion_list=[]
" 	    for fd_file in fd_list
" 		let enc=substitute(fnamemodify(fd_file,":t"),"\\d\\zs.*$","","")
" 		if enc != fnamemodify(fd_file,":t")
" 		    call add(completion_list,toupper(enc))
" 		endif
" 	    endfor
	    let completion_list=g:atp_completion_font_encodings
	endif
    " {{{3 ------------ BIBITEMS
    elseif g:atp_completion_method == 'bibitems'
	let time_bibitems=reltime()
	let col = col('.') - 1
	while col > 0 && line[col - 1] !~ '{\|,'
		let col -= 1
	endwhile
	let pat = strpart(l,col)
	let searchbib_time=reltime()
	if len(filter(values(copy(b:TypeDict)), "v:val == 'bib'"))
	    if !exists("b:ListOfFiles") && !exists("b:TypeDict")
		call TreeOfFiles(b:atp_MainFile)
	    endif
	    if has("python") || has("python3") && g:atp_bibsearch == "python" && pat != ""
		let bibfiles=[]
		for f in b:ListOfFiles
		    let type = get(b:TypeDict, f, "NOTYPE")
		    if type == 'bib'
			call add(bibfiles, f)
		    elseif type == "NOTYPE"
			InputFiles
			let type = get(b:TypeDict, f, "NOTYPE")
			if type == "NOTYPE"
			    echoerr "[ATP] error "
			endif
		    endif
		endfor
		let bibitems_list=values(atplib#bibsearch#searchbib_py("", pat, bibfiles))
	    else
		let bibdict={}
		for f in b:ListOfFiles
		    try
			let type = get(b:TypeDict, f, "NOTYPE")
			if type == 'bib'
			    let bibdict[f]=readfile(f)
			elseif type == "NOTYPE"
			    InputFiles
			    let type = get(b:TypeDict, f, "NOTYPE")
			    if type == "NOTYPE"
				echoerr "[ATP] error "
			    endif
			endif
		    catch /E716:/
			echoerr "[ATP]: key ".f." not present in dictionary b:TypeDict. Try to run :InputFiles."
			return ''
		    endtry
		endfor
		let bibitems_list=values(atplib#bibsearch#searchbib(pat, bibdict))
	    endif
	    let g:time_searchbib_py=reltimestr(reltime(searchbib_time))
	    if g:atp_debugTabCompletion
		let g:pat = pat
	    endif
	    let pre_completion_list=[]
	    let completion_dict=[]
	    let completion_list=[]
	    let time_bibitems_for=reltime()
	    for dict in bibitems_list
		for key in keys(dict)
		    " ToDo: change dict[key][...] to get() to not get errors
		    " if it is not present or to handle situations when it is not
		    " present!
		    call add(pre_completion_list, dict[key]['bibfield_key']) 
		    let bibkey=dict[key]['bibfield_key']
		    if stridx(bibkey, '{') != -1 && stridx(bibkey, '(') != -1
			let bibkey=substitute(strpart(bibkey,min([stridx(bibkey,'{'),stridx(bibkey,'(')])+1),',\s*','','')
		    elseif stridx(bibkey, '(') == -1
			let bibkey=substitute(strpart(bibkey,stridx(bibkey,'{')+1),',\s*','','')
		    else
			let bibkey=substitute(strpart(bibkey,stridx(bibkey,'(')+1),',\s*','','')
		    endif
		    if nchar != ',' && nchar != '}'
			let bibkey.="}"
		    endif
		    let title=get(dict[key],'title', 'notitle')
		    let title=substitute(matchstr(title,'^\s*\ctitle\s*=\s*\%("\|{\|(\)\zs.*\ze\%("\|}\|)\)\s*\%(,\|$\)'),'{\|}','','g')
		    let year=get(dict[key],'year',"")
		    let year=matchstr(year,'^\s*\cyear\s*=\s*\%("\|{\|(\)\zs.*\ze\%("\|}\|)\)\s*\%(,\|$\)')
		    let abbr=get(dict[key],'author',"noauthor")
		    let author = matchstr(abbr,'^\s*\cauthor\s*=\s*\%("\|{\|(\)\zs.*\ze\%("\|}\|)\)\s*,')
		    if abbr=="noauthor" || abbr == ""
			let abbr=get(dict[key],'editor',"")
			let author = matchstr(abbr,'^\s*\ceditor\s*=\s*\%("\|{\|(\)\zs.*\ze\%("\|}\|)\)\s*,')
		    endif
		    if len(author) >= 40
			if match(author,'\sand\s')
			    let author=strpart(author,0,match(author,'\sand\s')) . ' et al.'
			else
			    let author=strpart(author,0,40)
			endif
		    endif
		    let author=substitute(author,'{\|}','','g')
		    if dict[key]['bibfield_key'] =~? '\<article\>'
			let type="[a]"
		    elseif dict[key]['bibfield_key'] =~? '\<book\>'
			let type="[B]"
		    elseif dict[key]['bibfield_key'] =~? '\<booklet\>'
			let type="[b]"
		    elseif  dict[key]['bibfield_key'] =~? '\<\%(proceedings\|conference\)\>'
			let type="[p]"
		    elseif dict[key]['bibfield_key'] =~? '\<unpublished\>'
			let type="[u]"
		    elseif dict[key]['bibfield_key'] =~? '\<incollection\>'
			let type="[c]"
		    elseif dict[key]['bibfield_key'] =~? '\<phdthesis\>'
			let type="[PhD]"
		    elseif dict[key]['bibfield_key'] =~? '\<masterthesis\>'
			let type="[M]"
		    elseif dict[key]['bibfield_key'] =~? '\<misc\>'
			let type="[-]"
		    elseif dict[key]['bibfield_key'] =~? '\<techreport\>'
			let type="[t]"
		    elseif dict[key]['bibfield_key'] =~? '\<manual\>'
			let type="[m]"
		    else
			let type="   "
		    endif

		    let abbr=type." ".author." (".year.") "

		    call add(completion_dict, { "word" : bibkey, "menu" : title, "abbr" : abbr }) 
		endfor
	    endfor
            let g:completion_dict=completion_dict
	    for key in pre_completion_list
		call add(completion_list,substitute(strpart(key,max([stridx(key,'{'),stridx(key,'(')])+1),',\s*','',''))
	    endfor
	else
	    " add the \bibitems found in include files
	    let time_bibitems_SearchBibItems=reltime()
            let completion_dict=[]
            let dict=atplib#bibsearch#SearchBibItems()
	    let g:dict = copy(dict)
            for key in keys(dict)
		if a:expert_mode && ( key =~ '^'.begin || dict[key]['label'] =~ '^'.begin ) || 
			\ !a:expert_mode && ( key =~ begin || dict[key]['label'] =~ begin )
		    call add(completion_dict, { "word" : key, "menu" : dict[key]['rest'], "abbrev" : dict[key]['label'] })
		endif
            endfor
	    let g:time_bibitems_SearchBibItems=reltimestr(reltime(time_bibitems_SearchBibItems))
	endif
	let g:time_bibitems=reltimestr(reltime(time_bibitems))
    " {{{3 ------------ TODONOTES TODO & MISSING FIGURE OPTIONS
    elseif g:atp_completion_method == 'todo options'
	let completion_list = copy(g:atp_TodoNotes_todo_options)
    elseif g:atp_completion_method == 'missingfigure options'
	let completion_list = copy(g:atp_TodoNotes_missingfigure_options)
    endif
    " }}}3
    if exists("completion_list")
	let b:completion_list=completion_list	" DEBUG
	if g:atp_debugTabCompletion
	    call atplib#Log("TabCompletion.log", "completion_list=".string(completion_list))
	endif
    endif
    let g:time_TabCompletion_CLset = reltimestr(reltime(time))
" {{{2 make the list of matching completions
    "{{{3 --------- g:atp_completion_method = !close environments !env_close
    if g:atp_completion_method != 'close environments' && g:atp_completion_method != 'env_close'
	let completions=[]
	    " {{{4 --------- packages, package options, bibstyles, font (family, series, shapre, encoding), document class, documentclass options, environment options
	    if (g:atp_completion_method == 'package' 		||
		    \ g:atp_completion_method == 'package options'||
		    \ g:atp_completion_method == 'environment options'||
		    \ g:atp_completion_method == 'documentclass options'||
		    \ g:atp_completion_method == 'bibstyles' 	||
		    \ g:atp_completion_method =~ 'beamer\%(\|inner\|outer\|color\|font\)themes' ||
		    \ g:atp_completion_method == 'font family' 	||
		    \ g:atp_completion_method == 'font series' 	||
		    \ g:atp_completion_method == 'font shape'	||
		    \ g:atp_completion_method == 'font encoding'||
		    \ g:atp_completion_method == 'pagestyle'||
		    \ g:atp_completion_method == 'pagenumbering'||
		    \ g:atp_completion_method == 'documentclass' )
		if a:expert_mode
		    let completions	= filter(copy(completion_list),' v:val =~? "^".begin') 
		else
		    let completions	= filter(copy(completion_list),' v:val =~? begin') 
		endif
	    " {{{4 --------- environment options values, command values of values
	    elseif g:atp_completion_method == 'environment values of options' || g:atp_completion_method == 'command values of values'
		" This is essentialy done in previous step already
		let completions = completion_list
	    " {{{4 --------- command values, command optional values
	    elseif g:atp_completion_method == 'command values' || g:atp_completion_method == 'command optional values'
		if a:expert_mode
		    let completions	= filter(copy(completion_list),' v:val =~? "^".cmd_val_begin') 
		else
		    let completions	= filter(copy(completion_list),' v:val =~? cmd_val_begin') 
		endif
	    " {{{4 --------- package options values
	    elseif ( g:atp_completion_method == 'package options values' )
		if a:expert_mode
		    let completions	= filter(copy(completion_list),' v:val =~? "^".ebegin') 
		else
		    let completions	= filter(copy(completion_list),' v:val =~? ebegin') 
		endif
	    " {{{4 --------- environment names, bibfiles 
	    elseif ( g:atp_completion_method == 'environment_names'	||
			\ g:atp_completion_method == 'bibfiles' 	)
		if a:expert_mode
		    let completions	= filter(copy(completion_list),' v:val =~# "^".begin') 
		else
		    let completions	= filter(copy(completion_list),' v:val =~? begin') 
		endif
	    " {{{4 --------- colors
	    elseif g:atp_completion_method == 'tikzpicture colors'
		if a:expert_mode
		    let completions	= filter(copy(completion_list),' v:val =~# "^".color_begin') 
		else
		    let completions	= filter(copy(completion_list),' v:val =~? color_begin') 
		endif
	    " {{{4 --------- tikzpicture libraries, inputfiles 
	    " match not only in the beginning
	    elseif (g:atp_completion_method == 'tikz libraries' ||
			\ g:atp_completion_method == 'inputfiles')
		let completions	= filter(copy(completion_list),' v:val =~? begin') 
" 		if nchar != "}" && nchar != "," && g:atp_completion_method != 'inputfiles'
" 		    call map(completions,'v:val')
" 		endif
	    " {{{4 --------- Commands 
	    " must match at the beginning (but in a different way)
	    " (only in expert_mode).
	    elseif g:atp_completion_method == 'command' 
		if a:expert_mode == 1 
		    let completions	= filter(copy(completion_list),'v:val =~# "\\\\".tbegin')
		elseif a:expert_mode != 1 
		    let completions	= filter(copy(completion_list),'v:val =~? tbegin')
		endif
	    " {{{4 --------- Abbreviations
	    elseif g:atp_completion_method == 'abbreviations'
		let completions		= filter(copy(completion_list), 'v:val =~# "^" . abegin')
	    " {{{4 --------- Tikzpicture Keywords
	    elseif g:atp_completion_method == 'tikzpicture keywords' || 
			\ g:atp_completion_method == 'todo options' ||
			\ g:atp_completion_method == 'missingfigure options'
		if g:atp_completion_tikz_expertmode
		    let completions	= filter(copy(completion_list),'v:val =~# "^".tbegin') 
		else
		    let completions	= filter(copy(completion_list),'v:val =~? tbegin') 
		endif
	    " {{{4 --------- Tikzpicture Commands
	    elseif g:atp_completion_method == 'tikzpicture commands'
		if a:expert_mode == 1 
		    let completions	= filter(copy(completion_list),'v:val =~# "^".tbegin') 
		elseif a:expert_mode != 1 
		    let completions	= filter(copy(completion_list),'v:val =~? tbegin') 
		endif
	    " {{{4 --------- Labels
	    elseif g:atp_completion_method == 'labels'
		" Complete label by string or number:
		
		let aux_data	= atplib#tools#GrepAuxFile()
		let completion_dict = []
		let pattern 	= matchstr(l, '\\\%(eq\|page\|auto\|autopage\)\=ref\*\=\s*{\zs\S*$\|\\hyperref\s*\[\zs\S*$')
		for data in aux_data
		    " match label by string or number
		    if ( data[0] =~ '^' . pattern || data[1] =~ '^'. pattern ) && a:expert_mode || ( data[0] =~ pattern || data[1] =~ pattern ) && !a:expert_mode
			if l =~ '\\\%(eq\|page\|auto\|autopage\)\=ref\*\=\s*{\S*$'
			    let close = ( nchar == '}' ? '' : '}' )
			else
			    let close = ( nchar == ']' ? '' : ']' )
			endif
			call add(completion_dict, { "word" : data[0].close, "abbr" : data[0], "menu" : ( data[2] == 'equation' && data[1] != "" ? "(".data[1].")" : data[1] ) , "kind" : data[2][0] })
		    endif
		endfor 
	    " {{{4 --------- includegraphics
	    elseif g:atp_completion_method == 'includegraphics'
		let completions=copy(completion_list)
	    endif
    "{{{3 --------- else: try to close environment
    else
	call atplib#complete#CloseLastEnvironment('a', 'environment')
	let b:tc_return="1"
        let g:time_TabCompletion=reltimestr(reltime(time))
	return ''
    endif
    "{{{3 --------- SORTING and TRUNCATION
    " ToDo: we will not truncate if completion method is specific, this should be
    " made by a variable! Maybe better is to provide a positive list !!!
    if g:atp_completion_truncate && a:expert_mode && 
		\ index(['bibfiles', 'bibitems', 'bibstyles', 'font family',
		\ 'environment_names', 'environment options', 'font series', 
		\ 'font shape', 'font encoding', 'inputfiles', 'includefiles', 
		\ 'labels', 'package options', 'package options values',
		\ 'documentclass options', 'documentclass options values', 
		\ 'tikz libraries', 'command values', 'command optional values',
		\ 'command values of values', 'environment values' ], g:atp_completion_method) == -1
	call filter(completions, 'len(substitute(v:val,"^\\","","")) >= g:atp_completion_truncate')
    endif
"     THINK: about this ...
"     if g:atp_completion_method == "tikzpicture keywords"
" 	let bracket	= atplib#complete#CloseLastBracket(g:atp_bracket_dict, 1)
" 	if bracket != ""
" 	    call add(completions, bracket)
" 	endif
"     endif
    " if the list is long it is better if it is sorted, if it short it is
    " better if the more used things are at the beginning.
    if g:atp_sort_completion_list && len(completions) >= g:atp_sort_completion_list && g:atp_completion_method != 'labels'
	if g:atp_completion_method == 'abbreviations'
	    let completions=sort(completions, "atplib#CompareStarAfter")
	else
	    let completions=sort(completions)
	endif
    endif
    " DEBUG
    let b:completions=completions 
   " {{{2 COMPLETE 
    call cursor(pos_saved[1], pos_saved[2])
    " {{{3 package, tikz libraries, environment_names, colors, bibfiles, bibstyles, documentclass, font family, font series, font shape font encoding, input files, includegraphics
    if
		\ g:atp_completion_method == 'package' 	|| 
		\ g:atp_completion_method == 'environment options' ||
		\ g:atp_completion_method == 'environment_names' ||
		\ g:atp_completion_method == 'tikz libraries' || 
		\ g:atp_completion_method == 'pagestyle'	||
		\ g:atp_completion_method == 'pagenumbering'	||
		\ g:atp_completion_method == 'bibfiles' 	|| 
		\ g:atp_completion_method == 'bibstyles' 	|| 
		\ g:atp_completion_method == 'documentclass'  || 
		\ g:atp_completion_method == 'font family'  	||
		\ g:atp_completion_method == 'font series'  	||
		\ g:atp_completion_method == 'font shape'   	||
		\ g:atp_completion_method == 'font encoding'	||
		\ g:atp_completion_method == 'todo options' 	||
		\ g:atp_completion_method == 'missingfigure options' ||
		\ g:atp_completion_method == 'inputfiles' 	||
		\ g:atp_completion_method == 'includegraphics' 
	let column = nr+2
	call complete(column,completions)
    "{{{3 abbreviations
    elseif g:atp_completion_method == 'abbreviations'
	let col=match(l, '^.*\zs=')+1
	call complete(col, completions)
	let column=col
    "{{{3 labels
    elseif g:atp_completion_method == 'labels'
	let col=match(l, '\\\(eq\|page\|auto\|autopage\)\=ref\*\=\s*{\zs\S*$\|\\hyperref\s*\[\zs\S*$')+1
	call complete(col, completion_dict)
	let column=col
	return ''
    " {{{3 bibitems
    elseif !normal_mode && g:atp_completion_method == 'bibitems'
        if exists("completion_dict")
            " for bibtex, biblatex
            call complete(col+1,completion_dict)
	    let column=col+1
        else
            " for thebibliography environment
            call complete(col+1,completion_list)
	    let column=col+1
        endif
    " {{{3 commands, tikzcpicture commands
    elseif !normal_mode && (g:atp_completion_method == 'command' || g:atp_completion_method == 'tikzpicture commands')
	" We are not completing greek letters, but we add them if cbegin is
	" one. 
	call extend(completion_list, g:atp_greek_letters)
	if count(completion_list, cbegin) >= 1
	    " Add here brackets - somebody might want to
	    " close a bracket after \nu and not get \numberwithin{ (which is
	    " rarely used).
	    let b:comp_method = "brackets in commands"
	    if (!normal_mode &&  index(g:atp_completion_active_modes, 'brackets') != -1 ) ||
		    \ (normal_mode && index(g:atp_completion_active_modes_normal_mode, 'brackets') != -1 )
		let bracket=atplib#complete#GetBracket(append, g:atp_bracket_dict)
		if bracket != "0" && bracket != ""
		    let completions = extend([cbegin.bracket], completions)
		endif
	    endif
	    call add(completions, cbegin)
	endif
	call complete(o+1,completions)
	let column=o+1
    " {{{3 tikzpicture keywords
    elseif !normal_mode && (g:atp_completion_method == 'tikzpicture keywords')
	let t=match(l,'\zs\<\w*$')
	" in case '\zs\<\w*$ is empty
	if t == -1
	    let t=col(".")
	endif
	call complete(t+1,completions)
	let column=t+1
	let b:tc_return="tikzpicture keywords"
    " {{{3 tikzpicture colors
    elseif !normal_mode && (g:atp_completion_method == 'tikzpicture colors')
	call complete(color_nr+2, completions)
	let column=color_nr+2
    " {{{3 package and document class options
    elseif !normal_mode && ( g:atp_completion_method == 'package options' || g:atp_completion_method == 'documentclass options' 
		\ || g:atp_completion_method == 'environment options' )
	let col=len(matchstr(l,'^.*\\\%(documentclass\|usepackage\)\[.*,\ze'))
	if col==0
	    let col=len(matchstr(l,'^.*\\\%(documentclass\|usepackage\)\[\ze'))
	endif
	call complete(col+1, completions)
	let column = col+1
    " {{{3 command values
    elseif  !normal_mode && ( g:atp_completion_method == 'command values' || g:atp_completion_method == 'command optional values' )
	let col = len(l)-len(cmd_val_begin)
	call complete(col+1, completions)
	let column = col+1
    " {{{3 package and document class options values
    elseif !normal_mode && (g:atp_completion_method == 'package options values')
	let col=len(matchstr(l,'\\\%(documentclass\|usepackage\)\[.*=\%({[^}]*,\|{\)\?\ze'))
	if col==0
	    let col=len(matchstr(l,'\\\%(documentclass\|usepackage\)\[\ze'))
	endif
	call complete(col+1, completions)
	let column = col+1
    "{{{3 environment options values
    elseif !normal_mode && (g:atp_completion_method == 'environment values of options')
	let col=len(matchstr(l, '.*\\begin\s*{[^}]*}\[.*=\%({[^}]*,\|{\)\?\ze'))
	let column = col+1
	call complete(column, completions)
    elseif !normal_mode && (g:atp_completion_method == 'command values of values')
	let col=len(matchstr(l, '.*\\\w\+{\%([^}]*,\)\?[^,}=]*='.cvov_ignore_pattern.'\ze'))
	let column = col+1
	call complete(column, completions)
    else
	let column = col(".")
    endif
    " If the completion method was a command (probably in a math mode) and
    " there was no completion, check if environments are closed.
    " {{{3 Final call of CloseLastEnvrionment / CloseLastBracket
    let len=len(completions)
    let matched_word = strpart(getline(line(".")), column-1, pos_saved[2]-column)
    if len == 0 && (!count(['package', 'bibfiles', 'bibstyles', 'inputfiles'], g:atp_completion_method) || a:expert_mode == 1 ) || len == 1
	let b:comp_method .= " final"
	if count(['command', 'tikzpicture commands', 'tikzpicture keywords', 'command values'], g:atp_completion_method) && 
	    \ (len == 0 || len == 1 && completions[0] =~ '^\\\='. begin . '$' )

	    let filter 		= 'strpart(getline("."), 0, col(".") - 1) =~ ''\\\@<!%'''
	    let stopline 	= search('^\s*$\|\\par\>', 'bnW')

	    " Check Brackets 
	    let b:comp_method   .= " brackets: 1"
	    let cl_return 	= atplib#complete#GetBracket(append, g:atp_bracket_dict)

	    " If the bracket was closed return.
	    if cl_return != "0"
	        let g:time_TabCompletion=reltimestr(reltime(time))
		return cl_return
	    endif

	    " Check inline math:
	    if !has("python") && (atplib#complete#CheckClosed_math('texMathZoneV') || 
			\ atplib#complete#CheckClosed_math('texMathZoneW') ||
			\ atplib#complete#CheckClosed_math('texMathZoneX') ||
			\ b:atp_TexFlavor == 'plaintex' && atplib#complete#CheckClosed_math('texMathZoneY'))
		let zone = 'texMathZoneVWXY' 	" DEBUG
		call atplib#complete#CloseLastEnvironment(append, 'math')

	    " Check environments:
	    else
		let env_opened= searchpairpos('\\begin','','\\end','bnW','searchpair("\\\\begin{".matchstr(getline("."),"\\\\begin{\\zs[^}]*\\ze}"),"","\\\\end{".matchstr(getline("."),"\\\\begin{\\zs[^}]*\\ze}"),"nW")',max([1,(line(".")-g:atp_completion_limits[2])]))
		let env_name 	= matchstr(strpart(getline(env_opened[0]), env_opened[1]-1), '\\begin\s*{\zs[^}]*\ze}')
		let zone	= env_name 	" DEBUG
		if env_opened != [0, 0]
		    call atplib#complete#CloseLastEnvironment('a', 'environment', env_name, env_opened)
		endif
	    endif
	    " DEBUG
	    if exists("zone")
		let b:tc_return =" close_env end " . zone
		let b:comp_method.=' close_env end ' . zone
		if g:atp_debugTabCompletion
		    call atplib#Log("TabCompletion.log", "b:comp_method.=".b:comp_method)
		endif
	    else
		let b:tc_return=" close_env end"
		let b:comp_method.=' close_env end'
		if g:atp_debugTabCompletion
		    call atplib#Log("TabCompletion.log", "b:comp_method=".b:comp_method)
		endif
	    endif
	elseif len == 0 && 
		    \ g:atp_completion_method != 'labels' && 
		    \ g:atp_completion_method != 'bibitems' 
		    \ || len == 1 && get(completions, 0, "") == matched_word || 
		    \ g:atp_completion_method != 'brackets' &&
		    \ g:atp_completion_method != 'labels' &&
		    \ g:atp_completion_method != 'bibitems' &&
		    \ g:atp_completion_method != 'bibfiles' &&
		    \ g:atp_completion_method != 'close environments' &&
		    \ g:atp_completion_method != 'algorithmic' &&
		    \ g:atp_completion_method != 'abbreviations' &&
		    \ g:atp_completion_method != 'command' &&
		    \ g:atp_completion_method != 'command values' &&
		    \ g:atp_completion_method != 'tikzpicture' &&
		    \ g:atp_completion_method != 'tikzpicture commands' &&
		    \ g:atp_completion_method != 'tikzpicture keywords' &&
		    \ g:atp_completion_method != 'package options' &&
		    \ g:atp_completion_method != 'documentclass' &&
		    \ g:atp_completion_method != 'documentclass options' &&
		    \ g:atp_completion_method != 'environment_names' &&
		    \ g:atp_completion_method != 'environment options' &&
		    \ g:atp_completion_method != 'todo options' &&
		    \ g:atp_completion_method != 'missingfigure options'
" 	elseif g:atp_completion_method == 'package' || 
" 		    \  g:atp_completion_method == 'environment_names' || 
" 		    \  g:atp_completion_method == 'font encoding' || 
" 		    \  g:atp_completion_method == 'font family' || 
" 		    \  g:atp_completion_method == 'font series' || 
" 		    \  g:atp_completion_method == 'font shape' || 
" 		    \  g:atp_completion_method == 'bibstyles' || 
" 		    \ g:atp_completion_method == 'bibfiles'
	    let b:tc_return='close_bracket end'
	    let b:comp_method .= " brackets: 2"
	    let g:time_TabCompletion=reltimestr(reltime(time))
	    return atplib#complete#GetBracket(append, g:atp_bracket_dict)
	endif
    endif
    "}}}3
    let g:time_TabCompletion=reltimestr(reltime(time))
    return ''
    "}}}2
endfunction
catch /E127:/
endtry
" }}}1
" vim:fdm=marker:ff=unix:noet:ts=8:sw=4:fdc=1
