" Author:	Marcin Szmotulski
" Description:  This file contains mappings defined by ATP.
" Note:		This file is a part of Automatic Tex Plugin for Vim.
" Language:	tex
" Last Change: Mon Dec 03, 2012 at 22:24:47  +0000

" Add maps, unless the user didn't want them.
if exists("g:no_plugin_maps") && g:no_plugin_maps ||
	    \ exists("g:no_atp_maps") 	&& g:no_atp_maps ||
	    \ exists("g:no_".&l:filetype."_maps") && g:no_{&l:filetype}_maps
    finish
endif
" SOME VARIABLES: {{{1
" Try to be cpoptions compatible:
if &l:cpoptions =~# "B"
    let s:backslash="\\"
    let s:bbackslash="\\\\"
else
    let s:backslash="\\\\"
    let s:bbackslash="\\\\\\\\"
endif

if g:atp_mapNn
    call atplib#search#ATP_ToggleNn(1,"on")
endif
" DICTIONARY MAP: {{{1
if !hasmapto("<Plug>Dictionray")
    nmap <buffer> <silent> =d <Plug>Dictionary
endif
" REPLACE: {{{1 
function! <SID>Replace(sid,...)
    " It will not work with <:> since with the default settings "normal %" is not
    " working with <:>, possibly because g:atp_bracket_dict doesn't contain this
    " pair.
    let sid = eval('"\'.a:sid.'"')
    if !a:0
	let char =  nr2char(getchar())
    else
	let char = a:1
    endif
    let f_char = getline(line("."))[col(".")-1]
    if index([ '(', ')', '{', '}', '[', ']' ], f_char ) != -1
	if index([ '(', '{', '[' ], f_char) != -1
	    let bracket_dict = { '{' : '}',
			\  '(' : ')',
			\  '[' : ']',
			\  '|' : '|' }
	else
	    let bracket_dict = { '}' : '{',
			\  ')' : '(',
			\  ']' : '[',
			\  '|' : '|' }
	endif
	let c_bracket = get(bracket_dict,char, "")
	if c_bracket == ""
	    exec printf("nn <SID>ReplaceCmd %sr%s", (v:count>=1 ? v:count : ""), char)
	    call inputsave()
	    call feedkeys(sid."ReplaceCmd". sid."InputRestore")
	    return
	endif
	let [b_line, b_col] = [line("."), col(".")]
	exe "normal! %"
	let [e_line, e_col] = [line("."), col(".")]
	if b_line == e_line && b_col == e_col
	    exec printf("nn <SID>ReplaceCmd %sr%s", (v:count>=1 ? v:count : ""), char)
	    call inputsave()
	    call feedkeys(sid."ReplaceCmd". sid."InputRestore")
	    return
	endif

	call cursor(b_line, b_col)
	exe "normal! r".char

	call cursor(e_line, e_col)
	exe "normal! r".c_bracket
	call cursor(b_line, b_col)
	return
    else
	exec  printf("nn <SID>ReplaceCmd %sr%s", (v:count>=1 ? v:count : ""), char)
	call inputsave()
	call feedkeys(sid."ReplaceCmd". sid."InputRestore")
	call cursor(line("."), col("."))
    endif
endfunction
nn <buffer> <silent> <SID>InputRestore  :call inputrestore()<CR>
nnoremap <buffer> <Plug>Replace :<C-U>call <SID>Replace("<SID>")<CR>
if !g:atp_VimCompatible && !hasmapto("<Plug>Replace", "n")
    nmap <buffer> <silent> r <Plug>Replace
endif
" INNER WORD: {{{1
if stridx(g:atp_cpoptions, 'w') != -1
    if !hasmapto('<Plug>TexWordObject', 'v')
	vmap <silent> iw <Plug>TexWordObject
    endif
    if !hasmapto(':normal viw<CR>', 'o')
	omap <silent> iw :normal viw<CR>
    endif
endif
" UNWRAP MAP: {{{1
if !hasmapto("<Plug>Unwrap")
    nmap <buffer> <silent> <LocalLeader>u <Plug>Unwrap
endif
" CC IMAP: {{{1
" <c-c> in insert mode doesn't trigger InsertLeave autocommands
" this fixes this.
if g:atp_IMapCC
    imap <silent> <buffer> <C-c> <C-[>
endif
" NOT A COMMENT PATTERN CMAP: {{{1
exe "cmap <buffer> <expr> <M-c> '^'.(getcmdline() =~ '\\\\v' ? '' : '".s:backslash."').'([^'.(getcmdline() =~ '\\\\v' ? '".s:backslash."' : '').'%]'.(getcmdline() =~ '\\\\v' ? '' : '".s:backslash."').'\\|".s:bbackslash."'.(getcmdline() =~ '\\\\v' ? '".s:backslash."' : '').'%'.(getcmdline() =~ '\\\\v' ? '' : '".s:backslash."').')*".s:backslash."zs'"
" SPECIAL SPACE CMAP: {{{1
if &l:cpoptions =~# "B"
    if g:atp_cmap_space
	cmap <buffer> <expr> <space> ( g:atp_cmap_space && getcmdtype() =~ '[/?]' ? (getcmdline() =~ '\%([^\\]\\|^\)\\v' ? '\_s+' : '\_s\+') : ' ' )
    endif
    cmap <expr> <buffer> <C-@> ( g:atp_cmap_space && getcmdtype() =~ '[/?]' ? (getcmdline() =~ '\%([^\\]\\|^\)\\v' ? '\_s+' : '\_s\+') : ' ' )
    cmap <expr> <buffer> <C-_> ( g:atp_cmap_space && getcmdtype() =~ '[/?]' ? (getcmdline() =~ '\%([^\\]\\|^\)\\v' ? '\_s+' : '\_s\+') : ' ' )
else
    " Some how with no 'B' flag the patter which matches '\v' but not '\\v' is
    " might be simpler.
    if g:atp_cmap_space
	cmap <buffer> <expr> <space> ( g:atp_cmap_space && getcmdtype() =~ '[/?]' ? (getcmdline() =~ '[^\\\\]\\v' ? '\\_s+' : '\\_s\\+') : ' ' )
    endif
    cmap <expr> <buffer> <C-@> ( g:atp_cmap_space && getcmdtype() =~ '[/?]' ? (getcmdline() =~ '[^\\\\]\\v' ? '\\_s+' : '\\_s\\+') : ' ' )
    cmap <expr> <buffer> <C-_> ( g:atp_cmap_space && getcmdtype() =~ '[/?]' ? (getcmdline() =~ '[^\\\\]\\v' ? '\\_s+' : '\\_s\\+') : ' ' )
endif
if maparg("<F2>", "n") == ""
    nmap <buffer> <F2>	:echo ATP_ToggleSpace()<CR>
endif
" COMMANDS: font preview, open fd file, close last: environment, bracket {{{1
command! -buffer -bang -nargs=* FontSearch	:call atplib#fontpreview#FontSearch(<q-bang>, <f-args>)
command! -buffer -bang -nargs=* FontPreview	:call atplib#fontpreview#FontPreview(<q-bang>,<f-args>)
command! -buffer -nargs=1 -complete=customlist,atplib#Fd_completion OpenFdFile	:call atplib#tools#OpenFdFile(<f-args>) 
command! -buffer -nargs=* CloseLastEnvironment	:call atplib#complete#CloseLastEnvironment(<f-args>)
command! -buffer 	  CloseLastBracket	:call atplib#complete#CloseLastBracket()
" SECTION MOTION MAPS: {{{1
if !hasmapto("\"SSec") && !hasmapto("'SSec")
    exe "nmap <buffer> <silent>	".g:atp_goto_section_leader."S		:<C-U>keepjumps exe v:count1.\"SSec\"<CR>"
endif
if !hasmapto("\"Sec") && !hasmapto("'Sec")
    exe "nmap <buffer> <silent>	".g:atp_goto_section_leader."s		:<C-U>keepjumps exe v:count1.\"Sec\"<CR>"
endif
if !hasmapto("\"Chap") && !hasmapto("'Chap")
    exe "nmap <buffer> <silent>	".g:atp_goto_section_leader."c		:<C-U>keepjumps exe v:count1.\"Chap\"<CR>"
endif
if !hasmapto("\"Part") && !hasmapto("'Part")
    exe "nmap <buffer> <silent>	".g:atp_goto_section_leader."p		:<C-U>keepjumps exe v:count1.\"Part\"<CR>"
endif
" SYNCTEX MAPS: {{{1
if !hasmapto("<Plug>SyncTexKeyStroke", "n")
    nmap <buffer> <silent> <LocalLeader>f		<Plug>SyncTexKeyStroke
endif
if !hasmapto("<Plug>SyncTexLKeyStroke", "n")
    nmap <buffer> <silent> <LocalLeader><LocalLeader>f	<Plug>SyncTexLKeyStroke
    nmap <buffer> <silent> <LocalLeader>F		<Plug>SyncTexLKeyStroke
endif
if !hasmapto("<LeftMouse><Plug>SyncTexMouse", "n")
    nmap <buffer> <S-LeftMouse> 		<LeftMouse><Plug>SyncTexMouse
endif
" COMMENT LINES: {{{1
if g:atp_MapCommentLines && !empty(g:atp_map_Comment)
    if !hasmapto("<Plug>CommentLines", "n")
	exe "nmap <buffer> <silent> ".g:atp_map_Comment."	<Plug>CommentLines"
    endif
    if !hasmapto("<Plug>CommentLines", "v")
	exe "vmap <buffer> <silent> ".g:atp_map_Comment."	<Plug>CommentLines"
    endif
"     if !hasmapto("<Plug>UnCommentLines", "n")
" 	exe "nmap <buffer> <silent> ".g:atp_map_UnComment."	<Plug>UnCommentLines"
"     endif
"     if !hasmapto("<Plug>UnCommentLines", "v")
" 	exe "vmap <buffer> <silent> ".g:atp_map_UnComment."	<Plug>UnCommentLines"
"     endif
endif
" MOVE AROUND COMMENTS: {{{1
if !hasmapto("<Plug>ParagraphNormalMotion")
    nmap <buffer> <silent> }	<Plug>ParagraphNormalMotionForward
endif
if !hasmapto("<Plug>ParagraphNormalMotionBackward")
    nmap <buffer> <silent> {	<Plug>ParagraphNormalMotionBackward
endif
if !hasmapto("<Plug>SentenceNormalMotion")
    nmap <buffer> <silent> )	<Plug>SentenceNormalMotionForward
endif
if !hasmapto("<Plug>SentenceNormalMotionBackward")
    nmap <buffer> <silent> (	<Plug>SentenceNormalMotionBackward
endif
nnoremap <buffer> <silent> v :<c-u>call atplib#motion#StartVisualMode('v', v:count)<CR>
nnoremap <buffer> <silent> V :<c-u>call atplib#motion#StartVisualMode('V', v:count)<CR>
nnoremap <buffer> <silent> <C-v> :<c-u>call atplib#motion#StartVisualMode('cv', v:count)<CR>
if !hasmapto("<Plug>ParagraphVisualMotion")
    vmap <buffer> <silent> } 	<Plug>ParagraphVisualMotionForward
    vmap <buffer> <silent> { 	<Plug>ParagraphVisualMotionBackward
endif
omap <buffer> <silent> 	} :<C-U>exe "normal ".v:count1."}"<CR>
omap <buffer> <silent> 	{ :<C-U>exe "normal ".v:count1."{"<CR>

if !hasmapto(":SkipCommentForward<CR>", 'n')
    nmap <buffer> <silent> ]*	:SkipCommentForward<CR>
    nmap <buffer> <silent> ]%	:SkipCommentForward<CR>
    nmap <buffer> <silent> gc	:SkipCommentForward<CR>
endif
if !hasmapto(":SkipCommentForward<CR>", 'o')
    omap <buffer> <silent> ]*	:SkipCommentForward<CR>
    omap <buffer> <silent> ]%	:SkipCommentForward<CR>
    omap <buffer> <silent> gc	:SkipCommentForward<CR>
endif
if !hasmapto("<Plug>SkipCommentForward", 'v')
    vmap <buffer> <silent> ]*	<Plug>SkipCommentForward
    vmap <buffer> <silent> ]%	<Plug>SkipCommentForward
    vmap <buffer> <silent> gc	<Plug>SkipCommentForward
endif

