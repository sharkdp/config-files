" Author: 	Marcin Szamotulski	
" Description: 	This file contains all the options defined on startup of ATP
" Note:		This file is a part of Automatic Tex Plugin for Vim.
" Language:	tex
" Last Change: Thu Feb 07, 2013 at 17:50:18  +0000

" NOTE: you can add your local settings to ~/.atprc.vim or
" ftplugin/ATP_files/atprc.vim file

" Some options (functions) should be set once:
let s:did_options 	= exists("s:did_options") ? 1 : 0

if has("python") || has("python3")
let atp_path = fnamemodify(expand('<sfile>'), ':p:h')
python << EOF
import vim
import sys
sys.path.insert(0, vim.eval('atp_path'))
EOF
endif

"{{{ tab-local variables
" We need to know bufnumber and bufname in a tabpage.
" ToDo: we can set them with s: and call them using <SID> stack
" (how to make the <SID> stack invisible to the user!

    let t:atp_bufname	= expand("%:p")
    let t:atp_bufnr	= bufnr("")
    let t:atp_winnr	= winnr()


" autocommands for buf/win numbers
" These autocommands are used to remember the last opened buffer number and its
" window number:
if !s:did_options
    augroup ATP_TabLocalVariables
	au!
	au BufLeave *.tex 	let t:atp_bufname	= expand("%:p")
	au BufLeave *.tex 	let t:atp_bufnr		= bufnr("")
	" t:atp_winnr the last window used by tex, ToC or Labels buffers:
	au WinEnter *.tex 	let t:atp_winnr		= winnr("#")
	au WinEnter __ToC__ 	let t:atp_winnr		= winnr("#")
	au WinEnter __Labels__ 	let t:atp_winnr		= winnr("#")
	au TabEnter *.tex	let t:atp_SectionStack 	= ( exists("t:atp_SectionStack") ? t:atp_SectionStack : [] ) 
    augroup END
endif
"}}}

" ATP Debug Variables: (to debug atp behaviour)
" {{{ debug variables
if !exists("g:atp_debugCheckClosed")
    let g:atp_debugCheckClosed = 0
endif
if !exists("g:atp_debugMapFile")
    " debug of atplib#complete#CheckClosed_math function
    " (issues errormsg when synstack() failed).
    let g:atp_debugCheckClosed_math	= 0
endif
if !exists("g:atp_debugMapFile")
    " debug mappings.vim file (show which maps will not be defined).
    let g:atp_debugMapFile	= 0
endif
if !exists("g:atp_debugLatexTags")
    " debug <SID>LatexTags() function (motion.vim)
    let g:atp_debugLatexTags	= 0
endif
if !exists("g:atp_debugaaTeX")
    " debug <SID>auTeX() function (compiler.vim)
    let g:atp_debugauTeX	= 0
endif
if !exists("g:atp_debugSyncTex")
    " debug SyncTex (compiler.vim)
    let g:atp_debugSyncTex 	= 0
endif
if !exists("g:atp_debugInsertItem")
    " debug SyncTex (various.vim)
    let g:atp_debugInsertItem 	= 0
endif
if !exists("g:atp_debugUpdateATP")
    " debug UpdateATP (various.vim)
    let g:atp_debugUpdateATP 	= 0
endif
if !exists("g:atp_debugPythonCompiler")
    " debug MakeLatex (compiler.vim)
    let g:atp_debugPythonCompiler = 0
endif
if !exists("g:atp_debugML")
    " debug MakeLatex (compiler.vim)
    let g:atp_debugML		= 0
endif
if !exists("g:atp_debugGAF")
    " debug aptlib#GrepAuxFile
    let g:atp_debugGAF		= 0
endif
if !exists("g:atp_debugSelectCurrentParagraph")
    " debug s:SelectCurrentParapgrahp (LatexBox_motion.vim)
    let g:atp_debugSelectCurrentParagraph	= 0
endif
if !exists("g:atp_debugSIT")
    " debug <SID>SearchInTree (search.vim)
    let g:atp_debugSIT		= 0
endif
if !exists("g:atp_debugRS")
    " debug <SID>RecursiveSearch (search.vim)
    let g:atp_debugRS		= 0
endif
if !exists("g:atp_debugSync")
    " debug forward search (vim->viewer) (search.vim)
    let g:atp_debugSync		= 0
endif
if !exists("g:atp_debugV")
    " debug ViewOutput() (compiler.vim)
    let g:atp_debugV		= 0
endif
if !exists("g:atp_debugLPS")
    " Debug s:LoadProjectFile() (history.vim)
    " (currently it gives just the loading time info)
    let g:atp_debugLPS		= 0
endif
if !exists("g:atp_debugCompiler")
    " Debug s:Compiler() function (compiler.vim)
    " when equal 2 output is more verbose.
    let g:atp_debugCompiler 	= 0
endif
if !exists("g:atp_debugCallBack")
    " Debug <SID>CallBack() function (compiler.vim)
    let g:atp_debugCallBack	= 0
endif
if !exists("g:atp_debugST")
    " Debug SyncTex() (various.vim) function
    let g:atp_debugST 		= 0
endif
if !exists("g:atp_debugCloseLastEnvironment")
    " Debug atplib#complete#CloseLastEnvironment()
    let g:atp_debugCloseLastEnvironment	= 0
endif
if !exists("g:atp_debugMainScript")
    " loading times of scripts sources by main script file: ftpluing/tex_atp.vim
    " NOTE: it is listed here for completeness, it can only be set in
    " ftplugin/tex_atp.vim script file.
    let g:atp_debugMainScript 	= 0
endif

if !exists("g:atp_debugProject")
    " <SID>LoadScript(), <SID>LoadProjectScript(), <SID>WriteProject()
    " The value that is set in history file matters!
    let g:atp_debugProject 	= 0
endif
if !exists("g:atp_debugChekBracket")
    " atplib#complete#CheckBracket()
    let g:atp_debugCheckBracket 		= 0
endif
if !exists("g:atp_debugClostLastBracket")
    " atplib#complete#CloseLastBracket()
    let g:atp_debugCloseLastBracket 		= 0
endif
if !exists("g:atp_debugTabCompletion")
    " atplib#complete#TabCompletion()
    let g:atp_debugTabCompletion 		= 0
endif
if !exists("g:atp_debugBS")
    " atplib#bibsearch#searchbib()
    " atplib#bibsearch#showresults()
    " BibSearch() in ATP_files/search.vim
    " log file: /tmp/ATP_log 
    let g:atp_debugBS 		= 0
endif
if !exists("g:atp_debugToF")
    " TreeOfFiles() ATP_files/common.vim
    let g:atp_debugToF 		= 0
endif
if !exists("g:atp_debugBabel")
    " echo msg if  babel language is not supported.
    let g:atp_debugBabel 	= 0
endif
"}}}

" Vim Options:
" {{{ Vim options

" undo_ftplugin
let b:undo_ftplugin = "setlocal nrformats< complete< keywordprg< suffixes< comments< commentstring< define< include< suffixesadd< includeexpr< eventignore<"

" Make CTRL-A, CTRL-X work over alphabetic characters:
setl nrformats=alpha
setl backupskip+=*.tex.project.vim

" The vim option 'iskeyword' is adjust just after g:atp_separator and
" g:atp_no_separator variables are defined.

nmap <buffer> <silent> K :exe ':Texdoc' expand('<cword>')<cr>
" This works better than setting the keywordprg option.

exe "setlocal complete+=".
	    \ "k".split(globpath(&rtp, "ftplugin/ATP_files/dictionaries/greek"), "\n")[0].
	    \ ",k".split(globpath(&rtp, "ftplugin/ATP_files/dictionaries/dictionary"), "\n")[0].
	    \ ",k".split(globpath(&rtp, "ftplugin/ATP_files/dictionaries/SIunits"), "\n")[0].
	    \ ",k".split(globpath(&rtp, "ftplugin/ATP_files/dictionaries/tikz"), "\n")[0]

" The ams_dictionary is added after g:atp_amsmath variable is defined.

" setlocal iskeyword+=\
let suffixes = split(&suffixes, ",")
if index(suffixes, ".pdf") == -1
    setl suffixes+=.pdf
elseif index(suffixes, ".dvi") == -1
    setl suffixes+=.dvi
endif
" As a base we use the standard value defined in 
" The suffixes option is also set after g:atp_tex_extensions is set.

" Borrowed from tex.vim written by Benji Fisher:
" Set 'comments' to format dashed lists in comments
setl comments=sO:%\ -,mO:%\ \ ,eO:%%,:%

" Set 'commentstring' to recognize the % comment character:
" (Thanks to Ajit Thakkar.)
setl commentstring=%%s

