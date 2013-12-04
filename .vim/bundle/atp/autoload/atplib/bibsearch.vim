" Title: 	Vim library for ATP filetype plugin.
" Author:	Marcin Szamotulski
" Email:	mszamot [AT] gmail [DOT] com
" Note:		This file is a part of Automatic Tex Plugin for Vim.
" URL:		https://launchpad.net/automatictexplugin
" Language:	tex
" Last Modified: 

" BIB SEARCH:
" These are all bibsearch related variables and functions.
"{{{ atplib#bibsearch#variables
let atplib#bibsearch#bibflagsdict={ 
                \ 't' : ['title',       'title        '],               'a' : ['author',        'author       '], 
		\ 'b' : ['booktitle',   'booktitle    '],               'c' : ['mrclass',       'mrclass      '], 
		\ 'e' : ['editor',      'editor       '], 	        'j' : ['journal',       'journal      '], 
		\ 'f' : ['fjournal',    'fjournal     '], 	        'y' : ['year',          'year         '], 
		\ 'n' : ['number',      'number       '], 	        'v' : ['volume',        'volume       '], 
		\ 's' : ['series',      'series       '], 	        'p' : ['pages',         'pages        '], 
		\ 'P' : ['publisher',   'publisher    '],               'N' : ['note',          'note         '], 
		\ 'S' : ['school',      'school       '], 	        'h' : ['howpublished',  'howpublished '], 
		\ 'o' : ['organization', 'organization '],              'I' : ['institution' ,  'institution '],
		\ 'u' : ['url',         'url          '],
		\ 'H' : ['homepage',    'homepage     '], 	        'i' : ['issn',          'issn         '],
		\ 'k' : ['key',         'key          '], 	        'R' : ['mrreviewer',    'mrreviewer   ']}
" they do not work in the library script :(
" using g:bibflags... .
" let atplib#bibflagslist=keys(atplib#bibsearch#bibflagsdict)
" let atplib#bibflagsstring=join(atplib#bibflagslist,'')
"}}}
"{{{ atplib#bibsearch#searchbib
" This is the main search engine.
" ToDo should not search in comment lines.

" To make it work after kpsewhich is searching for bib path.
" let s:bibfiles=FindBibFiles(bufname('%'))
function! atplib#bibsearch#searchbib(pattern, bibdict, ...) 

    " for tex files this should be a flat search.
    let flat 	= &filetype == "plaintex" ? 1 : 0
    let bang	= a:0 >=1 ? a:1 : ""
    let atp_MainFile	= atplib#FullPath(b:atp_MainFile)

    " Make a pattern which will match for the elements of the list g:bibentries
    let pattern = '^\s*@\%(\<'.g:bibentries[0].'\>'
    for bibentry in g:bibentries['1':len(g:bibentries)]
	let pattern	= pattern . '\|\<' . bibentry . '\>'
    endfor
    let pattern	= pattern . '\)'
" This pattern matches all entry lines: author = \| title = \| ... 
    let pattern_b = '^\s*\%('
    for bibentry in keys(g:bibflagsdict)
	let pattern_b	= pattern_b . '\|\<' . g:bibflagsdict[bibentry][0] . '\>'
    endfor
    let pattern_b.='\)\s*='

    if g:atp_debugBS
	exe "redir! >>".g:atp_TempDir."/BibSearch.log"
	silent! echo "==========atplib#bibsearch#searchbib==================="
	silent! echo "atplib#bibsearch#searchbib_bibfiles=" . string(s:bibfiles)
	silent! echo "a:pattern=" . a:pattern
	silent! echo "pattern=" . pattern
	silent! echo "pattern_b=" . pattern_b
	silent! echo "bang=" . bang
	silent! echo "flat=" . flat
    endif

    unlet bibentry
    let b:bibentryline={} 
    
    " READ EACH BIBFILE IN TO DICTIONARY s:bibdict, WITH KEY NAME BEING THE bibfilename
    let s:bibdict={}
    let l:bibdict={}
    for l:f in keys(a:bibdict)
	let s:bibdict[l:f]=[]

	" read the bibfile if it is in b:atp_OutDir or in g:atp_raw_bibinputs directory
	" ToDo: change this to look in directories under g:atp_raw_bibinputs. 
	" (see also ToDo in FindBibFiles 284)
