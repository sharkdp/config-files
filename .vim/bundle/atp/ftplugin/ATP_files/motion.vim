" Author:	Marcin Szamotulski
" Description:	This file contains motion and highlight functions of ATP.
" Note:		This file is a part of Automatic Tex Plugin for Vim.
" Language:	tex
" Last Change:

let s:sourced = ( !exists("s:sourced") ? 0 : 1 )

" AutoCommands:
augroup ATP_BufList
    " Add opened files to t:atp_toc_buflist.
    au!
    au BufEnter *.tex call atplib#motion#buflist()
augroup END
function! <SID>toc_onwrite()
    if g:atp_python_toc
	" check if there is a __ToC__ window:
	if index(map(tabpagebuflist(), 'bufname(v:val)'), "__ToC__") != -1
	    Toc!
	    let ei=&ei
	    set ei=all
	    wincmd w
	    let &ei=ei
	endif
    endif
endfunction
augroup ATP_TOC_onwrite
    au!
    au BufWritePost *.tex call <SID>toc_onwrite()
augroup END

" Commands And Maps:
" {{{1
if exists(":Tags") != 2
    let b:atp_LatexTags = 1
    command! -buffer -bang Tags					:call atplib#motion#LatexTags(<q-bang>)
else
    let b:atp_LatexTags = 0
    command! -buffer -bang LatexTags				:call atplib#motion#LatexTags(<q-bang>)
endif
command! -nargs=? -complete=custom,atplib#motion#RemoveFromToCComp RemoveFromToC	:call atplib#motion#RemoveFromToC(<q-args>)
nnoremap <buffer> <silent> <Plug>JumptoNextEnvironment		:<C-U>call atplib#motion#JumptoEnvironment(1,v:count1)<CR>
nnoremap <buffer> <silent> <Plug>JumptoPreviousEnvironment	:<C-U>call atplib#motion#JumptoEnvironment(0,v:count1)<CR>
nnoremap <buffer> <silent> <Plug>FastJumptoNextEnvironment	:<C-U>call atplib#motion#FastJumptoEnvironment(1,v:count1)<CR>
nnoremap <buffer> <silent> <Plug>FastJumptoPreviousEnvironment	:<C-U>call atplib#motion#FastJumptoEnvironment(0,v:count1)<CR>
nnoremap <buffer> <silent> <Plug>JumpOutForward			:<C-U>call atplib#motion#JumpOut(1,v:count1)<CR>
nnoremap <buffer> <silent> <Plug>JumpOutBackward		:<C-U>call atplib#motion#JumpOut(0,v:count1)<CR>
nnoremap <buffer> <silent> <Plug>FastJumpOutForward		:<C-U>call atplib#motion#FastJumpOut(1)<CR>
nnoremap <buffer> <silent> <Plug>FastJumpOutBackward		:<C-U>call atplib#motion#FastJumpOut(0)<CR>
command! -buffer -count=1 Part		:call atplib#motion#ggGotoSection(<q-count>, 'part')
command! -buffer -count=1 Chap		:call atplib#motion#ggGotoSection(<q-count>, 'chapter')
command! -buffer -count=1 Sec		:call atplib#motion#ggGotoSection(<q-count>, 'section')
command! -buffer -count=1 SSec		:call atplib#motion#ggGotoSection(<q-count>, 'subsection')

command! -buffer -nargs=1 -complete=custom,atplib#motion#CompleteDestinations GotoNamedDest	:call atplib#motion#GotoNamedDestination(<f-args>)
command! -buffer -count=1 SkipCommentForward  	:call atplib#motion#SkipComment('fs', 'n', v:count1)
command! -buffer -count=1 SkipCommentBackward 	:call atplib#motion#SkipComment('bs', 'n', v:count1)
vmap <buffer> <Plug>SkipCommentForward	:call atplib#motion#SkipComment('fs', 'v', v:count1)<CR>
vmap <buffer> <Plug>SkipCommentBackward	:call atplib#motion#SkipComment('bs', 'v', v:count1)<CR>

vnoremap <buffer> <silent> <Plug>TexWordObject :<c-u>call atplib#motion#TexKeywordObject()<CR>

