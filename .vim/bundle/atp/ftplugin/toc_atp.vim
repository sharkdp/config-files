" Vim filetype plugin file
" Language:    tex
" Maintainer:  Marcin Szamotulski
" Last Change: Tue Dec 11, 2012 at 18:53:41  +0000
" Note:	       This file is a part of Automatic Tex Plugin for Vim.

" if exists("b:did_ftplugin") | finish | endif
let b:did_ftplugin = 1

function! ATP_TOC_StatusLine() " {{{
    return ( expand("%:t") == "__ToC__" ? "Table of Contents" : 
		\ ( expand("%:t") == "__Labels__" ? "List of Labels" : "" ) )
endfunction
setlocal statusline=%{ATP_TOC_StatusLine()}
" }}}

" {{{ <SID>GetLineNr(...)
" a:1 	line number to get, if not given the current line
" a:2	0/1 	0 (default) return linenr as for toc/labels
function! <SID>GetLineNr(...)
    let line 	=  a:0 >= 1 ? a:1 : line('.')
    let labels 	=  a:0 >= 2 ? a:2 : expand("%") == "__Labels__" ? 1 : 0

    if labels == 0
	return get(b:atp_Toc, line, ["", ""])[0:1]
    else
	return get(b:atp_Labels, line, ["", ""])[0:1]
    endif
endfunction
" command! -buffer GetLine :echo <SID>GetLineNr(line("."))
"}}}

function! s:getsectionnr(...) "{{{
    let line =  a:0 == 0 ? getline('.') : getline(a:1)
    return matchstr(l:line,'^\s*\d\+\s\+\zs\%(\d\|\.\)\+\ze\D')
endfunction
"}}}

" {{{1 s:gotowinnr
"---------------------------------------------------------------------
" Notes:
" 		(1) choose window with matching buffer name
" 		(2) choose among those which were edited last
" Solution:
"        			       +-N-> choose this window
"			 	       |
"			     +-N-> ----+
"			     | 	       |
" -go from where you come-->-+         +-Y-> choose that window		     
"  			     |	       Does there exist another open window  
"			     |	       with the right buffer name?           
"			     |	
"  			     +-Y-> use this window
"			   Does the window have
"			   a correct name?
"
" This function returns the window number to which we will eventually go.
function! s:gotowinnr()
    let labels_window	= ( expand("%") == "__Labels__" ? 1 : 0 )

    " This is the line number to which we will go.
    let [ l:bufname, l:nr ] =atplib#tools#getlinenr(line("."), labels_window)

    if labels_window
	" Find labels window to go in Labels window
	let l:gotowinnr=bufwinnr(l:bufname)
    else
	if t:atp_bufname == l:bufname
	    " if t:atp_bufname agree with that found in ToC
	    " if the t:atp_winnr is still open
	    let l:gotowinnr=bufwinnr(l:bufname)
	else
	    if bufwinnr("^" . l:bufname . "$") != 0
		" if not but there is a window with buffer l:bufname
		let l:gotowinnr=bufwinnr("^" . l:bufname . "$")
	    else
		" if not and there is no window with buffer l:bufname
		let l:gotowinnr=t:atp_winnr
	    endif
	endif
    endif

    return l:gotowinnr
endif
endfunction
command! -buffer GotoWinNr	:echo s:gotowinnr()
" }}}1

function! GotoLine(closebuffer) "{{{
    let labels_window	= expand("%") == "__Labels__" ? 1 : 0
    
    " if under help lines do nothing:
    let toc		= getbufline("%",1,"$")
    let h_line		= index(reverse(copy(toc)),'')+1
    if line(".") > len(toc)-h_line
	return ''
    endif

    " remember the ToC window number
    let tocbufnr= bufnr("")

    " line to go to
    let [file,nr] = atplib#tools#getlinenr(line("."), labels_window)

    " window to go to
    let gotowinnr= s:gotowinnr()

    if gotowinnr != -1
 	exe gotowinnr . " wincmd w"
	if fnamemodify(file, ":p") != fnamemodify(bufname("%"), ":p")
	    exe "e " . fnameescape(file)
	endif
    else
 	exe "wincmd w"
	exe "e " . fnameescape(file)
    endif
	
    "if we were asked to close the window
    if a:closebuffer == 1
        exe "silent! bdelete " . tocbufnr
    endif

    "finally, set the position
    call setpos("''", getpos("."))
    call setpos('.', [0, nr, 1, 0])
    exe "normal zt"
