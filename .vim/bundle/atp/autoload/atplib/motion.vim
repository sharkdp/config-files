" Author:	Marcin Szamotulski
" Description:	This file contains motion and highlight functions of ATP.
" Note:		This file is a part of Automatic Tex Plugin for Vim.
" Language:	tex
" Last Change:

" All table  of contents stuff: variables, functions and commands. 
" {{{1 __Table_of_Contents__
"--Make TOC -----------------------------
" This makes sense only for latex documents.
"
" Notes: Makeing toc from aux file:
" 	+ is fast
" 	+ one gets correct numbers
" 	- one doesn't get line numbers
" 		/ the title might be modified thus one can not make a pattern
" 		    which works in all situations, while this is important for 
" 		    :DeleteSection command /
"
" {{{2 atplib#motion#find_toc_lines
function! atplib#motion#find_toc_lines()
    let toc_lines_nr=[]
    let toc_lines=[]

    let pos_saved=getpos(".")
    let pos=[0,1,1,0]
    keepjumps call setpos(".",pos)

    " Pattern:
    let j=0
    for section in keys(g:atp_sections)
	if j == 0 
	    let pattern=g:atp_sections[section][0] . ''
	else
	    let pattern=pattern . '\|' . g:atp_sections[section][0] 
	endif
	let j+=1
    endfor

    " Searching Loop:
    let line=search(pattern, 'W')
    while line
	call add(toc_lines_nr, line)
	let line=search(pattern, 'W')
    endwhile
    keepjumps call setpos(".", pos_saved)
    for line in toc_lines_nr
	call add(toc_lines, getline(line))
    endfor
    return toc_lines