imap <Plug>TexSyntaxMotionForward	<Esc>:call atplib#motion#TexSyntaxMotion(1,1,1)<CR>a
imap <Plug>TexSyntaxMotionBackward	<Esc>:call atplib#motion#TexSyntaxMotion(0,1,1)<CR>a
nmap <Plug>TexSyntaxMotionForward	:call atplib#motion#TexSyntaxMotion(1,1)<CR>
nmap <Plug>TexSyntaxMotionBackward	:call atplib#motion#TexSyntaxMotion(0,1)<CR>

inoremap <Plug>TexJMotionForward	<Esc><Right>:call atplib#motion#JMotion('')<CR>i
inoremap <Plug>TexJMotionBackward	<Esc>:call atplib#motion#JMotion('b')<CR>a
nnoremap <Plug>TexJMotionForward	:call atplib#motion#JMotion('')<CR>
nnoremap <Plug>TexJMotionBackward	:call atplib#motion#JMotion('b')<CR>

nnoremap <buffer> <Plug>ParagraphNormalMotionForward 	:<C-U>call atplib#motion#ParagraphNormalMotion('', v:count1)<CR>
nnoremap <buffer> <Plug>ParagraphNormalMotionBackward	:<C-U>call atplib#motion#ParagraphNormalMotion('b', v:count1)<CR>
vnoremap <buffer> <Plug>ParagraphVisualMotionForward 	:<C-U>call atplib#motion#ParagraphVisualMotion('',v:count1)<CR>
vnoremap <buffer> <Plug>ParagraphVisualMotionBackward 	:<C-U>call atplib#motion#ParagraphVisualMotion('b',v:count1)<CR>
nnoremap <buffer> <Plug>SentenceNormalMotionForward 	:<C-U>call atplib#motion#SentenceNormalMotion('', v:count1)<CR>
nnoremap <buffer> <Plug>SentenceNormalMotionBackward	:<C-U>call atplib#motion#SentenceNormalMotion('b', v:count1)<CR>
" command! -buffer -nargs=1 -complete=buffer MakeToc	:echo atplib#motion#maketoc(fnamemodify(<f-args>, ":p"))[fnamemodify(<f-args>, ":p")] 
command! -buffer -bang -nargs=? Toc	:call atplib#motion#TOC(<q-bang>)
command! -buffer Ctoc			:call CTOC()
command! -buffer -bang Labels		:call atplib#motion#Labels(<q-bang>)
command! -buffer -count=1 -nargs=? -complete=customlist,EnvCompletionWithoutStarEnvs Nenv	:call atplib#motion#GotoEnvironment('sW',<q-count>,<q-args>)  | let v:searchforward=1 
command! -buffer -count=1 -nargs=? -complete=customlist,EnvCompletionWithoutStarEnvs Penv	:call atplib#motion#GotoEnvironment('bsW',<q-count>,<q-args>) | let v:searchforward=0
"TODO: These two commands should also work with sections.
command! -buffer -count=1 -nargs=? -complete=customlist,atplib#various#F_compl F	:call atplib#motion#GotoEnvironment('sW',<q-count>,<q-args>)  | let v:searchforward=1
command! -buffer -count=1 -nargs=? -complete=customlist,atplib#various#F_compl B	:call atplib#motion#GotoEnvironment('bsW',<q-count>,<q-args>) | let v:searchforward=0

nnoremap <silent> <buffer> <Plug>GotoNextEnvironment		:<C-U>call atplib#motion#GotoEnvironment('sW',v:count1,'')<CR>
nnoremap <silent> <buffer> <Plug>GotoPreviousEnvironment	:<C-U>call atplib#motion#GotoEnvironment('bsW',v:count1,'')<CR>

nnoremap <silent> <buffer> <Plug>GotoNextMath			:<C-U>call atplib#motion#GotoEnvironment('sW',v:count1,'math')<CR>
nnoremap <silent> <buffer> <Plug>GotoPreviousMath		:<C-U>call atplib#motion#GotoEnvironment('bsW',v:count1,'math')<CR>

nnoremap <silent> <buffer> <Plug>GotoNextInlineMath		:<C-U>call atplib#motion#GotoEnvironment('sW',v:count1,'inlinemath')<CR>
nnoremap <silent> <buffer> <Plug>GotoPreviousInlineMath		:<C-U>call atplib#motion#GotoEnvironment('bsW',v:count1,'inlinemath')<CR>