endfunction
" }}}

function! <SID>yank(arg, ...) " {{{
    let time = reltime()
    let labels_window	= expand("%") == "__Labels__" ? 1 : 0
    let register	= ( a:0 >= 1 ? a:1 : v:register )

    let l:toc=getbufline("%",1,"$")
    let l:h_line=index(reverse(copy(l:toc)),'')+1
    if line(".") > len(l:toc)-l:h_line
	return ''
    endif

    let l:cbufnr=bufnr("")
    let [ file_name, line_nr ] = atplib#tools#getlinenr(line("."), labels_window)

    if !labels_window
	if !exists("t:atp_labels") || index(keys(t:atp_labels), file_name) == -1
	    " set t:atp_labels variable
            if g:atp_python_toc
                call atplib#tools#generatelabels(get(b:atp_Toc, line("."), ["", "", ""])[2], 0)
            else
                call atplib#tools#generatelabels(getbufvar(file_name, 'atp_MainFile'), 0)
            endif
	endif

	let choice	= get(get(filter(get(deepcopy(t:atp_labels), file_name, []), 'v:val[0] ==  line_nr'), 0, []), 1 , 'nokey')
    else
        if exists("t:atp_labels")
	    let choice_list	= filter(get(deepcopy(t:atp_labels), file_name, []), "v:val[0] == line_nr" )
	    " There should be just one element in the choice list
	    " unless there are two labels in the same line.
	    let choice	= choice_list[0][1]
	else
	    let choice	= "nokey"
	endif
    endif

    if choice	== "nokey"
	" in TOC, if there is a key we will give it back if not:
	au! CursorHold __ToC__
	echomsg "[ATP:] there is no key."
	sleep 750m
	au CursorHold __ToC__ :call EchoLine()
	return ""
    else
	if a:arg == '@'
	    silent if register == 'a'
		let @a=choice
	    elseif register == 'b'
		let @b=choice
	    elseif register == 'c'
		let @c=choice
	    elseif register == 'd'
		let @d=choice
	    elseif register == 'e'
		let @e=choice
	    elseif register == 'f'
		let @f=choice
	    elseif register == 'g'
		let @g=choice
	    elseif register == 'h'
		let @h=choice
	    elseif register == 'i'
		let @i=choice
	    elseif register == 'j'
		let @j=choice
	    elseif register == 'k'
		let @k=choice
	    elseif register == 'l'
		let @l=choice
	    elseif register == 'm'
		let @m=choice
	    elseif register == 'n'
		let @n=choice
	    elseif register == 'o'
		let @o=choice
	    elseif register == 'p'
		let @p=choice
	    elseif register == 'q'
		let @q=choice
	    elseif register == 'r'
		let @r=choice
	    elseif register == 's'
		let @s=choice
	    elseif register == 't'
		let @t=choice
	    elseif register == 'u'
		let @u=choice
	    elseif register == 'v'
		let @v=choice
	    elseif register == 'w'
		let @w=choice
	    elseif register == 'x'
		let @x=choice
	    elseif register == 'y'
		let @y=choice
	    elseif register == 'z'
		let @z=choice
	    elseif register == '*'
		let @-=choice
	    elseif register == '+'
		let @+=choice
	    elseif register == '-'
		let @@=choice
	    endif
	elseif a:arg == 'p'

	    let l:gotowinnr=s:gotowinnr()
	    exe l:gotowinnr . " wincmd w"

	    " delete the buffer
" 	    exe "bdelete " . l:cbufnr

	    " set the line
	    let l:line=getline('.')
	    let l:colpos=getpos('.')[2]
	    if a:arg ==# 'p'
		let l:bline=strpart(l:line, 0, l:colpos)
		let l:eline=strpart(l:line, l:colpos)
	    else
		let l:bline=strpart(l:line, 0, l:colpos-1)
		let l:eline=strpart(l:line, l:colpos-1)
	    endif
	    call setline('.',l:bline . choice . l:eline)
	    call setpos('.',[getpos('.')[0],getpos('.')[1],getpos('.')[2]+len(choice),getpos('.')[3]])
	endif
    endif
    let g:time_yank=reltimestr(reltime(time))