" 	for l:path in split(g:atp_raw_bibinputs, ',') 
" 	    " it might be problem when there are multiple libraries with the
" 	    " same name under different locations (only the last one will
" 	    " survive)
" 	    let s:bibdict[l:f]=readfile(fnameescape(findfile(atplib#append(l:f,'.bib'), atplib#append(l:path,"/") . "**")))
" 	endfor
	let l:bibdict[l:f]=copy(a:bibdict[l:f])
	" clear the s:bibdict values from lines which begin with %    
	call filter(l:bibdict[l:f], ' v:val !~ "^\\s*\\%(%\\|@\\cstring\\)"')
    endfor

    if g:atp_debugBS
	silent! echo "values(l:bibdict) len(l:bibdict[v:val]) = " . string(map(deepcopy(l:bibdict), "len(v:val)"))
    endif

    if a:pattern != ""
	for l:f in keys(a:bibdict)
	    let l:list=[]
	    let l:nr=1
	    for l:line in l:bibdict[l:f]
		" Match Pattern:
		" if the line matches find the beginning of this bib field and add its
		" line number to the list l:list
		" remove ligatures and brackets {,} from the line
		let line_without_ligatures = substitute(substitute(l:line,'\C{\|}\|\\\%("\|`\|\^\|=\|\.\|c\|\~\|v\|u\|d\|b\|H\|t\)\s*','','g'), "\\\\'\\s*", '', 'g')
		let line_without_ligatures = substitute(line_without_ligatures, '\C\\oe', 'oe', 'g')
		let line_without_ligatures = substitute(line_without_ligatures, '\C\\OE', 'OE', 'g')
		let line_without_ligatures = substitute(line_without_ligatures, '\C\\ae', 'ae', 'g')
		let line_without_ligatures = substitute(line_without_ligatures, '\C\\AE', 'AE', 'g')
		let line_without_ligatures = substitute(line_without_ligatures, '\C\\o', 'o', 'g')
		let line_without_ligatures = substitute(line_without_ligatures, '\C\\O', 'O', 'g')
		let line_without_ligatures = substitute(line_without_ligatures, '\C\\i', 'i', 'g')
		let line_without_ligatures = substitute(line_without_ligatures, '\C\\j', 'j', 'g')
		let line_without_ligatures = substitute(line_without_ligatures, '\C\\l', 'l', 'g')
		let line_without_ligatures = substitute(line_without_ligatures, '\C\\L', 'L', 'g')

		if line_without_ligatures =~? a:pattern

		    if g:atp_debugBS
			silent! echo "line_without_ligatures that matches " . line_without_ligatures
			silent! echo "____________________________________"
		    endif

		    let l:true=1
		    let l:t=0
		    while l:true == 1
			let l:tnr=l:nr-l:t

			    if g:atp_debugBS
				silent! echo " l:tnr=" . string(l:tnr) . " l:bibdict[". string(l:f) . "][" . string(l:tnr-1) . "]=" . string(l:bibdict[l:f][l:tnr-1])
			    endif

			" go back until the line will match pattern (which
			" should be the beginning of the bib field.
		       if l:bibdict[l:f][l:tnr-1] =~? pattern && l:tnr >= 0
			   let l:true=0
			   let l:list=add(l:list,l:tnr)
		       elseif l:tnr <= 0
			   let l:true=0
		       endif
		       let l:t+=1
		    endwhile
		endif
		let l:nr+=1
	    endfor

	    if g:atp_debugBS
		silent! echo "A l:list=" . string(l:list)
	    endif

    " CLEAR THE l:list FROM ENTRIES WHICH APPEAR TWICE OR MORE --> l:clist
	    let l:pentry="A"		" We want to ensure that l:entry (a number) and l:pentry are different
	    for l:entry in l:list
		if l:entry != l:pentry
		    if count(l:list,l:entry) > 1
			while count(l:list,l:entry) > 1
			    let l:eind=index(l:list,l:entry)
			    call remove(l:list,l:eind)
			endwhile
		    endif 
		    let l:pentry=l:entry
		endif
	    endfor

	    " This is slower than the algorithm above! 
" 	    call sort(filter(l:list, "count(l:list, v:val) == 1"), "atplib#CompareNumbers")

	    if g:atp_debugBS
		silent! echo "B l:list=" . string(l:list)
	    endif

	    let b:bibentryline=extend(b:bibentryline,{ l:f : l:list })

	    if g:atp_debugBS
		silent! echo "atplib#bibsearch b:bibentryline= (pattern != '') " . string(b:bibentryline)
	    endif

	endfor
    endif
"   CHECK EACH BIBFILE
    let l:bibresults={}