if !hasmapto("<Plug>SkipCommentBackward<CR>", 'n')
    nmap <buffer> <silent> [*	:SkipCommentBackward<CR>
    nmap <buffer> <silent> [%	:SkipCommentBackward<CR>
    nmap <buffer> <silent> gC	:SkipCommentBackward<CR>
endif
if !hasmapto("<Plug>SkipCommentBackward<CR>", 'o')
    omap <buffer> <silent> [*	:SkipCommentBackward<CR>
    omap <buffer> <silent> [%	:SkipCommentBackward<CR>
    omap <buffer> <silent> gC	:SkipCommentBackward<CR>
endif
if !hasmapto("<Plug>SkipCommentBackward", 'v')
    vmap <buffer> <silent> [*	<Plug>SkipCommentBackward
    vmap <buffer> <silent> [%	<Plug>SkipCommentBackward
    vmap <buffer> <silent> gC	<Plug>SkipCommentBackward
endif

if !empty(g:atp_map_forward_motion_leader)
if !hasmapto(":NInput<CR>")
    execute "nmap <silent> <buffer> ".g:atp_map_forward_motion_leader."i	:<c-u>call atplib#motion#Input((&wrapscan ? 'w' : ''),v:count1)<CR>"
    execute "nmap <silent> <buffer> ".g:atp_map_forward_motion_leader."gf	:<c-u>call atplib#motion#Input((&wrapscan ? 'w' : ''), v:count1)<CR>"
endif

if !hasmapto(":PInput<CR>")
    execute "nmap <silent> <buffer> ".g:atp_map_backward_motion_leader."i	:<c-u>call atplib#motion#Input((&wrapscan ? 'wb' : 'b'), v:count1)<CR>"
    execute "nmap <silent> <buffer> ".g:atp_map_backward_motion_leader."gf	:<c-u>call atplib#motion#Input((&wrapscan ? 'wb' : 'b'), v:count1)<CR>"
endif
endif
" MOTIONS: {{{1
" imap <buffer> <C-j> <Plug>TexSyntaxMotionForward
" imap <buffer> <C-k> <Plug>TexSyntaxMotionBackward
" nmap <buffer> <C-j> <Plug>TexSyntaxMotionForward
" nmap <buffer> <C-k> <Plug>TexSyntaxMotionBackward

if !hasmapto("<Plug>TexJMotionForward", 'i')
    imap <silent> <buffer> <C-j> <Plug>TexJMotionForward
endif
if !hasmapto("<Plug>TexJMotionForward", 'n')
    nmap <silent> <buffer> <C-j> <Plug>TexJMotionForward
endif
if !hasmapto("<Plug>TexJMotionBackward", 'i')
    imap <silent> <buffer> <C-k> <Plug>TexJMotionBackward
endif
if !hasmapto("<Plug>TexJMotionBackward", 'n')
    nmap <silent> <buffer> <C-k> <Plug>TexJMotionBackward
endif

" Repair: } and { 
if g:atp_map_forward_motion_leader == "}"
    noremap <silent> <buffer> }} }
endif
if g:atp_map_backward_motion_leader == "{"
    noremap <silent> <buffer> {{ {
endif
" Repair: > and >> (<, <<) operators:
if g:atp_map_forward_motion_leader == ">"
    nnoremap <buffer> <silent> >>  :<C-U>exe "normal! ".v:count1.">>"<CR>
    vnoremap <buffer> <silent> >>  :<C-U>exe "'<,'>normal! v".v:count1.">>"<CR>
endif
if g:atp_map_backward_motion_leader == "<"
    nnoremap <buffer> <silent> <<  :<C-U>exe "normal! ".v:count1."<<"<CR>
    vnoremap <buffer> <silent> <<  :<C-U>exe "'<,'>normal! v".v:count1."<<"<CR>
endif

if !empty(g:atp_map_forward_motion_leader)
if !hasmapto("<Plug>GotoNextParagraph", 'n')
    execute "nmap <silent> <buffer> ".g:atp_map_forward_motion_leader."P 	<Plug>GotoNextParagraph"
endif
if !hasmapto("<Plug>GotoNextParagraph", 'o')
    execute "omap <silent> <buffer> ".g:atp_map_forward_motion_leader."P 	<Plug>GotoNextParagraph"
endif
if !hasmapto("<Plug>vGotoNextParagraph", 'v')
    execute "vmap <silent> <buffer> ".g:atp_map_forward_motion_leader."P	<Plug>vGotoNextParagraph"
endif
if !hasmapto("<Plug>GotoNextSubSection", 'n')
    execute "nmap <silent> <buffer> ".g:atp_map_forward_motion_leader."S 	<Plug>GotoNextSubSection"
endif
if !hasmapto("<Plug>GotoNextSubSection", 'o')
    execute "omap <silent> <buffer> ".g:atp_map_forward_motion_leader."S 	<Plug>GotoNextSubSection"
endif
if !hasmapto("<Plug>vGotoNextSubSection", 'v')
    execute "vmap <silent> <buffer> ".g:atp_map_forward_motion_leader."S	<Plug>vGotoNextSubSection"
endif
if !hasmapto("<Plug>GotoNextSection", 'n')
    execute "nmap <silent> <buffer> ".g:atp_map_forward_motion_leader."s 	<Plug>GotoNextSection"
endif
if !hasmapto("<Plug>GotoNextSection", 'o')
    execute "omap <silent> <buffer> ".g:atp_map_forward_motion_leader."s 	<Plug>GotoNextSection"
endif
if !hasmapto("<Plug>vGotoNextSection", 'v')
    execute "vmap <silent> <buffer> ".g:atp_map_forward_motion_leader."s	<Plug>vGotoNextSection"
endif
if !( g:atp_map_forward_motion_leader == "]" && &l:diff )
    if !hasmapto("<Plug>GotoNextChapter", 'n')
	execute "nmap <silent> <buffer> ".g:atp_map_forward_motion_leader."c 	<Plug>GotoNextChapter"
    endif
    if !hasmapto("<Plug>GotoNextChapter", 'o')
	execute "omap <silent> <buffer> ".g:atp_map_forward_motion_leader."c 	<Plug>GotoNextChapter"
    endif
    if !hasmapto("<Plug>vGotoNextChapter", 'v')
	execute "vmap <silent> <buffer> ".g:atp_map_forward_motion_leader."c 	<Plug>vGotoNextChapter"
    endif
endif
if !hasmapto("<Plug>JumptoNextEnvironment", "n")
    execute "nmap <silent> <buffer> ".g:atp_map_forward_motion_leader."e	<Plug>JumptoNextEnvironment"
endif
if !hasmapto("<Plug>JumptoNextEnvironment", "o")
    execute "omap <silent> <buffer> ".g:atp_map_forward_motion_leader."e	<Plug>JumptoNextEnvironment"
endif
if !hasmapto("<Plug>FastJumptoNextEnvironment", "n")
    execute "nmap <silent> <buffer> ".g:atp_map_forward_motion_leader."E	<Plug>FastJumptoNextEnvironment"
endif
if !hasmapto("<Plug>FastJumptoNextEnvironment", "o")
    execute "omap <silent> <buffer> ".g:atp_map_forward_motion_leader."E	<Plug>FastJumptoNextEnvironment"
endif
if !hasmapto("<Plug>JumpOutForward", "n")
    execute "nmap <silent> <buffer> ".g:atp_map_forward_motion_leader."o	<Plug>JumpOutForward"
endif
if !hasmapto("<Plug>JumpOutForward", "o")
    execute "omap <silent> <buffer> ".g:atp_map_forward_motion_leader."o	<Plug>JumpOutForward"
endif
if !hasmapto("<Plug>FastJumpOutForward", "n")
    execute "nmap <silent> <buffer> ".g:atp_map_forward_motion_leader."O	<Plug>FastJumpOutForward"
endif
if !hasmapto("<Plug>FastJumpOutForward", "o")
    execute "omap <silent> <buffer> ".g:atp_map_forward_motion_leader."O	<Plug>FastJumpOutForward"
endif
if !hasmapto("<Plug>GotoNextMath", "n")
    execute "nmap <silent> <buffer> ".g:atp_map_forward_motion_leader."m	<Plug>GotoNextMath"
endif
if !hasmapto("<Plug>GotoNextMath", "o")
    execute "omap <silent> <buffer> ".g:atp_map_forward_motion_leader."m	<Plug>GotoNextMath"
endif
if !hasmapto("<Plug>GotoNextDisplayedMath", "n")
    execute "nmap <silent> <buffer> ".g:atp_map_forward_motion_leader."M	<Plug>GotoNextDisplayedMath"
endif
if !hasmapto("<Plug>GotoNextDisplayedMath", "o")
    execute "omap <silent> <buffer> ".g:atp_map_forward_motion_leader."M	<Plug>GotoNextDisplayedMath"
endif
if !hasmapto("<Plug>GotoNextPart", 'n')
    execute "nmap <silent> <buffer> ".g:atp_map_forward_motion_leader."p 	<Plug>GotoNextPart"
endif
if !hasmapto("<Plug>GotoNextPart", 'o')
    execute "omap <silent> <buffer> ".g:atp_map_forward_motion_leader."p 	<Plug>GotoNextPart"
endif
if !hasmapto("<Plug>vGotoNextPart", 'v')
    execute "vmap <silent> <buffer> ".g:atp_map_forward_motion_leader."p 	<Plug>vGotoNextPart"
endif
endif
if !empty(g:atp_map_backward_motion_leader)
if !hasmapto("<Plug>GotoPreviousParagraph", 'n')
    execute "nmap <silent> <buffer> ".g:atp_map_backward_motion_leader."P 	<Plug>GotoPreviousParagraph"
endif
if !hasmapto("<Plug>GotoPreviousParagraph", 'o')
    execute "omap <silent> <buffer> ".g:atp_map_backward_motion_leader."P 	<Plug>GotoPreviousParagraph"
endif
if !hasmapto("<Plug>vGotoPreviousParagraph", 'v')
    execute "vmap <silent> <buffer> ".g:atp_map_backward_motion_leader."P 	<Plug>vGotoPreviousParagraph"
endif
if !hasmapto("<Plug>GotoPreviousSubSection", 'n')
    execute "nmap <silent> <buffer> ".g:atp_map_backward_motion_leader."S 	<Plug>GotoPreviousSubSection"
endif
if !hasmapto("<Plug>GotoPreviousSubSection", 'o')
    execute "omap <silent> <buffer> ".g:atp_map_backward_motion_leader."S 	<Plug>GotoPreviousSubSection"
endif
if !hasmapto("<Plug>vGotoPreviousSubSection", 'v')
    execute "vmap <silent> <buffer> ".g:atp_map_backward_motion_leader."S 	<Plug>vGotoPreviousSubSection"
endif
if !hasmapto("<Plug>GotoPreviousSection", 'n')
    execute "nmap <silent> <buffer> ".g:atp_map_backward_motion_leader."s 	<Plug>GotoPreviousSection"
endif
if !hasmapto("<Plug>GotoPreviousSection", 'o')
    execute "omap <silent> <buffer> ".g:atp_map_backward_motion_leader."s 	<Plug>GotoPreviousSection"
endif
if !hasmapto("<Plug>vGotoPreviousSection", 'v')
    execute "vmap <silent> <buffer> ".g:atp_map_backward_motion_leader."s 	<Plug>vGotoPreviousSection"
endif
if !( g:atp_map_backward_motion_leader == "]" && &l:diff )
    if !hasmapto("<Plug>GotoPreviousChapter", 'n')
	execute "nmap <silent> <buffer> ".g:atp_map_backward_motion_leader."c 	<Plug>GotoPreviousChapter"
    endif
    if !hasmapto("<Plug>GotoPreviousChapter", 'o')
	execute "omap <silent> <buffer> ".g:atp_map_backward_motion_leader."c 	<Plug>GotoPreviousChapter"
    endif
    if !hasmapto("<Plug>vGotoPreviousChapter", 'v')
	execute "vmap <silent> <buffer> ".g:atp_map_backward_motion_leader."c 	<Plug>vGotoPreviousChapter"
    endif
endif
if !hasmapto("<Plug>JumptoPreviousEnvironment", "n")
    execute "nmap <silent> <buffer> ".g:atp_map_backward_motion_leader."e 	<Plug>JumptoPreviousEnvironment"
endif
if !hasmapto("<Plug>JumptoPreviousEnvironment", "o")
    execute "omap <silent> <buffer> ".g:atp_map_backward_motion_leader."e 	<Plug>JumptoPreviousEnvironment"
endif
if !hasmapto("<Plug>FastJumptoPreviousEnvironment", "n")
    execute "nmap <silent> <buffer> ".g:atp_map_backward_motion_leader."E 	<Plug>FastJumptoPreviousEnvironment"
endif
if !hasmapto("<Plug>FastJumptoPreviousEnvironment", "o")
    execute "omap <silent> <buffer> ".g:atp_map_backward_motion_leader."E 	<Plug>FastJumptoPreviousEnvironment"
endif
if !hasmapto("<Plug>JumpOutBackward", "n")
    execute "nmap <silent> <buffer> ".g:atp_map_backward_motion_leader."o 	<Plug>JumpOutBackward"
endif
if !hasmapto("<Plug>JumpOutBackward", "o")
    execute "omap <silent> <buffer> ".g:atp_map_backward_motion_leader."o 	<Plug>JumpOutBackward"
endif
if !hasmapto("<Plug>FastJumpOutBackward", "n")
    execute "nmap <silent> <buffer> ".g:atp_map_backward_motion_leader."O 	<Plug>FastJumpOutBackward"
endif
if !hasmapto("<Plug>FastJumpOutBackward", "o")
    execute "omap <silent> <buffer> ".g:atp_map_backward_motion_leader."O 	<Plug>FastJumpOutBackward"
endif
if !hasmapto("<Plug>GotoPreviousMath", "n")
    execute "nmap <silent> <buffer> ".g:atp_map_backward_motion_leader."m	<Plug>GotoPreviousMath"
endif
if !hasmapto("<Plug>GotoPreviousMath", "o")
    execute "omap <silent> <buffer> ".g:atp_map_backward_motion_leader."m	<Plug>GotoPreviousMath"
endif
if !hasmapto("<Plug>GotoPreviousDisplayedMath", "n")
    execute "nmap <silent> <buffer> ".g:atp_map_backward_motion_leader."M	<Plug>GotoPreviousDisplayedMath"
endif
if !hasmapto("<Plug>GotoPreviousDisplayedMath", "o")
    execute "omap <silent> <buffer> ".g:atp_map_backward_motion_leader."M	<Plug>GotoPreviousDisplayedMath"
endif
if !hasmapto("<Plug>GotoPreviousPart", "n")
    execute "nmap <silent> <buffer> ".g:atp_map_backward_motion_leader."p 	<Plug>GotoPreviousPart"
endif
if !hasmapto("<Plug>GotoPreviousPart", "o")
    execute "omap <silent> <buffer> ".g:atp_map_backward_motion_leader."p 	<Plug>GotoPreviousPart"
endif
if !hasmapto("<Plug>vGotoPreviousPart", 'v')
    execute "vmap <silent> <buffer> ".g:atp_map_backward_motion_leader."p 	<Plug>vGotoPreviousPart"
endif
endif
" GOTO FILE MAP: {{{1
if has("path_extra") && !hasmapto(" GotoFile(", 'n')
	nnoremap <buffer> <silent> gf		:call atplib#motion#GotoFile("", "")<CR>
endif

if !g:atp_tab_map
    "Default Completion Maps:
    inoremap <silent> <buffer> <C-x><C-o> <C-R>=atplib#complete#TabCompletion(1)<CR>
    inoremap <silent> <buffer> <C-x>o <C-R>=atplib#complete#TabCompletion(0)<CR>
else 
    "Non Default Completion Maps:
    if !hasmapto("<C-R>=atplib#complete#TabCompletion(1)<CR>", 'i')
	imap <silent> <buffer> <Tab> 		<C-R>=atplib#complete#TabCompletion(1)<CR>
    endif
    if !hasmapto("<C-R>=atplib#complete#TabCompletion(0)<CR>", 'i')
	imap <silent> <buffer> <S-Tab> 		<C-R>=atplib#complete#TabCompletion(0)<CR>
    endif
endif
if !hasmapto(":Wrap { } begin<cr>", 'v')
    execute "vnoremap <silent> <buffer> ".g:atp_vmap_bracket_leader."{ 	:Wrap { } begin<CR>"
endif
" WRAPERS: {{{1
" OPERATOR FONT MAPS: {{{2
function! ATP_LastWrap(type)
    if a:type == "block" | return | endif
    let marks = ["'[", "']"]
    call atplib#various#RedoLastWrapSelection(marks)
endfunction
if !empty(g:atp_vmap_text_font_leader)
exe "nmap <buffer> ".g:atp_vmap_text_font_leader."w :set opfunc=ATP_LastWrap<CR>g@"
function! ATP_WrapRoman(type)
    if a:type == "block" | return | endif
    call atplib#various#InteligentWrapSelection(['\textrm{'], ['\mathrm{'], 'end', 0, ["'[", "']"])
endfunction
exe "nmap <buffer> ".g:atp_vmap_text_font_leader."rm :set opfunc=ATP_WrapRoman<CR>g@"
function! ATP_WrapBold(type)
    if a:type == "block" | return | endif
    call atplib#various#InteligentWrapSelection(['\textbf{'], ['\mathbf{'], 'end', 0, ["'[", "']"])
endfunction
exe "nmap <buffer> ".g:atp_vmap_text_font_leader."bf :set opfunc=ATP_WrapBold<CR>g@"
function! ATP_WrapBB(type)
    if a:type == "block" | return | endif
    call atplib#various#InteligentWrapSelection(['\textbf{'], ['\mathbb{'], 'end', 0, ["'[", "']"])
endfunction
exe "nmap <buffer> ".g:atp_vmap_text_font_leader."bb :set opfunc=ATP_WrapBB<CR>g@"
function! ATP_WrapItalic(type)
    if a:type == "block" | return | endif
    call atplib#various#InteligentWrapSelection(['\textit{'], ['\mathit{'], 'end', 0, ["'[", "']"])
endfunction
exe "nmap <buffer> ".g:atp_vmap_text_font_leader."it :set opfunc=ATP_WrapItalic<CR>g@"
function! ATP_WrapEmph(type)
    if a:type == "block" | return | endif
    call atplib#various#InteligentWrapSelection(['\emph{'], ['\mathit{'], 'end', 0, ["'[", "']"])
endfunction
exe "nmap <buffer> ".g:atp_vmap_text_font_leader."em :set opfunc=ATP_WrapEmph<CR>g@"
function! ATP_WrapSF(type)
    if a:type == "block" | return | endif
    call atplib#various#InteligentWrapSelection(['\textsf{'], ['\mathsf{'], 'end', 0, ["'[", "']"])
endfunction
exe "nmap <buffer> ".g:atp_vmap_text_font_leader."sf :set opfunc=ATP_WrapSF<CR>g@"
function! ATP_WrapTT(type)
    if a:type == "block" | return | endif
    call atplib#various#InteligentWrapSelection(['\texttt{'], ['\mathtt{'], 'end', 0, ["'[", "']"])
endfunction
exe "nmap <buffer> ".g:atp_vmap_text_font_leader."tt :set opfunc=ATP_WrapTT<CR>g@"
function! ATP_WrapSL(type)
    if a:type == "block" | return | endif
    call atplib#various#WrapSelection('\textsl{', '}', 'end', 0, ["'[", "']"])
endfunction
exe "nmap <buffer> ".g:atp_vmap_text_font_leader."sl :set opfunc=ATP_WrapSL<CR>g@"
function! ATP_WrapSC(type)
    if a:type == "block" | return | endif
    call atplib#various#WrapSelection('\textsc{', '}', 'end', 0, ["'[", "']"])
endfunction
exe "nmap <buffer> ".g:atp_vmap_text_font_leader."sc :set opfunc=ATP_WrapSC<CR>g@"
function! ATP_WrapUP(type)
    if a:type == "block" | return | endif
    call atplib#various#WrapSelection('\textup{', '}', 'end', 0, ["'[", "']"])
endfunction
exe "nmap <buffer> ".g:atp_vmap_text_font_leader."up :set opfunc=ATP_WrapUP<CR>g@"
function! ATP_WrapMD(type)
    if a:type == "block" | return | endif
    call atplib#various#WrapSelection('\textmd{', '}', 'end', 0, ["'[", "']"])
endfunction
" g:atp_vmap_text_font_leader is used instead of g:atp_imap_over_leader = "`"
" which interferes with marks.
exe "nmap <buffer> ".g:atp_vmap_text_font_leader."md :set opfunc=ATP_WrapMD<CR>g@"
function! ATP_WrapUnderline(type)
    if a:type == "block" | return | endif
    call atplib#various#WrapSelection('\underline{', '}', 'end', 0, ["'[", "']"])
endfunction
exe "nmap <buffer> ".g:atp_vmap_text_font_leader."un :set opfunc=ATP_WrapUnderline<CR>g@"
function! ATP_WrapOverline(type)
    if a:type == "block" | return | endif
    call atplib#various#WrapSelection('\overline{', '}', 'end', 0, ["'[", "']"])
endfunction
exe "nmap <buffer> ".g:atp_vmap_text_font_leader."ov :set opfunc=ATP_WrapOverline<CR>g@"
function! ATP_WrapCal(type)
    if a:type == "block" | return | endif
    if atplib#IsInMath()
	call atplib#various#WrapSelection('\mathcal{', '}', 'end', 0, ["'[", "']"])
    endif
endfunction
exe "nmap <buffer> ".g:atp_vmap_text_font_leader."cal :set opfunc=ATP_WrapCal<CR>g@"
function! ATP_WrapFrak(type)
    if a:type == "block" | return | endif
    call atplib#various#WrapSelection('\mathfrak{', '}', 'end', 0, ["'[", "']"])
endfunction
exe "nmap <buffer> ".g:atp_vmap_text_font_leader."fr :set opfunc=ATP_WrapFrak<CR>g@"
endif

" FONTS: {{{2
if !empty(g:atp_vmap_text_font_leader)
if !hasmapto(":Wrap {".s:backslash."usefont{".g:atp_font_encoding."}{}{}{}\\selectfont", 'v')
    execute "vnoremap <silent> <buffer> ".g:atp_vmap_text_font_leader."uf	:Wrap {".s:backslash."usefont{".g:atp_font_encoding."}{}{}{}\\selectfont\\  } ".(len(g:atp_font_encoding)+11)."<CR>"
endif
if !hasmapto(":Wrap {".s:backslash."mathfrak{", 'v')
    execute "vnoremap <silent> <buffer> ".g:atp_vmap_text_font_leader."fr	:Wrap ".s:backslash."mathfrak{ }<CR>"
endif
if !hasmapto(":Wrap ".s:backslash."mbox{", 'v')
    execute "vnoremap <silent> <buffer> ".g:atp_vmap_text_font_leader."mb	:Wrap ".s:backslash."mbox{ } begin<CR>"
endif

if !hasmapto(":<C-U>IWrap ['".s:backslash."textrm{'],['".s:backslash."text{']<CR>", 'v')
    execute "vnoremap <silent> <buffer> ".g:atp_vmap_text_font_leader."te	:<C-U>IWrap ['".s:backslash."textrm{'],['".s:backslash."text{']<CR>"
endif
if !hasmapto(":<C-U>IWrap ['".s:backslash."textrm{'],['".s:backslash."mathrm{']<CR>", 'v')
    execute "vnoremap <silent> <buffer> ".g:atp_vmap_text_font_leader."rm	:<C-U>IWrap ['".s:backslash."textrm{'],['".s:backslash."mathrm{']<CR>"
endif
if !hasmapto(":<C-U>IWrap ['".s:backslash."emph{'],['".s:backslash."mathit{']<CR>", 'v')
    execute "vnoremap <silent> <buffer> ".g:atp_vmap_text_font_leader."em	:<C-U>IWrap ['".s:backslash."emph{'],['".s:backslash."mathit{']<CR>"
endif
"   Suggested Maps:
"     execute "vnoremap <silent> <buffer> ".g:atp_vmap_text_font_leader."tx	:<C-U>IWrap [''],['".s:backslash."text{']<CR>"
"     execute "vnoremap <silent> <buffer> ".g:atp_vmap_text_font_leader."in	:<C-U>IWrap [''],['".s:backslash."intertext{']<CR>"
if !hasmapto(":<C-U>IWrap ['".s:backslash."textit{'],['".s:backslash."mathit{']<CR>", 'v')
    execute "vnoremap <silent> <buffer> ".g:atp_vmap_text_font_leader."it	:<C-U>IWrap ['".s:backslash."textit{'],['".s:backslash."mathit{']<CR>"
endif
if !hasmapto(":<C-U>IWrap ['".s:backslash."textsf{'],['".s:backslash."mathsf{']<CR>", 'v')
    execute "vnoremap <silent> <buffer> ".g:atp_vmap_text_font_leader."sf	:<C-U>IWrap ['".s:backslash."textsf{'],['".s:backslash."mathsf{']<CR>"
endif
if !hasmapto(":<C-U>IWrap ['".s:backslash."texttt{'],['".s:backslash."mathtt{']<CR>", 'v')
    execute "vnoremap <silent> <buffer> ".g:atp_vmap_text_font_leader."tt	:<C-U>IWrap ['".s:backslash."texttt{'],['".s:backslash."mathtt{']<CR>"
endif
if !hasmapto(":<C-U>IWrap ['".s:backslash."textbf{'],['".s:backslash."mathbf{']<CR>", 'v')
    execute "vnoremap <silent> <buffer> ".g:atp_vmap_text_font_leader."bf	:<C-U>IWrap ['".s:backslash."textbf{'],['".s:backslash."mathbf{']<CR>"
endif
if !hasmapto(":<C-U>IWrap ['".s:backslash."textbf{'],['".s:backslash."mathbb{']<CR>", 'v')
    execute "vnoremap <silent> <buffer> ".g:atp_vmap_text_font_leader."bb	:<C-U>IWrap ['".s:backslash."textbf{'],['".s:backslash."mathbb{']<CR>"
endif
if !hasmapto(":<C-U>Wrap ".s:backslash."textsl{<CR>", 'v')
    execute "vnoremap <silent> <buffer> ".g:atp_vmap_text_font_leader."sl	:<C-U>Wrap ".s:backslash."textsl{<CR>"
endif
if !hasmapto(":<C-U>Wrap ".s:backslash."textsc{<CR>", 'v')
    execute "vnoremap <silent> <buffer> ".g:atp_vmap_text_font_leader."sc	:<C-U>Wrap ".s:backslash."textsc{<CR>"
endif
if !hasmapto(":<C-U>Wrap ".s:backslash."textup{<CR>", 'v')
    execute "vnoremap <silent> <buffer> ".g:atp_vmap_text_font_leader."up	:<C-U>Wrap ".s:backslash."textup{<CR>"
endif
if !hasmapto(":<C-U>Wrap ".s:backslash."textmd{<CR>", 'v')
    execute "vnoremap <silent> <buffer> ".g:atp_vmap_text_font_leader."md	:<C-U>Wrap ".s:backslash."textmd{<CR>"
endif
if !hasmapto(":<C-U>Wrap ".s:backslash."underline{<CR>", 'v')
    execute "vnoremap <silent> <buffer> ".g:atp_vmap_text_font_leader."un	:<C-U>Wrap ".s:backslash."underline{<CR>"
endif
if !hasmapto(":<C-U>Wrap ".s:backslash."overline{<CR>", 'v')
    execute "vnoremap <silent> <buffer> ".g:atp_vmap_text_font_leader."ov	:<C-U>Wrap ".s:backslash."overline{<CR>"
endif
if !hasmapto(":<C-U>IWrap ['".s:backslash."textnormal{'],['".s:backslash."mathnormal{']<CR>", 'v')
    execute "vnoremap <silent> <buffer> ".g:atp_vmap_text_font_leader."no	:<C-U>IWrap ['".s:backslash."textnormal{'],['".s:backslash."mathnormal{']<CR>"
endif
if !hasmapto(":<C-U>IWrap [''],['".s:backslash."mathcal{']<CR>", 'v')
    execute "vnoremap <silent> <buffer> ".g:atp_vmap_text_font_leader."cal	:<C-U>IWrap [''],['".s:backslash."mathcal{']<CR>"
endif
if !hasmapto("atplib#various#RedoLastWrapSelection", 'v')
    execute "vnoremap <silent> <buffer> ".g:atp_vmap_text_font_leader."w	<Esc>:<C-U>:call atplib#various#RedoLastWrapSelection([\"'<\", \"'>\"])<CR>"
endif
endif

" ENVIRONMENTS: {{{2
if !empty(g:atp_vmap_environment_leader)
if !hasmapto(":Wrap ".s:backslash."begin{center} ".s:backslash."end{center} 0 1<CR>", 'v')
    execute "vnoremap <silent> <buffer> ".g:atp_vmap_environment_leader."C   :Wrap ".s:backslash."begin{center} ".s:backslash."end{center} 0 1<CR>"
endif
if !hasmapto(":Wrap ".s:backslash."begin{flushright} ".s:backslash."end{flushright} 0 1<CR>", 'v')
    execute "vnoremap <silent> <buffer> ".g:atp_vmap_environment_leader."R   :Wrap ".s:backslash."begin{flushright} ".s:backslash."end{flushright} 0 1<CR>"
endif
if !hasmapto(":Wrap ".s:backslash."begin{flushleft} ".s:backslash."end{flushleft} 0 1<CR>", 'v')
    execute "vnoremap <silent> <buffer> ".g:atp_vmap_environment_leader."L   :Wrap ".s:backslash."begin{flushleft} ".s:backslash."end{flushleft} 0 1<CR>"
endif
if !hasmapto(":Wrap ".s:backslash."begin{equation=b:atp_StarMathEnvDefault<CR>} ".s:backslash."end{equation=b:atp_StarMathEnvDefault<CR>} 0 1<CR>", 'v')
    execute "vnoremap <silent> <buffer> ".g:atp_vmap_environment_leader."E   :Wrap ".s:backslash."begin{equation=b:atp_StarMathEnvDefault<CR>} ".s:backslash."end{equation=b:atp_StarMathEnvDefault<CR>} 0 1<CR>"
endif
if !hasmapto(":Wrap ".s:backslash."begin{align=b:atp_StarMathEnvDefault<CR>} ".s:backslash."end{align=b:atp_StarMathEnvDefault<CR>} 0 1<CR>", 'v')
    execute "vnoremap <silent> <buffer> ".g:atp_vmap_environment_leader."A   :Wrap ".s:backslash."begin{align=b:atp_StarMathEnvDefault<CR>} ".s:backslash."end{align=b:atp_StarMathEnvDefault<CR>} 0 1<CR>"
endif
endif

" MATH MODES: {{{2
if !hasmapto(':<C-U>Wrap '.s:backslash.'( '.s:backslash.')<CR>', 'v')
    exe "vmap <silent> <buffer> m				:<C-U>Wrap ".s:backslash."( ".s:backslash.")<CR>"
endif
if !hasmapto(':<C-U>Wrap '.s:backslash.'[ '.s:backslash.']<CR>', 'v')
    exe "vmap <silent> <buffer> M				:<C-U>Wrap ".s:backslash."[ ".s:backslash."]<CR>"
endif
function! ATP_WrapVMath(type)
    if a:type == "block" | return | endif
    call atplib#various#WrapSelection('\(', '\)', 'begin', 0, ["'[", "']"])
endfunction
function! ATP_WrapWMath(type)
    if a:type == "block" | return | endif
    call atplib#various#WrapSelection('\[', '\]', 'begin', 0, ["'[", "']"])
endfunction
if !empty(g:atp_vmap_bracket_leader)
exe "nmap <buffer> ".g:atp_vmap_bracket_leader."m :set opfunc=ATP_WrapVMath<CR>g@"
exe "nmap <buffer> ".g:atp_vmap_bracket_leader."M :set opfunc=ATP_WrapWMath<CR>g@"
endif

" BRACKETS: {{{2
if !empty(g:atp_vmap_bracket_leader)
if !hasmapto(":Wrap ( ) begin<cr>", 'v')
    execute "vnoremap <silent> <buffer> ".g:atp_vmap_bracket_leader."( 	:Wrap ( ) begin<CR>"
endif
function! ATP_WrapKet_1_begin(type)
    if a:type == "block" | return | endif
    call atplib#various#WrapSelection('(', ')', 'begin', 0, ["'[", "']"])
endfunction
exe "nmap <silent> <buffer> ".g:atp_vmap_bracket_leader."( :set opfunc=ATP_WrapKet_1_begin<CR>g@"
if !hasmapto(":Wrap ( ) end<cr>", 'v')
    execute "vnoremap <silent> <buffer> ".g:atp_vmap_bracket_leader.") 	:Wrap ( ) end<CR>"
endif
function! ATP_WrapKet_1_end(type)
    if a:type == "block" | return | endif
    call atplib#various#WrapSelection('(', ')', 'end', 0, ["'[", "']"])
endfunction
exe "nmap <silent> <buffer> ".g:atp_vmap_bracket_leader.") :set opfunc=ATP_WrapKet_1_end<CR>g@"
if !hasmapto(":Wrap [ ] begin<cr>", 'v')
    execute "vnoremap <silent> <buffer> ".g:atp_vmap_bracket_leader."[ 	:Wrap [ ] begin<CR>"
endif
function! ATP_WrapKet_2_begin(type)
    if a:type == "block" | return | endif
    call atplib#various#WrapSelection('[', ']', 'begin', 0, ["'[", "']"])
endfunction
exe "nmap <silent> <buffer> ".g:atp_vmap_bracket_leader."[ :set opfunc=ATP_WrapKet_2_begin<CR>g@"
if !hasmapto(":Wrap [ ] end<cr>", 'v')
    execute "vnoremap <silent> <buffer> ".g:atp_vmap_bracket_leader."] 	:Wrap [ ] end<CR>"
endif
function! ATP_WrapKet_2_end(type)
    if a:type == "block" | return | endif
    call atplib#various#WrapSelection('[', ']', 'end', 0, ["'[", "']"])
endfunction
exe "nmap <silent> <buffer> ".g:atp_vmap_bracket_leader."] :set opfunc=ATP_WrapKet_2_end<CR>g@"
if !hasmapto(":Wrap ".s:backslash."{ ".s:backslash."} begin<cr>", 'v')
    execute "vnoremap <silent> <buffer> ".g:atp_vmap_bracket_leader.s:backslash."{	:Wrap ".s:backslash."{ ".s:backslash."} begin<CR>"
endif
function! ATP_WrapKet_3_begin(type)
    if a:type == "block" | return | endif
    call atplib#various#WrapSelection('\{', '\}', 'begin', 0, ["'[", "']"])
endfunction
exe "nmap <silent> <buffer> ".g:atp_vmap_bracket_leader.s:backslash."{ :set opfunc=ATP_WrapKet_3_begin<CR>g@"
if !hasmapto(":Wrap ".s:backslash."} ".s:backslash."} end<cr>", 'v')
    execute "vnoremap <silent> <buffer> ".g:atp_vmap_bracket_leader.s:backslash."}	:Wrap ".s:backslash."{ ".s:backslash."} end<CR>"
endif
function! ATP_WrapKet_3_end(type)
    if a:type == "block" | return | endif
    call atplib#various#WrapSelection('\{', '\}', 'end', 0, ["'[", "']"])
endfunction
exe "nmap <silent> <buffer> ".g:atp_vmap_bracket_leader.s:backslash."} :set opfunc=ATP_WrapKet_3_end<CR>g@"
" This is defined before:
" if !hasmapto(":Wrap { } begin<cr>", 'v')
"     execute "vnoremap <silent> <buffer> ".g:atp_vmap_bracket_leader."{ 	:Wrap { } begin<CR>"
" endif
function! ATP_WrapKet_4_begin(type)
    if a:type == "block" | return | endif
    call atplib#various#WrapSelection('{', '}', 'begin', 0, ["'[", "']"])
endfunction
exe "nmap <silent> <buffer> ".g:atp_vmap_bracket_leader."{ :set opfunc=ATP_WrapKet_4_begin<CR>g@"
if !hasmapto(":Wrap { } end<cr>", 'v')
    execute "vnoremap <silent> <buffer> ".g:atp_vmap_bracket_leader."}	:Wrap { } end<CR>"
endif
function! ATP_WrapKet_4_end(type)
    if a:type == "block" | return | endif
    call atplib#various#WrapSelection('{', '}', 'end', 0, ["'[", "']"])
endfunction
exe "nmap <silent> <buffer> ".g:atp_vmap_bracket_leader."} :set opfunc=ATP_WrapKet_4_end<CR>g@"
if !hasmapto(":Wrap < > begin<cr>", 'v')
    execute "vnoremap <silent> <buffer> ".g:atp_vmap_bracket_leader."< 	:Wrap < > begin<CR>"
endif
function! ATP_WrapKet_5_begin(type)
    if a:type == "block" | return | endif
    call atplib#various#WrapSelection('<', '>', 'begin', 0, ["'[", "']"])
endfunction
exe "nmap <silent> <buffer> ".g:atp_vmap_bracket_leader."< :set opfunc=ATP_WrapKet_5_begin<CR>g@"
if !hasmapto(":Wrap < > end<cr>", 'v')
    execute "vnoremap <silent> <buffer> ".g:atp_vmap_bracket_leader."> 	:Wrap < > end<CR>"
endif
function! ATP_WrapKet_5_end(type)
    if a:type == "block" | return | endif
    call atplib#various#WrapSelection('<', '>', 'end', 0, ["'[", "']"])
endfunction
exe "nmap <silent> <buffer> ".g:atp_vmap_bracket_leader."> :set opfunc=ATP_WrapKet_5_end<CR>g@"
endif
if !empty(g:atp_vmap_big_bracket_leader)
if !hasmapto(":Wrap ".s:backslash."left( ".s:backslash."right) end<CR>", 'v')
    execute "vnoremap <silent> <buffer> ".g:atp_vmap_big_bracket_leader.")	:Wrap ".s:backslash."left( ".s:backslash."right) end<CR>"
endif
function! ATP_WrapBigKet_1_end(type)
    if a:type == "block" | return | endif
    call atplib#various#WrapSelection('\left(', '\right)', 'end', 0, ["'[", "']"])
endfunction
exe "nmap <silent> <buffer> ".g:atp_vmap_big_bracket_leader.") :set opfunc=ATP_WrapBigKet_1_end<CR>g@"
if !hasmapto(":Wrap ".s:backslash."left[ ".s:backslash."right] end<cr>", 'v')
    execute "vnoremap <silent> <buffer> ".g:atp_vmap_big_bracket_leader."]	:Wrap ".s:backslash."left[ ".s:backslash."right] end<cr>"
endif
function! ATP_WrapBigKet_2_end(type)
    if a:type == "block" | return | endif
    call atplib#various#WrapSelection('\left[', '\right]', 'end', 0, ["'[", "']"])
endfunction
exe "nmap <silent> <buffer> ".g:atp_vmap_big_bracket_leader."] :set opfunc=ATP_WrapBigKet_2_end<CR>g@"
if !hasmapto(":Wrap ".s:backslash."left".s:backslash."{ ".s:backslash."right".s:backslash."} end<CR>", 'v')
    execute "vnoremap <silent> <buffer> ".g:atp_vmap_big_bracket_leader.s:backslash."}	:Wrap ".s:backslash."left".s:backslash."{ ".s:backslash."right".s:backslash."} end<CR>"
endif
function! ATP_WrapBigKet_3_end(type)
    if a:type == "block" | return | endif
    call atplib#various#WrapSelection('\left\{', '\right\}', 'end', 0, ["'[", "']"])
endfunction
exe "nmap <silent> <buffer> ".g:atp_vmap_big_bracket_leader.s:backslash."} :set opfunc=ATP_WrapBigKet_3_end<CR>g@"
" for compatibility:
if !hasmapto(":Wrap ".s:backslash."left( ".s:backslash."right) begin<CR>", 'v')
    execute "vnoremap <silent> <buffer> ".g:atp_vmap_big_bracket_leader."(	:Wrap ".s:backslash."left( ".s:backslash."right) begin<CR>"
endif
function! ATP_WrapBigKet_1_begin(type)
    if a:type == "block" | return | endif
    call atplib#various#WrapSelection('\left(', '\right)', 'begin', 0, ["'[", "']"])
endfunction
exe "nmap <silent> <buffer> ".g:atp_vmap_big_bracket_leader."( :set opfunc=ATP_WrapBigKet_1_begin<CR>g@"
if !hasmapto(":Wrap ".s:backslash."left[ ".s:backslash."right] begin<CR>", 'v')
    execute "vnoremap <silent> <buffer> ".g:atp_vmap_big_bracket_leader."[	:Wrap ".s:backslash."left[ ".s:backslash."right] begin<CR>"
endif
function! ATP_WrapBigKet_2_begin(type)
    if a:type == "block" | return | endif
    call atplib#various#WrapSelection('\left[', '\right]', 'begin', 0, ["'[", "']"])
endfunction
exe "nmap <silent> <buffer> ".g:atp_vmap_big_bracket_leader."[ :set opfunc=ATP_WrapBigKet_2_begin<CR>g@"
if !hasmapto(":Wrap ".s:backslash."left".s:backslash."{ ".s:backslash."right".s:backslash."} begin<CR>", 'v')
    execute "vnoremap <silent> <buffer> ".g:atp_vmap_big_bracket_leader.s:backslash."{	:Wrap ".s:backslash."left".s:backslash."{ ".s:backslash."right".s:backslash."} begin<CR>"
    execute "vnoremap <silent> <buffer> ".g:atp_vmap_big_bracket_leader."{	:Wrap ".s:backslash."left".s:backslash."{ ".s:backslash."right".s:backslash."} begin<CR>"
endif
function! ATP_WrapBigKet_3_begin(type)
    if a:type == "block" | return | endif
    call atplib#various#WrapSelection('\left\{', '\right\}', 'begin', 0, ["'[", "']"])
endfunction
exe "nmap <silent> <buffer> ".g:atp_vmap_big_bracket_leader.s:backslash."{ :set opfunc=ATP_WrapBigKet_3_begin<CR>g@"
exe "nmap <silent> <buffer> ".g:atp_vmap_big_bracket_leader."{ :set opfunc=ATP_WrapBigKet_3_begin<CR>g@"
if !hasmapto(":Wrap ".s:backslash."left".s:backslash."{ ".s:backslash."right".s:backslash."} end<CR>", 'v')
    execute "vnoremap <silent> <buffer> ".g:atp_vmap_big_bracket_leader."}	:Wrap ".s:backslash."left".s:backslash."{ ".s:backslash."right".s:backslash."} end<CR>"
    execute "vnoremap <silent> <buffer> ".g:atp_vmap_big_bracket_leader.s:backslash."}	:Wrap ".s:backslash."left".s:backslash."{ ".s:backslash."right".s:backslash."} end<CR>"
endif
endif

" ACCENTS: {{{2
if !empty(g:atp_imap_over_leader)
if !hasmapto(":<C-U>IWrap ['".s:backslash."''{'],['".s:backslash."acute{']<CR>", "v")
    execute "vnoremap <silent> <buffer> ".g:atp_imap_over_leader."' 		:<C-U>IWrap ['".s:backslash."''{'],['".s:backslash."acute{']<CR>"
endif
if !hasmapto(":<C-U>Wrap ".s:backslash."\"{ } end<CR>", "v")
    execute "vnoremap <silent> <buffer> ".g:atp_imap_over_leader."\"		:<C-U>Wrap ".s:backslash."\"{ } end<CR>"
endif
if !hasmapto(":<C-U>Wrap ".s:backslash."^{ } end<CR>", "v")
    execute "vnoremap <silent> <buffer> ".g:atp_imap_over_leader."^		:<C-U>Wrap ".s:backslash."^{ } end<CR>"
endif
if !hasmapto(":<C-U>IWrap ['".s:backslash."v{'],['".s:backslash."check{']<CR>", "v")
    execute "vnoremap <silent> <buffer> ".g:atp_imap_over_leader."v 		:<C-U>IWrap ['".s:backslash."v{'],['".s:backslash."check{']<CR>"
endif
if !hasmapto(":<C-U>IWrap ['".s:backslash."`{'],['".s:backslash."grave{']<CR>", "v")
    execute "vnoremap <silent> <buffer> ".g:atp_imap_over_leader."` 		:<C-U>IWrap ['".s:backslash."`{'],['".s:backslash."grave{']<CR>"
endif
if !hasmapto(":<C-U>Wrap ".s:backslash."b{ } end<CR>", "v")
    execute "vnoremap <silent> <buffer> ".g:atp_imap_over_leader."b		:<C-U>Wrap ".s:backslash."b{ } end<CR>"
endif
if !hasmapto(":<C-U>Wrap ".s:backslash."d{ } end<CR>", "v")
    execute "vnoremap <silent> <buffer> ".g:atp_imap_over_leader."d		:<C-U>Wrap ".s:backslash."d{ } end<CR>"
endif
if !hasmapto(":<C-U>Wrap ".s:backslash."H{ } end<CR>", "v")
    execute "vnoremap <silent> <buffer> ".g:atp_imap_over_leader."H		:<C-U>Wrap ".s:backslash."H{ } end<CR>"
endif
if !hasmapto(":<C-U>Wrap ".s:backslash."~{ } end<CR>", "v")
    execute "vnoremap <silent> <buffer> ".g:atp_imap_over_leader."~		:<C-U>Wrap ".s:backslash."~{ } end<CR>"
endif
if !hasmapto(":<C-U>IWrap ['".s:backslash.".{'],['".s:backslash."dot{']<CR>", "v")
    execute "vnoremap <silent> <buffer> ".g:atp_imap_over_leader.". 		:<C-U>IWrap ['".s:backslash.".{'],['".s:backslash."dot{']<CR>"
endif
if !hasmapto(":<C-U>Wrap ".s:backslash."c{ } end<CR>", "v")
    execute "vnoremap <silent> <buffer> ".g:atp_imap_over_leader."c		:<C-U>Wrap ".s:backslash."c{ } end<CR>"
endif
if !hasmapto(":<C-U>Wrap ".s:backslash."t{ } end<CR>", "v")
    execute "vnoremap <silent> <buffer> ".g:atp_imap_over_leader."t		:<C-U>Wrap ".s:backslash."t{ } end<CR>"
endif
execute "vnoremap <silent> <buffer> <expr>".g:atp_imap_over_leader."~		':<C-U>Wrap ".s:backslash."'.(g:atp_imap_wide ? \"wide\" : \"\").'tilde{ } end<CR>'"
endif

" TEX ALIGN: {{{1
if !hasmapto("<Plug>TexAlign", 'n')
    nmap <silent> <buffer> <Localleader>a	<Plug>TexAlign
endif
if !hasmapto("<Plug>TexAlign", 'v')
    vmap <silent> <buffer> <localleader>a	<Plug>vTexAlign
endif
" PARAGRAPH SELECTION: {{{1
if !hasmapto("<Plug>ATP_SelectCurrentParagraphInner", 'v')
    vmap <silent> <buffer> ip 	<Plug>ATP_SelectCurrentParagraphInner
endif
if !hasmapto("<Plug>ATP_SelectCurrentParagraphOuter", 'v')
    vmap <silent> <buffer> ap 	<Plug>ATP_SelectCurrentParagraphOuter
endif
if !hasmapto(" vip<CR>", "o")
    omap <silent> <buffer>  ip	:normal vip<CR>
endif
if !hasmapto(" vap<CR>", "o")
    omap <silent> <buffer>  ap	:normal vap<CR>
endif
" FORMATING: {{{1
if !hasmapto("<Plug>FormatLines", "n")
    nmap <buffer> gW		<Plug>FormatLines
endif
" SELECT SYNTAX: {{{1
if !hasmapto("<Plug>SelectOuterSyntax", "v")
    vmap <buffer> <silent> aS		<Plug>SelectOuterSyntax
endif
if !hasmapto("<Plug>SelectInnerSyntax", "v")
    vmap <buffer> <silent> iS		<Plug>SelectInnerSyntax
endif
" ENVIRONMENT MOVES: {{{1
" From vim.vim plugin (by Bram Mooleaner)
" Move around functions.
if !hasmapto("<Plug>GotoPreviousEnvironment", "n")
    nmap <silent> <buffer> [[ <Plug>GotoPreviousEnvironment
endif
exe "vnoremap <silent> <buffer> <Plug>vBegPrevEnvironment m`:<C-U>exe \"normal! gv\"<Bar>call search('".s:bbackslash."begin".s:backslash."s*{".s:bbackslash."|".s:backslash.s:bbackslash."@<!".s:backslash.s:bbackslash."[".s:bbackslash."|".s:backslash.s:bbackslash."@<!".s:backslash."$".s:backslash."$', 'bW')<CR>"
if !hasmapto("<Plug>vBegPrevEnvironment", "v")
    vmap <silent> <buffer> [[ <Plug>vBegPrevEnvironment
endif
exe "nnoremap <silent> <buffer> <Plug>BegNextEnvironment m`:call search('".s:bbackslash."begin".s:backslash."s*{".s:bbackslash."|".s:backslash.s:bbackslash."@<!".s:backslash.s:bbackslash."[".s:bbackslash."|".s:backslash.s:bbackslash."@<!".s:backslash."$".s:backslash."$', 'W')<CR>"
if !hasmapto("<Plug>GotoNextEnvironment", "n")
    nmap <silent> <buffer> ]] <Plug>GotoNextEnvironment
endif
exe "vnoremap <silent> <buffer> <Plug>vBegNextEnvironment m`:<C-U>exe \"normal! gv\"<Bar>call search('".s:bbackslash."begin".s:backslash."s*{".s:bbackslash."|".s:backslash.s:bbackslash."@<!".s:backslash.s:bbackslash."[".s:bbackslash."|".s:backslash.s:bbackslash."@<!".s:backslash."$".s:backslash."$', 'W')<CR>"
if !hasmapto("<Plug>vBegNextEnvironment", "v")
    vmap <silent> <buffer> ]] <Plug>vBegNextEnvironment
endif
exe "nnoremap <silent> <buffer> <Plug>EndPrevEnvironment m`:call search('".s:bbackslash."end".s:backslash."s*{".s:bbackslash."|".s:backslash.s:bbackslash."@<!".s:backslash.s:bbackslash."]".s:bbackslash."|".s:backslash.s:bbackslash."@<!".s:backslash."$".s:backslash."$', 'bW')<CR>"
if !hasmapto("<Plug>EndPrevEnvironment", "n")
    nmap <silent> <buffer> [] <Plug>EndPrevEnvironment
endif
exe "vnoremap <silent> <buffer> <Plug>vEndPrevEnvironment m`:<C-U>exe \"normal! gv\"<Bar>call search('".s:bbackslash."end".s:backslash."s*{".s:bbackslash."|".s:backslash.s:bbackslash."@<!".s:backslash.s:bbackslash."]".s:bbackslash."|".s:backslash.s:bbackslash."@<!".s:backslash."$".s:backslash."$', 'bW')<CR>"
if !hasmapto("<Plug>vEndPrevEnvironment", "v")
    vmap <silent> <buffer> [] <Plug>vEndPrevEnvironment
endif
exe "nnoremap <silent> <buffer> <Plug>EndNextEnvironment m`:call search('".s:backslash."%(".s:bbackslash."end".s:backslash."s*{".s:bbackslash."|".s:backslash.s:bbackslash."@<!".s:backslash.s:bbackslash."]".s:bbackslash."|".s:backslash.s:bbackslash."@<!".s:backslash."$".s:backslash."$".s:backslash.")', 'W')<CR>"
if !hasmapto("<Plug>EndNextEnvironment", "n")
    nmap <silent> <buffer> ][ <Plug>EndNextEnvironment
endif
exe "vnoremap <silent> <buffer> <Plug>vEndNextEnvironment m`:<C-U>exe \"normal! gv\"<Bar>call search('".s:bbackslash."end".s:backslash."s*{".s:bbackslash."|".s:backslash.s:bbackslash."@<!".s:backslash.s:bbackslash."]".s:bbackslash."|".s:backslash.s:bbackslash."@<!".s:backslash."$".s:backslash."$', 'W')<CR>"
if !hasmapto("<Plug>vEndNextEnvironment", "v")
    vmap <silent> <buffer> ][ <Plug>vEndNextEnvironment
endif
" SELECT COMMENT: {{{1
if !empty(g:atp_MapSelectComment)
if !hasmapto("v<Plug>vSelectComment", "n")
    exe "nmap <silent> <buffer> ".g:atp_MapSelectComment." v<Plug>vSelectComment"
endif
" if !hasmapto(g:atp_MapSelectComment, "o")
    " It is turned off since it interferes with == operator
    " exe "omap <silent> <buffer>".g:atp_MapSelectComment." :normal ".g:atp_MapSelectComment."<CR>"
" endif
endif
" SELECT FRAME: (beamer) {{{1
" This is done by a function, because it has to be run through an autocommand
" otherwise atplib#search#DocumentClass is not working.
function! <SID>BeamerOptions()
    if atplib#search#DocumentClass(atplib#FullPath(b:atp_MainFile)) == "beamer"
	
	" _f
	if !exists("g:atp_MapSelectFrame")
	    let g:atp_MapSelectFrame = "=f"
	endif

	" =f
	if !hasmapto("<Plug>SelectFrameEnvironment", "n")
	    exe "nmap <silent> <buffer> ".g:atp_MapSelectFrame." <Plug>SelectFrameEnvironment"
	endif

	" >f, <f
	exe "nmap <buffer> <silent> <expr> ".g:atp_map_forward_motion_leader."f ':<C-U>'.v:count1.'F frame<CR>'"
	exe "nmap <buffer> <silent> <expr> ".g:atp_map_backward_motion_leader."f ':<C-U>'.v:count1.'B frame<CR>'"

	" >F, <F
	exe "nmap <buffer> <silent> ".g:atp_map_forward_motion_leader."F <Plug>NextFrame"
	exe "nmap <buffer> <silent> ".g:atp_map_backward_motion_leader."F <Plug>PreviousFrame"
    endif
endfunction
augroup ATP_BeamerOptions
    au!
    au BufEnter *.tex 	call <SID>BeamerOptions()
augroup END
" NORMAL MODE MAPS: (most of them) {{{1

" Enabling this requires uncommenting augroup ATP_Cmdwin in options.vim
" exe "nnoremap  <silent> <buffer> <Plug>QForwardSearch 	q".s:backslash.":call ATP_CmdwinToggleSpace(1)<CR>i"
" if !hasmapto("<Plug>QForwardSearch", "n")
" "     if mapcheck('Q/', 'n') == ""
" 	nmap <silent> <buffer> Q/			<Plug>QForwardSearch
" "     endif
" endif
" exe "nmap <silent> <buffer> <Plug>QBackwardSearch	q?:call ATP_CmdwinToggleSpace(1)<CR>"
" if !hasmapto("<Plug>QBackwardSearch", "n")
" "     if mapcheck('Q?', 'n') == "" && !hasmapto("<Plug>QBackwardSearch", "n")
" 	nmap <silent> <buffer> Q?			<Plug>QBackwardSearch
" "     endif
" endif

if mapcheck('<LocalLeader>s$') == "" && !hasmapto("<Plug>ToggleStar", "n")
    nmap  <silent> <buffer> <LocalLeader>s		<Plug>ToggleStar
elseif !hasmapto("<Plug>ToggleStar", "n") && g:atp_debugMapFile && !g:atp_reload_functions
    echoerr "[ATP:] there will be no nmap to <Plug>ToggleStar"
endif

if !hasmapto("<Plug>TogglesilentMode", "n")
    nmap  <silent> <buffer> <LocalLeader><Localleader>s	<Plug>TogglesilentMode
endif
if !hasmapto("<Plug>ToggledebugMode", "n")
    nmap  <silent> <buffer> <LocalLeader><Localleader>d	<Plug>ToggledebugMode
endif
if !hasmapto("<Plug>ToggleDebugMode", "n")
    nmap  <silent> <buffer> <LocalLeader><Localleader>D	<Plug>ToggleDebugMode
endif
if !hasmapto("<Plug>WrapEnvironment", "v")
    vmap  <silent> <buffer> <F4>			<Plug>WrapEnvironment
endif
if !hasmapto("<Plug>ChangeEnv", "n")
    nmap  <silent> <buffer> <F4>			<Plug>ChangeEnv
endif
if !hasmapto("<Plug>ChangeEnv", "i")
    imap  <silent> <buffer> <F4>			<C-O><Plug>ChangeEnv
endif
if !hasmapto("<Plug>ToggleEnvForward", "n")
    nmap  <silent> <buffer> <S-F4>			<Plug>ToggleEnvForward
endif
"     ToDo:
"     if g:atp_LatexBox
" 	nmap <silent> <buffer> <F3>			:call <Sid>ChangeEnv()<CR>
"     endif
if !hasmapto("<Plug>ATP_ViewOutput", "n")
    nmap  <silent> <buffer> <F3>        		<Plug>ATP_ViewOutput_sync
    nmap  <silent> <buffer> <LocalLeader>v		<Plug>ATP_ViewOutput_nosync
endif
if !hasmapto("<Plug>ATP_ViewLocalOutput", "n")
    nmap  <silent> <buffer> <S-F3>        		<Plug>ATP_ViewLocalOutput_sync
    nmap  <silent> <buffer> <LocalLeader>V		<Plug>ATP_ViewLocalOutput_nosync
endif
if !hasmapto("<Plug>ATP_ViewOutput", "i")
    imap  <silent> <buffer> <F3> 			<C-O><Plug>ATP_ViewOutput_sync
endif
if !hasmapto("<Plug>ATP_ViewLocalOutput", "i")
    imap  <silent> <buffer> <S-F3> 			<C-O><Plug>ATP_ViewLocalOutput_sync
endif
if !hasmapto("<Plug>Getpid", "n")
    nmap  <silent> <buffer> <LocalLeader>g 		<Plug>Getpid
endif
if !hasmapto("<Plug>ATP_TOC", "n")
    nmap  <silent> <buffer> <LocalLeader>t		<Plug>ATP_TOC
endif
if !hasmapto("<Plug>ATP_Labels", "n")
    nmap  <silent> <buffer> <LocalLeader>L		<Plug>ATP_Labels
endif
if !hasmapto("<Plug>ATP_TeXCurrent", "n")
    nmap  <silent> <buffer> <LocalLeader>l 		<Plug>ATP_TeXCurrent
endif
if !hasmapto("<Plug>ATP_TeXLocal", "n")
    nmap <silent> <buffer> <LocalLeader><LocalLeader>l  <Plug>ATP_TeXLocal
endif
if !hasmapto("<Plug>ATP_TeXdebug", "n")
    nmap  <silent> <buffer> <LocalLeader>d 		<Plug>ATP_TeXdebug
endif
if !hasmapto("<Plug>ATP_TeXDebug", "n")
    nmap  <silent> <buffer> <LocalLeader>D 		<Plug>ATP_TeXDebug
endif
" if !hasmapto("<Plug>ATP_MakeLatex", "n")
"      nmap           <buffer> <c-l>			<Plug>ATP_MakeLatex
" endif
"ToDo: imaps!
if !hasmapto("<Plug>ATP_TeXVerbose", "n")
    nmap  <silent> <buffer> <F5> 			<Plug>ATP_TeXVerbose
endif
if !hasmapto("<Plug>ToggleAuTeX", "n")
    nmap  <silent> <buffer> <s-F5> 				<Plug>ToggleAuTeX
endif
if !hasmapto("<Plug>ToggleAuTeXa", "i")
    imap  <silent> <buffer> <s-F5> 			<C-O><Plug>ToggleAuTeX
endif
if !hasmapto("<Plug>ToggleTab", "n") && g:atp_tab_map
    nmap  <silent> <buffer> `<Tab>			<Plug>ToggleTab
endif
if !hasmapto("<Plug>ToggleTab", "i") && g:atp_tab_map
    imap  <silent> <buffer> `<Tab>			<Plug>ToggleTab
endif
if !hasmapto("<Plug>ToggleIMaps", "n")
    nmap  <silent> <buffer> '<Tab>			<Plug>ToggleIMaps
endif
if !hasmapto("<Plug>ToggleIMapsa", "i")
    imap  <silent> <buffer> '<Tab>			<Plug>ToggleIMaps
endif
if !hasmapto("<Plug>SimpleBibtex", "n")
    nmap  <silent> <buffer> <LocalLeader>B		<Plug>SimpleBibtex
endif
if !hasmapto("<Plug>BibtexDefault", "n")
    nmap  <silent> <buffer> <LocalLeader>b		<Plug>BibtexDefault
endif
if !hasmapto("<Plug>Delete", "n")
    nmap  <silent> <buffer> <F6>d 			<Plug>Delete
endif
if !hasmapto("<Plug>Delete", "i")
    imap  <silent> <buffer> <F6>d			<C-O><Plug>Delete
endif
if !hasmapto("<Plug>OpenLog", "n")
    nmap  <silent> <buffer> <F6>l 			<Plug>OpenLog
endif
if !hasmapto("<Plug>OpenLog", "i")
    imap  <silent> <buffer> <F6>l 			<C-O><Plug>OpenLog
endif
if !hasmapto(":ShowErrors e<CR>", "n")
    nmap  <silent> <buffer> <F6> 			:ShowErrors e<CR>
endif
if !hasmapto(":ShowErrors e<CR>", "i")
    imap  <silent> <buffer> <F6> 			:ShowErrors e<CR>
endif
if !hasmapto(":ShowErrors<CR>", "n")
    nmap   <silent> <buffer> <LocalLeader>e		:ShowErrors<CR>
endif
if !hasmapto(":ShowErrors w<CR>", "n")
    nmap  <silent> <buffer> <F6>w 			:ShowErrors w<CR>
endif
if !hasmapto(":ShowErrors w<CR>", "i")
    imap  <silent> <buffer> <F6>w 			:ShowErrors w<CR>
endif
if !hasmapto(":ShowErrors rc<CR>", "n")
    nmap  <silent> <buffer> <F6>r 			:ShowErrors rc<CR>
endif
if !hasmapto(":ShowErrors rc<CR>", "i")
    imap  <silent> <buffer> <F6>r 			:ShowErrors rc<CR>
endif
if !hasmapto(":ShowErrors f<CR>", "n")
    nmap  <silent> <buffer> <F6>f 			:ShowErrors f<CR>
endif
if !hasmapto(":ShowErrors f<CR>", "i")
    imap  <silent> <buffer> <F6>f 			:ShowErrors f<CR>
endif
if !hasmapto("<Plug>PdfFonts", "n")
    nmap  <silent> <buffer> <F6>g 			<Plug>PdfFonts
endif
" TEXDOC: {{{2
" Note :TexDoc map cannot be <silent>
nnoremap           <buffer> <Plug>Texdoc		:Texdoc<space>
if !hasmapto("<Plug>Texdoc", "n")
    nmap           <buffer> <F1>			<Plug>Texdoc
endif
inoremap           <buffer> <Plug>iTexdoc		<C-O>:Texdoc<space>
if !hasmapto("<Plug>iTexdoc", "i")
    imap           <buffer> <F1> 			<Plug>iTexdoc
endif

" FONT IMAPS: {{{1
if g:atp_imap_leader_1 == "]" || g:atp_imap_leader_2 == "]" || g:atp_imap_leader_3 == "]" || g:atp_imap_leader_4 == "]" 
    inoremap <silent> <buffer> ]] ]
endif
if !exists("g:atp_imap_define_fonts")
    let g:atp_imap_define_fonts = 1
endif

let s:math_open = ( &filetype == "plaintex" ? "$" : (&l:cpoptions =~# "B" ? "\\" : "\\\\")."(" )
if (!empty(g:atp_imap_leader_2) && !exists("g:atp_imap_fonts")) || g:atp_reload_variables
    let g:atp_imap_fonts = []
    
    for font in [ 'rm', 'it', 'sf', 'bf', 'tt', 'normal']
	call add(g:atp_imap_fonts, 
	    \ [ 'inoremap', '<silent> <buffer> <expr>', g:atp_imap_leader_2, font, '(atplib#IsInMath() ? "\\math'.font.'{}<Left>" : "\\text'.font.'{}<Left>" )' , "g:atp_imap_define_fonts", '\text'.font ])
    endfor
    for font in [ 'up', 'md', 'sl', 'sc' ]
	call add(g:atp_imap_fonts, 
	    \ [ 'inoremap', '<silent> <buffer>', g:atp_imap_leader_2, font, s:backslash.'text'.font.'{}<Left>', "g:atp_imap_define_fonts", '\text'.font.'{}']
	    \ )
    endfor
    call extend(g:atp_imap_fonts,  [
	    \ [ 'inoremap', '<silent> <buffer>', g:atp_imap_leader_2, 'te', 
		\ s:backslash.'text{}<Left>', "g:atp_imap_define_fonts", '\text{}'],
	    \ [ 'inoremap', '<silent> <buffer>', g:atp_imap_leader_2, 'em', 
		\ s:backslash.'emph{}<Left>', "g:atp_imap_define_fonts", '\emph{}'],
	    \ [ 'inoremap', '<silent> <buffer> <expr>', g:atp_imap_leader_2, 'bb', 
		\ '(atplib#IsInMath() ? "'.s:bbackslash.'mathbb{}<Left>" : ( &filetype == "plaintex" ? "$" : (&l:cpoptions =~# "B" ? "\\" : "\\\\")."(" )."'.s:bbackslash.'mathbb{}<Left>" )' , "g:atp_imap_define_fonts", '\mathbb' ],
	    \ [ 'inoremap', '<silent> <buffer> <expr>', g:atp_imap_leader_2, 'cal', 
		\ '(atplib#IsInMath() ? "'.s:bbackslash.'mathcal{}<Left>" : ( &filetype == "plaintex" ? "$" : (&l:cpoptions =~# "B" ? "\\" : "\\\\")."(" )."'.s:bbackslash.'mathcal{}<Left>" )' , "g:atp_imap_define_fonts", '\mathcal' ],
	    \ [ 'inoremap', '<silent> <buffer> <expr>', g:atp_imap_leader_2, 'cr', 
		\ '(atplib#IsInMath() ? "'.s:bbackslash.'mathscr{}<Left>" : ( &filetype == "plaintex" ? "$" : (&l:cpoptions =~# "B" ? "\\" : "\\\\")."(" )."'.s:bbackslash.'mathscr{}<Left>" )' , "g:atp_imap_define_fonts", '\mathscr' ],
	    \ [ 'inoremap', '<silent> <buffer> <expr>', g:atp_imap_leader_2, 'fr', 
		\ '(atplib#IsInMath() ? "'.s:bbackslash.'mathfrak{}<Left>" : ( &filetype == "plaintex" ? "$" : (&l:cpoptions =~# "B" ? "\\" : "\\\\")."(" )."'.s:bbackslash.'mathfrak{}<Left>" )' , "g:atp_imap_define_fonts", '\mathfrak' ],
	    \ [ 'inoremap', '<silent> <buffer>', g:atp_imap_leader_2, 'uf',
		\ s:backslash.'usefont{'.g:atp_font_encoding.'}{}{}{}<Left><Left><Left><Left><Left>', "g:atp_imap_define_fonts", 'usefont command']
	\ ])
endif
" Make Font Maps:
call atplib#MakeMaps(g:atp_imap_fonts)
" GREEK LETTERS: {{{1
if !exists("g:atp_imap_greek_letters") || g:atp_reload_variables
    if !empty(g:atp_imap_leader_1)
    let g:atp_imap_greek_letters= [
	    \ [ 'inoremap', '<silent> <buffer> <expr>', g:atp_imap_leader_1, 'a', '(!atplib#IsLeft("\\")&& atplib#IsInMath() ? "'.s:bbackslash.'alpha" : g:atp_imap_leader_1."a" )' ,	 
		    \ "g:atp_imap_define_greek_letters", '\alpha' ],
	    \ [ 'inoremap', '<silent> <buffer> <expr>', g:atp_imap_leader_1, 'b', '(!atplib#IsLeft("\\")&& atplib#IsInMath() ? "'.s:bbackslash.'beta" : g:atp_imap_leader_1."b" )',	 
		    \ "g:atp_imap_define_greek_letters", '\beta' ],
	    \ [ 'inoremap', '<silent> <buffer> <expr>', g:atp_imap_leader_1, 'c', '(!atplib#IsLeft("\\")&& atplib#IsInMath() ? "'.s:bbackslash.'chi" : g:atp_imap_leader_1."c" )',	 
		    \ "g:atp_imap_define_greek_letters", '\chi' ],
	    \ [ 'inoremap', '<silent> <buffer> <expr>', g:atp_imap_leader_1, 'd', '(!atplib#IsLeft("\\")&& atplib#IsInMath() ? "'.s:bbackslash.'delta" : g:atp_imap_leader_1."d" )',	 
		    \ "g:atp_imap_define_greek_letters", '\delta' ],
	    \ [ 'inoremap', '<silent> <buffer> <expr>', g:atp_imap_leader_1, 'e', '(!atplib#IsLeft("\\")&& atplib#IsInMath() ? "'.s:bbackslash.'epsilon" : g:atp_imap_leader_1."e" )',	 
		    \ "g:atp_imap_define_greek_letters", '\epsilon' ],
	    \ [ 'inoremap', '<silent> <buffer> <expr>', g:atp_imap_leader_1, 'f', '(!atplib#IsLeft("\\")&& atplib#IsInMath() ? "'.s:bbackslash.'phi" : g:atp_imap_leader_1."f" )',	 
		    \ "g:atp_imap_define_greek_letters", '\phi' ],
	    \ [ 'inoremap', '<silent> <buffer> <expr>', g:atp_imap_leader_1, 'y', '(!atplib#IsLeft("\\")&& atplib#IsInMath() ? "'.s:bbackslash.'psi" : g:atp_imap_leader_1."y" )',	 
		    \ "g:atp_imap_define_greek_letters", '\psi' ],
	    \ [ 'inoremap', '<silent> <buffer> <expr>', g:atp_imap_leader_1, 'g', '(!atplib#IsLeft("\\")&& atplib#IsInMath() ? "'.s:bbackslash.'gamma" : g:atp_imap_leader_1."g" )',	 
		    \ "g:atp_imap_define_greek_letters", '\gamma' ],
	    \ [ 'inoremap', '<silent> <buffer> <expr>', g:atp_imap_leader_1, 'h', '(!atplib#IsLeft("\\")&& atplib#IsInMath() ? "'.s:bbackslash.'eta" : g:atp_imap_leader_1."h" )',	 
		    \ "g:atp_imap_define_greek_letters", '\eta' ],
	    \ [ 'inoremap', '<silent> <buffer> <expr>', g:atp_imap_leader_1, 'k', '(!atplib#IsLeft("\\")&& atplib#IsInMath() ? "'.s:bbackslash.'kappa" : g:atp_imap_leader_1."k" )',	 
		    \ "g:atp_imap_define_greek_letters", '\kappa' ],
	    \ [ 'inoremap', '<silent> <buffer> <expr>', g:atp_imap_leader_1, 'l', '(!atplib#IsLeft("\\")&& atplib#IsInMath() ? "'.s:bbackslash.'lambda" : g:atp_imap_leader_1."l" )',	 
		    \ "g:atp_imap_define_greek_letters", '\lambda' ],
	    \ [ 'inoremap', '<silent> <buffer> <expr>', g:atp_imap_leader_1, 'i', '(!atplib#IsLeft("\\")&& atplib#IsInMath() ? "'.s:bbackslash.'iota" : g:atp_imap_leader_1."i" )',	 
		    \ "g:atp_imap_define_greek_letters", '\iota' ],
	    \ [ 'inoremap', '<silent> <buffer> <expr>', g:atp_imap_leader_1, 'm', '(!atplib#IsLeft("\\")&& atplib#IsInMath() ? "'.s:bbackslash.'mu" : g:atp_imap_leader_1."m" )',	 
		    \ "g:atp_imap_define_greek_letters", '\mu' ],
	    \ [ 'inoremap', '<silent> <buffer> <expr>', g:atp_imap_leader_1, 'n', '(!atplib#IsLeft("\\")&& atplib#IsInMath() ? "'.s:bbackslash.'nu" : g:atp_imap_leader_1."n" )',	 
		    \ "g:atp_imap_define_greek_letters", '\nu' ],
	    \ [ 'inoremap', '<silent> <buffer> <expr>', g:atp_imap_leader_1, 'p', '(!atplib#IsLeft("\\")&& atplib#IsInMath() ? "'.s:bbackslash.'pi" : g:atp_imap_leader_1."p" )',	 
		    \ "g:atp_imap_define_greek_letters", '\pi' ],
	    \ [ 'inoremap', '<silent> <buffer> <expr>', g:atp_imap_leader_1, 'o', '(!atplib#IsLeft("\\")&& atplib#IsInMath() ? "'.s:bbackslash.'theta" : g:atp_imap_leader_1."o" )',	 
		    \ "g:atp_imap_define_greek_letters", '\theta' ],
	    \ [ 'inoremap', '<silent> <buffer> <expr>', g:atp_imap_leader_1, 'r', '(!atplib#IsLeft("\\")&& atplib#IsInMath() ? "'.s:bbackslash.'rho" : g:atp_imap_leader_1."r" )',	 
		    \ "g:atp_imap_define_greek_letters", '\rho' ],
	    \ [ 'inoremap', '<silent> <buffer> <expr>', g:atp_imap_leader_1, 's', '(!atplib#IsLeft("\\")&& atplib#IsInMath() ? "'.s:bbackslash.'sigma" : g:atp_imap_leader_1."s" )',	 
		    \ "g:atp_imap_define_greek_letters", '\sigma' ],
	    \ [ 'inoremap', '<silent> <buffer> <expr>', g:atp_imap_leader_1, 't', '(!atplib#IsLeft("\\")&& atplib#IsInMath() ? "'.s:bbackslash.'tau" : g:atp_imap_leader_1."t" )',	 
		    \ "g:atp_imap_define_greek_letters", '\tau' ],
	    \ [ 'inoremap', '<silent> <buffer> <expr>', g:atp_imap_leader_1, 'u', '(!atplib#IsLeft("\\")&& atplib#IsInMath() ? "'.s:bbackslash.'upsilon" : g:atp_imap_leader_1."u" )',	 
		    \ "g:atp_imap_define_greek_letters", '\upsilon' ],
	    \ [ 'inoremap', '<silent> <buffer> <expr>', g:atp_imap_leader_1, 'w', '(!atplib#IsLeft("\\")&& atplib#IsInMath() ? "'.s:bbackslash.'omega" : g:atp_imap_leader_1."w" )',	 
		    \ "g:atp_imap_define_greek_letters", '\omega' ],
	    \ [ 'inoremap', '<silent> <buffer> <expr>', g:atp_imap_leader_1, 'x', '(!atplib#IsLeft("\\")&& atplib#IsInMath() ? "'.s:bbackslash.'xi" : g:atp_imap_leader_1."x" )',	 
		    \ "g:atp_imap_define_greek_letters", '\xi' ],
	    \ [ 'inoremap', '<silent> <buffer> <expr>', g:atp_imap_leader_1, 'z', '(!atplib#IsLeft("\\")&& atplib#IsInMath() ? "'.s:bbackslash.'zeta" : g:atp_imap_leader_1."z" )',	 
		    \ "g:atp_imap_define_greek_letters", '\zeta' ],
	    \ [ 'inoremap', '<silent> <buffer> <expr>', g:atp_imap_leader_1, 've', '(!atplib#IsLeft("\\")&& atplib#IsInMath() ? "'.s:bbackslash.'varepsilon" : g:atp_imap_leader_1."ve" )', 
		    \ "g:atp_imap_define_greek_letters", '\varepsilon' ],
	    \ [ 'inoremap', '<silent> <buffer> <expr>', g:atp_imap_leader_1, 'vs', '(!atplib#IsLeft("\\")&& atplib#IsInMath() ? "'.s:bbackslash.'varsigma" : g:atp_imap_leader_1."vs" )', 	 
		    \ "g:atp_imap_define_greek_letters", '\varsigma' ],
	    \ [ 'inoremap', '<silent> <buffer> <expr>', g:atp_imap_leader_1, 'vo', '(!atplib#IsLeft("\\")&& atplib#IsInMath() ? "'.s:bbackslash.'vartheta" : g:atp_imap_leader_1."vo" )',	 
		    \ "g:atp_imap_define_greek_letters", '\vartheta' ],
	    \ [ 'inoremap', '<silent> <buffer> <expr>', g:atp_imap_leader_1, 'vf', '(!atplib#IsLeft("\\")&& atplib#IsInMath() ? "'.s:bbackslash.'varphi" : g:atp_imap_leader_1."vf" )',	 
		    \ "g:atp_imap_define_greek_letters", '\varphi' ],
	    \ [ 'inoremap', '<silent> <buffer> <expr>', g:atp_imap_leader_1, 'vp', '(!atplib#IsLeft("\\")&& atplib#IsInMath() ? "'.s:bbackslash.'varpi" : g:atp_imap_leader_1."vp" )',	 
		    \ "g:atp_imap_define_greek_letters", '\varpi' ],
	    \ [ 'inoremap', '<silent> <buffer> <expr>', g:atp_imap_leader_1, 'X', '(!atplib#IsLeft("\\")&& atplib#IsInMath() ? "'.s:bbackslash.'Xi" : g:atp_imap_leader_1."X" )',	 
		    \ "g:atp_imap_define_greek_letters", '\Xi' ],
	    \ [ 'inoremap', '<silent> <buffer> <expr>', g:atp_imap_leader_1, 'D', '(!atplib#IsLeft("\\")&& atplib#IsInMath() ? "'.s:bbackslash.'Delta" : g:atp_imap_leader_1."D" )',	 
		    \ "g:atp_imap_define_greek_letters", '\Delta' ],
	    \ [ 'inoremap', '<silent> <buffer> <expr>', g:atp_imap_leader_1, 'Y', '(!atplib#IsLeft("\\")&& atplib#IsInMath() ? "'.s:bbackslash.'Psi" : g:atp_imap_leader_1."Y" )',	 
		    \ "g:atp_imap_define_greek_letters", '\Psi' ],
	    \ [ 'inoremap', '<silent> <buffer> <expr>', g:atp_imap_leader_1, 'F', '(!atplib#IsLeft("\\")&& atplib#IsInMath() ? "'.s:bbackslash.'Phi" : g:atp_imap_leader_1."F" )',	 
		    \ "g:atp_imap_define_greek_letters", '\Phi' ],
	    \ [ 'inoremap', '<silent> <buffer> <expr>', g:atp_imap_leader_1, 'G', '(!atplib#IsLeft("\\")&& atplib#IsInMath() ? "'.s:bbackslash.'Gamma" : g:atp_imap_leader_1."G" )',	 
		    \ "g:atp_imap_define_greek_letters", '\Gamma' ],
	    \ [ 'inoremap', '<silent> <buffer> <expr>', g:atp_imap_leader_1, 'L', '(!atplib#IsLeft("\\")&& atplib#IsInMath() ? "'.s:bbackslash.'Lambda" : g:atp_imap_leader_1."L" )',	 
		    \ "g:atp_imap_define_greek_letters", '\Lambda' ],
	    \ [ 'inoremap', '<silent> <buffer> <expr>', g:atp_imap_leader_1, 'P', '(!atplib#IsLeft("\\")&& atplib#IsInMath() ? "'.s:bbackslash.'Pi" : g:atp_imap_leader_1."P" )',	 
		    \ "g:atp_imap_define_greek_letters", '\Pi' ],
	    \ [ 'inoremap', '<silent> <buffer> <expr>', g:atp_imap_leader_1, 'O', '(!atplib#IsLeft("\\")&& atplib#IsInMath() ? "'.s:bbackslash.'Theta" : g:atp_imap_leader_1."O" )',	 
		    \ "g:atp_imap_define_greek_letters", '\Theta' ],
	    \ [ 'inoremap', '<silent> <buffer> <expr>', g:atp_imap_leader_1, 'S', '(!atplib#IsLeft("\\")&& atplib#IsInMath() ? "'.s:bbackslash.'Sigma" : g:atp_imap_leader_1."S" )',	 
		    \ "g:atp_imap_define_greek_letters", '\Sigma' ],
	    \ [ 'inoremap', '<silent> <buffer> <expr>', g:atp_imap_leader_1, 'U', '(!atplib#IsLeft("\\")&& atplib#IsInMath() ? "'.s:bbackslash.'Upsilon" : g:atp_imap_leader_1."U" )',	 
		    \ "g:atp_imap_define_greek_letters", '\Upsilon' ],
	    \ [ 'inoremap', '<silent> <buffer> <expr>', g:atp_imap_leader_1, 'W', '(!atplib#IsLeft("\\")&& atplib#IsInMath() ? "'.s:bbackslash.'Omega" : g:atp_imap_leader_1."W" )',	 
		    \ "g:atp_imap_define_greek_letters", '\Omega' ],
	    \ ]
    else
	let g:atp_imap_greek_letters = []
    endif
endif

    " Make Greek Letters:
    augroup ATP_MathIMaps_GreekLetters
	au!
	" au CursorMovedI	*.tex 	:call atplib#ToggleIMaps(g:atp_imap_greek_letters, 'CursorMovedI', [], 1)
	au CursorHoldI 	*.tex 	:call atplib#ToggleIMaps(g:atp_imap_greek_letters, 'CursorHoldI')
	au InsertEnter	*.tex 	:call atplib#ToggleIMaps(g:atp_imap_greek_letters, 'InsertEnter') 
	" Make imaps visible with :imap /this will not work with i_CTRL-C/
	" au InsertLeave	*.tex 	:call atplib#MakeMaps(g:atp_imap_greek_letters, 'InsertLeave')
	" au BufEnter	*.tex 	:call atplib#MakeMaps(g:atp_imap_greek_letters, 'BufEnter')
    augroup END
" MISCELLANEOUS MATHEMATICAL MAPS: {{{1
if !exists("g:atp_imap_math_misc") || g:atp_reload_variables
let g:atp_imap_math_misc = [
\ [ 'inoremap', '<silent> <buffer> <expr>', '+',	      '+', 
	\ '!atplib#IsLeft("^")&&!atplib#IsLeft("_") ? '''.s:backslash.'sum'' : "++"',
	\ "g:atp_imap_define_math_misc", '\sum' ],
\ [ 'inoremap', '<silent> <buffer> <expr>', '<bar>', '-', 'getline(".")[:col(".")-2] !~ ''\\draw\s*\[[^\]]*$'' ? "\\vdash" : "\|-"',
	\ "g:atp_imap_define_math_misc", '\sum' ],
\ [ 'inoremap', '<silent> <buffer> <expr>', '-', '<bar>', 'getline(".")[:col(".")-2] !~ ''\\draw\s*\[[^\]]*$'' ? "\\dashv" : "\|-"',
	\ "g:atp_imap_define_math_misc", '\dashv' ],
\ ]
let s:misc_infty_leader = [
\ [ 'inoremap', '<silent> <buffer>', g:atp_infty_leader,      '8', s:backslash.'infty', 	
	\ "g:atp_imap_define_math_misc", '\infty' ],
\ [ 'inoremap', '<silent> <buffer>', g:atp_infty_leader,      '6', s:backslash.'partial',	
	\ "g:atp_imap_define_math_misc", '\partial' ],
\ ]
if !empty(g:atp_infty_leader)
    call extend(g:atp_imap_math_misc, s:misc_infty_leader)
endif
let s:misc_over_leader = [
\ [ 'inoremap', '<silent> <buffer>', g:atp_imap_over_leader,  '`', s:backslash.'grave{}<Left>',
	\ "g:atp_imap_define_math_misc", '\grave{}' ],
\ [ 'inoremap', '<silent> <buffer>', g:atp_imap_over_leader,  'v', s:backslash.'check{}<Left>',
	\ "g:atp_imap_define_math_misc", '\check{}' ],
\ [ 'inoremap', '<silent> <buffer>', g:atp_imap_over_leader,  "'", s:backslash.'acute{}<Left>',
	\ "g:atp_imap_define_math_misc", '\acute{}' ],
\ [ 'inoremap', '<silent> <buffer>', g:atp_imap_over_leader,  '.', s:backslash.'dot{}<Left>',
	\ "g:atp_imap_define_math_misc", '\dot{}' ],
\ [ 'inoremap', '<silent> <buffer>', g:atp_imap_over_leader,  '>', s:backslash.'vec{}<Left>',
	\ "g:atp_imap_define_math_misc", '\vec{}' ],
\ [ 'inoremap', '<silent> <buffer>', g:atp_imap_over_leader,  '_', s:backslash.'bar{}<Left>',
	\ "g:atp_imap_define_math_misc", '\bar{}' ],
\ [ 'inoremap', '<silent> <buffer>', g:atp_imap_over_leader,  '~', s:backslash.'=(g:atp_imap_wide ? "wide" : "")<CR>tilde{}<Left>',
	\ "g:atp_imap_define_math_misc", '''\''.(g:atp_imap_wide ? "wide" : "")."tilde"' ],
\ [ 'inoremap', '<silent> <buffer>', g:atp_imap_over_leader,  '^', s:backslash.'=(g:atp_imap_wide ? "wide" : "" )<CR>hat{}<Left>',
	\ "g:atp_imap_define_math_misc", '''\''.(g:atp_imap_wide ? "wide" : "")."hat"' ], 
\ [ 'inoremap', '<silent> <buffer> <expr>', g:atp_imap_over_leader,  	      'D', '"<ESC>vx".(col(".")<=len(getline("."))? "i" : "a" )."'.s:bbackslash.'frac{'.s:bbackslash.'partial}{'.s:bbackslash.'partial \"}".(g:atp_imap_diffop_move ? "<C-o>F}<space>" : "")', 
	\ "g:atp_imap_define_math_misc", '\frac{\partial}{\partial x} - x comes from the letter wrote just before' ]
\ ]
if !empty(g:atp_imap_over_leader)
    call extend(g:atp_imap_math_misc, s:misc_over_leader)
endif
let s:misc_leader_2 = [
\ [ 'inoremap', '<silent> <buffer>', g:atp_imap_leader_2,  'ov', s:backslash.'overline{}<Left>',
	\ "g:atp_imap_define_math_misc", '\overline{}' ],
\ [ 'inoremap', '<silent> <buffer>', g:atp_imap_leader_2,  'un', s:backslash.'underline{}<Left>',
	\ "g:atp_imap_define_math_misc", '\underline{}' ],
\ ]
if !empty(g:atp_imap_leader_2)
    call extend(g:atp_imap_math_misc, s:misc_leader_2)
endif
let s:misc_leader_1 = [
    \ [ 'inoremap', '<silent> <buffer>', g:atp_imap_leader_1, '&', s:backslash.'wedge',	    
    \ "g:atp_imap_define_math_misc", '\wedge' ], 
    \ [ 'inoremap', '<silent> <buffer>', g:atp_imap_leader_1, '+', s:backslash.'bigcup',    
    \ "g:atp_imap_define_math_misc", '\bigcup' ],
    \ [ 'inoremap', '<silent> <buffer>', g:atp_imap_leader_1, '*', s:backslash.'bigcap',    
    \ "g:atp_imap_define_math_misc", '\bigcap' ],
    \ [ 'inoremap', '<silent> <buffer>', g:atp_imap_leader_1, 'N', s:backslash.'Nabla',	    
    \ "g:atp_imap_define_math_misc", '\Nabla' ],
    \ [ 'inoremap', '<silent> <buffer>', g:atp_imap_leader_1, '@', s:backslash.'circ',	
    \ "g:atp_imap_define_math_misc", '\circ' ],
    \ [ 'inoremap', '<silent> <buffer>', g:atp_imap_leader_1, '=', s:backslash.'equiv',	    
    \ "g:atp_imap_define_math_misc", '\equiv' ],
    \ [ 'inoremap', '<silent> <buffer>', g:atp_imap_leader_1, '.', s:backslash.'dot', 
    \ "g:atp_imap_define_math_misc", '\dot' ],
    \ [ 'inoremap', '<silent> <buffer>', g:atp_imap_leader_1, '/', s:backslash.'frac{}{}<Esc>F}i',
    \ "g:atp_imap_define_math_misc", '\frac{}{}' ],
    \ ]
if !empty(g:atp_imap_leader_1)
    call extend(g:atp_imap_math_misc, s:misc_leader_1)
endif

" These two maps where interfering with \varepsilon
" \ [ 'inoremap', '<silent> <buffer>', g:atp_imap_leader_1, 've', s:backslash.'vee',
" 	\ "g:atp_imap_define_math_misc", '\vee' ],
" \ [ 'inoremap', '<silent> <buffer>', g:atp_imap_leader_1, 'V', s:backslash.'bigvee',
" 	\ "g:atp_imap_define_math_misc", '\Vee' ],

" " 		\ [ 'inoremap', '<silent> <buffer>', g:atp_imap_leader_1, '~', s:backslash.'=(g:atp_imap_wide ? "wide" : "")<CR>tilde{}<Left>', 	"g:atp_imap_define_math_misc", '''\''.(g:atp_imap_wide ? "wide" : "")."tilde"' ],
" 		\ [ 'inoremap', '<silent> <buffer>', g:atp_imap_leader_1, '^', s:backslash.'=(g:atp_imap_wide ? "wide" : "" )<CR>hat{}<Left>', 	"g:atp_imap_define_math_misc", '''\''.(g:atp_imap_wide ? "wide" : "")."hat"' ], 
endif

    " Make Miscellaneous Mathematical Maps:
    augroup ATP_MathIMaps_misc
	au!
	au CursorHoldI 	*.tex 	:call atplib#ToggleIMaps(g:atp_imap_math_misc, 'CursorHoldI', g:atp_imap_diacritics) 
	au InsertEnter	*.tex 	:call atplib#ToggleIMaps(g:atp_imap_math_misc, 'InsertEnter', g:atp_imap_diacritics) 
    augroup END
" DIACRITICSC IMAPS: {{{1
if !exists("g:atp_imap_diacritics")
    if g:atp_diacritics == 1
	let g:atp_imap_diacritics = [
	    \ [ 'inoremap', '<silent> <buffer>', g:atp_imap_over_leader,  '''', s:backslash.'''{}<Left>',
		    \ "g:atp_imap_define_diacritics", '\''{}' ],
	    \ [ 'inoremap', '<silent> <buffer>', g:atp_imap_over_leader,  '"', s:backslash.'"{}<Left>',
		    \ "g:atp_imap_define_diacritics", '\"{}' ],
	    \ [ 'inoremap', '<silent> <buffer>', g:atp_imap_over_leader,  '2', s:backslash.'"{}<Left>',
		    \ "g:atp_imap_define_diacritics", '\"{}' ],
	    \ [ 'inoremap', '<silent> <buffer>', g:atp_imap_over_leader,  '^', s:backslash.'^{}<Left>',
		    \ "g:atp_imap_define_diacritics", '\^{}' ],
	    \ [ 'inoremap', '<silent> <buffer>', g:atp_imap_over_leader,  'v', s:backslash.'v{}<Left>',
		    \ "g:atp_imap_define_diacritics", '\v{}' ],
	    \ [ 'inoremap', '<silent> <buffer>', g:atp_imap_over_leader,  'b', s:backslash.'b{}<Left>',
		    \ "g:atp_imap_define_diacritics", '\b{}' ],
	    \ [ 'inoremap', '<silent> <buffer>', g:atp_imap_over_leader,  'd', s:backslash.'d{}<Left>',
		    \ "g:atp_imap_define_diacritics", '\d{}' ],
	    \ [ 'inoremap', '<silent> <buffer>', g:atp_imap_over_leader,  '`', s:backslash.'`{}<Left>',
		    \ "g:atp_imap_define_diacritics", '\`{}' ],
	    \ [ 'inoremap', '<silent> <buffer>', g:atp_imap_over_leader,  'H', s:backslash.'H{}<Left>',
		    \ "g:atp_imap_define_diacritics", '\H{}' ],
	    \ [ 'inoremap', '<silent> <buffer>', g:atp_imap_over_leader,  '~', s:backslash.'~{}<Left>',
		    \ "g:atp_imap_define_diacritics", '\~{}' ],
	    \ [ 'inoremap', '<silent> <buffer>', g:atp_imap_over_leader,  '.', s:backslash.'.{}<Left>',
		    \ "g:atp_imap_define_diacritics", '\.{}' ],
	    \ [ 'inoremap', '<silent> <buffer>', g:atp_imap_over_leader,  'c', s:backslash.'c{}<Left>',
		    \ "g:atp_imap_define_diacritics", '\c{}' ],
	    \ [ 'inoremap', '<silent> <buffer>', g:atp_imap_over_leader,  't', s:backslash.'t{}<Left>',
		    \ "g:atp_imap_define_diacritics", '\t{}' ]
	    \ ]
    elseif g:atp_diacritics == 2
	let g:atp_imap_diacritics = [
	    \ [ 'inoremap', '<silent> <buffer> <expr>', g:atp_imap_over_leader,  '''', '(index(split(g:atp_diacritics_letters["''"], ''\zs''), tolower(getline(line("."))[col(".")-2])) != -1  ? "<ESC>vx".(col(".")<=len(getline(line(".")))? "i" : "a" )."'.s:bbackslash.'''{\"}" : "'.escape(g:atp_imap_over_leader, '\"').'''")', 
		    \ "g:atp_imap_define_diacritics", '\''{}' ],
	    \ [ 'inoremap', '<silent> <buffer> <expr>', g:atp_imap_over_leader,  '"', '(index(split(g:atp_diacritics_letters[''"''], ''\zs''), tolower(getline(line("."))[col(".")-2])) != -1  ? "<ESC>vx".(col(".")<=len(getline("."))? "i" : "a" )."'.s:bbackslash.'\"{\"}" : "'.escape(g:atp_imap_over_leader, '\"').'\"")',
		    \ "g:atp_imap_define_diacritics", '\"{}' ],
	    \ [ 'inoremap', '<silent> <buffer> <expr>', g:atp_imap_over_leader,  '2', '(index(split(g:atp_diacritics_letters[''2''], ''\zs''), tolower(getline(line("."))[col(".")-2])) != -1 ? "<ESC>vx".(col(".")<=len(getline("."))? "i" : "a" )."'.s:bbackslash.'2{\"}" : "'.escape(g:atp_imap_over_leader, '\"').'2")',
		    \ "g:atp_imap_define_diacritics", '\2{}' ],
	    \ [ 'inoremap', '<silent> <buffer> <expr>', g:atp_imap_over_leader,  '^', '(index(split(g:atp_diacritics_letters[''^''], ''\zs''), tolower(getline(line("."))[col(".")-2])) != -1 ? "<ESC>vx".(col(".")<=len(getline("."))? "i" : "a" )."'.s:bbackslash.'^{\"}" : "'.escape(g:atp_imap_over_leader, '\"').'^")',
		    \ "g:atp_imap_define_diacritics", '\^{}' ],
	    \ [ 'inoremap', '<silent> <buffer> <expr>', g:atp_imap_over_leader,  'v', '(index(split(g:atp_diacritics_letters[''v''], ''\zs''), tolower(getline(line("."))[col(".")-2])) != -1 ? "<ESC>vx".(col(".")<=len(getline("."))? "i" : "a" )."'.s:bbackslash.'v{\"}" : "'.escape(g:atp_imap_over_leader, '\"').'v" )',
		    \ "g:atp_imap_define_diacritics", '\v{}' ],
	    \ [ 'inoremap', '<silent> <buffer> <expr>', g:atp_imap_over_leader,  'b', '(index(split(g:atp_diacritics_letters[''b''], ''\zs''), tolower(getline(line("."))[col(".")-2])) != -1 ? "<ESC>vx".(col(".")<=len(getline("."))? "i" : "a" )."'.s:bbackslash.'b{\"}" : "'.escape(g:atp_imap_over_leader, '\"').'b" )',
		    \ "g:atp_imap_define_diacritics", '\b{}' ],
	    \ [ 'inoremap', '<silent> <buffer> <expr>', g:atp_imap_over_leader,  'd', '(index(split(g:atp_diacritics_letters[''d''], ''\zs''), tolower(getline(line("."))[col(".")-2])) != -1 ? "<ESC>vx".(col(".")<=len(getline("."))? "i" : "a" )."'.s:bbackslash.'d{\"}" : "'.escape(g:atp_imap_over_leader, '\"').'d" )',
		    \ "g:atp_imap_define_diacritics", '\d{}' ],
	    \ [ 'inoremap', '<silent> <buffer> <expr>', g:atp_imap_over_leader,  '`', '(index(split(g:atp_diacritics_letters[''`''], ''\zs''), tolower(getline(line("."))[col(".")-2])) != -1 ? "<ESC>vx".(col(".")<=len(getline("."))? "i" : "a" )."'.s:bbackslash.'`{\"}" : "'.escape(g:atp_imap_over_leader, '\"').'`" )',
		    \ "g:atp_imap_define_diacritics", '\`{}' ],
	    \ [ 'inoremap', '<silent> <buffer> <expr>', g:atp_imap_over_leader,  'H', '(index(split(g:atp_diacritics_letters[''H''], ''\zs''), tolower(getline(line("."))[col(".")-2])) != -1 ? "<ESC>vx".(col(".")<=len(getline("."))? "i" : "a" )."'.s:bbackslash.'H{\"}" : "'.escape(g:atp_imap_over_leader, '\"').'H" )',
		    \ "g:atp_imap_define_diacritics", '\H{}' ],
	    \ [ 'inoremap', '<silent> <buffer> <expr>', g:atp_imap_over_leader,  '~', '(index(split(g:atp_diacritics_letters[''~''], ''\zs''), tolower(getline(line("."))[col(".")-2])) != -1 ?"<ESC>vx".(col(".")<=len(getline("."))? "i" : "a" )."'.s:bbackslash.'~{\"}" : "'.escape(g:atp_imap_over_leader, '\"').'~" )',
		    \ "g:atp_imap_define_diacritics", '\~{}' ],
	    \ [ 'inoremap', '<silent> <buffer> <expr>', g:atp_imap_over_leader,  '.', '(index(split(g:atp_diacritics_letters[''.''], ''\zs''), tolower(getline(line("."))[col(".")-2])) != -1 ?"<ESC>vx".(col(".")<=len(getline("."))? "i" : "a" )."'.s:bbackslash.'.{\"}" : "'.escape(g:atp_imap_over_leader, '\"').'." )',
		    \ "g:atp_imap_define_diacritics", '\.{}' ],
	    \ [ 'inoremap', '<silent> <buffer> <expr>', g:atp_imap_over_leader,  'c', '(index(split(g:atp_diacritics_letters[''c''], ''\zs''), tolower(getline(line("."))[col(".")-2])) != -1 ?"<ESC>vx".(col(".")<=len(getline("."))? "i" : "a" )."'.s:bbackslash.'c{\"}" : "'.escape(g:atp_imap_over_leader, '\"').'c" )',
		    \ "g:atp_imap_define_diacritics", '\c{}' ],
	    \ [ 'inoremap', '<silent> <buffer> <expr>', g:atp_imap_over_leader,  't', '(index(split(g:atp_diacritics_letters[''t''], ''\zs''), tolower(getline(line("."))[col(".")-2])) != -1 ? "<ESC>vx".(col(".")<=len(getline("."))? "i" : "a" )."'.s:bbackslash.'t{\"}" : "'.escape(g:atp_imap_over_leader, '\"').'t" )',
		    \ "g:atp_imap_define_diacritics", '\t{}' ]
	    \ ]
    else
	let g:atp_imap_diacritics=[]
    endif
endif
" ENVIRONMENT MAPS: {{{1
if !exists("g:atp_imap_environments") || g:atp_reload_variables
    if g:atp_no_env_maps != 1 && !empty(g:atp_imap_leader_3)
    let g:atp_imap_environments = [
	\ [ "inoremap", "<buffer> <silent>", 	g:atp_imap_leader_3, "m", 			s:backslash.'('.s:backslash.')<Left><Left>', 						"g:atp_imap_define_environments", 'inlince math' ],
	\ [ "inoremap", "<buffer> <silent>", 	g:atp_imap_leader_3, "M", 			s:backslash.'['.s:backslash.']<Left><Left>', 						"g:atp_imap_define_environments", 'displayed math' ],
	\ [ 'inoremap', '<silent> <buffer>',	g:atp_imap_leader_3, g:atp_imap_begin, 		s:backslash.'begin{}<Left>', 						"g:atp_imap_define_environments", '\begin{}' ],
	\ [ 'inoremap', '<silent> <buffer>',	g:atp_imap_leader_3, g:atp_imap_end, 		s:backslash.'end{}<Left>', 						"g:atp_imap_define_environments", '\end{}' ],
	\ [ 'inoremap', '<silent> <buffer>',	g:atp_imap_leader_3, g:atp_imap_proof, 		s:backslash.'begin{proof}<CR>'.s:backslash.'end{proof}<Esc>O', 				"g:atp_imap_define_environments", 'proof' ],
	\ [ 'inoremap', '<silent> <buffer>',	g:atp_imap_leader_3, g:atp_imap_center, 	s:backslash.'begin{center}<CR>\end{center}<Esc>O', 			"g:atp_imap_define_environments", 'center' ],
	\ [ 'inoremap', '<silent> <buffer>',	g:atp_imap_leader_3, g:atp_imap_flushleft, 	s:backslash.'begin{flushleft}<CR>'.s:backslash.'end{flushleft}<Esc>O', 			"g:atp_imap_define_environments", 'flushleft' ],
	\ [ 'inoremap', '<silent> <buffer>',	g:atp_imap_leader_3, g:atp_imap_flushright, 	s:backslash.'begin{flushright}<CR>'.s:backslash.'end{flushright}<Esc>O', 		"g:atp_imap_define_environments", 'flushright' ],
	\ [ 'inoremap', '<silent> <buffer>',	g:atp_imap_leader_3, g:atp_imap_bibliography, 	s:backslash.'begin{thebibliography}<CR>'.s:backslash.'end{thebibliography}<Esc>O', 	"g:atp_imap_define_environments", 'bibliography' ],
	\ [ 'inoremap', '<silent> <buffer>',	g:atp_imap_leader_3, g:atp_imap_abstract, 	s:backslash.'begin{abstract}<CR>'.s:backslash.'end{abstract}<Esc>O', 			"g:atp_imap_define_environments", 'abstract' ],
	\ [ 'inoremap', '<silent> <buffer>',	g:atp_imap_leader_3, g:atp_imap_item, 		'<Esc>:call InsertItem()<CR>a', 				"g:atp_imap_define_environments", 'item' 	],
	\ [ 'inoremap', '<silent> <buffer>',	g:atp_imap_leader_3, g:atp_imap_frame, 		s:backslash.'begin{frame}<CR>'.s:backslash.'end{frame}<Esc>O', 				"g:atp_imap_define_environments", 'frame' ],
	\ [ 'inoremap', '<silent> <buffer>',	g:atp_imap_leader_3, g:atp_imap_enumerate, 	s:backslash.'begin{enumerate}'.g:atp_EnvOptions_enumerate.'<CR>'.s:backslash.'end{enumerate}<Esc>O'.s:backslash.'item', 	"g:atp_imap_define_environments", 'enumerate' ],
	\ [ 'inoremap', '<silent> <buffer>',	g:atp_imap_leader_3, g:atp_imap_tabular, 	s:backslash.'end{tabular}<Esc>O'.s:backslash.'begin{tabular}{}<Left>', 	"g:atp_imap_define_environments", 'tabular' ],
	\ [ 'inoremap', '<silent> <buffer>',	g:atp_imap_leader_3, g:atp_imap_table, 		s:backslash.'end{table}<Esc>O<C-T>'.s:backslash.'caption{}<Esc>O'.s:backslash.'begin{table}<CR>'.s:backslash.'end{tabular}<C-T><Esc>O'.s:backslash.'begin{tabular}{}<Left>', 	"g:atp_imap_define_environments", 'tabular' ],
	\ [ 'inoremap', '<silent> <buffer>',	g:atp_imap_leader_3, g:atp_imap_itemize, 	s:backslash.'begin{itemize}'.g:atp_EnvOptions_itemize.'<CR>'.s:backslash.'end{itemize}<Esc>O'.s:backslash.'item', 		"g:atp_imap_define_environments", 'itemize' ],
	\ [ 'inoremap', '<silent> <buffer>',	g:atp_imap_leader_3, g:atp_imap_tikzpicture, 	s:backslash.'begin{center}<CR>'.s:backslash.'begin{tikzpicture}<CR>'.s:backslash.'end{tikzpicture}<CR>'.s:backslash.'end{center}<Up><Esc>O', "g:atp_imap_define_environments", 'tikzpicture' ],
	\ [ 'inoremap', '<silent> <buffer>',	g:atp_imap_leader_3, g:atp_imap_theorem, 	s:backslash.'begin{=g:atp_EnvNameTheorem<CR>=(getline(".")[col(".")-2]=="*"?"":b:atp_StarEnvDefault)<CR>}<CR>'.s:backslash.'end{=g:atp_EnvNameTheorem<CR>=(getline(".")[col(".")-2]=="*"?"":b:atp_StarEnvDefault)<CR>}<Esc>O',  	"g:atp_imap_define_environments", 'theorem'],
	\ [ 'inoremap', '<silent> <buffer>',	g:atp_imap_leader_3, g:atp_imap_definition, 	s:backslash.'begin{=g:atp_EnvNameDefinition<CR>=(getline(".")[col(".")-2]=="*"?"":b:atp_StarEnvDefault)<CR>}<CR>'.s:backslash.'end{=g:atp_EnvNameDefinition<CR>=(getline(".")[col(".")-2]=="*"?"":b:atp_StarEnvDefault)<CR>}<Esc>O', 	"g:atp_imap_define_environments", 'definition'],
	\ [ 'inoremap', '<silent> <buffer>',	g:atp_imap_leader_3, g:atp_imap_proposition, 	s:backslash.'begin{=g:atp_EnvNameProposition<CR>=(getline(".")[col(".")-2]=="*"?"":b:atp_StarEnvDefault)<CR>}<CR>'.s:backslash.'end{=g:atp_EnvNameProposition<CR>=(getline(".")[col(".")-2]=="*"?"":b:atp_StarEnvDefault)<CR>}<Esc>O', 	"g:atp_imap_define_environments", 'proposition' ],
	\ [ 'inoremap', '<silent> <buffer>',	g:atp_imap_leader_3, g:atp_imap_lemma, 		s:backslash.'begin{=g:atp_EnvNameLemma<CR>=(getline(".")[col(".")-2]=="*"?"":b:atp_StarEnvDefault)<CR>}<CR>'.s:backslash.'end{=g:atp_EnvNameLemma<CR>=(getline(".")[col(".")-2]=="*"?"":b:atp_StarEnvDefault)<CR>}<Esc>O', 		"g:atp_imap_define_environments", 'lemma' ],
	\ [ 'inoremap', '<silent> <buffer>',	g:atp_imap_leader_3, g:atp_imap_remark, 	s:backslash.'begin{=g:atp_EnvNameRemark<CR>=(getline(".")[col(".")-2]=="*"?"":b:atp_StarEnvDefault)<CR>}<CR>'.s:backslash.'end{=g:atp_EnvNameRemark<CR>=(getline(".")[col(".")-2]=="*"?"":b:atp_StarEnvDefault)<CR>}<Esc>O', 		"g:atp_imap_define_environments", 'remark' ],
	\ [ 'inoremap', '<silent> <buffer>',	g:atp_imap_leader_3, g:atp_imap_note, 		s:backslash.'begin{=g:atp_EnvNameNote<CR>=(getline(".")[col(".")-2]=="*"?"":b:atp_StarEnvDefault)<CR>}<CR>'.s:backslash.'end{=g:atp_EnvNameNote<CR>=(getline(".")[col(".")-2]=="*"?"":b:atp_StarEnvDefault)<CR>}<Esc>O', 		"g:atp_imap_define_environments", 'note' ],
	\ [ 'inoremap', '<silent> <buffer>',	g:atp_imap_leader_3, g:atp_imap_example, 	s:backslash.'begin{=g:atp_EnvNameExample<CR>=(getline(".")[col(".")-2]=="*"?"":b:atp_StarEnvDefault)<CR>}<CR>'.s:backslash.'end{=g:atp_EnvNameExample<CR>=(getline(".")[col(".")-2]=="*"?"":b:atp_StarEnvDefault)<CR>}<Esc>O', 		"g:atp_imap_define_environments", 'example' ],
	\ [ 'inoremap', '<silent> <buffer>',	g:atp_imap_leader_3, g:atp_imap_corollary, 	s:backslash.'begin{=g:atp_EnvNameCorollary<CR>=(getline(".")[col(".")-2]=="*"?"":b:atp_StarEnvDefault)<CR>}<CR>'.s:backslash.'end{=g:atp_EnvNameCorollary<CR>=(getline(".")[col(".")-2]=="*"?"":b:atp_StarEnvDefault)<CR>}<Esc>O', 	"g:atp_imap_define_environments", 'corollary' ],
	\ [ 'inoremap', '<silent> <buffer>',	g:atp_imap_leader_3, g:atp_imap_align, 		s:backslash.'begin{align=(getline(".")[col(".")-2]=="*"?"":b:atp_StarMathEnvDefault)<CR>}<CR>'.s:backslash.'end{align=(getline(".")[col(".")-2]=="*"?"":b:atp_StarMathEnvDefault)<CR>}<Esc>O', 	"g:atp_imap_define_environments", 'align' ],
	\ [ 'inoremap', '<silent> <buffer>',	g:atp_imap_leader_3, g:atp_imap_gather, 	s:backslash.'begin{gather=(getline(".")[col(".")-2]=="*"?"":b:atp_StarMathEnvDefault)<CR>}<CR>'.s:backslash.'end{gather=(getline(".")[col(".")-2]=="*"?"":b:atp_StarMathEnvDefault)<CR>}<Esc>O', 	"g:atp_imap_define_environments", 'gather' ],
	\ [ 'inoremap', '<silent> <buffer>',	g:atp_imap_leader_3, g:atp_imap_split,		s:backslash.'begin{split=(getline(".")[col(".")-2]=="*"?"":b:atp_StarMathEnvDefault)<CR>}<CR>'.s:backslash.'end{split=(getline(".")[col(".")-2]=="*"?"":b:atp_StarMathEnvDefault)<CR>}<Esc>O', 	"g:atp_imap_define_environments", 'split' ],
	\ [ 'inoremap', '<silent> <buffer>',	g:atp_imap_leader_3, g:atp_imap_multiline, 	s:backslash.'begin{multiline=(getline(".")[col(".")-2]=="*"?"":b:atp_StarMathEnvDefault)<CR>}<CR>'.s:backslash.'end{multiline=(getline(".")[col(".")-2]=="*"?"":b:atp_StarMathEnvDefault)<CR>}<Esc>O', 	"g:atp_imap_define_environments", 'multiline' ],
	\ [ 'inoremap', '<silent> <buffer>',	g:atp_imap_leader_3, g:atp_imap_equation, 	s:backslash.'begin{equation=(getline(".")[col(".")-2]=="*"?"":b:atp_StarMathEnvDefault)<CR>}<CR>'.s:backslash.'end{equation=(getline(".")[col(".")-2]=="*"?"":b:atp_StarMathEnvDefault)<CR>}<Esc>O', 	"g:atp_imap_define_environments", 'equation' ],
	\ [ 'inoremap', '<silent> <buffer>',	g:atp_imap_leader_3, g:atp_imap_letter, 	s:backslash.'begin{letter}{}<CR>'.s:backslash.'opening{=g:atp_letter_opening<CR>}<CR>'.s:backslash.'closing{=g:atp_letter_closing<CR>}<CR>'.s:backslash.'end{letter}<Esc>?'.s:bbackslash.'begin{letter}{'.s:backslash.'zs<CR>i', 				"g:atp_imap_define_environments", 'letter' ],
	\ ]
    else
	let g:atp_imap_environments = []
    endif
endif
" Make Environment Maps:
call atplib#MakeMaps(g:atp_imap_environments)
" MATHEMATICAL MAPS: {{{1
if !exists("g:atp_imap_math") || g:atp_reload_variables
    let g:atp_imap_math	= [ 
	\ [ "inoremap", "<buffer> <silent> <expr>", "", "~", "atplib#IsLeft('~') && atplib#IsInMath() ? '<BS>".s:backslash."=(g:atp_imap_wide ? \"wide\" : \"\" ) <CR>tilde=(g:atp_imap_tilde_braces ? \"{}\" : \"\")<CR>'.(g:atp_imap_tilde_braces ? '<Left>' : '') : '~'" , "g:atp_imap_define_math", 	'\\(wide)tilde({})'], 
	\ [ "inoremap", "<buffer> <silent> <expr>", "", "=", "atplib#IsInMath() && atplib#IsLeft('=') && !atplib#IsLeft('&',1) ? '<BS>&=' : '='", "g:atp_imap_define_math",	'&=' ],
	\ [ "inoremap", "<buffer> <silent> <expr>", "", "o+", "atplib#IsInMath() ? '".s:backslash."oplus' 	: 'o+'", "g:atp_imap_define_math", 		'\\oplus' ],
	\ [ "inoremap", "<buffer> <silent> <expr>", "", "O+", "atplib#IsInMath() ? '".s:backslash."bigoplus' 	: 'O+'", "g:atp_imap_define_math",		'\\bigoplus'],
	\ [ "inoremap", "<buffer> <silent> <expr>", "", "o-", "atplib#IsInMath() ? '".s:backslash."ominus' 	: 'o-'", "g:atp_imap_define_math",		'\\ominus'],
	\ [ "inoremap", "<buffer> <silent> <expr>", "", "o.", "atplib#IsInMath() ? '".s:backslash."odot' 	: 'o.'", "g:atp_imap_define_math",		'\\odot'],
	\ [ "inoremap", "<buffer> <silent> <expr>", "", "O.", "atplib#IsInMath() ? '".s:backslash."bigodot' 	: 'O.'", "g:atp_imap_define_math",		'\\bigodot'],
	\ [ "inoremap", "<buffer> <silent> <expr>", "", "o*", "atplib#IsInMath() ? '".s:backslash."otimes' 	: 'o*'", "g:atp_imap_define_math",		'\\otimes'],
	\ [ "inoremap", "<buffer> <silent> <expr>", "", "O*", "atplib#IsInMath() ? '".s:backslash."bigotimes' 	: 'O*'", "g:atp_imap_define_math",		'\\bigotimes'],
	\ [ "inoremap", "<buffer> <silent> <expr>", "", "t*", "atplib#IsInMath() ? '".s:backslash."times' 	: 't*'", "g:atp_imap_define_math",		'\\otimes'],
	\ [ "inoremap", "<buffer> <silent> <expr>", "", "s+", "atplib#IsInMath() ? '".s:backslash."cup' 	: 's+'", "g:atp_imap_define_math",		'\\cup'],
	\ [ "inoremap", "<buffer> <silent> <expr>", "", "s-", "atplib#IsInMath() ? '".s:backslash."setminus' 	: 's-'", "g:atp_imap_define_math",		'\\cup'],
	\ [ "inoremap", "<buffer> <silent> <expr>", "", "S+", "atplib#IsInMath() ? '".s:backslash."bigcup' 	: 'S+'", "g:atp_imap_define_math",		'\\bigcup'],
	\ [ "inoremap", "<buffer> <silent> <expr>", "", "s*", "atplib#IsInMath() ? '".s:backslash."cap' 	: 's*'", "g:atp_imap_define_math",		'\\cap'],
	\ [ "inoremap", "<buffer> <silent> <expr>", "", "S*", "atplib#IsInMath() ? '".s:backslash."bigcap' 	: 'S*'", "g:atp_imap_define_math",		'\\bigcap'],
	\ [ "inoremap", "<buffer> <silent> <expr>", "", "l*", "atplib#IsInMath() ? '".s:backslash."wedge' 	: 'l*'", "g:atp_imap_define_math",		'\\wedge'],
	\ [ "inoremap", "<buffer> <silent> <expr>", "", "L*", "atplib#IsInMath() ? '".s:backslash."bigwedge' 	: 'L*'", "g:atp_imap_define_math",		'\\bigwedge'],
	\ [ "inoremap", "<buffer> <silent> <expr>", "", "l+", "atplib#IsInMath() ? '".s:backslash."vee' 	: 'l+'", "g:atp_imap_define_math",		'\\vee'],
	\ [ "inoremap", "<buffer> <silent> <expr>", "", "L+", "atplib#IsInMath() ? '".s:backslash."bigvee' 	: 'L+'", "g:atp_imap_define_math",		'\\bigvee'],
	\ [ "inoremap", "<buffer> <silent> <expr>", "", "c*", "atplib#IsInMath() ? '".s:backslash."prod' 	: 'c*'", "g:atp_imap_define_math",		'\\prod'],
	\ [ "inoremap", "<buffer> <silent> <expr>", "", "c+", "atplib#IsInMath() ? '".s:backslash."coprod' 	: 'c+'", "g:atp_imap_define_math",		'\\coprod'],
	\ [ "inoremap", "<buffer> <silent> <expr>", "", "t<", "atplib#IsInMath() ? '".s:backslash."triangleleft' : 't<'", "g:atp_imap_define_math",		'\\triangleleft'],
	\ [ "inoremap", "<buffer> <silent> <expr>", "", "t>", "atplib#IsInMath() ? '".s:backslash."triangleright' : 't>'", "g:atp_imap_define_math",		'\\triangleright'],
	\ [ "inoremap", "<buffer> <silent> <expr>", "", "s<", "atplib#IsInMath() ? '".s:backslash."subseteq' 	: 's<'", "g:atp_imap_define_math",		'\\subseteq'],
	\ [ "inoremap", "<buffer> <silent> <expr>", "", "s>", "atplib#IsInMath() ? '".s:backslash."supseteq' 	: 's>'", "g:atp_imap_define_math",		'\\supseteq'],
	\ [ "inoremap", "<buffer> <silent> <expr>", "", "<=", "atplib#IsInMath() ? '".s:backslash."leq' 	: '<='", "g:atp_imap_define_math",		'\\leq'],
	\ [ "inoremap", "<buffer> <silent> <expr>", "", ">=", "atplib#IsInMath() ? '".s:backslash."geq' 	: '>='", "g:atp_imap_define_math",		'\\geq'],
	\ [ "inoremap", "<buffer> <silent> <expr>", "", "#<", "atplib#IsInMath() ? '".s:backslash."langle' 	: '#<'", "g:atp_imap_define_math",		'\\langle'],
	\ [ "inoremap", "<buffer> <silent> <expr>", "", "#>", "atplib#IsInMath() ? '".s:backslash."rangle' 	: '#>'", "g:atp_imap_define_math",		'\\rangle'],
	\ [ "inoremap", "<buffer> <silent> <expr>", "", "->", "atplib#IsInMath('!') ? '".s:backslash."rightarrow' 	: ( atplib#complete#CheckSyntaxGroups(['texMathZoneT']) && getline('.')[1:col('.')] !~ '\\[[^\\]]*$' ? '\\draw[->]' : '->' )", "g:atp_imap_define_math",		'\\rightarrow'],
	\ [ "inoremap", "<buffer> <silent> <expr>", "", "<-", "atplib#IsInMath('!') ? '".s:backslash."leftarrow' 	: ( atplib#complete#CheckSyntaxGroups(['texMathZoneT']) && getline('.')[1:col('.')] !~ '\\[[^\\]]*$' ? '\\draw[<-]' : '<-' )", "g:atp_imap_define_math",		'\\leftarrow'],
	\ [ "inoremap", "<buffer> <silent> <expr>", "", "<_", "atplib#IsInMath('!') ? '".s:backslash."Leftarrow' 	: '<-'", "g:atp_imap_define_math",		'\\Leftarrow'],
	\ [ "inoremap", "<buffer> <silent> <expr>", "", "_>", "atplib#IsInMath('!') ? '".s:backslash."Rightarrow' 	: '->'", "g:atp_imap_define_math",		'\\Rightarrow'],
	\ ]

    if !empty(g:atp_imap_subscript)
	call add(g:atp_imap_math, [ "inoremap", "<buffer> <silent> <expr>", "", g:atp_imap_subscript, "( g:atp_imap_subscript == '_' && !atplib#IsLeft('\\', 1) && atplib#IsLeft('_') <bar><bar> g:atp_imap_subscript != '_' ) && atplib#IsInMath() ? (g:atp_imap_subscript == '_' ? '<BS>' : '' ).'_{}<Left>' : '_'", "g:atp_imap_define_math", 	'_{}'] )
    endif
    if !empty(g:atp_imap_supscript)
	call add(g:atp_imap_math, [ "inoremap", "<buffer> <silent> <expr>", "", g:atp_imap_supscript, "( g:atp_imap_supscript == '^' && !atplib#IsLeft('\\', 1) && atplib#IsLeft('^') <bar><bar> g:atp_imap_supscript != '^' ) && atplib#IsInMath() ? (g:atp_imap_supscript == '^' ? '<BS>' : '' ).'^{}<Left>' : (atplib#IsLeft('~') ? '<BS>".s:backslash."=(g:atp_imap_wide ? ''wide'' : '''' )<CR>hat{}<Left>' : '^')", "g:atp_imap_define_math", 	'^{}'] )
    endif
endif
" MAKE MATHEMATICAL MAPS: (autocommands) "{{{1
augroup ATP_MathIMaps
    au!
    au CursorHoldI 	*.tex 	:call atplib#ToggleIMaps(g:atp_imap_math, 'CursorHoldI')
    au InsertEnter	*.tex 	:call atplib#ToggleIMaps(g:atp_imap_math, 'InsertEnter')
    " Make imaps visible with :imap  /this will not work with i_CTRL-C/
    " au InsertLeave	*.tex 	:call atplib#MakeMaps(g:atp_imap_math, 'InsertLeave')
    " au BufEnter		*.tex 	:call atplib#MakeMaps(g:atp_imap_math, 'BufEnter')
augroup END

augroup ATP_IMaps_CursorMovedI
    " This also fires SetMathVimOptions() (options.vim)
    au CursorMovedI *.tex 	:call atplib#ToggleIMaps(g:atp_imap_greek_letters+g:atp_imap_math_misc
		\ +g:atp_imap_math, 'CursorMovedI', g:atp_imap_diacritics, 1)
augroup END
" }}}1
" vim:fdm=marker:tw=85:ff=unix:noet:ts=8:sw=4:fdc=1:nowrap