endfunction
command! -buffer P :call Yank("p")
" }}}

if !exists("*YankToReg")
function! YankToReg()
    call <SID>yank("@", v:register)
endfunction
endif

if !exists("*Paste")
function! Paste()
    call <SID>yank("p")
endfunction
endif

" Show Label Context 
" {{{1 ShowLabelContext
if !exists("*ShowLabelContext")
function! ShowLabelContext(height)
    let labels_window	= ( expand("%:t") == "__Labels__" ? 1 : 0 )

    let toc	= getbufline("%",1,"$")
    let h_line	= index(reverse(copy(toc)),'')+1
    if line(".") > len(toc)-h_line
	return ''
    endif

    let cbuf_name	= bufname('%')
    let [buf_name, line] = atplib#tools#getlinenr(line("."), labels_window)
    wincmd w
    let buf_nr		= bufnr("^" . buf_name . "$")
    let height		= ( !a:height ? "" : a:height )
    " Note: using split without argument is faster than split #{bufnr} or 
    " split {bufname}.
    if buf_nr == bufnr("%")
	let splitcmd = height."split"
    elseif buf_nr != -1
	let splitcmd = height."split #" . buf_nr
    else
	let splitcmd = height."split " . buf_name
    endif
    silent exe splitcmd
    call setpos('.', [0, line, 1, 0])
    if !labels_window
	exe "normal! zt"
    endif
endfunction
endif
" }}}1
" Echo line
" {{{1 EchoLine
if !exists("*EchoLine")
function! EchoLine()
    " Note: only shows the line of loaded buffers (loading buffer takes some
    " time)

    " If we are not on a toc/label line 
    " return
    if atplib#tools#getlinenr(line(".")) == ['', '']
	return 0
    endif

    let labels_window	= expand("%") == "__Labels__" ? 1 : 0

    let toc		= getbufline("%",1,"$")
    let h_line		= index(reverse(copy(toc)),'')+1
"     if line(".") > len(toc)-h_line
" 	return 0
"     endif

    let [buf_name,line] = atplib#tools#getlinenr(line("."), labels_window)
    let buf_nr		= bufnr("^" . buf_name . "$")
    if labels_window && !exists("t:atp_labels")
	let t:atp_labels[buf_name]	= UpdateLabels(buf_name)[buf_name]
    endif
    if buf_nr != -1
	let sec_line	= get(getbufline(buf_name,line),0,"")
    else
	let sec_line	= get(readfile(buf_name),line-1,"")
    endif
    let i 		= 1
    while sec_line	!~ '\\\%(\%(sub\)\?paragraph\|\%(sub\)\{0,2}section\|chapter\|part\)\s*{.*}' && i <= 20
	let sec_line	= substitute(sec_line, '\s*$', '', '') . substitute(join(getbufline(buf_name, line+i)), '^\s*', ' ', '')
	let i 		+= 1
    endwhile
    let sec_type	= ""

    if sec_line =~ '\\subparagraph[^\*]'
	let sec_type="subparagraph  "
    elseif sec_line =~ '\\subparagraph\*'
	let sec_type="subparagraph* "
    elseif sec_line =~ '\\paragraph[^\*]'
	let sec_type="paragraph     "
    elseif sec_line =~ '\\paragraph\*'
	let sec_type="paragraph*    "
    elseif sec_line =~ '\\subsubsection[^\*]'
	let sec_type="subsubsection "
    elseif sec_line =~ '\\subsubsection\*'
	let sec_type="subsubsection*"
    elseif sec_line =~ '\\subsection[^\*]'
	let sec_type="subsection    "
    elseif sec_line =~ '\\subsection\*'
	let sec_type="subsection*   "
    elseif sec_line =~ '\\section[^\*]'
	let sec_type="section       "
    elseif sec_line =~ '\\section\*'
	let sec_type="section*      "
    elseif sec_line =~ '\\chapter[^\*]'
	let sec_type="chapter       "
    elseif sec_line =~ '\\chapter\*'
	let sec_type="chapter*      "
    elseif sec_line =~ '\\part[^\*]'
	let sec_type="part          "
    elseif sec_line =~ '\\part\*'
	let sec_type="part*         "
    elseif sec_line =~ '\\bibliography'
	let sec_type="bibliography  "
    elseif sec_line =~ '\\abstract\|\\begin\s*{\s*abstract\s*}'
	let sec_type="abstract      "
    elseif sec_line =~ '\\documentclass'
	let sec_type="preambule     "
    endif
    let sec_type = toupper(sec_type)
    if expand("%") == "__Labels__"
	let sec_type="TYPE " 
    endif

    let label		= matchstr(sec_line,'\\label\s*{\zs[^}]*\ze}')
    try
        let section	= matchstr(sec_line, '{\zs\%([^{}]*\|{\%([^{}]\|{[^{}]*}\)*}\)*\ze}')
    catch /E363/
        let section     = sec_line
    endtry
    if section != "" && label != ""
	echo sec_type . " : '" . section . "'\t label : " . label
    elseif section != ""
	echo sec_type . " : '" . section . "'"
    else
	echo ""
    endif
    return 1
