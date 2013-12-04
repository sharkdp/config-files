" Title:	Vim syntax file
" Author:	Marcin Szamotulski
" Note:		This file is a part of Automatic Tex Plugin for Vim.
" URL:		https://launchpad.net/automatictexplugin

syntax match atp_Help /^".*$/
syntax match atp_FileName /^>> .*$/
syntax match atp_Number /\%(\d\+\.\?\|\*\|-\)\+/ms=b,me=e contained nextgroup=atp_SectionTitle,atp_SubSectionTitle 
syntax match atp_Abstract /\s\s\(\S\&\D\).*$/ 
syntax match atp_Chapter /^\s*\%(\d\+\|\*\|-\)\s.*/ contains=atp_Number,atp_ChapterTitle
syntax match atp_Section /^\s*\(\d\+\.\d\+\|\s\{3,}\|\*\|-\)\s.\+/ contains=atp_LineNr,atp_Number,atp_SectionTitle 
syntax match atp_SubSection /^\s*\(\d\+\.\d\+\.\d\+\|\s\{5,}\|\*\|-\)\s.\+/ contains=atp_Number,atp_SubSectionTitle 

hi link atp_FileName 	Directory
hi link atp_LineNr 	LineNr
hi link atp_Number 	Number
hi link atp_Abstract 	Label
hi link atp_Chapter 	Title
hi link atp_Section 	Label 
hi link atp_SubSection 	Normal
hi link atp_Help	String
