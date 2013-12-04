" Author: 	Marcin Szamotulski
" Description: 	This script has functions which have to be called before ATP_files/options.vim 
" Note:		This file is a part of Automatic Tex Plugin for Vim.
" Language:	tex

" This file contains set of functions which are needed to set to set the atp
" options and some common tools.

" Set the project name
"{{{ atplib#common#SetProjectName (function and autocommands)
" This function sets the main project name (b:atp_MainFile)
"
" It is used by EditInputFile which copies the value of this variable to every
" input file included in the main source file. 
"
" nmap gf (GotoFile function) is not using this function.
"
" the b:atp_MainFile variable is set earlier in the startup
" (by the augroup ATP_Syntax_TikzZone), calling SetProjectName to earlier cause
" problems (g:atp_raw_bibinputs undefined). 
"
" ToDo: CHECK IF THIS IS WORKS RECURSIVELY?
" ToDo: THIS FUNCTION SHUOLD NOT SET AUTOCOMMANDS FOR AuTeX function! 
" 	every tex file should be compiled (the compiler function calls the  
" 	right file to compile!
"
" {{{ atplib#common#SetProjectName ( function )
" store a list of all input files associated to some file
function! atplib#common#SetProjectName(...)
    let bang 	= ( a:0 >= 1 ? a:1 : "" )	" do we override b:atp_project	
    let did 	= ( a:0 >= 2 ? a:2 : 1	) 	" do we check if the project name was set
    						" but also overrides the current b:atp_MainFile when 0 	

    " if the project name was already set do not set it for the second time
    " (which sets then b:atp_MainFile to wrong value!)  
    if &filetype == "fd_atp"
	" this is needed for EditInputFile function to come back to the main
	" file.
	let b:atp_MainFile	= ( g:atp_RelativePath ? expand("%:t") : expand("%:p") )
	let s:did_project_name	= 1
    endif

    let g:did_project_name = (exists("s:did_project_name") ? s:did_project_name : -1)
    if exists("s:did_project_name") && s:did_project_name && did && exists("b:atp_MainFile")
	return " project name was already set"
    else
	let s:did_project_name	= 1
    endif

    let b:atp_MainFile	= exists("b:atp_MainFile") && did ? b:atp_MainFile : 
		\ ( g:atp_RelativePath ? expand("%:t") : expand("%:p") )

    if !exists("b:atp_ProjectDir")
	let b:atp_ProjectDir = ( exists("b:atp_ProjectScriptFile") ? fnamemodify(b:atp_ProjectScriptFile, ":h") : fnamemodify(resolve(expand("%:p")), ":h") )
    endif
endfunction
" }}}
"}}}

" This functions sets the value of b:atp_OutDir variable
" {{{ atplib#common#SetOutDir
" This options are set also when editing .cls files.
" It can overwrite the value of b:atp_OutDir
" if arg != 0 then set errorfile option accordingly to b:atp_OutDir
" if a:0 >0 0 then b:atp_atp_OutDir is set iff it doesn't exsits.
function! atplib#common#SetOutDir(arg, ...)

    if exists("b:atp_OutDir") && a:0 >= 1
	return "atp_OutDir EXISTS"
    endif

    " if the user want to be asked for b:atp_OutDir
    if g:askfortheoutdir == 1 
	let b:atp_OutDir=substitute(input("Where to put output? do not escape white spaces "), '\\\s', ' ', 'g')
    endif

    if ( get(getbufvar(bufname("%"),""),"outdir","optionnotset") == "optionnotset" 
		\ && g:askfortheoutdir != 1 
		\ || b:atp_OutDir == "" && g:askfortheoutdir == 1 )
		\ && !exists("$TEXMFOUTPUT")
	 let b:atp_OutDir=( exists("b:atp_ProjectScriptFile") ? fnamemodify(b:atp_ProjectScriptFile, ":h") : fnamemodify(resolve(expand("%:p")), ":h") )

    elseif exists("$TEXMFOUTPUT")
	 let b:atp_OutDir=substitute($TEXMFOUTPUT, '\\\s', ' ', 'g') 
    endif	

    " if arg != 0 then set errorfile option accordingly to b:atp_OutDir
    if bufname("") =~ ".tex$" && a:arg != 0
	 call atplib#common#SetErrorFile()
    endif

    if exists("g:outdir_dict")
	let g:outdir_dict	= extend(g:outdir_dict, {fnamemodify(bufname("%"),":p") : b:atp_OutDir })
    else
	let g:outdir_dict	= { fnamemodify(bufname("%"),":p") : b:atp_OutDir }
    endif
    return b:atp_OutDir
endfunction
" }}}

" This function sets vim 'errorfile' option.
"{{{ atplib#common#SetErrorFile
" let &l:errorfile=b:atp_OutDir . fnameescape(fnamemodify(expand("%"),":t:r")) .".(g:atp_ParseLog ? "_" : "")." "log"
if !exists("g:atp_ParseLog")
    let g:atp_ParseLog = has("python")
endif
function! atplib#common#SetErrorFile()

    " set b:atp_OutDir if it is not set
    if !exists("b:atp_OutDir")
	call atplib#common#SetOutDir(0)
    endif

    " set the b:atp_MainFile varibale if it is not set (the project name)
    if !exists("b:atp_MainFile")
	call atplib#common#SetProjectName()
    endif

    let main_file = atplib#FullPath(b:atp_MainFile)

    " vim doesn't like escaped spaces in file names ( cg, filereadable(),
    " writefile(), readfile() - all acepts a non-escaped white spaces)
    let &l:errorfile = atplib#joinpath(expand(b:atp_OutDir), fnamemodify(main_file,":t:r") . ".".(g:atp_ParseLog ? "_" : "")."log")
    return &l:errorfile
endfunction
"}}}
" vim:fdm=marker:tw=85:ff=unix:noet:ts=8:sw=4:fdc=1