endfunction
endif
setl updatetime=200 
augroup ATP_TOC
    au!
    au CursorHold __ToC__ :call EchoLine()
augroup END
"}}}1

" Compare Numbers Function {{{1
function! s:CompareNumbers(i1, i2)
    return str2nr(a:i1) == str2nr(a:i2) ? 0 : str2nr(a:i1) > str2nr(a:i2) ? 1 : -1
endfunction "}}}1

" YankSection, DeleteSection, PasteSection, SectionStack, Undo.
" {{{1
" Stack of sections that were removed but not yet paste
" each entry is a list [ section title , list of deleted lines, section_nr ]
" where the section title is the one from t:atp_toc[filename][2]
" section_nr is the section number before deletion
" the recent positions are put in the front of the list
if expand("%") == "__ToC__" &&
	    \ ( !g:atp_python_toc || g:atp_devversion )
    if !exists("t:atp_SectionStack")
	let t:atp_SectionStack 	= []
    endif

    function! <SID>SectionScope()
	" Return [ file, begin_line, end_line, title, type, section_nr, bibliography ] or ['', '', '', '', '', '', '']  if error.

	" Get the name and path of the file
	" to operato on
	let [file_name,begin_line]	= atplib#tools#getlinenr()
	let section_nr			= s:getsectionnr()
	if g:atp_python_toc
	    let main_file	= get(b:atp_Toc, line("."), ["", "", ""])[2]
	    let toc		= deepcopy(t:atp_pytoc[main_file]) 
	    let type		= ""
	    let toc_entry	= ['', '', '', '', '', '', ''] 
	    let ind		= 0
	    for toc_entry in toc
		if toc_entry[0:1] == [file_name, begin_line]
		    let type	= toc_entry[2]
		    break
		endif
		let ind+=1
	    endfor
	else
	    let toc		= deepcopy(t:atp_toc[file_name]) 
	    let type		= toc[begin_line][0]
	endif

	" Only some types are supported:
	if index(['bibliography', 'subsubsection', 'subsection', 'section', 'chapter', 'part'], type) == -1
	    echo "Section type: " . type . " is not supported"
	    sleep 750m
	    return ['', '', '', '', '', '', '']
	endif

	" Find the end of the section:
	" part 		is ended by part
	" chapter		is ended by part or chapter
	" section		is ended by part or chapter or section
	" and so on,
	" bibliography 	is ended by like subsubsection.
	if type == 'part'
	    let type_pattern = 'part\|bibliography'
	elseif type == 'chapter'
	    let type_pattern = 'chapter\|part\|bibliography'
	elseif type == 'section'
	    let type_pattern = '\%(sub\)\@<!section\|chapter\|part\|bibliography'
	elseif type == 'subsection'
	    let type_pattern = '\%(sub\)\@<!\%(sub\)\=section\|chapter\|part\|bibliography'
	elseif type == 'subsubsection' || type == 'bibliography'
	    let type_pattern = '\%(sub\)*section\|chapter\|part\|bibliography'
	endif
	if g:atp_python_toc
	    let title	= toc_entry[3]
	    let toc	= toc[ind+1:]
	    " We will search for end line only in the same file:
	    call filter(toc, "v:val[0] == file_name")
	else
	    let title		= toc[begin_line][2]
	    call filter(toc, 'str2nr(v:key) > str2nr(begin_line)')
	endif
	let end_line 		= -1
	let bibliography	=  0

	if g:atp_python_toc
	    for toc_e in toc
		if toc_e[2] =~ type_pattern
		    let end_line = toc_e[1]-1
		    if toc_e[2] =~ 'bibliography'
			let bibliography = 1
		    endif
		    break
		endif
	    endfor
	else
	    for line in sort(keys(toc), "s:CompareNumbers")
		if toc[line][0] =~ type_pattern
		    let end_line = line-1
		    if toc[line][0] =~ 'bibliography'
			let bibliography = 1
		    endif
		    break
		endif
	    endfor
	endif

	if end_line == -1 && &l:filetype == "plaintex"
	    " TODO:
	    echomsg "[ATP:] can not yank last section in plain tex files :/"
	    sleep 750m
	    return ['', '', '', '', '', '', '']
	endif
	return [ file_name, begin_line, end_line, title, type, section_nr, bibliography]
    endfunction

    function! <SID>YankSection(...)

	let register = ( a:0 >= 1 ? '"'.a:1 : '' ) 

	" if under help lines do nothing:
	let toc_line	= getbufline("%",1,"$")
	let h_line	= index(reverse(copy(toc_line)),'')+1
	if line(".") > len(toc_line)-h_line
	    return ''
	endif

	let s:deleted_section = toc_line

	let [file_name, begin_line, end_line, title, type, section_nr, bibliography] = <SID>SectionScope()
	if [file_name, begin_line, end_line, title, type, section_nr, bibliography] == ['', '', '', '', '', '']
	    return
	endif

	" Window to go to
	let toc_winnr	= winnr()
	let gotowinnr	= s:gotowinnr()

	if gotowinnr != -1
	    exe gotowinnr . " wincmd w"
	    let winview	= winsaveview()
	    let bufnr = bufnr("%")
	else
