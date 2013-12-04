" Language:	latex, tex
" Author:	Johannes Zellner <johannes [at] zellner [dot] org>
" Modified By:  Marcin Szamotulski <mszamot [at] gmail [dot] com>

if exists("g:atp_folding") && !g:atp_folding
    finish
endif

" [-- local settings --]
setlocal foldexpr=TexFold(v:lnum)
setlocal foldtext=TexFoldText()

" [-- avoid multiple sourcing --]
if exists("*TexFold")
    setlocal foldmethod=expr
    finish
endif

" [-- ATP options --]
if !exists("g:atp_fold_environments")
    " List of environments to fold
    let g:atp_fold_environments = []
endif

let s:class = atplib#search#DocumentClass(atplib#FullPath(b:atp_MainFile))
let s:part = 0
fun! TexFoldContextWithDepth(line)
    if s:class =~ '\(ams\)\=art\(icle\)\=$'
	if a:line =~ '\\section\>'		| return 1
	elseif a:line =~ '\\subsection\>'	| return 2
	elseif a:line =~ '\\subsubsection\>'	| return 3
	elseif a:line =~ '\\paragraph\>'	| return 4
	elseif a:line =~ '\\subparagraph\>'	| return 5
	else					| return 0
	endif
    else
	" fold parts only if s:part is set (by TexFold)
	if s:part
	    if a:line =~ '\\part\>'			| return 1
	    elseif a:line =~ '\\chapter\>'		| return 2
	    elseif a:line =~ '\\section\>'		| return 3
	    elseif a:line =~ '\\subsection\>'		| return 4
	    elseif a:line =~ '\\subsubsection\>'	| return 5
	    elseif a:line =~ '\\paragraph\>'		| return 6
	    elseif a:line =~ '\\subparagraph\>'		| return 7
	    else					| return 0
	    endif
	else
	    if a:line =~ '\\chapter\>'			| return 1
	    elseif a:line =~ '\\section\>'		| return 2
	    elseif a:line =~ '\\subsection\>'		| return 3
	    elseif a:line =~ '\\subsubsection\>'	| return 4
	    elseif a:line =~ '\\paragraph\>'		| return 5
	    elseif a:line =~ '\\subparagraph\>'		| return 6
	    else					| return 0
	    endif
	endif
    endif
endfun

fun! TexFoldContextFlat(line)
    if a:line =~ '\\\(part\|chapter\|\(sub\)\+section\|\(sub\)\=paragraph\)\>'
	return 1
    else
	return 0
    endif
endfun

fun! TexFold(lnum)
    " remove comments
    let line = substitute(getline(a:lnum), '\(^%\|\s*[^\\]%\).*$', '', 'g')
    if line =~ '\\part'
	let s:part=1
    endif
    if a:lnum > 0
	let pline = getline(a:lnum-1)
    else
	let pline = ''
    endif
    " let level = TexFoldContextFlat(line)
    let level = TexFoldContextWithDepth(line)
    if level
	exe 'return ">'.level.'"'
    elseif a:lnum == 1
	return ">1"
    elseif getline(a:lnum) =~ '^[^%]*\\begin\s*{\s*document\s*}'
	return '>0'
    elseif line =~ '^[^%]*\\begin\>.*' && !empty(g:atp_fold_environments)
	if index(g:atp_fold_environments, '_all_') != -1
	    return 'a1'
	else
	    let env_name = matchstr(line, '\\begin\s*{\s*\zs[^}]*\ze\s*}')
	    if index(g:atp_fold_environments, env_name) != -1
		return 'a1'
	    else
		return '='
	    endif
	endif
    elseif line =~ '^[^%]*\\end\>.*' && !empty(g:atp_fold_environments)
	if index(g:atp_fold_environments, '_all_') != -1
	    return 's1'
	else
	    let env_name = matchstr(line, '^.*\\end\s*{\s*\zs[^}]*\ze\s*}')
	    if index(g:atp_fold_environments, env_name) != -1
		return 's1'
	    else
		return '='
	    endif
	endif
    " Fold comments which are longer than two lines:
    elseif getline(a:lnum) =~ '^\s*%' && getline(a:lnum+1) =~ '^\s*%' && getline(a:lnum-1) !~ '^\s*%'
	return 'a1'
    elseif getline(a:lnum) =~ '^\s*%' && getline(a:lnum+1) !~ '^\s*%' && getline(a:lnum-1) =~ '^\s*%'
	return 's1'
    elseif getline(a:lnum) =~ '^[^%]*\\mainmatter'
	return '>0'
    else
	return '='
    endif