nnoremap <silent> <buffer> <Plug>GotoNextDisplayedMath	 	:<C-U>call atplib#motion#GotoEnvironment('sW',v:count1,'displayedmath')<CR>
nnoremap <silent> <buffer> <Plug>GotoPreviousDisplayedMath	:<C-U>call atplib#motion#GotoEnvironment('bsW',v:count1,'displayedmath')<CR>

if &l:cpoptions =~# 'B'
    nnoremap <silent> <Plug>GotoNextParagraph		:<C-U>call atplib#motion#GotoSection("", v:count1, "s", "\\\\\\%(paragraph\\\\|subsection\\\\|section\\\\|chapter\\\\|part\\)\\*\\=\\>", ( g:atp_mapNn ? 'atp' : 'vim' ), 'n', '')<CR>
    onoremap <silent> <Plug>GotoNextParagraph		:<C-U>call atplib#motion#GotoSection("", v:count1, "s","\\\\\\%(paragraph\\\\|subsection\\\\|section\\\\|chapter\\\\|part\\)\\*\\=\\>", 'vim')<CR>
    vnoremap <silent> <Plug>vGotoNextParagraph		m':<C-U>exe "normal! gv"<Bar>exe "normal! w"<Bar>call search('^\([^%]\\|\\\@<!\\%\)*\\\%(paragraph\\|subsection\\|section\\|chapter\\|part\)\*\=\>\\|\\end\s*{\s*document\s*}', 'W')<Bar>exe "normal! b"<CR>

    nnoremap <silent> <Plug>GotoNextSubSection		:<C-U>call atplib#motion#GotoSection("", v:count1, "s", "\\\\\\%(subsection\\\\|section\\\\|chapter\\\\|part\\)\\*\\=\\>", ( g:atp_mapNn ? 'atp' : 'vim' ), 'n', '')<CR>
    onoremap <silent> <Plug>GotoNextSubSection		:<C-U>call atplib#motion#GotoSection("", v:count1, "s","\\\\\\%(subsection\\\\|section\\\\|chapter\\\\|part\\)\\*\\=\\>", 'vim')<CR>
    vnoremap <silent> <Plug>vGotoNextSubSection		m':<C-U>exe "normal! gv"<Bar>exe "normal! w"<Bar>call search('^\([^%]\\|\\\@<!\\%\)*\\\%(subsection\\|section\\|chapter\\|part\)\*\=\>\\|\\end\s*{\s*document\s*}', 'W')<Bar>exe "normal! b"<CR>

    nnoremap <silent> <Plug>GotoNextSection		:<C-U>call atplib#motion#GotoSection("", v:count1, "s", "\\\\\\%(section\\\\|chapter\\\\|part\\)\\*\\=\\>", ( g:atp_mapNn ? 'atp' : 'vim' ), 'n', '')<CR>
    onoremap <silent> <Plug>GotoNextSection		:<C-U>call atplib#motion#GotoSection("", v:count1, "s", "\\\\\\%(section\\\\|chapter\\\\|part\\)\\*\\=\\>", 'vim')<CR>
    vnoremap <silent> <Plug>vGotoNextSection		m':<C-U>exe "normal! gv"<Bar>exe "normal! w"<Bar>call search('^\([^%]\\|\\\@<!\\%\)*\\\%(section\\|chapter\\|part\)\*\=\>\\|\\end\s*{\s*document\s*}', 'W')<Bar>exe "normal! b"<CR>

    nnoremap <silent> <Plug>GotoNextChapter		:<C-U>call atplib#motion#GotoSection("", v:count1, "s", "\\\\\\%(chapter\\\\|part\\)\\*\\=\\>", ( g:atp_mapNn ? 'atp' : 'vim' ))<CR>
    onoremap <silent> <Plug>GotoNextChapter		:<C-U>call atplib#motion#GotoSection("", v:count1, "s", "\\\\\\%(chapter\\\\|part\\)\\*\\=\\>", 'vim')<CR>
    vnoremap <silent> <Plug>vGotoNextChapter		m':<C-U>exe "normal! gv"<Bar>exe "normal! w"<Bar>call search('^\([^%]\\|\\\@<!\\%\)*\\\%(chapter\\|part\)\*\=\>\\|\\end\s*{\s*document\s*}', 'W')<Bar>exe "normal! b"<CR>

    nnoremap <silent> <Plug>GotoNextPart		:<C-U>call atplib#motion#GotoSection("", v:count1, "s", "\\\\part\\*\\=\\>", ( g:atp_mapNn ? 'atp' : 'vim' ), 'n')<CR>
    onoremap <silent> <Plug>GotoNextPart		:<C-U>call atplib#motion#GotoSection("", v:count1, "s", "\\\\part\\*\\=\\>", 'vim', 'n')<CR>
    vnoremap <silent> <Plug>vGotoNextPart		m':<C-U>exe "normal! gv"<Bar>exe "normal! w"<Bar>call search('^\([^%]\\|\\\@<!\\%\)*\\\%(part\*\=\>\\|\\end\s*{\s*document\s*}\)', 'W')<Bar>exe "normal! b"<CR>
