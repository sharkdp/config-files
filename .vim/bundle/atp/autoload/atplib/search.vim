" Author:	Marcin Szamotulski
" Description:  This file provides searching tools of ATP.
" Note:		This file is a part of Automatic Tex Plugin for Vim.
" Language:	tex
" Last Change:Tue Sep 06, 2011 at 03:18  +0100

" Make a dictionary of definitions found in all input files.
" {{{ atplib#search#make_defi_dict_vim
" Comparing with ]D, ]d, ]i, ]I vim maps this function deals with multiline
" definitions.
"
" The output dictionary is of the form: 
" 	{ input_file : [ [begin_line, end_line], ... ] }
" a:1 	= buffer name to search in for input files
" a:3	= 1 	skip searching for the end_line
"
" ToDo: it is possible to check for the end using searchpairpos, but it
" operates on a list not on a buffer.
function! atplib#search#make_defi_dict_vim(bang,...)

    let atp_MainFile	= atplib#FullPath(b:atp_MainFile)
    let bufname	= a:0 >= 1 ? a:1 : atp_MainFile

    " pattern to match the definitions this function is also used to fine
    " \newtheorem, and \newenvironment commands  
    let pattern	= a:0 >= 2 ? a:2 : '\\def\|\\newcommand'

    let preambule_only	= ( a:bang == "!" ? 0 : 1 )

    " this is still to slow!
    let only_begining	= ( a:0 >= 3 ? a:3 : 0 )

    let defi_dict={}

    let inputfiles=atplib#search#FindInputFiles(bufname)
    let input_files=[]

    " TeX: How this work in TeX files.
    for inputfile in keys(inputfiles)
	if inputfiles[inputfile][0] != "bib" && ( !preambule_only || inputfiles[inputfile][0] == "preambule" )
	    call add(input_files, inputfiles[inputfile][2])
	endif
    endfor

    let input_files=filter(input_files, 'v:val != ""')
    if !count(input_files, atp_MainFile)
	call extend(input_files,[ atp_MainFile ])
    endif

    if len(input_files) > 0
    for inputfile in input_files
	let defi_dict[inputfile]=[]
	" do not search for definitions in bib files 
	"TODO: it skips lines somehow. 
	let ifile=readfile(inputfile)
	
	" search for definitions
	let lnr=1
	while (lnr <= len(ifile) && (!preambule_only || ifile[lnr-1] !~ '\\begin\s*{document}'))

	    let match=0

	    let line=ifile[lnr-1]
	    if substitute(line,'\\\@<!%.*','','') =~ pattern

		let b_line=lnr

		let lnr+=1	
		if !only_begining
		    let open=atplib#count(line,'{')    
		    let close=atplib#count(line,'}')
		    while open != close
			"go to next line and count if the definition ends at
			"this line
			let line	= ifile[lnr-1]
			let open	+=atplib#count(line,'{')    
			let close	+=atplib#count(line,'}')
			let lnr		+=1	
		    endwhile
		    let e_line	= lnr-1
		    call add(defi_dict[inputfile], [ b_line, e_line ])
		else
		    call add(defi_dict[inputfile], [ b_line, b_line ])
		endif
	    else
		let lnr+=1
	    endif
	endwhile
    endfor
    endif

    return defi_dict
endfunction "}}}
" {{{ atplib#search#make_defi_dict_py
" command! -nargs=* -bang MakeDefiDict  :call atplib#search#make_defi_dict_py(<q-bang>,<f-args>)
function! atplib#search#make_defi_dict_py(bang,...)

    let atp_MainFile	= atplib#FullPath(b:atp_MainFile)
    let bufname	= a:0 >= 1 ? a:1 : atp_MainFile
    " Not tested
    let pattern	= a:0 >= 2 ? a:2 : '\\def\|\\newcommand'
    " Not implemeted
    let preambule_only= a:bang == "!" ? 0 : 1
    let only_begining	= a:0 >= 3 ? a:3 : "0"

    if a:bang == "!" || !exists("b:TreeOfFiles")
	 " Update the cached values:
	 let [ b:TreeOfFiles, b:ListOfFiles, b:TypeDict, b:LevelDict ] = TreeOfFiles(atp_MainFile)
    endif
    let [ Tree, List, Type_Dict, Level_Dict ] = deepcopy([ b:TreeOfFiles, b:ListOfFiles, b:TypeDict, b:LevelDict ])

    let defi_dict = {}
 
python << ENDPYTHON
import re
import subprocess
import os
import glob
from atplib.atpvim import readlines
from atplib.search import newcmd_pattern as pattern


def preambule_end(file):
    """find linenr where preambule ends,

    file is list of lines"""
    nr=1
    for line in file:
        if re.search(r'\\begin\s*{\s*document\s*}', line):
            return nr
        nr+=1
    return 0

type_dict=vim.eval("b:TypeDict")
main_file=vim.eval("atp_MainFile")
if int(vim.eval("preambule_only")) != 0:
    preambule_only=True
    files=[main_file]
    for f in type_dict.keys():
        if type_dict[f] == "preambule":
            files.append(f)
    with open(main_file) as sock:
	main_file_l=sock.read().splitlines()
    preambule_end=preambule_end(main_file_l)
else:
    preambule_only=False
    files=[main_file]
    files.extend(vim.eval("b:ListOfFiles"))

only_begining = (vim.eval("only_begining") != "0")

if hasattr(vim, 'bindeval'):
    defi_dict = vim.bindeval("defi_dict")
else:
    defi_dict = {}

for fname in files:
    defi_dict[fname]=[]
    lnr=1
    file_l = readlines(fname)

    while lnr <= len(file_l) and ( preambule_only and ( fname == main_file and lnr <= preambule_end or fname != main_file ) or not preambule_only):
        line=file_l[lnr-1]
        if re.search(pattern, line):
            # add: no search in comments.
            b_lnr = lnr
            if not only_begining:
                _open  = len(re.findall("({)", line))
                _close = len(re.findall("(})", line))
                while _open != _close:
                    lnr+=1
                    line    = file_l[lnr-1]
                    _open  += len(re.findall("({)", line))
                    _close += len(re.findall("(})", line))
                e_lnr = lnr
                defi_dict[fname].extend([[b_lnr, e_lnr ]])
            else:
                defi_dict[fname].extend([[b_lnr, b_lnr ]])
            lnr += 1
        else:
            lnr += 1

if not hasattr(vim, 'bindeval'):
    # There is no need of using json.dumps() here since the defi_dict has str
    # type keys and list of intergers inside.
    import json
    vim.command("let defi_dict_py=%s" % json.dumps(defi_dict))
ENDPYTHON
return defi_dict
endfunction
"}}}
function! atplib#search#GlobalDefi(command) "{{{
    " This function behaves like gD, but descends to included files.
    " a:cmd   - cmd which definition we are searching for
if !has("python")
    return
endif
python << EOF
import vim
import re
import os
from atplib.atpvim import readlines
from atplib.search import scan_preambule
from atplib.search import addext
from atplib.search import kpsewhich_find
from atplib.search import kpsewhich_path
from atplib.search import newcmd_pattern as pattern

cur_line = vim.eval('line(".")')
cur_file = vim.eval('atplib#FullPath(expand("%"))')
command = vim.eval('a:command')
mainfile = vim.eval('atplib#FullPath(b:atp_MainFile)')
if scan_preambule(mainfile, re.compile(r'\\usepackage{[^}]*\bsubfiles\b')):
    pat_str = r'^[^%]*(?:\\input\s+([\w_\-\.]*)|\\(?:input|include(?:only)?|subfile)\s*{([^}]*)})'
    inclpat = re.compile(pat_str)
else:
    pat_str = r'^[^%]*(?:\\input\s+([\w_\-\.]*)|\\(?:input|include(?:only)?)\s*{([^}]*)})'
    inclpat = re.compile(pat_str)

tex_path=kpsewhich_path('tex')
relative_path = vim.eval('g:atp_RelativePath')
project_dir = vim.eval('b:atp_ProjectDir')

def scan_file(fname, command, pattern=pattern):
    linenr = 0
    flines = readlines(fname)
    for line in flines:
        linenr += 1
        matches = re.findall(inclpat, line)
        if len(matches) > 0:
            for match in matches:
                for m in match:
                    if str(m) != "":
                        m=addext(m, "tex")
                        if not os.access(m, os.F_OK):
                            try:
                                m=kpsewhich_find(m, tex_path)[0]
                            except IndexError:
                                pass
                        (ffile, linenr, col) = scan_file(m, command, pattern)
                        if ffile:
                            return (ffile, linenr, col)
        match = re.search(pattern, line)
        if match:
            if match.group(1) == command:
                col = match.start(1)+1
                return (fname, linenr, col)
    else:
        return ("", 0, 0)
    if os.path.abspath(fname) == os.path.abspath(cur_file) and linenr > cur_line:
        return ("", 0, 0)


(ffile, line, col) = scan_file(mainfile, command, pattern)
vim.command("let ffile='%s'" % ffile)
vim.command(" let line=%d" % line)
vim.command(" let col=%d" % col)
EOF
if !empty(ffile)
    let bufnr = bufnr(ffile)
    if bufnr != -1 && buflisted(bufnr)
        exe "b ".bufnr
        call setpos(".", [0, line, col, 0])
    else
        exe "edit +".line." ".ffile
        call setpos(".", [0, line, col, 0])
    endif
endif
endfunction "}}}

