" Author: 	Marcin Szamotulski	
" Note:		this file contain the main compiler function and related tools, to
" 		view the output, see error file.
" Note:		This file is a part of Automatic Tex Plugin for Vim.
" Language:	tex


if !filereadable("makefile") && !filereadable("Makefile")
    if !exists("b:TypeDict")
	let b:TypeDict=[]
    endif
    let s:makeprg=g:atp_Python." ".split(globpath(&rtp, "ftplugin/ATP_files/makelatex.py"), "\n")[0].
		\ " --texfile ".shellescape(atplib#FullPath(b:atp_MainFile)).
		\ " --bufnr ".bufnr("%").
		\ " --start 0".
		\ " --output-format ".substitute(get(g:atp_CompilersDict, matchstr(b:atp_TexCompiler, '^\s*\zs\S\+\ze'), ".pdf"), '\.', '', '').
		\ " --verbose ".t:atp_DebugMode.
		\ " --cmd ".b:atp_TexCompiler.
		\ " --bibcmd ".b:atp_BibCompiler.
		\ " --bibliographies ".shellescape(join(keys(filter(copy(b:TypeDict), "v:val == 'bib'")), ',')).
		\ " --outdir ".shellescape(b:atp_OutDir).
		\ " --keep ". shellescape(join(g:atp_keep, ',')).
		\ " --tex-options ".shellescape(b:atp_TexOptions.',-interaction='.( t:atp_DebugMode=="verbose" ? b:atp_VerboseLatexInteractionMode : 'nonstopmode' )).
		\ " --servername ".v:servername.
		\ " --viewer ".shellescape(b:atp_Viewer).
		\ " --xpdf-server ".shellescape(b:atp_XpdfServer).
		\ " --viewer-options ".shellescape((join((exists("g:atp_".matchstr(b:atp_Viewer, '^\s*\zs\S\+\ze')."Options") ? g:atp_{matchstr(b:atp_Viewer, '^\s*\zs\S\+\ze')}Options : []), ";") != "" ? join((exists("g:atp_".matchstr(b:atp_Viewer, '^\s*\zs\S\+\ze')."Options") ? g:atp_{matchstr(b:atp_Viewer, '^\s*\zs\S\+\ze')}Options : []), ";").";".join((exists("b:atp_".matchstr(b:atp_Viewer, '^\s*\zs\S\+\ze')."Options") ? getbufvar(bufnr("%"), "atp_".matchstr(b:atp_Viewer, '^\s*\zs\S\+\ze')."Options") : []), ";") : join((exists("b:atp_".matchstr(b:atp_Viewer, '^\s*\zs\S\+\ze')."Options") ? getbufvar(bufnr("%"), "atp_".matchstr(b:atp_Viewer, '^\s*\zs\S\+\ze')."Options") : []), ";"))).
		\ " --progname ".v:progname.
		\ " --tempdir ".shellescape(g:atp_TempDir).
		\ " --logdir ".shellescape(g:atp_TempDir).
		\ (g:atp_callback ? "" : " --no-callback ").
		\ (t:atp_DebugMode=='verbose' ? ' --env ""': " --env ".shellescape(b:atp_TexCompilerVariable)).
		\ ( index(g:atp_ReloadViewers, b:atp_Viewer)+1  ? ' --reload-viewer ' : '' ) . ( b:atp_ReloadOnError ? ' --reload-on-error ' : '' ).
		\ " &"

    let &l:makeprg = s:makeprg
endif
" Maps:
"{{{
noremap <silent> <Plug>ATP_ViewOutput_sync		:call atplib#compiler#ViewOutput("!", b:atp_MainFile, b:atp_XpdfServer)<CR>
noremap <silent> <Plug>ATP_ViewOutput_nosync		:call atplib#compiler#ViewOutput("",  b:atp_MainFile, b:atp_XpdfServer)<CR>
noremap <silent> <Plug>ATP_ViewLocalOutput_sync		:call atplib#compiler#ViewOutput("!", expand("%:p"), b:atp_LocalXpdfServer)<CR>
noremap <silent> <Plug>ATP_ViewLocalOutput_nosync	:call atplib#compiler#ViewOutput("",  expand("%:p"), b:atp_LocalXpdfServer)<CR>
nnoremap <buffer> <Plug>SyncTexKeyStroke	:call atplib#compiler#SyncTex("", 0, b:atp_MainFile, b:atp_XpdfServer)<CR>
nnoremap <buffer> <Plug>SyncTexMouse	:call atplib#compiler#SyncTex("", 1, b:atp_MainFile, b:atp_XpdfServer)<CR>
nnoremap <buffer> <Plug>SyncTexLKeyStroke	:call atplib#compiler#SyncTex("", 0, expand("%:t"), b:atp_LocalXpdfServer)<CR>
nnoremap <buffer> <Plug>SyncTexLMouse	:call atplib#compiler#SyncTex("", 1, expand("%:t"), b:atp_LocalXpdfServer)<CR>
noremap <silent> <Plug>ATP_TeXCurrent	:<C-U>call atplib#compiler#TeX(v:count1, "", t:atp_DebugMode)<CR>
noremap <silent> <Plug>ATP_TeXLocal	:<C-U>call atplib#compiler#LocalCompiler("n", v:count1, "silent")<CR>
noremap <silent> <Plug>ATP_TeXDefault	:<C-U>call atplib#compiler#TeX(v:count1, "", 'default')<CR>
noremap <silent> <Plug>ATP_TeXSilent	:<C-U>call atplib#compiler#TeX(v:count1, "", 'silent')<CR>
noremap <silent> <Plug>ATP_TeXDebug	:<C-U>call atplib#compiler#TeX(v:count1, "", 'Debug')<CR>
noremap <silent> <Plug>ATP_TeXdebug	:<C-U>call atplib#compiler#TeX(v:count1, "", 'debug')<CR>
noremap <silent> <Plug>ATP_TeXVerbose	:<C-U>call atplib#compiler#TeX(v:count1, "", 'verbose')<CR>
inoremap <silent> <Plug>iATP_TeXVerbose	<Esc>:<C-U>call atplib#compiler#TeX(v:count1, "", 'verbose')<CR>
nnoremap <silent> <Plug>SimpleBibtex	:call atplib#compiler#SimpleBibtex()<CR>
nnoremap <silent> <Plug>SimpleBibtex	:call atplib#compiler#Bibtex("")<CR>
nnoremap <silent> <Plug>BibtexDefault	:call atplib#compiler#Bibtex("!", "default")<CR>
nnoremap <silent> <Plug>BibtexSilent	:call atplib#compiler#Bibtex("!", "silent")<CR>
nnoremap <silent> <Plug>Bibtexdebug	:call atplib#compiler#Bibtex("!", "debug")<CR>
nnoremap <silent> <Plug>BibtexDebug	:call atplib#compiler#Bibtex("!", "Debug")<CR>
nnoremap <silent> <Plug>BibtexVerbose	:call atplib#compiler#Bibtex("!", "verbose")<CR>
"}}}
" Commands And Autocommands: 
" {{{
if !has("patch468")
    command! 	 		Cgetfile		:cgetfile<bar>call atplib#compiler#FilterQuickFix()
endif
command! -buffer		HighlightErrors		:call atplib#callback#HighlightErrors()
command! -buffer		ClearHighlightErrors	:call atplib#callback#ClearHighlightErrors()
command! -buffer -bang 		Kill			:call atplib#compiler#Kill(<q-bang>)
command! -buffer -bang  	View			:call atplib#compiler#ViewOutput(<q-bang>, b:atp_MainFile, b:atp_XpdfServer)
command! -buffer -bang  	Viewl			:call atplib#compiler#ViewOutput(<q-bang>, expand("%:p"), b:atp_LocalXpdfServer)
command! -buffer -bang 		SyncTex			:call atplib#compiler#SyncTex(<q-bang>, 0, b:atp_MainFile, b:atp_XpdfServer)
command! -buffer -bang 		SyncTexl		:call atplib#compiler#SyncTex(<q-bang>, 0, expand("%"), b:atp_LocalXpdfServer)
command! -buffer 		Pid			:call atplib#compiler#GetPID()
command! -buffer -nargs=? -bang -complete=custom,atplib#compiler#DebugComp MakeLatex	:call atplib#compiler#SetBiberSettings() | call atplib#compiler#MakeLatex(<q-bang>, <q-args>, 0)
nmap <buffer> <Plug>ATP_MakeLatex			:MakeLatex<CR>
command! -buffer -nargs=? -bang -count=1 -complete=custom,atplib#compiler#DebugComp Tex	:call atplib#compiler#TeX(<count>, <q-bang>, <f-args>)
command! -buffer -nargs=? -count=1 -complete=custom,atplib#compiler#DebugComp Texl 	:call atplib#compiler#LocalCompiler("n", <count>, <f-args>)
command! -buffer -count=1 Dtex				:call atplib#compiler#TeX(<count>, <q-bang>, 'debug') 
command! -buffer -bang -nargs=? -complete=custom,atplib#compiler#BibtexComp Bibtex		:call atplib#compiler#Bibtex(<q-bang>, <f-args>)
" command! -buffer BibtexOutput	:echo b:atp_BibtexOutput
" command! -buffer MakeidxOutput 	:echo b:atp_MakeidxOutput
command! -buffer -nargs=? -complete=custom,atplib#compiler#ListErrorsFlags_A SetErrorFormat 	:call atplib#compiler#SetErrorFormat(1,<f-args>)

augroup ATP_QuickFix_Commands
    au!
    au FileType qf command! -buffer -nargs=? -complete=custom,atplib#compiler#ListErrorsFlags_A SetErrorFormat :call atplib#compiler#SetErrorFormat(1,<q-args>)
    au FileType qf command! -buffer -nargs=? -complete=custom,atplib#compiler#ListErrorsFlags_A ErrorFormat :call atplib#compiler#SetErrorFormat(1,<q-args>)
    au FileType qf command! -buffer -nargs=? -complete=custom,atplib#compiler#ListErrorsFlags_A ShowErrors :call atplib#compiler#SetErrorFormat(0,<f-args>)
augroup END

command! -buffer -nargs=? -complete=custom,atplib#compiler#ListErrorsFlags_A 	ErrorFormat 	:call atplib#compiler#SetErrorFormat(1,<q-args>)
let load_ef=(exists("t:atp_QuickFixOpen") ? !t:atp_QuickFixOpen : 1)
command! -buffer -bang -nargs=? -complete=custom,atplib#compiler#ListErrorsFlags 	ShowErrors 	:call atplib#compiler#ShowErrors(<q-bang>,0,<f-args>)
command! -buffer -bang -nargs=? -complete=custom,atplib#compiler#ListErrorsFlags 	ShowErrorsL 	:call atplib#compiler#ShowErrors(<q-bang>,1,<f-args>)
" }}}
" vim:fdm=marker:tw=85:ff=unix:noet:ts=8:sw=4:fdc=1