else
    nnoremap <silent> <Plug>GotoNextParagraph		:<C-U>call atplib#motion#GotoSection("", v:count1, "s", '\\\\\\%(paragraph\\\\|subsection\\\\|section\\\\|chapter\\\\|part\\)\\*\\=\\>', ( g:atp_mapNn ? 'atp' : 'vim' ), 'n', '')<CR>
    onoremap <silent> <Plug>GotoNextParagraph		:<C-U>call atplib#motion#GotoSection("", v:count1, "s",'\\\\\\%(paragraph\\\\|subsection\\\\|section\\\\|chapter\\\\|part\\)\\*\\=\\>', 'vim')<CR>
    vnoremap <silent> <Plug>vGotoNextParagraph		m':<C-U>exe "normal! gv"<Bar>exe "normal! w"<Bar>call search('^\\([^%]\\\\|\\\\\\@<!\\\\%\\)*\\\\\\%(paragraph\\\\|subsection\\\\|section\\\\|chapter\\\\|part\\)\\*\\=\\>\\\\|\\\\end\\s*{\\s*document\\s*}', 'W')<Bar>exe "normal! b"<CR>

    nnoremap <silent> <Plug>GotoNextSubSection		:<C-U>call atplib#motion#GotoSection("", v:count1, "s", '\\\\\\%(subsection\\\\|section\\\\|chapter\\\\|part\\)\\*\\=\\>', ( g:atp_mapNn ? 'atp' : 'vim' ), 'n', '')<CR>
    onoremap <silent> <Plug>GotoNextSubSection		:<C-U>call atplib#motion#GotoSection("", v:count1, "s",'\\\\\\%(subsection\\\\|section\\\\|chapter\\\\|part\\)\\*\\=\\>', 'vim')<CR>
    vnoremap <silent> <Plug>vGotoNextSubSection		m':<C-U>exe "normal! gv"<Bar>exe "normal! w"<Bar>call search('^\\([^%]\\\\|\\\\\\@<!\\\\%\\)*\\\\\\%(subsection\\\\|section\\\\|chapter\\\\|part\\)\\*\\=\\>\\\\|\\\\end\\s*{\\s*document\\s*}', 'W')<Bar>exe "normal! b"<CR>

    nnoremap <silent> <Plug>GotoNextSection		:<C-U>call atplib#motion#GotoSection("", v:count1, "s", '\\\\\\%(section\\\\|chapter\\\\|part\\)\\*\\=\\>', ( g:atp_mapNn ? 'atp' : 'vim' ), 'n', '')<CR>
    onoremap <silent> <Plug>GotoNextSection		:<C-U>call atplib#motion#GotoSection("", v:count1, "s", '\\\\\\%(section\\\\|chapter\\\\|part\\)\\*\\=\\>', 'vim')<CR>
    vnoremap <silent> <Plug>vGotoNextSection		m':<C-U>exe "normal! gv"<Bar>exe "normal! w"<Bar>call search('^\\([^%]\\\\|\\\\\\@<!\\\\%\\)*\\\\\\%(section\\\\|chapter\\\\|part\\)\\*\\=\\>\\\\|\\\\end\\s*{\\s*document\\s*}', 'W')<Bar>exe "normal! b"<CR>

    nnoremap <silent> <Plug>GotoNextChapter		:<C-U>call atplib#motion#GotoSection("", v:count1, "s", '\\\\\\%(chapter\\\\|part\\)\\*\\=\\>', ( g:atp_mapNn ? 'atp' : 'vim' ))<CR>
    onoremap <silent> <Plug>GotoNextChapter		:<C-U>call atplib#motion#GotoSection("", v:count1, "s", '\\\\\\%(chapter\\\\|part\\)\\*\\=\\>', 'vim')<CR>
    vnoremap <silent> <Plug>vGotoNextChapter		m':<C-U>exe "normal! gv"<Bar>exe "normal! w"<Bar>call search('^\\([^%]\\\\|\\\\\\@<!\\\\%\\)*\\\\\\%(chapter\\\\|part\\)\\*\\=\\>\\\\|\\\\end\\s*{\\s*document\\s*}', 'W')<Bar>exe "normal! b"<CR>

    nnoremap <silent> <Plug>GotoNextPart		:<C-U>call atplib#motion#GotoSection("", v:count1, "s", '\\\\part\\*\\=\\>', ( g:atp_mapNn ? 'atp' : 'vim' ), 'n')<CR>
    onoremap <silent> <Plug>GotoNextPart		:<C-U>call atplib#motion#GotoSection("", v:count1, "s", '\\\\part\\*\\=\\>', 'vim', 'n')<CR>
    vnoremap <silent> <Plug>vGotoNextPart		m':<C-U>exe "normal! gv"<Bar>exe "normal! w"<Bar>call search('^\\([^%]\\\\|\\\\\\@<!\\\\%\\)*\\\\\\%(part\\*\\=\\>\\\\|\\\\end\\s*{\\s*document\\s*}\\)', 'W')<Bar>exe "normal! b"<CR>
