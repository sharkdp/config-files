" Title: 	Vim library for ATP filetype plugin.
" Author:	Marcin Szamotulski
" Email:	mszamot [AT] gmail [DOT] com
" Note:		This file is a part of Automatic Tex Plugin for Vim.
" URL:		https://launchpad.net/automatictexplugin
" Language:	tex


" Compilation Call Back Communication: 
" with some help of D. Munger
" (Communications with compiler script: both in compiler.vim and the python script.)
" atplib#callback#TexReturnCode {{{
function! atplib#callback#TexReturnCode(returncode)
	let b:atp_TexReturnCode=a:returncode
endfunction "}}}
" atplib#callback#BibtexReturnCode {{{
function! atplib#callback#BibtexReturnCode(returncode,...)
	let b:atp_BibtexReturnCode=a:returncode
	let b:atp_BibtexOutput= ( a:0 >= 1 ? a:1 : "" )
endfunction
" }}}
" atplib#callback#MakeidxReturnCode {{{
function! atplib#callback#MakeidxReturnCode(returncode,...)
	let b:atp_MakeidxReturnCode=a:returncode
	let b:atp_MakeidxOutput= ( a:0 >= 1 ? a:1 : "" )
endfunction
" }}}
" atplib#callback#Signs {{{
function! atplib#callback#Signs(bufnr)
    if has("signs")
	if a:bufnr != bufnr("%")
	    if bufwinnr(str2nr(a:bufnr)) != -1
		let cwinnr = bufwinnr(bufnr("%"))
		exe bufwinnr(str2nr(a:bufnr))."wincmd w"
	    else
		return
	    endif
	endif
	sign unplace *
	" This unplaces also signs not in the current buffer

	" This unplaces only signs in the current buffer, but uses 
	" redir => var | signs place buffer=a:bufnr | redir END
	" construct which shows signs on the srceen for a second.
	"
	" There should be a function which lists signs.
	"
" 	let more = &more
" 	let lz	= &lz
" 	set nomore
" 	setl lz
" 	redir => unplace_signs
" 	silent exe "sign place buffer=".a:bufnr
" 	redir END
" 	let &more = more
" 	let &lz = lz
" 	let signs = split(unplace_signs, "\n")
" 	call map(signs, 'matchstr(v:val, ''\<id=\>\zs\d\+\ze'')')
" 	for sign in signs
" 	    exe "sign unplace ".sign." buffer=".a:bufnr
" 	endfor
" 	unlet sign
" 	unlet signs
" 	unlet unplace_signs


	" There is no way of getting list of defined signs in the current buffer.
	" Thus there is no proper way of deleting them. I overwrite them using
	" numbers as names. The vim help tells that there might be at most 120
	" signs.
	
	" But this is not undefineing signs.
	let qflist=getqflist()
	let i=1
	for item in qflist
	    if item['type'] == 'E'
		let hl = 'ErrorMsg'
	    elseif item['type'] == 'W'
		let hl = 'WarningMsg'
	    else
		let hl = 'Normal'
	    endif
	    exe 'sign define '.i.' text='.item['type'].': texthl='.hl
	    if g:atp_ParseLog
		let file = bufname(item['bufnr'])
		if file != "" && bufloaded(file)
		    exe 'sign place '.i.' line='.item['lnum'].' name='.i.' file='.file
		endif
	    else
		exe 'sign place '.i.' line='.item['lnum'].' name='.i.' file='.expand('%:p')
	    endif
	    let i+=1
	endfor
	if exists("cwinnr")
	    exe cwinnr."wincmd w"
	    unlet cwinnr
	endif
    endif
