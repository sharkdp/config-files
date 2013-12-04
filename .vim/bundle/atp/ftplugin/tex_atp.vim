" Title: Vim filetype plugin file
" Author: Marcin Szamotulski
" Web Page: http://atp-vim.sourceforge.net
" Mailing List:	atp-vim-list [AT] lists.sourceforge.net
" Do NOT DELETE the line just below, it is used by :UpdateATP (':help atp-:UpdateATP')
" Time Stamp: 28-04-13_16-23
" (but you can edit, if there is a reason for doing this. The format is dd-mm-yy_HH-MM)
" Language: tex
" Last Change: Sat Oct 27, 2012 at 11:16:57  +0100
" GetLatestVimScripts: 2945 62 :AutoInstall: tex_atp.vim
" GetLatestVimScripts: 884 1 :AutoInstall: AutoAlign.vim
" Copyright: © Marcin Szamotulski, 2012
" License: 
"     This file is a part of Automatic Tex Plugin for Vim.
"
"     Automatic Tex Plugin for Vim is free software: you can redistribute it
"     and/or modify it under the terms of the GNU General Public License as
"     published by the Free Software Foundation, either version 3 of the
"     License, or (at your option) any later version.
" 
"     Automatic Tex Plugin for Vim is distributed in the hope that it will be
"     useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
"     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
"     General Public License for more details.
" 
"     You should have received a copy of the GNU General Public License along
"     with Automatic Tex Plugin for Vim.  If not, see <http://www.gnu.org/licenses/>.
"
"     This licence applies to all files shipped with Automatic Tex Plugin.

" Do not source ATP if g:no_atp is set
if exists("g:no_atp") && g:no_atp || exists("b:did_ftplugin")
    finish
elseif  stridx(expand("%"), 'fugitive:') == 0
    " Minimal settings for Gdiff (fugitive plugin):
    " [these are setting needed for autocommands that are runnign with *.tex]
    let b:atp_MainFile = expand("")
    let b:atp_ProjectDir = expand("/tmp") " some files might be written: :LatexTags run through BufWrite autocommand.
    let b:atp_ProjectScript = 0
    let b:atp_XpdfServer = 'fugitive'
    let b:atp_StatusLine = ''
    let b:atp_statusCurSection = 0
    let b:TypeDict = {}
    let b:ListOfFiles = []
    let b:LevelDict = {}
    let b:atp_autex = 0
    let b:atp_updatetime_normal = 0
    let b:atp_updatetime_insert = 0
    " Note: ATP could run, but in this way Gdiff is faster.
    finish
endif

let b:did_ftplugin	= 1
let g:loaded_AutomaticLatexPlugin = "12.3"

if !exists("g:atp_reload_functions")
	let g:atp_reload_functions = 0
endif
if !exists("g:atp_reload_variables")
	let g:atp_reload_variables = 0
endif

if &cpo =~# 'C'
    set cpo-=C
endif
let saved_cpo = &cpo
if &cpo =~ '<'
    setl cpo-=<
endif

" Set Python path.
if has("python") || has("python3")
let atp_path = fnamemodify(expand('<sfile>'), ':p:s?tex_atp.vim$?ATP_files?')
python << EOF
import vim
import sys
sys.path.insert(0, vim.eval('atp_path'))
EOF
endif


	" Source Project Script
	runtime ftplugin/ATP_files/project.vim

	" ATPRC file overwrites project settings
	" (if the user put sth in atprc file, it means that he wants this globbaly) 
	call atplib#ReadATPRC()

	" Functions needed before setting options.
	runtime ftplugin/ATP_files/common.vim

	" Options, global and local variables, autocommands.
	runtime ftplugin/ATP_files/options.vim

	" Completion.
	runtime ftplugin/ATP_files/complete.vim

	runtime ftplugin/ATP_files/tex-fold.vim

	" Compilation related stuff.
	runtime ftplugin/ATP_files/compiler.vim

" 	let compiler_file = findfile('compiler/tex_atp.vim', &rtp)
" 	if compiler_file
" 		execute 'source ' 	. fnameescape(compiler_file)
" 	endif

	" LatexBox addons (by D.Munger, with some modifications).
	if g:atp_LatexBox

		runtime ftplugin/ATP_files/LatexBox_common.vim
		runtime ftplugin/ATP_files/LatexBox_complete.vim
		runtime ftplugin/ATP_files/LatexBox_motion.vim
		runtime ftplugin/ATP_files/LatexBox_latexmk.vim

	endif

	runtime ftplugin/ATP_files/motion.vim
	runtime ftplugin/ATP_files/search.vim
	runtime ftplugin/ATP_files/various.vim

	" Source maps and menu files.
	runtime ftplugin/ATP_files/mappings.vim

	if g:atp_LatexBox
		" LatexBox mappings.
		runtime ftplugin/ATP_files/LatexBox_mappings.vim
			
	endif

	" Source abbreviations.
	runtime ftplugin/ATP_files/abbreviations.vim

	" The menu.
	runtime ftplugin/ATP_files/menu.vim

	" Read ATPRC once again (to set mapps).
	call atplib#ReadATPRC()
	" Load Vim Settings from .tex.project file.

let &cpo=saved_cpo

" vim:fdm=marker:tw=85:ff=unix:noet:ts=8:sw=4:fdc=1
