" Author:      Marcin Szamotulski
" Description: This script has functions which have to be called before ATP_files/options.vim 
" Note:	       This file is a part of Automatic Tex Plugin for Vim.
" Language:    tex
" Last Change: Wed Nov 28, 2012 at 13:46:30  +0000

" This file contains set of functions which are needed to set to set the atp
" options and some common tools.

let s:sourced 	= exists("s:sourced") ? 1 : 0

" {{{ Variables
if !exists("g:askfortheoutdir") || g:atp_reload_variables
    let g:askfortheoutdir = 0
endif
if !exists("g:atp_raw_texinputs")
    let g:atp_raw_texinputs = substitute(substitute(substitute(system("kpsewhich -show-path tex"),'!!','','g'),'\/\/\+','\/','g'), ':\|\n', ',', 'g')
"     lockvar g:atp_raw_texinputs
endif

" atp tex and bib inputs directories (kpsewhich)
if !exists("g:atp_texinputs") || g:atp_reload_variables
    let path_list	= split(g:atp_raw_texinputs, ',')
    let idx		= index(path_list, '.')
    if idx != -1
	let dot = remove(path_list, index(path_list,'.')) . ","
    else
	let dot = ""
    endif
    call map(path_list, 'v:val . "**"')

    let g:atp_texinputs	= dot . join(path_list, ',')
endif
" a list where tex looks for bib files
" It must be defined before atplib#common#SetProjectName function.
if !exists("g:atp_raw_bibinputs") || g:atp_reload_variables

    let g:atp_raw_bibinputs=substitute(substitute(substitute(
		\ system("kpsewhich -show-path bib"),
		\ '\/\/\+',	'\/',	'g'),	
		\ '!\|\n',	'',	'g'),
		\ ':',		',' ,	'g')
endif
if !exists("g:atp_bibinputs") || g:atp_reload_variables
    let path_list	= split(g:atp_raw_bibinputs, ',')
    let idx		= index(path_list, '.')
    if idx != -1
	let dot = remove(path_list, index(path_list,'.')) . ","
    else
	let dot = ""
    endif
    call map(path_list, 'v:val . "**"')

    let g:atp_bibinputs	= dot . join(path_list, ',')
endif
" }}}

augroup ATP_SetErrorFile
    au!
    au BufEnter 	*.tex 		call atplib#common#SetErrorFile()
augroup END

" TreeOfFiles
function! TreeOfFiles(main_file,...) "{{{1
    let pattern		= a:0 >= 1 	? a:1 : g:atp_inputfile_pattern
    let flat		= a:0 >= 2	? a:2 : 0	
    let run_nr		= a:0 >= 3	? a:3 : 1 
    let time=reltime()
    if has("python") && &filetype != "plaintex" && ( !exists("g:atp_no_python") || g:atp_no_python == 0 )
	" It was not tested on plaintex files.
	let [tree, list, types, levels] = atplib#search#TreeOfFiles_py(a:main_file)
    else
	let [tree, list, types, levels] = atplib#search#TreeOfFiles_vim(a:main_file, pattern, flat, run_nr)
    endif
    " Notes: vim script avrage is 0.38s, python avrage is 0.28
    return [ tree, list, types, levels ]
endfunction "}}}1

" SetOutDir 
fun! <sid>SetOutDir(...) "{{{1
    if a:0 && !empty(a:1)
	let b:atp_OutDir = fnamemodify(a:1, ':p')
	call atplib#common#SetErrorFile()
    else
	echo b:atp_OutDir
    endif
endfun "}}}1

" {{{ Syntax and Hilighting
" ToDo:
" syntax 	match 	atp_statustitle 	/.*/ 
" syntax 	match 	atp_statussection 	/.*/ 
" syntax 	match 	atp_statusoutdir 	/.*/ 
" hi 	link 	atp_statustitle 	Number
" hi 	link 	atp_statussection 	Title
" hi 	link 	atp_statusoutdir 	String
" }}}

"}}}