endfun

" [-- trigger indention --]
setlocal foldmethod=expr

" [-- foldtext --]
fun! TexFoldText()
    let line = getline(v:foldstart)
    if line =~ '^\s*$'
	let foldstart = searchpos('\S', 'nW')[0]
	let line = getline(foldstart)
    endif
    let foldlen = "lines: ".(v:foldend-v:foldstart)."  "
    let test=1
    if line =~ '^[^%]*\\begin\s*{[^}]*}[^}]*'
	let envname = matchstr(line, '^.*\\begin\s*{\s*\zs[^}]*')
	let foldtext = v:folddashes."env: ".envname
	let space = repeat(" ", max([1,12-len(envname)]))
	if line =~ '\\label'
	    let foldtext.=space." label: ".matchstr(line, '\\label\s*{\s*\zs[^}]*')
	elseif line =~ '\\begin\s*{\s*[^}]*}\s*\[\s*\zs[^\]]*'
	    let foldtext.=space." title: ".matchstr(line, '\\begin\s*{\s*[^}]*}\s*\[\s*\zs.*\s*\]')
	endif
    elseif line =~ '^\s*%'
	if line =~ '^\s*%\s*\%(todo\>\|.\{0,5}\\todo\>\)'
	    let foldtext = v:folddashes."todo"
	else
	    let foldtext = v:folddashes."comment"
	endif
    elseif line =~ '\\section'
	let title = matchstr(line, '\\section\*\=\s*\[\zs.*\ze\s*\]')
	if empty(title)
	    let title = matchstr(line, '\\section\*\=\%(\s*\[.*\]\)\=\s*{\s*\zs.\{-}\ze\s*}')
	endif
	let foldtext = v:folddashes."section: ".title
    elseif line =~ '\\chapter'
	let title = matchstr(line, '\\chapter\*\=\s*\[\zs.*\ze\s*\]')
	if empty(title)
	    let title = matchstr(line, '\\chapter\*\=\%(\s*\[.*\]\)\=\s*{\s*\zs.\{-}\ze\s*}')
	endif
	let foldtext = v:folddashes."chapter: ".title
    elseif line =~ '\\subsection'
	let title = matchstr(line, '\\subsection\*\=\s*\[\zs.*\ze\s*\]')
	if empty(title)
	    let title = matchstr(line, '\\subsection\*\=\%(\s*\[.*\]\)\=\s*{\s*\zs.\{-}\ze\s*}')
	endif
	let foldtext = v:folddashes."subsection: ".title
    elseif line =~ '\\paragraph'
	let title = matchstr(line, '\\paragraph\*\=\s*\[\zs.*\ze\s*\]')
	if empty(title)
	    let title = matchstr(line, '\\paragraph\*\=\%(\s*\[.*\]\)\=\s*{\s*\zs.\{-}\ze\s*}')
	endif
	let foldtext = v:folddashes."paragraph ".title
    elseif line =~ '\\part'
	let title = matchstr(line, '\\part\*\=\s*\[\zs.*\ze\s*\]')
	if empty(title)
	    let title = matchstr(line, '\\part\*\=\%(\s*\[.*\]\)\=\s*{\s*\zs.\{-}\ze\s*}')
	endif
	let foldtext = v:folddashes."part: ".title
    elseif line =~ '\\subparagraph'
	let title = matchstr(line, '\\subparagraph\*\=\s*\[\zs.*\ze\s*\]')
	if empty(title)
	    let title = matchstr(line, '\\subparagraph\*\=\%(\s*\[.*\]\)\=\s*{\s*\zs.\{-}\ze\s*}')
	endif
	let foldtext = v:folddashes."subparagraph ".title
    elseif line =~ '\\documentclass'
	let foldtext = v:folddashes."preamble: ".matchstr(line,  '\\documentclass\%(\s*\[[^\]]*\]*\)\=\s*{\s*\zs[^}]*').".cls"
    else
	let test=0
	let foldtext = foldtext()
    endif
    if test
	let x=&columns-len(foldlen)
	let foldtext.=repeat(" ",max([2,x-len(foldtext)])).foldlen
    endif
    return foldtext
endfun

" vim:ts=8
