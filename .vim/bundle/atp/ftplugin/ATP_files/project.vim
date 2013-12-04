" Author: 	Marcin Szamotulski
" Description: 	A vim script which stores values of variables in a project script.
" 		It is read, and written via autocommands.
" Note:		This file is a part of Automatic Tex Plugin for Vim.
" Language:	tex
" Last Change:Tue Sep 06, 2011 at 03:17  +0100

let s:sourced 	= exists("s:sourced") ? 1 : 0

" VARIABLES:
" Variables {{{

" If the user set g:atp_RelativePath
" if exists("g:atp_RelativePath") && g:atp_RelativePath
"     setl noautochdir
" endif

let s:file	= expand('<sfile>:p')

" This gives some debug info: which project scripts are loaded, loading time,
" which project scripts are written.
" Debug File: /tmp/ATP_ProjectScriptDebug.vim  / only for s:WriteProjectScript() /
if !exists("g:atp_debugProject")
    let g:atp_debugProject 	= 0
endif
if !exists("g:atp_debugLPS")
    " debug <SID>LoadProjectScript (project.vim)
    let g:atp_debugLPS		= 0
endif
if !exists("g:atp_RelativePath")
    let g:atp_RelativePath 	= 1
endif
" Also can be set in vimrc file or atprc file! (tested)
" The default value (0) is set in options.vim
if !exists("g:atp_TempDir")
    call atplib#TempDir()
endif

" Windows version:
let s:windows	= has("win16") || has("win32") || has("win64") || has("win95")

" This variable is set if the projectr script was loaded by s:LoadScript()
" function.
" s:project_Load = { type : 0/1 }

if !exists("s:project_Load")
    " Load once in s:LoadScript() function
    let s:project_Load	= {}
endif
if !exists("g:atp_CommonScriptDirectory")
    let g:atp_CommonScriptDirectory	= expand('<sfile>:p:h')
endif
if !isdirectory(g:atp_CommonScriptDirectory)
    " Make common script dir if it doesn't exist (and all intermediate directories).
    call mkdir(g:atp_CommonScriptDirectory, "p")
endif

" Mimic names of vim view files
let s:common_project_script	= s:windows ? g:atp_CommonScriptDirectory  . '\common_var.vim' : g:atp_CommonScriptDirectory . '/common_var.vim' 

" These local variables will be saved:
" let g:atp_ProjectGlobalVariable = [ 
" 	    \ 'b:atp_MainFile',
" 	    \ 'b:atp_ProjectScript',
" 	    \ 'b:atp_LocalCommands', 		'b:atp_LocalEnvironments', 
" 	    \ 'b:atp_LocalColors',
" 	    \ 'b:TreeOfFiles', 			'b:ListOfFiles', 
" 	    \ 'b:TypeDict', 			'b:LevelDict', 
" 	    \ 'b:atp_StarEnvDefault', 		'b:atp_StarMathEnvDefault',
" 	    \ ]
" Note: b:atp_ProjectDir is not here by default by the following reason: it is
" specific to the host, without it sharing the project file is possible.
" b:atp_PackageList is another variable that could be put into project script.

" This are common variable to all tex files.
let g:atp_ProjectGlobalVariables = [ 'g:atp_LatexPackages', 'g:atp_LatexClasses', 'g:atp_Library' ]
" }}}

" AUTOCOMMANDS:
augroup ATP_ProjectFile
    au!
    au BufEnter *.tex.project.vim if has("persistent_undo") | setlocal noundofile | endif
augroup END