" The main status function, it is called via autocommand defined in 'options.vim'.
let s:errormsg = 0
function! ATPStatus(command,...) "{{{
    if expand("%") == "[Command Line]" || &l:filetype == "qf" || expand("%:e") != "tex"
	" If one uses q/ or q? this status function should not be used.
	return
    endif

    if a:command >= 1
	" This is run be the command :Status (:ATPStatus)
	if a:0 >= 1 && a:1
	    let g:status_OutDir = atplib#StatusOutDir()
	    let g:atp_statusOutDir = 1
	else
	    let g:status_OutDir = ""
	    let g:atp_statusOutDir = 0
	endif
	let b:atp_statusCurSection = ( a:0 >= 2 ? a:2 : 0 )
    else
	" This is run by the autocommand group ATP_Status
	if g:atp_statusOutDir
	    let g:status_OutDir = atplib#StatusOutDir()
	else
	    let g:status_OutDir = ""
	endif
	let b:atp_statusCurSection = ( a:0 >= 1 ? a:1 : 0 )
    endif

    let status_CurrentSection = ( b:atp_statusCurSection ? '%{atplib#CurrentSectionn()}' : '' )
    if g:atp_statusNotifHi > 9 || g:atp_statusNotifHi < 0
	let g:atp_statusNotifHi = 9
	if !s:errormsg
	    echoerr "Wrong value of g:atp_statusNotifHi, should be 0,1,...,9. Setting it to 9."
	    let s:errormsg = 1
	endif
    endif
    let status_NotifHi	=
		\ ( g:atp_statusNotif && g:atp_statusNotifHi 	? '%#User'.g:atp_statusNotifHi . '#' : '' )
    let status_NotifHiPost =
		\ ( g:atp_statusNotif && g:atp_statusNotifHi 	? '%*' 	: '' )
    let status_Notif	=
		\ ( g:atp_statusNotif 			? '%{atplib#ProgressBar()}' 	: '' )
    let status_KeyMap	=
		\ ( has("keymap") && g:atp_babel && exists("b:keymap_name") 	
								\ ? b:keymap_name 	: '' )
    let g:atp_StatusLine= '%<%f '.status_KeyMap.'%(%h%m%r%) '.status_NotifHi.status_Notif.status_NotifHiPost.'%= '.status_CurrentSection.' %{g:status_OutDir}'
    if &ruler
	let g:atp_StatusLine.=' %-14.16(%l,%c%V%)%P'
    endif
    setl statusline=%!g:atp_StatusLine
endfunction
try
    command -buffer -bang Status	:call ATPStatus(1,(<q-bang> == "")) 
catch /E174:/
    command! -buffer -bang ATPStatus	:call ATPStatus(1,(<q-bang> == "!")) 
endtry
" }}}
"}}}
" The Script:
" (includes commands, and maps - all the things 
" 		that must be sources for each file
" 		+ sets g:atp_inputfile_pattern variable)
call atplib#common#SetProjectName() "{{{1

" The pattern g:atp_inputfile_pattern should match till the begining of the file name
" and shouldn't use \zs:\ze. 
if !exists("g:atp_inputfile_pattern") || g:atp_reload_variables
    if &filetype == 'plaintex'
	let g:atp_inputfile_pattern = '^[^%]*\\input\>\s*'
    else
	if atplib#search#SearchPackage("subfiles")
	    let g:atp_inputfile_pattern = '^[^%]*\\\(input\s*{\=\|include\s*{\|subfile\s*{'
	else
	    let g:atp_inputfile_pattern = '^[^%]*\\\(input\s*{\=\|include\s*{'
	endif
	if atplib#search#SearchPackage("biblatex")
	    let g:atp_inputfile_pattern .= '\)'
	else
	    let g:atp_inputfile_pattern .= '\|bibliography\s*{\)'
	endif
    endif
endif


call atplib#common#SetOutDir(0, 1)
if expand("%:e") == "tex"
    " cls and sty files also have filetype 'tex', this prevents from setting the error
    " file for them.
    call atplib#common#SetErrorFile()
endif "}}}1

fun! <SID>InputFiles(bang)
    call atplib#search#UpdateMainFile() 
    call atplib#search#FindInputFiles(atplib#FullPath(b:atp_MainFile)) 
    if a:bang == ""
	WriteProjectScript local 1
    endif
    echo join([b:atp_MainFile]+b:ListOfFiles, "\n")
endfun

" Commands:
"{{{1
command! -buffer -bang SetProjectName	:call atplib#common#SetProjectName(<q-bang>, 0)
command! -buffer SetErrorFile		:echo atplib#common#SetErrorFile()
command! -buffer -nargs=? -complete=dir SetOutDir :call <sid>SetOutDir(<f-args>)
command! -buffer -bang InputFiles 	:call <SID>InputFiles(<q-bang>)

" This should set the variables and run atplib#common#SetNotificationColor function
command! -buffer SetNotificationColor :call atplib#common#SetNotificationColor()
"}}}
" vim:fdm=marker:tw=85:ff=unix:noet:ts=8:sw=4:fdc=1