"     if the pattern was empty make it faster. 
    if a:pattern == ""
	for l:bibfile in keys(l:bibdict)
	    let l:bibfile_len=len(l:bibdict[l:bibfile])
	    let s:bibd={}
		let l:nr=0
		while l:nr < l:bibfile_len
		    let l:line=l:bibdict[l:bibfile][l:nr]
		    if l:line =~ pattern
			let s:lbibd={}
			let s:lbibd["bibfield_key"]=l:line
			let l:beg_line=l:nr+1
			let l:nr+=1
			let l:line=l:bibdict[l:bibfile][l:nr]
			let l:y=1
			while l:line !~ pattern && l:nr < l:bibfile_len
			    let l:line=l:bibdict[l:bibfile][l:nr]
			    let l:lkey=tolower(
					\ matchstr(
					    \ strpart(l:line,0,
						\ stridx(l:line,"=")
					    \ ),'\<\w*\>'
					\ ))
	" CONCATENATE LINES IF IT IS NOT ENDED
			    let l:y=1
			    if l:lkey != ""
				let s:lbibd[l:lkey]=l:line
	" IF THE LINE IS SPLIT ATTACH NEXT LINE									
				let l:nline=get(l:bibdict[l:bibfile],l:nr+l:y)
				while l:nline !~ '=' && 
					    \ l:nline !~ pattern &&
					    \ (l:nr+l:y) < l:bibfile_len
				    let s:lbibd[l:lkey]=substitute(s:lbibd[l:lkey],'\s*$','','') . " ". substitute(get(l:bibdict[l:bibfile],l:nr+l:y),'^\s*','','')
				    let l:line=get(l:bibdict[l:bibfile],l:nr+l:y)
				    let l:y+=1
				    let l:nline=get(l:bibdict[l:bibfile],l:nr+l:y)
				    if l:y > 30
					echoerr "ATP-Error /see :h atp-errors-bibsearch/, missing '}', ')' or '\"' in bibentry (check line " . l:nr . ") in " . l:f . " line=".l:line
					break
				    endif
				endwhile
				if l:nline =~ pattern 
				    let l:y=1
				endif
			    endif
			    let l:nr+=l:y
			    unlet l:y
			endwhile
			let l:nr-=1
			call extend(s:bibd, { l:beg_line : s:lbibd })
		    else
			let l:nr+=1
		    endif
		endwhile
	    let l:bibresults[l:bibfile]=s:bibd
	endfor

	if g:atp_debugBS
	    silent! echo "atplib#bibsearch#searchbib_bibresults A =" . l:bibresults
	endif

	return l:bibresults
    endif
    " END OF NEW CODE: (up)

    for l:bibfile in keys(b:bibentryline)
	let l:f=l:bibfile . ".bib"
"s:bibdict[l:f])	CHECK EVERY STARTING LINE (we are going to read bibfile from starting
"	line till the last matching } 
 	let s:bibd={}
 	for l:linenr in b:bibentryline[l:bibfile]

	    let l:nr=l:linenr-1
	    let l:i=atplib#count(get(l:bibdict[l:bibfile],l:linenr-1),"{")-atplib#count(get(l:bibdict[l:bibfile],l:linenr-1),"}")
	    let l:j=atplib#count(get(l:bibdict[l:bibfile],l:linenr-1),"(")-atplib#count(get(l:bibdict[l:bibfile],l:linenr-1),")") 
	    let s:lbibd={}
	    let s:lbibd["bibfield_key"]=get(l:bibdict[l:bibfile],l:linenr-1)
	    if s:lbibd["bibfield_key"] !~ '@\w\+\s*{.\+' 
		let l:l=0
		while get(l:bibdict[l:bibfile],l:linenr-l:l) =~ '^\s*$'
		    let l:l+=1
		endwhile
		let s:lbibd["bibfield_key"] .= get(l:bibdict[l:bibfile],l:linenr+l:l)
		let s:lbibd["bibfield_key"] = substitute(s:lbibd["bibfield_key"], '\s', '', 'g')
	    endif

	    let l:x=1
" we go from the first line of bibentry, i.e. @article{ or @article(, until the { and (
" will close. In each line we count brackets.	    
            while l:i>0	|| l:j>0
		let l:tlnr=l:x+l:linenr
		let l:pos=atplib#count(get(l:bibdict[l:bibfile],l:tlnr-1),"{")
		let l:neg=atplib#count(get(l:bibdict[l:bibfile],l:tlnr-1),"}")
		let l:i+=l:pos-l:neg
		let l:pos=atplib#count(get(l:bibdict[l:bibfile],l:tlnr-1),"(")
		let l:neg=atplib#count(get(l:bibdict[l:bibfile],l:tlnr-1),")")
		let l:j+=l:pos-l:neg
		let l:lkey=tolower(
			    \ matchstr(
				\ strpart(get(l:bibdict[l:bibfile],l:tlnr-1),0,
				    \ stridx(get(l:bibdict[l:bibfile],l:tlnr-1),"=")
				\ ),'\<\w*\>'
			    \ ))
		if l:lkey != ""
		    let s:lbibd[l:lkey]=get(l:bibdict[l:bibfile],l:tlnr-1)
			let l:y=0
" IF THE LINE IS SPLIT ATTACH NEXT LINE									
			if get(l:bibdict[l:bibfile],l:tlnr-1) !~ '\%()\|}\|"\)\s*,\s*\%(%.*\)\?$'
