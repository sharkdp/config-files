" This file is a part of ATP.
" Written by M.Szamotulski.
" Based On: caption package documentation 2008/04/06.
let g:atp_caption_options	= [
	    \ 'format=', 'indentation=',
	    \ 'lableformat=', 'labelsep=',
	    \ 'textformat=', 'justification=',
	    \ 'singlelinecheck=off', 'font=', 'labelfont=', 'textfont=',
	    \ 'margin=', 'margin*=', 'width=', 'oneside', 'twoside', 
	    \ 'minmargin=', 'maxmargin=', 'parskip=', 'hangindent=',
	    \ 'style=', 'skip=', 'position=', 'list=', 'listformat=',
	    \ 'figurename=', 'tablename=', 'listfigurename=', 
	    \ 'listtablename=', 'figurewithin=', 'tablewithin='
	    \ ]
let s:vals = sort([ 'sriptsize', 'footnotesize', 'small', 'normalsize', 
			    \ 'large', 'Large', 'normalfont', 'up', 'it', 'sl',
			    \ 'sc', 'md', 'bf', 'rm', 'sf', 'tt', 'singlespacing',
			    \ 'onehalfspacing', 'stretch=', 'color=', 'normal' ])
let g:atp_caption_options_values = {
	    \ 'format\>' : [ 'plain', 'hang' ],
	    \ 'labelformat\>' : [ 'default', 'empty', 'simple', 'brace', 'parens' ],
	    \ 'textformat\>' : [ 'simple', 'period' ],
	    \ 'justification\>' : [ 'justified', 'centering', 'centerlast', 'centerfirst', 
					\ 'raggedright', 'RaggedRight', 'raggedleft' ],
	    \ '\%(label\|text\)\?font\>' : s:vals,
	    \ 'labelsep\>' : [ 'none', 'colon', 'period', 'space', 'quad', 'newline', 'endash' ],
	    \ 'style\>' : [ 'base', 'default' ],
	    \ '\%(figure\|table\)\?position\>' : [  'top', 'above', 'bottom', 'below', 'auto' ],
	    \ 'list\>' : [ 'on', 'off' ],
	    \ 'listformat\>' : [ 'empty', 'simple', 'parens', 'subsimple', 'subparens' ],
	    \ '\%(figure\|table\)within\>' : [ 'chapter', 'section', 'none' ],
	    \ }
" Notes own formats can be added using \DeclareCaptionFormat, the same for
" \DeclareCaptionLabelFormat, \DeclareCaptionLabelSeparator
let g:atp_caption_commands	= [
	    \ '\caption', '\captionof', 
	    \ '\captionlistentry{', 
	    \ '\captionsetup{', '\clearcaptionsetup',
	    \ '\showcaptionsetup{', '\ContinuedFloat', '\ContinuedFloat*', 
	    \ '\DeclareCaptionFormat{', '\DeclareCaptionLabelFormat{', 
	    \ '\DeclareCaptionTextFormat{', '\DeclareCaptionLabelSeparator',
	    \ '\DeclareCaptionJustification{', '\DeclareCaptionFont{', '\DeclareCaptionStyle{',
	    \ '\DeclareCaptionListFormat{', '\DeclareCaptionType{'
	    \ ]
let g:atp_caption_command_values = {
	    \ '\\captionsetup\s*\[[' : [ 'figure', 'table' ],
	    \ '\\captionsetup\s*\%(\[[^\]]*\]\)\=\s*{' : g:atp_caption_options,
	    \ '\\\%(captionof\*\=\|showcaptionsetup\)\s*{' : [ 'figure', 'table' ],
	    \ }
let g:atp_caption_command_values_dict = { 
	    \ '\\captionsetup' : g:atp_caption_options_values,
	    \ }