" Allow "[d" to be used to find a macro definition:
" Recognize plain TeX \def as well as LaTeX \newcommand and \renewcommand .
" I may as well add the AMS-LaTeX DeclareMathOperator as well.
let &l:define='\\\([egx]\|char\|mathchar\|count\|dimen\|muskip\|skip\|toks\)\=def'
	\ .	'\|\\font\|\\\(future\)\=let'
	\ . '\|\\new\(count\|dimen\|skip\|muskip\|box\|toks\|read\|write\|fam\|insert\)'
	\ .	'\|\\definecolor{'
	\ . '\|\\\(re\)\=new\(boolean\|command\|counter\|environment\|font'
	\ . '\|if\|length\|savebox\|theorem\(style\)\=\)\s*\*\=\s*{\='
	\ . '\|DeclareMathOperator\s*{\=\s*'
	\ . '\|DeclareFixedFont\s*{\s*'
if &l:filetype != "plaintex"
    if atplib#search#SearchPackage('subfiles')
	setl include=^[^%]*\\%(\\\\input\\(\\s*{\\)\\=\\\\|\\\\include\\s*{\\\\|\\\\subfile\\s*{\\)
    else
	setl include=^[^%]*\\%(\\\\input\\(\\s*{\\)\\=\\\\|\\\\include\\s*{\\)
    endif
else
    setlocal include=^[^%]*\\\\input
endif
setl suffixesadd=.tex

setl includeexpr=substitute(v:fname,'\\%(.tex\\)\\?$','.tex','')
" TODO set define and work on the above settings, these settings work with [i
" command but not with [d, [D and [+CTRL D (jump to first macro definition)

" AlignPlugin settings
if !exists("g:Align_xstrlen") && v:version >= 703 && &conceallevel 
    let g:Align_xstrlen="ATP_strlen"
endif
setl formatlistpat=^\\s*\\\\item\\s*
setl formatoptions+=n
" setl formatexpr=TexFormat
setl cinwords=
" }}}

" BUFFER LOCAL VARIABLES:
" {{{ buffer variables
let b:atp_running	= 0

" these are all buffer related variables:
function! <SID>TexCompiler()
    if exists("b:atp_TexCompiler")
	return b:atp_TexCompiler
    elseif buflisted(atplib#FullPath(b:atp_MainFile))
	let line = get(getbufline(atplib#FullPath(b:atp_MainFile), "", 1), 0, "")
	if line =~ '^%&\w*tex\>'
	    return matchstr(line, '^%&\zs\w\+')
	endif
    elseif filereadable(atplib#FullPath(b:atp_MainFile))
	let line = get(readfile(atplib#FullPath(b:atp_MainFile), "", 1), 0, "")
	if line =~ '^%&\w*tex\>'
	    return matchstr(line, '^%&\zs\w\+')
	endif
    endif
    return (&filetype == "plaintex" ? "pdftex" : "pdflatex")
endfunction
    
let s:optionsDict= { 	
		\ "atp_TexOptions" 		: "-synctex=1", 
	        \ "atp_ReloadOnError" 		: "1", 
		\ "atp_OpenViewer" 		: "1", 		
		\ "atp_autex" 			: !&l:diff && expand("%:e") == 'tex', 
		\ "atp_autex_wait"		: 0,
		\ "atp_updatetime_insert"	: 4000,
		\ "atp_updatetime_normal"	: 2000,
		\ "atp_MaxProcesses"		: 3,
		\ "atp_KillYoungest"		: 0,
		\ "atp_ProjectScript"		: ( fnamemodify(b:atp_MainFile, ":e") != "tex" || stridx(expand('%'), 'fugitive:') == 0 ? "0" : "1" ),
		\ "atp_Viewer" 			: has("win26") || has("win32") || has("win64") || has("win95") || has("win32unix") ? "AcroRd32.exe" : ( has("mac") || has("macunix") ? "open" : "okular" ), 
		\ "atp_TexFlavor" 		: &l:filetype, 
		\ "atp_XpdfServer" 		: fnamemodify(b:atp_MainFile,":t:r"), 
		\ "atp_LocalXpdfServer" 	: expand("%:t:r"), 
		\ "atp_okularOptions"		: ["--unique"],
		\ "atp_TempDir"			: substitute(fnamemodify(atplib#FullPath(b:atp_MainFile), ':h') . "/.tmp", '\/\/', '\/', 'g'),
		\ "atp_OutDir"			: ( exists("b:atp_ProjectScriptFile") ? fnamemodify(b:atp_ProjectScriptFile, ":h") : fnamemodify(resolve(expand("%:p")), ":h") ),
		\ "atp_TexCompiler" 		: <SID>TexCompiler(),
		\ "atp_BibCompiler"		: ( getline(atplib#search#SearchPackage('biblatex')) =~ '\<backend\s*=\s*biber\>' ? 'biber' : "bibtex" ),
		\ "atp_auruns"			: "1",
		\ "atp_TruncateStatusSection"	: "60", 
		\ "atp_LastBibPattern"		: "",
		\ "atp_TexCompilerVariable"	: "max_print_line=2000",
		\ "atp_StarEnvDefault"		: "",
		\ "atp_StarMathEnvDefault"	: "",
		\ "atp_LatexPIDs"		: [],
		\ "atp_BibtexPIDs"		: [],
		\ "atp_PythonPIDs"		: [],
		\ "atp_MakeindexPIDs"		: [],
		\ "atp_LastLatexPID"		: 0,
		\ "atp_LastPythonPID"		: 0,
		\ "atp_VerboseLatexInteractionMode" : "errorstopmode",
		\ "atp_BibtexReturnCode"	: 0,
		\ "atp_MakeidxReturnCode"	: 0,
		\ "atp_BibtexOutput"		: "",
		\ "atp_MakeidxOutput"		: "",
		\ "atp_DocumentClass"		: atplib#search#DocumentClass(atplib#FullPath(b:atp_MainFile)),
		\ "atp_statusCurSection"	: 1,
		\ }

" Note: the above atp_OutDir is not used! the function s:SetOutDir() is used, it is just to
" remember what is the default used by s:SetOutDir().

" This function sets options (values of buffer related variables) which were
" not already set by the user.
" {{{ s:SetOptions
let s:ask = { "ask" : "0" }
function! s:SetOptions()

    let s:optionsKeys		= keys(s:optionsDict)
    let s:optionsinuseDict	= getbufvar(bufname("%"),"")

    "for each key in s:optionsKeys set the corresponding variable to its default
    "value unless it was already set in .vimrc file.
    for key in s:optionsKeys
" 	echomsg key
	if string(get(s:optionsinuseDict,key, "optionnotset")) == string("optionnotset") && key != "atp_OutDir" && key != "atp_autex"
	    call setbufvar(bufname("%"), key, s:optionsDict[key])
	elseif key == "atp_OutDir"

	    " set b:atp_OutDir and the value of errorfile option
	    if !exists("b:atp_OutDir")
		call atplib#common#SetOutDir(1)
	    endif
	    let s:ask["ask"] 	= 1
	endif
    endfor

        " Do not run tex on tex files which are in texmf tree
    " Exception: if it is opened using the command ':EditInputFile'
    " 		 which sets this itself.
    let time=reltime()
    if string(get(s:optionsinuseDict,"atp_autex", 'optionnotset')) == string('optionnotset')
	let atp_texinputs=split(substitute(substitute(system("kpsewhich -show-path tex"),'\/\/\+','\/','g'),'!\|\n','','g'),':')
	call remove(atp_texinputs, index(atp_texinputs, '.'))
	call filter(atp_texinputs, 'expand(b:atp_OutDir) =~# v:val')
	let b:atp_autex = ( len(atp_texinputs) ? 0 : s:optionsDict['atp_autex'])  
    endif
    let g:source_time_INPUTS=reltimestr(reltime(time))

    let time=reltime()
    if !exists("b:TreeOfFiles") || !exists("b:ListOfFiles") || !exists("b:TypeDict") || !exists("b:LevelDict")
	if exists("b:atp_MainFile") 
	    let atp_MainFile	= atplib#FullPath(b:atp_MainFile)
	    call TreeOfFiles(atp_MainFile, g:atp_inputfile_pattern, (&filetype == 'plaintex' ? 1 : 0))
	else
	    echomsg "[ATP:] b:atp_MainFile: ".b:atp_MainFile." doesn't exists."
	endif
    endif
    let g:source_time_TREE=reltimestr(reltime(time))
endfunction
"}}}
call s:SetOptions()

"}}}

" GLOBAL VARIABLES: (almost all)
" {{{ global variables 
if !exists("g:atp_indent")
    let g:atp_indent=1
endif
if !exists("g:atp_DisplaylinePath")
    let g:atp_DisplaylinePath = "/Applications/Skim.app/Contents/SharedSupport/displayline"
endif
" if !exists("g:atp_ParseLog") " is set in ftplugin/ATP_files/common.vim script.
"     let g:atp_ParseLog = has("python")
" endif
" if !exists("g:atp_autocclose")
"     " This can be done by setting g:atp_DefautDebugMode = 'debug' (but it
"     not documented and not tested)
"     let g:atp_autocclose = 0
" endif
if !exists("g:atp_diacritics_letters")
    let g:atp_diacritics_letters={}
endif
let s:diacritics_letters = {
	    \ "'"  : 'aceginorsuyz',
	    \ "\"" : 'aeiouy',
	    \ "`"  : 'aeiouy',
	    \ "^"  : 'aceghilosuwy',
	    \ "v"  : 'acdehlnrstuz',
	    \ "b"  : '',
	    \ "d"  : '',
	    \ "H"  : 'ou',
	    \ "~"  : 'aeinouy',
	    \ "."  : 'acegioz',
	    \ "c"  : 'cegklnrst',
	    \ "t"  : '',
	    \ "2"  : '' }
for key in keys(s:diacritics_letters)
    if !has_key(g:atp_diacritics_letters, key)
	let g:atp_diacritics_letters[key] = s:diacritics_letters[key]
    endif
endfor
if !exists("g:atp_python_toc")
    let g:atp_python_toc = has("python")
endif
if !exists("g:atp_write_eventignore")
    " This is a comma separated list of events which will be ignored when 
    " atp saved the file (for example before background compilation but not
    " with :TEX command)
    let g:atp_write_eventignore=""
    " This was added to make:
    " au BufWrite *.tex :call atplib#motion#LatexTags('', 1) "silently make tags file
endif
if !exists("g:atp_ProgressBarValues")
    let g:atp_ProgressBarValues = {}
endif
if get(g:atp_ProgressBarValues,bufnr("%"),{}) == {}
    call extend(g:atp_ProgressBarValues, { bufnr("%") : {} })
endif
" if !exists("g:atp_TempDir")
"     " Is set in project.vim script.
"     call atplib#TempDir()
" endif
if !exists("g:atp_LogStatusLine")
    let g:atp_LogStatusLine = 0
endif
if !exists("g:atp_OpenAndSyncSleepTime")
    let g:atp_OpenAndSyncSleepTime = "750m"
endif
if !exists("g:atp_tab_map")
    let g:atp_tab_map = 0
endif
if !exists("g:atp_folding")
    let g:atp_folding = 0
endif
if !exists("g:atp_devversion")
    let g:atp_devversion = 0
endif
if !exists("g:atp_completion_tikz_expertmode")
    let g:atp_completion_tikz_expertmode = 1
endif
if !exists("g:atp_signs")
    let g:atp_signs = 0
endif
if !exists("g:atp_TexAlign_join_lines")
    let g:atp_TexAlign_join_lines = 0
endif
" if !exists("g:atp_imap_put_space") || g:atp_imap_put_space
" This was not working :(.
"     let g:atp_imap_put_space 	= 1
" endif
if !exists("g:atp_imap_tilde_braces")
    let g:atp_imap_tilde_braces = 0
endif
if !exists("g:atp_diacritics")
    let g:atp_diacritics = 2
endif
if !exists("g:atp_imap_diffop_move")
    let g:atp_imap_diffop_move 	= 0
endif
if !exists("g:atp_noautex_in_math")
    let g:atp_noautex_in_math 	= 1
endif
if !exists("g:atp_cmap_space")
    let g:atp_cmap_space 	= 1
endif
if !exists("g:atp_bibsearch")
    " Use python search engine (and python regexp) for bibsearch
    let g:atp_bibsearch 	= "python"
endif
if !exists("g:atp_map_Comment")
    let g:atp_map_Comment 	= "-c"
endif
if !exists("g:atp_map_UnComment")
    let g:atp_map_UnComment 	= "-u"
endif
if !exists("g:atp_HighlightErrors")
    let g:atp_HighlightErrors 	= 0
endif
if !exists("g:atp_Highlight_ErrorGroup")
    let g:atp_Highlight_ErrorGroup = "Error"
endif
if !exists("g:atp_Highlight_WarningGroup")
"     let g:atp_Highlight_WarningGroup = "WarningMsg"
    let g:atp_Highlight_WarningGroup = ""
endif
if !exists("maplocalleader")
    if &l:cpoptions =~# "B"
	let maplocalleader="\\"
    else
	let maplocalleader="\\\\"
    endif
endif
if !exists("g:atp_sections")
    " Used by :TOC command (s:maketoc in motion.vim)
    let g:atp_sections={
	\	'chapter' 	: [ '\m^\s*\(\\chapter\*\?\>\)',			'\m\\chapter\*'		],	
	\	'section' 	: [ '\m^\s*\(\\section\*\?\>\)',			'\m\\section\*'		],
	\ 	'subsection' 	: [ '\m^\s*\(\\subsection\*\?\>\)',			'\m\\subsection\*'	],
	\	'subsubsection' : [ '\m^\s*\(\\subsubsection\*\?\>\)',			'\m\\subsubsection\*'	],
	\	'bibliography' 	: [ '\m^\s*\(\\begin\s*{\s*thebibliography\s*}\|\\bibliography\s*{\)' , 'nopattern'],
	\	'abstract' 	: [ '\m^\s*\(\\begin\s*{abstract}\|\\abstract\s*{\)',	'nopattern'		],
	\   	'part'		: [ '\m^\s*\(\\part\*\?\>\)',				'\m\\part\*'		],
	\   	'frame'		: [ '\m^\s*\(\\frametitle\*\?\>\)',			'\m\\frametitle\*'	]
	\ }
endif
if !exists("g:atp_cgetfile")
    let g:atp_cgetfile = 1
endif
if !exists("g:atp_atpdev")
    " if 1 defines DebugPrint command to print log files from g:atp_Temp directory.
    let g:atp_atpdev = 0
endif
if !exists("g:atp_imap_ShortEnvIMaps")
    " By default 1, then one letter (+leader) mappings for environments are defined,
    " for example ]t -> \begin{theorem}\end{theorem}
    " if 0 three letter maps are defined: ]the -> \begin{theorem}\end{theorem}
    let g:atp_imap_ShortEnvIMaps = 1
endif
if !exists("g:atp_imap_over_leader")
    " I'm not using "'" by default - because it is used quite often in mathematics to
    " denote symbols.
    let g:atp_imap_over_leader	= "`"
endif
if !exists("g:atp_imap_subscript")
    let g:atp_imap_subscript 	= "__"
endif
if !exists("g:atp_imap_supscript")
    let g:atp_imap_supscript	= "^"
endif
if !exists("g:atp_imap_define_math")
    let g:atp_imap_define_math	= 1
endif
if !exists("g:atp_imap_define_environments")
    let g:atp_imap_define_environments = 1
endif
if !exists("g:atp_imap_define_math_misc")
    let g:atp_imap_define_math_misc = 1
endif
if !exists("g:atp_imap_define_diacritics")
    let g:atp_imap_define_diacritics = 1
endif
if !exists("g:atp_imap_define_greek_letters")
    let g:atp_imap_define_greek_letters = 1
endif
if !exists("g:atp_imap_wide")
    let g:atp_imap_wide		= 0
endif
if !exists("g:atp_letter_opening")
    let g:atp_letter_opening	= ""
endif
if !exists("g:atp_letter_closing")
    let g:atp_letter_closing	= ""
endif
if !exists("g:atp_imap_bibiliography")
    if g:atp_imap_ShortEnvIMaps
	let g:atp_imap_letter=""
    else
	let g:atp_imap_letter="let"
    endif
endif
if !exists("g:atp_imap_bibiliography")
    if g:atp_imap_ShortEnvIMaps
	let g:atp_imap_bibliography="B"
    else
	let g:atp_imap_bibliography="bib"
    endif
endif
if !exists("g:atp_imap_begin")
    if g:atp_imap_ShortEnvIMaps
	let g:atp_imap_begin="b"
    else
	let g:atp_imap_begin="beg"
    endif
endif
if !exists("g:atp_imap_end")
    if g:atp_imap_ShortEnvIMaps
	let g:atp_imap_end="e"
    else
	let g:atp_imap_end="end"
    endif
endif
if !exists("g:atp_imap_theorem")
    if g:atp_imap_ShortEnvIMaps
	let g:atp_imap_theorem="t"
    else
	let g:atp_imap_theorem="the"
    endif
endif
if !exists("g:atp_imap_definition")
    if g:atp_imap_ShortEnvIMaps
	let g:atp_imap_definition="d"
    else
	let g:atp_imap_definition="def"
    endif
endif
if !exists("g:atp_imap_proposition")
    if g:atp_imap_ShortEnvIMaps
	let g:atp_imap_proposition="P"
    else
	let g:atp_imap_proposition="Pro"
    endif
endif
if !exists("g:atp_imap_lemma")
    if g:atp_imap_ShortEnvIMaps
	let g:atp_imap_lemma="l"
    else
	let g:atp_imap_lemma="lem"
    endif
endif
if !exists("g:atp_imap_remark")
    if g:atp_imap_ShortEnvIMaps
	let g:atp_imap_remark="r"
    else
	let g:atp_imap_remark="rem"
    endif
endif
if !exists("g:atp_imap_corollary")
    if g:atp_imap_ShortEnvIMaps
	let g:atp_imap_corollary="c"
    else
	let g:atp_imap_corollary="cor"
    endif
endif
if !exists("g:atp_imap_proof")
    if g:atp_imap_ShortEnvIMaps
	let g:atp_imap_proof="p"
    else
	let g:atp_imap_proof="pro"
    endif
endif
if !exists("g:atp_imap_example")
    if g:atp_imap_ShortEnvIMaps
	let g:atp_imap_example="x"
    else
	let g:atp_imap_example="exa"
    endif
endif
if !exists("g:atp_imap_note")
    if g:atp_imap_ShortEnvIMaps
	let g:atp_imap_note="n"
    else
	let g:atp_imap_note="not"
    endif
endif
if !exists("g:atp_imap_enumerate")
    if g:atp_imap_ShortEnvIMaps
	let g:atp_imap_enumerate="E"
    else
	let g:atp_imap_enumerate="enu"
    endif
endif
if !exists("g:atp_imap_tabular")
    if g:atp_imap_ShortEnvIMaps
	let g:atp_imap_tabular="u"
    else
	let g:atp_imap_tabular="tab"
    endif
endif
if !exists("g:atp_imap_table")
    if g:atp_imap_ShortEnvIMaps
	let g:atp_imap_table=""
    else
	let g:atp_imap_table="Tab"
    endif
endif
if !exists("g:atp_imap_itemize")
    if g:atp_imap_ShortEnvIMaps
	let g:atp_imap_itemize="I"
    else
	let g:atp_imap_itemize="ite"
    endif
endif
if !exists("g:atp_imap_item")
    if g:atp_imap_ShortEnvIMaps
	let g:atp_imap_item="i"
    else
	let g:atp_imap_item="I"
    endif
endif
if !exists("g:atp_imap_align")
    if g:atp_imap_ShortEnvIMaps
	let g:atp_imap_align="a"
    else
	let g:atp_imap_align="ali"
    endif
endif
if !exists("g:atp_imap_gather")
    if g:atp_imap_ShortEnvIMaps
	let g:atp_imap_gather="g"
    else
	let g:atp_imap_gather="gat"
    endif
endif
if !exists("g:atp_imap_split")
    if g:atp_imap_ShortEnvIMaps
	let g:atp_imap_split="s"
    else
	let g:atp_imap_split="spl"
    endif
endif
if !exists("g:atp_imap_multiline")
    " Is not defined by default: ]m, and ]M are used for \(:\) and \[:\].
    if g:atp_imap_ShortEnvIMaps
	let g:atp_imap_multiline=""
    else
	let g:atp_imap_multiline="lin"
    endif
endif
if !exists("g:atp_imap_abstract")
    if g:atp_imap_ShortEnvIMaps
	let g:atp_imap_abstract="A"
    else
	let g:atp_imap_abstract="abs"
    endif
endif
if !exists("g:atp_imap_equation")
    if g:atp_imap_ShortEnvIMaps
	let g:atp_imap_equation="q"
    else
	let g:atp_imap_equation="equ"
    endif
endif
if !exists("g:atp_imap_center")
    if g:atp_imap_ShortEnvIMaps
	let g:atp_imap_center="C"
    else
	let g:atp_imap_center="cen"
    endif
endif
if !exists("g:atp_imap_flushleft")
    if g:atp_imap_ShortEnvIMaps
	let g:atp_imap_flushleft="L"
    else
	let g:atp_imap_flushleft="lef"
    endif
endif
if !exists("g:atp_imap_flushright")
    if g:atp_imap_ShortEnvIMaps
	let g:atp_imap_flushright="R"
    else
	let g:atp_imap_flushright="rig"
    endif
endif
if !exists("g:atp_imap_tikzpicture")
    if g:atp_imap_ShortEnvIMaps
	let g:atp_imap_tikzpicture="T"
    else
	let g:atp_imap_tikzpicture="tik"
    endif
endif
if !exists("g:atp_imap_frame")
    if g:atp_imap_ShortEnvIMaps
	let g:atp_imap_frame="f"
    else
	let g:atp_imap_frame="fra"
    endif
endif
if !exists("g:atp_goto_section_leader")
    let g:atp_goto_section_leader="-"
endif
if !exists("g:atp_autex_wait")
    " the value is a comma speareted list of modes, for modes see mode() function.
"     let g:atp_autex_wait = "i,R,Rv,no,v,V,c,cv,ce,r,rm,!"
    let g:atp_autex_wait = ""
endif
if !exists("g:atp_MapSelectComment")
    let g:atp_MapSelectComment = "=c"
endif
if exists("g:atp_latexpackages")
    " Transition to nicer name:
    let g:atp_LatexPackages = g:atp_latexpackages
    unlet g:atp_latexpackages
endif
if !exists("g:texmf")
    let g:texmf = substitute(system("kpsewhich -expand-var='$TEXMFHOME'"), '\n', '', 'g')
endif
if !exists("g:atp_LatexPackages")
    " Rescan the $TEXMFHOME directory for sty and tex files.
    let g:atp_LatexPackages = atplib#search#KpsewhichGlobPath('tex', g:texmf."/**", '*.\(sty\|tex\)', ':p')
endif
if !exists("g:atp_LatexClasses")
    " Rescan the $TEXMFHOME directory for cls files.
    let g:atp_LatexClasses = atplib#search#KpsewhichGlobPath('tex', g:texmf."/**", '*.cls', ':p')
endif
if !exists("g:atp_Python")
    " Also set in atplib#various#GetLatestSnapshot() and atplib#various#UpdateATP()
    " This might be a name of python executable or full path to it (if it is not in
    " the $PATH) 
    if has("win32") || has("win64")
	" TO BE TESTED:
	" see why to use "pythonw.exe" on:
	" "http://docs.python.org/using/windows.html".
	let g:atp_Python = "pythonw.exe"
    else
	let g:atp_Python = "python"
    endif
endif
if !exists("g:atp_UpdateToCLine")
    let g:atp_UpdateToCLine = 1
endif
if !exists("g:atp_DeleteWithBang")
    let g:atp_DeleteWithBang = [ 'synctex.gz', 'tex.project.vim']
endif
if !exists("g:atp_CommentLeader")
    let g:atp_CommentLeader="% "
endif
if !exists("g:atp_MapCommentLines")
    let g:atp_MapCommentLines = empty(globpath(&rtp, 'plugin/EnhancedCommentify.vim').globpath(&rtp,'plugin/NERD_commenter.vim').globpath(&rtp, 'commenter.vim'))
endif
if !exists("g:atp_XpdfSleepTime")
    let g:atp_XpdfSleepTime = "0"
endif
if !exists("g:atp_IMapCC")
    let g:atp_IMapCC = 0
endif
if !exists("g:atp_DefaultErrorFormat")
    let g:atp_DefaultErrorFormat = "erc"
endif
let b:atp_ErrorFormat = g:atp_DefaultErrorFormat
if !exists("g:atp_DsearchMaxWindowHeight")
    let g:atp_DsearchMaxWindowHeight=15
endif
if !exists("g:atp_ProgressBar")
    let g:atp_ProgressBar = 1
endif
let g:atp_cmdheight = &l:cmdheight
if !exists("g:atp_DebugModeQuickFixHeight")
    let g:atp_DebugModeQuickFixHeight = 8 
endif
if !exists("g:atp_DebugModeCmdHeight")
    let g:atp_DebugModeCmdHeight = &l:cmdheight
endif
if !exists("g:atp_DebugMode_AU_change_cmdheight")
    " Background Compilation will change the 'cmdheight' option when the compilation
    " was without errors. AU - autocommand compilation
    let g:atp_DebugMode_AU_change_cmdheight = 0
    " This is the 'stay out of my way' solution. 
endif
if !exists("g:atp_Compiler")
    let g:atp_Compiler = "python"
endif
if !exists("g:atp_ReloadViewers")
    " List of viewers which need to be reloaded after output file is updated.
    let g:atp_ReloadViewers	= [ 'xpdf' ]
endif
if !exists("g:atp_PythonCompilerPath")
    let g:atp_PythonCompilerPath=fnamemodify(expand("<sfile>"), ":p:h")."/compile.py"
endif
if !exists("g:atp_cpcmd")
    let g:atp_cpcmd="/bin/cp"
endif
" Variables for imaps, standard environment names:
if !exists("g:atp_EnvNameTheorem")
    let g:atp_EnvNameTheorem="theorem"
endif
if !exists("g:atp_EnvNameDefinition")
    let g:atp_EnvNameDefinition="definition"
endif
if !exists("g:atp_EnvNameProposition")
    let g:atp_EnvNameProposition="proposition"
endif
if !exists("g:atp_EnvNameObservation")
    " This mapping is defined only in old layout:
    " i.e. if g:atp_env_maps_old == 1
    let g:atp_EnvNameObservation="observation"
endif
if !exists("g:atp_EnvNameLemma")
    let g:atp_EnvNameLemma="lemma"
endif
if !exists("g:atp_EnvNameNote")
    let g:atp_EnvNameNote="note"
endif
if !exists("g:atp_EnvNameCorollary")
    let g:atp_EnvNameCorollary="corollary"
endif
if !exists("g:atp_EnvNameRemark")
    let g:atp_EnvNameRemark="remark"
endif
if !exists("g:atp_EnvNameExample")
    let g:atp_EnvNameExample="example"
endif
if !exists("g:atp_EnvOptions_enumerate")
    " add options to \begin{enumerate} for example [topsep=0pt,noitemsep] Then the
    " enumerate map <Leader>E will put \begin{enumerate}[topsep=0pt,noitemsep] Useful
    " options of enumitem to make enumerate more condenced.
    let g:atp_EnvOptions_enumerate=""
endif
if !exists("g:atp_EnvOptions_itemize")
    " Similar to g:atp_enumerate_options.
    let g:atp_EnvOptions_itemize=""
endif
if !exists("g:atp_VimCompatible")
    " Used by: % (s:JumpToMatch in LatexBox_motion.vim).
    " Remap :normal! r to <SID>Replace() (various.vim)
    let g:atp_VimCompatible = 0
    " It can be 0/1 or yes/no.
endif 
if !exists("g:atp_CupsOptions")
    " lpr command options for completion of SshPrint command.
    let g:atp_CupsOptions = [ 'landscape=', 'scaling=', 'media=', 'sides=', 'Collate=', 'orientation-requested=', 
		\ 'job-sheets=', 'job-hold-until=', 'page-ragnes=', 'page-set=', 'number-up=', 'page-border=', 
		\ 'number-up-layout=', 'fitplot=', 'outputorder=', 'mirror=', 'raw=', 'cpi=', 'columns=',
		\ 'page-left=', 'page-right=', 'page-top=', 'page-bottom=', 'prettyprint=', 'nowrap=', 'position=',
		\ 'natural-scaling=', 'hue=', 'ppi=', 'saturation=', 'blackplot=', 'penwidth=']
endif
if !exists("g:atp_lprcommand")
    " Used by :SshPrint
    let g:atp_lprcommand = "lpr"
endif 
if !exists("g:atp_iabbrev_leader")
    " Used for abbreviations: =theorem= (from both sides).
    let g:atp_iabbrev_leader = "="
endif 
if !exists("g:atp_bibrefRegister")
    " A register to which bibref obtained from AMS will be copied.
    let g:atp_bibrefRegister = "0"
endif
if !exists("g:atpbib_pathseparator")
    if has("win16") || has("win32") || has("win64") || has("win95")
	let g:atpbib_pathseparator = "\\"
    else
	let g:atpbib_pathseparator = "/"
    endif 
endif
if !exists("g:atpbib_WgetOutputFile")
    let g:atpbib_WgetOutputFile = "amsref.html"
endif
if !exists("g:atpbib_wget")
    let g:atpbib_wget="wget"
endif
if !exists("g:atp_vmap_text_font_leader")
    let g:atp_vmap_text_font_leader="_"
endif
if !exists("g:atp_vmap_environment_leader")
    let g:atp_vmap_environment_leader="<LocalLeader>"
endif
if !exists("g:atp_vmap_bracket_leader")
    let g:atp_vmap_bracket_leader="<LocalLeader>"
endif
if !exists("g:atp_vmap_big_bracket_leader")
    let g:atp_vmap_big_bracket_leader='<LocalLeader>b'
endif
if !exists("g:atp_map_forward_motion_leader")
    let g:atp_map_forward_motion_leader='}'
endif
if !exists("g:atp_map_backward_motion_leader")
    let g:atp_map_backward_motion_leader='{'
endif
if !exists("g:atp_RelativePath")
    " This is here only for completness, the default value is set in project.vim
    let g:atp_RelativePath 	= 1
endif
if !exists("g:atp_SyncXpdfLog")
    let g:atp_SyncXpdfLog 	= 0
endif
if !exists("g:atp_LogSync")
    let g:atp_LogSync 		= 0
endif

function! s:Sync(...)
    let arg = ( a:0 >=1 ? a:1 : "" )
    if arg == "on"
	let g:atp_LogSync = 1
    elseif arg == "off"
	let g:atp_LogSync = 0
    else
	let g:atp_LogSync = !g:atp_LogSync
    endif
    echomsg "[ATP:] g:atp_LogSync = " . g:atp_LogSync
endfunction
command! -buffer -nargs=? -complete=customlist,s:SyncComp LogSync :call s:Sync(<f-args>)
function! s:SyncComp(ArgLead, CmdLine, CursorPos)
    return filter(['on', 'off'], "v:val =~ a:ArgLead") 
endfunction

if !exists("g:atp_Compare")
    " Use b:changedtick variable to run s:Compiler automatically.
    let g:atp_Compare = "changedtick"
endif
if !exists("g:atp_babel")
    let g:atp_babel = 0
endif
" if !exists("g:atp_closebracket_checkenv")
    " This is a list of environment names. They will be checked by
    " atplib#complete#CloseLastBracket() function (if they are opened/closed:
    " ( \begin{array} ... <Tab>       will then close first \begin{array} and then ')'
    try
	let g:atp_closebracket_checkenv	= [ 'array' ]
	" Changing this variable is not yet supported *see ToDo: in
	" atplib#complete#CloseLastBracket() (autoload/atplib.vim)
	lockvar g:atp_closebracket_checkenv
    catch /E741:/
    endtry
" endif
" if !exists("g:atp_ProjectScript")
"     let g:atp_ProjectScript = 1
" endif
if !exists("g:atp_OpenTypeDict")
    let g:atp_OpenTypeDict = { 
		\ "pdf" 	: "xpdf",		"ps" 	: "evince",
		\ "djvu" 	: "djview",		"txt" 	: "split" ,
		\ "tex"		: "edit",		"dvi"	: "xdvi -s 5" }
    " for txt type files supported viewers are: cat, gvim = vim = tabe, split, edit
endif
if !exists("g:atp_LibraryPath")
    let g:atp_LibraryPath	= 0
endif
if !exists("g:atp_statusOutDir")
    let g:atp_statusOutDir 	= 1
endif
" if !exists("g:atp_developer") " is set in plugin/tex_atp.vim
"     let g:atp_developer		= 0
" endif
if !exists("g:atp_mapNn")
	let g:atp_mapNn		= 0 " This value is used only on startup, then :LoadHistory sets the default value.
endif  				    " user cannot change the value set by :LoadHistory on startup in atprc file.
" 				    " Unless using: 
" 				    	au VimEnter *.tex let b:atp_mapNn = 0
" 				    " Recently I changed this: in project files it is
" 				    better to start with atp_mapNn = 0 and let the
" 				    user change it. 
if !exists("g:atp_TeXdocDefault")
    let g:atp_TeXdocDefault	= '-I lshort'
endif
"ToDo: to doc.
"ToDo: luatex! (can produce both!)
if !exists("g:atp_CompilersDict")
    let g:atp_CompilersDict	= { 
		\ "pdflatex" 	: ".pdf", 	"pdftex" 	: ".pdf", 
		\ "xetex" 	: ".pdf", 	"latex" 	: ".dvi", 
		\ "tex" 	: ".dvi",	"elatex"	: ".dvi",
		\ "etex"	: ".dvi", 	"luatex"	: ".pdf"}
endif

if !exists("g:CompilerMsg_Dict")
    let g:CompilerMsg_Dict	= { 
		\ 'tex'			: 'TeX', 
		\ 'etex'		: 'eTeX', 
		\ 'pdftex'		: 'pdfTeX', 
		\ 'latex' 		: 'LaTeX',
		\ 'elatex' 		: 'eLaTeX',
		\ 'pdflatex'		: 'pdfLaTeX', 
		\ 'context'		: 'ConTeXt',
		\ 'luatex'		: 'LuaTeX',
		\ 'xetex'		: 'XeTeX'}
endif

if !exists("g:ViewerMsg_Dict")
    let g:ViewerMsg_Dict	= {
		\ 'xpdf'		: 'Xpdf',
		\ 'xdvi'		: 'Xdvi',
		\ 'kpdf'		: 'Kpdf',
		\ 'okular'		: 'Okular', 
		\ 'open'		: 'open',
		\ 'skim'		: 'Skim', 
		\ 'evince'		: 'Evince',
		\ 'acroread'		: 'AcroRead',
		\ 'epdfview'		: 'epdfView' }
endif
if b:atp_updatetime_normal
    let &l:updatetime=b:atp_updatetime_normal
endif
if !exists("g:atp_DefaultDebugMode")
    " recognised values: silent, debug.
    let g:atp_DefaultDebugMode	= "silent"
endif
if !exists("g:atp_show_all_lines")
    " boolean
    let g:atp_show_all_lines 	= 0
endif
if !exists("g:atp_ignore_unmatched")
    " boolean
    let g:atp_ignore_unmatched 	= 1
endif
if !exists("g:atp_imap_leader_1")
    let g:atp_imap_leader_1	= "#"
endif
if !exists("g:atp_infty_leader")
    let g:atp_infty_leader = (g:atp_imap_leader_1 == '#' ? '`' : g:atp_imap_leader_1 ) 
endif
if !exists("g:atp_imap_leader_2")
    let g:atp_imap_leader_2= "##"
endif
if !exists("g:atp_imap_leader_3")
    let g:atp_imap_leader_3	= "]"
endif
if !exists("g:atp_imap_leader_4")
    let g:atp_imap_leader_4= "["
endif
if !exists("g:atp_completion_font_encodings")
    let g:atp_completion_font_encodings	= ['T1', 'T2', 'T3', 'T5', 'OT1', 'OT2', 'OT4', 'UT1']
endif
if !exists("g:atp_font_encoding")
    let s:line=atplib#search#SearchPackage('fontenc')
    if s:line != 0
	" the last enconding is the default one for fontenc, this we will
	" use
	let s:enc=matchstr(getline(s:line),'\\usepackage\s*\[\%([^,]*,\)*\zs[^]]*\ze\]\s*{fontenc}')
    else
	let s:enc='OT1'
    endif
    let g:atp_font_encoding=s:enc
    unlet s:line
    unlet s:enc
endif
if !exists("g:atp_no_star_environments")
    let g:atp_no_star_environments=['document', 'flushright', 'flushleft', 'center', 
		\ 'enumerate', 'itemize', 'tikzpicture', 'scope', 
		\ 'picture', 'array', 'proof', 'tabular', 'table' ]
endif
if !exists("g:atp_sizes_of_brackets")
    let g:atp_sizes_of_brackets={'\left': '\right', 
			    \ '\bigl' 	: '\bigr', 
			    \ '\Bigl' 	: '\Bigr', 
			    \ '\biggl' 	: '\biggr' , 
			    \ '\Biggl' 	: '\Biggr', 
			    \ '\big'	: '\big',
			    \ '\Big'	: '\Big',
			    \ '\bigg'	: '\bigg',
			    \ '\Bigg'	: '\Bigg',
			    \ '\' 	: '\',
			    \ }
   " the last one is not a size of a bracket is to a hack to close \(:\), \[:\] and
   " \{:\}
endif
if !exists("g:atp_algorithmic_dict")
    let g:atp_algorithmic_dict = { 'IF' : 'ENDIF', 'FOR' : 'ENDFOR', 'WHILE' : 'ENDWHILE' }
endif
if !exists("g:atp_bracket_dict")
    let g:atp_bracket_dict = { '(' : ')', '{' : '}', '[' : ']', '\(': '\)', '\{': '\}', '\[': '\]', '\lceil' : '\rceil', '\lfloor' : '\rfloor', '\langle' : '\rangle', '\lgroup' : '\rgroup', '\begin' : '\end' }
    " <:> is not present since < (and >) are used in math.
endif
if !exists("g:atp_LatexBox")
    let g:atp_LatexBox		= 1
endif
if !exists("g:atp_check_if_LatexBox")
    let g:atp_check_if_LatexBox	= 1
endif
if !exists("g:atp_autex_check_if_closed")
    let g:atp_autex_check_if_closed = 1
endif
if !exists("g:atp_env_maps_old")
    let g:atp_env_maps_old	= 0
endif
if !exists("g:atp_amsmath")
    let g:atp_amsmath=atplib#search#SearchPackage('ams')
endif
if atplib#search#SearchPackage('amsmath') || g:atp_amsmath != 0 || atplib#search#DocumentClass(atplib#FullPath(b:atp_MainFile)) =~ '^ams'
    exe "setl complete+=k".split(globpath(&rtp, "ftplugin/ATP_files/dictionaries/ams_dictionary"), "\n")[0]
endif
if !exists("g:atp_no_math_command_completion")
    let g:atp_no_math_command_completion = 0
endif
if !exists("g:atp_tex_extensions")
    let g:atp_tex_extensions	= ["tex.project.vim", "aux", "_aux", "log", "bbl", "blg", "bcf", "run.xml", "spl", "snm", "nav", "thm", "brf", "out", "toc", "mpx", "idx", "ind", "ilg", "maf", "glo", "mtc[0-9]", "mtc1[0-9]", "pdfsync", "synctex.gz" ]
    if g:atp_ParseLog
	call add(g:atp_tex_extensions, '_log')
    endif
endif
for ext in g:atp_tex_extensions
    let suffixes = split(&suffixes, ",")
    if index(suffixes, ".".ext) == -1 && ext !~ 'mtc'
	exe "setl suffixes+=.".ext
    endif
endfor
if !exists("g:atp_delete_output")
    let g:atp_delete_output	= 0
endif
if !exists("g:atp_keep")
    " Files with this extensions will be copied back and forth to/from temporary
    " directory in which compelation happens.
    let g:atp_keep=[ "log", "aux", "toc", "bbl", "ind", "idx", "synctex.gz", "blg", "loa", "toc", "lot", "lof", "thm", "out", "nav" ]
    " biber stuff is added before compelation, this makes it possible to change 
    " to biber on the fly
    if b:atp_BibCompiler =~ '^\s*biber\>'
	let g:atp_keep += [ "run.xml", "bcf" ]
    endif
endif
if !exists("g:atp_ssh")
    " WINDOWS NOT COMPATIBLE
    let g:atp_ssh=$USER . "@localhost"
endif
" opens bibsearch results in vertically split window.
if !exists("g:vertical")
    let g:vertical		= 1
endif
if !exists("g:matchpair")
    let g:matchpair="(:),[:],{:}"
endif
if !exists("g:atp_compare_embedded_comments") || g:atp_compare_embedded_comments != 1
    let g:atp_compare_embedded_comments  = 0
endif
if !exists("g:atp_compare_double_empty_lines") || g:atp_compare_double_empty_lines != 0
    let g:atp_compare_double_empty_lines = 1
endif
"TODO: put toc_window_with and labels_window_width into DOC file
if !exists("g:atp_toc_window_width")
    let g:atp_toc_window_width 	= 30
endif
if !exists("t:toc_window_width")
    let t:toc_window_width	= g:atp_toc_window_width
endif
if !exists("t:atp_labels_window_width")
    if exists("g:labels_window_width")
	let t:atp_labels_window_width = g:labels_window_width
    else
	let t:atp_labels_window_width = 30
    endif
endif
if !exists("g:atp_completion_limits")
    let g:atp_completion_limits	= [40,60,80,120,60]
endif
if !exists("g:atp_long_environments")
    let g:atp_long_environments	= []
endif
if !exists("g:atp_no_complete")
     let g:atp_no_complete	= ['document']
endif
" if !exists("g:atp_close_after_last_closed")
"     let g:atp_close_after_last_closed=1
" endif
if !exists("g:atp_no_env_maps")
    let g:atp_no_env_maps	= 0
endif
if !exists("g:atp_extra_env_maps")
    let g:atp_extra_env_maps	= 0
endif
" todo: to doc. Now they go first.
" if !exists("g:atp_math_commands_first")
"     let g:atp_math_commands_first=1
" endif
if !exists("g:atp_completion_truncate")
    let g:atp_completion_truncate	= 4
endif
" add server call back (then automatically reads errorfiles)
if !exists("g:atp_statusNotif")
    if has('clientserver') && !empty(v:servername) 
	let g:atp_statusNotif	= 1
    else
	let g:atp_statusNotif	= 0
    endif
endif
if !exists("g:atp_statusNotifHi")
    " User<nr>  - highlight status notifications with highlight group User<nr>.
    let g:atp_statusNotifHi	= 0
endif
if !exists("g:atp_callback")
    if exists("g:atp_statusNotif") && g:atp_statusNotif == 1 &&
		\ has('clientserver') && !empty(v:servername) &&
		\ !(has('win16') || has('win32') || has('win64') || has('win95'))
	let g:atp_callback	= 1
    else
	let g:atp_callback	= 0
    endif
endif
if !exists("g:atp_ProgressBarFile")
    " Only needed if g:atp_callback == 0
    let g:atp_ProgressBarFile = tempname()
endif
if !exists("g:atp_iskeyword")
    let g:atp_iskeyword = '65-90,97-122'
endif
if !exists("g:atp_HighlightMatchingPair")
    let g:atp_HighlightMatchingPair = 1
endif
if !exists("g:atp_SelectInlineMath_withSpace")
    let g:atp_SelectInlineMath_withSpace = 0
endif
if !exists("g:atp_splitright")
    let g:atp_splitright = &splitright
endif
if !exists("g:atp_StatusLine")
    " If non 0, a new value will be assigned and used fot the statusline
    " option (common.vim)
    let g:atp_StatusLine = 1
endif
if !exists("g:atp_cpoptions")
    " Possible entries:
    " w - remap iw in visual and operator mode
    let g:atp_cpoptions = ""
endif
" }}}

" PROJECT SETTINGS:
" {{{1
if !exists("g:atp_ProjectLocalVariables")
    " This is a list of variable names which will be preserved in project files
    let g:atp_ProjectLocalVariables = [
		\ "b:atp_MainFile",	     "g:atp_mapNn",		"b:atp_autex",
		\ "b:atp_TexCompiler",	     "b:atp_TexOptions",	"b:atp_TexFlavor", 
		\ "b:atp_auruns",	     "b:atp_ReloadOnError",	"b:atp_OutDir",
		\ "b:atp_OpenViewer",	     "b:atp_XpdfServer",
		\ "b:atp_Viewer",	     "b:TreeOfFiles",		"b:ListOfFiles",
		\ "b:TypeDict",		     "b:LevelDict",		"b:atp_BibCompiler",
		\ "b:atp_StarEnvDefault",    "b:atp_StarMathEnvDefault",
		\ "b:atp_updatetime_insert", "b:atp_updatetime_normal",
		\ "b:atp_LocalCommands",     "b:atp_LocalEnvironments", "b:atp_LocalColors",
		\ ] 
    if !has("python")
	call extend(g:atp_ProjectLocalVariables, ["b:atp_LocalCommands", "b:atp_LocalEnvironments", "b:atp_LocalColors"])
    endif
endif
" This variable is used by atplib#motion#GotoFile (atp-:Edit command):c
let g:atp_SavedProjectLocalVariables = [
                \ "b:atp_MainFile",          "g:atp_mapNn",             "b:atp_autex",
                \ "b:atp_TexCompiler",       "b:atp_TexOptions",        "b:atp_TexFlavor", 
                \ "b:atp_ProjectDir",        "b:atp_auruns",            "b:atp_ReloadOnError",
                \ "b:atp_OutDir",            "b:atp_OpenViewer",        "b:atp_XpdfServer",
                \ "b:atp_Viewer",            "b:TreeOfFiles",           "b:ListOfFiles",
                \ "b:TypeDict",              "b:LevelDict",             "b:atp_BibCompiler",
                \ "b:atp_StarEnvDefault",    "b:atp_StarMathEnvDefault",
                \ "b:atp_updatetime_insert", "b:atp_updatetime_normal", 
                \ "b:atp_ErrorFormat",       "b:atp_LastLatexPID",      "b:atp_LatexPIDs",
                \ "b:atp_LatexPIDs",         "b:atp_BibtexPIDs",        "b:atp_MakeindexPIDs",
                \ "b:atp_LocalCommands",     "b:atp_LocalEnvironments", "b:atp_LocalColors",
		\ ]

" }}}1

" This is to be extended into a nice function which shows the important options
" and allows to reconfigure atp
"{{{ ShowOptions
let s:file	= expand('<sfile>:p')
function! s:ShowOptions(bang,...)

    let pattern	= a:0 >= 1 ? a:1 : ".*,"
    let mlen	= max(map(copy(keys(s:optionsDict)), "len(v:val)"))

    redraw
    echohl WarningMsg
    echo "Local buffer variables:"
    echohl None
    for key in sort(keys(s:optionsDict))
	let space = ""
	for s in range(mlen-len(key)+1)
	    let space .= " "
	endfor
	if "b:".key =~ pattern
" 	    if patn != '' && "b:".key !~ patn
		echo "b:".key.space.string(getbufvar(bufnr(""), key))
" 	    endif
	endif
    endfor
    if a:bang == "!"
" 	Show some global options
	echo "\n"
	echohl WarningMsg
	echo "Global variables (defined in ".s:file."):"
	echohl None
	let saved_loclist	= getloclist(0)
	    execute "lvimgrep /^\\s*let\\s\\+g:/j " . fnameescape(s:file)
	let global_vars		= getloclist(0)
	call setloclist(0, saved_loclist)
	let var_list		= []

	for var in global_vars
	    let var_name	= matchstr(var['text'], '^\s*let\s\+\zsg:\S*\ze\s*=')
	    if len(var_name) 
		call add(var_list, var_name)
	    endif
	endfor
	call sort(var_list)

	" Filter only matching variables that exists!
	call filter(var_list, 'count(var_list, v:val) == 1 && exists(v:val)')
	let mlen	= max(map(copy(var_list), "len(v:val)"))
	for var_name in var_list
	    let space = ""
	    for s in range(mlen-len(var_name)+1)
		let space .= " "
	    endfor
	    if var_name =~ pattern && var_name !~ '_command\|_amsfonts\|ams_negations\|tikz_\|keywords'
" 		if patn != '' && var_name !~ patn
		if index(["g:atp_LatexPackages", "g:atp_LatexClasses", "g:atp_completion_modes", "g:atp_completion_modes_normal_mode", "g:atp_Environments", "g:atp_shortname_dict", "g:atp_MathTools_environments", "g:atp_keymaps", "g:atp_CupsOptions", "g:atp_CompilerMsg_Dict", "g:ViewerMsg_Dict", "g:CompilerMsg_Dict", "g:atp_amsmath_environments", "g:atp_siuinits"], var_name) == -1 && var_name !~# '^g:atp_Beamer' && var_name !~# '^g:atp_TodoNotes'
		    echo var_name.space.string({var_name})
		    if len(var_name.space.string({var_name})) > &l:columns
			echo "\n"
		    endif
		endif
" 		endif
	    endif
	endfor

    endif
endfunction
command! -buffer -bang -nargs=* ShowOptions		:call <SID>ShowOptions(<q-bang>, <q-args>)
"}}}
" DEBUG MODE VARIABLES:
" {{{ Debug Mode
let t:atp_DebugMode	= g:atp_DefaultDebugMode 
" there are three possible values of t:atp_DebugMode
" 	silent/normal/debug
if !exists("t:atp_QuickFixOpen")
    let t:atp_QuickFixOpen	= 0
endif

if !s:did_options
    augroup ATP_DebugMode
	au!
	au BufEnter *.tex let t:atp_DebugMode	 = ( exists("t:atp_DebugMode") ? t:atp_DebugMode : g:atp_DefaultDebugMode )
	au BufEnter *.tex let t:atp_QuickFixOpen = ( exists("t:atp_QuickFixOpen") ? t:atp_QuickFixOpen : 0 )
	" When opening the quickfix error buffer:  
	au FileType qf 	let t:atp_QuickFixOpen 	 = 1
	" When closing the quickfix error buffer (:close, :q) also end the Debug Mode.
	au FileType qf 	au BufUnload <buffer> let t:atp_DebugMode = g:atp_DefaultDebugMode | let t:atp_QuickFixOpen = 0
	au FileType qf	setl nospell norelativenumber nonumber
    augroup END
endif
"}}}

" BABEL:
" {{{1 variables
if !exists("g:atp_keymaps")
let g:atp_keymaps = { 
		\ 'british'	: 'ignore',		'english' 	: 'ignore',
		\ 'USenglish'	: 'ignore', 		'UKenglish'	: 'ignore',
		\ 'american'	: 'ignore',
	    	\ 'bulgarian' 	: 'bulgarian-bds', 	'croatian' 	: 'croatian',
		\ 'czech'	: 'czech',		'greek'		: 'greek',
		\ 'plutonikogreek': 'greek',		'hebrew'	: 'hebrew',
		\ 'russian' 	: 'russian-jcuken',	'serbian' 	: 'serbian',
		\ 'slovak' 	: 'slovak', 		'ukrainian' 	: 'ukrainian-jcuken',
		\ 'polish' 	: 'polish-slash' }
else "extend the existing dictionary with default values not ovverriding what is defind:
    for lang in [ 'croatian', 'czech', 'greek', 'hebrew', 'serbian', 'slovak' ] 
	call extend(g:atp_keymaps, { lang : lang }, 'keep')
    endfor
    call extend(g:atp_keymaps, { 'british' 	: 'ignore' }, 		'keep')
    call extend(g:atp_keymaps, { 'american' 	: 'ignore' }, 		'keep')
    call extend(g:atp_keymaps, { 'english' 	: 'ignore' }, 		'keep')
    call extend(g:atp_keymaps, { 'UKenglish' 	: 'ignore' }, 		'keep')
    call extend(g:atp_keymaps, { 'USenglish' 	: 'ignore' }, 		'keep')
    call extend(g:atp_keymaps, { 'bulgarian' 	: 'bulgarian-bds' }, 	'keep')
    call extend(g:atp_keymaps, { 'plutonikogreek' : 'greek' }, 		'keep')
    call extend(g:atp_keymaps, { 'russian' 	: 'russian-jcuken' }, 	'keep')
    call extend(g:atp_keymaps, { 'ukrainian' 	: 'ukrainian-jcuken' },	'keep')
endif

" {{{1 <SID>Babel
function! <SID>Babel()
    " Todo: make notification.
    if &filetype != "tex" || !exists("b:atp_MainFile") || !has("keymap")
	" This only works for LaTeX documents.
	" but it might work for plain tex documents as well!
	return
    endif
    let atp_MainFile	= atplib#FullPath(b:atp_MainFile)

    try
	let mf_lines = readfile(atp_MainFile)
    catch /E484:/
	let mf_lines = []
    endtry
    let babel_line = ""
    for line in mf_lines
	if line =~ '^[^%]*\\usepackage.*{babel}'
	    let babel_line = line
	    break
	elseif line =~ '\\begin\s*{\s*document\s*}'
	    break
	endif
    endfor
    let languages = split(matchstr(babel_line, '\[\zs[^]]*\ze\]'), ',')
    if len(languages) == 0
	return
    endif
    let default_language 	= get(languages, '-1', '') 
	if g:atp_debugBabel
	    echomsg "[Babel:] defualt language: " . default_language
	endif
    let keymap 			= get(g:atp_keymaps, default_language, '')

    if keymap == ''
	if g:atp_debugBabel
	    echoerr "No keymap in g:atp_keymaps.\n" . babel_line
	endif
	return
    endif

    if keymap != 'ignore'
	execute "set keymap=" . keymap
    else
	execute "set keymap="
    endif
endfunction
command! -buffer Babel	:call <SID>Babel()
" {{{1 start up
" if g:atp_babel
    " call <SID>Babel()
" endif
"  }}}1

" These are two functions which sets options for Xpdf and Xdvi. 
" {{{ Xpdf, Xdvi
" xdvi - supports forward and reverse searching
" {{{ SetXdvi
function! <SID>SetXdvi()

    if buflisted(atplib#FullPath(b:atp_MainFile))
	let line = getbufline(atplib#FullPath(b:atp_MainFile), 1)[0]
	if line =~ '^%&\w*tex\>'
	    let compiler = matchstr(line, '^%&\zs\w\+')
	else
	    let compiler = ""
	endif
    else
	let line = readfile(atplib#FullPath(b:atp_MainFile), "", 1)[0] 
	if line =~ '^%&\w*tex\>'
	    let compiler = matchstr(line, '^%&\zs\w\+')
	else
	    let compiler = ""
	endif
    endif
    if compiler != "" && compiler !~ '\(la\)\=tex'
	echohl Error
	echomsg "[SetXdvi:] You need to change the first line of your project!"
	echohl None
    endif

    " Remove menu entries
    let Compiler		= get(g:CompilerMsg_Dict, matchstr(b:atp_TexCompiler, '^\s*\S*'), 'Compiler')
    let Viewer			= get(g:ViewerMsg_Dict, matchstr(b:atp_Viewer, '^\s*\S*'), 'View\ Output')
    try
	execute "aunmenu Latex.".Compiler
	execute "aunmenu Latex.".Compiler."\\ debug"
	execute "aunmenu Latex.".Compiler."\\ twice"
	execute "aunmenu Latex.View\\ with\\ ".Viewer
	execute "aunmenu Latex.View\\Output"
    catch /E329:/
    endtry

    " Set new options:
    let b:atp_TexCompiler	= "latex"
    let b:atp_TexOptions	= "-src-specials"
    let b:atp_Viewer		= "xdvi"
    if exists("g:atp_xdviOptions")
	let g:atp_xdviOptions	+= index(g:atp_xdviOptions, '-editor') != -1 && 
		    \ ( !exists("b:atp_xdviOptions") || exists("b:atp_xdviOptions") && index(b:atp_xdviOptions,  '-editor') != -1 )
		    \ ? ["-editor", v:progname." --servername ".v:servername." --remote-wait +%l %f"] : []
	if index(g:atp_xdviOptions, '-watchfile') != -1 && 
	\ ( !exists("b:atp_xdviOptions") || exists("b:atp_xdviOptions") && index(b:atp_xdviOptions,  '-watchfile') != -1 )
	    let g:atp_xdviOptions += [ '-watchfile', '1' ]
	endif

    else
	if ( !exists("b:atp_xdviOptions") || exists("b:atp_xdviOptions") && index(b:atp_xdviOptions,  '-editor') != -1 )
	    let g:atp_xdviOptions = ["-editor",  v:progname." --servername ".v:servername." --remote-wait +%l %f"]
	endif
	if ( !exists("b:atp_xdviOptions") || exists("b:atp_xdviOptions") && index(b:atp_xdviOptions,  '-watchfile') != -1 )
	    if exists("g:atp_xdviOptions")
		let g:atp_xdviOptions += [ '-watchfile', '1' ]
	    else
		let g:atp_xdviOptions = [ '-watchfile', '1' ]
	    endif
	endif
    endif

    " Put new menu entries:
    let Compiler	= get(g:CompilerMsg_Dict, matchstr(b:atp_TexCompiler, '^\s*\zs\S*'), 'Compile')
    let Viewer		= get(g:ViewerMsg_Dict, matchstr(b:atp_Viewer, '^\s*\zs\S*'), "View\\ Output")
    execute "nmenu 550.5 &Latex.&".Compiler."<Tab>:TEX			:TEX<CR>"
    execute "nmenu 550.6 &Latex.".Compiler."\\ debug<Tab>:TEX\\ debug 	:DTEX<CR>"
    execute "nmenu 550.7 &Latex.".Compiler."\\ &twice<Tab>:2TEX		:2TEX<CR>"
    execute "nmenu 550.10 Latex.&View\\ with\\ ".Viewer."<Tab>:View 	:View<CR>"
endfunction
command! -buffer SetXdvi			:call <SID>SetXdvi()
nnoremap <silent> <buffer> <Plug>SetXdvi	:call <SID>SetXdvi()<CR>
" }}}

" xpdf - supports server option (we use the reoding mechanism, which allows to
" copy the output file but not reload the viewer if there were errors during
" compilation (b:atp_ReloadOnError variable)
" {{{ SetXpdf
function! <SID>SetPdf(viewer)

    " Remove menu entries.
    let Compiler		= get(g:CompilerMsg_Dict, matchstr(b:atp_TexCompiler, '^\s*\S*'), 'Compiler')
    let Viewer			= get(g:ViewerMsg_Dict, matchstr(b:atp_Viewer, '^\s*\S*'), 'View\ Output')
    try 
	execute "aunmenu Latex.".Compiler
	execute "aunmenu Latex.".Compiler."\\ debug"
	execute "aunmenu Latex.".Compiler."\\ twice"
	execute "aunmenu Latex.View\\ with\\ ".Viewer
    catch /E329:/
    endtry

    if buflisted(atplib#FullPath(b:atp_MainFile))
	let line = getbufline(atplib#FullPath(b:atp_MainFile), 1)[0]
	if line =~ '^%&\w*tex>'
	    let compiler = matchstr(line, '^%&\zs\w\+')
	else
	    let compiler = ""
	endif
    else
	let line = readfile(atplib#FullPath(b:atp_MainFile), "", 1)[0] 
	if line =~ '^%&\w*tex\>'
	    let compiler = matchstr(line, '^%&\zs\w\+')
	else
	    let compiler = ""
	endif
    endif
    if compiler != "" && compiler !~ 'pdf\(la\)\=tex'
	echohl Error
	echomsg "[SetPdf:] You need to change the first line of your project!"
	echohl None
    endif

    let b:atp_TexCompiler	= "pdflatex"
    " We have to clear tex options (for example -src-specials set by :SetXdvi)
    let b:atp_TexOptions	= "-synctex=1"
    let preview_viewer		= b:atp_Viewer
    let b:atp_Viewer		= a:viewer

    if has("unix") && has("clientserver")
	if a:viewer ==? 'evince'
	    let input_path  = atplib#FullPath(b:atp_MainFile)
	    let output_path = fnamemodify(input_path, ":r").".pdf"
	    " Start sync script
	    let sync_cmd = g:atp_Python." ".shellescape(split(globpath(&rtp, "ftplugin/ATP_files/evince_sync.py"), "\n")[0])
			\ ." ".toupper(v:progname)." ".shellescape(v:servername)
			\ ." ".shellescape(output_path)
			\ ." ".shellescape(input_path)
			\ ." &"
	    call system(sync_cmd)
	elseif preview_viewer ==? 'evince'
	    " Stop sync script.
            call <SID>Kill_Evince_Sync()
	endif
    endif

    " Delete menu entry.
    try
	silent aunmenu Latex.Reverse\ Search
    catch /E329:/
    endtry

    " Put new menu entries:
    let Compiler	= get(g:CompilerMsg_Dict, matchstr(b:atp_TexCompiler, '^\s*\zs\S*'), 'Compile')
    let Viewer		= get(g:ViewerMsg_Dict, matchstr(b:atp_Viewer, '^\s*\zs\S*'), 'View\ Output')
    execute "nmenu 550.5 &Latex.&".Compiler.	"<Tab>:TEX			:TEX<CR>"
    execute "nmenu 550.6 &Latex." .Compiler.	"\\ debug<Tab>:TEX\\ debug 	:DTEX<CR>"
    execute "nmenu 550.7 &Latex." .Compiler.	"\\ &twice<Tab>:2TEX		:2TEX<CR>"
    execute "nmenu 550.10 Latex.&View\\ with\\ ".Viewer.	"<Tab>:View 	:View<CR>"
endfunction
command! -buffer SetXpdf			:call <SID>SetPdf('xpdf')
command! -buffer SetOkular			:call <SID>SetPdf('okular')
command! -buffer SetEvince			:call <SID>SetPdf('evince')
nnoremap <silent> <buffer> <Plug>SetXpdf	:call <SID>SetPdf('xpdf')<CR>
nnoremap <silent> <buffer> <Plug>SetOkular	:call <SID>SetPdf('okular')<CR>
nnoremap <silent> <buffer> <Plug>SetEvince	:call <SID>SetPdf('evince')<CR>

function! <SID>Kill_Evince_Sync()
python << EOF
try:
    import psutil
    import vim
    import os
    import signal
    import re
    from psutil import NoSuchProcess
    for pid in psutil.get_pid_list():
        try:
            process = psutil.Process(pid)
            cmdline = process.cmdline
            if len(cmdline) > 1 and re.search('evince_sync\.py$', cmdline[1]):
                os.kill(pid, signal.SIGTERM)
        except psutil.error.NoSuchProcess:
            pass
        except psutil.error.AccessDenied:
            pass
except ImportError:
    vim.command("echomsg '[ATP:] Import error. You will have to kill evince_sync.py script yourself'")
EOF
endfunction
if has("unix")
    augroup ATP_Evince_Sync
        au!
        au VimLeave * :call <SID>Kill_Evince_Sync()
    augroup END
endif

" }}}
""
" }}}

" These are functions which toggles some of the options:
"{{{ Toggle Functions
if !s:did_options || g:atp_reload_functions
" {{{ ATP_ToggleAuTeX
" command! -buffer -count=1 TEX	:call TEX(<count>)		 
function! ATP_ToggleAuTeX(...)
    if a:0 && ( a:1 == 2 || a:1 == "local" )
	let b:atp_autex=2
	echo "[ATP:] LOCAL"
	silent! aunmenu Latex.Toggle\ AuTeX\ [off]
	silent! aunmenu Latex.Toggle\ AuTeX\ [on]
	silent! aunmenu Latex.Toggle\ AuTeX\ [local]
	menu 550.75 &Latex.&Toggle\ AuTeX\ [local]<Tab>b:atp_autex	:<C-U>ToggleAuTeX<CR>
	cmenu 550.75 &Latex.&Toggle\ AuTeX\ [local]<Tab>b:atp_autex	<C-U>ToggleAuTeX<CR>
	imenu 550.75 &Latex.&Toggle\ AuTeX\ [local]<Tab>b:atp_autex	<ESC>:ToggleAuTeX<CR>a
	return
    endif
    let on = ( a:0 ? ( a:1 == 'on' ? 1 : 0 ) : !b:atp_autex )
    if on
	let b:atp_autex=1	
	echo "[ATP:] ON"
	silent! aunmenu Latex.Toggle\ AuTeX\ [off]
	silent! aunmenu Latex.Toggle\ AuTeX\ [on]
	silent! aunmenu Latex.Toggle\ AuTeX\ [local]
	menu 550.75 &Latex.&Toggle\ AuTeX\ [on]<Tab>b:atp_autex		:<C-U>ToggleAuTeX<CR>
	cmenu 550.75 &Latex.&Toggle\ AuTeX\ [on]<Tab>b:atp_autex	<C-U>ToggleAuTeX<CR>
	imenu 550.75 &Latex.&Toggle\ AuTeX\ [on]<Tab>b:atp_autex	<ESC>:ToggleAuTeX<CR>a
    else
	let b:atp_autex=0
	silent! aunmenu Latex.Toggle\ AuTeX\ [off]
	silent! aunmenu Latex.Toggle\ AuTeX\ [on]
	silent! aunmenu Latex.Toggle\ AuTeX\ [local]
	menu 550.75 &Latex.&Toggle\ AuTeX\ [off]<Tab>b:atp_autex	:<C-U>ToggleAuTeX<CR>
	cmenu 550.75 &Latex.&Toggle\ AuTeX\ [off]<Tab>b:atp_autex	<C-U>ToggleAuTeX<CR>
	imenu 550.75 &Latex.&Toggle\ AuTeX\ [off]<Tab>b:atp_autex	<ESC>:ToggleAuTeX<CR>a
	echo "[ATP:] OFF"
    endif
endfunction
"}}}
" {{{ ATP_ToggleSpace
" Special Space for Searching 
let s:special_space="[off]"
function! ATP_ToggleSpace(...)
    let on	= ( a:0 >=1 ? ( a:1 == 'on'  ? 1 : 0 ) : !g:atp_cmap_space )
    if on
	if mapcheck("<space>", 'c') == ""
	    if &cpoptions =~# 'B'
		cmap <buffer> <expr> <space> 	( g:atp_cmap_space && getcmdtype() =~ '[\/?]' ? '\_s\+' : ' ' )
	    else
		cmap <buffer> <expr> <space> 	( g:atp_cmap_space && getcmdtype() =~ '[\\/?]' ? '\\_s\\+' : ' ' )
	    endif
	endif
	let g:atp_cmap_space=1
	let s:special_space="[on]"
	silent! aunmenu Latex.Toggle\ Space\ [off]
	silent! aunmenu Latex.Toggle\ Space\ [on]
	menu 550.78 &Latex.&Toggle\ Space\ [on]<Tab>cmap\ <space>\ \\_s\\+	:<C-U>ToggleSpace<CR>
	cmenu 550.78 &Latex.&Toggle\ Space\ [on]<Tab>cmap\ <space>\ \\_s\\+	<C-U>ToggleSpace<CR>
	imenu 550.78 &Latex.&Toggle\ Space\ [on]<Tab>cmap\ <space>\ \\_s\\+	<Esc>:ToggleSpace<CR>a
	tmenu &Latex.&Toggle\ Space\ [on] cmap <space> \_s\+ is curently on
	redraw
	let msg = "[ATP:] special space is on"
    else
	let g:atp_cmap_space=0
	let s:special_space="[off]"
	silent! aunmenu Latex.Toggle\ Space\ [on]
	silent! aunmenu Latex.Toggle\ Space\ [off]
	menu 550.78 &Latex.&Toggle\ Space\ [off]<Tab>cmap\ <space>\ \\_s\\+	:<C-U>ToggleSpace<CR>
	cmenu 550.78 &Latex.&Toggle\ Space\ [off]<Tab>cmap\ <space>\ \\_s\\+	<C-U>ToggleSpace<CR>
	imenu 550.78 &Latex.&Toggle\ Space\ [off]<Tab>cmap\ <space>\ \\_s\\+	<Esc>:ToggleSpace<CR>a
	tmenu &Latex.&Toggle\ Space\ [off] cmap <space> \_s\+ is curently off
	redraw
	let msg = "[ATP:] special space is off"
    endif
    return msg
endfunction
" nnoremap <buffer> <silent> <Plug>ToggleSpace	:call ATP_ToggleSpace() 
" cnoremap <buffer> <Plug>ToggleSpace	:call ATP_ToggleSpace() 
function! ATP_CmdwinToggleSpace(on)
    let on		= ( a:0 >=1 ? ( a:1 == 'on'  ? 1 : 0 ) : maparg('<space>', 'i') == "" )
    if on
	echomsg "space ON"
	let backslash 	= ( &l:cpoptions =~# "B" ? "\\" : "\\\\\\" ) 
	exe "imap <space> ".backslash."_s".backslash."+"
    else
	echomsg "space OFF"
	iunmap <space>
    endif
endfunction
"}}}
" {{{ ATP_ToggleCheckMathOpened
" This function toggles if ATP is checking if editing a math mode.
" This is used by insert completion.
" ToDo: to doc.
function! ATP_ToggleCheckMathOpened(...)
    let on	= ( a:0 >=1 ? ( a:1 == 'on'  ? 1 : 0 ) :  !g:atp_MathOpened )
"     if g:atp_MathOpened
    if !on
	let g:atp_MathOpened = 0
	echomsg "[ATP:] check if in math environment is off"
	silent! aunmenu Latex.Toggle\ Check\ if\ in\ Math\ [on]
	silent! aunmenu Latex.Toggle\ Check\ if\ in\ Math\ [off]
	menu 550.79 &Latex.Toggle\ &Check\ if\ in\ Math\ [off]<Tab>g:atp_MathOpened			
		    \ :<C-U>ToggleCheckMathOpened<CR>
	cmenu 550.79 &Latex.Toggle\ &Check\ if\ in\ Math\ [off]<Tab>g:atp_MathOpened			
		    \ <C-U>ToggleCheckMathOpened<CR>
	imenu 550.79 &Latex.Toggle\ &Check\ if\ in\ Math\ [off]<Tab>g:atp_MathOpened			
		    \ <Esc>:ToggleCheckMathOpened<CR>a
    else
	let g:atp_MathOpened = 1
	echomsg "[ATP:] check if in math environment is on"
	silent! aunmenu Latex.Toggle\ Check\ if\ in\ Math\ [off]
	silent! aunmenu Latex.Toggle\ Check\ if\ in\ Math\ [off]
	menu 550.79 &Latex.Toggle\ &Check\ if\ in\ Math\ [on]<Tab>g:atp_MathOpened
		    \ :<C-U>ToggleCheckMathOpened<CR>
	cmenu 550.79 &Latex.Toggle\ &Check\ if\ in\ Math\ [on]<Tab>g:atp_MathOpened
		    \ <C-U>ToggleCheckMathOpened<CR>
	imenu 550.79 &Latex.Toggle\ &Check\ if\ in\ Math\ [on]<Tab>g:atp_MathOpened
		    \ <Esc>:ToggleCheckMathOpened<CR>a
    endif
endfunction
"}}}
" {{{ ATP_ToggleCallBack
function! ATP_ToggleCallBack(...)
    let on	= ( a:0 >=1 ? ( a:1 == 'on'  ? 1 : 0 ) :  !g:atp_callback )
    if !on
	let g:atp_callback	= 0
	echomsg "[ATP:] call back is off"
	silent! aunmenu Latex.Toggle\ Call\ Back\ [on]
	silent! aunmenu Latex.Toggle\ Call\ Back\ [off]
	menu 550.80 &Latex.Toggle\ &Call\ Back\ [off]<Tab>g:atp_callback	
		    \ :<C-U>call ToggleCallBack()<CR>
	cmenu 550.80 &Latex.Toggle\ &Call\ Back\ [off]<Tab>g:atp_callback	
		    \ <C-U>call ToggleCallBack()<CR>
	imenu 550.80 &Latex.Toggle\ &Call\ Back\ [off]<Tab>g:atp_callback	
		    \ <Esc>:call ToggleCallBack()<CR>a
    else
	let g:atp_callback	= 1
	echomsg "[ATP:] call back is on"
	silent! aunmenu Latex.Toggle\ Call\ Back\ [on]
	silent! aunmenu Latex.Toggle\ Call\ Back\ [off]
	menu 550.80 &Latex.Toggle\ &Call\ Back\ [on]<Tab>g:atp_callback
		    \ :call ToggleCallBack()<CR>
	cmenu 550.80 &Latex.Toggle\ &Call\ Back\ [on]<Tab>g:atp_callback
		    \ <C-U>call ToggleCallBack()<CR>
	imenu 550.80 &Latex.Toggle\ &Call\ Back\ [on]<Tab>g:atp_callback
		    \ <Esc>:call ToggleCallBack()<CR>a
    endif
endfunction
"}}}
" {{{ ATP_ToggleDebugMode
" ToDo: to doc.
" TODO: it would be nice to have this command (and the map) in quickflist (FileType qf)
" describe DEBUG MODE in doc properly.
function! ATP_ToggleDebugMode(mode,...)
    if a:mode != ""
	let set_new 		= 1
	let new_debugmode 	= ( t:atp_DebugMode ==# a:mode ? g:atp_DefaultDebugMode : a:mode )
	let copen 		= ( a:mode =~? '^d\%[ebug]' && t:atp_DebugMode !=? 'debug' && !t:atp_QuickFixOpen )
	let on 			= ( a:mode !=# t:atp_DebugMode )
	if t:atp_DebugMode ==# 'Debug' && a:mode ==# 'debug' || t:atp_DebugMode ==# 'debug' && a:mode ==# 'Debug'
	    let change_menu 	= 0
	else
	    let change_menu 	= 1
	endif
    else
	let change_menu 	= 1
	let new_debugmode	= ""
	if a:0 >= 1 && a:1 =~ '^on\|off$'
	    let [ on, new_debugmode ]	= ( a:1 == 'on'  ? [ 1, 'debug' ] : [0, g:atp_DefaultDebugMode] )
	    let set_new=1
	    let copen = 1
	elseif a:0 >= 1
	    let t:atp_DebugMode	= a:1
	    let new_debugmode 	= a:1
	    let set_new		= 0
	    if a:1 =~ 's\%[ilent]'
		let on		= 0
		let copen		= 0
	    elseif a:1 =~ '^d\%[ebug]'
		let on		= 1 
		let copen		= ( a:1 =~# '^D\%[ebug]' ? 1 : 0 )
	    else
		" for verbose mode
		let on		= 0
		let copen		= 0
	    endif
	else
	    let set_new = 1
	    let [ on, new_debugmode ] = ( t:atp_DebugMode =~? '^\%(debug\|verbose\)$' ? [ 0, g:atp_DefaultDebugMode ] : [ 1, 'debug' ] )
	    let copen 		= 1
	endif
    endif

"     let g:on = on
"     let g:set_new = set_new
"     let g:new_debugmode = new_debugmode
"     let g:copen = copen
"     let g:change_menu = change_menu

    " on == 0 set debug off
    " on == 1 set debug on
    if !on
	echomsg "[ATP debug mode:] ".new_debugmode

	if change_menu
	    silent! aunmenu 550.20.5 Latex.Log.Toggle\ &Debug\ Mode\ [on]
	    silent! aunmenu 550.20.5 Latex.Log.Toggle\ &Debug\ Mode\ [off]
	    menu 550.20.5 &Latex.&Log.Toggle\ &Debug\ Mode\ [off]<Tab>ToggleDebugMode
			\ :<C-U>ToggleDebugMode<CR>
	    cmenu 550.20.5 &Latex.&Log.Toggle\ &Debug\ Mode\ [off]<Tab>ToggleDebugMode
			\ <C-U>ToggleDebugMode<CR>
	    imenu 550.20.5 &Latex.&Log.Toggle\ &Debug\ Mode\ [off]<Tab>ToggleDebugMode
			\ <Esc>:ToggleDebugMode<CR>a

	    silent! aunmenu Latex.Toggle\ Call\ Back\ [on]
	    silent! aunmenu Latex.Toggle\ Call\ Back\ [off]
	    menu 550.80 &Latex.Toggle\ &Call\ Back\ [off]<Tab>g:atp_callback	
			\ :<C-U>ToggleDebugMode<CR>
	    cmenu 550.80 &Latex.Toggle\ &Call\ Back\ [off]<Tab>g:atp_callback	
			\ <C-U>ToggleDebugMode<CR>
	    imenu 550.80 &Latex.Toggle\ &Call\ Back\ [off]<Tab>g:atp_callback	
			\ <Esc>:ToggleDebugMode<CR>a
	endif

	if set_new
	    let t:atp_DebugMode	= new_debugmode
	endif
	silent cclose
    else
	echomsg "[ATP debug mode:] ".new_debugmode

	if change_menu
	    silent! aunmenu 550.20.5 Latex.Log.Toggle\ Debug\ Mode\ [off]
	    silent! aunmenu 550.20.5 Latex.Log.Toggle\ &Debug\ Mode\ [on]
	    menu 550.20.5 &Latex.&Log.Toggle\ &Debug\ Mode\ [on]<Tab>ToggleDebugMode
			\ :<C-U>ToggleDebugMode<CR>
	    cmenu 550.20.5 &Latex.&Log.Toggle\ &Debug\ Mode\ [on]<Tab>ToggleDebugMode
			\ <C-U>ToggleDebugMode<CR>
	    imenu 550.20.5 &Latex.&Log.Toggle\ &Debug\ Mode\ [on]<Tab>ToggleDebugMode
			\ <Esc>:ToggleDebugMode<CR>a

	    silent! aunmenu Latex.Toggle\ Call\ Back\ [on]
	    silent! aunmenu Latex.Toggle\ Call\ Back\ [off]
	    menu 550.80 &Latex.Toggle\ &Call\ Back\ [on]<Tab>g:atp_callback	
			\ :<C-U>ToggleDebugMode<CR>
	    cmenu 550.80 &Latex.Toggle\ &Call\ Back\ [on]<Tab>g:atp_callback	
			\ <C-U>ToggleDebugMode<CR>
	    imenu 550.80 &Latex.Toggle\ &Call\ Back\ [on]<Tab>g:atp_callback	
			\ <Esc>:ToggleDebugMode<CR>a
	endif

	let g:atp_callback	= 1
	if set_new
	    let t:atp_DebugMode	= new_debugmode
	endif
	let winnr = bufwinnr("%")
	if copen
	    let efm=b:atp_ErrorFormat
	    exe "ErrorFormat ".efm
	    silent! cg
	    if len(getqflist()) > 0
		exe "silent copen ".min([atplib#qflength(), g:atp_DebugModeQuickFixHeight])
		exe winnr . " wincmd w"
	    else
		echo "[ATP:] no errors for b:atp_ErrorFormat=".efm
	    endif
	endif
    endif
endfunction
function! ToggleDebugModeCompl(A,B,C)
    return "silent\ndebug\nDebug\nverbose\non\noff"
endfunction
augroup ATP_DebugModeCommandsAndMaps
    au!
    au FileType qf command! -buffer ToggleDebugMode 	:call <SID>ToggleDebugMode()
    au FileType qf nnoremap <silent> <LocalLeader>D		:ToggleDebugMode<CR>
augroup END
" }}}
" {{{ ATP_ToggleTab
" switches on/off the <Tab> map for TabCompletion
function! ATP_ToggleTab(...)
    if mapcheck('<F7>','i') !~ 'atplib#complete#TabCompletion'
	let on	= ( a:0 >=1 ? ( a:1 == 'on'  ? 1 : 0 ) : mapcheck('<Tab>','i') !~# 'atplib#complete#TabCompletion' )
	if !on 
	    iunmap <buffer> <Tab>
	    echo '[ATP:] <Tab> map OFF'
	else
	    imap <buffer> <Tab> <C-R>=atplib#complete#TabCompletion(1)<CR>
	    echo '[ATP:] <Tab> map ON'
	endif
    endif
endfunction
" }}}
" {{{ ATP_ToggleIMaps
" switches on/off the imaps g:atp_imap_math, g:atp_imap_math_misc and
" g:atp_imap_diacritics
function! ATP_ToggleIMaps(insert_enter, bang,...)
    let on	= ( a:0 >=1 ? ( a:1 == 'on'  ? 1 : 0 ) : g:atp_imap_define_math <= 0 || g:atp_imap_define_math_misc <= 0 )
    if on == 0
	let g:atp_imap_define_math = ( a:bang == "!" ? -1 : 0 ) 
	call atplib#DelMaps(g:atp_imap_math)
	let g:atp_imap_define_math_misc = ( a:bang == "!" ? -1 : 0 )
	call atplib#DelMaps(g:atp_imap_math_misc)
	let g:atp_imap_define_diacritics = ( a:bang == "!" ? -1 : 0 ) 
	call atplib#DelMaps(g:atp_imap_diacritics)
	echo '[ATP:] imaps OFF '.(a:bang == "" ? '(insert)' : '')
    else
	let g:atp_imap_define_math =1
	let g:atp_imap_define_math_misc = 1
	let g:atp_imap_define_diacritics = 1
	if atplib#IsInMath()
	    call atplib#MakeMaps(g:atp_imap_math)
	    call atplib#MakeMaps(g:atp_imap_math_misc)
	else
	    call atplib#MakeMaps(g:atp_imap_diacritics)
	endif
	echo '[ATP:] imaps ON'
    endif
" Setting eventignore is not a good idea 
" (this might break specific user settings)
"     if a:insert_enter
" 	let g:atp_eventignore=&l:eventignore
" 	let g:atp_eventignoreInsertEnter=1
" 	set eventignore+=InsertEnter
" " 	" This doesn't work because startinsert runs after function ends.
"     endif
endfunction
" }}}
endif
" }}}
 
" Some Commands And Maps:
"{{{
command! -buffer ToggleSpace	:call <SID>ToggleSpace()
command! -buffer -nargs=? -complete=customlist,atplib#OnOffComp	ToggleIMaps	 	:call ATP_ToggleIMaps(0, "!", <f-args>)
nnoremap <silent> <buffer> 	<Plug>ToggleIMaps		:call ATP_ToggleIMaps(0, "!")<CR>
inoremap <silent> <buffer> 	<Plug>ToggleIMaps		<C-O>:call ATP_ToggleIMaps(0, "!")<CR>
" inoremap <silent> <buffer> 	<Plug>ToggleIMaps		<Esc>:call ATP_ToggleIMaps(1, "")<CR>

command! -buffer -nargs=? -complete=customlist,atplib#OnOffLocalComp ToggleAuTeX 	:call ATP_ToggleAuTeX(<f-args>)
nnoremap <silent> <buffer> 	<Plug>ToggleAuTeX 		:call ATP_ToggleAuTeX()<CR>

command! -buffer -nargs=? -complete=customlist,atplib#OnOffComp ToggleSpace 	:echo ATP_ToggleSpace(<f-args>)
nnoremap <silent> <buffer> 	<Plug>ToggleSpace 		:echo ATP_ToggleSpace()<CR>
nnoremap <silent> <buffer> 	<Plug>ToggleSpaceOn 		:echo ATP_ToggleSpace('on')<CR>
nnoremap <silent> <buffer> 	<Plug>ToggleSpaceOff 		:echo ATP_ToggleSpace('off')<CR>

command! -buffer -nargs=? -complete=customlist,atplib#OnOffComp	ToggleCheckMathOpened 	:call ATP_ToggleCheckMathOpened(<f-args>)
nnoremap <silent> <buffer> 	<Plug>ToggleCheckMathOpened	:call ATP_ToggleCheckMathOpened()<CR>

command! -buffer -nargs=? -complete=customlist,atplib#OnOffComp	ToggleCallBack 		:call ATP_ToggleCallBack(<f-args>)
nnoremap <silent> <buffer> 	<Plug>ToggleCallBack		:call ATP_ToggleCallBack()<CR>

command! -buffer -nargs=? -complete=custom,ToggleDebugModeCompl	ToggleDebugMode 	:call ATP_ToggleDebugMode("",<f-args>)
nnoremap <silent> <buffer> 	<Plug>TogglesilentMode		:call ATP_ToggleDebugMode("silent")<CR>
nnoremap <silent> <buffer> 	<Plug>ToggledebugMode		:call ATP_ToggleDebugMode("debug")<CR>
nnoremap <silent> <buffer> 	<Plug>ToggleDebugMode		:call ATP_ToggleDebugMode("Debug")<CR>

if g:atp_tab_map
    command! -buffer -nargs=? -complete=customlist,atplib#OnOffComp	ToggleTab	 	:call ATP_ToggleTab(<f-args>)
endif
nnoremap <silent> <buffer> 	<Plug>ToggleTab		:call ATP_ToggleTab()<CR>
inoremap <silent> <buffer> 	<Plug>ToggleTab		<C-O>:call ATP_ToggleTab()<CR>
"}}}


" AUTOCOMMANDS:
" Some of the autocommands (Status Line, LocalCommands, Log File):
" {{{1 Autocommands:

if !s:did_options
    

    " {{{2 SwapExists (not used)
    let g:atp_DoSwapExists = 0
    fun! <SID>SwapExists(swapfile)
	if g:atp_DoSwapExists
	    let v:swapchoice = 'a'
	    echoerr "[ATP:] swap exist for file ".a:swapfile
	else
	    let v:swapchoice = ''
	endif
    endfun

    " augroup ATP_SwapExists
	" au!
	" au SwapExists	:call <SID>SwapExists(v:swapname)
    " augroup END

    augroup ATP_changedtick " {{{2
	au!
	au BufEnter,BufWritePost 	*.tex 	:let b:atp_changedtick = b:changedtick
    augroup END 

    augroup ATP_auTeX " {{{2
	au!
	au CursorHold 	*.tex call atplib#compiler#auTeX()
	au CursorHoldI 	*.tex call atplib#compiler#auTeX()
    augroup END 
    " {{{2 Setting ErrorFormat
    " Is done using autocommands, if the opened file belongs to the same
    " project as the previous file, then just copy the variables
    " b:atp_ErrorFormat, other wise read the error file and set error format
    " to g:atp_DefaultErrorFormat (done with
    " atplib#compiler#SetErrorFormat()).
    "
    " For sty and cls files, always pretend they belong to the same project.
    function! ATP_BufLeave()
	let s:error_format = ( exists("b:atp_ErrorFormat") ? b:atp_ErrorFormat : 'no_error_format' )
	let s:ef = &l:ef
	" echomsg "PFILE ".s:previous_file." EFM ".s:error_format
    endfunction
    let s:error_format = ( exists("b:atp_ErrorFormat") ? b:atp_ErrorFormat : 'no_error_format' )
    let s:ef = &l:ef
    function! <SID>BufEnter()
	if !( &l:filetype == 'tex' || &l:ef == s:ef  )
	    " buftype option is not yet set when this function is executed,
	    " but errorfile option is already set.
	    return
	endif
	if exists("s:ef")
	    let same_project= ( &l:ef == s:ef )
	    if !same_project
		" other project:
		let errorflags = exists("b:atp_ErrorFormat") ? b:atp_ErrorFormat : g:atp_DefaultErrorFormat
		call atplib#compiler#SetErrorFormat(1, errorflags)
	    else
		" the same project:
		if s:error_format != 'no_error_format'
		    call atplib#compiler#SetErrorFormat(0, s:error_format)
		else
		    call atplib#compiler#SetErrorFormat(0, g:atp_DefaultErrorFormat)
		endif
	    endif
	else
	    " init:
	    call atplib#compiler#SetErrorFormat(1, g:atp_DefaultErrorFormat)
	endif
    endfunction

    " This augroup sets the efm on startup:
    augroup ATP_ErrorFormat
	au!
	au BufLeave * :call ATP_BufLeave()
	au BufEnter * :call <SID>BufEnter()
    augroup END
    "}}}2

    augroup ATP_UpdateToCLine " {{{2
	au!
	au CursorHold *.tex nested :call atplib#motion#UpdateToCLine()
    augroup END

    " Redraw ToC {{{2
    function! RedrawToC()
	if bufwinnr(bufnr("__ToC__")) != -1
	    let winnr = winnr()
	    Toc
	    exe winnr." wincmd w"
	endif
    endfunction

    augroup ATP_TOC_tab
	au!
	au TabEnter *.tex	:call RedrawToC()
    augroup END

    " InsertLeave_InsertEnter {{{2
    let g:atp_eventignore		= &l:eventignore
    let g:atp_eventignoreInsertEnter 	= 0
    function! <SID>InsertLeave_InsertEnter()
	if g:atp_eventignoreInsertEnter
	    setl eventignore-=g:atp_eventignore
	endif
    endfunction
    augroup ATP_InsertLeave_eventignore
	" ToggleMathIMaps
	au!
	au InsertLeave *.tex 	:call <SID>InsertLeave_InsertEnter()
    augroup END

    " augroup ATP_Cmdwin " {{{2
	" au!
	" au CmdwinLeave / if expand("<afile>") == "/"|:call ATP_CmdwinToggleSpace(0)|:endif
	" au CmdwinLeave ? if expand("<afile>") == "/"|:call ATP_CmdwinToggleSpace(0)|:endif
    " augroup END

    augroup ATP_cmdheight " {{{2
	" update g:atp_cmdheight when user writes the buffer
	au!
	au BufWrite *.tex :let g:atp_cmdheight = &l:cmdheight
    augroup END

    function! <SID>Rmdir(dir) "{{{2
    if executable("rmdir")
	call system("rmdir ".shellescape(a:dir))
    elseif has("python")
python << EOF
import os, errno
dir=vim.eval('a:dir')
try:
    os.rmdir(dir)
except OSError, e:
    if errno.errorcode[e.errno] == 'ENOENT':
        pass
EOF
    else
	echohl ErrorMsg
	echo "[ATP:] the directory ".a:dir." is not removed."
	echohl None
    endif
    endfunction "}}}2
    function! ErrorMsg(type) "{{{2
	let errors		= len(filter(getqflist(),"v:val['type']==a:type"))
	if errors > 1
	    let type		= (a:type == 'E' ? 'errors' : 'warnings')
	else
	    let type		= (a:type == 'E' ? 'error' : 'warning')
	endif
	let msg			= ""
	if errors
	    let msg.=" ".errors." ".type
	endif
	return msg
    endfunction " }}}2
    augroup ATP_QuickFix_2 " {{{2
	au!
	au FileType qf command! -bang -buffer -nargs=? -complete=custom,DebugComp DebugMode	:call <SID>SetDebugMode(<q-bang>,<f-args>)
	au FileType qf let w:atp_qf_errorfile=&l:errorfile
	au FileType qf setl statusline=%{w:atp_qf_errorfile}%=\ %#WarningMsg#%{ErrorMsg('W')}\ %{ErrorMsg('E')}
	au FileType qf exe "resize ".min([atplib#qflength(), g:atp_DebugModeQuickFixHeight])
    augroup END

    function! <SID>BufEnterCgetfile() "{{{2
	if !exists("b:atp_ErrorFormat")
	    return
	endif
	" Do not execute :cgetfile if we are moving out of a quickfix buffer,
	" or switching between project files unless b:atp_autex == 2.
	if exists("s:leaving_buffer") && 
		    \ ( s:leaving_buffer == 'quickfix'
		    \ ||(exists("b:ListOfFiles") && index(map(b:ListOfFiles, 'atplib#FullPath(v:val)'), s:leaving_buffer) != -1 ||
		    \ exists("b:atp_MainFile") && atplib#FullPath(b:atp_MainFile) == s:leaving_buffer ) &&
		    \ exists("b:atp_autex") && b:atp_autex < 2
		    \ )
	    unlet s:leaving_buffer
	    return
	endif
	if g:atp_cgetfile 
	    try
		" This command executes cgetfile:
		exe "ErrorFormat ".b:atp_ErrorFormat
	    catch /E40:/ 
	    endtry
	endif
    endfunction " }}}2
    function! <SID>BufLeave() " {{{2
	if &buftype == 'quickfix'
	    let s:leaving_buffer='quickfix'
	else
	    let s:leaving_buffer=expand("%:p")
	endif
    endfunction "}}}2
    " {{{2
    if (v:version < 703 || v:version == 703 && !has("patch468"))
	augroup ATP_QuickFix_cgetfile
	" When using cgetfile the position in quickfix-window is lost, which is
	" annoying when changing windows. 
	    au!
	    au BufLeave *		:call <SID>BufLeave()
	    au BufEnter *.tex 	:call <SID>BufEnterCgetfile()
	augroup END
    else
	function! <SID>Latex_Log() " {{{3
	    if exists("b:atp_MainFile")
		let log_file  = fnamemodify(atplib#FullPath(b:atp_MainFile), ":r").".log"
		let _log_file = fnamemodify(atplib#FullPath(b:atp_MainFile), ":r")."._log"
		if !filereadable(log_file)
		    return
		endif
		" Run latex_log.py only if log_file is newer than _log_file. 
		" This is only if the user run latex manualy, since ATP calles
		" latex_log.py after compilation.
		if !filereadable(_log_file) || !exists("*getftime") || getftime(log_file) > getftime(_log_file)
		    call system("python ".shellescape(split(globpath(&rtp, "ftplugin/ATP_files/latex_log.py"), "\n")[0])." ".shellescape(fnamemodify(atplib#FullPath(b:atp_MainFile), ":r").".log"))
		endif
	    endif
	endfunction " }}}3
	augroup ATP_QuickFix_cgetfile
	    au QuickFixCmdPre cgetfile,cfile,cfileadd 	:call <SID>Latex_Log()
	    au QuickFixCmdPost cgetfile,cfile,cfileadd 	:call atplib#compiler#FilterQuickFix()
	augroup END
    endif 

    augroup ATP_VimLeave " {{{2
	au!
	" Remove b:atp_TempDir (where compilation is done).
	au VimLeave *.tex :call <SID>Rmdir(b:atp_TempDir)
	" Remove TempDir for debug files.
	au VimLeave *     :call <SID>RmTempDir()
	" :Kill! (i.e. silently if there is no python support.)
	au VimLeave *.tex :Kill!
    augroup END

    " UpdateTime {{{2
    function! <SID>UpdateTime(enter)
	if a:enter	== "Enter" && b:atp_updatetime_insert != 0
	    let &l:updatetime	= b:atp_updatetime_insert
	elseif a:enter 	== "Leave" && b:atp_updatetime_normal != 0
	    let &l:updatetime	= b:atp_updatetime_normal
	endif
    endfunction

    augroup ATP_UpdateTime
	au!
	au InsertEnter *.tex :call <SID>UpdateTime("Enter")
	au InsertLeave *.tex :call <SID>UpdateTime("Leave")
    augroup END

    augroup ATP_TeXFlavor " {{{2
	au!
	au FileType *tex 	let b:atp_TexFlavor = &filetype
    augroup END "}}}2

    " Idea:
    " au 		*.log if LogBufferFileDiffer | silent execute '%g/^\s*$/d' | w! | endif
    " or maybe it is better to do that after latex made the log file in the call back
    " function, but this adds something to every compilation process !
    " This changes the cursor position in the log file which is NOT GOOD.
"     au WinEnter	*.log	execute "normal m'" | silent execute '%g/^\s*$/d' | execute "normal ''"

    " Experimental:
	" This doesn't work !
" 	    fun! GetSynStackI()
" 		let synstack=[]
" 		let synstackI=synstack(line("."), col("."))
" 		try 
" 		    let test =  synstackI == 0
" 		    let b:return 	= 1
" 		    catch /Can only compare List with List/
" 		    let b:return	= 0
" 		endtry
" 		if b:return == 0
" 		    return []
" 		else
" 		    return map(synstack, "synIDattr(v:val, 'name')")
" 		endif
" 	    endfunction

    " The first one is not working! (which is the more important of these two :(
"     au CursorMovedI *.tex let g:atp_synstackI	= GetSynStackI()
    " This has problems in visual mode:
"     au CursorMoved  *.tex let g:atp_synstack	= map(synstack(line('.'), col('.')), "synIDattr(v:val, 'name')")
    
endif

    " Quit {{{2
    if exists('##QuitPre')
	fun! <sid>ATP_Quit(cmd) 
	    let blist = tabpagebuflist()
	    let cbufnr = bufnr("%")
	    if index(['__ToC__', '__Labels__'],bufname(cbufnr)) == -1
		call remove(blist, index(blist, cbufnr))
	    endif
	    let bdict = {}
	    for buf in blist
		let bdict[buf]=bufname(buf)
	    endfor
	    let l=0
	    let l+= (index(values(bdict), '__ToC__') != -1)
	    let l+= (index(values(bdict), '__Labels__') != -1)
	    call filter(bdict, 'bdict[v:key] == "__ToC__" || bdict[v:key] == "__Labels__"')
	    if !empty(bdict)
		for i in keys(bdict)
		    if a:cmd == 'quit'
			quit
		    else
			exe a:cmd i
		    endif
		endfor
	    endif
	endfun
	augroup ATP_Quit
	    au!
	    au QuitPre * :call <sid>ATP_Quit('quit')
	    au BufUnload * :call <sid>ATP_Quit('bw')
	augroup END
    endif
" }}}1

" This function and the following autocommand toggles the textwidth option if
" editing a math mode. Currently, supported are $:$, \(:\), \[:\] and $$:$$.
" {{{  SetMathVimOptions

if !exists("g:atp_SetMathVimOptions")
    let g:atp_SetMathVimOptions 	= 1
endif

if !exists("g:atp_MathVimOptions")
"     { 'option_name' : [ val_in_math, normal_val], ... }
    let g:atp_MathVimOptions		= {}
endif

if !exists("g:atp_MathZones")
let g:atp_MathZones	= ( &l:filetype == "tex" ? [ 
	    		\ 'texMathZoneV', 	'texMathZoneW', 
	    		\ 'texMathZoneX', 	'texMathZoneY',
	    		\ 'texMathZoneA', 	'texMathZoneAS',
	    		\ 'texMathZoneB', 	'texMathZoneBS',
	    		\ 'texMathZoneC', 	'texMathZoneCS',
	    		\ 'texMathZoneD', 	'texMathZoneDS',
	    		\ 'texMathZoneE', 	'texMathZoneES',
	    		\ 'texMathZoneF', 	'texMathZoneFS',
	    		\ 'texMathZoneG', 	'texMathZoneGS',
	    		\ 'texMathZoneH', 	'texMathZoneHS',
	    		\ 'texMathZoneI', 	'texMathZoneIS',
	    		\ 'texMathZoneJ', 	'texMathZoneJS',
	    		\ 'texMathZoneK', 	'texMathZoneKS',
	    		\ 'texMathZoneL', 	'texMathZoneLS',
			\ 'texMathZoneT'
			\ ]
			\ : [ 'plaintexMath' ] )
endif

" a:0 	= 0 check if in math mode
" a:1   = 0 assume cursor is not in math
" a:1	= 1 assume cursor stands in math  
function! SetMathVimOptions(event,...)

	if !g:atp_SetMathVimOptions || len(keys(g:atp_MathVimOptions)) == 0
	    return "no setting to toggle" 
	endif

	let MathZones = copy(g:atp_MathZones)
	    
	" Change the long values to numbers 
	let MathVimOptions = map(copy(g:atp_MathVimOptions),
			\ " v:val[0] =~ v:key ? [ v:val[0] =~ '^no' . v:key ? 0 : 1, v:val[1] ] : v:val " )
	let MathVimOptions = map(MathVimOptions,
			\ " v:val[1] =~ v:key ? [ v:val[0], v:val[1] =~ '^no' . v:key ? 0 : 1 ] : v:val " )

	" check if the current (and 3 steps back) cursor position is in math
	" or use a:1
" 	let check	= a:0 == 0 ? atplib#complete#CheckSyntaxGroups(MathZones) + atplib#complete#CheckSyntaxGroups(MathZones, line("."), max([ 1, col(".")-3])) : a:1
	let check	= a:0 == 0 ? atplib#IsInMath() : a:1

	let when = -1
	if a:event == 'InsertEnter' && check
	    let when = 0
	    for option_name in keys(MathVimOptions)
		execute "let &l:".option_name. " = " . MathVimOptions[option_name][0]
	    endfor
	elseif a:event == 'CursorMovedI'
	    if check
		let when = 1
		for option_name in keys(MathVimOptions)
		    execute "let &l:".option_name. " = " . MathVimOptions[option_name][0]
		endfor
	    else
		let when = 2
		for option_name in keys(MathVimOptions)
		    execute "let &l:".option_name. " = " . MathVimOptions[option_name][1]
		endfor
	    endif
	else
	    for option_name in keys(MathVimOptions)
                if a:event == 'InsertLeave'
		    let when = 3
                    execute "let &l:".option_name. " = " . MathVimOptions[option_name][1]
                elseif a:event == 'InsertEnter'
		    let when = 4
		    execute "let g:atp_MathVimOptions[option_name][1] = &l:".option_name
                endif
	    endfor
	endif
	if exists("g:debug")
	    call add(g:debug, [a:event, check, when, deepcopy(MathVimOptions)])
	endif
endfunction

if !s:did_options

    augroup ATP_SetMathVimOptions
	au!
	" if leaving the insert mode set the non-math options
	au InsertLeave 	*.tex 	:call SetMathVimOptions('InsertLeave', 0)
	" if entering the insert mode or in the insert mode check if the cursor is in
	" math or not and set the options acrodingly
	au InsertEnter	*.tex 	:call SetMathVimOptions('InsertEnter')
" This is done by atplib#ToggleIMap() function, which is run only when cursor
" enters/leaves LaTeX math mode:
	" au CursorMovedI *.tex 	:call s:SetMathVimOptions('CursorMovedI')
    augroup END

endif
"}}}

" SYNTAX GROUPS:
" {{{1 ATP_SyntaxGroups
function! <SID>ATP_SyntaxGroups()
    if &filetype != "tex" || &syntax != "tex"
	" this is important for :Dsearch window
	return
    endif
    " add texMathZoneT syntax group for tikzpicture environment:
    if atplib#search#SearchPackage('tikz') || atplib#search#SearchPackage('pgfplots')
	" This works with \matrix{} but not with \matrix[matrix of math nodes]
	" It is not working with tikzpicture environment inside mathematics.
	syntax cluster texMathZones add=texMathZoneT
	syntax region texMathZoneT start='\\begin\s*{\s*tikzpicture\s*}' end='\\end\s*{\s*tikzpicture\s*}' keepend containedin=@texMathZoneGroup contains=@texMathZoneGroup,@texMathZones,@NoSpell
	syntax sync match texSyncMathZoneT grouphere texMathZoneT '\\begin\s*{\s*tikzpicture\s*}'
	" The function TexNewMathZone() will mark whole tikzpicture
	" environment as a math environment.  This makes problem when one
	" wants to close \(:\) inside tikzpicture.  
" 	call TexNewMathZone("T", "tikzpicture", 0)
    endif
    " add texMathZoneALG syntax group for algorithmic environment:
    if atplib#search#SearchPackage('algorithmic')
	try
	    call TexNewMathZone("ALG", "algorithmic", 0)
	catch /E117:/ 
	endtry
    endif
endfunction
augroup ATP_SyntaxGroups
    au!
    " This should be run on Syntax, but it needs setting done in FileType
    " (Syntax group runs first).
    au FileType tex :call <SID>ATP_SyntaxGroups()
augroup END

augroup ATP_Devel
    au!
    au BufEnter *.sty	:setl nospell	
    au BufEnter *.cls	:setl nospell
    au BufEnter *.fd	:setl nospell
augroup END
"}}}1
"{{{1 Highlightings in help file
augroup ATP_HelpFile_Highlight
    au!
    au BufEnter automatic-tex-plugin.txt call matchadd(hlexists('atp_FileName') ? "atp_FileName" : "Title",  'highlight atp_FileName\s\+Title')
    au BufEnter automatic-tex-plugin.txt call matchadd(hlexists('atp_LineNr') 	? "atp_LineNr"   : "LineNr", 'highlight atp_LineNr\s\+LineNr')
    au BufEnter automatic-tex-plugin.txt call matchadd(hlexists('atp_Number') 	? "atp_Number"   : "Number", 'highlight atp_Number\s\+Number')
    au BufEnter automatic-tex-plugin.txt call matchadd(hlexists('atp_Chapter') 	? "atp_Chapter"  : "Label",  'highlight atp_Chapter\s\+Label')
    au BufEnter automatic-tex-plugin.txt call matchadd(hlexists('atp_Section') 	? "atp_Section"  : "Label",  'highlight atp_Section\s\+Label')
    au BufEnter automatic-tex-plugin.txt call matchadd(hlexists('atp_SubSection') ? "atp_SubSection": "Label", 'highlight atp_SubSection\s\+Label')
    au BufEnter automatic-tex-plugin.txt call matchadd(hlexists('atp_Abstract')	? "atp_Abstract" : "Label", 'highlight atp_Abstract\s\+Label')

    au BufEnter automatic-tex-plugin.txt call matchadd(hlexists('atp_label_FileName') 	? "atp_label_FileName" 	: "Title",	'^\s*highlight atp_label_FileName\s\+Title\s*$')
    au BufEnter automatic-tex-plugin.txt call matchadd(hlexists('atp_label_LineNr') 	? "atp_label_LineNr" 	: "LineNr",	'^\s*highlight atp_label_LineNr\s\+LineNr\s*$')
    au BufEnter automatic-tex-plugin.txt call matchadd(hlexists('atp_label_Name') 	? "atp_label_Name" 	: "Label",	'^\s*highlight atp_label_Name\s\+Label\s*$')
    au BufEnter automatic-tex-plugin.txt call matchadd(hlexists('atp_label_Counter') 	? "atp_label_Counter" 	: "Keyword",	'^\s*highlight atp_label_Counter\s\+Keyword\s*$')

    au BufEnter automatic-tex-plugin.txt call matchadd(hlexists('bibsearchInfo')	? "bibsearchInfo"	: "Number",	'^\s*highlight bibsearchInfo\s*$')
augroup END
"}}}1

" {{{1 :Viewer, :Compiler, :DebugMode
function! <SID>Viewer(...) 
    if a:0 == 0 || a:1 =~ '^\s*$'
	echomsg "[ATP:] current viewer: ".b:atp_Viewer
	return
    else
	let new_viewer = a:1
    endif
    let old_viewer	= b:atp_Viewer
    let oldViewer	= get(g:ViewerMsg_Dict, matchstr(old_viewer, '^\s*\zs\S*'), "")
    let b:atp_Viewer	= new_viewer
    let Viewer		= get(g:ViewerMsg_Dict, matchstr(b:atp_Viewer, '^\s*\zs\S*'), "")
    silent! execute "aunmenu Latex.View\\ with\\ ".oldViewer
    silent! execute "aunmenu Latex.View\\ Output"
    if Viewer != ""
	execute "menu 550.10 LaTe&X.&View\\ with\\ ".Viewer."<Tab>:View 		:<C-U>View<CR>"
	execute "cmenu 550.10 LaTe&X.&View\\ with\\ ".Viewer."<Tab>:View 		<C-U>View<CR>"
	execute "imenu 550.10 LaTe&X.&View\\ with\\ ".Viewer."<Tab>:View 		<Esc>:View<CR>a"
    else
	execute "menu 550.10 LaTe&X.&View\\ Output\\ <Tab>:View 		:<C-U>View<CR>"
	execute "cmenu 550.10 LaTe&X.&View\\ Output\\ <Tab>:View 		<C-U>View<CR>"
	execute "imenu 550.10 LaTe&X.&View\\ Output\\ <Tab>:View 		<Esc>:View<CR>a"
    endif
endfunction
command! -buffer -nargs=? -complete=customlist,ViewerComp Viewer	:call <SID>Viewer(<q-args>)
function! ViewerComp(A,L,P)
    let view = [ 'open', 'okular', 'xpdf', 'xdvi', 'evince', 'epdfview', 'kpdf', 'acroread', 'zathura', 'gv',
		\  'AcroRd32.exe', 'sumatrapdf.exe' ]
    " The names of Windows programs (second line) might be not right [sumatrapdf.exe (?)].
    call filter(view, "v:val =~ '^' . a:A")
    call filter(view, 'executable(v:val)')
    return view
endfunction

function! <SID>Compiler(...) 
    if a:0 == 0
	echo "[ATP:] b:atp_TexCompiler=".b:atp_TexCompiler
	return
    else
	let compiler		= a:1
	let old_compiler	= b:atp_TexCompiler
	let oldCompiler	= get(g:CompilerMsg_Dict, matchstr(old_compiler, '^\s*\zs\S*'), "")
	let b:atp_TexCompiler	= compiler
	let Compiler		= get(g:CompilerMsg_Dict, matchstr(b:atp_TexCompiler, '^\s*\zs\S*'), "")
	silent! execute "aunmenu Latex.".oldCompiler
	silent! execute "aunmenu Latex.".oldCompiler."\\ debug"
	silent! execute "aunmenu Latex.".oldCompiler."\\ twice"
	execute "menu 550.5 LaTe&X.&".Compiler."<Tab>:TEX				:<C-U>TEX<CR>"
	execute "cmenu 550.5 LaTe&X.&".Compiler."<Tab>:TEX				<C-U>TEX<CR>"
	execute "imenu 550.5 LaTe&X.&".Compiler."<Tab>:TEX				<Esc>:TEX<CR>a"
	execute "menu 550.6 LaTe&X.".Compiler."\\ debug<Tab>:TEX\\ debug		:<C-U>DTEX<CR>"
	execute "cmenu 550.6 LaTe&X.".Compiler."\\ debug<Tab>:TEX\\ debug		<C-U>DTEX<CR>"
	execute "imenu 550.6 LaTe&X.".Compiler."\\ debug<Tab>:TEX\\ debug		<Esc>:DTEX<CR>a"
	execute "menu 550.7 LaTe&X.".Compiler."\\ &twice<Tab>:2TEX			:<C-U>2TEX<CR>"
	execute "cmenu 550.7 LaTe&X.".Compiler."\\ &twice<Tab>:2TEX			<C-U>2TEX<CR>"
	execute "imenu 550.7 LaTe&X.".Compiler."\\ &twice<Tab>:2TEX			<Esc>:2TEX<CR>a"
    endif
endfunction
command! -buffer -nargs=? -complete=customlist,CompilerComp Compiler	:call <SID>Compiler(<f-args>)
function! CompilerComp(A,L,P)
    let compilers = [ 'tex', 'pdftex', 'latex', 'pdflatex', 'etex', 'xetex', 'luatex', 'xelatex' ]
"     let g:compilers = copy(compilers)
    call filter(compilers, "v:val =~ '^' . a:A")
    call filter(compilers, 'executable(v:val)')
    return compilers
endfunction

function! <SID>SetDebugMode(bang,...)
    if a:0 == 0
	echo t:atp_DebugMode
	return
    else
	let match = matchlist(a:1, '^\(auto\)\?\(.*$\)')
	let auto = match[1]
	let mode = match[2]
	if mode =~# '^s\%[silent]'
	    let t:atp_DebugMode= auto.'silent'
	elseif mode =~# '^d\%[debug]'
	    let t:atp_DebugMode= auto.'debug'
	elseif mode =~# '^D\%[debug]'
	    let t:atp_DebugMode= auto.'Debug'
	elseif mode =~# '^v\%[erbose]'
	    let t:atp_DebugMode= auto.'verbose'
	else
	    let t:atp_DebugMode= auto.g:atp_DefaultDebugMode
	endif
    endif

    if t:atp_DebugMode =~# 'Debug$' && a:1 =~# 'debug$' || t:atp_DebugMode =~# 'debug$' && a:1 =~# 'Debug$'
	let change_menu 	= 0
    else
	let change_menu 	= 1
    endif

    "{{{ Change menu
    if change_menu && t:atp_DebugMode !~? 'debug$'
	silent! aunmenu 550.20.5 Latex.Log.Toggle\ &Debug\ Mode\ [on]
	silent! aunmenu 550.20.5 Latex.Log.Toggle\ &Debug\ Mode\ [off]
	menu 550.20.5 &Latex.&Log.Toggle\ &Debug\ Mode\ [off]<Tab>ToggleDebugMode
		    \ :<C-U>ToggleDebugMode<CR>
	cmenu 550.20.5 &Latex.&Log.Toggle\ &Debug\ Mode\ [off]<Tab>ToggleDebugMode
		    \ <C-U>ToggleDebugMode<CR>
	imenu 550.20.5 &Latex.&Log.Toggle\ &Debug\ Mode\ [off]<Tab>ToggleDebugMode
		    \ <Esc>:ToggleDebugMode<CR>a

	silent! aunmenu Latex.Toggle\ Call\ Back\ [on]
	silent! aunmenu Latex.Toggle\ Call\ Back\ [off]
	menu 550.80 &Latex.Toggle\ &Call\ Back\ [off]<Tab>g:atp_callback	
		    \ :<C-U>ToggleDebugMode<CR>
	cmenu 550.80 &Latex.Toggle\ &Call\ Back\ [off]<Tab>g:atp_callback	
		    \ <C-U>ToggleDebugMode<CR>
	imenu 550.80 &Latex.Toggle\ &Call\ Back\ [off]<Tab>g:atp_callback	
		    \ <Esc>:ToggleDebugMode<CR>a
    elseif change_menu
	silent! aunmenu 550.20.5 Latex.Log.Toggle\ Debug\ Mode\ [off]
	silent! aunmenu 550.20.5 Latex.Log.Toggle\ &Debug\ Mode\ [on]
	menu 550.20.5 &Latex.&Log.Toggle\ &Debug\ Mode\ [on]<Tab>ToggleDebugMode
		    \ :<C-U>ToggleDebugMode<CR>
	cmenu 550.20.5 &Latex.&Log.Toggle\ &Debug\ Mode\ [on]<Tab>ToggleDebugMode
		    \ <C-U>ToggleDebugMode<CR>
	imenu 550.20.5 &Latex.&Log.Toggle\ &Debug\ Mode\ [on]<Tab>ToggleDebugMode
		    \ <Esc>:ToggleDebugMode<CR>a

	silent! aunmenu Latex.Toggle\ Call\ Back\ [on]
	silent! aunmenu Latex.Toggle\ Call\ Back\ [off]
	menu 550.80 &Latex.Toggle\ &Call\ Back\ [on]<Tab>g:atp_callback	
		    \ :<C-U>ToggleDebugMode<CR>
	cmenu 550.80 &Latex.Toggle\ &Call\ Back\ [on]<Tab>g:atp_callback	
		    \ <C-U>ToggleDebugMode<CR>
	imenu 550.80 &Latex.Toggle\ &Call\ Back\ [on]<Tab>g:atp_callback	
		    \ <Esc>:ToggleDebugMode<CR>a
    endif "}}}

    if a:1 =~# '\%(auto\)\?s\%[ilent]'
	let winnr=winnr()
	if t:atp_QuickFixOpen
	    cclose
	else
	    try
		cgetfile
		if v:version < 703 || v:version == 703 && !has("path468")
		    call atplib#compiler#FilterQuickFix()
		endif
	    catch /E40/
		echohl WarningMsg 
		echo "[ATP:] log file missing."
		echohl None
	    endtry
	    if a:bang == "!"
		exe "cwindow " . (max([1, min([len(getqflist()), g:atp_DebugModeQuickFixHeight])]))
		exe winnr . "wincmd w"
	    endif
	endif
    elseif a:1 =~# '\%(auto\)\?d\%[ebug]'
	let winnr=winnr()
	exe "copen " . (!exists("w:quickfix_title") 
		    \ ? (max([1, min([atplib#qflength(), g:atp_DebugModeQuickFixHeight])]))
		    \ : "" )
	exe winnr . "wincmd w"
	try
	    cgetfile
	    if v:version < 703 || v:version == 703 && !has("path468")
		call atplib#compiler#FilterQuickFix()
	    endif
	catch /E40/
	    echohl WarningMsg 
	    echo "[ATP:] log file missing."
	    echohl None
	endtry
	" DebugMode is not changing when log file is missing!
    elseif a:1 =~# '\%(auto\)\?D\%[ebug]'
	let winnr=winnr()
	exe "copen " . (!exists("w:quickfix_title") 
		    \ ? (max([1, min([atplib#qflength(), g:atp_DebugModeQuickFixHeight])]))
		    \ : "" )
	exe winnr . "wincmd w"
	try
	    cgetfile
	    if v:version < 703 || v:version == 703 && !has("path468")
		call atplib#compiler#FilterQuickFix()
	    endif
	catch /E40/
	    echohl WarningMsg 
	    echo "[ATP:] log file missing."
	    echohl None
	endtry
	try 
	    cc
	catch E42:
	    echo "[ATP:] no errors."
	endtry
    endif
endfunction
command! -buffer -bang -nargs=? -complete=custom,DebugComp DebugMode	:call <SID>SetDebugMode(<q-bang>,<f-args>)
function! DebugComp(A,L,P)
    return "silent\nautosilent\ndebug\nautodebug\nDebug\nautoDebug\nverbose"
endfunction
"}}}1

" Python test if libraries are present
" (TestPythoLibs() is not runnow, it was too slow)
" {{{
function! <SID>TestPythonLibs()
let time=reltime()
python << END
import vim
try:
    import psutil
except ImportError:
    vim.command('echohl ErrorMsg|echomsg "[ATP:] needs psutil python library."')
    vim.command('echomsg "You can get it from: http://code.google.com/p/psutil/"')
    test=vim.eval("has('mac')||has('macunix')||has('unix')")
    if test != str(0):
	vim.command('echomsg "Falling back to bash"')
	vim.command("let g:atp_Compiler='bash'")
    vim.command("echohl None")
    vim.command("echomsg \"If you don't want to see this message (and you are on *nix system)\"") 
    vim.command("echomsg \"put let g:atp_Compiler='bash' in your vimrc or atprc file.\"")
    vim.command("sleep 2")
END
endfunction

if g:atp_Compiler == "python"
    if !executable(g:atp_Python) || !has("python")
	echohl ErrorMsg
	echomsg "[ATP:] needs: python and python support in vim."
	echohl None
	if has("mac") || has("macunix") || has("unix")
	    echohl ErrorMsg
	    echomsg "I'm falling back to bash (deprecated)."
	    echohl None
	    let g:atp_Compiler = "bash"
	    echomsg "If you don't want to see this message"
	    echomsg "put let g:atp_Compiler='bash' in your vimrc or atprc file."
	    if !has("python")
		echomsg "You Vim is compiled without pyhon support, some tools might not work."
	    endif
	    sleep 2
	endif
"     else
" 	call <SID>TestPythonLibs()
    endif
endif
" }}}

" Remove g:atp_TempDir tree where log files are stored.
function! <SID>RmTempDir() "{{{
if has("python")
python << END
import shutil
temp=vim.eval("g:atp_TempDir")
shutil.rmtree(temp)
END
elseif has("unix") || has("macunix")
    call system("rm -rf ".shellescape(g:atp_TempDir))
else
    echohl ErrorMsg
    echoerr "[ATP:] leaving temporary directory ".g:atp_TempDir
    echohl None
    sleep 1
endif
if isdirectory(g:atp_TempDir)
    echoerr "[ATP]: g:atp_TempDir=".g:atp_TempDir." is not deleted."
endif
endfunction "}}}

" VIM PATH OPTION: 
exe "setlocal path+=".substitute(g:texmf."/tex,".join(filter(split(globpath(b:atp_ProjectDir, '**'), "\n"), "isdirectory(expand(v:val))"), ","), ' ', '\\\\\\\ ', 'g')

" Some Commands:
" {{{
command! -buffer HelpMathIMaps 	:call atplib#helpfunctions#HelpMathIMaps()
command! -buffer HelpEnvIMaps 	:call atplib#helpfunctions#HelpEnvIMaps()
command! -buffer HelpVMaps 	:call atplib#helpfunctions#HelpVMaps()
" }}}

" Status Line:
if g:atp_StatusLine != 0
    call ATPStatus(0)
endif


" Help:
silent call atplib#helpfunctions#HelpEnvIMaps()
" vim:fdm=marker:tw=85:ff=unix:noet:ts=8:sw=4:fdc=1