"{{{ atplib#search#LocalCommands_vim 
" a:1 = pattern
" a:2 = "!" => renegenerate the input files.
function! atplib#search#LocalCommands_vim(...)
"     let time = reltime()
    let pattern = a:0 >= 1 && a:1 != '' ? a:1 : '\\def\>\|\\newcommand\>\|\\newenvironment\|\\newtheorem\|\\definecolor\|'
		\ . '\\Declare\%(RobustCommand\|FixedFont\|TextFontCommand\|MathVersion\|SymbolFontAlphabet'
			    \ . '\|MathSymbol\|MathDelimiter\|MathAccent\|MathRadical\|MathOperator\)'
		\ . '\|\\SetMathAlphabet\>'
    let bang	= a:0 >= 2 ? a:2 : '' 

    let atp_MainFile	= atplib#FullPath(b:atp_MainFile)

    " Makeing lists of commands and environments found in input files
    if bang == "!" || !exists("b:TreeOfFiles")
	 " Update the cached values:
	 let [ b:TreeOfFiles, b:ListOfFiles, b:TypeDict, b:LevelDict ] = TreeOfFiles(atp_MainFile)
     endif
     let [ Tree, List, Type_Dict, Level_Dict ] = deepcopy([ b:TreeOfFiles, b:ListOfFiles, b:TypeDict, b:LevelDict ])

     let saved_loclist	= getloclist(0)
     " I should scan the preambule separately!
     " This will make the function twice as fast!
     silent! execute "lvimgrep /".pattern."/j " . fnameescape(atp_MainFile)
     for file in List
	 if get(Type_Dict, file, 'no_file') == 'preambule'
	     silent! execute "lvimgrepadd /".pattern."/j " . fnameescape(file)
	 endif
     endfor
     let loclist	= getloclist(0)
     call setloclist(0, saved_loclist)

     let atp_LocalCommands	= []
     let atp_LocalEnvironments	= []
     let atp_LocalColors	= []

     for line in loclist
	" the order of pattern is important
	if line['text'] =~ '^[^%]*\\definecolor'
	    " color name
	    let name=matchstr(line['text'],
			\ '\\definecolor\s*{\s*\zs[^}]*\ze\s*}')
	    let type="Colors"
	elseif line['text'] =~ '^[^%]*\%(\\def\>\|\\newcommand\)'
	    " definition name 
	    let name= '\' . matchstr(line['text'], '\\def\\\zs[^{]*\ze{\|\\newcommand{\?\\\zs[^\[{]*\ze}')
	    let name=substitute(name, '\(#\d\+\)\+\s*$', '', '')
            let name.=(line['text'] =~ '\\def\\\w\+#[1-9]\|\\newcommand{[^}]*}\[[1-9]\]' ? '{' : '')
	    if name =~ '#\d\+'
		echo line['text']
		echo name
	    endif
	    let type="Commands"
	    " definition
" 	    let def=matchstr(line['text'],
" 			\ '^\%(\\def\\[^{]*{\zs.*\ze}\|\\newcommand\\[^{]*{\zs.*\ze}\)') 
	elseif line['text'] =~ '^[^%]*\%(\\Declare\%(RobustCommand\|FixedFont\|TextFontCommand\|MathVersion\|SymbolFontAlphabet'
			    \ . '\|MathSymbol\|MathDelimiter\|MathAccent\|MathRadical\|MathOperator\)\>\|\\SetMathAlphabet\)'
	    let name=matchstr(line['text'],
			\ '\%(\\Declare\%(RobustCommand\|FixedFont\|TextFontCommand\|MathVersion\|SymbolFontAlphabet'
			    \ . '\|MathSymbol\|MathDelimiter\|MathAccent\|MathRadical\|MathOperator\)\|\\SetMathAlphabet\)\s*{\s*\zs[^}]*\ze\s*}')
	    let type="Commands"
	elseif line['text'] =~ '^[^%]*\%(\\newenvironment\|\\newtheorem\)'
	    " environment name
	    let name=matchstr(line['text'],
			\ '^[^%]*\\\%(newtheorem\*\?\|newenvironment\)\s*{\s*\zs[^}]*\ze\s*}')
	    let type="Environments"
	endif
	if exists("name") && name != '' && name != '\'
	    if count(atp_Local{type}, name) == 0
		call add(atp_Local{type}, name)
	    endif
	endif
    endfor

    let b:atp_LocalCommands		= atp_LocalCommands
    let b:atp_LocalEnvironments		= atp_LocalEnvironments
    let b:atp_LocalColors		= atp_LocalColors
    return [ atp_LocalEnvironments, atp_LocalCommands, atp_LocalColors ]

endfunction "}}}
" {{{ atplib#search#LocalCommands_py
function! atplib#search#LocalCommands_py(write, ...)
    let time=reltime()
    " The first argument pattern is not implemented
    " but it should be a python regular expression
    let bang	= a:0 >= 2 ? a:2 : '' 

    let atp_MainFile	= atplib#FullPath(b:atp_MainFile)
    let pwd		= getcwd()
    try
	exe "lcd ".fnameescape(b:atp_ProjectDir)
    catch /E344:/
	return
    endtry

"     if a:write
" 	call atplib#write("nobackup")
"     endif


    " Makeing lists of commands and environments found in input files
    if bang == "!" || !exists("b:TreeOfFiles")
	 " Update the cached values:
	 let [ b:TreeOfFiles, b:ListOfFiles, b:TypeDict, b:LevelDict ] = TreeOfFiles(atp_MainFile)
     endif
     let [ Tree, List, Type_Dict, Level_Dict ] = deepcopy([ b:TreeOfFiles, b:ListOfFiles, b:TypeDict, b:LevelDict ])

     " Note: THIS CODE IS ONLY NEEDED WHEN PWD is different than the TreeOfFiles was
     " called! There is an option to store full path in ATP, then this is not needed.
     let files = []
     for file in b:ListOfFiles
	 if get(b:TypeDict, file, "") == "input" || get(b:TypeDict, file, "") == "preambule" 
	     if filereadable(file)
		 call add(files, atplib#FullPath(file))
	     else
                 " This makes it really slow when the files are missing.
		 let file=atplib#search#KpsewhichFindFile("tex", file)
		 if file != ""
		     call add(files, file)
		 endif
	     endif
	 endif
     endfor
let atp_LocalCommands = []
let atp_LocalColors = []
let atp_LocalEnvironments = []
python << END
import re
import vim
import os.path
from atplib.atpvim import readlines

pattern=re.compile(r'\s*(?:\\(?P<def>def)(?P<def_c>\\[^#{]*)|(?:\\(?P<nc>newcommand)|\\(?P<env>newenvironment)|\\(?P<nt>newtheorem\*?)|\\(?P<col>definecolor)|\\(?P<dec>Declare)(?:RobustCommand|FixedFont|TextFontCommand|MathVersion|SymbolFontAlphabet|MathSymbol|MathDelimiter|MathAccent|MathRadical|MathOperator)\s*{|\\(?P<sma>SetMathAlphabet))\s*{(?P<arg>[^}]*)})')

files=[vim.eval("atp_MainFile")]+vim.eval("files")
localcommands = []
localcolors = []
localenvs  = []
for fname in files:
    lnr=1
    file_l = readlines(fname)
    for line in file_l:
        m=re.match(pattern, line)
        if m:
            if m.group('def'):
                if re.search(r'\\def\\\w+#[1-9]', line):
                    localcommands.append(m.group('def_c')+'{')
                else:
                    localcommands.append(m.group('def_c'))
            elif m.group('nc') or m.group('dec') or m.group('sma'):
                if re.search(r'\\newcommand\s*{[^}]*}\s*\[[1-9]\]\s*{', line):
                    localcommands.append(m.group('arg')+'{')
                else:
                    localcommands.append(m.group('arg'))
            elif m.group('nt') or m.group('env'):
                localenvs.append(m.group('arg'))
            elif m.group('col'):
                localcolors.append(m.group('arg'))

if hasattr(vim, 'bindeval'):
    cmds = vim.bindeval('atp_LocalCommands')
    cmds.extend(localcommands)
    envs = vim.bindeval('atp_LocalEnvironments')
    envs.extend(localenvs)
    cols = vim.bindeval('atp_LocalColors')
    cols.extend(localcolors)
else:
    import json
    vim.command("let atp_LocalCommands=%s" % json.dumps(localcommands))
    vim.command("let atp_LocalEnvironments=%s" % json.dumps(localenvs))
    vim.command("let atp_LocalColors=%s" % json.dumps(localcolors))
END
if exists("atp_LocalCommands")
    let b:atp_LocalCommands=map(atp_LocalCommands, 'substitute(v:val, ''\\\\'', ''\'', '''')')
else
    let b:atp_LocalCommands=[]
endif
if exists("atp_LocalColors")
    let b:atp_LocalColors=map(atp_LocalColors, 'substitute(v:val, ''\\\\'', ''\'', '''')')
else
    let b:atp_LocalColors=[]
endif
if exists("atp_LocalEnvironments")
    let b:atp_LocalEnvironments=map(atp_LocalEnvironments, 'substitute(v:val, ''\\\\'', ''\'', '''')')
else
    let b:atp_LocalEnvironments=[]
endif
exe "lcd ".fnameescape(pwd)
let g:time_LocalCommands_py=reltimestr(reltime(time))
return [ b:atp_LocalEnvironments, b:atp_LocalCommands, b:atp_LocalColors ]
endfunction
"}}}
" atplib#search#LocalAbbreviations {{{
function! atplib#search#LocalAbbreviations()
    if !exists("b:atp_LocalEnvironments")
	let no_abbrev= ( exists('g:atp_no_local_abbreviations') ? g:atp_no_local_abbreviations : -1 )
	let g:atp_no_local_abbreviations = 1
	call LocalCommands(0)
	if no_abbrev == -1
	    unlet g:atp_no_local_abbreviations
	else
	    let g:atp_no_local_abbreviations = no_abbrev
	endif
    endif
    if exists("b:atp_LocalEnvironments")
	for env in b:atp_LocalEnvironments
	    if !empty(maparg(g:atp_iabbrev_leader.env.g:atp_iabbrev_leader, "i", 1))
	" 	silent echomsg "abbreviation " . g:atp_iabbrev_leader.env.g:atp_iabbrev_leader . " exists."
		continue
	    endif
	    if exists("g:atp_abbreviate_".env)
		execute "iabbrev <buffer> ".g:atp_iabbrev_leader.env.g:atp_iabbrev_leader." \\begin{".env."}".get(g:atp_abbreviate_{env}, 0, "<CR>")."\\end{".env."}".get(g:atp_abbreviate_{env}, 1, "<Esc>O")
	    else
		execute "iabbrev <buffer> ".g:atp_iabbrev_leader.env.g:atp_iabbrev_leader." \\begin{".env."}<CR>\\end{".env."}<Esc>O"
	    endif
	endfor
    endif
endfunction "}}}

" Search for Definition in the definition dictionary (atplib#search#make_defi_dict).
"{{{ atplib#search#Dsearch
function! atplib#search#Dsearch(bang,...)

    call atplib#write("nobackup")

    let time		= reltime()
    let o_pattern	= a:0 >= 1 ? matchstr(a:1, '\/\=\zs.*[^\/]\ze\/\=') : ''
    let pattern		= '\%(\\def\|\\\%(re\)\=newcommand\s*{\=\|\\providecommand\s*{\=\|\\\%(re\)\=newenvironment\s*{\|\\\%(re\)\=newtheorem\s*{\|\\definecolor\s*{\)\s*\\\=\w*\zs'.o_pattern
    let preambule_only	= ( a:bang == "!" ? 0 : 1 )
    let atp_MainFile	= atplib#FullPath(b:atp_MainFile)

    if has("python")
	let defi_dict	= atplib#search#make_defi_dict_py(a:bang, atp_MainFile, pattern)
    else
	let defi_dict	= atplib#search#make_defi_dict_vim(a:bang, atp_MainFile, pattern)
    endif

    if len(defi_dict) > 0
	" wipe out the old buffer and open new one instead
	if bufloaded("DefiSearch")
	    exe "silent bw! " . bufnr("DefiSearch") 
	endif
	if !exists("b:atp_MainFile") || !exists("b:atp_ProjectDir")
	    " Note: I should write a function to read just one variable from
	    " project file.
	    LoadProjectScript
	endif
	setl syntax=tex

	let defi_list 	= []
	let signs	= []

	for inputfile in keys(defi_dict)
	    let ifile	= readfile(inputfile)
	    for l:range in defi_dict[inputfile]
		" This respects the options 'smartcase' and 'ignorecase'.
		let case = ( &l:smartcase && &l:ignorecase && pattern =~ '\u' ? 'noignorecase'  : ( &l:ignorecase ? 'ignorecase' : 'noignorecase' )) 
		let condition = ( case == "noignorecase" ? ifile[l:range[0]-1] =~# pattern : ifile[l:range[0]-1] =~? pattern )
		if condition
		    " print the lines into defi_list
		    let i=0
		    let c=0
		    " add an empty line if the definition is longer than one line
		    if l:range[0] != l:range[1]
			call add(defi_list, '')
			let i+=1
		    endif
		    while c <= l:range[1]-l:range[0] 
			let line=l:range[0]+c
			call add(defi_list, ifile[line-1])
			if c == 0 
			    let cmd = matchstr(ifile[line-1], '\\\%(def\|\%(re\)\?newcommand\s*{\|providecommand\s*{\|\%(re\)\?newenvironment\s*{\|\%(re\)\?newtheorem\s*{\|definecolor\s*{\)\zs[^ {}#]*\ze')
			    call add(signs, [len(defi_list), cmd])
			endif
			let i+=1
			let c+=1
		    endwhile
		endif
	    endfor
	endfor

	if len(defi_list) == 0
	    redraw
	    echohl ErrorMsg
	    if a:bang == "!"
		echomsg "[ATP:] definition not found."
	    else
		echomsg "[ATP:] definition not found in the preambule, try [D or :Dsearch! to search beyond."
	    endif
	    echohl None
	    return
	endif

	" open new buffer
	let window_height= min([g:atp_DsearchMaxWindowHeight, len(defi_list)])
	let openbuffer=" +setl\\ buftype=nofile\\ nospell\\ nornu\\ nonu\\ mod\\ noswf\\ nobl\\ bh=wipe " . fnameescape("DefiSearch")
	if g:vertical == 1
	    let openbuffer="keepalt vsplit " . openbuffer 
	else
	    let openbuffer="keepalt rightbelow ".window_height."split " . openbuffer 
	endif
	silent exe openbuffer
	let &l:statusline="Dsearch: ".o_pattern

	call setline(1, defi_list)
	if getline(line(".")) =~ '^\s*$'
	    normal! dd
	    call map(signs, '[v:val[0]-1,v:val[1]]')
	endif
	if o_pattern != ""
	    call matchadd('Search', ( &l:ignorecase ? '\c' : '\C' ) .o_pattern)
	    let @/=o_pattern
	endif
	setl syntax=tex
	setl readonly
	map <buffer> <silent> q	:bd<CR>
	" Place signs:
	if has("signs") && len(signs) > 1
	    sign unplace *
	    for i in range(0,len(signs)-1)
		try
		    exe 'sign define '.signs[i][1].' text=>>'
		    exe 'sign place '.(i+1).' line='.signs[i][0].' name='.signs[i][1].' file='.expand('%:p')
		catch /E474/
		    if g:atp_devversion
			echoerr "[signs:] ".'sign place '.(i+1).' line='.signs[i][0].' name='.signs[i][1].' file='.expand('%:p')
		    endif
		endtry
	    endfor
	endif
    else
	redraw
	echohl ErrorMsg
	if a:bang == "!"
	    echomsg "[ATP:] definition not found."
	else
	    echomsg "[ATP:] definition not found in the preambule, try with a bang ! to search beyond."
	endif
	echohl None
    endif
    setl nomodifiable

    let g:source_time_DSEARCH=reltimestr(reltime(time))
endfunction
function! atplib#search#DsearchComp(ArgLead, CmdLine, CursorPos)
    if !exists("b:atp_LocalCommands")
        LocalCommands
    endif
    let list=[]
    call extend(list, b:atp_LocalCommands)
    call extend(list, b:atp_LocalColors)
    call extend(list, b:atp_LocalEnvironments)
    call filter(list, 'v:val =~ a:ArgLead')
    call map(list, 'escape(v:val, ''\*'')')
    return sort(list)
endfunction
"}}}

" Search in tree and return the one level up element and its line number.
" {{{ atplib#search#SearchInTree
" Before running this function one has to set the two variables
" s:branch/s:branch_line to 0.
" the a:tree variable should be something like:
" a:tree = { b:atp_MainFile, [ TreeOfFiles(b:atp_MainFile)[0], 0 ] }
" necessary a rooted tree!

" This function remaps keys of dictionary.
function! atplib#search#MapDict(dict) 
    let new_dict = {}
    for key in keys(a:dict)
	let new_key = fnamemodify(key, ":p")
	let new_dict[new_key] = a:dict[key] 
    endfor
    return new_dict
endfunction

function! atplib#search#SearchInTree(tree, branch, what)
    if g:atp_debugSIT
	exe "redir! > ".g:atp_TempDir."/SearchInTree.log"
	silent! echo "___SEARCH_IN_TREE___"
	silent! echo "a:branch=". a:branch
	silent! echo "a:what=" . a:what
    endif
    if g:atp_debugSIT >= 2
	silent! echo "a:tree=" . string(a:tree)
    endif
	
"     let branch	= a:tree[a:branch][0]
    if a:branch =~ '^\s*\/'
	let cwd		= getcwd()
	exe "lcd " . fnameescape(b:atp_ProjectDir)
	let branchArg	= ( g:atp_RelativePath 	? fnamemodify(a:branch, ":.") 	: a:branch  )
	let branchArgN	= ( !g:atp_RelativePath ? fnamemodify(a:branch, ":.") 	: a:branch  )
	let whatArg	= ( g:atp_RelativePath 	? fnamemodify(a:what, ":.") 	: a:what  )
	let whatArgN	= ( !g:atp_RelativePath ? fnamemodify(a:what, ":.") 	: a:what  )
	if g:atp_debugSIT
	    silent! echo "*** cwd=" . getcwd() . " b:atp_ProjectDir= " . b:atp_ProjectDir . " " . fnamemodify(a:branch, ":.") . " " . a:branch
	endif
	exe "lcd " . fnameescape(cwd)
    else
	let branchArg	= ( g:atp_RelativePath 	? a:branch 	: atplib#FullPath(a:branch) )
	let branchArgN	= ( !g:atp_RelativePath ? a:branch 	: atplib#FullPath(a:branch) )
	let whatArg	= ( g:atp_RelativePath 	? a:what 	: atplib#FullPath(a:what) )
	let whatArgN	= ( !g:atp_RelativePath ? a:what 	: atplib#FullPath(a:what) )
    endif
    if g:atp_debugSIT
	silent! echo "branchArg=" . branchArg . " branchArgN=" . branchArgN
	silent! echo "whatArg=" . whatArg . " whatArgN=" . whatArgN
    endif
    let branch	= get(a:tree, branchArg , get(a:tree, branchArgN, ['NO_BRANCH']))[0]
    if count(keys(branch), whatArg) || count(keys(branch), whatArgN)
	" The following variable is used as a return value in
	" RecursiveSearch!
	let g:ATP_branch	= branchArg
	let g:ATP_branch_line	= get(branch, whatArg, get(branch, whatArgN, ['', 'ERROR']))[1]
	if g:atp_debugSIT
	    silent! echo "g:ATP_branch=" . g:ATP_branch . "   g:ATP_branch_line=" . g:ATP_branch_line
	    redir END
	endif
	return branchArg
    else
	for new_branch in keys(branch)
	    call atplib#search#SearchInTree(branch, new_branch, whatArg)
	endfor
    endif
    if g:atp_debugSIT
	redir END
    endif
    return
endfunction
" }}}

" Search in all input files recursively.
" {{{ __Recursive_Search__
"
" Variables are used to pass them to next runs (this function calls it self) 
" a:main_file	= b:atp_MainFile
" a:start_file	= expand("%:p") 	/this variable will not change untill the
" 						last instance/ 
" a:tree	= make_tree 		=> make a tree
" 		= any other value	=> use { a:main_file : [ b:TreeOfFiles, 0] }	
" a:cur_branch	= expand("%") 		/this will change whenever we change a file/
" a:call_nr	= number of the call			
" a:wrap_nr	= if hit top/bottom a:call=0 but a:wrap_nr+=1
" a:winsaveview = winsaveview(0)  	to resotre the view if the pattern was not found
" a:bufnr	= bufnr("%")		to come back to begining buffer if pattern not found
" a:strftime	= strftime(0)		to compute the time
" a:pattern	= 			pattern to search
" a:1		=			flags: 'bcewWs'
" a:2 is not not used:
" a:2		= 			goto = DOWN_ACCEPT / Must not be used by the end user/
" 					0/1 1=DOWN_ACCEPT	
" 								
" g:atp_debugRS 	if 1 sets debugging messages which are appended to '/tmp/ATP_rs_debug' 
			" you can :set errorfile=/tmp/ATP_rs_debug
			" and	  :set efm=.*
			" if 2 show time
" log file : /tmp/ATP_rs_debug
" {{{ atplib#search#RecursiveSearch function
try
function! atplib#search#RecursiveSearch(main_file, start_file, maketree, tree, cur_branch, call_nr, wrap_nr, winsaveview, bufnr, strftime, vim_options, cwd, pattern, subfiles, ... )

    let main_file	= g:atp_RelativePath ? atplib#RelativePath(a:main_file, b:atp_ProjectDir) : a:main_file
	
    let time0	= reltime()

    " set and restore some options:
    " foldenable	(unset to prevent opening the folds :h winsaveview)
    " comeback to the starting buffer
    if a:call_nr == 1 && a:wrap_nr == 1

	" Erease message 'search hit TOP, continuing at BOTTOM':
	if &shortmess =~# 's'
	    echo ""
	endif

	if a:vim_options	== { 'no_options' : 'no_options' }
	    let vim_options 	=  { 'hidden'	: &l:hidden, 
				\ 'foldenable' 	: &l:foldenable,
				\ 'autochdir'	: &l:autochdir }
	else
	    let vim_options	= a:vim_options
	endif
	let &l:hidden		= 1
	let &l:foldenable	= 0
	let &l:autochdir	= 0

	if a:cwd		== 'no_cwd'
	    let cwd		=  getcwd()
	else
	    let cwd		= a:cwd
	endif
	exe "lcd " . fnameescape(b:atp_ProjectDir)

	" This makes it work faster when the input files were not yet opened by vim 
	" some of them will not be shown to the user.
	" Note: but sometimes files are loaded without filetype what messes up
	" things. It is possible to make it work I think, but this might not
	" be needed (speed seems to be fine).
" 	syntax off
	set eventignore+=Syntax
" 	filetype off 
	" there are many errors in /tmp/ATP_rs_debug file due to this which are not
	" important.

    else
	let vim_options		= a:vim_options
	let cwd			= a:cwd
    endif

    let subfiles = ( a:subfiles == "" ? atplib#search#SearchPackage('subfiles') : a:subfiles )

	    " Redirect debuggin messages:
	    if g:atp_debugRS
		if a:wrap_nr == 1 && a:call_nr == 1
		    exe "redir! > ".g:atp_TempDir."/RecursiveSearch.log"
		else
		    exe "redir! >> ".g:atp_TempDir."/RecursiveSearch.log"
		endif
		silent echo "________________"
		silent echo "Args: a:pattern:".a:pattern." call_nr:".a:call_nr. " wrap_nr:".a:wrap_nr . " cwd=" . getcwd()
	    endif

    	let flags_supplied = a:0 >= 1 ? a:1 : ""

	if flags_supplied =~# 'p'
	    let flags_supplied = substitute(flags_supplied, 'p', '', 'g')
	    echohl WarningMsg
	    echomsg "[ATP:] searching flag 'p' is not supported, filtering it out."
	    echohl None
	endif

	if a:maketree == 'make_tree'
	    if g:atp_debugRS
	    silent echo "*** Makeing Tree ***"
	    endif
	    let tree_of_files 	= TreeOfFiles(main_file)[0]
	else
	    if g:atp_debugRS
	    silent echo "*** Using Tree ***"
	    endif
	    let tree_of_files	= a:tree
	endif
	let tree	= { main_file : [ tree_of_files, 0 ] }

	if a:cur_branch != "no cur_branch "
	    let cur_branch	= a:cur_branch
	else
	    let cur_branch	= main_file
	endif

		if g:atp_debugRS > 1
		    silent echo "TIME0:" . reltimestr(reltime(time0))
		endif

	let pattern		= a:pattern
	let flags_supplied	= substitute(flags_supplied, '[^bcenswWS]', '', 'g')

    	" Add pattern to the search history
	if a:call_nr == 1
	    call histadd("search", a:pattern)
	    let @/ = a:pattern
	endif

	" Set up searching flags
	let flag	= flags_supplied
	if a:call_nr > 1 
	    let flag	= flags_supplied !~# 'c' ? flags_supplied . 'c' : flags_supplied
	endif
	let flag	= substitute(flag, 'w', '', 'g') . 'W'
	let flag	= flag !~# 'n' ? substitute(flag, 'n', '', 'g') . 'n' : flag
	let flag	= substitute(flag, 's', '', 'g')

	if flags_supplied !~# 'b'
	    " forward searching flag for input files:
	    let flag_i	= flags_supplied !~# 'c' ? flags_supplied . 'c' : flags_supplied
	else
	    let flag_i	= substitute(flags_supplied, 'c', '', 'g')
	endif
	let flag_i	= flag_i !~# 'n' ? flag_i . 'n' : flag_i
	let flag_i	= substitute(flag_i, 'w', '', 'g') . 'W'
	let flag_i	= substitute(flag_i, 's', '', 'g')

		if g:atp_debugRS
		silent echo "      flags_supplied:".flags_supplied." flag:".flag." flag_i:".flag_i." a:1=".(a:0 != 0 ? a:1 : "")
		endif

	" FIND PATTERN: 
	let cur_pos		= [line("."), col(".")]
	" We filter out the 's' flag which should be used only once
	" as the flags passed to next atplib#search#RecursiveSearch()es are based on flags_supplied variable
	" this will work.
	let s_flag		= flags_supplied =~# 's' ? 1 : 0
	let flags_supplied	= substitute(flags_supplied, 's', '', 'g')
	if s_flag
	    call setpos("''", getpos("."))
	endif
	keepjumps let pat_pos	= searchpos(pattern, flag)

		if g:atp_debugRS > 1
		    silent echo "TIME1:" . reltimestr(reltime(time0))
		endif

	" FIND INPUT PATTERN: 
	" (we do not need to search further than pat_pos)
	if pat_pos == [0, 0]
	    let stop_line	= flag !~# 'b' ? line("$")  : 1
	else
	    let stop_line	= pat_pos[0]
	endif
	if subfiles
	    keepjumps let input_pos	= searchpos('^[^%]*\\\(input\|include\|subfile\)\s*{', flag_i . 'n', stop_line )
	else
	    keepjumps let input_pos	= searchpos('^[^%]*\\\(input\|include\)\s*{', flag_i . 'n', stop_line )
	endif

		if g:atp_debugRS > 1
		    silent echo "TIME2:" . reltimestr(reltime(time0))
		endif

		if g:atp_debugRS
		silent echo "Positions: ".string(cur_pos)." ".string(pat_pos)." ".string(input_pos)." in branch: ".cur_branch."#".expand("%:p") . " stop_line: " . stop_line 
		endif


	" Down Accept:
	" the current value of down_accept
	let DOWN_ACCEPT = a:0 >= 2 ? a:2 : 0
	" the value of down_accept in next turn 
	let down_accept	= getline(input_pos[0]) =~ pattern || input_pos == [0, 0] ?  1 : 0

" 		if g:atp_debugRS
" 		    silent echo "DOWN_ACCEPT=" . DOWN_ACCEPT . " down_accept=" . down_accept
" 		endif

	" Decide what to do: accept the pattern, go to higher branch, go to lower
	" branch or say Pattern not found
	if flags_supplied !~# 'b'
	    " FORWARD
	    " cur < pat <= input
	    if atplib#CompareCoordinates(cur_pos,pat_pos) && atplib#CompareCoordinates_leq(pat_pos, input_pos)
		let goto_s	= 'ACCEPT'
	    " cur == pat <= input
	    elseif cur_pos == pat_pos && atplib#CompareCoordinates_leq(pat_pos, input_pos)
		" this means that the 'flag' variable has to contain 'c' or the
		" wrapscan is on
		" ACCEPT if 'c' and wrapscan is off or there is another match below,
		" if there is not go UP.
		let wrapscan	= ( flags_supplied =~# 'w' || &l:wrapscan && flags_supplied !~# 'W' )
		if flag =~# 'c'
		let goto_s	= 'ACCEPT'
		elseif wrapscan
		    " if in wrapscan and without 'c' flag
		let goto_s	= 'UP'
		else
		    " this should not happen: cur == put can hold only in two cases:
		    " wrapscan is on or 'c' is used.
		    let goto_s	= 'ERROR'
		endif
	    " pat < cur <= input
	    elseif atplib#CompareCoordinates(pat_pos, cur_pos) && atplib#CompareCoordinates_leq(cur_pos, input_pos) 
		let goto_s	= 'UP'
	    " cur < input < pat
	    elseif atplib#CompareCoordinates(cur_pos, input_pos) && atplib#CompareCoordinates(input_pos, pat_pos)
		let goto_s	= 'UP'
	    " cur < input == pat 		/we are looking for '\\input'/
	    elseif atplib#CompareCoordinates(cur_pos, input_pos) && input_pos == pat_pos
		let goto_s	= 'ACCEPT'
	    " input < cur <= pat	(includes input = 0])
	    elseif atplib#CompareCoordinates(input_pos, cur_pos) && atplib#CompareCoordinates_leq(cur_pos, pat_pos)
		" cur == pat thus 'flag' contains 'c'.
		let goto_s	= 'ACCEPT'
	    " cur == input
	    elseif cur_pos == input_pos
		let goto_s	= 'UP'
	    " cur < input < pat
	    " input == 0 			/there is no 'input' ahead - flag_i contains 'W'/
	    " 					/but there is no 'pattern ahead as well/
	    " at this stage: pat < cur 	(if not then  input = 0 < cur <= pat was done above).
	    elseif input_pos == [0, 0]
		if expand("%:p") == fnamemodify(main_file, ":p")
		    " wrapscan
		    if ( flags_supplied =~# 'w' || &l:wrapscan  && flags_supplied !~# 'W' )
			let new_flags	= substitute(flags_supplied, 'w', '', 'g') . 'W'  
			if a:wrap_nr <= 2
			    call cursor(1,1)

				if g:atp_debugRS
				silent echo " END 1 new_flags:" . new_flags 
				redir END
				endif

			    keepjumps call atplib#search#RecursiveSearch(main_file, a:start_file, "", tree_of_files, a:cur_branch, 1, a:wrap_nr+1, a:winsaveview, a:bufnr, a:strftime, vim_options, cwd, pattern, subfiles, new_flags) 

			    return
			else
			    let goto_s 	= "REJECT"
" 			    echohl ErrorMsg
" 			    echomsg 'Pattern not found: ' . a:pattern
" 			    echohl None
			endif
		    else
			let goto_s 	= "REJECT"
" 			echohl ErrorMsg
" 			echomsg 'Pattern not found: ' . a:pattern
" 			echohl None
		    endif
		" if we are not in the main file go up.
		else
		    let goto_s	= "DOWN"
		endif
	    else
		let goto_s 	= 'ERROR'
	    endif
	else
	    " BACKWARD
	    " input <= pat < cur (pat != 0)
	    if atplib#CompareCoordinates(pat_pos, cur_pos) && atplib#CompareCoordinates_leq(input_pos, pat_pos) && pat_pos != [0, 0]
		" input < pat
		if input_pos != pat_pos
		    let goto_s	= 'ACCEPT'
		" input == pat
		else
		    let goto_s	= 'UP'
		endif
	    " input <= pat == cur (input != 0)			/pat == cur => pat != 0/
	    elseif cur_pos == pat_pos && atplib#CompareCoordinates_leq(input_pos, pat_pos) && input_pos != [0, 0]
		" this means that the 'flag' variable has to contain 'c' or the
		" wrapscan is on
		let wrapscan	= ( flags_supplied =~# 'w' || &l:wrapscan  && flags_supplied !~# 'W' )
		if flag =~# 'c'
		    let goto_s 	= 'ACCEPT'
		elseif wrapscan
		    " if in wrapscan and without 'c' flag
		    let goto_s	= 'UP'
		else
		    " this should not happen: cur == put can hold only in two cases:
		    " wrapscan is on or 'c' is used.
		    let goto_s	= 'ERROR'
		endif
	    " input <= cur < pat (input != 0)
	    elseif atplib#CompareCoordinates(cur_pos, pat_pos) && atplib#CompareCoordinates_leq(input_pos, cur_pos) && input_pos != [0, 0] 
		let goto_s	= 'UP'
	    " pat < input <= cur (input != 0)
	    elseif atplib#CompareCoordinates_leq(input_pos, cur_pos) && atplib#CompareCoordinates(pat_pos, input_pos) && input_pos != [0, 0]
		let goto_s	= 'UP'
	    " input == pat < cur (pat != 0) 		/we are looking for '\\input'/
	    elseif atplib#CompareCoordinates(input_pos, cur_pos) && input_pos == pat_pos && pat_pos != [0, 0]
		let goto_s	= 'ACCEPT'
	    " pat <= cur < input (pat != 0) 
	    elseif atplib#CompareCoordinates(cur_pos, input_pos) && atplib#CompareCoordinates_leq(pat_pos, cur_pos) && input_pos != [0, 0]
		" cur == pat thus 'flag' contains 'c'.
		let goto_s	= 'ACCEPT'
	    " cur == input
	    elseif cur_pos == input_pos
		let goto_s 	= 'UP'
	    " input == 0 			/there is no 'input' ahead - flag_i contains 'W'/
	    " 					/but there is no 'pattern ahead as well/
	    " at this stage: cur < pat || pat=input=0  (if not then  pat <= cur was done above, input=pat=0 is the 
	    " 						only posibility to be passed by the above filter).
	    elseif input_pos == [0, 0]
		" I claim that then cur < pat or pat=0
		if expand("%:p") == fnamemodify(main_file, ":p")
		    " wrapscan
		    if ( flags_supplied =~# 'w' || &l:wrapscan  && flags_supplied !~# 'W' )
			let new_flags	= substitute(flags_supplied, 'w', '', 'g') . 'W'  
			if a:wrap_nr <= 2
			    call cursor(line("$"), col("$"))

				if g:atp_debugRS
				silent echo " END 2 new_flags:".new_flags
				redir END
				endif

			    keepjumps call atplib#search#RecursiveSearch(main_file, a:start_file, "", tree_of_files, a:cur_branch, 1, a:wrap_nr+1, a:winsaveview, a:bufnr, a:strftime, vim_options, cwd, pattern, subfiles, new_flags) 

				if g:atp_debugRS > 1
				    silent echo "TIME_END:" . reltimestr(reltime(time0))
				endif

			    return
			else
			    let goto_s 	= "REJECT"
" 			    echohl ErrorMsg
" 			    echomsg 'Pattern not found: ' . a:pattern
" 			    echohl None
			endif
		    else
			let goto_s 	= "REJECT"
		    endif
		" if we are not in the main file go up.
		else
		    let goto_s	= "DOWN" 
		    " If using the following line DOWN_ACCEPT and down_accept
		    " variables are not needed. This seems to be the best way.
		    " 	There is no need to use this feature for
		    " 	\input <file_name> 	files.
		    if pattern =~ '\\\\input' || pattern =~ '\\\\include' || pattern =~ '\\\\subfile'
" 			if getline(input_pos[0]) =~ pattern || getline(".") =~ pattern
			let goto_s	= "DOWN_ACCEPT"
		    endif
		endif
	    else
		let goto_s 	= 'ERROR'
	    endif
	endif

		if g:atp_debugRS
		silent echo "goto_s:".goto_s
		endif
		if g:atp_debugRS >= 2
		    silent echo "TIME ***goto*** " . reltimestr(reltime(time0))
		endif

	" When ACCEPTING the line:
	if goto_s == 'ACCEPT'
	    keepjumps call setpos(".", [ 0, pat_pos[0], pat_pos[1], 0])
	    if flags_supplied =~#  'e'
		keepjumps call search(pattern, 'e', line("."))
	    endif
	    "A Better solution must be found.
" 	    if &l:hlsearch
" 		execute '2match Search /'.pattern.'/'
" 	    endif
		
	    let time	= matchstr(reltimestr(reltime(a:strftime)), '\d\+\.\d\d\d') . "sec."

	    if &shortmess =~# 's'
		if a:wrap_nr == 2 && flags_supplied =~# 'b'
		    redraw
		    echohl WarningMsg
		    echo "search hit TOP, continuing at BOTTOM "
		    echohl None
		elseif a:wrap_nr == 2
		    redraw
		    echohl WarningMsg
		    echo "search hit BOTTOM, continuing at TOP "
		    echohl None
		endif
	    endif

		if g:atp_debugRS
		silent echo "FOUND PATTERN: " . a:pattern . " time " . time
		silent echo ""
		redir END
		endif

		" restore vim options 
		if a:vim_options != { 'no_options' : 'no_options' }
		    for option in keys(a:vim_options)
			execute "let &l:".option."=".a:vim_options[option]
		    endfor
		endif
		exe "lcd " . fnameescape(cwd)
		set eventignore-=Syntax
		syntax enable
" 		filetype on
" 		filetype detect

	    return

	" when going UP
	elseif goto_s == 'UP'
	    call setpos(".", [ 0, input_pos[0], input_pos[1], 0])
	    " Open file and Search in it"
	    " This should be done by kpsewhich:
	    if subfiles
		let file = matchstr(getline(input_pos[0]), '\\\(input\|subfile\|include\)\s*{\zs[^}]*\ze}')
	    else
		let file = matchstr(getline(input_pos[0]), '\\\(input\|include\)\s*{\zs[^}]*\ze}')
	    endif
	    if g:atp_debugRS
		silent echo " ------ file=".file." ".getline(input_pos[0])
		silent echo " ------ input_pos=".string(input_pos)
	    endif
	    let file = atplib#append_ext(file, '.tex')

	    let keepalt = ( @# == '' || expand("%:p") == a:start_file ? '' : 'keepalt' )
	    let open =  flags_supplied =~ 'b' ? keepalt . ' edit + ' : keepalt.' edit +1 '
	    let swapfile = globpath(fnamemodify(file, ":h"), ( has("unix") ? "." : "" ) . fnamemodify(file, ":t") . ".swp")

	    if !( a:call_nr == 1 && a:wrap_nr == 1 )
		let open = "silent keepjumps " . open
	    endif

	    let projectVarDict 	= SaveProjectVariables()
	    if g:atp_debugRS >= 3
		silent echo "projectVarDict : " . string(projectVarDict) 
		let g:projectVarDict = projectVarDict
	    elseif g:atp_debugRS >= 2
		let g:projectVarDict = projectVarDict
	    endif
	    if g:atp_debugRS >= 2
		silent echo "TIME ***goto UP before open*** " . reltimestr(reltime(time0))
	    endif

" ERROR: When opening for the first time there are two errors which
" I cannot figure out.

	    " OPEN:
	    if empty(swapfile) || bufexists(file)
		if g:atp_debugRS >= 2
		silent echo "Alternate (before open) " . bufname("#")
		silent echo " XXXXXXXX file=".file
		endif
		" silent should not have bang, which prevents E325 to be shown.
		silent execute open . fnameescape(file)
		if g:atp_mapNn
		    call atplib#search#ATP_ToggleNn(1,"on")
		else
		    call atplib#search#ATP_ToggleNn(1,"off")
		endif
" 		if &l:filetype != "tex"
" 		    setl filetype=tex
" 		endif
	    else
		echoerr "Recursive Search: swap file: " . swapfile . " exists. Aborting." 
		set eventignore-=Syntax
		syntax enable
		return
	    endif
	    if g:atp_debugRS >= 2
		exe "redir! >> ".g:atp_TempDir."/RecursiveSearch.log"
		silent echo "TIME ***goto UP after open*** " . reltimestr(reltime(time0))
	    endif

	    call RestoreProjectVariables(projectVarDict)
	    if g:atp_debugRS >= 2
		silent echo "TIME ***goto UP restore variables *** " . reltimestr(reltime(time0))
	    endif

	    if flags_supplied =~# 'b'
		call cursor(line("$"), col("$"))
	    else
		call cursor(1,1)
	    endif

		if g:atp_debugRS
		silent echo "In higher branch:      " . file . " POS " line(".").":".col(".") 
		silent echo "Open Command:          '" . open . file . "'"
		silent echo "exist b:TreeOfFiles    " . exists("b:TreeOfFiles")
		silent echo "flags_supplied:        " . flags_supplied
		endif
		if g:atp_debugRS >= 2
		silent echo "Alternate (after open) " . bufname("#")
		endif

		if g:atp_debugRS >= 2
		silent echo "TIME_END:              " . reltimestr(reltime(time0))
		endif


	    let flag	= flags_supplied =~ 'W' ? flags_supplied : flags_supplied . 'W'
	    if @# == ''
		keepjumps call atplib#search#RecursiveSearch(main_file, a:start_file, "", tree_of_files, expand("%:p"), a:call_nr+1, a:wrap_nr, a:winsaveview, a:bufnr, a:strftime, vim_options, cwd, pattern, subfiles, flags_supplied, down_accept)
	    else
		keepalt keepjumps call atplib#search#RecursiveSearch(main_file, a:start_file, "", tree_of_files, expand("%:p"), a:call_nr+1, a:wrap_nr, a:winsaveview, a:bufnr, a:strftime, vim_options, cwd, pattern, subfiles, flags_supplied, down_accept)
	    endif

	    if g:atp_debugRS
		redir END
	    endif
	    return

	" when going DOWN
	elseif goto_s == 'DOWN' || goto_s == 'DOWN_ACCEPT'
	    " We have to get the element in the tree one level up + line number
	    let g:ATP_branch 		= "nobranch"
	    let g:ATP_branch_line	= "nobranch_line"

		if g:atp_debugRS
		silent echo "     SearchInTree Args " . expand("%:p")
		endif

	    if g:atp_RelativePath
		call atplib#search#SearchInTree(l:tree, main_file, atplib#RelativePath(expand("%:p"), resolve(b:atp_ProjectDir)))
	    else
		call atplib#search#SearchInTree(l:tree, main_file, expand("%:p"))
	    endif

		if g:atp_debugRS
		silent echo "     SearchInTree found " . g:ATP_branch . " g:ATP_branch_line=" . g:ATP_branch_line
		endif

	    if g:ATP_branch == "nobranch"
		echohl ErrorMsg
		echomsg "[ATP:] Error. Try to run :S! or :InputFiles command."
		echohl None

		silent! echomsg "Tree=" . string(l:tree)
		silent! echomsg "MainFile " . main_file . " current_file=" . expand("%:p")
		silent! echomsg "Going to file : " . g:ATP_branch . " ( g:ATP_branch ) "

	    	" restore the window and buffer!
		let keepalt = ( @# == '' || expand("%:p") == a:start_file ? '' : 'keepalt' )
		silent execute keepalt. " keepjumps edit #" . a:bufnr
		if g:atp_mapNn
		    call atplib#search#ATP_ToggleNn(1,"on")
		else
		    call atplib#search#ATP_ToggleNn(1,"off")
		endif
		call winrestview(a:winsaveview)
		if g:atp_debugRS
		    redir END
		endif

		set eventignore-=Syntax
		syntax enable
		return
	    endif

	    let next_branch = atplib#FullPath(g:ATP_branch)
	    let swapfile = globpath(fnamemodify(next_branch, ":h"), ( has("unix") ? "." : "" ) . fnamemodify(next_branch, ":t") . ".swp")
	    let keepalt = ( @# == '' || expand("%:p") == a:start_file ? '' : 'keepalt' )
	    if a:call_nr == 1 && a:wrap_nr == 1 
		let open =  'silent '.keepalt.' edit +'.g:ATP_branch_line." ".fnameescape(next_branch)
	    else
		let open =  'silent keepjumps '.keepalt.' edit +'.g:ATP_branch_line." ".fnameescape(next_branch)
	    endif

	    if g:atp_debugRS >= 2
		silent echo "TIME ***goto DOWN before open*** " . reltimestr(reltime(time0))
	    endif
	    let projectVarDict 	= SaveProjectVariables()
	    if empty(swapfile) || bufexists(next_branch)
		if g:atp_debugRS >= 2
		silent echo "Alternate (before open) " . bufname("#")
		endif
		" silent should not have bang, which prevents E325 to be shown.
		silent execute open
		if g:atp_mapNn
		    call atplib#search#ATP_ToggleNn(1,"on")
		else
		    call atplib#search#ATP_ToggleNn(1,"off")
		endif
" 		if &l:filetype != "tex"
" 		    setl filetype=tex
" 		endif
	    else
		echoerr "Recursive Search: swap file: " . swapfile . " exists. Aborting." 
		set eventignore-=Syntax
		syntax enable
		return
	    endif
	    if g:atp_debugRS >= 2
		silent echo "TIME ***goto DOWN after open*** " . reltimestr(reltime(time0))
	    endif
	    call RestoreProjectVariables(projectVarDict)
	    if g:atp_debugRS >= 2
		silent echo "TIME ***goto DOWN restore project variables *** " . reltimestr(reltime(time0))
	    endif

" 	    call cursor(g:ATP_branch_line, 1)
	    if flags_supplied !~# 'b'
		if subfiles
		    keepjumps call search('\m\\\(input\|\include\|subfile\)\s*{[^}]*}', 'e', line(".")) 
		else
		    keepjumps call search('\m\\\(input\|\include\)\s*{[^}]*}', 'e', line(".")) 
		endif
	    endif

		if g:atp_debugRS
		silent echo "In lower branch:       " . g:ATP_branch . " branch_line=" . g:ATP_branch_line. " POS " . line(".") . ":" . col(".") 
		silent echo "Open Command           '" . open . "'"
		silent echo "exist b:TreeOfFiles    " . exists("b:TreeOfFiles")
		silent echo "flags_supplied:        " . flags_supplied
		endif
		if g:atp_debugRS >= 2
		silent echo "Alternate (after open) " . bufname("#")
		endif

		if g:atp_debugRS > 1
		silent echo "TIME_END:               " . reltimestr(reltime(time0))
		endif

	    unlet g:ATP_branch
	    unlet g:ATP_branch_line
" 	    let flag	= flags_supplied =~ 'W' ? flags_supplied : flags_supplied . 'W'
	    if goto_s == 'DOWN'
		if @# == ''
		    keepjumps call atplib#search#RecursiveSearch(main_file, a:start_file, "", tree_of_files, expand("%:p"), a:call_nr+1, a:wrap_nr, a:winsaveview, a:bufnr, a:strftime, vim_options, cwd, pattern, subfiles, flags_supplied)
		else
		    keepalt keepjumps call atplib#search#RecursiveSearch(main_file, a:start_file, "", tree_of_files, expand("%:p"), a:call_nr+1, a:wrap_nr, a:winsaveview, a:bufnr, a:strftime, vim_options, cwd, pattern, subfiles, flags_supplied)
		endif
	    endif

	" when REJECT
	elseif goto_s == 'REJECT'
	    echohl ErrorMsg
	    echomsg "[ATP:] pattern not found"
	    echohl None

	    if g:atp_debugRS > 1
		silent echo "TIME_END:" . reltimestr(reltime(time0))
	    endif

" 	    restore the window and buffer!
" 		it is better to remember bufnumber
	    let keepalt = ( @# == '' || expand("%:p") == a:start_file ? '' : 'keepalt' )
	    silent execute "keepjumps ".keepalt." edit #" . a:bufnr
	    if g:atp_mapNn
		call atplib#search#ATP_ToggleNn(1,"on")
	    else
		call atplib#search#ATP_ToggleNn(1,"off")
	    endif

	    call winrestview(a:winsaveview)

		if g:atp_debugRS
		silent echo ""
		redir END
		endif

	    " restore vim options 
	    if a:vim_options != { 'no_options' : 'no_options' }
		for option in keys(a:vim_options)
		    execute "let &l:".option."=".a:vim_options[option]
		endfor
	    endif
	    exe "lcd " . fnameescape(cwd)
	    set eventignore-=Syntax
	    syntax enable
" 	    filetype on
" 	    filetype detect

	    return

	" when ERROR
	elseif
	    echohl ErrorMsg
	    echomsg "[ATP:] this is a bug in ATP."
	    echohl None
	    
	    " restore vim options 
	    if a:vim_options != { 'no_options' : 'no_options' }
		for option in keys(a:vim_options)
		    execute "let &l:".option."=".a:vim_options[option]
		endfor
	    endif
	    exe "lcd " . fnameescape(cwd)
	    set eventignore-=Syntax
" 	    filetype on
" 	    filetype detect

	    " restore the window and buffer!
	    let keepalt = ( @# == '' || expand("%:p") == a:start_file ? '' : 'keepalt' )
	    silent execute "keepjumps ".keepalt." edit #" . a:bufnr
	    if g:atp_mapNn
		call atplib#search#ATP_ToggleNn(1,"on")
	    else
		call atplib#search#ATP_ToggleNn(1,"off")
	    endif
	    call winrestview(a:winsaveview)

	    return 
	endif
endfunction
catch /E127:/  
endtry
" }}}

" User interface to atplib#search#RecursiveSearch function.
" atplib#search#GetSearchArgs {{{
" This functionn returns arguments from <q-args> - a list [ pattern, flag ]
" It allows to pass arguments to atplib#search#Search in a similar way to :vimgrep, :ijump, ... 
function! atplib#search#GetSearchArgs(Arg,flags)
    let g:Arg = a:Arg
    if a:Arg =~ '^\/'
	let pattern 	= matchstr(a:Arg, '^\/\zs.*\ze\/')
	let flag	= matchstr(a:Arg, '\/.*\/\s*\zs['.a:flags.']*\ze\s*$')
    elseif a:Arg =~ '^\i' && a:Arg !~ '^\w'
	let pattern 	= matchstr(a:Arg, '^\(\i\)\zs.*\ze\1')
	let flag	= matchstr(a:Arg, '\(\i\).*\1\s*\zs['.a:flags.']*\ze\s*$')
    else
	let pattern	= matchstr(a:Arg, '^\zs\S*\ze')
	let flag	= matchstr(a:Arg, '^\S*\s*\zs['.a:flags.']*\ze\s*$')
    endif
    return [ pattern, flag ]
endfunction
"}}}
" {{{ atplib#search#Search()
try
function! atplib#search#Search(Bang, Arg)

    "Like :s, :S should be a jump-motion (see :help jump-motions)
    normal! m`

    let atp_MainFile	= atplib#FullPath(b:atp_MainFile)
    let [ pattern, flag ] = atplib#search#GetSearchArgs(a:Arg, 'bceswWx')

    if pattern == ""
	echohl ErrorMsg
	echomsg "[ATP:] enclose the pattern with /.../"
	echohl None
	return
    endif

    let subfiles = atplib#search#SearchPackage('subfiles')

    if a:Bang == "!" || !exists("b:TreeOfFiles")
	call atplib#search#RecursiveSearch(atp_MainFile, expand("%:p"), 'make_tree', '', expand("%:p"), 1, 1, winsaveview(), bufnr("%"), reltime(), { 'no_options' : 'no_options' }, 'no_cwd', pattern, subfiles, flag)
    else
	call atplib#search#RecursiveSearch(atp_MainFile, expand("%:p"), '', deepcopy(b:TreeOfFiles),  expand("%:p"), 1, 1, winsaveview(), bufnr("%"), reltime(), { 'no_options' : 'no_options' }, 'no_cwd', pattern, subfiles, flag)
    endif

endfunction
catch /E127: Cannot redefine function/  
endtry
" }}}

function! atplib#search#ATP_ToggleNn(silent,...) " {{{
" With bang it is only used in RecursiveSearch function (where it is used
" twice in a row).
    let on	= ( a:0 ? ( a:1 == 'on' || string(a:1) == '1' ? 1 : 0 ) : !g:atp_mapNn )
    if !on
	silent! nunmap <buffer> n
	silent! nunmap <buffer> N
	silent! aunmenu LaTeX.Toggle\ Nn\ [on]
	let g:atp_mapNn	= 0
	nmenu 550.79 &LaTeX.Toggle\ &Nn\ [off]<Tab>:ToggleNn		:ToggleNn<CR>
	imenu 550.79 &LaTeX.Toggle\ &Nn\ [off]<Tab>:ToggleNn		<Esc>:ToggleNn<CR>a
	tmenu LaTeX.Toggle\ Nn\ [off] atp maps to n,N.
	if !a:silent
	    echomsg "[ATP:] vim nN maps"  
	endif
    else
	silent! nmap <buffer> <silent> n    <Plug>RecursiveSearchn
	silent! nmap <buffer> <silent> N    <Plug>RecursiveSearchN
	silent! aunmenu LaTeX.Toggle\ Nn\ [off]
	let g:atp_mapNn	= 1
	nmenu 550.79 &LaTeX.Toggle\ &Nn\ [on]<Tab>:ToggleNn			:ToggleNn<CR>
	imenu 550.79 &LaTeX.Toggle\ &Nn\ [on]<Tab>:ToggleNn			<Esc>:ToggleNn<CR>a
	tmenu LaTeX.Toggle\ Nn\ [on] n,N vim normal commands.
	if !a:silent
	    echomsg "[ATP:] atp nN maps"
	endif
    endif
endfunction
function! atplib#search#SearchHistCompletion(ArgLead, CmdLine, CursorPos)
    let search_history=[]
    let hist_entry	= histget("search")
    let nr = 0
    while hist_entry != ""
	call add(search_history, hist_entry)
	let nr 		-= 1
	let hist_entry	=  histget("search", nr)
    endwhile
    
    return filter(search_history, "v:val =~# '^'.a:ArgLead")
endfunction
"}}}
"}}}

" These are only variables and front end functions for Bib Search Engine of ATP.
" Search engine is define in autoload/atplib.vim script library.
"{{{ Bibliography Search
"-------------SEARCH IN BIBFILES ----------------------
" This function counts accurence of a:keyword in string a:line, 
" there are two methods keyword is a string to find (a:1=0)or a pattern to
" match, the pattern used to is a:keyword\zs.* to find the place where to cut.
" DEBUG:
" command -buffer -nargs=* Count :echo atplib#count(<args>)
" Front End Function
" {{{ BibSearch
"  There are three arguments: {pattern}, [flags, [choose]]
function! atplib#search#BibSearch(bang,...)
"     let pattern = a:0 >= 1 ? a:1 : ""
"     let flag	= a:0 >= 2 ? a:2 : ""
	
    let time=reltime()
	
    let Arg = ( a:0 >= 1 ? a:1 : "" )
    if Arg != ""
	let [ pattern, flag ] = atplib#search#GetSearchArgs(Arg, 'aetbjsynvpPNShouH@BcpmMtTulL')
    else
	let [ pattern, flag ] = [ "", ""] 
    endif

    let b:atp_LastBibPattern = pattern
    "     This cannot be set here.  It is set later by atplib#bibsearch#showresults function.
    "     let b:atp_LastBibFlags	= flag
    let @/ = pattern

    if g:atp_debugBS
	exe "redir! > ".g:atp_TempDir."/Bibsearch.log"
	silent! echo "==========BibSearch=========================="
	silent! echo "b:BibSearch_pattern=" . pattern
	silent! echo "b:BibSearch bang="    . a:bang
	silent! echo "b:BibSearch flag="    . flag	
	let g:BibSearch_pattern = pattern
	let g:BibSearch_bang	= a:bang
	let g:BibSearch_flag	= flag
	redir END
    endif

    if !exists("s:bibdict")
	let s:bibdict={}
	if !exists("b:ListOfFiles") || !exists("b:TypeDict") || a:bang == "!"
	    call TreeOfFiles(b:atp_MainFile)
	endif
	for file in b:ListOfFiles
	    if b:TypeDict[file] == "bib"
		if atplib#FullPath(file) != file
		    let s:bibdict[file]=readfile(atplib#search#KpsewhichFindFile('bib', file))
		else
		    let s:bibdict[file]=readfile(file)
		endif
	    endif
	endfor
    endif
    let b:atp_BibFiles=keys(s:bibdict)

    if has("python") && g:atp_bibsearch == "python"
	call atplib#bibsearch#showresults(a:bang, atplib#bibsearch#searchbib_py(a:bang, pattern, keys(s:bibdict)), flag, pattern, s:bibdict)
    else
	call atplib#bibsearch#showresults("", atplib#bibsearch#searchbib(pattern, s:bibdict), flag, pattern, s:bibdict)
    endif
    let g:time_BibSearch=reltimestr(reltime(time))
endfunction
" }}}
"}}}

" Other Searching Tools: 
" {{{1 atplib#search#KpsewhichGlobPath 
" 	a:format	is the format as reported by kpsewhich --help
" 	a:path		path if set to "", then kpsewhich will find the path.
" 			The default is what 'kpsewhich -show-path tex' returns
" 			with "**" appended. 
" 	a:name 		can be "*" then finds all files with the given extension
" 			or "*.cls" to find all files with a given extension.
" 	a:1		modifiers (the default is ":t:r")
" 	a:2		filters path names matching the pattern a:1
" 	a:3		filters out path names not matching the pattern a:2
"
" 	Argument a:path was added because it takes time for kpsewhich to return the
" 	path (usually ~0.5sec). ATP asks kpsewhich on start up
" 	(g:atp_kpsewhich_tex) and then locks the variable (this will work
" 	unless sb is reinstalling tex (with different personal settings,
" 	changing $LOCALTEXMF) during vim session - not that often). 
"
" Example: call atplib#search#KpsewhichGlobPath('tex', '', '*', ':p', '^\(\/home\|\.\)','\%(texlive\|kpsewhich\|generic\)')
" gives on my system only the path of current dir (/.) and my localtexmf. 
" this is done in 0.13s. The long pattern is to 
"
" atplib#search#KpsewhichGlobPath({format}, {path}, {expr=name}, [ {mods}, {pattern_1}, {pattern_2}]) 
function! atplib#search#KpsewhichGlobPath(format, path, name, ...)
    let time	= reltime()
    let modifiers = a:0 == 0 ? ":t:r" : a:1
    if a:path == ""
	let path	= substitute(substitute(system("kpsewhich -show-path ".a:format ),'!!','','g'),'\/\/\+','\/','g')
	let path	= substitute(path,':\|\n',',','g')
	let path_list	= split(path, ',')
	let idx		= index(path_list, '.')
	if idx != -1
	    let dot 	= remove(path_list, index(path_list,'.')) . ","
	else
	    let dot 	= ""
	endif
	call map(path_list, 'v:val . "**"')

	let path_list	= ['.']+path_list
	let path	= join(path_list, ',')
    else
	let path = a:path
    endif
    " If a:2 is non zero (if not given it is assumed to be 0 for compatibility
    " reasons)
    if get(a:000, 1, 0) != "0"
	if !exists("path_list")
	    let path_list	= split(path, ',')
	endif
	call filter(path_list, 'v:val =~ a:2')
	let path	= join(path_list, ',')
    endif
    if get(a:000, 2, 0) != "0"
	if !exists("path_list")
	    let path_list	= split(path, ',')
	endif
	call filter(path_list, 'v:val !~ a:3')
	let path	= join(path_list, ',')
    endif

    let list	= split(globpath(path, a:name),"\n") 
    if modifiers != ":p"
        call map(list, 'fnamemodify(v:val, modifiers)')
    endif
    let g:time_KpsewhichGlobPath=reltimestr(reltime(time))
    return list
endfunction
" }}}1
" {{{1 atplib#search#KpsewhichFindFile
" the arguments are similar to atplib#KpsewhichGlob except that the a:000 list
" is shifted:
" a:1		= path	
" 			if set to "" then kpsewhich will find the path.
" a:2		= count (as for findfile())
" 		  when count < 0 returns a list of all files found
" a:3		= modifiers 
" a:4		= positive filter for path (see KpsewhichGLob a:1)
" a:5		= negative filter for path (see KpsewhichFind a:2)
"
" needs +path_extra vim feature
"
" atp#KpsewhichFindFile({format}, {expr=name}, [{path}, {count}, {mods}, {pattern_1}, {pattern_2}]) 
function! atplib#search#KpsewhichFindFile(format, name, ...)

    " Unset the suffixadd option
    let saved_sua	= &l:suffixesadd
    let &l:sua	= ""

"     let time	= reltime()
    let path	= a:0 >= 1 ? a:1 : ""
    let l:count	= a:0 >= 2 ? a:2 : 0
    let modifiers = a:0 >= 3 ? a:3 : ""
    " This takes most of the time!
    if !path
	let path	= substitute(substitute(system("kpsewhich -show-path ".a:format ),'!!','','g'),'\/\/\+','\/','g')
	let path	= substitute(path,':\|\n',',','g')
	let path_list	= split(path, ',')
	let idx		= index(path_list, '.')
	if idx != -1
	    let dot 	= remove(path_list, index(path_list,'.')) . ","
	else
	    let dot 	= ""
	endif
	call map(path_list, 'v:val . "**"')

	let path	= dot . join(path_list, ',')
	unlet path_list
    endif


    " If a:2 is non zero (if not given it is assumed to be 0 for compatibility
    " reasons)
    if get(a:000, 3, 0) != 0
	let path_list	= split(path, ',')
	call filter(path_list, 'v:val =~ a:4')
	let path	= join(path_list, ',')
    endif
    if get(a:000, 4, 0) != 0
	let path_list	= split(path, ',')
	call filter(path_list, 'v:val !~ a:5')
	let path	= join(path_list, ',')
    endif

    let g:name = a:name
    let g:path = path
    let g:count = l:count

    if l:count >= 1
	if has("python")
	    let result	= atplib#search#findfile(a:name, path, l:count)
	else
	    let result	= findfile(a:name, path, l:count)
	endif
    elseif l:count == 0
	if has("python")
	    let result	= atplib#search#findfile(a:name, path)
	else
	    let result	= findfile(a:name, path)
	endif
    elseif l:count < 0
	if has("python")
	    let result	= atplib#search#findfile(a:name, path, -1)
	else
	    let result	= findfile(a:name, path, -1)
	endif
    endif
	
    if l:count >= 0 && modifiers != ""
	let result	= fnamemodify(result, modifiers) 
    elseif l:count < 0 && modifiers != ""
	call map(result, 'fnamemodify(v:val, modifiers)')
    endif

    let &l:sua	= saved_sua
    return result
endfunction
" }}}1
" {{{1 atplib#search#findfile
function! atplib#search#findfile(fname, ...)
" Python implementation of the vim findfile() function.
let time = reltime()
let path = ( a:0 >= 1 ? a:1 : &l:path )
let l:count = ( a:0 >= 2 ? a:2 : 1 )
python << EOF
import vim
import os.path
import glob
import json

path=vim.eval("path")
fname=vim.eval("a:fname")
file_list = []
for p in path.split(","):
    if len(p) >= 2 and p[-2:] == "**":
	file_list.extend(glob.glob(os.path.join( p[:-2], fname )))
    file_list.extend(glob.glob(os.path.join( p, fname )))

vim.command("let file_list=%s" % json.dumps(file_list))
EOF
if l:count == -1
    return file_list
elseif l:count <= len(file_list)
    return file_list[l:count-1]
else
    return ""
endif
endfunction
"}}}1

" atplib#search#SearchPackage {{{1
"
" This function searches if the package in question is declared or not.
" Returns the line number of the declaration  or 0 if it was not found.
"
" It was inspired by autex function written by Carl Mueller, math at carlm e4ward c o m
" and made work for project files using lvimgrep.
"
" This function doesn't support plaintex files (\\input{})
" ATP support plaintex input lines in a different way (but not that flexible
" as this: for plaintex I use atplib#GrepPackageList on startup (only!) and
" then match input name with the list).
"
" name = package name (tikz library name)
" a:1  = stop line (number of the line \\begin{document} 
" a:2  = pattern matching the command (without '^[^%]*\\', just the name)
" to match \usetikzlibrary{...,..., - 
function! atplib#search#SearchPackage(name,...)

    let atp_MainFile	= atplib#FullPath(b:atp_MainFile)
    if !filereadable(atp_MainFile)
	silent echomsg "[ATP:] atp_MainFile : " . atp_MainFile . " is not readable "
	return
    endif
    let cwd = getcwd()
    if exists("b:atp_ProjectDir") && getcwd() != b:atp_ProjectDir
	try
	    exe "lcd " . fnameescape(b:atp_ProjectDir)
	catch /E344/
	endtry
    endif

    if getbufvar("%", "atp_MainFile") == ""
	call SetProjectName()
    endif

    let com	= a:0 >= 2 ? a:2 : 'usepackage\s*\%(\[[^\]]*\]\)\?'

    " If the current file is the atp_MainFile
    if expand("%:p") == atp_MainFile

	if !exists("saved_pos")
	    let saved_pos=getpos(".")
	endif
	keepjumps call setpos(".",[0,1,1,0])
	let stop_line	= search('^\([^%]\|\\%]\)*\\begin\s*{\s*document\s*}', 'ncW')
	if stop_line != 0
	    keepjumps let ret = search('\C^[^%]*\\'.com.'\s*{[^}]*'.a:name,'ncW', stop_line)
	    keepjump call setpos(".",saved_pos)
	    exe "lcd " . fnameescape(cwd)
	    return ret
	else
	    keepjumps let ret = search('\C^[^%]*\\'.com.'\s*{[^}]*'.a:name,'ncW')
	    keepjump call setpos(".", saved_pos)
	    exe "lcd " . fnameescape(cwd)
	    return ret
	endif

    " If the current file is not the mainfile
    else
	" Cache the Preambule / it is not changing so this is completely safe /
	if !exists("s:Preambule")
	    let s:Preambule = readfile(atp_MainFile) 
	endif
	let lnum = 1
	for line in s:Preambule
	    if line =~ '^[^%]*\\'.com.'\s*{[^}]*\C'.a:name

		exe "lcd " . fnameescape(cwd)
		return lnum
	    endif
	    if line =~ '^\([^%]\|\\%\)*\\begin\s*{\s*document\s*}'
		if lnum < len(s:Preambule)
		    call remove(s:Preambule, lnum-1, -1)
		endif
		exe "lcd " . fnameescape(cwd)
		return 0
	    endif
	    let lnum += 1
	endfor
    endif

"     echo reltimestr(reltime(time))

    " If the package was not found return 0 
    exe "lcd " . fnameescape(cwd)
    return 0

endfunction
" }}}1
"{{{1 atplib#search#GrepPackageList
" This function returns list of packages declared in the b:atp_MainFile (or
" a:2). If the filetype is plaintex it returns list of all \input{} files in
" the b:atp_MainFile. 
" I'm not shure if this will be OK for project files written in plaintex: Can
" one declare a package in the middle of document? probably yes. So it might
" be better to use TreeOfFiles in that case.

" This takes =~ 0.02 s. This is too long to call it in complete#TabCompletion.
function! atplib#search#GrepPackageList(...)
" 	let time = reltime() 
    let file	= a:0 >= 2 ? a:2 : getbufvar("%", "atp_MainFile") 
    let pat	= a:0 >= 1 ? a:1 : ''
    if file == ""
	return []
    endif

    let ftype	= getbufvar(file, "&filetype")
    if pat == ''
	if ftype =~ '^\(ams\)\=tex$'
	    let pat	= '\\usepackage\s*\(\[[^]]*\]\)\=\s*{'
	elseif ftype == 'plaintex'
	    let pat = '\\input\s*{'
	else
    " 	echoerr "ATP doesn't recognize the filetype " . &l:filetype . ". Using empty list of packages."
	    return []
	endif
    endif

    let saved_loclist	= getloclist(0)
    try
	silent execute 'lvimgrep /^[^%]*'.pat.'/j ' . fnameescape(file)
    catch /E480:/
	call setloclist(0, [{'text' : 'empty' }])
    endtry
    let loclist		= getloclist(0)
    call setloclist(0, saved_loclist)

    let pre		= map(loclist, 'v:val["text"]')
    let pre_l		= []
    for line in pre
	let package_l	= matchstr(line, pat.'\zs[^}]*\ze}')
	call add(pre_l, package_l)
    endfor

    " We make a string of packages separeted by commas and the split it
    " (compatibility with \usepackage{package_1,package_2,...})
    let pre_string	= join(pre_l, ',')
    let pre_list	= split(pre_string, ',')
    call filter(pre_list, "v:val !~ '^\s*$'")

"      echo reltimestr(reltime(time))
    return pre_list
endfunction
"{{{1 atplib#search#GrepPreambule
function! atplib#search#GrepPreambule(pattern, ...)
    let saved_loclist 	= getloclist(0)
    let atp_MainFile	= ( a:0 >= 1 ? a:1 : atplib#FullPath(b:atp_MainFile) ) 
    let winview = winsaveview()
    exe 'silent! 1lvimgrep /^[^%]*\\begin\s*{\s*document\s*}/j ' . fnameescape(atp_MainFile)
    let linenr = get(get(getloclist(0), 0, {}), 'lnum', 'nomatch')
    if linenr == "nomatch"
	call setloclist(0, saved_loclist)
	return
    endif
    exe 'silent! lvimgrep /'.a:pattern.'\%<'.linenr.'l/jg ' . fnameescape(atp_MainFile) 
    let matches = getloclist(0)
    call setloclist(0, saved_loclist)
    return matches
endfunction

" atplib#search#DocumentClass {{{1
function! atplib#search#DocumentClass(file)
    if bufloaded(a:file)
	let bufnr = bufnr(a:file)
	let file = getbufline(bufnr, 1, 50)
    elseif filereadable(a:file)
	let file = readfile(a:file, 50)
    else
	return ''
    endif
    let lnr = -1
    let documentclass = ''
    for line in file
	let lnr += 1
	if line =~ '^[^%]*\\documentclass'
	    let stream = matchstr(line, '^[^%]*\\documentclass\zs.*').join(file[(lnr+1):], "\n")
	    let idx = -1
	    while idx < len(stream)
		let idx += 1
		let chr = stream[idx]
		if chr == '['
		    " jump to ']'
		    while idx < len(stream)
			let idx += 1
			let chr = stream[idx]
			if chr == ']'
			    break
			endif
		    endwhile
		elseif chr == '%'
		    while idx < len(stream)
			let idx += 1
			let chr = stream[idx]
			if chr == "\n"
			    break
			endif
		    endwhile
		elseif chr == '{'
		    while idx < len(stream)
			let idx += 1
			let chr = stream[idx]
			if chr == '}'
			    return matchstr(documentclass, '\s*\zs\S*')
			else
			    let documentclass .= chr
			endif
		    endwhile
		endif
	    endwhile
	endif
    endfor
    return 0
endfunction
" }}}1

" Make a tree of input files.
" {{{ atplib#search#TreeOfFiles_vim
" this is needed to make backward searching.
" It returns:
" 	[ {tree}, {list}, {type_dict}, {level_dict} ]
" 	where {tree}:
" 		is a tree of files of the form
" 			{ file : [ subtree, linenr ] }
"		where the linenr is the linenr of \input{file} iline the one level up
"		file.
"	{list}:
"		is just list of all found input files (except the main file!).
"	{type_dict}: 
"		is a dictionary of types for files in {list}
"		type is one of: preambule, input, bib. 
"
" {flat} =  1 	do not be recursive
" {flat} =  0	the deflaut be recursive for input files (not bib and not preambule) 
" 		bib and preambule files are not added to the tree	
" {flat} = -1 	include input and premabule files into the tree
" 		

" TreeOfFiles({main_file}, [{pattern}, {flat}, {run_nr}])
" debug file - /tmp/tof_log
" a:main_file	is the main file to start with
function! atplib#search#TreeOfFiles_vim(main_file,...)
" let time	= reltime()

    let atp_MainFile = atplib#FullPath(b:atp_MainFile)

    if !exists("b:atp_OutDir")
	call atplib#common#SetOutDir(0, 1)
    endif

    let tree		= {}

    " flat = do a flat search, i.e. fo not search in input files at all.
    let flat		= a:0 >= 2	? a:2 : 0	

    " This prevents from long runs on package files
    " for example babel.sty has lots of input files.
    if expand("%:e") != 'tex'
	return [ {}, [], {}, {} ]
    endif
    let run_nr		= a:0 >= 3	? a:3 : 1 
    let biblatex	= 0

    " Adjust g:atp_inputfile_pattern if it is not set right 
    if run_nr == 1 
	let pattern = '^[^%]*\\\%(input\s*{\=\|include\s*{'
	if '\subfile{' !~ g:atp_inputfile_pattern && atplib#search#SearchPackage('subfiles')
	    let pattern .= '\|subfile\s*{'
	endif
	let biblatex = atplib#search#SearchPackage('biblatex')
	if biblatex
	    " If biblatex is present, search for bibliography files only in the
	    " preambule.
	    if '\addbibresource' =~ g:atp_inputfile_pattern || '\addglobalbib' =~ g:atp_inputfile_pattern || '\addsectionbib' =~ g:atp_inputfile_pattern || '\bibliography' =~ g:atp_inputfile_pattern
		echo "[ATP:] You might remove biblatex patterns from g:atp_inputfile_pattern if you use biblatex package."
	    endif
	    let biblatex_pattern = '^[^%]*\\\%(bibliography\s*{\|addbibresource\s*\%(\[[^]]*\]\)\?\s*{\|addglobalbib\s*\%(\[[^]]*\]\)\?\s*{\|addsectionbib\s*\%(\[[^]]*\]\)\?\s*{\)'
	else
	    let pattern .= '\|bibliography\s*{'
	endif
	let pattern .= '\)'
    endif
    let pattern		= a:0 >= 1 	? a:1 : g:atp_inputfile_pattern

	if g:atp_debugToF
	    if exists("g:atp_TempDir")
		if run_nr == 1
		    exe "redir! > ".g:atp_TempDir."/TreeOfFiles.log"
		else
		    exe "redir! >> ".g:atp_TempDir."/TreeOfFiles.log"
		endif
	    endif
	endif

	if g:atp_debugToF
	    silent echo run_nr . ") |".a:main_file."| expand=".expand("%:p") 
	endif
	
    if run_nr == 1
	let cwd		= getcwd()
	exe "lcd " . fnameescape(b:atp_ProjectDir)
    endif
	

    let line_nr		= 1
    let ifiles		= []
    let list		= []
    let type_dict	= {}
    let level_dict	= {}

    let saved_llist	= getloclist(0)
    if run_nr == 1 && &l:filetype =~ '^\(ams\)\=tex$'
	try
	    silent execute 'lvimgrep /\\begin\s*{\s*document\s*}/j ' . fnameescape(a:main_file)
	catch /E480:/
	endtry
	let end_preamb	= get(get(getloclist(0), 0, {}), 'lnum', 0)
	call setloclist(0,[])
	if biblatex
	    try
		silent execute 'lvimgrep /'.biblatex_pattern.'\%<'.end_preamb.'l/j ' . fnameescape(a:main_file)
	    catch /E480:/
	    endtry
	endif
    else
	let end_preamb	= 0
	call setloclist(0,[])
    endif

    try
	silent execute "lvimgrepadd /".pattern."/jg " . fnameescape(a:main_file)
    catch /E480:/
"     catch /E683:/ 
" 	let g:pattern = pattern
" 	let g:filename = fnameescape(a:main_file)
    endtry
    let loclist	= getloclist(0)
    call setloclist(0, saved_llist)
    let lines	= map(loclist, "[ v:val['text'], v:val['lnum'], v:val['col'] ]")

    	if g:atp_debugToF
	    silent echo run_nr . ") Lines: " .string(lines)
	endif

    for entry in lines

	    let [ line, lnum, cnum ] = entry
	    " input name (iname) as appeared in the source file
	    let iname	= substitute(matchstr(line, pattern . '\(''\|"\)\=\zs\f\%(\f\|\s\)*\ze\1\='), '\s*$', '', '') 
	    if iname == "" && biblatex 
		let iname	= substitute(matchstr(line, biblatex_pattern . '\(''\|"\)\=\zs\f\%(\f\|\s\)*\ze\1\='), '\s*$', '', '') 
	    endif
	    if g:atp_debugToF
		silent echo run_nr . ") iname=".iname
	    endif
	    if line =~ '{\s*' . iname
		let iname	= substitute(iname, '\\\@<!}\s*$', '', '')
	    endif

	    let iext	= fnamemodify(iname, ":e")
	    if g:atp_debugToF
		silent echo run_nr . ") iext=" . iext
	    endif

	    if iext == "ldf"  || 
			\( &filetype == "plaintex" && getbufvar(fnamemodify(b:atp_MainFile, ":t"), "&filetype") != "tex") 
			\ && expand("%:p") =~ 'texmf'
		" if the extension is ldf (babel.sty) or the file type is plaintex
		" and the filetype of main file is not tex (it can be empty when the
		" buffer is not loaded) then match the full path of the file: if
		" matches then doesn't go below this file. 
		if g:atp_debugToF
		    silent echo run_nr . ") CONTINUE"
		endif
		continue
	    endif

	    " type: preambule,bib,input.
	    if strpart(line, cnum-1)  =~ '^\s*\(\\bibliography\>\|\\addglobalbib\>\|\\addsectionbib\>\|\\addbibresource\>\)'
		let type	= "bib"
	    elseif lnum < end_preamb && run_nr == 1
		let type	= "preambule"
	    else
		let type	= "input"
	    endif

	    if g:atp_debugToF
		silent echo run_nr . ") type=" . type
	    endif

	    let inames	= []
	    if type != "bib"
		let inames		= [ atplib#append_ext(iname, '.tex') ]
	    else
		let inames		= map(split(iname, ','), "atplib#append_ext(v:val, '.bib')")
	    endif

	    if g:atp_debugToF
		silent echo run_nr . ") inames " . string(inames)
	    endif

	    " Find the full path only if it is not already given. 
	    for iname in inames
		let saved_iname = iname
		if iname != fnamemodify(iname, ":p")
		    if type != "bib"
			let iname	= atplib#search#KpsewhichFindFile('tex', iname, expand(b:atp_OutDir) . "," . g:atp_texinputs , 1, ':p', '^\%(\/home\|\.\)', '\(^\/usr\|texlive\|kpsewhich\|generic\|miktex\)')
		    else
			let iname	= atplib#search#KpsewhichFindFile('bib', iname, expand(b:atp_OutDir) . "," . g:atp_bibinputs , 1, ':p')
		    endif
		endif

		if fnamemodify(iname, ":t") == "" 
		    let iname  = expand(saved_iname, ":p")
		endif

		if g:atp_debugToF
		    silent echo run_nr . ") iname " . string(iname)
		endif

		if g:atp_RelativePath
		    let iname = atplib#RelativePath(iname, (fnamemodify(resolve(b:atp_MainFile), ":h")))
		endif

		call add(ifiles, [ iname, lnum] )
		call add(list, iname)
		call extend(type_dict, { iname : type } )
		call extend(level_dict, { iname : run_nr } )
	    endfor
    endfor

	    if g:atp_debugToF
		silent echo run_nr . ") list=".string(list)
	    endif

    " Be recursive if: flat is off, file is of input type.
    if !flat || flat <= -1
    for [ifile, line] in ifiles	
	if type_dict[ifile] == "input" && flat <= 0 || ( type_dict[ifile] == "preambule" && flat <= -1 )
	     let [ ntree, nlist, ntype_dict, nlevel_dict ] = atplib#search#TreeOfFiles_vim(ifile, pattern, flat, run_nr+1)

	     call extend(tree, 		{ ifile : [ ntree, line ] } )
	     call extend(list, nlist, index(list, ifile)+1)  
	     call extend(type_dict, 	ntype_dict)
	     call extend(level_dict, 	nlevel_dict)
	endif
    endfor
    else
	" Make the flat tree
	for [ ifile, line ]  in ifiles
	    call extend(tree, { ifile : [ {}, line ] })
	endfor
    endif

"	Showing time takes ~ 0.013sec.
"     if run_nr == 1
" 	echomsg "TIME:" . join(reltime(time), ".") . " main_file:" . a:main_file
"     endif
    let [ b:TreeOfFiles, b:ListOfFiles, b:TypeDict, b:LevelDict ] = deepcopy([ tree, list, type_dict, level_dict])

    " restore current working directory
    if run_nr == 1
	exe "lcd " . fnameescape(cwd)
    endif

    if g:atp_debugToF && run_nr == 1
	silent! echo "========TreeOfFiles========================"
	silent! echo "TreeOfFiles b:ListOfFiles=" . string(b:ListOfFiles)
	redir END
    endif


    return [ tree, list, type_dict, level_dict ]

endfunction "}}}
" atplib#search#TreeOfFiles_py "{{{
function! atplib#search#TreeOfFiles_py(main_file)

let b:TreeOfFiles = {}
let b:ListOfFiles = []
let b:TypeDict = {}
let b:LevelDict = {}

let time=reltime()
python << END_PYTHON
import vim
import re
import subprocess
import os
import glob
import json
from atplib.search import scan_preambule
from atplib.search import addext
from atplib.search import kpsewhich_find
from atplib.search import kpsewhich_path

filename = vim.eval('a:main_file')
relative_path = vim.eval('g:atp_RelativePath')
project_dir = vim.eval('b:atp_ProjectDir')

def vim_remote_expr(servername, expr):
    """Send <expr> to vim server,

    expr must be well quoted:
          vim_remote_expr('GVIM', "atplib#callback#TexReturnCode()")"""
    cmd=[options.progname, '--servername', servername, '--remote-expr', expr]
    subprocess.Popen(cmd, stdout=subprocess.PIPE).wait()

def preambule_end(file):
    """Find linenr where preambule ends,

    file is list of lines."""
    nr=1
    for line in file:
        if re.search(r'\\begin\s*{\s*document\s*}', line):
            return nr
        nr+=1
    return 0

def bufnumber(file):

    cdir = os.path.abspath(os.curdir)
    try:
	os.chdir(project_dir)
    except OSError:
	return 0
    for buf in vim.buffers:
        # This requires that we are in the directory of the main tex file:
        if buf.name == os.path.abspath(file):
            os.chdir(cdir)
            return buf.number
    for buf in vim.buffers:
        if not buf.name is None and os.path.basename(buf.name) == file:
            os.chdir(cdir)
            return buf.number
    os.chdir(cdir)
    return 0

def scan_file(file, fname, pattern, bibpattern):
    """Scan file for a pattern, return all groups,

    file is a list of lines."""
    matches_d={}
    matches_l=[]
    nr = 0
    for line in file:
        nr+=1
        match_all=re.findall(pattern, line)
        if len(match_all) > 0:
            for match in match_all:
                for m in match:
                    if str(m) != "":
                        m=addext(m, "tex")
                        if not os.access(m, os.F_OK):
                            try:
                                m=kpsewhich_find(m, tex_path)[0]
                            except IndexError:
                                pass
                        elif relative_path == "0":
                            m=os.path.join(project_dir,m)
                        if fname == filename and nr < preambule_end:
                            matches_d[m]=[m, fname, nr, 'preambule']
                            matches_l.append(m)
                        else:
                            matches_d[m]=[m, fname, nr, 'input']
                            matches_l.append(m)
        match_all=re.findall(bibpattern, line)
        if len(match_all) > 0:
            for match in match_all:
                if str(match) != "":
                    for m in  match.split(','):
                        m=addext(m, "bib")
                        if not os.access(m, os.F_OK):
                            try:
                                m=kpsewhich_find(m, bib_path)[0]
                            except IndexError:
                                pass
                        matches_d[m]=[m, fname,  nr, 'bib']
                        matches_l.append(m)
    return [ matches_d, matches_l ]

def tree(file, level, pattern, bibpattern):
    """files - list of file names to scan,"""

    bufnr = bufnumber(file)
    if bufnr in vim.buffers:
        file_l = vim.buffers[bufnr]
    else:
        try:
            with open(file) as fo:
                file_l = fo.read().splitlines(False)
        except IOError:
            if file.endswith('.bib'):
                path=bib_path
            else:
                path=tex_path
            try:
                k_list = kpsewhich_find(file, path)
                if k_list:
                    file = k_list[0]
                else:
                    file = None
                if file:
                    with open(file) as fo:
                        file_l = fo.read().splitlines(False)
                else:
                    return [ {}, [], {}, {} ]
            except IOError:
                return [ {}, [], {}, {} ]
            except IndexError:
                return [ {}, [], {}, {} ]
    [found, found_l] = scan_file(file_l, file, pattern, bibpattern)
    t_list=[]
    t_level={}
    t_type={}
    t_tree={}
    for item in found_l:
        t_list.append(item)
        t_level[item]=level
        t_type[item]=(found[item][3]) # t_type values are ASCII
    i_list=[]
    for file in t_list:
        if found[file][3] == "input":
            i_list.append(file)
    for file in i_list:
        [ n_tree, n_list, n_type, n_level ] = tree(file, level+1, pattern, bibpattern)
        for f in n_list:
            t_list.append(f)
            t_type[f] = (n_type[f])
            t_level[f] = n_level[f]
        t_tree[file] = [ n_tree, found[file][2] ]
    return [ t_tree, t_list, t_type, t_level ]

try:
    with open(filename) as sock:
        mainfile = sock.read().splitlines(False)
except IOError:
    [ tree_of_files, list_of_files, type_dict, level_dict]= [ {}, [], {}, {} ]
else:
    if scan_preambule(mainfile, re.compile(r'\\usepackage{[^}]*\bsubfiles\b')):
        pat_str = r'^[^%]*(?:\\input\s+([\w_\-\.]*)|\\(?:input|include(?:only)?|subfile)\s*{([^}]*)})'
        pattern = re.compile(pat_str)
    else:
        pat_str = r'^[^%]*(?:\\input\s+([\w_\-\.]*)|\\(?:input|include(?:only)?)\s*{([^}]*)})'
        pattern = re.compile(pat_str)

    bibpattern=re.compile(r'^[^%]*\\(?:bibliography|addbibresource|addsectionbib(?:\s*\[.*\])?|addglobalbib(?:\s*\[.*\])?)\s*{([^}]*)}')

    bib_path=kpsewhich_path('bib')
    tex_path=kpsewhich_path('tex')
    preambule_end=preambule_end(mainfile)

    [ tree_of_files, list_of_files, type_dict, level_dict] = tree(filename, 1, pattern, bibpattern)

if hasattr(vim, 'bindeval'):
    def copy_dict(from_dict, to_dict):
        for key in from_dict.iterkeys():
            to_dict[str(key)] = from_dict[key]
    TreeOfFiles = vim.bindeval('b:TreeOfFiles')
    copy_dict(tree_of_files, TreeOfFiles)
    ListOfFiles = vim.bindeval('b:ListOfFiles')
    ListOfFiles.extend(list_of_files)
    TypeDict = vim.bindeval('b:TypeDict')
    copy_dict(type_dict, TypeDict)
    LevelDict = vim.bindeval('b:LevelDict')
    copy_dict(level_dict, LevelDict)
else:
    vim.command("let b:TreeOfFiles=%s"  % json.dumps(tree_of_files))
    vim.command("let b:ListOfFiles=%s"  % json.dumps(list_of_files))
    vim.command("let b:TypeDict=%s"     % json.dumps(type_dict))
    vim.command("let b:LevelDict=%s"    % json.dumps(level_dict))
END_PYTHON
let g:time_TreeOfFiles_py=reltimestr(reltime(time))

return [ b:TreeOfFiles, b:ListOfFiles, b:TypeDict, b:LevelDict ]
endfunction
"}}}

" This function finds all the input and bibliography files declared in the source files (recursive).
" {{{ atplib#search#FindInputFiles 
" Returns a dictionary:
" { <input_name> : [ 'bib', 'main file', 'full path' ] }
"			 with the same format as the output of FindInputFiles
" a:MainFile	- main file (b:atp_MainFile)
" a:1 = 0 [1]	- use cached values of tree of files.
function! atplib#search#FindInputFiles(MainFile,...)

"     let time=reltime()
    call atplib#write("nobackup")

    let cached_Tree	= a:0 >= 1 ? a:1 : 0

    let saved_llist	= getloclist(0)
    call setloclist(0, [])

    if cached_Tree && exists("b:TreeOfFiles")
	let [ TreeOfFiles, ListOfFiles, DictOfFiles, LevelDict ]= deepcopy([ b:TreeOfFiles, b:ListOfFiles, b:TypeDict, b:LevelDict ]) 
    else
	
	if &filetype == "plaintex"
	    let flat = 1
	else
	    let flat = 0
	endif

	let [ TreeOfFiles, ListOfFiles, DictOfFiles, LevelDict ]= TreeOfFiles(fnamemodify(a:MainFile, ":p"), g:atp_inputfile_pattern, flat)
	" Update the cached values:
	let [ b:TreeOfFiles, b:ListOfFiles, b:TypeDict, b:LevelDict ] = deepcopy([ TreeOfFiles, ListOfFiles, DictOfFiles, LevelDict ])
    endif

    let AllInputFiles	= keys(filter(copy(DictOfFiles), " v:val == 'input' || v:val == 'preambule' "))
    let AllBibFiles	= keys(filter(copy(DictOfFiles), " v:val == 'bib' "))

    let b:AllInputFiles	= deepcopy(AllInputFiles)
    let b:AllBibFiles	= deepcopy(AllBibFiles)
    let b:atp_BibFiles	= copy(b:AllBibFiles)


    " this variable will store unreadable bibfiles:    
    let NotReadableInputFiles=[]

    " this variable will store the final result:   
    let Files		= {}

    for File in ListOfFiles
	let File_Path	= atplib#FullPath(File)
	if filereadable(File) 
	call extend(Files, 
	    \ { fnamemodify(File_Path,":t:r") : [ DictOfFiles[File] , fnamemodify(a:MainFile, ":p"), File_Path ] })
	else
	" echo warning if a bibfile is not readable
" 	    echohl WarningMsg | echomsg "File " . File . " not found." | echohl None
	    if count(NotReadableInputFiles, File_Path) == 0 
		call add(NotReadableInputFiles, File_Path)
	    endif
	endif
    endfor
    let g:NotReadableInputFiles	= NotReadableInputFiles

    " return the list  of readable bibfiles
"     let g:time_FindInputFiles=reltimestr(reltime(time))
    return Files
endfunction
function! atplib#search#UpdateMainFile()
    if b:atp_MainFile =~ '^\s*\/'
	let cwd = getcwd()
	exe "lcd " . fnameescape(b:atp_ProjectDir)
	let b:atp_MainFile	= ( g:atp_RelativePath ? fnamemodify(b:atp_MainFile, ":.") : b:atp_MainFile )
	exe "lcd " . fnameescape(cwd)
    else
	let b:atp_MainFile	= ( g:atp_RelativePath ? b:atp_MainFile : atplib#FullPath(b:atp_MainFile) )
    endif
    return
endfunction
"}}}
" vim:fdm=marker:tw=85:ff=unix:noet:ts=8:sw=4:fdc=1
