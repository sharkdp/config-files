" This file is a part of ATP.
" Author: Marcin Szamotulski
" Based On: enumitem v3.5.2
"
" Todo: add completion for the \setlist command (values of options like for
" g:atp_enumitem_environment_options_values).

let s:env_options = [ 'label=', 'label*=', 'start=', 'ref=', 'align=', 'font=',
	\ 'topsep=', 'partopsep=', 'parsep=', 'itemsep=', 'leftmargin=',
	\ 'rightmargin=', 'listparindent=', 'labelwidth=', 'labelsep=', 'labelindent=', 'itemindent=',
	\ 'resume=', 'resume*=', 'beginpenalty=', 'midpenalty=', 'endpenalty=',
	\ 'before=', 'before*=', 'after=', 'after*=', 'style=', 'noitemsep', 'nolistsep', 'nosep',
	\ 'fullwidth', 'widest', 'series=', ]
" ToDo: This options are only valid if the package is declared with its 'inline'
" option:
call extend(s:env_options, [ 'itemjoin', 'afterlabel=' ])

let g:atp_enumitem_environment_options={
	\ '\<\%(enumerate\|itemize\|description\)\>' : s:env_options
	\ }
let s:options_values = { 
	    \ 'align\>' : [ 'left', 'right', 'parleft' ], 
	    \ 'style\>' : ['standard', 'unboxed', 'nextline', 'sameline', 'multiline' ], 
	    \ 'mode\>' : [ 'boxed', 'unboxed' ] 
	    \ }
let g:atp_enumitem_environment_options_values={
	    \ '\<\%(enumerate\|itemize\|description\)\>' : s:options_values
	    \ }
let g:atp_enumitem_command_values={
	\ '\\set\%(list\%(\[[^\]]*\]\)\=\|enumerate\|description\|itemize\){' : s:env_options,
	\ '\\SetLabelAlign' : [ 'left', 'right', 'perleft' ],
	\ '\\restartlist' : [ 'enumerate', 'enumerate*', 'itemize', 'itemize*', 'description', 'description*' ],
	\ }
let g:atp_enumitem_command_values_dict = {
	\ '\\setlist\s*\[[^\]]*\]\s*' : s:options_values,
	\ '\\setlist\s*\[\s*': ['enumerate', 'itemize', 'description'],
	\ }