endif

command! -buffer -bang -count=1 -nargs=? -complete=customlist,atplib#motion#Env_compl NSSSec		:call atplib#motion#GotoSection(<q-bang>, <q-count>, "s", '\\\%(subsubsection\|subsection\|section\|chapter\|part\)\*\=\>', ( g:atp_mapNn ? 'atp' : 'vim' ), 'n', <q-args>)
command! -buffer -bang -count=1 -nargs=? -complete=customlist,atplib#motion#Env_compl NSSec		:call atplib#motion#GotoSection(<q-bang>, <q-count>, "s", '\\\%(subsection\|section\|chapter\|part\)\*\=\>', ( g:atp_mapNn ? 'atp' : 'vim' ), 'n', <q-args>)
command! -buffer -bang -count=1 -nargs=? -complete=customlist,atplib#motion#Env_compl NSec		:call atplib#motion#GotoSection(<q-bang>, <q-count>, "s", '\\\%(section\|chapter\|part\)\*\=\>', ( g:atp_mapNn ? 'atp' : 'vim' ), 'n', <q-args>)
command! -buffer -bang -count=1 -nargs=? -complete=customlist,atplib#motion#Env_compl NChap		:call atplib#motion#GotoSection(<q-bang>, <q-count>, "s", '\\\%(chapter\|part\)\*\=\>', ( g:atp_mapNn ? 'atp' : 'vim' ), 'n', <q-args>)
command! -buffer -bang -count=1 -nargs=? -complete=customlist,atplib#motion#Env_compl NPart		:call atplib#motion#GotoSection(<q-bang>, <q-count>, "s", '\\part\*\=\>', ( g:atp_mapNn ? 'atp' : 'vim' ), 'n', <q-args>)