" 	    exe gotowinnr . " wincmd w"
	    exe "wincmd w"
	    let bufnr = bufnr("%")
	    let winview	= winsaveview()
	    exe "e " . fnameescape(file_name)
	endif
	    
	"Finally, set the position:
	keepjumps call setpos('.',[0,begin_line,1,0])
	normal! V
	if end_line != -1 && !bibliography
	    keepjumps call setpos('.',[0, end_line, 1, 0])
	elseif bibliography
	    keepjumps call setpos('.',[0, end_line, 1, 0])
	    let end_line 	= search('^\s*$', 'cbnW')-1
	elseif end_line == -1
	    let end_line 	= search('\ze\\end\s*{\s*document\s*}')
	    normal! ge
	endif

	execute 'normal '.register.'y'
	if bufnr != -1
	    execute "buffer ".bufnr
	endif
	call winrestview(winview)
	execute toc_winnr . "wincmd w"
	execute "let yanked_section=@".register
	let yanked_section_list= split(yanked_section, '\n')
	if yanked_section_list[0] !~ '^\s*$' 
	    call extend(yanked_section_list, [''], 0)  
	endif
	call extend(t:atp_SectionStack, [[title, type, yanked_section_list, section_nr, file_name]],0)
    endfunction
    command! -buffer -nargs=? YankSection	:call <SID>YankSection(<f-args>)

    function! <SID>DeleteSection()

	" if under help lines do nothing:
	let toc_line	= getbufline("%",1,"$")
	let h_line	= index(reverse(copy(toc_line)),'')+1
	if line(".") > len(toc_line)-h_line
	    return ''
	endif

	let s:deleted_section = toc_line

	let [file_name, begin_line, end_line, title, type, section_nr, bibliography] = <SID>SectionScope()
	if [file_name, begin_line, end_line, title, type, section_nr, bibliography] == ['', '', '', '', '', '']
	    return
	endif

	" Window to go to
	let gotowinnr	= s:gotowinnr()

	if gotowinnr != -1
	    exe gotowinnr . " wincmd w"
	else