endfunction "}}}
" atplib#callback#CallBack {{{
" a:mode 	= a:verbose 	of s:compiler ( one of 'default', 'silent',
" 				'debug', 'verbose')
" a:commnad	= a:commmand 	of s:compiler 
"		 		( a:commnad = 'AU' if run from background)
"
" Uses b:atp_TexReturnCode which is equal to the value returned by tex
" compiler.
function! atplib#callback#CallBack(bufnr,mode,...)

    " If the compiler was called by autocommand.
    let AU 	= ( a:0 >= 1 ? a:1 : 'COM' )
    " Was compiler called to make bibtex
    let BIBTEX 	= ( a:0 >= 2 ? a:2 : "False" )
    let BIBTEX 	= ( BIBTEX == "True" || BIBTEX == 1 ? 1 : 0 )
    let MAKEIDX	= ( a:0 >= 3 ? a:3 : "False" )
    let MAKEIDX = ( MAKEIDX == "TRUE" || MAKEIDX == 1 ? 1 : 0 )

    if g:atp_debugCallBack
	exe "redir! > ".g:atp_TempDir."/CallBack.log"
    endif

    for cmd in keys(g:CompilerMsg_Dict) 
    if b:atp_TexCompiler =~ '^\s*' . cmd . '\s*$'
	    let Compiler 	= g:CompilerMsg_Dict[cmd]
	    break
	else
	    let Compiler 	= b:atp_TexCompiler
	endif
    endfor
    let b:atp_running	= b:atp_running - 1

    " Read the log file
    cgetfile
    if v:version < 703 || v:version == 703 && !has("patch648")
	call atplib#compiler#FilterQuickFix()
    endif

    " signs
    if g:atp_signs
	call atplib#callback#Signs(a:bufnr)
    endif

    if g:atp_debugCallBack
	silent echo "file=".expand("%:p")
	silent echo "g:atp_HighlightErrors=".g:atp_HighlightErrors
    endif
    if g:atp_HighlightErrors
	call atplib#callback#HighlightErrors()
    endif
    " /this cgetfile is not working (?)/
    let error	= len(getqflist()) + (BIBTEX ? b:atp_BibtexReturnCode : 0)

    " If the log file is open re read it / it has 'autoread' opion set /
    checktime

    " redraw the status line /for the notification to appear as fast as
    " possible/ 
    if a:mode != 'verbose'
	redrawstatus
    endif

    " redraw has values -0,1 
    "  1 do  not redraw 
    "  0 redraw
    "  i.e. redraw at the end of function (this is done to not redraw twice in
    "  this function)
    let l:clist 	= 0
    let atp_DebugMode 	= t:atp_DebugMode

    if !exists('b:atp_TexReturnCode')
	let b:atp_TexReturnCode = ''
    endif
    if b:atp_TexReturnCode == 0 && ( a:mode == 'silent' || atp_DebugMode == 'silent' ) && g:atp_DebugMode_AU_change_cmdheight 
	let &l:cmdheight=g:atp_cmdheight
    endif

    if g:atp_debugCallBack
	let g:debugCB 		= 0
	let g:debugCB_mode 	= a:mode
	let g:debugCB_error 	= error
	silent echo "mode=".a:mode."\nerror=".error
    endif

    let msg_list = []
    let showed_message = 0

    if a:mode == "silent" && !error

	if t:atp_QuickFixOpen 

	    if g:atp_debugCallBack
		let g:debugCB .= 7
	    endif

	    if a:mode =~ "^auto" && t:atp_QuickFixOpen
		cclose
		call add(msg_list, ["[ATP:] no errors, closing quick fix window.", "Normal"])
	    endif
	endif

"     elseif a:mode == "silent" && AU == "COM"
" 	if b:atp_TexReturnCode
" 	    let showed_message		= 1
" 	    call add(msg_list, ["[ATP:] ".Compiler." returned with exit code ".b:atp_TexReturnCode.".", 'ErrorMsg', 'after'])
" 	endif
" 	if BIBTEX && b:atp_BibtexReturnCode
" 	    let showed_message		= 1
" 	    call add(msg_list, ["[ATP:] ".b:atp_BibCompiler." returned with exit code ".b:atp_BibtexReturnCode.".", 'ErrorMsg', 'after'])
" 	endif
" 	if MAKEIDX && b:atp_Makeindex
" 	    let showed_message		= 1
" 	    call add(msg_list, ["[ATP:] makeidx returned with exit code ".b:atp_MakeidxReturnCode.".", 'ErrorMsg', 'after'])
" 	endif
    endif

    if a:mode =~ 'auto' && !error

	if g:atp_debugCallBack
	    let g:debugCB 	.= 3
	endif

	call add(msg_list,["[ATP:] ".b:atp_TexCompiler." returned without errors [b:atp_ErrorFormat=".b:atp_ErrorFormat."]".(g:atp_DefaultDebugMode=='silent'&&atp_DebugMode!='silent'?"\ngoing out of debuging mode.": "."), "Normal", "after"]) 
	let showed_message 	= 1
	let t:atp_DebugMode = g:atp_DefaultDebugMode
	if a:mode =~ "auto" && t:atp_QuickFixOpen
	    cclose
	endif
	let &l:cmdheight 	= g:atp_cmdheight
    endif

    " debug mode with errors
    if a:mode ==? 'debug' && error
	if len(getqflist())

	    if g:atp_debugCallBack
		let g:debugCB .= 4
	    endif

	    let &l:cmdheight 	= g:atp_DebugModeCmdHeight
		let showed_message 	= 1
		if b:atp_ReloadOnError || b:atp_Viewer !~ '^\s*xpdf\>'
		    call add(msg_list, ["[ATP:] ".Compiler." returned with exit code " . b:atp_TexReturnCode . ".", (b:atp_TexReturnCode ? "ErrorMsg" : "Normal"), "before"])
		else
		    call add(msg_list, ["[ATP:] ".Compiler." returned with exit code " . b:atp_TexReturnCode . " output file not reloaded.", (b:atp_TexReturnCode ? "ErrorMsg" : "Normal"), "before"])
		endif
	    if !t:atp_QuickFixOpen
		let l:clist		= 1
	    endif
	endif

	if BIBTEX && b:atp_BibtexReturnCode
	    let l:clist		= 1
	    call add(msg_list, [ "[Bib:] ".b:atp_BibtexCompiler." returned with exit code ".b:atp_BibtexReturnCode .".", "ErrorMsg", "after"])
	    call add(msg_list, [ "BIBTEX_OUTPUT" , "Normal", "after"])
	endif

	if MAKEIDX && b:atp_MakeidxReturnCode
	    let l:clist		= 1
	    call add(msg_list, [ "[Bib:] makeidx returned with exit code ".b:atp_MakeidxReturnCode .".", "ErrorMsg", "after"])
	    call add(msg_list, [ "MAKEIDX_OUTPUT" , "Normal", "after"])
	endif

	" In debug mode, go to first error. 
	if a:mode ==# "Debug"

	    if g:atp_debugCallBack
		let g:debugCB .= 6
	    endif

	    cc
	endif
    endif

    if msg_list == []
	if g:atp_debugCallBack
	    redir END
	endif
	return
    endif

    " Count length of the message:
    let msg_len		= len(msg_list)
    if len(filter(copy(msg_list), "v:val[0] == 'BIBTEX_OUTPUT'")) 
	let msg_len 	+= (BIBTEX ? len(split(b:atp_BibtexOutput, "\\n")) - 1 : - 1 )
    endif
    if len(filter(copy(msg_list), "v:val[0] == 'MAKEIDX_OUTPUT'")) 
	let msg_len 	+= (MAKEIDX ? len(split(b:atp_MakeidxOutput, "\\n")) - 1 : - 1 )
    endif
    " We never show qflist: (that's why it is commented out)