" 				    \ get(l:bibdict[l:bibfile],l:tlnr) !~ pattern_b
			    let l:lline=substitute(get(l:bibdict[l:bibfile],l:tlnr+l:y-1),'\\"\|\\{\|\\}\|\\(\|\\)','','g')
			    let l:pos=atplib#count(l:lline,"{")
			    let l:neg=atplib#count(l:lline,"}")
			    let l:m=l:pos-l:neg
			    let l:pos=atplib#count(l:lline,"(")
			    let l:neg=atplib#count(l:lline,")")
			    let l:n=l:pos-l:neg
			    let l:o=atplib#count(l:lline,"\"")
    " this checks if bracets {}, and () and "" appear in pairs in the current line:  
			    if l:m>0 || l:n>0 || l:o>l:o/2*2 
				while l:m>0 || l:n>0 || l:o>l:o/2*2 
				    let l:pos=atplib#count(get(l:bibdict[l:bibfile],l:tlnr+l:y),"{")
				    let l:neg=atplib#count(get(l:bibdict[l:bibfile],l:tlnr+l:y),"}")
				    let l:m+=l:pos-l:neg
				    let l:pos=atplib#count(get(l:bibdict[l:bibfile],l:tlnr+l:y),"(")
				    let l:neg=atplib#count(get(l:bibdict[l:bibfile],l:tlnr+l:y),")")
				    let l:n+=l:pos-l:neg
				    let l:o+=atplib#count(get(l:bibdict[l:bibfile],l:tlnr+l:y),"\"")
    " Let's append the next line: 
				    let s:lbibd[l:lkey]=substitute(s:lbibd[l:lkey],'\s*$','','') . " ". substitute(get(l:bibdict[l:bibfile],l:tlnr+l:y),'^\s*','','')
				    let l:y+=1
				    if l:y > 30
					echoerr "ATP-Error /see :h atp-errors-bibsearch/, missing '}', ')' or '\"' in bibentry at line " . l:linenr . " (check line " . l:tlnr . ") in " . l:f)
					break
				    endif
				endwhile
			    endif
			endif
		endif
" we have to go line by line and we could skip l:y+1 lines, but we have to
" keep l:m, l:o values. It do not saves much.		
		let l:x+=1
		if l:x > 30
			echoerr "ATP-Error /see :h atp-errors-bibsearch/, missing '}', ')' or '\"' in bibentry at line " . l:linenr . " in " . l:f
			break
	        endif
		let b:x=l:x
		unlet l:tlnr
	    endwhile
	    
	    let s:bibd[l:linenr]=s:lbibd
	    unlet s:lbibd
	endfor
	let l:bibresults[l:bibfile]=s:bibd
    endfor

    if g:atp_debugBS
	silent! echo "atplib#bibsearch#searchbib_bibresults A =" . string(l:bibresults)
	redir END
    endif

    return l:bibresults
endfunction
"}}}
" {{{ atplib#bibsearch#searchbib_py
function! atplib#bibsearch#searchbib_py(bang,pattern, bibfiles, ...)
    " for tex files this should be a flat search.
    let flat 	= &filetype == "plaintex" ? 1 : 0
    let bang	= a:0 >=1 ? a:1 : ""
    let atp_MainFile	= atplib#FullPath(b:atp_MainFile)

    let b:atp_BibFiles=a:bibfiles
    if a:bang != "!"
	let pattern = atplib#VimToPyPattern(a:pattern)
    else
	let pattern = a:pattern
    endif
python << END
import vim
import re
import locale
from atplib.atpvim import readlines


files=vim.eval("b:atp_BibFiles")

def remove_ligatures(string):
    string = re.sub("\\\\'\s*", '', re.sub('{|}|\\\\(?:"|`|\^|=|\.|c|~|v|u|d|b|H|t)\s*', '', string))
    string = re.sub('\\\\oe', 'oe', string)
    string = re.sub('\\\\OE', 'OE', string)
    string = re.sub('\\\\ae', 'ae', string)
    string = re.sub('\\\\AE', 'AE', string)
    string = re.sub('\\\\o', 'o', string)
    string = re.sub('\\\\O', 'O', string)
    string = re.sub('\\\\i', 'i', string)
    string = re.sub('\\\\j', 'j', string)
    string = re.sub('\\\\l', 'l', string)
    string = re.sub('\\\\L', 'L', string)
    return string

def remove_quotes(string):
    line=re.sub("'", "\"", string)
    line=re.sub('\\\\', '', line)
    return line
type_pattern=re.compile('\s*@(article|book|mvbook|inbook|bookinbook|suppbook|booklet|collection|mvcollection|incollection|suppcollection|manual|misc|online|patent|periodical|supppertiodical|proceedings|mvproceedings|inproceedings|reference|mvreference|inreference|report|set|thesis|unpublished|custom[a-f]|conference|electronic|masterthesis|phdthesis|techreport|www)', re.I)