if &l:cpoptions =~# 'B'
    nnoremap <silent> <Plug>GotoPreviousParagraph	:<C-U>call atplib#motion#GotoSection("", v:count1, "sb", "\\\\\\%(paragraph\\\\|subsection\\\\|section\\\\|chapter\\\\|part\\)\\*\\=\\>", ( g:atp_mapNn ? 'atp' : 'vim' ), 'n')<CR>
    onoremap <silent> <Plug>GotoPreviousParagraph	:<C-U>call atplib#motion#GotoSection("", v:count1, "sb", "\\\\\\%(paragraph\\\\|subsection\\\\|section\\\\|chapter\\\\|part\\)\\*\\=\\>", 'vim')<CR>
    vnoremap <silent> <Plug>vGotoPreviousParagraph	m':<C-U>exe "normal! gv"<Bar>call search('\\\%(paragraph\\\\|subsection\\|section\\|chapter\\|part\)\*\=\>\\|\\begin\s*{\s*document\s*}', 'bW')<CR>

    nnoremap <silent> <Plug>GotoPreviousSubSection	:<C-U>call atplib#motion#GotoSection("", v:count1, "sb", "\\\\\\%(subsection\\\\|section\\\\|chapter\\\\|part\\)\\*\\=\\>", ( g:atp_mapNn ? 'atp' : 'vim' ), 'n')<CR>
    onoremap <silent> <Plug>GotoPreviousSubSection	:<C-U>call atplib#motion#GotoSection("", v:count1, "sb", "\\\\\\%(subsection\\\\|section\\\\|chapter\\\\|part\\)\\*\\=\\>", 'vim')<CR>
    vnoremap <silent> <Plug>vGotoPreviousSubSection	m':<C-U>exe "normal! gv"<Bar>call search('\\\%(subsection\\|section\\|chapter\\|part\)\*\=\>\\|\\begin\s*{\s*document\s*}', 'bW')<CR>

    nnoremap <silent> <Plug>GotoPreviousSection	:<C-U>call atplib#motion#GotoSection("", v:count1, "sb", "\\\\\\%(section\\\\|chapter\\\\|part\\)\\*\\=\\>", ( g:atp_mapNn ? 'atp' : 'vim' ), 'n')<CR>
    onoremap <silent> <Plug>GotoPreviousSection	:<C-U>call atplib#motion#GotoSection("", v:count1, "sb", "\\\\\\%(section\\\\|chapter\\\\|part\\)\\*\\=\\>", 'vim')<CR>
    vnoremap <silent> <Plug>vGotoPreviousSection	m':<C-U>exe "normal! gv"<Bar>call search('\\\%(section\\|chapter\\|part\)\*\=\>\\|\\begin\s*{\s*document\s*}', 'bW')<CR>

    nnoremap <silent> <Plug>GotoPreviousChapter	:<C-U>call atplib#motion#GotoSection("", v:count1, "sb", "\\\\\\%(chapter\\\\|part\\)\\>", ( g:atp_mapNn ? 'atp' : 'vim' ))<CR>
    onoremap <silent> <Plug>GotoPreviousChapter	:<C-U>call atplib#motion#GotoSection("", v:count1, "sb", "\\\\\\%(chapter\\\\|part\\)\\>", 'vim')<CR
    vnoremap <silent> <Plug>vGotoPreviousChapter	m':<C-U>exe "normal! gv"<Bar>call search('\\\%(chapter\\|part\)\*\=\>\\|\\begin\s*{\s*document\s*}', 'bW')<CR>

    nnoremap <silent> <Plug>GotoPreviousPart	:<C-U>call atplib#motion#GotoSection("", v:count1, "sb", "\\\\part\\*\\=\\>", ( g:atp_mapNn ? 'atp' : 'vim' ))<CR>
    onoremap <silent> <Plug>GotoPreviousPart	:<C-U>call atplib#motion#GotoSection("", v:count1, "sb", "\\\\part\\*\\=\\>", 'vim')<CR>
    vnoremap <silent> <Plug>vGotoPreviousPart	m':<C-U>exe "normal! gv"<Bar>call search('\\\%(part\*\=\)\>', 'bW')<CR>