"     let msg_len		+= ((len(getqflist()) <= 7 && !t:atp_QuickFixOpen) ? len(getqflist()) : 0 )

    " Show messages/clist
    
    if g:atp_debugCallBack
	let g:msg_list 	= msg_list
	let g:clist 	= l:clist
	silent echo "msg_list=\n**************\n".join(msg_list, "\n")."\n**************"
	silent echo "l:clist=".l:clist
    endif

    let cmdheight = &l:cmdheight
    if msg_len <= 2
	let add=0
    elseif msg_len <= 7
	let add=1
    else
	let add=2
    endif
    let &l:cmdheight	= max([cmdheight, msg_len+add])
    let g:msg_len=msg_len
    if l:clist && len(getqflist()) > 7 && !t:atp_QuickFixOpen
	let winnr = winnr()
	copen
	exe winnr."wincmd w"
    elseif (a:mode ==? "debug") && !t:atp_QuickFixOpen 
	let l:clist = 1
    endif
    redraw
    let before_msg = filter(copy(msg_list), "v:val[2] == 'before'")
    let after_msg = filter(copy(msg_list), "v:val[2] == 'after'")
    for msg in before_msg 
	exe "echohl " . msg[1]
	echo msg[0]
    endfor
    let l:redraw	= 1
    if l:clist && len(getqflist()) <= 7 && !t:atp_QuickFixOpen
	if g:atp_debugCallBack
	    let g:debugCB .= "clist"
	endif
	try
	    clist
	catch E42:
	endtry
	let l:redraw	= 0
    endif
    for msg in after_msg 
	exe "echohl " . msg[1]
	if msg[0] !=# "BIBTEX_OUTPUT"
	    echo msg[0]
	else
	    echo "       ".substitute(b:atp_BibtexOutput, "\n", "\n       ", "g")
" 	    let bib_output=split(b:atp_BibtexOutput, "\n")
" 	    let len=max([10,len(bib_output)])
" 	    below split +setl\ buftype=nofile\ noswapfile Bibtex\ Output
" 	    setl nospell
" 	    setl nonumber
" 	    setl norelativenumber
" 	    call append(0,bib_output)
" 	    resize 10
" 	    redraw!
" 	    normal gg
" 	    nmap q :bd<CR>
	    let g:debugCB .=" BIBTEX_output "
	endif
    endfor
    echohl None
    if len(msg_list)==0
	redraw
    endif
    let &l:cmdheight = cmdheight
    if g:atp_debugCallBack
	redir END
    endif