# types=['abstract', 'addendum', 'afterword', 'annotation', 'author', 'authortype', 'bookauthor', 'bookpaginator', 'booksupbtitle', 'booktitle', 'booktitleaddon', 'chapter', 'commentator', 'date', 'doi', 'edition', 'editor', 'editora', 'editorb', 'editorc', 'editortype', 'editoratype', 'editorbtype', 'editorctype', 'eid', 'eprint', 'eprintclass', 'eprinttype', 'eventdate', 'eventtile', 'file', 'forword', 'holder', 'howpublished', 'indxtitle', 'institution', 'introduction', 'isan', 'isbn', 'ismn', 'isrn', 'issn', 'issue', 'issuesubtitle', 'issuetitle', 'iswc', 'journalsubtitle', 'journaltitle', 'label', 'language', 'library', 'location', 'mainsubtitle', 'maintitle', 'maintitleaddon', 'month', 'nameaddon', 'note', 'number', 'organization', 'origdate', 'origlanguage', 'origpublisher', 'origname', 'pages', 'pagetotal', 'pagination', 'part', 'publisher', 'pubstate', 'reprinttitle', 'series', 'shortauthor', 'shorteditor', 'shorthand', 'shorthandintro', 'shortjournal', 'shortseries', 'subtitle', 'title', 'titleaddon', 'translator', 'type', 'url', 'urldate', 'venue', 'version', 'volume', 'volumes', 'year', 'crossref', 'entryset', 'entrysubtype', 'execute', 'mrreviewer']

types=['author', 'bookauthor', 'booktitle', 'date', 'editor', 'eprint', 'eprintclass', 'eprinttype', 'howpublished', 'institution', 'journal', 'month', 'note', 'number', 'organization', 'pages', 'publisher', 'school', 'series', 'subtitle', 'title', 'url', 'year', 'mrreviewer', 'volume', 'pages']

def parse_bibentry(bib_entry):
    bib={}
    bib['bibfield_key']=(re.sub('\\r$', '', bib_entry[0]))
    nr=1
    while nr < len(bib_entry)-1:
        line=bib_entry[nr]
        if not re.match('\s*%', line):
            if not re.search('=', line):
                while not re.search('=', line) and nr < len(bib_entry)-1:
                    val=re.sub('\s*$', '', bib[p_e_type])+" "+re.sub('^\s*', '', re.sub('\t', ' ', line))
                    val=re.sub('%.*', '', val)
                    bib[p_e_type]=(remove_quotes(re.sub('\\r$', '', val)))
                    nr+=1
                    line=bib_entry[nr]
            else:
                v_break=False
                for e_type in types:
                    if re.match('\s*%s\s*=' % e_type, line, re.I):
                        # TODO: this is not working when title is two lines long!
                        line=re.sub('%.*', '', line)
                        bib[e_type]=remove_quotes(re.sub('\\r$', '', re.sub('\t', ' ', line)))
                        p_e_type=e_type
                        nr+=1
                        v_break=True
                        break
                if not v_break:
                    nr+=1
    return bib

pattern=vim.eval("pattern")

if pattern == "":
    pat=""
else:
    pat=pattern
pattern=re.compile(pat, re.I)
pattern_b=re.compile('\s*@\w+\s*{.+', re.I)

bibresults={}
for file in files:
    file_l = readlines(file)
    file_len=len(file_l)
    lnr=0
    bibresults[file]={}
    while lnr < file_len:
        lnr+=1
        line=file_l[lnr-1]
	if re.search('@string', line):
            continue
        line_without_ligatures=remove_ligatures(line)
        if re.search(pattern, line_without_ligatures):
            """find first line"""
            b_lnr=lnr
            b_line=line
            while not re.match(pattern_b, b_line) and b_lnr >= 1:
                b_lnr-=1
                b_line=file_l[b_lnr-1]
            """find last line"""
            e_lnr=lnr
            e_line=line
            if re.match(pattern_b, e_line):
                lnr+=1
                e_lnr=lnr
                line=file_l[lnr-1]
                e_line=file_l[lnr-1]
            while not re.match(pattern_b, e_line) and e_lnr <= file_len:
                e_lnr+=1
                e_line=file_l[min(e_lnr-1, file_len-1)]
            e_lnr-=1
            e_line=file_l[min(e_lnr-1, file_len-1)]
            while re.match('\s*$', e_line):
                e_lnr-=1
                e_line=file_l[e_lnr-1]
            bib_entry=file_l[b_lnr-1:e_lnr]
            if bib_entry != [] and not re.search('@string', bib_entry[0]):
                entry_dict=parse_bibentry(bib_entry)
                bibresults[file][str(b_lnr)]=entry_dict
            if lnr < e_lnr:
                lnr=e_lnr
            else:
                lnr+=1
if int(vim.eval("v:version")) < 703 or int(vim.eval("v:version")) == 703 and not int(vim.eval("has('patch569')")):
    import json
    vim.command("let bibresults=%s" % json.dumps(bibresults))
END
if v:version == 703 && has('patch569') || v:version > 703
    let bibresults = pyeval("bibresults")