else
    nnoremap <silent> <Plug>GotoPreviousParagraph	:<C-U>call atplib#motion#GotoSection("", v:count1, "sb", '\\\\\\%(paragraph\\\\|subsection\\\\|section\\\\|chapter\\\\|part\\)\\*\\=\\>', ( g:atp_mapNn ? 'atp' : 'vim' ), 'n')<CR>
    onoremap <silent> <Plug>GotoPreviousParagraph	:<C-U>call atplib#motion#GotoSection("", v:count1, "sb", '\\\\\\%(paragraph\\\\|subsection\\\\|section\\\\|chapter\\\\|part\\)\\*\\=\\>', 'vim')<CR>
    vnoremap <silent> <Plug>vGotoPreviousParagraph	m':<C-U>exe "normal! gv"<Bar>call search('\\\\\\%(paragraph\\\\|subsection\\\\|section\\\\|chapter\\\\|part\\)\\*\\=\\>\\\\|\\\\begin\\s*{\\s*document\\s*}', 'bW')<CR>

    nnoremap <silent> <Plug>GotoPreviousSubSection	:<C-U>call atplib#motion#GotoSection("", v:count1, "sb", '\\\\\\%(subsection\\\\|section\\\\|chapter\\\\|part\\)\\*\\=\\>', ( g:atp_mapNn ? 'atp' : 'vim' ), 'n')<CR>
    onoremap <silent> <Plug>GotoPreviousSubSection	:<C-U>call atplib#motion#GotoSection("", v:count1, "sb", '\\\\\\%(subsection\\\\|section\\\\|chapter\\\\|part\\)\\*\\=\\>', 'vim')<CR>
    vnoremap <silent> <Plug>vGotoPreviousSubSection	m':<C-U>exe "normal! gv"<Bar>call search('\\\\\\%(subsection\\\\|section\\\\|chapter\\\\|part\\)\\*\\=\\>\\\\|\\\\begin\\s*{\\s*document\\s*}', 'bW')<CR>

    nnoremap <silent> <Plug>GotoPreviousSection	:<C-U>call atplib#motion#GotoSection("", v:count1, "sb", '\\\\\\%(section\\\\|chapter\\\\|part\\)\\*\\=\\>', ( g:atp_mapNn ? 'atp' : 'vim' ), 'n')<CR>
    onoremap <silent> <Plug>GotoPreviousSection	:<C-U>call atplib#motion#GotoSection("", v:count1, "sb", '\\\\\\%(section\\\\|chapter\\\\|part\\)\\*\\=\\>', 'vim')<CR>
    vnoremap <silent> <Plug>vGotoPreviousSection	m':<C-U>exe "normal! gv"<Bar>call search('\\\\\\%(section\\\\|chapter\\\\|part\\)\\*\\=\\>\\\\|\\\\begin\\s*{\\s*document\\s*}', 'bW')<CR>

    nnoremap <silent> <Plug>GotoPreviousChapter	:<C-U>call atplib#motion#GotoSection("", v:count1, "sb", '\\\\\\%(chapter\\\\|part\\)\\>', ( g:atp_mapNn ? 'atp' : 'vim' ))<CR>
    onoremap <silent> <Plug>GotoPreviousChapter	:<C-U>call atplib#motion#GotoSection("", v:count1, "sb", '\\\\\\%(chapter\\\\|part\\)\\>', 'vim')<CR
    vnoremap <silent> <Plug>vGotoPreviousChapter	m':<C-U>exe "normal! gv"<Bar>call search('\\\\\\%(chapter\\\\|part\\)\\*\\=\\>\\\\|\\\\begin\\s*{\\s*document\\s*}', 'bW')<CR>

    nnoremap <silent> <Plug>GotoPreviousPart	:<C-U>call atplib#motion#GotoSection("", v:count1, "sb", '\\\\part\\*\\=\\>', ( g:atp_mapNn ? 'atp' : 'vim' ))<CR>
    onoremap <silent> <Plug>GotoPreviousPart	:<C-U>call atplib#motion#GotoSection("", v:count1, "sb", '\\\\part\\*\\=\\>', 'vim')<CR>
    vnoremap <silent> <Plug>vGotoPreviousPart	m':<C-U>exe "normal! gv"<Bar>call search('\\\\\\%(part\\*\\=\\)\\>', 'bW')<CR>
endif