endfunction "}}}
"{{{ atplib#callback#LatexPID
"Store LatexPIDs in a variable
function! atplib#callback#LatexPID(pid)
    call add(b:atp_LatexPIDs, a:pid)
    let b:atp_LastLatexPID=a:pid
endfunction "}}}
"{{{ atplib#callback#BibtexPID
"Store BibtexPIDs in a variable
function! atplib#callback#BibtexPID(pid)
    call add(b:atp_BibtexPIDs, a:pid)
endfunction "}}}
"{{{ atplib#callback#MakeindexPID
"Store MakeindexPIDs in a variable
function! atplib#callback#MakeindexPID(pid)
    call add(b:atp_MakeindexPIDs, a:pid)
    let b:atp_LastMakeindexPID =a:pid
endfunction "}}}
"{{{ atplib#callback#PythonPID
"Store PythonPIDs in a variable
function! atplib#callback#PythonPID(pid)
    call add(b:atp_PythonPIDs, a:pid)
endfunction "}}}
"{{{ atplib#callback#MakeindexPID
"Store MakeindexPIDs in a variable
function! atplib#callback#PythonPIDs(pid)
    call add(b:atp_PythonPIDs, a:pid)
    let b:atp_LastPythonPID =a:pid
endfunction "}}}
"{{{ atplib#callback#PIDsRunning
function! atplib#callback#PIDsRunning(var)
" a:var is a string, and might be one of 'b:atp_LatexPIDs', 'b:atp_BibtexPIDs' or
" 'b:atp_MakeindexPIDs'. PIDs that are not running are removed from this list.
python << EOL
import sys
import re
import vim
import psutil

var  = vim.eval("a:var")
pids = vim.eval(var)
if len(pids) > 0:
    ps_list=psutil.get_pid_list()
    rmpids=[]
    for lp in pids:
	run=False
	for p in ps_list:
            if str(lp) == str(p):
		run=True
		break
	if not run:
            rmpids.append(lp)
    rmpids.sort()
    rmpids.reverse()
    for pid in rmpids:
	vim.eval("filter("+var+", 'v:val !~ \""+str(pid)+"\"')")
EOL
endfunction "}}}
"{{{ atplib#callback#ProgressBar
function! atplib#callback#ProgressBar(value,pid,bufnr)
    if !exists("g:atp_callback") || !g:atp_callback
	return
    endif
    if !exists("g:atp_ProgressBarValues")
	let g:atp_ProgressBarValues = { a:bufnr : {} }
    endif
    if !has_key(g:atp_ProgressBarValues, a:bufnr)
	call extend(g:atp_ProgressBarValues, { a:bufnr, {} })
    endif
    if a:value != 'end'
	let g:atp_ProgressBarValues[a:bufnr][a:pid] = a:value
    else
	call remove(g:atp_ProgressBarValues[a:bufnr], a:pid)
    endif
    if bufwinnr(a:bufnr) != -1
	redrawstatus
    endif
endfunction "}}}
"{{{ atplib#callback#redrawstatus
function! atplib#callback#redrawstatus()
    redrawstatus
endfunction "}}}
"{{{ atplib#callback#CursorMoveI
" function! atplib#callback#CursorMoveI()
"     if mode() != "i"
" 	return
"     endif
"     let cursor_pos=[ line("."), col(".")]
"     call feedkeys("\<left>", "n")
"     call cursor(cursor_pos)
" endfunction "}}}
" {{{ atplib#callback#HighlightErrors
function! atplib#callback#HighlightErrors()
    call atplib#callback#ClearHighlightErrors()
    let qf_list = getqflist()
    for error in qf_list
	if error.type ==? 'e'
	    let hlgroup = g:atp_Highlight_ErrorGroup
	else
	    let hlgroup = g:atp_Highlight_WarningGroup
	endif
	if hlgroup == ""
	    continue
	endif
	let m_id = matchadd(hlgroup, '\%'.error.lnum.'l.*', 20)
	call add(s:matchid, m_id)
	let error_msg=split(error.text, "\n")
    endfor
endfunction "}}}
" {{{ atplib#callback#ClearHighlightErrors
function! atplib#callback#ClearHighlightErrors()
    if !exists("s:matchid")
	let s:matchid=[]
	return
    endif
    for m_id in s:matchid
	try
	    silent call matchdelete(m_id)
	catch /E803:/
	endtry
    endfor
    let s:matchid=[]
endfunction "}}}
"{{{ atplib#callback#Echo
function! atplib#callback#Echo(msg, cmd, hlgroup, ...)
    if a:0 >= 1 && a:1
	redraw
    endif
    exe "echohl ".a:hlgroup
    exe a:cmd." '".a:msg."'"
    echohl None
endfunction "}}}
" vim:fdm=marker:ff=unix:noet:ts=8:sw=4:fdc=1