endif
return bibresults
endfunction
"}}}
" {{{ atplib#bibsearch#SearchBibItems
" the argument should be b:atp_MainFile but in any case it is made in this way.
" it specifies in which file to search for include files.
function! atplib#bibsearch#SearchBibItems()
    let time=reltime()

    let atp_MainFile	= atplib#FullPath(b:atp_MainFile)
    " we are going to make a dictionary { citekey : label } (see :h \bibitem) 
    let l:citekey_label_dict={}

    " make a list of include files.
    let l:includefile_list=[]
    if !exists("b:ListOfFiles") || !exists("b:TypeDict")
	call TreeOfFiles(b:atp_MainFile)
    endif
    let i=1
    for f in b:ListOfFiles
	let type = get(b:TypeDict, f, 'no_type')
	if type == 'no_type' && i
	    call TreeOfFiles(b:atp_MainFile)
	    let i=0
	endif
	if b:TypeDict[f] == "input"
	    call add(l:includefile_list, f)
	endif
    endfor
    call add(l:includefile_list, atp_MainFile) 
    call map(l:includefile_list, 'atplib#FullPath(v:val)')

    if has("python")
python << PEND
import vim
import re
import atplib.atpvim as atp
files=vim.eval("l:includefile_list")
citekey_label_dict={}
for f in files:
    f_l=atp.read(f).split("\n")
    for line in f_l:
        if re.match('[^%]*\\\\bibitem', line):
            match=re.search('\\\\bibitem\s*(?:\[([^\]]*)\])?\s*{([^}]*)}\s*(.*)', line)
            if match:
                label=match.group(1)
                if label == None:
                    label = ""
                key=match.group(2)
                if key == None:
                    key = ""
                rest=match.group(3)
                if rest == None:
                    rest = ""
                if key != "":
                    citekey_label_dict[key]={ 'label' : label, 'rest' : rest }
vim.command("let l:citekey_label_dict="+str(citekey_label_dict))
PEND
    else
        " search for bibitems in all include files.
        for l:ifile in l:includefile_list

            let l:input_file = atplib#ReadInputFile(l:ifile,0)

                " search for bibitems and make a dictionary of labels and citekeys
                for l:line in l:input_file
                    if l:line =~# '^[^%]*\\bibitem'
                        let l:label=matchstr(l:line,'\\bibitem\s*\[\zs[^]]*\ze\]')
                        let l:key=matchstr(l:line,'\\bibitem\s*\%(\[[^]]*\]\)\?\s*{\zs[^}]*\ze}') 
                        let l:rest=matchstr(l:line,'\\bibitem\s*\%(\[[^]]*\]\)\?\s*{[^}]*}\s*\zs')
                        if l:key != ""
                            call extend(l:citekey_label_dict, { l:key : { 'label' : l:label, 'rest' : l:rest } }, 'error') 
                        endif
                    endif
                endfor
        endfor
    endif
	
    let g:time_SearchBibItems=reltimestr(reltime(time))
    return l:citekey_label_dict
endfunction
" }}}
"{{{ atplib#bibsearch#showresults
" FLAGS:
" for currently supported flags see ':h atp_bibflags'
" All - all flags	
" L - last flag
" a - author
" e - editor
" t - title
" b - booktitle
" j - journal
" s - series
" y - year
" n - number
" v - volume
" p - pages
" P - publisher
" N - note
" S - school
" h - howpublished
" o - organization
" i - institution
" R - mrreviewer

function! atplib#bibsearch#showresults(bang, bibresults, flags, pattern, bibdict)
 
    "if nothing was found inform the user and return:
    if len(a:bibresults) == count(a:bibresults, {})
	echo "BibSearch: no bib fields matched."
	if g:atp_debugBS
	    exe "redir! >> ".g:atp_TempDir."/BibSeach.log"
	    silent! echo "==========atplib#bibsearch#showresults================="
	    silent! echo "atplib#bibsearch#showresults return A - no bib fields matched. "
	    redir END
	endif
	return 0
    elseif g:atp_debugBS
	    exe "redir! >> ".g:atp_TempDir."/BibSearch.log"
	    silent! echo "==========atplib#bibsearch#showresults================="
	    silent! echo "atplib#bibsearch#showresults return B - found something. "
	    redir END
    endif

    function! s:showvalue(value)
	return substitute(strpart(a:value,stridx(a:value,"=")+1),'^\s*','','')
    endfunction

    let s:z=1
    let l:ln=1
    let l:listofkeys={}
"--------------SET UP FLAGS--------------------------    
	    let l:allflagon=0
	    let l:flagslist=[]
	    let l:kwflagslist=[]

    " flags o and i are synonims: (but refer to different entry keys): 
	if a:flags =~# 'i' && a:flags !~# 'o'
	    let l:flags=substitute(a:flags,'i','io','') 
	elseif a:flags !~# 'i' && a:flags =~# 'o'
	    let l:flags=substitute(a:flags,'o','oi','')
	endif
	if a:flags !~# 'All'
	    if a:flags =~# 'L'
