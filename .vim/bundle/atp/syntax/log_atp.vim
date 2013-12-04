" Tite: 	Syntax file for tex log messages
" Author: 	Marcin Szamotulski
" Note:		This file is a part of Automatic Tex Plugin for Vim.
" URL:		https://launchpad.net/automatictexplugin

syntax keyword texlogKeyword 		LuaTeX LaTeX2e Babel pdfTeXk pdfTeX Web2C pdflatex latex teTeX TeXLive ON OFF 

" There is a small bug with this: 
" syntax keyword texlogLatexKeyword	LaTeX 			contained

syntax match texlogBrackets		'(\|)\|{\|}\|\\@<!\[\|\\@<!\]\|<\|>'

syntax match texlogOpenOut		'\\openout\d\+'

syntax match texlogDate			'\%(\s\|<\)\zs\%(\d\d\=\s\w\w\w\s\d\d\d\d\s\d\d:\d\d\|\d\d\d\d\/\d\d\/\d\d\)\ze\%(\s\|>\|$\)' 	
syntax match texlogVersion		'\<\%(v\|ver\)\s*\d*\.\d*\w\>'

" keywords: obsolete, undefined, not available
syntax match texlogWarningKeyword	'o\n\?b\n\?s\n\?o\n\?l\n\?e\n\?t\n\?e\|u\n\?n\n\?d\n\?e\n\?f\n\?i\n\?n\n\?e\n\?d\|n\n\?o\n\?t\_s\+a\n\?v\n\?a\n\?i\n\?l\n\?a\n\?b\n\?l\n\?e' 

syntax match texlogLatexInfo		'LaTeX Info:' 		contains=NONE
syntax match texlogLatexFontInfo	'LaTeX Font Info:' 	contains=NONE
syntax match texlogEndInfo		'Output written on\s\+\%(\S\|\.\|\\\s\|\n\)*' contains=texlogOutputWritten,texlogFileName transparent
syntax match texlogOutputWritten	'Output written on' 	contained 
syntax match texlogPages		'\zs\_d\+\_s\+pages\ze,\_s*\_d\+\_s\+bytes'

syntax match texlogPath			'\%(\/\%(\w\|-\|\\.\|\s\|\n\)\+\)\+\%(\.\_w\+\ze\%($\|)\)\)\+'
syntax match texlogPathB		'\%(<\|{\|\n\=\)\%(\/\%(\w\|-\|\\.\|\s\|\n\)\+\)\+\%(\.\_w\+\ze\%($\|)\|\n\=\)\)\+\%(>\|}\)'
syntax match texlogFont			'\\\=\%(OT\d\|T\d\|OMS\|OML\|U\|OMX\|PD\d\)\n\?\%(\/\_w\+\)\+'
syntax match texlogFontB		'\%(OT\d\|T\d\|OMS\|OML\|U\|OMX\|PD\d\)\n\?+\_w\+'
syntax match texlogFontSize		'<\d\+\%(\.\d\+\)\?>'

syntax match texlogLatexWarning		'LaTeX Warning:' 	contains=NONE
" is visible in synstack but is not highlighted.
syntax match texlogLatexFontWarning	'LaTeX Font Warning:' 	contains=NONE

syntax match texlogPdfTeXWarning	'pdfTeX warning'	contains=NONE

syntax match texlogPackageWarning	'Package\s\+\_w\+\_s\+Warning'
syntax match texlogPackageInfo		'Package\s\+\_w\+\_s\+Info'

syntax match texlogError		'^!.*$' contains=texlogLineNr

syntax match texlogOverfullBox		'Overfull\_s\\[hv]box'
syntax match texlogUnderfullBox		'Underfull\_s\\[hv]box'
syntax match texlogTooWide		't\n\?o\n\?o\_sw\n\?i\n\?d\n\?e'
syntax match texlogMultiplyDefined	'm\n\?u\n\?l\n\?t\n\?i\n\?p\n\?l\n\?y\%(\_s\s\?\|\n\?-\n\?\)\n\?d\n\?e\n\?f\n\?i\n\?n\n\?e\n\?d'
syntax match texlogRedefining		'\cr\n\?e\n\?d\n\?e\n\?f\n\?i\n\?n\n\?i\n\?n\n\?g'
syntax match texlogRedeclaring		'\cr\n\?e\n\?d\n\?e\n\?c\n\?l\n\?a\n\?r\n\?i\n\?n\n\?g'
syntax match texlogSourceSpecials	'S\n\?o\n\?u\n\?r\n\?c\n\?e\_ss\n\?p\n\?e\n\?c\n\?i\n\?a\n\?l\n\?s'
syntax match texlogLineParsing		'%\n\?&\n\?-\n\?l\n\?i\n\?n\n\?e\_sp\n\?a\n\?r\n\?s\n\?i\n\?n\n\?g'
syntax match texlogEnabled		'e\n\?n\n\?a\n\?b\n\?l\n\?e\n\?d' 