endfunction
" {{{2 atplib#motion#maketoc 
" this will store information: 
" { 'linenumber' : ['chapter/section/..', 'sectionnumber', 'section title', '0/1=not starred/starred'] }
" a:0 >= 1 avoid using atplib#search#SearchPackage('biblatex') (requires that b:atp_MainFile exists)
function! atplib#motion#maketoc(filename,...)
    let toc={}
    let search_package = ( a:0 >= 1 ? a:1 : 1 ) 

    " if the dictinary with labels is not defined, define it
    if !exists("t:atp_labels")
	let t:atp_labels = {}
    endif

    let texfile		= []
    " getbufline reads only loaded buffers, unloaded can be read from file.
    let bufname		= fnamemodify(a:filename,":t")
    try
	let texfile = ( bufexists(bufname)  ? getbufline("^" . bufname . "$","1","$") : readfile(a:filename) )
    catch /E484:/
	echohl Warning
	echo "File " . a:filename . " not readable."
	echohl None
    endtry
    let texfile_copy	= deepcopy(texfile)

    let true		= 1
    let bline		= 0 	" We are not removing the preambule any more.
    let i		= 1
    " set variables for chapter/section numbers
    for section in keys(g:atp_sections)
	let ind{section} = 0
    endfor
    " make a filter
    let j = 0
    let biblatex	= ( search_package ? atplib#search#SearchPackage("biblatex") : 0 )
    " When \usepackge{biblatex} do not search for \bibliography{} commands -- they are placed in the preambule.
    let key_list 	= ( biblatex ? filter(keys(g:atp_sections), "v:val != 'bibliography'") : keys(g:atp_sections) ) 
    for section in key_list
	let filter = ( j == 0 ? g:atp_sections[section][0] . '' : filter . '\|' . g:atp_sections[section][0] )
	let j+=1
    endfor

    let s:filtered	= filter(deepcopy(texfile), 'v:val =~ filter')
    let line_number = -1
    for line in s:filtered
	let line_number+=1
	for section in keys(g:atp_sections)
	    if line =~ g:atp_sections[section][0] 
		if line !~ '^\s*\\\@<!%'
		    " THIS DO NOT WORKS WITH \abstract{ --> empty set, but with
		    " \chapter{title} --> title, solution: the name of
		    " 'Abstract' will be plased, as we know what we have
		    " matched
		    let title	= line
" This is an attempt to join consecutive lines iff the title is spanned
" through more than one line.
" s:filtered doesn't is not the same as texfile!!!
" we should use texfile, but for this we need to know the true line numbers,
" they should be around though.
" 		    let open=count(split(title, '\zs'), '{')
" 		    let closed=count(split(title, '\zs'), '}')
" 		    let i=0
" 		    if open!=closed
" 			echomsg "XXXXXXX"
" 			echomsg title
" 		    endif
" 		    while open!=closed && line_number+i+2<=len(s:filtered)
" 			echomsg i." ".s:filtered[line_number+i]
" 			let i+=1 
" 			let open+=count(split(s:filtered[line_number+i], '\zs'), '{')
" 			let closed+=count(split(s:filtered[line_number+i], '\zs'), '}')
" 			let title.=" ".substitute(s:filtered[line_number+i], '^\s*', '', '')
" 		    endwhile

		    " test if it is a starred version.
		    let star=0
		    if g:atp_sections[section][1] != 'nopattern' && line =~ g:atp_sections[section][1] 
			let star=1 
		    else
			let star=0
		    endif

		    " Problem: If there are two sections with the same title, this
		    " does't work:
		    let idx	= index(texfile,line)
		    call remove(texfile, idx)
		    let i	= idx
		    let tline	= i+bline+1
		    let bline	+=1

		    " Find Title:
		    let start	= stridx(title,'{')+1
		    let title	= strpart(title,start)
		    " we are looking for the maching '}' 
		    let l:count	= 1
		    let i=-1
		    while i<=len(title)
			let i+=1
			if strpart(title,i,1) == '{'	
			    let l:count+=1
			elseif strpart(title,i,1) == '}'
			    let l:count-=1
			endif
			if l:count == 0
			    break
			endif
		    endwhile	
		    let title = strpart(title,0,i)
		    let title = substitute(title, '[{}]\|\\titlefont\|\\hfill\=\|\\hrule\|\\[vh]space\s*{[^}]\+}', '', 'g')

		    " Section Number:
		    " if it is not starred version add one to the section number
		    " or it is not an abstract 
		    if star == 0  
			if !(section == 'chapter' && title =~ '^\cabstract$')
			    let ind{section}+=1
			endif
		    endif

		    if section == 'part'
			let indchapter		= 0
			let indsection		= 0
			let indsubsection	= 0
			let indsubsubsection	= 0
		    elseif section ==  'chapter'
			let indsection		= 0
			let indsubsection	= 0
			let indsubsubsection	= 0
		    elseif section ==  'section' || section == 'frame'
			let indsubsection	= 0
			let indsubsubsection	= 0
		    elseif section ==  'subsection'
			let indsubsubsection	= 0
		    endif

		    " Find Short Title:
		    let shorttitle=line
		    let start=stridx(shorttitle,'[')+1
		    if start == 0
			let shorttitle=''
		    else
			let shorttitle=strpart(shorttitle,start)
			" we are looking for the maching ']' 
			let l:count=1
			let i=-1
			while i<=len(shorttitle)
			    let i+=1
			    if strpart(shorttitle,i,1) == '['	
				let l:count+=1
			    elseif strpart(shorttitle,i,1) == ']'
				let l:count-=1
			    endif
			    if l:count==0
				break
			    endif
			endwhile	
			let shorttitle = strpart(shorttitle,0,i)
		    endif

		    "ToDo: if section is bibliography (using bib) then find the first
		    " empty line:
		    if section == "bibliography" && line !~ '\\begin\s*{\s*thebibliography\s*}' && !biblatex
			let idx	= tline-1
			while texfile_copy[idx] !~ '^\s*$'
			    let idx-= 1
			endwhile
" 			" We add 1 as we want the first non blank line, and one more
" 			" 1 as we want to know the line number not the list index
" 			" number:
			let tline=idx+1
		    endif

		    " Add results to the dictionary:
		    if biblatex && section != "bibliography" || !biblatex
			call extend(toc, { tline : [ section, ind{section}, title, star, shorttitle] }) 
		    endif

		endif
	    endif
	endfor
    endfor
"     if exists("t:atp_toc")
" 	call extend(t:atp_toc, { a:filename : toc }, "force")
"     else
" 	let t:atp_toc = { a:filename : toc }
"     endif
"     return t:atp_toc
    return { a:filename : toc }
endfunction
"
" {{{2 atplib#motion#maketoc_py
function! atplib#motion#maketoc_py(filename,...)
    " filename is supposed to be b:atp_MainFile
let s:py_toc = []
python << END
import vim
import fileinput
import sys
import re
import os
import os.path
from atplib.atpvim import readlines

enc = vim.eval('&enc')

# main file
file_name = vim.eval("a:filename")
# Change the directory to the main file
main_dir = os.path.dirname(file_name)
if main_dir != '':
    os.chdir(main_dir)

section_pattern         = re.compile(r'[^%]*\\(subsection|section|chapter|part)(\*)?\s*(?:\[|{)')
shorttitle_pattern      = re.compile(r'[^%]*\\(subsection|section|chapter|part)(\*)?\s*\[')
subfile_pattern         = re.compile(r'[^%]*\\(input|include|subfile)\s*{([^}]*)}')
bib_pattern		= re.compile(r'[^%]*\\bibliography\s*{([^}]*)}')

# the toc list:
toc = []
# toc = [ [file_name, line_nr, section_unit, title, short_title, star ], ... ]
# after the section number will be computed (depending on section/parts/ ..., 
# or it might be taken from the aux file)

# the list of files:
file_list = [[file_name, 'root', 0]]
# file_list = [ [ file, subfile, lnr ], ... ]

def map_none(val):
    if val == None:
	return ''
    else:
	return val

def file_path(fname):
    # add tex extension if the file has no extension,

    if not fname.endswith('.tex'):
        return os.path.join(main_dir,fname+".tex")
    else:
        return os.path.join(main_dir,fname)

def find_in_brackets(string, bra='{', ket='}'):
    # find string in brackets {...},

    if bra in string:
        match = string.split(bra, 1)[1]
        bopen = 1
        for index in xrange(len(match)):
            if match[index] == bra:
                bopen += 1
            elif match[index] == ket:
                bopen -= 1
            if not bopen:
                return match[:index]

def scan_project(fname):
    # scan file for section units starting after line start_line,

    try:
        flines = readlines(file_path(fname))
        length = len(flines)
        for ind in xrange(length):
            line = flines[ind]
            secu = re.match(section_pattern, line)
            if secu:
		# Join lines (find titles if they are spread in more than one line):
                i = 1
                while i+ind < length and i < 6:
                    line += flines[ind+i]
                    i+=1
                if re.match(shorttitle_pattern, line):
                    short_title = find_in_brackets(line, '[', ']')
                    short_title = re.sub('\s*\n\s*', ' ', short_title)
                else:
                    short_title = ''
                title = find_in_brackets(line, '{', '}')
                if title != None:
                    title = re.sub('\s*\n\s*', ' ', title)
                else:
                    title = ''
                # sec_nr is added afterwards.
                add = [ file_path(fname), ind+1, secu.group(1), title, short_title, secu.group(2)]
                toc.append(map(map_none,add))
            else:
                subf = re.match(subfile_pattern, line)
                if subf:
                    file_list.append(map(map_none,[file_path(fname), subf.group(2), ind+1]))
                    scan_project(subf.group(2))
                else:
                    bibf = re.match(bib_pattern, line)
                    if bibf:
                        toc.append([file_path(fname), ind+1, 'bibliography', re.sub('\s*,\s*',' ',bibf.group(1)), '', '*'])
    except IOError:
        print("[ATP]: cannot open '%s' (cwd='%s')" % (file_path(fname), os.getcwd()))
	pass


# add stuff to the toc list.
scan_project(file_name)

def check_sec(sec_name,toc):
    # Check if there is a section sec_name in toc

    def filter_toc(val):
        if val[2] == sec_name:
            return True
        else:
            return False
    return len(filter(filter_toc,toc)) > 0

has_part = check_sec('part', toc)
has_chapter = check_sec('chapter', toc)
has_section = check_sec('section', toc)
if len(toc) > 0:
    p_nr = 0
    c_nr = 0
    s_nr = 0
    ss_nr = 0
    sss_nr = 0
    for i in range(0,len(toc)):
        if toc[i][2] == 'part' and toc[i][5] == '':
            p_nr += 1
            c_nr = 0
            s_nr = 0
            ss_nr = 0
            sss_nr = 0
        elif toc[i][2] == 'chapter' and toc[i][5] == '':
            c_nr += 1
            s_nr = 0
            ss_nr = 0
            sss_nr = 0
        elif toc[i][2] == 'section' and toc[i][5] == '':
            s_nr += 1
            ss_nr = 0
            sss_nr = 0
        elif toc[i][2] == 'subsection' and toc[i][5] == '':
            ss_nr += 1
            sss_nr = 0
        elif toc[i][2] == 'subsubsection' and toc[i][5] == '':
            sss_nr += 1
        if toc[i][5] == '*':
            sec_nr = "*"
        else:
            if has_part:
                if toc[i][2] == 'part':
                    sec_nr = str(p_nr)
                elif toc[i][2] == 'chapter':
                    sec_nr = str(p_nr)+"."+str(c_nr)
                elif toc[i][2] == 'section':
                    sec_nr = str(p_nr)+"."+str(c_nr)+"."+str(s_nr)
                elif toc[i][2] == 'subsection':
                    sec_nr = str(p_nr)+"."+str(c_nr)+"."+str(s_nr)+"."+str(ss_nr)
                elif toc[i][2] == 'subsubsection':
                    sec_nr = str(p_nr)+"."+str(c_nr)+"."+str(s_nr)+"."+str(ss_nr)+"."+str(sss_nr)
            elif has_chapter:
                if toc[i][2] == 'chapter':
                    sec_nr = str(c_nr)
                elif toc[i][2] == 'section':
                    sec_nr = str(c_nr)+"."+str(s_nr)
                elif toc[i][2] == 'subsection':
                    sec_nr = str(c_nr)+"."+str(s_nr)+"."+str(ss_nr)
                elif toc[i][2] == 'subsubsection':
                    sec_nr = str(c_nr)+"."+str(s_nr)+"."+str(ss_nr)+"."+str(sss_nr)
            elif has_section:
                if toc[i][2] == 'section':
                    sec_nr = str(s_nr)
                elif toc[i][2] == 'subsection':
                    sec_nr = str(s_nr)+"."+str(ss_nr)
                elif toc[i][2] == 'subsubsection':
                    sec_nr = str(s_nr)+"."+str(ss_nr)+"."+str(sss_nr)
        toc[i] = toc[i]+[sec_nr]

if hasattr(vim, 'bindeval'):
    vtoc = vim.bindeval('s:py_toc')
    vtoc.extend(toc)
else:
    import json
    vim.command("let s:py_toc=%s" % json.dumps(toc))
END
return { a:filename : s:py_toc }
endfunction
" {{{2 atplib#motion#buflist
function! atplib#motion#buflist()
    " this names are used in TOC and passed to atplib#motion#maketoc, which
    " makes a dictionary whose keys are the values of name defined
    " just below:
    if !exists("t:atp_toc_buflist")
	let t:atp_toc_buflist = []
    endif
    if g:atp_python_toc
        let name = atplib#FullPath(b:atp_MainFile)
    else
        let name=resolve(fnamemodify(bufname("%"),":p")) " add an entry to the list t:atp_toc_buflist if it is not there.
    endif
    if bufname("") =~ ".tex" && index(t:atp_toc_buflist,name) == -1
        if index(t:atp_toc_buflist,name) == -1
            call add(t:atp_toc_buflist,name)
        endif
    endif
    return t:atp_toc_buflist
endfunction
" {{{2 tplib#motion#RemoveFromToC
function! atplib#motion#RemoveFromToC(file)
    if a:file == ""
	if exists("b:atp_MainFile")
	    let list = filter(copy(t:atp_toc_buflist), "v:val != fnamemodify(b:atp_MainFile, ':p')")
	else
	    let list = copy(t:atp_toc_buflist)
	endif
	if len(list) >= 2
	    let i=1
	    for f in list
		echo "(" . i . ") " . f
		let i+=1
	    endfor
	    let which=input("Which file to remove (press <Enter> for none)")
	    if which == ""
		return
	    endif
	    let which=t:atp_toc_buflist[which-1]
	elseif exists("b:atp_MainFile") && len(list) == 1
	    let which=get(list,0,"")
	else
	    return
	endif
    else
	let which = fnamemodify(a:file, ":p")
    endif

    if which != ""
	silent! call remove(t:atp_toc_buflist,index(t:atp_toc_buflist, which))
	silent! call remove(t:atp_toc,which)
    endif
    let winnr=winnr()
    if index(map(tabpagebuflist(), 'bufname(v:val)'), '__ToC__') != -1
	call atplib#motion#TOC("!", 0, 0)
    endif
    exe winnr."wincmd w"
endfunction
function! atplib#motion#RemoveFromToCComp(A, B, C)
    return join(map(copy(t:atp_toc_buflist), 'fnamemodify(v:val, ":t")'),"\n")
endfunction
" {{{2 atplib#motion#showtoc
function! atplib#motion#showtoc(toc)

    " this is a dictionary of line numbers where a new file begins.
    let cline=line(".")
"     " Open new window or jump to the existing one.
"     " Remember the place from which we are coming:
    let t:atp_bufname=atplib#FullPath(expand("%:t"))
"     let t:atp_winnr=winnr()	 these are already set by TOC()
    let bname="__ToC__"
    let tocwinnr=bufwinnr(bufnr("^".bname."$"))
    if tocwinnr != -1
	" Jump to the existing window.
	exe tocwinnr . " wincmd w"
	setl modifiable noreadonly
	silent exe "%delete _"
    else
	" Open new window if its width is defined (if it is not the code below
	" will put toc in the current buffer so it is better to return.
	if !exists("t:toc_window_width")
	    let t:toc_window_width = g:atp_toc_window_width
	endif
	let labels_winnr=bufwinnr(bufnr("__Labels__"))
	if labels_winnr != -1
	    exe labels_winnr."wincmd w"
	    let split_cmd = "above split"
	else
	    let split_cmd = "vsplit"
	endif
	let toc_winnr=bufwinnr(bufnr("__ToC__"))
	if toc_winnr == -1
	    let openbuffer="keepalt " . (labels_winnr == -1 ? t:toc_window_width : ''). split_cmd." +setl\\ buftype=nofile\\ modifiable\\ noreadonly\\ noswapfile\\ bufhidden=delete\\ nobuflisted\\ tabstop=1\\ filetype=toc_atp\\ nowrap\\ nonumber\\ norelativenumber\\ winfixwidth\\ nospell\\ cursorline __ToC__"
	    let splitright = &splitright
	    let &splitright = g:atp_splitright
	    keepalt silent exe openbuffer
	    let &splitright = splitright
	else
	    exe toc_winnr."wincmd w"
	    setl modifiable noreadonly
	endif
    endif
    let number=1
    " this is the line number in ToC.
    " number is a line number relative to the file listed in ToC.
    " the current line number is linenumber+number
    " there are two loops: one over linenumber and the second over number.
    let numberdict	= {}
    let s:numberdict	= numberdict
    unlockvar b:atp_Toc
    let b:atp_Toc	= {}
    " this variable will be used to set the cursor position in ToC.
    for openfile in keys(a:toc)
	call extend(numberdict, { openfile : number })
	let part_on=0
	let chap_on=0
	let chnr=0
	let secnr=0
	let ssecnr=0
	let sssecnr=0
	for line in keys(a:toc[openfile])
	    if a:toc[openfile][line][0] == 'chapter'
		let chap_on=1
		break
	    elseif a:toc[openfile][line][0] == 'part'
		let part_on=1
	    endif
	endfor
	let sorted	= sort(keys(a:toc[openfile]), "atplib#CompareNumbers")
	let len		= len(sorted)
	" write the file name in ToC (with a full path in paranthesis)
	call setline(number, ">> ".fnamemodify(openfile,":t")." (".fnamemodify(openfile,":p:h").")")
	call extend(b:atp_Toc, { number : [ openfile, 1 ]}) 
	let number+=1
	let showline = " "
	for line in sorted
	    call extend(b:atp_Toc,  { number : [ openfile, line ] })
	    let lineidx=index(sorted,line)
	    let nlineidx=lineidx+1
	    if nlineidx< len(sorted)
		let nline=sorted[nlineidx]
	    else
		let nline=line("$")
	    endif
	    " Print ToC lines.
	    if a:toc[openfile][line][0] == 'abstract' || a:toc[openfile][line][2] =~ '^\cabstract$'
		call setline(number, showline . "- " . "Abstract" )
	    elseif a:toc[openfile][line][0] =~ 'bibliography\|references'
		call setline(number, showline . "- " . a:toc[openfile][line][2])
	    elseif a:toc[openfile][line][0] == 'part'
		let partnr=a:toc[openfile][line][1]
		let nr=partnr
		if a:toc[openfile][line][3]
		    "if it is stared version
		    let nr=substitute(nr,'.',' ','')
		endif
		if a:toc[openfile][line][4] != ''
		    call setline (number, " " . a:toc[openfile][line][4])
		else
		    call setline (number, " " . a:toc[openfile][line][2])
		endif
	    elseif a:toc[openfile][line][0] == 'chapter'
		let chnr=a:toc[openfile][line][1]
		let nr=chnr
		if a:toc[openfile][line][3]
		    "if it is stared version
		    let nr=substitute(nr,'.',' ','')
		endif
		if a:toc[openfile][line][4] != ''
		    call setline (number, showline . nr . " " . a:toc[openfile][line][4])
		else
		    call setline (number, showline . nr . " " . a:toc[openfile][line][2])
		endif
	    elseif a:toc[openfile][line][0] == 'section' || a:toc[openfile][line][0] == 'frame'
		let secnr=a:toc[openfile][line][1]
		if chap_on
		    let nr=chnr . "." . secnr  
		    if a:toc[openfile][line][3]
			"if it is stared version
			let nr=substitute(nr,'.',' ','g')
		    endif
		    if a:toc[openfile][line][4] != ''
			call setline (number, showline . nr . " " . a:toc[openfile][line][4])
		    else
			call setline (number, showline . nr . " " . a:toc[openfile][line][2])
		    endif
		else
		    let nr=secnr 
		    if a:toc[openfile][line][3]
			"if it is stared version
			let nr=substitute(nr,'.',' ','g')
		    endif
		    if a:toc[openfile][line][4] != ''
			call setline (number, showline . nr . " " . a:toc[openfile][line][4])
		    else
			call setline (number, showline . nr . " " . a:toc[openfile][line][2])
		    endif
		endif
	    elseif a:toc[openfile][line][0] == 'subsection'
		let ssecnr=a:toc[openfile][line][1]
		if chap_on
		    let nr=chnr . "." . secnr  . "." . ssecnr
		    if a:toc[openfile][line][3]
			"if it is stared version 
			let nr=substitute(nr,'.',' ','g')
		    endif
		    if a:toc[openfile][line][4] != ''
			call setline (number, showline . nr . " " . a:toc[openfile][line][4])
		    else
			call setline (number, showline . nr . " " . a:toc[openfile][line][2])
		    endif
		else
		    let nr=secnr  . "." . ssecnr
		    if a:toc[openfile][line][3]
			"if it is stared version 
			let nr=substitute(nr,'.',' ','g')
		    endif
		    if a:toc[openfile][line][4] != ''
			call setline (number, showline . nr . " " . a:toc[openfile][line][4])
		    else
			call setline (number, showline . nr . " " . a:toc[openfile][line][2])
		    endif
		endif
	    elseif a:toc[openfile][line][0] == 'subsubsection'
		let sssecnr=a:toc[openfile][line][1]
		if chap_on
		    let nr=chnr . "." . secnr . "." . sssecnr  
		    if a:toc[openfile][line][3]
			"if it is stared version
			let nr=substitute(nr,'.',' ','g')
		    endif
		    if a:toc[openfile][line][4] != ''
			call setline(number, showline . nr . " " . a:toc[openfile][line][4])
		    else
			call setline(number, showline . nr . " " . a:toc[openfile][line][2])
		    endif
		else
		    let nr=secnr  . "." . ssecnr . "." . sssecnr
		    if a:toc[openfile][line][3]
			"if it is stared version 
			let nr=substitute(nr,'.',' ','g')
		    endif
		    if a:toc[openfile][line][4] != ''
			call setline (number, showline . nr . " " . a:toc[openfile][line][4])
		    else
			call setline (number, showline . nr . " " . a:toc[openfile][line][2])
		    endif
		endif
	    else
		let nr=""
	    endif
	    let number+=1
	endfor
    endfor
    " set the cursor position on the correct line number.
    " first get the line number of the begging of the ToC of t:atp_bufname
    " (current buffer)
    " 	let t:numberdict=numberdict	"DEBUG
    " 	t:atp_bufname is the full path to the current buffer.
    let num = get(numberdict, t:atp_bufname, 'no_number')
    if num == 'no_number'
	setl nomodifiable
	return
    endif
    let sorted		= sort(keys(a:toc[t:atp_bufname]), "atplib#CompareNumbers")
    let t:sorted	= sorted
    for line in sorted
	if cline>=line
	    let num+=1
	endif
    keepjumps call setpos('.',[bufnr(""),num,1,0])
    endfor
   
    " Help Lines:
    if search('" <Enter> jump and close', 'nW') == 0
	call append('$', [ '', 			
		\ '" _       set',
		\ '" <Enter> jump', 
		\ '" <Space> jump and close', 	
		\ '" s       jump and split', 
		\ '" y or c  yank label', 	
		\ '" p       paste label', 
		\ '" q       close', 		
		\ '" zc	     fold section[s]',
		\ '" ^j	     go to next chapter',
		\ '" ^k	     go to previous chapter',
		\ '" J	     go to next project',
		\ '" K	     go to previous project',
		\ '" :[range]Fold',
		\ '" :YankSection', 
		\ '" :DeleteSection', 
		\ '" :PasteSection[!]', 		
		\ '" :SectionStack', 
		\ '" :Undo' ])
    endif
    setl nomodifiable
    lockvar 3 b:atp_Toc
endfunction
" {{{2 atplib#motion#show_pytoc
function! atplib#motion#show_pytoc(toc)


    " this is a dictionary of line numbers where a new file begins.
    let cline=line(".")
"     " Open new window or jump to the existing one.
"     " Remember the place from which we are coming:
    let t:atp_bufname=atplib#FullPath(expand("%:t"))
    let bname="__ToC__"
    let tabpagebufdict = {}
    for bufnr in tabpagebuflist()
	if fnamemodify(bufname(bufnr), ":t") != ""
	    let tabpagebufdict[fnamemodify(bufname(bufnr), ":t")]=bufnr
	endif
    endfor
    if index(keys(tabpagebufdict), "__ToC__") != -1
	let tocwinnr = bufwinnr(tabpagebufdict["__ToC__"])
    else
	let tocwinnr = -1
    endif

    if tocwinnr != -1
	" Jump to the existing window.
	    exe tocwinnr . " wincmd w"
	    setl modifiable noreadonly
	    silent exe "%delete _"
    else
	" Open new window if its width is defined (if it is not the code below
	" will put toc in the current buffer so it is better to return.
	if !exists("t:toc_window_width")
	    let t:toc_window_width = g:atp_toc_window_width
	endif
	let labels_winnr=bufwinnr(bufnr("__Labels__"))
	if labels_winnr != -1
	    exe labels_winnr."wincmd w"
	    let split_cmd = "above split"
	else
	    let split_cmd = "vsplit"
	endif
	let toc_winnr=bufwinnr(bufnr("__ToC__"))
	if toc_winnr == -1
	    let openbuffer="keepalt " . (labels_winnr == -1 ? t:toc_window_width : ''). split_cmd." +setl\\ buftype=nofile\\ modifiable\\ noreadonly\\ noswapfile\\ bufhidden=delete\\ nobuflisted\\ tabstop=1\\ filetype=toc_atp\\ nowrap\\ nonumber\\ norelativenumber\\ winfixwidth\\ nospell\\ cursorline __ToC__"
	    let splitright = &splitright
	    let &splitright = g:atp_splitright
	    keepalt silent exe openbuffer
	    let &splitright = splitright
	else
	    exe toc_winnr."wincmd w"
	    setl modifiable noreadonly
	endif
    endif
    let number=1
    " this is the line number in ToC.
    " number is a line number relative to the file listed in ToC.
    " the current line number is linenumber+number
    " there are two loops: one over linenumber and the second over number.
    let numberdict	= {}
    let s:numberdict	= numberdict
    unlockvar b:atp_Toc
    let b:atp_Toc	= {}
    " this variable will be used to set the cursor position in ToC.
    for openfile in keys(a:toc)
	call extend(numberdict, { openfile : number })
	" write the file name in ToC (with a full path in paranthesis)
	call setline(number, ">> ".fnamemodify(openfile,":t")." (".fnamemodify(openfile,":p:h").")")
        " openfile is the project name
	call extend(b:atp_Toc, { number : [ openfile, 1, openfile ]}) 
	let number+=1
        let lineidx = -1
	for line_list in a:toc[openfile]
            let line = line_list[1]
	    call extend(b:atp_Toc,  { number : [ line_list[0], line, openfile ] })
            let lineidx+=1
	    let nlineidx=lineidx+1
	    if nlineidx < len(a:toc[openfile])
		let nline=a:toc[openfile][nlineidx][1]
	    else
		let nline=line("$")
	    endif
	    let showline = ' '
	    " Print ToC lines.
	    if line_list[2] == 'abstract' || line_list[3] =~ '^\cabstract$'
		call setline(number, showline . "- " . "Abstract" )
	    elseif line_list[2] =~ 'bibliography\|references'
		call setline (number, showline . "- bib:" . line_list[3])
	    else
		let secnr=get(line_list,6,"XXX") " there might not bee section number in the line_list
                let nr=secnr 
                if line_list[4] != ''
                    call setline (number, showline . nr . " " . line_list[4])
                else
                    call setline (number, showline . nr . " " . line_list[3])
                endif
	    endif
	    let number+=1
	endfor
    endfor
    " set the cursor position on the correct line number.
    " first get the line number of the begging of the ToC of t:atp_bufname
    " (current buffer)
    let MainFile    = atplib#FullPath(getbufvar(bufnr(t:atp_bufname), "atp_MainFile"))
    let num 	= get(s:numberdict, MainFile, 'no_number')
    if num == 'no_number'
	return
    endif
    let sorted	= t:atp_pytoc[MainFile]
    let num_list=[0]
    let f_test = ( t:atp_bufname == atplib#FullPath(getbufvar(bufnr(t:atp_bufname), "atp_MainFile")) )
    for ind in range(0,len(sorted)-1)
	let line_l = sorted[ind]
        if g:atp_python_toc
	    " t:atp_bufname buffer from which :TOC was invoked.
	    let f_test_p = f_test
	    let f_test   = ( !f_test && t:atp_bufname == line_l[0] ? 1 : f_test )
	    if f_test && !f_test_p
		call add(num_list, ind+1)
	    endif
	    if t:atp_bufname == line_l[0] && (str2nr(cline) >= str2nr(line_l[1]))
		call add(num_list, ind+1)
	    endif
        else
            let line = line_l
            if cline>=line
                let num+=1
            else
                break
            endif
        endif
    endfor
    if g:atp_python_toc
	let num = max(num_list)+1
	keepjumps call setpos('.', [0,0,0,0])
	keepjumps call search('^>> '.escape(fnamemodify(MainFile, ":t"), '.\/').'\s\+(.*)\s*$', 'cW')
	call cursor(line(".")+(num-1),1)
    else
	keepjumps call setpos('.',[bufnr(""),num,1,0])
    endif
   
    " Help Lines:
    if search('"<Enter> jump and close', 'nW') == 0
	call append('$', [ '', 			
		\ '" _       set',
		\ '" <Enter> jump', 
		\ '" <Space> jump and close', 	
		\ '" s       jump and split', 
		\ '" y or c  yank label', 	
		\ '" p       paste label', 
		\ '" q       close', 		
		\ '" ^j	     go to next chapter',
		\ '" ^k	     go to previous chapter',
		\ '" J	     go to next project',
		\ '" K	     go to previous project',
		\ '" :YankSection', 
		\ '" :DeleteSection', 
		\ '" :PasteSection[!]', 		
		\ '" :SectionStack', 
		\ '" :Undo' ])
" 		\ '" zc	     fold section[s]',
" 		\ '" :[range]Fold',
    endif
    setl nomodifiable
    setl fdm=expr
    normal! zMzv
    lockvar 3 b:atp_Toc
endfunction
" {{{2 atplib#motion#ToCbufnr()
" This function returns toc buffer number if toc window is not open returns -1.
function! atplib#motion#ToCbufnr() 
    let tabpagebufdict = {}
    for bufnr in tabpagebuflist()
	if fnamemodify(bufname(bufnr), ":t") != ""
	    " For QuickFix bufname is an empty string:
	    let tabpagebufdict[fnamemodify(bufname(bufnr), ":t")]=bufnr
	endif
    endfor
    if index(keys(tabpagebufdict), "__ToC__") != -1
	return tabpagebufdict["__ToC__"]
    else
	let bufnames = []
	for bufnr in range(1,bufnr('$'))
	    if bufexists(bufnr)
		let bname = bufname(bufnr)
		if !empty(bname)
		    call add(bufnames, [fnamemodify(bname, ":t"), bufnr])
		endif
	    endif
	endfor
	call filter(bufnames, 'v:val[0] == "__ToC__"')
	if !empty(bufnames)
	    return bufnames[0][1]
	else
	    return -1
	endif
    endif
endfunction
" atplib#motion#UpdateToCLine {{{2
function! atplib#motion#UpdateToCLine(...)
    let time = reltime()
    if !g:atp_UpdateToCLine
	return
    endif
    let toc_bufnr = atplib#motion#ToCbufnr()
    if index(tabpagebuflist(), toc_bufnr) == -1
	return
    endif
    let check_line 	= (a:0>=1 ? a:1 : -1) 
    if toc_bufnr == -1 || check_line != -1 && 
		\ getline(line(".")+check_line) !~# '\\\%(part\|chapter\|\%(sub\)\{0,2}section\)\s*{'
	return
    endif
    let cline  	= line(".")
    let cbufnr 	= bufnr("%")
    let cwinnr	= winnr()
    exe "keepalt" bufwinnr(toc_bufnr)."wincmd w"
    let MainFile    = atplib#FullPath(getbufvar(bufnr(t:atp_bufname), "atp_MainFile"))
    if g:atp_python_toc
        let num = get(s:numberdict, MainFile, 'no_number')
    else
        let num = get(s:numberdict, t:atp_bufname, 'no_number')
    endif
    if num == 'no_number'
	exe cwinnr."wincmd w"
	return
    endif
    let lazyredraw = &lazyredraw
    let eventignore=&eventignore
    set lazyredraw
    set eventignore=all
    if g:atp_python_toc
        let sorted = t:atp_pytoc[MainFile]
    else
        let sorted = sort(keys(t:atp_toc[t:atp_bufname]), "atplib#CompareNumbers")
    endif
    let num_list = [0]
    let f_test = ( t:atp_bufname == atplib#FullPath(getbufvar(bufnr(t:atp_bufname), "atp_MainFile")) )
    for ind in range(0,len(sorted)-1)
	let line_l = sorted[ind]
        if g:atp_python_toc
	    " t:atp_bufname buffer from which :TOC was invoked.
	    let f_test_p = f_test
	    let f_test   = ( !f_test && t:atp_bufname == line_l[0] ? 1 : f_test )
	    if f_test && !f_test_p
		call add(num_list, ind+1)
	    endif
	    if t:atp_bufname == line_l[0] && (str2nr(cline) >= str2nr(line_l[1]))
		call add(num_list, ind+1)
	    endif
        else
            let line = line_l
            if cline>=line
                let num+=1
            else
                break
            endif
        endif
    endfor
    let savedview = winsaveview()
    if g:atp_python_toc
	let savedview = winsaveview()
	let num = max(num_list)+1
	keepjumps call setpos('.', [0,0,0,0])
	keepjumps call search('^'.escape(fnamemodify(MainFile, ":t"), '.\/').'\s\+(.*)\s*$', 'cW')
	call cursor(line(".")+(num-1),1)
    else
	keepjumps call setpos('.',[bufnr(""),num,1,0])
    endif
    if line(".") == savedview['lnum']
	call winrestview(savedview)
    endif

    call atplib#tools#CursorLine()

    exe cwinnr."wincmd w"
    let &eventignore = eventignore
    let &lazyredraw = lazyredraw
    let g:time_UpdateTocLine = reltimestr(reltime(time))
endfunction
" This is User Front End Function 
" atplib#motion#TOC {{{2
function! atplib#motion#TOC(bang,...)
    let time = reltime()
    " skip generating t:atp_toc list if it exists and if a:0 != 0
    if &l:filetype != 'tex' && &l:filetype != 'toc_atp'   
	echoerr "Wrong 'filetype'. This command works only for latex documents."
	return
    endif
    if a:0 == 0 
	call atplib#motion#buflist()
    endif
    let search_package = ( a:0 >= 2 ? a:2 : 1 ) " avoid using atplib#search#SearchPackage() in atplib#motion#maketoc()
    " for each buffer in t:atp_toc_buflist (set by atplib#motion#buflist)
    if ( a:bang == "!" || !exists("t:atp_toc") || g:atp_python_toc )
	if !g:atp_python_toc
	    let t:atp_toc = {}
	else
	    let t:atp_pytoc = {}
	endif
	for buffer in t:atp_toc_buflist 
            if g:atp_python_toc
		update
                call extend(t:atp_pytoc, atplib#motion#maketoc_py(buffer,search_package))
            else
                call extend(t:atp_toc, atplib#motion#maketoc(buffer,search_package))
            endif
	endfor
    endif
    if g:atp_python_toc
        call atplib#motion#show_pytoc(t:atp_pytoc)
    else
        call atplib#motion#showtoc(t:atp_toc)
    endif
    let g:time_TOC = reltimestr(reltime(time))
endfunction
nnoremap <Plug>ATP_TOC			:call atplib#motion#TOC("")<CR>

" This finds the name of currently eddited section/chapter units. 
" {{{2 atplib#motion#NearestSection
" This function finds the section name of the current section unit with
" respect to the dictionary a:section={ 'line number' : 'section name', ... }
" it returns the [ section_name, section line, next section line ]
function! atplib#motion#NearestSection(section)
    let cline=line('.')

    let sorted=sort(keys(a:section), "atplib#CompareNumbers")
    let x=0
    while x<len(sorted) && sorted[x]<=cline
       let x+=1 
    endwhile
    if x>=1 && x < len(sorted)
	let section_name=a:section[sorted[x-1]]
	return [section_name, sorted[x-1], sorted[x]]
    elseif x>=1 && x >= len(sorted)
	let section_name=a:section[sorted[x-1]]
	return [section_name,sorted[x-1], line('$')]
    elseif x<1 && x < len(sorted)
	" if we are before the first section return the empty string
	return ['','0', sorted[x]]
    elseif x<1 && x >= len(sorted)
	return ['', '0', line('$')]
    endif
endfunction
" {{{2 atplib#motion#ctoc
function! atplib#motion#ctoc()
    if &l:filetype != 'tex' || expand("%:e") != 'tex'
	return []
    endif
    " resolve the full path:
    let t:atp_bufname = expand("%:p")
    
    " if t:atp_toc(t:atp_bufname) exists use it otherwise make it 
    if !exists("t:atp_toc") || !has_key(t:atp_toc, t:atp_bufname) 
	if !exists("t:atp_toc")
	    let t:atp_toc = {}
	endif
	call extend(t:atp_toc, atplib#motion#maketoc(t:atp_bufname))
    endif

    " l:count where the preambule ends
    let buffer=getbufline(bufname("%"),"1","$")
    let i=0
    let line=buffer[0]
    while line !~ '\\begin\s*{document}' && i < len(buffer)
	let line=buffer[i]
	if line !~ '\\begin\s*{document}' 
	    let i+=1
	endif
    endwhile
	
    " if we are before the '\\begin{document}' line: 
    if line(".") <= i
	let return=['Preambule']
	return return
    endif

    let chapter={}
    let section={}
    let subsection={}

    for key in keys(t:atp_toc[t:atp_bufname])
	if t:atp_toc[t:atp_bufname][key][0] == 'chapter'
	    " return the short title if it is provided
	    if t:atp_toc[t:atp_bufname][key][4] != ''
		call extend(chapter, {key : t:atp_toc[t:atp_bufname][key][4]},'force')
	    else
		call extend(chapter, {key : t:atp_toc[t:atp_bufname][key][2]},'force')
	    endif
	elseif t:atp_toc[t:atp_bufname][key][0] == 'section'
	    " return the short title if it is provided
	    if t:atp_toc[t:atp_bufname][key][4] != ''
		call extend(section, {key : t:atp_toc[t:atp_bufname][key][4]},'force')
	    else
		call extend(section, {key : t:atp_toc[t:atp_bufname][key][2]},'force')
	    endif
	elseif t:atp_toc[t:atp_bufname][key][0] == 'subsection'
	    " return the short title if it is provided
	    if t:atp_toc[t:atp_bufname][key][4] != ''
		call extend(subsection, {key : t:atp_toc[t:atp_bufname][key][4]},'force')
	    else
		call extend(subsection, {key : t:atp_toc[t:atp_bufname][key][2]},'force')
	    endif
	endif
    endfor

    " Remove $ from chapter/section/subsection names to save the space.
    let chapter_name=substitute(atplib#motion#NearestSection(chapter)[0],'\$\|\\(\|\\)','','g')
    let chapter_line=atplib#motion#NearestSection(chapter)[1]
    let chapter_nline=atplib#motion#NearestSection(chapter)[2]

    let section_name=substitute(atplib#motion#NearestSection(section)[0],'\$\|\\(\|\\)','','g')
    let section_line=atplib#motion#NearestSection(section)[1]
    let section_nline=atplib#motion#NearestSection(section)[2]

    let subsection_name=substitute(atplib#motion#NearestSection(subsection)[0],'\$\|\\(\|\\)','','g')
    let subsection_line=atplib#motion#NearestSection(subsection)[1]
    let subsection_nline=atplib#motion#NearestSection(subsection)[2]

    let names	= [ chapter_name ]
    if (section_line+0 >= chapter_line+0 && section_line+0 <= chapter_nline+0)
	call add(names, section_name) 
    else
	call add(names, '')
    endif
    if subsection_line+0 >= section_line+0 && subsection_line+0 <= section_nline+0
	call add(names, subsection_name)
    else
	call add(names, '')
    endif
    return names
endfunction
" Labels Front End Finction. The search engine/show function are in autoload/atplib.vim script
" library.
" }}}1

" {{{1 atplib#motion#Labels
" a:bang = "!" do not regenerate labels if not necessary
function! atplib#motion#Labels(bang)
    let t:atp_bufname	= expand("%:p")
    let error		= ( exists("b:atp_TexReturnCode") ? b:atp_TexReturnCode : 0 )
    let atp_MainFile	= atplib#FullPath(b:atp_MainFile)

    " Generate the dictionary with labels
    if a:bang == "" || ( a:bang == "!" && !exists("t:atp_labels") ) ||
		\ ( a:bang == "!" && exists("t:atp_labels") && get(t:atp_labels, atp_MainFile, []) == [] )
	let [ t:atp_labels, b:ListOfFiles ] =  atplib#tools#generatelabels(atp_MainFile, 1)
    endif

    " Show the labels in seprate window
    call atplib#tools#showlabels([ t:atp_labels, map(extend([b:atp_MainFile], copy(b:ListOfFiles)), 'atplib#FullPath(v:val)')])

    if error
	echohl WarningMsg
	redraw
	echomsg "[ATP:] the compelation contains errors, aux file might be not appriopriate for labels window."
	echohl None
    endif
endfunction
nnoremap <Plug>ATP_Labels		:call atplib#motion#Labels("")<CR>

" atplib#motion#GotoLabel {{{1
" a:bang = "!" do not regenerate labels if not necessary
" This is developed for one tex project in a vim.
function! atplib#motion#GotoLabel(bang,...)

    let alabel = ( a:0 == 0 ? "" : a:1 )

    let atp_MainFile	= atplib#FullPath(b:atp_MainFile)
    " Generate the dictionary with labels
    if a:bang == "" || ( a:bang == "!" && ( !exists("b:ListOfFiles") || !exists("t:atp_labels") ) )
	let [ t:atp_labels, b:ListOfFiles ] =  atplib#tools#generatelabels(atp_MainFile, 1)
    endif

    let matches = []
    for file in keys(t:atp_labels)
	if index(b:ListOfFiles, fnamemodify(file, ":t")) != -1 || index(b:ListOfFiles, file) != -1 || file == atplib#FullPath(b:atp_MainFile)
	    for label in t:atp_labels[file]
		if label[1] =~ alabel || label[2] =~ '^'.alabel
		    call add(matches, extend([file], label))
		endif
	    endfor
	endif
    endfor

    if len(matches) == 0
	redraw
	echohl WarningMsg
	echomsg "[ATP:] no matching label"
	echohl None
	return 1
    elseif len(matches) == 1
	let file=matches[0][0]
	let line=matches[0][1]
    else
" 	if len(keys(filter(copy(b:TypeDict), 'v:val == "input"'))) == 0
	    let mlabels=map(copy(matches), "[(index(matches, v:val)+1).'.', v:val[2],v:val[3]]")
" 	else
" 	Show File from which label comes
" 	The reason to not use this is as follows: 
" 		it only matters for project files, which probably have many
" 		labels, so it's better to make the list as concise as possible
" 	    let mlabels=map(copy(matches), "[(index(matches, v:val)+1).'.', v:val[2], v:val[3], fnamemodify(v:val[0], ':t')]")
" 	    let file=1 
" 	endif
	echohl Title
	echo "Which label to choose?"
	echohl None
" 	let mlabels= ( file ? extend([[' nr', 'LABEL', 'LABEL NR', 'FILE']], mlabels) : extend([[' nr', 'LABEL', 'LABEL NR']], mlabels) )
	for row in atplib#FormatListinColumns(atplib#Table(mlabels, [1,2]),2)
	    echo join(row)
	endfor
	let nr = input("Which label to choose? type number and press <Enter> ")-1
	if nr < 0 || nr >= len(matches)
	    return
	endif
	let file=matches[nr][0]
	let line=matches[nr][1]
    endif

    " Check if the buffer is loaded.
    if bufloaded(file)
	execute "b " . file
	call cursor(line,1)
    else
	execute "edit " . file
	call cursor(line,1)
    endif
endfunction
" atplib#motion#GotoLabelCompletion {{{1
function! atplib#motion#GotoLabelCompletion(ArgLead, CmdLine, CursorPos)

    let atp_MainFile	= atplib#FullPath(b:atp_MainFile)
    " Generate the dictionary with labels (only if it doesn't exist)
    if !exists("t:atp_labels") || t:atp_labels == {} || !exists("b:ListOfFiles") || a:CmdLine !~# '^GotoLabel!'
	let [ t:atp_labels, b:ListOfFiles ] =  atplib#tools#generatelabels(atp_MainFile, 1)
" It would be nice to delete the ! from the cmdline after this step. There are
" only getcmdline(), getcmdpos() and setcmdpos() functions available.
	let cmd_line=substitute(getcmdline(), "GotoLabel!", "GotoLabel", "")
    endif

    let labels=[]
    for file in keys(t:atp_labels)
	if index(b:ListOfFiles, fnamemodify(file, ":t")) != -1 || index(b:ListOfFiles, file) != -1 || file == atplib#FullPath(b:atp_MainFile)
	    call extend(labels, map(deepcopy(t:atp_labels)[file], 'v:val[1]'))
	    call extend(labels, map(deepcopy(t:atp_labels)[file], 'v:val[2]'))
	endif
    endfor
    call filter(labels, "v:val !~ '^\s*$' && v:val =~ a:ArgLead ")

    return map(labels, "v:val.'\\>'")
endfunction
" atplib#motion#LatexTags {{{1
function! atplib#motion#LatexTags(bang,...)
    " a:1 == 1 :  silent
    if stridx(expand("%"), 'fugitive://') == 0
	return
    endif
    let silent = ( ( a:0 ? a:1 : 0 ) ? ' --silent ' : ' ' )
    let hyperref_cmd = ( atplib#search#SearchPackage("hyperref") ? " --hyperref " : "" )
    if has("clientserver")
	let servername 	= " --servername ".v:servername." "
	let progname	= " --progname ".v:progname." " 
    else
	let servername 	= ""
	let progname	= ""
    endif
    let bibtags = ( a:bang == "" ? " --bibtags " : "" )
    " Write file:
    call atplib#write('nobackup')

    let latextags=split(globpath(&rtp, "ftplugin/ATP_files/latextags.py"), "\n")[0]
    let files=join(
		\ map([b:atp_MainFile]+filter(copy(keys(b:TypeDict)), "b:TypeDict[v:val] == 'input'"), 'atplib#FullPath(v:val)')
		\ , ";")
    
    if len(filter(copy(keys(b:TypeDict)), "b:TypeDict[v:val] == 'bib'")) >= 1
	let bibfiles=join(filter(copy(keys(b:TypeDict)), "b:TypeDict[v:val] == 'bib'"), ";")
	let bib= " --bibfiles ".shellescape(bibfiles) 
    else
	let bib= " --bibtags_env "
    endif
    let dir 	= expand("%:p:h")
    if atplib#search#SearchPackage("biblatex")
	let cite = " --cite biblatex "
    elseif atplib#search#SearchPackage("natbib")
	let cite = " --cite natbib "
    else
	let cite = " "
    endif

    let cmd=g:atp_Python." ".shellescape(latextags).
		\ " --files ".shellescape(files).
		\ " --auxfile ".shellescape(atplib#joinpath(expand(b:atp_OutDir), fnamemodify(b:atp_MainFile, ":t:r").".aux")).
		\ " --dir ".shellescape(dir).
		\ bib . cite . silent .
		\ hyperref_cmd . servername . progname . bibtags . " &"
    if g:atp_debugLatexTags
	let g:cmd=cmd
    endif
    call system(cmd)
endfunction
"{{{1 atplib#motion#GotoDestination
function! atplib#motion#GotoNamedDestination(destination)
    if b:atp_Viewer !~ '^\s*xpdf\>' 
	echomsg "[ATP:] this only works with Xpdf viewer."
	return 0
    endif
    let cmd='xpdf -remote '.b:atp_XpdfServer.' -exec gotoDest\("'.a:destination.'"\)'
    call system(cmd)
endfunction
function! atplib#motion#FindDestinations()
    let files = [ b:atp_MainFile ]
    if !exists("b:TypeDict")
	call TreeOfFiles(b:atp_MainFile)
    endif
    for file in keys(b:TypeDict)
	if b:TypeDict[file] == 'input'
	    call add(files, file)
	endif
    endfor
    let saved_loclist = getloclist(0)
    exe 'lvimgrep /\\hypertarget\>/gj ' . join(map(files, 'fnameescape(v:val)'), ' ') 
    let dests = []
    let loclist	= copy(getloclist(0))
    call setloclist(0, saved_loclist)
    for loc in loclist
	let destname = matchstr(loc['text'], '\\hypertarget\s*{\s*\zs[^}]*\ze}')
	call add(dests, destname)
    endfor
    return dests
endfunction
function! atplib#motion#CompleteDestinations(ArgLead, CmdLine, CursorPos)
    let dests=atplib#motion#FindDestinations()
    return join(dests, "\n")
endfunction

" Motion functions through environments and sections. 
"  atplib#motion#GotoEnvironment {{{1
" which name is given as the argument. Do not wrap
" around the end of the file.
function! atplib#motion#GotoEnvironment(flag,count,...)

    " Options :
    let env_name 	= ( a:0 >= 1 && a:1 != ""  ? a:1 : '[^}]*' )
    if env_name == 'part'
	if a:flag =~ 'b'
	    exe a:count.'PPart'
	    return
	else
	    exe a:count.'NPart'
	    return
	endif
    elseif env_name  == 'chapter' 
	if a:flag =~ 'b'
	    exe a:count.'PChap'
	    return
	else
	    exe a:count.'NChap'
	    return
	endif
    elseif env_name == 'section' 
	if a:flag =~ 'b'
	    exe a:count.'PSec'
	    return
	else
	    exe a:count.'NSec'
	    return
	endif
    elseif env_name == 'subsection' 
	if a:flag =~ 'b'
	    exe a:count.'PSSec'
	    return
	else
	    exe a:count.'NSSec'
	    return
	endif
    elseif env_name == 'subsubsection' 
	if a:flag =~ 'b'
	    exe a:count.'PSSSec'
	    return
	else
	    exe a:count.'NSSSec'
	    return
	endif
    endif

    let flag = a:flag
    
    " Set the search tool :
    " Set the pattern : 
    if env_name == 'math'
	let pattern = '\m\%(\(\\\@<!\\\)\@<!%.*\)\@<!\%(\%(\\begin\s*{\s*\%(\(displayed\)\?math\|\%(fl\)\?align\|eqnarray\|equation\|gather\|multline\|subequations\|xalignat\|xxalignat\)\s*\*\=\s*}\)\|\\\@<!\\\[\|\\\@<!\\(\|\\\@<!\$\$\=\)'
	let pattern_zs = '\m\%(\(\\\@<!\\\)\@<!%.*\)\@<!\%(\%(\\begin\s*\zs{\s*\%(\(displayed\)\?math\|\%(fl\)\?align\|eqnarray\|equation\|gather\|multline\|subequations\|xalignat\|xxalignat\)\s*\*\=\s*}\)\|\\\@<!\\\[\|\\\@<!\\(\|\\\@<!\$\$\=\)'
    elseif env_name == 'displayedmath'
	let pattern = '\m\%(\(\\\@<!\\\)\@<!%.*\)\@<!\%(\%(\\begin\s*{\s*\%(displayedmath\|\%(fl\)\?align\*\=\|eqnarray\*\=\|equation\*\=\|gather\*\=\|multline\*\=\|xalignat\*\=\|xxalignat\*\=\)\s*}\)\|\\\@<!\\\[\|\\\@!\$\$\)'
	let pattern_zs = '\m\%(\(\\\@<!\\\)\@<!%.*\)\@<!\%(\%(\\begin\zs\s*{\s*\%(displayedmath\|\%(fl\)\?align\*\=\|eqnarray\*\=\|equation\*\=\|gather\*\=\|multline\*\=\|xalignat\*\=\|xxalignat\*\=\)\s*}\)\|\\\@<!\\\[\|\\\@!\$\$\)'
    elseif env_name == 'inlinemath'
	let pattern = '\m\%(\(\\\@<!\\\)\@<!%.*\)\@<!\%(\\begin\s*{\s*math\s*}\|\\\@<!\\(\|\$\@<!\\\@<!\$\$\@!\)'
	let pattern_zs = '\m\%(\(\\\@<!\\\)\@<!%.*\)\@<!\%(\\begin\s*\zs{\s*math\s*}\|\\\@<!\\(\|\$\@<!\\\@<!\$\$\@!\)'
    else
	let pattern = '\m\%(\(\\\@<!\\\)\@<!%.*\)\@<!\\begin\s*{\s*' . env_name 
	let pattern_zs = '\m\%(\(\\\@<!\\\)\@<!%.*\)\@<!\\begin\s*\zs{\s*' . env_name 
    endif


    " Search (twice if needed)
    for i in range(1, a:count)
	if i > 1
	    " the 's' flag should be used only in the first search. 
	    let flag=substitute(flag, 's', '', 'g') 
	endif
	if g:atp_mapNn
	    let search_cmd = "S /"
	    let search_cmd_e= "/ " . flag
	else
	    let search_cmd = "silent! call search('"
	    let search_cmd_e= "','" . flag . "')"
	endif
	if a:flag !~# 'b'
            execute  search_cmd . pattern . search_cmd_e
	    if getline(".")[col(".")-1] == "$" 
		if ( get(split(getline("."), '\zs'), col(".")-1, '') == "$" && get(split(getline("."), '\zs'), col("."), '') == "$" )
		    "check $$
		    let rerun = !atplib#complete#CheckSyntaxGroups(['texMathZoneY'], line("."), col(".")+1 )
		elseif get(split(getline("."), '\zs'), col(".")-1, '') == "$" 
		    "check $
		    let rerun = !atplib#complete#CheckSyntaxGroups(['texMathZoneX', 'texMathZoneY'], line("."), col(".") )
		endif
		if rerun
		    silent! execute search_cmd . pattern . search_cmd_e
		endif
	    endif
	else " a:flag =~# 'b'
            execute  search_cmd . pattern_zs . search_cmd_e
            call search(pattern, 'bc', line("."))
	    if getline(".")[col(".")-1] == "$" 
		if ( get(split(getline("."), '\zs'), col(".")-1, '') == "$" && get(split(getline("."), '\zs'), col(".")-2, '') == "$" )
		    "check $$
		    let rerun = atplib#complete#CheckSyntaxGroups(['texMathZoneY'], line("."), col(".")-3 )
		elseif get(split(getline("."), '\zs'), col(".")-1, '') == "$" 
		    "check $
		    let rerun = atplib#complete#CheckSyntaxGroups(['texMathZoneX', 'texMathZoneY'], line("."), col(".")-2 )
		endif
		if rerun
		    silent! execute search_cmd . pattern_zs . search_cmd_e
                    call search(pattern, 'bc', line("."))
		endif
	    endif
	endif
    endfor

    call atplib#motion#UpdateToCLine()
    silent! call histadd("search", pattern)
    silent! let @/  = pattern
    return ""
endfunction
" atplib#motion#GotoFrame {{{1
function! atplib#motion#GotoFrame(f, count)
    let lz=&lazyredraw
    set lazyredraw
    if a:f == "backward"
	call atplib#motion#GotoEnvironment('bsW', a:count, 'frame')
    else
	call atplib#motion#GotoEnvironment('sW', a:count, 'frame')
    endif
    normal! zt
    let &lz=lz
endfunction
nnoremap <Plug>NextFrame	:<C-U>call atplib#motion#GotoFrame('forward', v:count1)<CR>
nnoremap <Plug>PreviousFrame	:<C-U>call atplib#motion#GotoFrame('backward', v:count1)<CR>
" atplib#motion#JumptoEnvironment {{{1 
" Good for going through all \begin:\end pairs in a given envionrment, without
" visiting child nodes.
function! atplib#motion#JumptoEnvironment(forward, ...)
    let cnt = (a:0>=1 ? a:1 : 1)
    k`
    call setpos("''", getpos("."))
    let lazyredraw=&l:lazyredraw
    set lazyredraw
    if a:forward
	" let min = max([0, col(".")-6])
	" let max = min([col(".")+5, len(getline(line(".")))])
	" if getline(line("."))[(min):(max)] =~ '\\begin\>'
	    " If on \begin moved to the start of it.
	    call search('\\begin\>\(.*\\end\>\)\@!', 'b', line('.'))
	" endif
	for i in range(cnt)
	    if !i && getline(".")[col(".")-1:] !~ '^\\begin\s*{'
		call search('^\%([^%]\|\\%\)*\zs\\begin\>', 'W')
	    else
		call searchpair('\\begin\s*{\s*\%(document\>\)\@!', '', '\\end\s*{\s*\%(document\>\)\@!', 'W')
		call search('^\%([^%]\|\\%\)*\zs\\begin\>', 'W')
	    endif
	endfor
    else
	" let min = max([0, col(".")-6])
	" let max = min([col(".")+5, len(getline(line(".")))])
	" if getline(line("."))[(min):(max)] =~ '\\begin\>'
	    " If on \begin moved to the start of it.
	    call search('\\begin\>\(.*\\end\>\)\@!', 'b', line('.'))
	" endif
	for i in range(cnt)
	    call search('^\%([^%]\|\\%\)*\zs\\\%(begin\|end\)\>', 'Wb')
	    if getline(".")[col(".")-1:] =~ '^\\end\s*{'
		call LaTeXBox_JumpToMatch('n', 0, 0)
	    endif
	endfor
    endif
    let &l:lazyredraw=lazyredraw
endfunction 
" atplib#motion#FastJumptoEnvironment {{{1 
" Good for going up one level omittig current nodes.
function! atplib#motion#FastJumptoEnvironment(forward, ...)
    let cnt = (a:0>=1 ? a:1 : 1)
    k`
    call setpos("''", getpos("."))
    let lazyredraw=&l:lazyredraw
    set lazyredraw
    if a:forward
	call search('\\begin\>\(.*\\end\>\)\@!', 'b', line('.'))
	for i in range(cnt)
	    let ppos = getpos(".")[1:2]
	    call searchpair('\\begin\s*\zs{\s*\%(document\>\)\@!', '', '\\end\s*{\s*\%(document\>\)\@!', 'W')
	    call search('\\begin\>\(.*\\end\>\)\@!', 'b', line('.'))
	    let pos = getpos(".")[1:2]
	    if pos == ppos
		call searchpair('\\begin\s*{\s*\%(document\>\)\@!', '', '\\end\s*{\s*\%(document\>\)\@!', 'W')
	    endif
	    call search('^\%([^%]\|\\%\)*\zs\\begin\>', 'W')
	endfor
    else
	call search('\\begin\>\(.*\\end\>\)\@!', 'b', line('.'))
	for i in range(cnt)
	    let ppos = getpos(".")[1:2]
	    call searchpair('\\begin\s*{\s*\zs\%(document\>\)\@!', '', '\\end\s*{\s*\%(document\>\)\@!', 'Wb')
	    call search('\\begin', 'b', line('.'))
	    let pos = getpos(".")[1:2]
	    if  ppos == pos
		call search('\\end\s*{\s*\%(document\>\)\@!', 'Wb')
		if pos != getpos(".")[1:2]
		    call LaTeXBox_JumpToMatch('n', 0, 0)
		endif
	    endif
	endfor
    endif
    let &l:lazyredraw=lazyredraw
endfunction 
" atplib#motion#JumpOut {{{1 
function! atplib#motion#JumpOut(forward,count)
    k`
    call setpos("''", getpos("."))
    let lazyredraw=&l:lazyredraw
    set lazyredraw
    if a:forward
	let flags = 'W'
	" let limit = line(".")+g:atp_completion_limits[3]
    else
	let flags = 'Wb'
	" let limit = max([1, line(".")-g:atp_completion_limits[3]])
    endif
    let ppos = getpos(".")[1:2]
    let pos = searchpairpos('\\begin\s*{\s*\%(document\>\)\@!', '', '\\end\s*{\s*\%(document\>\)\@!', flags) " , '', limit)
    for i in range(a:count-1)
	let ppos = pos
	if a:forward
	    let limit = line(".")+g:atp_completion_limits[3]
	else
	    let limit = max([1, line(".")-g:atp_completion_limits[3]])
	endif
	let pos =  searchpairpos('\\begin\s*{\s*\%(document\>\)\@!', '', '\\end\s*{\s*\%(document\>\)\@!', flags) " , '', limit)
	if pos == ppos
	    break
	endif
    endfor
    let &l:lazyredraw=lazyredraw
endfunction 
" atplib#motion#FastJumpOut {{{1 
function! atplib#motion#FastJumpOut(forward)
    k`
    let s_pos = getpos(".")[1:2]
    let lazyredraw=&l:lazyredraw
    set lazyredraw
    if a:forward
	let flags = 'W'
	let limit = line(".")+g:atp_completion_limits[3]
    else
	let flags = 'Wb'
	let limit = max([1, line(".")-g:atp_completion_limits[3]])
    endif
    let ppos = getpos(".")[1:2]
    let pos = searchpairpos('\\begin\s*{\s*\%(document\>\)\@!', '', '\\end\s*{\s*\%(document\>\)\@!', flags, '', limit)
    while pos != ppos
	let ppos = pos
	if a:forward
	    let limit = line(".")+g:atp_completion_limits[3]
	else
	    let limit = max([1, line(".")-g:atp_completion_limits[3]])
	endif
	let pos =  searchpairpos('\\begin\s*{\s*\%(document\>\)\@!', '', '\\end\s*{\s*\%(document\>\)\@!', flags, '', limit)
    endwhile
    if getpos(".")[1:2] == s_pos
	echohl ErrorMsg
	if a:forward
	    echom '[ATP]: End not found within limits. Try ]o or enlarge g:atp_completion_limits[3]='.g:atp_completion_limits[3].'.'
	else
	    echom '[ATP]: Begin not found within limits. Try [o or enlarge g:atp_completion_limits[3]='.g:atp_completion_limits[3].'.'
	endif
	echohl None
    endif
    let &l:lazyredraw=lazyredraw
endfunction 

" atplib#motion#GotoSection {{{1 
" The extra argument is a pattern to match for the
" section title. The first, obsolete argument stands for:
" part,chapter,section,subsection,etc.
" This commands wrap around the end of the file.
" with a:3 = 'vim' it uses vim search() function
" with a:3 = 'atp' 
" the default is: 
" 	if g:atp_mapNn then use 'atp'
" 	else use 'vim'.
function! atplib#motion#GotoSection(bang, count, flag, secname, ...)
    let search_tool		= ( a:0 >= 1 ? a:1	: ( g:atp_mapNn ? 'atp' : 'vim' ) )
    let mode			= ( a:0 >= 2 ? a:2	: 'n' )
    let title_pattern 		= ( a:0 >= 3 ? a:3	: ''  )
    let pattern = ( empty(a:bang) ? '^\([^%]\|\\\@<!\\%\)*' . a:secname . title_pattern : a:secname . title_pattern )

    if getline(line(".")) =~ pattern
	" If we are on the line that matches go to begining of this line, so
	" that search will find previous match unless the flag contains 'c'.
	call cursor(line("."), 1)
    endif

    " This is not working ?:/
    " just because it goes back to the mark '< and searches again:
"     if mode == 'v' | call cursor(getpos("'<")[1], getpos("'<")[2]) | endif
"     if mode == 'v' && visualmode() ==# 'V'
" 	normal! V
"     elseif mode == 'v' 
" 	normal! v
"     endif
"     let bpat = ( mode == 'v' 	? "\\n\\s*" : "" ) 
    let bpat 	= "" 
    let flag	= a:flag
    for i in range(1,a:count)
	if i > 1
	    " the 's' flag should be used only in the first search. 
	    let flag=substitute(flag, 's', '', 'g') 
	endif
	if search_tool == 'vim'
	    call searchpos(bpat . pattern, flag)
	else
	    execute "S /". bpat . pattern . "/ " . flag 
	endif
    endfor

    call atplib#motion#UpdateToCLine()
    call histadd("search", pattern)
    let @/ = pattern
endfunction
function! atplib#motion#Env_compl(A,P,L) 
    let envlist=sort(['algorithm', 'algorithmic', 'abstract', 'definition', 'equation', 'proposition', 
		\ 'theorem', 'lemma', 'array', 'tikzpicture', 
		\ 'tabular', 'table', 'align', 'alignat', 'proof', 
		\ 'corollary', 'enumerate', 'examples\=', 'itemize', 'remark', 
		\ 'notation', 'center', 'quotation', 'quote', 'tabbing', 
		\ 'picture', 'math', 'displaymath', 'minipage', 'list', 'flushright', 'flushleft', 
		\ 'frame', 'figure', 'eqnarray', 'thebibliography', 'titlepage', 
		\ 'verbatim', 'verse', 'inlinemath', 'displayedmath', 'subequations',
		\ 'part', 'section', 'subsection', 'subsubsection' ])
    let returnlist=[]
    for env in envlist
	if env =~ '^' . a:A 
	    call add(returnlist,env)
	endif
    endfor
    return returnlist
endfunction

function! atplib#motion#ggGotoSection(count,section)
    let mark  = getpos("''")
    if a:section == "part"
	let secname = '\\part\>'
	call cursor(1,1)
    elseif a:section == "chapter"
	let secname = '\\\%(part\|chapter\)\>'
	if !search('\\part\>', 'bc')
	    call cursor(1,1)
	endif
    elseif a:section == "section"
	let secname = '\\\%(part\|chapter\|section\)\>'
	if !search('\\chapter\>\|\\part\>', 'bc')
	    call cursor(1,1)
	endif
    elseif a:section == "subsection"
	let secname = '\\\%(part\|chapter\|section\|subsection\)\>'
	if !search('\\section\>\|\\chapter\>\|\\part\>', 'bc')
	    call cursor(1,1)
	endif
    elseif a:section == "subsubsection"
	let secname = '\\\%(part\|chapter\|section\|subsection\|subsubsection\)\>'
	if !search('\subsection\>\|\\section\>\|\\chapter\>\|\\part\>', 'bc')
	    call cursor(1,1)
	endif
    endif
    call atplib#motion#UpdateToCLine()
    call atplib#motion#GotoSection("", a:count, 'Ws', secname)
    call setpos("''",mark)
endfunction

" atplib#motion#Input {{{1 
function! atplib#motion#Input(flag, count)
    let pat 	= ( &l:filetype == "plaintex" ? '\\input\s*{' : '\%(\\input\s*{\=\>'.(atplib#search#SearchPackage('subfiles') ?  '\|\\subfile\s*{' : '' ).'\|\\include\s*{\)' )
    let @/	= '^\([^%]\|\\\@<!\\%\)*' . pat
    if stridx(a:flag, 'b') != -1
	let ww=&ww
	set ww+=h
	normal h
	let &ww=ww
    endif
    for i in range(a:count)
	if g:atp_mapNn
	    exe ':S /^\([^%]\|\\\@<!\\%\)*' .  pat . '/ ' . a:flag
	else
	    call search('^\([^%]\|\\\@<!\\%\)*' . pat, a:flag)
	endif
    endfor
    call atplib#motion#UpdateToCLine()
    "     This pattern is quite simple and it might be not neccesary to add it to
    "     search history.
    "     call histadd("search", pat)
endfunction
" atplib#motion#GotoFile {{{1
" This function also sets filetype vim option.
" It is useing '\f' pattern thus it depends on the 'isfname' vim option.
try
    " NOTE: if the filetype is wrong the path will not be recognized
    " 		it is better to make it syntax independet!
    "
    " It let choose if there are multiple files only when this is fast
    " (\input{,\input ) methods. However, then the file name should be unique! 

    " It correctly sets b:atp_MainFile, and TreeOfFiles, ... variables in the new
    " buffer.
function! atplib#motion#GotoFile(bang,args,...)

    let edit_args = matchstr(a:args, '\zs\%(++\=\%(\%(\\\@<!\s\)\@<!.\)*\s*\)\=')
    let find_args = matchstr(a:args, '+/\(\(\\\@<!\s\)\@<!.\)*')
    let edit_args = substitute(edit_args, '+/\(\(\\\@<!\s\)\@<!.\)*', '', 'g')
    let file	= matchstr(matchstr(a:args, '\%(\\\@<!\s[^+]\)\=\%(\%(\\\@<!\s\)\@<!.\)*\s*'), '\s*\zs.*')
    let cwd	= getcwd()
    exe "lcd " . fnameescape(b:atp_ProjectDir)
    let atp_MainFile	= atplib#FullPath(b:atp_MainFile)

    " The default value is to check line if not stending on a comment.
    let check_line	= ( a:0 >= 1 ? a:1 : strpart(getline("."), 0, col(".")) !~ '\(\\\@<!\\\)\@<!%' )

    if !has("path_extra")
	echoerr "Needs +path_extra vim feature."
	exe "lcd " . cwd
	return
    endif	

    let filetype 	= &l:filetype

    if a:bang == "!" || !exists("b:TreeOfFiles") || !exists("b:ListOfFiles") || !exists("b:TypeDict") || !exists("b:LevelDict") 
	let [tree_d, file_l, type_d, level_d ] 	= TreeOfFiles(atp_MainFile)
    else
	let [tree_d, file_l, type_d, level_d ] 	= deepcopy([ b:TreeOfFiles, b:ListOfFiles, b:TypeDict, b:LevelDict ])
    endif

    " This is passed to the newly opened buffer.
    let projectVarDict = SaveProjectVariables()

    let file_l_orig = deepcopy(file_l)

    " Note: line is set to "" if check_line == 0 => method = "all" is used. 
    let line		= ( check_line ? getline(".") : "" )
    if check_line
	let beg_line	= strpart(line, 0,col(".")-1)
	" Find the begining column of the file name:
	let bcol	= searchpos('\%({\|,\)', 'bn',  line("."))[1]
	if bcol == 0
	    let bcol 	= searchpos('{', 'n', line("."))[1]
	endif

	" Find the end column of the file name
	let col		= searchpos(',\|}', 'cn', line("."))[1]
	" Current column
	let cur_col		= col(".")
    endif

    " This part will be omitted if check_line is 0 (see note above).
    " \usepackege{...,<package_name>,...}
    if line =~ '\\usepackage' && g:atp_developer
	let method = "usepackage"
	let ext 	= '.sty'

	let fname   	= atplib#append_ext(strpart(getline("."), bcol, col-bcol-1), ext)
	let file 	= atplib#search#KpsewhichFindFile('tex', fname, '', 1)
	let file_l	= [ file ]

	let message = "Pacakge: "
	let options = ""

    " \input{...}, \include{...}
    elseif line =~ '\\\(input\|include\|subfile\)\s*{' 
	let method = "input{"
	let ext 	= '.tex'

	" \input{} doesn't allow for {...,...} many file path. 
	let fname 	= atplib#append_ext(strpart(getline("."), bcol, col-bcol-1), '.tex')

	" The 'file . ext' might be already a full path.
	if fnamemodify(fname, ":p") != fname
	    let file_l 	= atplib#search#KpsewhichFindFile('tex', fname, g:atp_texinputs, -1, ':p', '^\(\/home\|\.\)', '\%(^\/usr\|kpsewhich\|texlive\|miktex\)')
	    let file	= get(file_l, 0, 'file_missing')
	else
	    let file_l	= [ fname ] 
	    let file	= fname
	endif


	let message = "File: "
	let options = ""

    " \input 	/without {/
    elseif line =~ '\\input\s*{\@!'
	let method = "input"
	let fname	= atplib#append_ext(matchstr(getline(line(".")), '\\input\s*\zs\f*\ze'), '.tex')
	let file_l	= atplib#search#KpsewhichFindFile('tex', fname, g:atp_texinputs, -1, ':p', '^\(\/home\|\.\)', '\%(^\/usr\|kpsewhich\|texlive\)')
	let file	= get(file_l, 0, "file_missing")
	let options = ' +setl\ ft=' . &l:filetype  
    " \documentclass{...}
    elseif line =~ '\\documentclass' && g:atp_developer
	let method = "documentclass"
	let saved_pos	= getpos(".")
	call cursor(line("."), 1)
	call search('\\documentclass\zs', 'cb', line("."))
	let bcol	= searchpos('{', 'c', line("."))[1]
	execute "normal %"
	let ecol	= col(".")
	call cursor(saved_pos[0], saved_pos[1])
	let classname 	= strpart(getline("."), bcol, ecol-bcol-1)
	let fname	= atplib#append_ext(classname, '.cls')
	let file	= atplib#search#KpsewhichFindFile('tex', fname,  g:atp_texinputs, 1, ':p')
	let file_l	= [ file ]
	let options	= ""
    elseif line =~ '\\RequirePackage' && g:atp_developer
	let method = "requirepackage"
	let ext 	= '.sty'
	let fname	= atplib#append_ext(strpart(getline("."), bcol, col-bcol-1), ext)
	let file	= atplib#search#KpsewhichFindFile('tex', fname, g:atp_texinputs, 1, ':p')
	let file_l	= [ file ]
	let options = ' +setl\ ft=' . &l:filetype  
    elseif line =~ '\\bibliography\>'
	let method 	= "bibliography"
	setl iskeyword +=\
	let fname	= expand("<cword>")
	setl iskeyword -=\
	if fname == "\\bibliography"
	    let fname 	= matchstr(getline(line(".")), '\\bibliography{\zs[^},]*\ze\%(,\|}\)')
	endif
	let fname 	= atplib#append_ext(fname, '.bib')
	let file_l	= atplib#search#KpsewhichFindFile('bib', fname, g:atp_bibinputs, -1, ':p', '^\(\/home\|\.\)', '\%(^\/usr\|kpsewhich\|texlive\)')
	let file	= get(file_l, 0, "file_missing")
	let options = ' +setl\ ft=' . &l:filetype  
    else 
	" If not over any above give a list of input files to open, like
	" EditInputFile  
	let method	= "all"

	call extend(file_l, [ atp_MainFile ], 0)
	call extend(level_d, { atp_MainFile : 0 })
    endif

    if len(file_l) > 1 && file =~ '^\s*$'
	if method == "all"
	    let msg = "Which file to edit?"
	else
	    let msg = "Found many files. Which file to use?"
	endif
	let mods	= method == 'all' ? ":t" : ":p"
	" It is better to start numbering from 0,
	" then 	0 - is the main file 
	"	1 - is the first chapter, and so on.
	let i		= 0
	let input_l	= []
	for f in file_l
	    if exists("level_d")
		let space = ""
		if g:atp_RelativePath
		    exe "lcd " . fnameescape(b:atp_ProjectDir)
		    let level = get(level_d,fnamemodify(f, ':.'), get(level_d, f, 1))
		    exe "lcd " . fnameescape(cwd)
		else
		    exe "lcd " . fnameescape(b:atp_ProjectDir)
		    let level = get(level_d,f, get(level_d,fnamemodify(f, ':.'), 1))
		    exe "lcd " . fnameescape(cwd)
		endif
		for j in range(level)
		    let space .= "   "
		endfor
	    else
		space	= ""
	    endif
	    call add(input_l, "(" . i . ") " . space . fnamemodify(f, mods))
	    let i+=1
	endfor
	" Ask the user which file to edit:
	redraw
	if len([ msg ] + input_l) < &l:lines
	    for f in  [ msg ] + input_l
		" echo highlighted message
		if matchstr(f, '(\d\+)\s*\zs.*$') == expand("%:t")
		    echohl CursorLine
		elseif f == msg
		    echohl Title
		endif
		echo f
		if matchstr(f, '(\d\+)\s*\zs.*$') == expand("%:t") || f == msg
		    echohl None
		endif
	    endfor
	    let choice	= input("Type number and <Enter> (empty cancels): ")
	    if choice != "" 
		let choice	+= 1
	    endif
	elseif 
	    for line in [ msg ] + input_l
		if line == msg
		    echohl Title	
		endif
		echo line
		echohl None
	    endfor
	    echohl MoreMsg
	    let choice = input("Type number and <Enter> (empty cancels): ")
	    echohl None
	    if choice != "" 
		let choice	+= 1
	    endif
	endif
	" Remember: 0 == "" returns 1! 
	" char2nr("") = 0
	" nr2char(0) = ""
	if choice == ""
	    exe "lcd " . fnameescape(cwd)
	    return
	endif
	if choice < 1 || choice > len(file_l)
	    if choice < 1 || choice > len(file_l)
		echo "\n"
		echoerr "Choice out of range."
	    endif
	    exe "lcd " . fnameescape(cwd)
	    return
	endif
	let file 	= atplib#FullPath(file_l[choice-1])
	let fname 	= file
    elseif file !~ '^\s*$'
	let file 	= atplib#FullPath(file)
	let fname	= file
    endif

    if !exists("file")
	exe "lcd " . fnameescape(cwd)
	return
    endif

    if file != "file_missing" && filereadable(file) && ( !exists("choice") || exists("choice") && choice != 0 )

	" Inherit tex flavour.
	" So that bib, cls, sty files will have their file type (bib/plaintex).
	let filetype	= &l:filetype
	let old_file	= expand("%:p")
	execute "edit ".edit_args." ".escape(find_args, '\')." ".fnameescape(file)
	call RestoreProjectVariables(projectVarDict)
	if &l:filetype =~ 'tex$' && file =~ '\.tex$' && &l:filetype != filetype  
	    let &l:filetype	= filetype
	endif

	" Set the main file variable and pass the TreeOfFiles variables to the new
	" buffer.
	if exists("b:atp_ErrorFormat")
	    unlockvar b:atp_ErrorFormat
	endif
	return file
    else
	echohl ErrorMsg
	redraw
	if file != "file_missing" && exists("fname")
	    echo "File \'".fname."\' not found."
	else
	    echo "Missing file."
	endif
	echohl None

	exe "lcd " . fnameescape(cwd)
	return file
    endif
endfunction
catch /E127:/
endtry
function! atplib#motion#GotoFileComplete(ArgLead, CmdLine, CursorPos)
    let bang = ( a:CmdLine =~ '^\w*!' ? '!' : '')
    if bang == "!" || !exists("b:TreeOfFiles") || !exists("b:ListOfFiles") || !exists("b:TypeDict") || !exists("b:LevelDict") 
	let [tree_d, file_l, type_d, level_d ] 	= TreeOfFiles(atp_MainFile)
    else
	let [tree_d, file_l, type_d, level_d ] 	= deepcopy([ b:TreeOfFiles, b:ListOfFiles, b:TypeDict, b:LevelDict ])
    endif
    if index(file_l, b:atp_MainFile) == -1 || index(file_l, fnamemodify(b:atp_MailFile, ":p")) == -1 
	call add(file_l, b:atp_MainFile) 
    endif
    return  filter(file_l, "v:val =~ a:ArgLead")
endfunction
" atplib#motion#SkipComment {{{1
" a:flag=fb (f-forward, b-backward)
" f works like ]*
" b workd like [*
" Note: the 's' search flag is passed by the associated commands.
" This can be extended: 
" 	(1) skip empty lines between comments
function! atplib#motion#SkipComment(flag, mode, count, ...)
    let flag 	= ( a:flag =~ 'b' ? 'b' : '' ) 
    let nr	= ( a:flag =~ 'b' ? -1 : 1 )

    for c in range(1, a:count)
	let test = search('^\zs\s*%', flag)
	if !test
	    return
	endif
	call cursor(line("."), ( nr == -1 ? 1 : len(getline(line(".")))))

	let line	= getline(line("."))
	" find previous line
	let pline_nr=min([line("$"), max([1,line(".")+nr])])
	let pline	= getline(pline_nr) 

	while pline =~ '^\s*%' && line(".") != line("$") && line(".") != 1
	    call cursor(line(".")+nr, ( nr == -1 ? 1 : len(getline(line(".")+nr))))
	    let pline_nr=min([line("$"), max([1,line(".")+nr])])
	    let pline	= getline(pline_nr) 
	endwhile
	if a:mode == 'n' && ( !g:atp_VimCompatible || g:atp_VimCompatible =~? '\<no\>' )
	    if a:flag =~# 'b'
		call cursor(line(".")-1,1)
	    else
		call cursor(line(".")+1,1)
	    endif
	endif
	if a:mode == 'v'
	    let end_pos = [ line("."), col(".") ]
	    " Go where visual mode started
	    exe "normal `" . ( nr == 1 ? '<' : '>' ) 
	    exe "normal " . visualmode()
	    call cursor(end_pos)
	endif
    endfor
endfunction

" Syntax motion
" {{{1 atplib#motion#TexSyntaxMotion
function! atplib#motion#TexSyntaxMotion(forward, how, ...)

    " If the function is used in imap.
    let in_imap	= ( a:0 >= 1 ? a:1 : 0 )

    let whichwrap	= split(&l:whichwrap, ',')
    if !count(whichwrap, 'l') 
	setl ww+=l
    endif
    if !count(whichwrap, 'h')
	setl ww+=h
    endif

    " before we use <Esc> 
    let line=line(".")
    if in_imap && len(getline(".")) > col(".")
	let col = col(".")+1
    else
	let col = col(".")
    endif
"     execute "normal l"
    let step 		= ( a:forward > 0 ? "l" : "h" )
    let synstack	= map(synstack(line, col), 'synIDattr( v:val, "name")')
    let synstackh	= map(synstack(line, max([1, col-1])), 'synIDattr( v:val, "name")')

    let DelimiterCount	= count(synstack, 'Delimiter') 
    let ScriptCount	= count(synstack, 'texSuperscript') + count(synstack, 'texSubscript')
    let ScriptsCount	= count(synstack, 'texSuperscripts') + count(synstack, 'texSubscripts')
    let StatementCount	= count(synstack, 'texStatement')
    let StatementCounth	= count(synstackh, 'texStatement') && col(".") > 1
    let SectionCount	= count(synstack, 'texSection')

    let TypeStyleCount	= count(synstack, 'texTypeStyle')
    let TypeStyleCounth	= count(synstackh, 'texTypeStyle') && col(".") > 1
    let MathTextCount	= count(synstack, 'texMathText')
    let MathTextCounth	= count(synstackh, 'texMathText') && col(".") > 1
    let RefZoneCount	= count(synstack, 'texRefZone')
    let RefZoneCounth	= count(synstackh, 'texRefZone') && col(".") > 1 
    let RefOptionCount	= count(synstack, 'texRefOption')
    let RefOptionCounth	= count(synstackh, 'texRefOption') && !count(synstackh, 'Delimiter') && col(".") > 1
    let CiteCount	= count(synstack, 'texCite')
    let CiteCounth	= count(synstackh, 'texCite') && !count(synstackh, 'Delimiter') && col(".") > 1
    let MatcherCount 	= count(synstack, 'texMatcher')
    let MatcherCounth 	= count(synstackh, 'texMatcher') && !count(synstackh, 'Delimiter') && col(".") > 1
    let MathMatcherCount 	= count(synstack, 'texMathMatcher')
    let MathMatcherCounth 	= count(synstackh, 'texMathMatcher') && !count(synstackh, 'Delimiter') && col(".") > 1
    let SectionNameCount 	= count(synstack, 'texSectionName')
    let SectionNameCounth 	= count(synstackh, 'texSectionName') && !count(synstackh, 'Delimiter') && col(".") > 1
    let SectionMarkerCount 	= count(synstack, 'texSectionMarker')

    let SectionModifierCount 	= count(synstack, 'texSectionModifier')
    let SectionModifierCounth 	= count(synstackh, 'texSectionModifier') && !count(synstackh, 'Delimiter') && col(".") > 1
"     let MathZonesCount		= len(filter(copy(synstack), 'v:val =~ ''^texMathZone[A-Z]'''))

    if DelimiterCount 
	let syntax	= [ 'Delimiter' ]
    elseif StatementCount && StatementCounth && step == "h"
	let syntax	= [ 'texStatement' ]
    elseif StatementCount && step != "h"
	let syntax	= [ 'texStatement' ]
    elseif SectionCount 
	let syntax	= [ 'texSection' ]
    elseif ScriptCount
	if a:how == 1
	    let syntax	= [ 'texSuperscript', 'texSubscript']
	else
	    let syntax	= [ 'texSuperscripts', 'texSubscripts']
	endif
    elseif TypeStyleCount && TypeStyleCounth && step == "h"
	let syntax	= [ 'texTypeStyle' ]
    elseif TypeStyleCount && step != "h"
	let syntax	= [ 'texTypeStyle' ]
    elseif RefZoneCount && RefZoneCounth && step == "h"
	let syntax	= [ 'texRefZone' ]
    elseif RefZoneCount && step != "h"
	let syntax	= [ 'texRefZone' ]
    elseif RefOptionCount && RefOptionCounth && step == "h"
	let syntax	= [ 'texRefOption' ]
    elseif RefOptionCount && step != "h"
	let syntax	= [ 'texRefOption' ]
    elseif CiteCount && CiteCounth && step == "h"
	let syntax	= [ 'texCite' ]
    elseif CiteCount && step != "h"
	let syntax	= [ 'texCite' ]
    elseif MatcherCount && MatcherCounth && step == "h"
	let syntax	= [ 'texMatcher' ]
    elseif MatcherCount && step != "h"
	let syntax	= [ 'texMatcher' ]
    elseif MathMatcherCount && MathMatcherCounth && step == "h"
	let syntax	= [ 'texMathMatcher' ]
    elseif MathMatcherCount && step != "h"
	let syntax	= [ 'texMathMatcher' ]
    elseif SectionNameCount && SectionNameCounth && step == "h"
	let syntax	= [ 'texSectionName' ]
    elseif SectionNameCount && step != "h"
	let syntax	= [ 'texSectionName' ]
    elseif SectionMarkerCount
	let syntax	= [ 'texSectionMarker' ]
    elseif SectionModifierCount && SectionModifierCounth && step == "h"
	let syntax	= [ 'texSectionModifier' ]
    elseif SectionModifierCount && step != "h"
	let syntax	= [ 'texSectionModifier' ]
    elseif MathTextCount && MathTextCounth && step == "h"
	let syntax	= [ 'texMathText' ]
    elseif MathTextCount && step != "h"
	let syntax	= [ 'texMathText' ]
"     elseif MathZonesCount
"     This might be slow
"     but we might change 'normal l' to 'normal w'
" 	let syntax	= [ 'texMathZoneA', 'texMathZoneB', 'texMathZoneC', 'texMathZoneD', 'texMathZoneE', 'texMathZoneF', 'texMathZoneG', 'texMathZoneH', 'texMathZoneI', 'texMathZoneJ', 'texMathZoneK', 'texMathZoneL', 'texMathZoneT', 'texMathZoneV', 'texMathZoneW', 'texMathZoneX', 'texMathZoneY' ]
    else
	" Go after first Delimiter
	let i=0
	let DelimiterCount	= count(synstack, 'Delimiter') 
	while !DelimiterCount
	    exe "normal " . step
	    let synstack	= map(synstack(line("."), col(".")), 'synIDattr( v:val, "name")')
	    let DelimiterCount	= count(synstack, 'Delimiter') 
	    if i == 1
		let DelimiterCount = 0
	    endif
	    let i+=1
	endwhile
	if in_imap
	    normal a
	endif
	return "Delimiter motion"
    endif

    let true	= 0
    for syn in syntax
	let true += count(synstack, syn)
    endfor
    let initial_count	= true

    while true >= initial_count
	let true	= 0
	execute "normal " . step
	let synstack	= map(synstack(line("."), col(".")), 'synIDattr( v:val, "name")')
	for syn in syntax
	    let true += count(synstack, syn)
	endfor
    endwhile
    while getline(".")[col(".")] =~ '^{\|}\|(\|)\|\[\|\]$'
	exe "normal l"
    endwhile
    if getline(".")[col(".")-2] == "{"
	exe "normal h"
    endif
    let &l:whichwrap	= join(whichwrap, ',')
    if in_imap
	normal a
"     else
" 	normal l
    endif
    if step == "l" && syntax == [ 'Delimiter' ]
	normal h
    endif
endfunction

" ctrl-j motion
" atplib#motion#JMotion {{{1
" New <Ctrl-j> motion
function! atplib#motion#JMotion(flag)
" 	Note: pattern to match only commands which do not have any arguments:
" 	'\(\\\w\+\>\s*{\)\@!\\\w\+\>'
    let line = getline(".")
    if a:flag !~# 'b'
	let pline = strpart(line, col(".")-1)
	if pline =~ '[{]*}{'
	    call search('{.', 'e')
	    return
	endif
    else
	let pline = strpart(line, 0, col("."))
	if pline =~ '}{'
	    call search('}{', 'b')
	    normal! h
	    return
	endif
    endif
    let lz = &lz
    set lz
    if a:flag !~# 'b'
	let pattern = '\%(\]\zs\|{\zs\|}\zs\|(\zs\|)\zs\|\[\zs\|\]\zs\|\$\zs\|^\zs\s*$\|\(\\\w\+\>\s*{\)\@!\\\w\+\>\zs\)'
    else
	let pattern = '\%(\]\|{\|}\|(\|)\|\[\|\]\|\$\|^\s*$\|\(\\\w\+\>\s*{\)\@!\\\w\+\>\)'
    endif
    if getline(line(".")) =~ '&'
	let pattern = '\%(&\s*\zs\|^\s*\zs\)\|' . pattern
    endif

    if getline(line("."))[col(".")-1] =~ '\%(\$\|{\|}\|(\|)\|\[\|\]\)' && a:flag !~# 'b'
	if col(".") == len(getline(line(".")))
	    execute "normal! +"
	else
	    call cursor(line("."), col(".")+1)
	endif
    else
	call search(pattern, a:flag)
	" In the imaps we use 'a' for the backward move and 'i' for forward move! 
	let condition = getline(line("."))[col(".")-1] =~ '\%(\$\|{\|}\|(\|)\|\[\|\]\)'
	if a:flag !~# 'b' && col(".") == len(getline(line("."))) && condition
	    " Add a space at the end of line and move there
	    execute "normal a"
	endif
    endif
    let &lz=lz
endfunction
" }}}1
" atplib#motion#ParagraphNormalMotion {{{1
function! atplib#motion#ParagraphNormalMotion(backward,count)
    normal! m`
    if a:backward != "b"
	for i in range(1,a:count)
	    call search('\(^\(\n\|\s\)*\n\s*\zs\S\|\zs\\par\>\|\%'.line("$").'l$\)', 'W')
	endfor
    else
	for i in range(1,a:count)
	    call search('\(^\(\n\|\s\)*\n\s*\zs\S\|\zs\\par\>\|^\%1l\)', 'Wb')
	endfor
    endif
endfunction
" atplib#motion#SentenceNormalMotion {{{1
fun! atplib#motion#SentenceNormalMotion(backward,count)
    normal! m`
    if a:backward != "b"
	for i in range(1,a:count)
	    call search('\%(\.\|\\par\|\\]\|\\noindent\|\\\%(begin\|end\)\%(\s*{.*}\|\s*\[.*\]\)*\|\\\%(part\|chapter\|\%(sub\)\{0,2}section\|\%(sub\)\?paragraph\)\%(\s*[.\{-}]\)\?{.*}\)\_s\+\zs\%(\s*\\begin\|\s*\\end\)\@![A-Z]', 'W')
	endfor
    else
	for i in range(1,a:count)
	    call search('\%(\.\|\\par\|\\]\|\\noindent\|\\\%(begin\|end\)\%(\s*{.*}\|\s*\[.*\]\)*\|\\\%(part\|chapter\|\%(sub\)\{0,2}section\|\%(sub\)\?paragraph\)\%(\s*[.\{-}]\)\?{.*}\)\_s\+\zs\%(\s*\\begin\|\s*\\end\)\@![A-Z]', 'Wb')
	endfor
    endif
endfun
" atplib#motion#StartVisualMode {{{1
function! atplib#motion#StartVisualMode(mode, count)
    let g:atp_visualstartpos = getpos(".")
    let l:count = ( a:count ? a:count : "" )
    if a:mode ==# 'v'
	exe "normal! ".l:count."v"
    elseif a:mode ==# 'V'
	exe "normal! ".l:count."V"
    elseif a:mode ==# 'cv'
	exe "normal! ".l:count."\<c-v>"
    endif
endfunction
" atplib#motion#ParagraphVisualMotion {{{1
function! atplib#motion#ParagraphVisualMotion(backward,count)
    let bpos = g:atp_visualstartpos
    normal! m`
    if a:backward != "b"
	let cond = (bpos[1] >= getpos("'>")[1])
	if cond
	    call cursor(getpos("'<")[1:2])
	else
	    call cursor(getpos("'>")[1:2])
	endif
	for i in range(1,a:count)
	    call search('.', 'cW')
	    let epos = searchpos('\(^\(\n\|\s\)*\n\ze\|\(\_s*\)\=\\par\>\|\%'.line("$").'l$\)', 'W')
	    if epos == [0, 0]
		let epos = getpos(".")[1:2]
	    endif
	endfor
    else 
	let cond = (bpos[1] < getpos("'>")[1])
	if cond
	    call cursor(getpos("'>")[1:2])
	else
	    call cursor(getpos("'<")[1:2])
	endif
	for i in range(1,a:count)
	    call search('.', 'cbW')
	    let epos = searchpos('\(^\(\n\|\s\)*\n\ze\|\(\_s*\)\=\\par\>\|^\%1l\ze\)', 'Wb')
	    if epos == [0, 0]
		let epos = getpos(".")[1:2]
	    endif
	endfor
    endif
    call cursor(bpos[1:2])
    exe "normal ".visualmode()
    call cursor(epos)
endfunction
fun! atplib#motion#TexKeywordObject() " {{{1
    let line = getline(line("."))
    let beg = len(matchstr(line[:(col(".")-1)], '\\\?\k*$'))
    let end = len(matchstr(line[col("."):], '^\k*'))
    if beg-1 >= 1
	exe "normal! ".(beg-1)."h"
    endif
    normal v
    if end+beg-1 >= 1
	exe "normal! ".(beg+end-1)."l"
    endif
endfun
" Modeliens: {{{1
" vim:fdm=marker:tw=85:ff=unix:noet:ts=8:sw=4:fdc=1
