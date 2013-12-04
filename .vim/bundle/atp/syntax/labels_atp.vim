" Title: 	Vim syntax file
" Author:	Marcin Szamotulski
" Note:		This file is a part of Automatic Tex Plugin for Vim.
" URL:		https://launchpad.net/automatictexplugin

syntax region 	atp_Label_Line start=/^/ end=/$/ transparent contains=atp_Label_CounterValue,atp_Label_Name,atp_Label_LineNr  oneline nextgroup=atp_Label_Section
syntax match 	atp_Label_CounterValue	/^\%(\d\%(\d\|\.\)*[[:alpha:]]\=\)\|\%(\C[IXVL]\+\)/ nextgroup=atp_Label_Counter,atp_Label_Name
syntax match 	atp_Label_Name 		/\s\S.*\ze(/ contains=atp_label_Counter
syntax match 	atp_Label_Counter	/\[\w\=\]/ contained
syntax match  	atp_Label_LineNr 	/(\d\+)/ nextgroup=atp_Label_LineNr
syntax match 	atp_Label_FileName 	/^\(\S\&\D\).*(\/[^)]*)$/	

hi link atp_Label_FileName 	Title
hi link atp_Label_LineNr 	LineNr
hi link atp_Label_Name 		Label
hi link atp_Label_Counter	Keyword