"  		if strpart(a:flags,0,1) != '+'
"  		    let l:flags=b:atp_LastBibFlags . substitute(a:flags, 'L', '', 'g')
"  		else
 		    let l:flags=b:atp_LastBibFlags . substitute(a:flags, 'L', '', 'g')
"  		endif
		let g:atp_LastBibFlags = deepcopy(b:atp_LastBibFlags)
	    else
		if a:flags == "" 
		    let l:flags=g:defaultbibflags
		elseif strpart(a:flags,0,1) != '+' && a:flags !~ 'All' 
		    let l:flags=a:flags
		elseif strpart(a:flags,0,1) == '+' && a:flags !~ 'All'
		    let l:flags=g:defaultbibflags . strpart(a:flags,1)
		endif
	    endif
	    let b:atp_LastBibFlags=substitute(l:flags,'+\|L','','g')
		if l:flags != ""
		    let l:expr='\C[' . g:bibflagsstring . ']' 
		    while len(l:flags) >=1
			let l:oneflag=strpart(l:flags,0,1)
    " if we get a flag from the variable g:bibflagsstring we copy it to the list l:flagslist 
			if l:oneflag =~ l:expr
			    let l:flagslist=add(l:flagslist, l:oneflag)
			    let l:flags=strpart(l:flags,1)
    " if we get '@' we eat ;) two letters to the list l:kwflagslist			
			elseif l:oneflag == '@'
			    let l:oneflag=strpart(l:flags,0,2)
			    if index(keys(g:kwflagsdict),l:oneflag) != -1
				let l:kwflagslist=add(l:kwflagslist,l:oneflag)
			    endif
			    let l:flags=strpart(l:flags,2)
    " remove flags which are not defined
			elseif l:oneflag !~ l:expr && l:oneflag != '@'
			    let l:flags=strpart(l:flags,1)
			endif
		    endwhile
		endif
	else
    " if the flag 'All' was specified. 	    
	    let l:flagslist=split(g:defaultallbibflags, '\zs')
	    let l:af=substitute(a:flags,'All','','g')
	    for l:kwflag in keys(g:kwflagsdict)
		if a:flags =~ '\C' . l:kwflag	
		    call extend(l:kwflagslist,[l:kwflag])
		endif
	    endfor
	endif

	"NEW: if there are only keyword flags append default flags
	if len(l:kwflagslist) > 0 && len(l:flagslist) == 0 
	    let l:flagslist=split(g:defaultbibflags,'\zs')
	endif

"   Open a new window.
    let l:bufnr=bufnr("___Bibsearch: " . a:pattern . "___"  )
    if l:bufnr != -1
	let l:bdelete=l:bufnr . "bwipeout"
	exe l:bdelete
    endif
    unlet l:bufnr
    let l:openbuffer=" +setl\\ buftype=nofile\\ filetype=bibsearch_atp " . fnameescape("___Bibsearch: " . a:pattern . "___")
    if g:vertical ==1
	let l:openbuffer="keepalt vsplit " . l:openbuffer 
	let l:skip=""
    else
	let l:openbuffer="keepalt split " . l:openbuffer 
	let l:skip="       "
    endif

    let BufNr	= bufnr("%")
    let LineNr	= line(".")
    let ColNr	= col(".")
    silent exe l:openbuffer

"     set the window options
    silent call atplib#setwindow()
" make a dictionary of clear values, which we will fill with found entries. 	    
" the default value is no<keyname>, which after all is matched and not showed
" SPEED UP:
    let l:values={'bibfield_key' : 'nokey'}	
    for l:flag in g:bibflagslist
	let l:values_clear=extend(l:values,{ g:bibflagsdict[l:flag][0] : 'no' . g:bibflagsdict[l:flag][0] })
    endfor

" SPEED UP: 
    let l:kwflag_pattern="\\C"	
    let l:len_kwflgslist=len(l:kwflagslist)
    let l:kwflagslist_rev=reverse(deepcopy(l:kwflagslist))
    for l:lkwflag in l:kwflagslist
	if index(l:kwflagslist_rev,l:lkwflag) == 0 
	    let l:kwflag_pattern.=g:kwflagsdict[l:lkwflag]
	else
	    let l:kwflag_pattern.=g:kwflagsdict[l:lkwflag].'\|'
	endif
    endfor
"     let b:kwflag_pattern=l:kwflag_pattern

    for l:bibfile in keys(a:bibresults)
	if a:bibresults[l:bibfile] != {}
	    call setline(l:ln, "Found in " . l:bibfile )	
	    let l:ln+=1
	endif
	for l:linenr in copy(sort(keys(a:bibresults[l:bibfile]), "atplib#CompareNumbers"))
	    let l:values=deepcopy(l:values_clear)
	    let b:values=l:values
" fill l:values with a:bibrsults	    
	    let l:values["bibfield_key"]=a:bibresults[l:bibfile][l:linenr]["bibfield_key"]