" 	    exe gotowinnr . " wincmd w"
	    exe "wincmd w"
	    exe "e " . fnameescape(file_name)
	endif
	    
	"finally, set the position
	call setpos('.',[0,begin_line,1,0])
	normal! V
	if end_line != -1 && !bibliography
	    call setpos('.',[0, end_line, 1, 0])
	elseif bibliography
	    call setpos('.',[0, end_line, 1, 0])
	    let end_line 	= search('^\s*$', 'cbnW')-1
	elseif end_line == -1
	    let end_line 	= search('\ze\\end\s*{\s*document\s*}')
	    normal! ge
	endif
	" and delete
	normal d
	let deleted_section	= split(@*, '\n')
	if deleted_section[0] !~ '^\s*$' 
	    call extend(deleted_section, [''], 0)  
	endif

	" Update the Table of Contents
	if !g:atp_python_toc
	    call remove(t:atp_toc[file_name], begin_line)
	    let new_toc={}
	    for line in keys(t:atp_toc[file_name])
		if str2nr(line) < str2nr(begin_line)
		    call extend(new_toc, { line : t:atp_toc[file_name][line] })
		else
		    call extend(new_toc, { line-len(deleted_section) : t:atp_toc[file_name][line] })
		endif
	    endfor
	    let t:atp_toc[file_name]	= new_toc
	endif
	" Being still in the tex file make backup:
	if exists("g:atp_SectionBackup")
	    call extend(g:atp_SectionBackup, [[title, type, deleted_section, section_nr, expand("%:p")]], 0)
	else
	    let g:atp_SectionBackup	= [[title, type, deleted_section, section_nr, expand("%:p")]]
	endif
	" return to toc 
	Toc! 0

	" Update the stack of deleted sections
	call extend(t:atp_SectionStack, [[title, type, deleted_section, section_nr, file_name]],0)
    endfunction
    command! -buffer DeleteSection	:call <SID>DeleteSection()
    " nnoremap dd			:call <SID>DeleteSection()<CR>

    " Paste the section from the stack
    " just before where the next section starts.
    " type = p/P	like paste p/P.
    " a:1	- the number of the section in the stack (from 1,...)
    " 	- by default it is the last one.
    function! <SID>PasteSection(type, ...)

	let stack_number = a:0 >= 1 ? a:1-1 : 0 

	if !len(t:atp_SectionStack)
	    sleep 750m
	    echomsg "[ATP:] the stack of deleted sections is empty"
	    return
	endif

	if a:type ==# "P" || line(".") == 1
	    let [buffer, begin_line]	= atplib#tools#getlinenr((line(".")))
	else
	    let [buffer, begin_line]	= atplib#tools#getlinenr((line(".")+1))
	    if begin_line	== ""
		let begin_line	= "last_line"
	    endif
	endif

	" Window to go to
	let gotowinnr	= s:gotowinnr()

	if gotowinnr != -1
	    exe gotowinnr . " wincmd w"
	else
	    exe "wincmd w"
	    exe "e " . fnameescape(buffer)
	endif

	if begin_line != ""
	    if begin_line != "last_line"
		call setpos(".", begin_line-1)
	    else
		keepjumps call setpos(".", [0, line("$"), 1, 0])
		keepjumps exe "normal $"
		keepjumps call search('\n.*\\end\s*{\s*document\s*}', 'bW')
		let begin_line = line(".")
	    endif
	elseif &l:filetype != 'plaintex'
	    keepjumps let begin_line	= search('\\end\s*{\s*document\s*}', 'nw')
	else
	    echo "Pasting at the end is not supported for plain tex documents"
	    return
	endif
	let number	= len(t:atp_SectionStack)-1
	" Append the section
	call append(begin_line-1, t:atp_SectionStack[stack_number][2])
	" Set the cursor position to the begining of moved section and add it to
	" the jump list
	call setpos(".", [0, begin_line, 1, 0])

	" Regenerate the Table of Contents:
	Toc!

	" Update the stack
	call remove(t:atp_SectionStack, stack_number)
    endfunction
    command! -buffer -nargs=? -bang PasteSection	:call <SID>PasteSection((<q-bang> == '!' ? 'P' : 'p'), <f-args>)

    " Lists title of sections in the t:atp_SectionStack
    function! <SID>SectionStack()
	if len(t:atp_SectionStack) == 0
	    echomsg "[ATP:] section stack is empty"
	    sleep 750m
	    return
	endif
	let i	= 1
	echohl WarningMsg
	echo "Number\tType\t\t\tTitle\t\t\t\t\tFile"
	echohl Normal
	let msg = []
	for section in t:atp_SectionStack
	    call add(msg, i . "\t" .  section[1] . " " . section[3] . "\t\t" . section[0]."\t\t".fnamemodify(section[4], ':.'))
	    let i+=1
	endfor
	" There is CursorHold event in toc list which showes the line,
	" using input() the message will not disapear imediately.
	call input(join(msg + [ "Press <Enter>" ] , "\n"))
    endfunction
    command! -buffer SectionStack	:call <SID>SectionStack()

    " Undo in the winnr under the cursor.
    " a:1 is one off u or U, default is u.
    function! <SID>Undo(...)
	let cmd	= ( a:0 >= 1 && a:1 =~ '\cu\|g\%(-\|+\)' ? a:1 : 'u' )
	let winnr	= s:gotowinnr()
	exe winnr . " wincmd w"
	exe "normal! " . cmd
	Toc!
    endfunction
    command! -buffer -nargs=? Undo 	:call <SID>Undo(<f-args>) 
    nnoremap <buffer> u			:call <SID>Undo('u')<CR>
    nnoremap <buffer> U			:call <SID>Undo('U')<CR>
    nnoremap <buffer> g-		:call <SID>Undo('g-')<CR>
    nnoremap <buffer> g+		:call <SID>Undo('g+')<CR>