if &l:cpoptions =~# 'B'
    command! -buffer -bang -count=1 -nargs=? -complete=customlist,atplib#motion#Env_compl PSSSec		:call atplib#motion#GotoSection(<q-bang>, <q-count>, 'sb', '\\\%(\%(sub\)\{1,2}section\|section\|chapter\|part\)\*\=\>', ( g:atp_mapNn ? 'atp' : 'vim' ), 'n', <q-args>)
    command! -buffer -bang -count=1 -nargs=? -complete=customlist,atplib#motion#Env_compl PSSec		:call atplib#motion#GotoSection(<q-bang>, <q-count>, 'sb', '\\\%(subsection\|section\|chapter\|part\)\*\=\>', ( g:atp_mapNn ? 'atp' : 'vim' ), 'n', <q-args>)
    command! -buffer -bang -count=1 -nargs=? -complete=customlist,atplib#motion#Env_compl PSec		:call atplib#motion#GotoSection(<q-bang>, <q-count>, 'sb', '\\\%(section\|chapter\|part\)\*\=\>', ( g:atp_mapNn ? 'atp' : 'vim' ), 'n', <q-args>)
    command! -buffer -bang -count=1 -nargs=? -complete=customlist,atplib#motion#Env_compl PChap		:call atplib#motion#GotoSection(<q-bang>, <q-count>, 'sb', '\\\%(chapter\|part\)\*\=\>', ( g:atp_mapNn ? 'atp' : 'vim' ), 'n', <q-args>)
    command! -buffer -bang -count=1 -nargs=? -complete=customlist,atplib#motion#Env_compl PPart		:call atplib#motion#GotoSection(<q-bang>, <q-count>, 'sb', '\\part\*\=\>', ( g:atp_mapNn ? 'atp' : 'vim' ), 'n', <q-args>)
else
    command! -buffer -bang -count=1 -nargs=? -complete=customlist,atplib#motion#Env_compl PSSSec		:call atplib#motion#GotoSection(<q-bang>, <q-count>, 'sb', '\\\\\\%(\\%(sub\\)\\{1,2}section\\|section\\|chapter\\|part\\)\\*\\=\\>', ( g:atp_mapNn ? 'atp' : 'vim' ), 'n', <q-args>)
    command! -buffer -bang -count=1 -nargs=? -complete=customlist,atplib#motion#Env_compl PSSec		:call atplib#motion#GotoSection(<q-bang>, <q-count>, 'sb', '\\\\\\%(subsection\\|section\\|chapter\\|part\\)\\*\\=\\>', ( g:atp_mapNn ? 'atp' : 'vim' ), 'n', <q-args>)
    command! -buffer -bang -count=1 -nargs=? -complete=customlist,atplib#motion#Env_compl PSec		:call atplib#motion#GotoSection(<q-bang>, <q-count>, 'sb', '\\\\\\%(section\\|chapter\\|part\\)\\*\\=\\>', ( g:atp_mapNn ? 'atp' : 'vim' ), 'n', <q-args>)
    command! -buffer -bang -count=1 -nargs=? -complete=customlist,atplib#motion#Env_compl PChap		:call atplib#motion#GotoSection(<q-bang>, <q-count>, 'sb', '\\\\\\%(chapter\\|part\\)\\*\\=\\>', ( g:atp_mapNn ? 'atp' : 'vim' ), 'n', <q-args>)
    command! -buffer -bang -count=1 -nargs=? -complete=customlist,atplib#motion#Env_compl PPart		:call atplib#motion#GotoSection(<q-bang>, <q-count>, 'sb', '\\\\part\\*\\=\\>', ( g:atp_mapNn ? 'atp' : 'vim' ), 'n', <q-args>)
endif

command! -buffer -count=1 NInput			:call atplib#motion#Input("w", <q-count>)| let v:searchforward = 1
command! -buffer -count=1 PInput 			:call atplib#motion#Input("bw", <q-count>)| let v:searchforward = 0
command! -buffer -nargs=? -bang -complete=customlist,atplib#motion#GotoFileComplete GotoFile	:call atplib#motion#GotoFile(<q-bang>,<q-args>, 0)
command! -buffer -nargs=? -bang -complete=customlist,atplib#motion#GotoFileComplete Edit 	:call atplib#motion#GotoFile(<q-bang>,<q-args>, 0)
command! -bang -nargs=? -complete=customlist,atplib#motion#GotoLabelCompletion GotoLabel  		:call atplib#motion#GotoLabel(<q-bang>, <q-args>)
" vim:fdm=marker:tw=85:ff=unix:noet:ts=8:sw=4:fdc=1