syntax match texlogLineNr		'\%(^l\.\|\so\n\?n\_si\n\?n\n\?p\n\?u\n\?t\_sl\n\?i\n\?n\n\?e\_s*\)\_d\+\s\?\|\s\?a\n\?t\n\?\_sl\n\?i\n\?n\n\?e\n\?s\_s\+\_d\+--\_d\+\s\?'
syntax match texlogPageNr		'\[\_d\+\%(\_s*{[^}]*}\)\?\]\|\s\?o\n\?n\n?\_sp\n\?a\n\?g\n\?e\_s\_d\+'

syntax match texlogDocumentClass	'Document Class:\s\+\S*'
syntax match texlogPackage		'Package:\s\+\S*'
syntax match texlogFile			'File:\s\+\S*'
syntax match texlogFileName		'\/\zs\%(\w\|\\\s\|-\|\n\)\+\.\%(dvi\|pdf\|ps\)' contained
syntax match texlogCitation		'Citation\s\+\`[^']*\'' 	contains=texlogScope
syntax match texlogReference		'Reference\s\+\`[^']*\'' 	contains=texlogScope
syntax match texlogScope		'\%(^\|\s\)\%(\`\|\'\)\zs[^']*\ze\'\%($\|\s\|\.\)'

syntax match texlogFontShapes		'\Cfont shapes' 
syntax match texlogChapter		'Chapter\s\+\%(\d\|\.\)\+'

" syntax match texlogDelimiter		'(\|)'
"
" This works only with 'sync fromstart'.
" syntax region texlogBracket	start="(" skip="\\[()]"	end=")" transparent contains=texlogPath,texlogPathB,texlogLatexInfo,texlogFontInfo,texlogEndInfo,texlogOutputWritten,texlogLatexWarning,texlogLatexFontInfo,texlogLatexFontWarning,texlogPackageWarning,texlogPackageInfo,texlogError,texlogLineNr,texlogPageNr,texlogPackage,texlogDocumentClass,texlogFile,texlogCitation,texlogReference,texlogKeyword,texlogLatexKeyword,texlogScope,texlogFont,texlogFontB,texlogFontSize,texlogOverfullBox,texlogUnderfullBox,texlogTooWide,texlogRedefining,texlogRedeclaring,texlogDate,texlogVersion,texlogWarningKeyword,texlogPages,texlogFontShapes,texlogOpenOut,texlogPdfTeXWarning,texlogBrackets,texlogEndInfo,texlogFileName,texlogPages,texlogChapter,texlogMultiplyDefined,texlogEnabled
" 
" syntax sync fromstart 

hi def link texlogKeyword		Keyword
hi def link texlogLatexKeyword		Keyword
hi def link texlogBrackets		Special
hi def link texlogOpenOut		Statement
hi def link texlogWarningKeyword	Identifier
hi def link texlogPath			Include
hi def link texlogPathB			texlogPath

hi def link texlogLatexInfo 		String

hi def link texlogOutputWritten		String
hi def link texlogFileName		Identifier
hi def link texlogPages			Identifier
hi def link texlogChapter		String

hi def link texlogLatexFontInfo 	String
hi def link texlogLatexWarning 		Identifier
hi def link texlogLatexFontWarning 	Identifier
hi def link texlogPackageWarning	Identifier
hi def link texlogPdfTeXWarning		Identifier
hi def link texlogPackageInfo 		String
hi def link texlogError 		Error

hi def link texlogLineNr		Number
hi def link texlogPageNr		Number

hi def link texlogDocumentClass		String
hi def link texlogPackage		String
hi def link texlogFile			String
hi def link texlogCitation		String
hi def link texlogReference		String
hi def link texlogOverfullBox		Function
hi def link texlogUnderfullBox		Function
hi def link texlogTooWide		Function
hi def link texlogRedefining		Function
hi def link texlogRedeclaring		Function
hi def link texlogSourceSpecials	Keyword
hi def link texlogEnabled		Keyword
hi def link texlogLineParsing		Keyword
hi def link texlogMultiplyDefined	Function
hi def link texlogScope			Label 

hi def link texlogFont			Label
hi def link texlogFontB			Label
hi def link texlogFontSize		Label
hi def link texlogFontShapes		String

hi def link texlogDate			Number
hi def link texlogVersion		Number