endif
" }}}1

function! Help() " {{{1
    " Note: here they are not well indented, but in the output they are :)
    echo "Available Mappings:"
    echo "q 			close ToC window"
    echo "<CR>  			go to and close"
    echo "<space>			go to"
    echo "c or y			yank the label to a register"
    echo "p or P			yank and paste the label (in the source file)"
    echo "e			echo the title to command line"
    if expand("%")  == "__ToC__"
	echo ":YankSection [reg]	Yank section under the cursor to register"
	echo "                  	  (by default to the unnamed register \")"
	echo ":DeleteSection		Delete section under the cursor"
	echo ":PasteSection [arg] 	Paste section from section stack"
	echo ":SectionStack		Show section stack"
	echo ":Undo			Undo"
    endif
    echo "<F1>			this help message"
endfunction " }}}1

" ATP_CursorLine autocommand:
" {{{1
augroup ATP_CursorLine
    au CursorMoved,CursorMovedI __ToC__ call atplib#tools#CursorLine()
augroup END 
" }}}1

" Fold section
" CompareNumbers, Section2Nr {{{1
func! CompareNumbers(i1, i2)
    return str2nr(a:i1) == str2nr(a:i2) ? 0 : str2nr(a:i1) > str2nr(a:i2) ? 1 : -1
endfunc
function! <sid>Section2Nr(section)
    if a:section == 'part'
	return 1
    elseif a:section == 'chapter'
	return 2
    elseif a:section == 'section' || a:section == 'abstract'
	return 3
    elseif a:section == 'subsection'
	return 4
    elseif a:section == 'paragraph'
	return 5
    elseif a:section == 'subparagraph'
	return 6
    else
	return 7
    endif
endfunction
" }}}1
" Get the file name and its path from the LABELS/ToC list.
function! <sid>file() "{{{
    let labels		= expand("%") == "__Labels__" ? 1 : 0

    if labels == 0
	return get(b:atp_Toc, line("."), ["", ""])[0]
    else
	return get(b:atp_Labels, line("."), ["", ""])[0]
    endif
endfunction
"}}}
function! <sid>Fold(cmd) " {{{1
    if !g:atp_folding || (expand("%") != "__ToC__" ? 1 : 0)
	return
    endif
    let [file,nr] = atplib#tools#getlinenr(line("."), 0)
    let winnr = s:gotowinnr()
    let toc_winnr = winnr()
    exe winnr."wincmd w"
    let pos_saved = getpos(".")
    if a:cmd != 'zv'
	call cursor(nr,1)
    endif
    exe "normal! ".a:cmd
    if a:cmd != 'zv'
	call cursor(pos_saved[1:2])
    endif
    exe toc_winnr."wincmd w"
endfunction " }}}1

" TocMotion
fun! <sid>TocMotion(up)
    if a:up
	call search('^\%(\s\%(\d\+\|\*\|-\)\s\|>>\)', 'bW')
    else
	call search('^\%(\s\%(\d\+\|\*\|-\)\s\|>>\)', 'W')
    endif
endfun