" FUNCTIONS: (soure once)
if !s:sourced || g:atp_reload_functions "{{{
" LOAD PROJECT SCRIPT:
"{{{ s:LoadScript(), FindProjectScripts(), GetProjectScript(), s:LoadProjectScript()
" s:LoadScript({bang}, {project_script}, {type}, {load_variables}, [silent], [ch_load])
"
" a:bang == "!" ignore texmf tree and ignore b:atp_ProjectScript, g:atp_ProjectScript
" variables
" a:project_script	file to source 
" a:type = 'local'/'global'
" a:load_variabels	load variables after loading project script	
" 			can be used on startup to load variables which depend
" 			on things set in project script.
" a:1 = 'silent'/'' 	echo messages
" a:2 = ch_load		check if project script was already loaded
" a:3 = ignore		ignore b:atp_ProjectScript and g:atp_ProjectScript variables
" 				used by commands
function! <SID>LoadScript(bang, project_script, type, load_variables, ...) "{{{

    if g:atp_debugProject
	exe "redir! > ".g:atp_TempDir."/LoadScript.log"
	let hist_time	= reltime()
	echomsg "ATP_ProjectScript: LoadScript " . a:type . " file " . string(a:project_script)
    endif

    let silent	= a:0 >= 1 ? a:1 : "0"
    let silent 	= silent || silent == "silent" ? "silent" : ""
    let ch_load = a:0 >= 2 ? a:2 : 0 
    let ignore	= a:0 >= 3 ? a:3 : 0

    " Is project script on/off
    " The local variable overrides the global ones!

    " Note:
    " When starting the vim b:atp_ProjectScript might not be yet defined (will be
    " defined later, and g:atp_ProjectScript might already be defined, so not always
    " global variables override local ones).

    " Global variable overrides local one:
    let cond = ( exists("g:atp_ProjectScript") && !g:atp_ProjectScript || exists("b:atp_ProjectScript") && ( !b:atp_ProjectScript && (!exists("g:atp_ProjectScript") || exists("g:atp_ProjectScript") && !g:atp_ProjectScript )) )
    let g:cond_LPS = cond
    if !ignore && cond
	exe silent . ' echomsg "[ATP:] LoadScirpt: not loading project script."'

	if g:atp_debugProject
	    echomsg "b:atp_ProjectScript=" . ( exists("b:atp_ProjectScript") ? b:atp_ProjectScript : -1 ) . " g:atp_ProjectScript=" . ( exists("g:atp_ProjectScript") ? g:atp_ProjectScript : -1 ) . "\n"
	    echomsg "ATP_ProjectScript : END " !ignore
	    redir END
	endif
	return
    endif

    " Load once feature (if ch_load)	- this is used on starup
    if ch_load && get(get(s:project_Load, expand("%:p"), []), a:type, 0) >= 1
	silent echomsg "[ATP:]  " . a:type . "project script already loaded for buffer " . expand("%:p") . "."
	if g:atp_debugProject
	    redir END
	endif
	return
    endif

    let cond_A	= get(s:project_Load, expand("%:p"), {}) != {}
    let cond_B	= get(get(s:project_Load, expand("%:p"), []), a:type, 0)
    if empty(expand("%:p"))
	if g:atp_debugProject
	    echohl ErrorMsg
	    echomsg "[ATP LoadProjectScript:] Error : File name is empty. Not loading project script."
	    echohl None
	    redir END
	endif
	return
    endif
    if cond_B
	let s:project_Load[expand("%:p")][a:type][0] += 1 
    elseif cond_A
	call extend(s:project_Load[expand("%:p")], { a:type : 1 })
    else
	let s:project_Load= { expand("%:p") : { a:type : 1 } }
    endif

    if a:bang == "" && expand("%:p") =~ 'texmf' 
	if g:atp_debugProject
	    redir END
	endif
	return
    endif

    let b:atp_histloaded=1
    if a:type == "local"
	try
	    let ps_lines = readfile(a:project_script)
	catch /E484:/
	    let ps_lines = []
	endtry
	" let b:atp_vim_settings = []
	for line in ps_lines
	    if line =~ '^[^"]*\Clet\s\+b:atp_ProjectScript\>\s*='
		execute line
	    endif
	    " if line =~ '^\s*\(set\?\|setl\%[ocal]\)\s'
		" call add(b:atp_vim_settings, line)
	    " endif
	endfor
	if exists("b:atp_ProjectScript") && !b:atp_ProjectScript
	    if g:atp_debugProject
		silent echomsg "[ATP:] ATP_ProjectScript: b:atp_ProjectScript == 0 in the project script."
		redir END
	    endif
	    return
	endif
    endif

    " Load first b:atp_ProjectScript variable
    try
	if filereadable(a:project_script)
	    execute "silent! source " . fnameescape(a:project_script)
	endif

	if g:atp_debugProject
	    echomsg "[ATP:] ATP_ProjectScript: sourcing " . a:project_script
	endif
    catch /E484:/
    endtry

    if g:atp_debugProject
	echomsg "[ATP:] ATP_ProjectScript: sourcing time: " . reltimestr(reltime(hist_time))
	redir! END
    endif

    if a:load_variables
	if !exists("b:atp_project")
	    if exists("b:LevelDict") && max(values(filter(deepcopy(b:LevelDict), "get(b:TypeDict, v:key, '')=='input'"))) >= 1
		let b:atp_project	= 1
	    else
		let b:atp_project 	= 0
	    endif
	endif
    endif