" 	    for l:key in keys(l:values)
" 		if l:key != 'key' && get(a:bibresults[l:bibfile][l:linenr],l:key,"no" . l:key) != "no" . l:key
" 		    let l:values[l:key]=a:bibresults[l:bibfile][l:linenr][l:key]
" 		endif
" SPEED UP:
		call extend(l:values,a:bibresults[l:bibfile][l:linenr],'force')
" 	    endfor
" ----------------------------- SHOW ENTRIES -------------------------
" first we check the keyword flags, @a,@b,... it passes if at least one flag
" is matched
	    let l:check=0
" 	    for l:lkwflag in l:kwflagslist
" 	        let l:kwflagpattern= '\C' . g:kwflagsdict[l:lkwflag]
" 		if l:values['bibfield_key'] =~ l:kwflagpattern
" 		   let l:check=1
" 		endif
" 	    endfor
	    if l:values['bibfield_key'] =~ l:kwflag_pattern
		let l:check=1
	    endif
	    if l:check == 1 || len(l:kwflagslist) == 0
		let l:linenumber=index(a:bibdict[l:bibfile],l:values["bibfield_key"])+1
 		call setline(l:ln,s:z . ". line " . l:linenumber . "  " . l:values["bibfield_key"])
		let l:ln+=1
 		let l:c0=atplib#count(l:values["bibfield_key"],'{')-atplib#count(l:values["bibfield_key"],'(')

	
" this goes over the entry flags:
		for l:lflag in l:flagslist
" we check if the entry was present in bibfile:
		    if l:values[g:bibflagsdict[l:lflag][0]] != "no" . g:bibflagsdict[l:lflag][0]
" 			if l:values[g:bibflagsdict[l:lflag][0]] =~ a:pattern
			    call setline(l:ln, l:skip . g:bibflagsdict[l:lflag][1] . " = " . s:showvalue(l:values[g:bibflagsdict[l:lflag][0]]))
			    let l:ln+=1
" 			else
" 			    call setline(l:ln, l:skip . g:bibflagsdict[l:lflag][1] . " = " . s:showvalue(l:values[g:bibflagsdict[l:lflag][0]]))
" 			    let l:ln+=1
" 			endif
		    endif
		endfor
		let l:lastline=getline(line('$'))
		let l:c1=atplib#count(l:lastline,'{')-atplib#count(l:lastline,'}')
		let l:c2=atplib#count(l:lastline,'(')-atplib#count(l:lastline,')')
		let l:c3=atplib#count(l:lastline,'\"')
		if l:c0 == 1 && l:c1 == -1
		    call setline(line('$'),substitute(l:lastline,'}\s*$','',''))
		    call setline(l:ln,'}')
		    let l:ln+=1
		elseif l:c0 == 1 && l:c1 == 0	
		    call setline(l:ln,'}')
		    let l:ln+=1
		elseif l:c0 == -1 && l:c2 == -1
		    call setline(line('$'),substitute(l:lastline,')\s*$','',''))
		    call setline(l:ln,')')
		    let l:ln+=1
		elseif l:c0 == -1 && l:c1 == 0	
		    call setline(l:ln,')')
		    let l:ln+=1
		endif
		let l:listofkeys[s:z]=l:values["bibfield_key"]
		let s:z+=1
	    endif
	endfor
    endfor
    if g:atp_debugBS
	let g:pattern	= a:pattern
    endif
    if (has("python") || g:atp_bibsearch == "python") && a:bang == "!"
	let pattern_tomatch = atplib#VimToPyPattern(a:pattern)
    else
        let pattern_tomatch = a:pattern
    endif
    let pattern_tomatch = substitute(pattern_tomatch, '\Co', 'oe\\=', 'g')
    let pattern_tomatch = substitute(pattern_tomatch, '\CO', 'OE\\=', 'g')
    let pattern_tomatch = substitute(pattern_tomatch, '\Ca', 'ae\\=', 'g')
    let pattern_tomatch = substitute(pattern_tomatch, '\CA', 'AE\\=', 'g')
    if g:atp_debugBS
	let g:pm = pattern_tomatch
    endif
    let pattern_tomatch	= join(split(pattern_tomatch, '\zs\\\@!\\\@<!'),  '[''"{\}]\{,3}')
    if g:atp_debugBS
	let g:pattern_tomatch = pattern_tomatch
    endif
    if pattern_tomatch != "" && pattern_tomatch != ".*"
	silent! call matchadd("Search", '\c' . pattern_tomatch)
	let @/=pattern_tomatch
    endif
    " return l:listofkeys which will be available in the bib search buffer
    " as b:ListOfKeys (see the BibSearch function below)
    let b:ListOfBibKeys = l:listofkeys
    let b:BufNr		= BufNr

    " Resize if the window height is too big.
    if line("$") <= winheight(0)
	exe "resize ".line("$")
    endif
    return l:listofkeys
endfunction
"}}}