" Folding:
fun! ATP_TocFold(linenr) " {{{1
    " let pos = getpos(".")
    " call cursor(a:linenr, 0)
    " let help = searchpos('>> Help', 'nbW')[0]
    " call cursor(pos[1], pos[2])
    " if help
        " return 0
    " else
    let line = getline(a:linenr)
    if stridx(line, '>>') == 0
        return '>1'
    elseif line =~ '^"'
	return 0
    else
        return 1
    endif
endfun
setl foldexpr=ATP_TocFold(v:lnum)
" Mappings:
fun! ATP_ToCFoldText() " {{{1
    return getline(v:foldstart)[3:]
endfun
setl fdt=ATP_ToCFoldText()
" MAPPINGS {{{1
if !exists("no_plugin_maps") && !exists("no_atp_toc_maps")

    if (expand("%") == "__ToC__" ? 1 : 0)
	nmap <silent> <buffer> Zv		:call <sid>Fold('zv')<CR>
	nmap <silent> <buffer> Zc		:call <sid>Fold('zc')<CR>
	nmap <silent> <buffer> ZC		:call <sid>Fold('zC')<CR>
	nmap <silent> <buffer> Zo		:call <sid>Fold('zo')<CR>
	nmap <silent> <buffer> ZO		:call <sid>Fold('zO')<CR>
    endif
    map <silent> <buffer> q 		:bdelete<CR>
    map <silent> <buffer> <CR> 		:call GotoLine(0)<CR>
    map <silent> <buffer> <space> 	:call GotoLine(1)<CR>
    map <silent> <buffer> <LeftRelease>   <LeftMouse><bar>:call GotoLine(0)<CR>
    vmap <silent> <buffer> <LeftRelease>  <Esc><LeftMouse><bar>:call GotoLine(0)<CR>
    if expand("%") == "__ToC__"
	map <silent> <buffer> _		:call GotoLine(0)<bar>wincmd w<CR>
    else
	map <silent> <buffer> _		:call GotoLine(0)<bar>Labels<CR>
    endif
" This does not work: 
"   noremap <silent> <buffer> <LeftMouse> :call GotoLine(0)<CR>
"   when the cursor is in another buffer (and the option mousefocuse is not
"   set) it calles the command instead of the function, I could add a check if
"   mouse is over the right buffer. With mousefocuse it also do not works very
"   well.
    map <silent> <buffer> c		:call YankToReg()<CR>
    map <silent> <buffer> y 		:call YankToReg()<CR>
    map <silent> <buffer> p 		:call Paste()<CR>
    map <silent> <buffer> P 		:call <SID>yank("P")<CR>
    map <silent> <buffer> s 		:<C-U>call ShowLabelContext(v:count)<CR> 
    map <silent> <buffer> e 		:call EchoLine()<CR>
    map <silent> <buffer> <F1>		:call Help()<CR>

    nnoremap <silent> <buffer> ]]	:call search('^\s*\zs\d\s', 'W')<cr>
    nnoremap <silent> <buffer> [[	:call search('^\s*\zs\d\s', 'Wb')<cr>
    nnoremap <silent> <buffer> <c-k> :call <sid>TocMotion(1)<cr>
    nnoremap <silent> <buffer> <c-j> :call <sid>TocMotion(0)<cr>
    nnoremap <silent> <buffer> K :call search('^>>', 'bW')<cr>
    nnoremap <silent> <buffer> J :call search('^>>', 'W')<cr>

    nnoremap <silent> <buffer> I <nop>
    nnoremap <silent> <buffer> x <nop>
    nnoremap <silent> <buffer> X <nop>
    nnoremap <silent> <buffer> dd <nop>
    nnoremap <silent> <buffer> d <nop>
    nnoremap <silent> <buffer> D <nop>
    nnoremap <silent> <buffer> A <nop>
    nnoremap <silent> <buffer> a <nop>
    nnoremap <silent> <buffer> S <nop>
    nnoremap <silent> <buffer> u <nop>
    nnoremap <silent> <buffer> U <nop>
    nnoremap <silent> <buffer> o <nop>
    nnoremap <silent> <buffer> O <nop>
    nnoremap <silent> <buffer> P <nop>
endif
" vim:fdm=marker:tw=85:ff=unix:noet:ts=8:sw=4:fdc=1