"     if a:type == 'local'
" 	call <SID>TEST()
"     endif
endfunction "}}}
" This functoin finds recursilevy (upward) all project scripts. 
" {{{ FindProjectScripts()
function! FindProjectScripts()
    let dir 	= fnamemodify(resolve(expand("%:p")), ":p:h")
    let cwd 	= getcwd()
    try
	exe "lcd " . fnameescape(dir)
    catch /E344:/
	return [] 
    endtry
    while glob('*.project.vim', 1) == '' 
	let dir_l 	= dir
	let dir 	= fnamemodify(dir, ":h")
	if dir == $HOME || dir == dir_l
	    break
	endif
	exe "lcd " . fnameescape(dir)
    endwhile
    let project_files = map(split(glob('*project.vim', 1), "\n"), "fnamemodify(v:val, \":p\")")
    exe "lcd " . fnameescape(cwd)
    return project_files
endfunction "}}}
" This function looks to which project current buffer belongs.
" {{{ GetProjectScript(project_files)
" a:project_files = FindProjectScripts()
function! GetProjectScript(project_files)
    for pfile in a:project_files
	if g:atp_debugLPS
	    echomsg "[ATP:] checking " . pfile 
	endif
	let file_name 	= s:windows ? escape(expand("%:p"), '\') : escape(expand("%:p"), '/') 
	let sfile_name 	= expand("%:t")
	try
	    let pf_lines = readfile(pfile)
	catch /E484:/
	    let pf_lines = []
	endtry
	if !g:atp_RelativePath
	    for line in pf_lines
		if line =~ '^\s*let\s\+\%(b:atp_MainFile\s\+=\s*\%(''\|"\)\%(' . file_name . '\|' . sfile_name . '\)\>\%(''\|"\)\|b:ListOfFiles\s\+=.*\%(''\|"\)' . file_name . '\>\)'
		    return pfile
		endif
	    endfor
	else
	    for line in pf_lines
		if line =~ '^\s*let\s\+\%(b:atp_MainFile\s\+=\s*\%(''\|"\)[^''"]*\<\%(' . sfile_name . '\)\>\%(''\|"\)\|b:ListOfFiles\s\+=.*\%(''\|"\)[^''"]*\<' . sfile_name . '\>\)'
		    return pfile
		endif
	    endfor
	endif
	if g:atp_debugProject
	    silent echomsg "[ATP:] script file " . pfile . " doesn't match."
	endif
    endfor
    return "no project script found"
endfunction "}}}
" This function uses all three above functions: FindProjectScripts(),
" GetProjectScript() and <SID>LoadScript()
" {{{ <SID>LoadProjectScript
" Note: bang has a meaning only for loading the common project script.
function! <SID>LoadProjectScript(bang,...)

    if ( exists("g:atp_ProjectScript") && !g:atp_ProjectScript || exists("b:atp_ProjectScript") && ( !b:atp_ProjectScript && (!exists("g:atp_ProjectScript") || exists("g:atp_ProjectScript") && !g:atp_ProjectScript )) )
	exe "redir! > ".g:atp_TempDir."/LoadProjectScript.log"
	silent echo "+++ SKIPPING : LOAD PROJECT SCRIPT +++"
	redir END
	return
    endif

    let local = (a:0 >= 1 ? a:1 : 'local' )
    if g:atp_debugLPS
	let time = reltime()
    endif

    if local == 'global' || local == 'common' 
	call s:LoadScript(a:bang,s:common_project_script, 'global', 0, '', 1)
	if g:atp_debugLPS
	    let g:LPS_time = reltimestr(reltime(time))
	    echomsg "Load Project Script time (common): " . g:LPS_time
	endif
	return
    endif

    if !exists("b:atp_ProjectScriptFile")
	" Look for the project file
	let project_files = FindProjectScripts()

	" Return if nothing was found
	if len(project_files) == 0
	    let b:atp_ProjectScriptFile = resolve(expand("%:p")) . ".project.vim"
	    let b:atp_ProjectDir	= fnamemodify(b:atp_ProjectScriptFile, ":h")
	    return
	endif

	" Move project_file corresponding to the current buffer to the first
	" place if it exists.
	" This saves time :) when there are many project files
	" (especially when the projects are big)
	let index 	= index(project_files, expand("%:p") . ".project.vim")
	if index != -1
	    call remove(project_files, index)
	    call extend(project_files, [ expand("%:p") . ".project.vim" ], 0) 
	endif

	let project_script = GetProjectScript(project_files)
	if project_script != "no project script found"
	    if g:atp_debugLPS
		echomsg "Loading  " . project_script 
	    endif
	    call <SID>LoadScript("", project_script, "local", 0, "silent", 1, 0)
	    let b:atp_ProjectScriptFile = project_script
	    let b:atp_ProjectDir	= fnamemodify(b:atp_ProjectScriptFile, ":h")
	else
	    " If there was no project script we set the variable and it will
	    " be written when quiting vim by <SID>WriteProjectScript().
	    let b:atp_ProjectScriptFile = resolve(expand("%:p")) . ".project.vim"
	    let b:atp_ProjectDir	= fnamemodify(b:atp_ProjectScriptFile, ":h")
	    return
	endif
    else
	try
	execute "silent! source " . fnameescape(b:atp_ProjectScriptFile)
	let b:atp_ProjectDir	= fnamemodify(b:atp_ProjectScriptFile, ":h")
	catch /E484/
	    " this is used by the s:Babel() function.
	    " if b:atp_ProjectDir is unset it returns.
	    unlet b:atp_ProjectDir
	endtry
    endif

    if g:atp_debugLPS
	let g:LPS_time = reltimestr(reltime(time))
	echomsg "LPS time: " . g:LPS_time
    endif
endfunction
function! s:LocalCommonComp(ArgLead, CmdLine, CursorPos)
    return filter([ 'local', 'common'], 'v:val =~ "^" . a:ArgLead')
endfunction
" }}}
"}}}
" WRITE PROJECT SCRIPT:
"{{{ s:WriteProjectScript(), :WriteProjectScript, autocommands
" This function writes the project file but only if there there are changes.
" This is so, because writing very long lines is much slower than reading (it
" reads the file and compare the variables with the existing ones).
try
function! <SID>WriteProjectScript(bang, project_script, cached_variables, type, ...)

    "Do not echo messages
    let silent = ( a:0 > 0 ? a:1 : 0 )

    if g:atp_debugProject
	let g:project_script = a:project_script
	let g:type = a:type
    endif

    if !exists("b:ListOfFiles")
	let atp_MainFile	= atplib#FullPath(b:atp_MainFile)
	call TreeOfFiles(atp_MainFile)
    endif

    if g:atp_debugProject
	exe "redir! > ".g:atp_TempDir."/WriteProjectScript.log"
	echomsg "ATP_ProjectScript: WriteProjectScript " . a:type
	let time = reltime()
    endif

    " If none of the variables exists -> return
    let exists=max(map(deepcopy(a:cached_variables), "exists(v:val)")) 
    if !exists
	if g:atp_debugProject
	    echomsg "no variable exists"
	endif
	if g:atp_debugProject >= 2
	    echomsg "Write Project Script time " . reltimestr(reltime(time))
	endif
	return
    endif

    if a:bang == "" && expand("%:p") =~ 'texmf'
	if g:atp_debugProject
	    echomsg "texmf return"
	endif
	if g:atp_debugProject
	    let g:return = 1
	endif
	if g:atp_debugProject >= 2
	    echomsg "Write Project Script time " . reltimestr(reltime(time))
	endif
	return
    endif

    " a:bang == '!' then force to write project script even if it is turned off
    " localy or globaly.
    " The global variable overrides the local one!
    let cond = exists("g:atp_ProjectScript") && !g:atp_ProjectScript || exists("b:atp_ProjectScript") && ( !b:atp_ProjectScript && (!exists("g:atp_ProjectScript") || exists("g:atp_ProjectScript") && !g:atp_ProjectScript )) || !exists("b:atp_ProjectScript") && !exists("g:atp_ProjectScript")
    if  a:bang == "" && cond
	if !silent
	    echomsg "[ATP:] WriteProjectScript: ProjectScript is turned off."
	endif
	if g:atp_debugProject
	    redir END
	endif
	if g:atp_debugProject
	    let g:return = 2
	endif
	if g:atp_debugProject >= 2
	    echomsg "Write Project Script time " . reltimestr(reltime(time))
	endif
	return
    endif

    let winsaveview	= winsaveview()

    " Check if global variables where changed.
    " (1) copy global variable to l:variables
    " 	  and remove defined global variables.
    " (2) source the project script and compare the results.
    " (3) resore variables and write the project script.
    if a:type == "global"
	let existing_variables 	= {}
	for var in a:cached_variables 
	    if g:atp_debugProject >= 2
		echomsg var . " EXISTS " . exists(var)
	    endif

	    " step (1) copy variables
	    let lvar = "l:" . substitute(var, '^[bg]:', '', '')
	    if exists(var)
		call extend(existing_variables, { var : string({var}) })
		exe "let " . lvar . "=" .  string({var})
		exe "unlet " . var
	    endif
	endfor
	" step (2a) source project script
	if filereadable(a:project_script)
	    execute "source " . fnameescape(a:project_script)
	endif
	let cond = 0
	for var in a:cached_variables
	    let lvar = "l:" . substitute(var, '^[bg]:', '', '')
	    " step (2b) check if variables have changed
	    if exists(var) && exists(lvar)
		let cond_A = ({lvar} != {var})
		if g:atp_debugProject
		    echomsg var . " and " . lvar . " exist. cond_A=" . cond_A 
		endif
		let cond += cond_A
		if cond_A
		    let {var} = {lvar}
		endif
	    elseif !exists(var) && exists(lvar)
		if g:atp_debugProject
		    echomsg var . " nexists but " . lvar . " exist."
		endif
		let {var} = {lvar}
		let cond += 1
	    elseif exists(var) && !exists(lvar)
		if g:atp_debugProject
		    echomsg var . " exists and " . lvar . " nexist."
		endif
		unlet {var}
		let cond += 1
	    else
		if g:atp_debugProject
		    echomsg var . " and " . lvar . " nexist."
		endif
	    endif
	endfor

	if g:atp_debugProject
	    let g:cond_global = cond
	    echomsg "cond " . cond
	endif

	" step (3a) copy variables from local ones.
	for var in g:atp_ProjectGlobalVariables
	    let lvar = "l:" . substitute(var, '^[bg]:', '', '')
	    if g:atp_debugProject
		echomsg "(3a) " . var . " exists " . lvar . " " . ( exists(lvar) ? 'exists' : 'nexists' )
	    endif
	    if exists(lvar)
		if g:atp_debugProject
		    echomsg "(3a) Restoring " . var . " from " . lvar
		endif
		try
		    let {var} = {lvar}
		catch /E741:/ 
		    exe "unlockvar " . var
		    let {var} = {lvar}
		    exe "lockvar " . var
		endtry
	    endif
	endfor

	if cond == 0
	    if g:atp_debugProject
		silent echomsg "Project script not changed " . "\n"
		silent echo "Write Project Script time = " . reltimestr(reltime(time)) . "\n"
	    endif
	    if g:atp_debugProject
		let g:return = 3
	    endif
	    if g:atp_debugProject >= 2
		echomsg "Write Project Script time " . reltimestr(reltime(time))
	    endif
	    return
	endif
    endif
    
    " Make a list of variables defined in project script
    let defined_variables	= []
    let defined_variables = []
    try
	let ps_lines = readfile(a:project_script)
    catch /E484:/
	let ps_lines = []
    endtry
    for line in ps_lines
	if line =~ '^\s*\<let\>\s\+[bg]:'
	    call add(defined_variables, line)
	endif
    endfor
    call map(defined_variables, 'matchstr(v:val, ''^\s*let\s\+\zs[bg]:[^[:blank:]=]*'')') 
    if g:atp_debugProject
	let g:defined_variables	= defined_variables
    endif


    let deleted_variables	= []
    for var in defined_variables
	if !exists(var)
	    call add(deleted_variables, var)
	endif
    endfor

    if g:atp_debugProject
	let g:existing_variables	= []
    endif
    for var in a:cached_variables
	if exists(var)
	    let lvar	= 'l:' . substitute(var, '^[bg]:', '', '')
	    let {lvar} = {var}
	    if g:atp_debugProject
		call add(g:existing_variables, var)
	    endif
	endif
    endfor

    if g:atp_debugProject
	let g:deleted_variables = deleted_variables
    endif

    let hidden	= &l:hidden
    setl hidden

    let lazyredraw = &l:lazyredraw
    setl lazyredraw

    let bufnr	= bufnr("%")
    try
	silent! exe "keepalt keepjumps edit +setl\\ noswapfile " . fnameescape(a:project_script)
    catch /.*/
	echoerr v:errmsg
	let errmsg	= v:errmsg
	echoerr "WriteProjectScript catched error while opening " . a:project_script . ". Project script not written."
	let v:errmsg	= errmsg
	let &l:hidden		= hidden
	let &l:lazyredraw	= lazyredraw
	if g:atp_debugProject
	    let g:return = 4
	endif
	if g:atp_debugProject >= 2
	    echomsg "Write Project Script time " . reltimestr(reltime(time))
	endif
	return 
    endtry
    if !&l:modifiable
	setl modifiable
    endif
    if &l:readonly
	setl noreadonly
    endif
    if has("persistent_undo")
	setl noundofile
    endif

    " Delete the variables which where unlet:
    for var in deleted_variables
	try 
	    exe 'keepjumps silent! %g/^\s*let\s\+' . var . '\>/d_'
	catch /E48\%(6\|0\):/
	endtry
    endfor

    " Write new variables:
    for var in a:cached_variables

	let lvar 	=  "l:" . substitute(var, '^[bg]:', '', '')
	    if g:atp_debugProject
		echomsg var . " " . exists(lvar)
	    endif

	if exists(lvar)

	    try 
		exe 'silent! keepjumps %g/^\s*let\s\+' . var . '\>/d_'
	    catch /^Vim\%((\a\+)\)\=:E486/
	    catch /^Vim\%((\a\+)\)\=:E21/
	    endtry
	    keepjumps call append('$', 'let ' . var . ' = ' . string({lvar}))
	endif
    endfor
    " Save project script file:
    if getline(1) !~# '" ATP project vim script'
	call append(0, '" ATP project vim script: '.strftime( "%a %b %d, %Y at %I:%M %p %z").".")
    endif
    silent write
    let projectscript_bufnr	= bufnr("%")
    exe "silent keepalt keepjumps b " . bufnr
    exe "bdelete " . projectscript_bufnr


    let &l:lazyredraw = lazyredraw
    call winrestview(winsaveview)

    if g:atp_debugProject
	silent echo "Write Project Script time = " . reltimestr(reltime(time))
	redir END
    endif
    if g:atp_debugProject >= 2
	echomsg "Write Project Script time " . reltimestr(reltime(time))
    endif
endfunction
catch /E127:/
endtry
function! <SID>WriteProjectScriptInterface(bang,...)
    let type 	= ( a:0 >= 1 ? a:1 : 'local' )
    let silent  = ( a:0 >= 2 ? str2nr(a:2) : 0 )

    let cond = exists("g:atp_ProjectScript") && !g:atp_ProjectScript || exists("b:atp_ProjectScript") && ( !b:atp_ProjectScript && (!exists("g:atp_ProjectScript") || exists("g:atp_ProjectScript") && !g:atp_ProjectScript )) || !exists("b:atp_ProjectScript") && !exists("g:atp_ProjectScript")
    if a:bang == "" && cond
	if !silent
	    echomsg "[ATP:] WriteProjectScript: ProjectScript is turned off."
	endif
	return
    endif

    if type != 'global' && type != 'local' 
	echoerr "WriteProjectScript Error : type (".type.") can be: local or global." 
	return
    endif
    
    if !exists("b:atp_ProjectScriptFile")
	let project_script = GetProjectScript(FindProjectScripts())
	if project_script != "no project script found"
	    let b:atp_ProjectScriptFile = project_script
	    let b:atp_ProjectDir	= fnamemodify(project_script, ":h")
	else
	    let b:atp_ProjectScriptFile = resolve(expand("%:p")) . ".project.vim"
	    let b:atp_ProjectDir	= fnamemodify(b:atp_ProjectScriptFile, ":h")
	endif
    endif

    let script 	= ( type == 'local' ? b:atp_ProjectScriptFile : s:common_project_script )
    let variables = ( type == 'local' ? g:atp_ProjectLocalVariables : g:atp_ProjectGlobalVariables )
    if type == 'local' && !silent
	echomsg "[ATP:] writing to " . b:atp_ProjectScriptFile
    endif
    call s:WriteProjectScript(a:bang, script, variables, type, silent)
endfunction
function! s:WPSI_comp(ArgLead, CmdLine, CursorPos)
    return filter(['local', 'global'], 'v:val =~ a:ArgLead')
endfunction 
"{{{ WriteProjectScript AUTOCOMMANDS:
function! <SID>AU_WriteLocalProjectScript()
    if &filetype =~ 'tex' &&
	    \ !( exists("g:atp_ProjectScript") && !g:atp_ProjectScript || exists("b:atp_ProjectScript") && ( !b:atp_ProjectScript && (!exists("g:atp_ProjectScript") || exists("g:atp_ProjectScript") && !g:atp_ProjectScript )) )
	call s:WriteProjectScript("", b:atp_ProjectScriptFile, g:atp_ProjectLocalVariables, 'local', 1)
    endif
endfunction
function! <SID>AU_WriteGlobalProjectScript()
    if &filetype =~ 'tex' &&
	    \ !( exists("g:atp_ProjectScript") && !g:atp_ProjectScript || exists("b:atp_ProjectScript") && ( !b:atp_ProjectScript && (!exists("g:atp_ProjectScript") || exists("g:atp_ProjectScript") && !g:atp_ProjectScript )) )
	call s:WriteProjectScript("", s:common_project_script, g:atp_ProjectGlobalVariables, 'global', 1)
    endif
endfunction
augroup ATP_WriteProjectScript 
    au!
    " Before it was VimLeave, write silently.
    au BufUnload *.tex call <SID>AU_WriteLocalProjectScript()
    au BufUnload *.tex call <SID>AU_WriteGlobalProjectScript()
augroup END 
"}}}
"}}}
" SET PROJECT SCRIPT: on/off
" {{{ s:ProjectScript
function! <SID>ProjectScript(...)
    let arg = ( a:0 >=1 ? a:1 : "" )
    if arg == ""
	let b:atp_ProjectScript=!b:atp_ProjectScript
    elseif arg == "on"
	let b:atp_ProjectScript=1
	:WriteProjectScript!
    elseif arg == "off"
	let b:atp_ProjectScript=0
	:WriteProjectScript!
    endif
    if b:atp_ProjectScript
	echomsg "[ATP:] Project Script - ON."
    else
	echomsg "[ATP:] Project Script - OFF."
    endif
    return b:atp_ProjectScript
endfunction
function! HistComp(ArgLead, CmdLine, CursorPos)
    return filter(['on', 'off'], 'v:val =~ a:ArgLead')
endfunction "}}}

" DELETE PROJECT SCRIPT:
" s:DeleteProjectScript {{{
" 	It has one argument a:1 == "local" or " a:0 == 0 " delete the		 
" 	b:atp_ProjectScriptFile.
" 	otherwise delete s:common_project_script.  With bang it forces to delete the
" 	s:common_project_script" 
" 	It also unlets the variables stored in s:common_project_script.
function! <SID>DeleteProjectScript(bang,...) 
    let type	= ( a:0 >= 1 ? a:1 : "local" )

    if type == "local"
	let file = b:atp_ProjectScriptFile
    else
	let file = s:common_project_script
    endif

    call delete(file)
    echo "[ATP:] Project Script ".file." deleted."
    if type == "local" && a:bang == "!"
	let file = s:common_project_script
	call delete(file)
	echo "[ATP:] Project Script ".file." deleted."
    endif
    if file == s:common_project_script
	for var in g:atp_ProjectGlobalVariables
	    exe "unlet " . var
	endfor
    endif
endfunction
function! s:DelPS(CmdArg, CmdLine, CursorPos)
    let comp	= [ "local", "common" ]  
    call filter(comp, "v:val =~ '^' . a:CmdArg")
    return comp
endfunction
" Show ProjectScript:
" function! <SID>ShowProjectScript(bang)
" 
"     let history_file
" endfunction
" }}}

" Save and Restore Project Variables (used by atplib#motion#GotoFile()).
function! SaveProjectVariables(...) "{{{
    let variables_List	= ( a:0 >= 1 ? {a:1} : g:atp_SavedProjectLocalVariables )
    let variables_Dict 	= {}
    for var in variables_List
	if exists(var)
	    call extend(variables_Dict, { var : {var} })
	endif
    endfor
    return variables_Dict
endfunction "}}}
function! RestoreProjectVariables(variables_Dict) "{{{
    for var in keys(a:variables_Dict)
 	let cmd =  "let " . var . "=" . string(a:variables_Dict[var])
	try
	    exe cmd
	catch E741:
	    " if the variable was locked:
	    exe "unlockvar ".var
	    exe cmd
	    exe "lockvar ".var 
	endtry
    endfor
endfunction "}}}
endif "}}}

" SCRIPT:
" (includes commands, and maps - all the things 
" 		that must be sources for each file)
" {{{
call <SID>LoadProjectScript("", "local")
" Project script should by loaded now, and not by autocommands which are executed after
" sourcing scripts. In this way variables set in project script will be used
" when sourcing other atp scripts.
call s:LoadScript("", s:common_project_script, 'global', 0, 'silent',1)

" Commands:
command! -buffer -bang -nargs=? -complete=customlist,s:LocalCommonGlobalComp LoadProjectScript :call <SID>LoadProjectScript(<q-bang>,<f-args>)
" write:
command! -buffer -bang -nargs=* -complete=customlist,s:WPSI_comp WriteProjectScript	:call <SID>WriteProjectScriptInterface(<q-bang>,<f-args>)
command! -buffer -nargs=* -complete=customlist,HistComp 	ProjectScript 		:call <SID>ProjectScript(<f-args>)

" delete:
command! -buffer -bang -complete=customlist,s:DelPS -nargs=? 	DeleteProjectScript 	:call s:DeleteProjectScript(<q-bang>, <f-args>)
" }}}
