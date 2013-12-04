" Author: 	Marcin Szamotulski
" Description: 	This file contains help commands and variables (for mappings used by ATP) 
" Note:		This file is a part of Automatic Tex Plugin for Vim.
" Language:	tex
" Last Change:

" {{{1 Help Math IMAPS
function! atplib#helpfunctions#HelpMathIMaps()

    if exists("g:no_plugin_maps") || exists("g:no_atp_maps")
	echomsg "[ATP:] ATP maps are turned off"
	return ''
    endif

    echohl Title
    echo "MATH IMAPS"
    echohl WarningMsg
    echo "<maplocalleader> has value g:atp_imap_leader_1"
    echohl Normal
    echohl Keyword|echo g:atp_imap_leader_1."a"|echohl Normal|echon " \\alpha            "
    echohl Keyword|echon g:atp_imap_leader_1."b"|echohl Normal|echon " \\beta"
    " echo g:help_mathimaps
    echohl Keyword|echo g:atp_imap_leader_1."g"|echohl Normal|echon " \\gamma            "
    echohl Keyword|echon g:atp_imap_leader_1."d"|echohl Normal|echon " \\delta"
    echohl Keyword|echo g:atp_imap_leader_1."e"|echohl Normal|echon " \\epsilon          "
    echohl Keyword|echon g:atp_imap_leader_1."v"|echohl Normal|echon " \\varepsilon"
    echohl Keyword|echo g:atp_imap_leader_1."z"|echohl Normal|echon " \\zeta             "
    echohl Keyword|echon g:atp_imap_leader_1."h"|echohl Normal|echon " \\eta"
    echohl Keyword|echo g:atp_imap_leader_1."o"|echohl Normal|echon " \\theta            "
    echohl Keyword|echon g:atp_imap_leader_1."v"|echohl Normal|echon " \\vartheta"
    echohl Keyword|echo g:atp_imap_leader_1."i"|echohl Normal|echon " \\iota             "
    echohl Keyword|echon g:atp_imap_leader_1."k"|echohl Normal|echon " \\kappa"
    echohl Keyword|echo g:atp_imap_leader_1."l"|echohl Normal|echon " \\lambda           "
    echohl Keyword|echon g:atp_imap_leader_1."m"|echohl Normal|echon " \\mu"
    echohl Keyword|echo g:atp_imap_leader_1."n"|echohl Normal|echon " \\nu               "
    echohl Keyword|echon g:atp_imap_leader_1."x"|echohl Normal|echon " \\xi"
    echohl Keyword|echo g:atp_imap_leader_1."p"|echohl Normal|echon " \\pi               "
    echohl Keyword|echon g:atp_imap_leader_1."r"|echohl Normal|echon " \\rho"
    echohl Keyword|echo g:atp_imap_leader_1."s"|echohl Normal|echon " \\sigma            "
    echohl Keyword|echon g:atp_imap_leader_1."v"|echohl Normal|echon " \\varsigma"
    echohl Keyword|echo g:atp_imap_leader_1."t"|echohl Normal|echon " \\tau              "
    echohl Keyword|echon g:atp_imap_leader_1."u"|echohl Normal|echon " \\upsilon"
    echohl Keyword|echo g:atp_imap_leader_1."f"|echohl Normal|echon " \\phi              "
    echohl Keyword|echon g:atp_imap_leader_1."c"|echohl Normal|echon " \\chi"
    echohl Keyword|echo g:atp_imap_leader_1."y"|echohl Normal|echon " \\psi              "
    echohl Keyword|echon g:atp_imap_leader_1."w"|echohl Normal|echon " \\omega"
    echohl Keyword|echo g:atp_imap_leader_1."G"|echohl Normal|echon " \\Gamma            "
    echohl Keyword|echon g:atp_imap_leader_1."D"|echohl Normal|echon " \\Delta"
    echohl Keyword|echo g:atp_imap_leader_1."Z"|echohl Normal|echon " \\mathrm{Z}        "
    echohl Keyword|echon g:atp_imap_leader_1."O"|echohl Normal|echon " \\Theta"
    echohl Keyword|echo g:atp_imap_leader_1."L"|echohl Normal|echon " \\Lambda           "
    echohl Keyword|echon g:atp_imap_leader_1."M"|echohl Normal|echon " \\Mu"
    echohl Keyword|echo g:atp_imap_leader_1."N"|echohl Normal|echon " \\Nu               "
    echohl Keyword|echon g:atp_imap_leader_1."P"|echohl Normal|echon " \\Pi"
    echohl Keyword|echo g:atp_imap_leader_1."S"|echohl Normal|echon " \\Sigma            "
    echohl Keyword|echon g:atp_imap_leader_1."U"|echohl Normal|echon " \\Upsilon"
    echohl Keyword|echo g:atp_imap_leader_1."F"|echohl Normal|echon " \\Phi              "
    echohl Keyword|echon g:atp_imap_leader_1."Y"|echohl Normal|echon " \\Psi"
    echohl Keyword|echo g:atp_imap_leader_1."w"|echohl Normal|echon " \\Omega            "

    echohl Keyword|echo g:atp_imap_leader_1."+"|echohl Normal|echon " \\bigcup           "
    echohl Keyword|echon g:atp_imap_leader_1."-"|echohl Normal|echon " \\setminus"
    echohl Keyword|echo g:atp_imap_leader_1."8"|echohl Normal|echon " \\infty            "
    echohl Keyword|echon g:atp_imap_leader_1."&"|echohl Normal|echon " \\wedge"
    echohl Keyword|echo g:atp_imap_leader_1."m"|echohl Normal|echon " \\(\\)              "
    echohl Keyword|echon g:atp_imap_leader_1."M"|echohl Normal|echon " \\[\\]           "
    echohl WarningMsg|echon "<maplocalleader> has value g:atp_imap_leader_3"|echohl Normal
endfunction
silent call atplib#helpfunctions#HelpMathIMaps()

" {{{1 Help Environment IMAPS
function! atplib#helpfunctions#HelpEnvIMaps()

    if exists("g:no_plugin_maps") || exists("g:no_atp_maps")
	echomsg "[ATP:] ATP maps are turned off"
	return ''
    endif

    let help_envimaps = ''
		\." ".(g:atp_imap_begin != "" ? g:atp_imap_leader_3.g:atp_imap_begin." \\begin{}             " : "" ).(g:atp_imap_end != "" ? g:atp_imap_leader_3.g:atp_imap_end." \\end{}" : "")
		\."\n ".(g:atp_imap_theorem != "" ? g:atp_imap_leader_3.g:atp_imap_theorem." theorem              " : "" ).(g:atp_imap_definition != "" ? g:atp_imap_leader_3.g:atp_imap_definition." definition" : "")
		\."\n ".(g:atp_imap_proposition != "" ? g:atp_imap_leader_3.g:atp_imap_proposition." proposition          " : "").(g:atp_imap_lemma != "" ? g:atp_imap_leader_3.g:atp_imap_lemma." lemma" : "")
		\."\n ".(g:atp_imap_remark != "" ? g:atp_imap_leader_3.g:atp_imap_remark." remark               " : "").(g:atp_imap_corollary != "" ? g:atp_imap_leader_3.g:atp_imap_corollary." corollary" : "")
		\."\n ".(g:atp_imap_proof != "" ? g:atp_imap_leader_3.g:atp_imap_proof." proof                " : "").(g:atp_imap_example != "" ? g:atp_imap_leader_3.g:atp_imap_example." example" : "")
		\."\n ".(g:atp_imap_note != "" ? g:atp_imap_leader_3.g:atp_imap_note." note                 " : "")
		\."\n"
		\."\n ".(g:atp_imap_enumerate != "" ? g:atp_imap_leader_3.g:atp_imap_enumerate." enumerate            " : "").(g:atp_imap_itemize != "" ? g:atp_imap_leader_3.g:atp_imap_itemize." itemize" : "")
		\."\n ".(g:atp_imap_item != "" ? g:atp_imap_leader_3.g:atp_imap_item." \\item" : "")
		\."\n"
		\.(g:atp_imap_align != "" ? "\n ".g:atp_imap_leader_3.g:atp_imap_align." align                " : "").(g:atp_imap_equation != "" ? g:atp_imap_leader_3.g:atp_imap_equation." equation" : "")
		\.(g:atp_imap_gather != "" ? "\n ".g:atp_imap_leader_3.g:atp_imap_gather." gather               " : "").(g:atp_imap_split != "" ? g:atp_imap_leader_3.g:atp_imap_split." split" : "")
		\."\n"
		\."\n ".(g:atp_imap_flushleft != "" ? g:atp_imap_leader_3.g:atp_imap_flushleft." flushleft            " : "").(g:atp_imap_flushright != "" ? g:atp_imap_leader_3.g:atp_imap_flushright." flushright" : "")
		\."\n ".(g:atp_imap_center != "" ? g:atp_imap_leader_3.g:atp_imap_center." center" : "")
		\."\n"
		\.(g:atp_imap_tikzpicture != "" ? "\n ".g:atp_imap_leader_3.g:atp_imap_tikzpicture." tikzpicture          " : "").(g:atp_imap_tabular != "" ? g:atp_imap_leader_3.g:atp_imap_tabular." tabular" : "")
		\."\n"
		\."\n ".(g:atp_imap_frame != "" ? g:atp_imap_leader_3.g:atp_imap_frame." frame                " : "").(g:atp_imap_letter != "" ?  g:atp_imap_leader_3.g:atp_imap_letter." letter" : "" )
    echohl Title
    echo "ENVIRONMENT IMAPS" 
    echohl WarningMsg
    echo "<maplocalleader> has value g:atp_imap_leader_3"
    echohl Normal
    echo help_envimaps
endfunction

" {{{1 Help VMaps
function! atplib#helpfunctions#HelpVMaps() 

    if exists("g:no_plugin_maps") || exists("g:no_atp_maps")
	echomsg "[ATP:] ATP maps are turned off"
	return ''
    endif

    let l:atp_vmap_text_font_leader 	= ( exists("maplocalleader") && g:atp_vmap_text_font_leader 	== "<LocalLeader>" ? maplocalleader : g:atp_vmap_text_font_leader )
    let l:atp_vmap_environment_leader 	= ( exists("maplocalleader") && g:atp_vmap_environment_leader 	== "<LocalLeader>" ? maplocalleader : g:atp_vmap_environment_leader )
    let l:atp_vmap_bracket_leader 	= ( exists("maplocalleader") && g:atp_vmap_bracket_leader 	== "<LocalLeader>" ? maplocalleader : g:atp_vmap_bracket_leader )
    let l:atp_vmap_big_bracket_leader 	= ( exists("maplocalleader") && g:atp_vmap_big_bracket_leader 	=~ "<LocalLeader>" ? substitute(g:atp_vmap_big_bracket_leader, '<LocalLeader>', maplocalleader, '')  : g:atp_vmap_big_bracket_leader )

    let help_vmaps_1 =
	    \ " ".l:atp_vmap_text_font_leader."rm               \\textrm{}            \\mathrm{}"
	    \."\n ".l:atp_vmap_text_font_leader."em               \\emph{}              \\mathit{}"
	    \."\n ".l:atp_vmap_text_font_leader."it               \\textit{}            \\mathit{}"
	    \."\n ".l:atp_vmap_text_font_leader."sf               \\textsf{}            \\mathsf{}"
	    \."\n ".l:atp_vmap_text_font_leader."tt               \\texttt{}            \\mathtt{}"
	    \."\n ".l:atp_vmap_text_font_leader."bf               \\textbf{}            \\mathbf{}"
	    \."\n ".l:atp_vmap_text_font_leader."bb               \\textbf{}            \\mathbb{}"
	    \."\n ".l:atp_vmap_text_font_leader."bb               \\textbf{}            \\mathbb{}"
	    \."\n ".l:atp_vmap_text_font_leader."sl               \\textsl{}"
	    \."\n ".l:atp_vmap_text_font_leader."sc               \\textsc{}"
	    \."\n ".l:atp_vmap_text_font_leader."up               \\textup{}"
	    \."\n ".l:atp_vmap_text_font_leader."md               \\textmd{}"
	    \."\n ".l:atp_vmap_text_font_leader."un               \\underline{}         \\underline{}"
	    \."\n ".l:atp_vmap_text_font_leader."ov               \\overline{}          \\overline{}"
	    \."\n ".l:atp_vmap_text_font_leader."no               \\textnormal{}        \\mathnormal{}"
	    \."\n ".l:atp_vmap_text_font_leader."cal                                   \\mathcal{}"
    let help_vmaps_2 = 
	    \ " ".l:atp_vmap_environment_leader."C		   wrap in center environment"
	    \."\n ".l:atp_vmap_environment_leader."L		   wrap in flushleft environment"
	    \."\n ".l:atp_vmap_environment_leader."R		   wrap in flushright environment"
	    \."\n ".l:atp_vmap_environment_leader."E		   wrap in equation environment"
	    \."\n ".l:atp_vmap_environment_leader."A		   wrap in align environment"
    let help_vmaps_3 =
	    \ " ".l:atp_vmap_bracket_leader."(                (:)            ".l:atp_vmap_bracket_leader.")           (:)" 
	    \."\n ".l:atp_vmap_bracket_leader."[                [:]            ".l:atp_vmap_bracket_leader."]           [:]" 
	    \."\n ".l:atp_vmap_bracket_leader."{                {:}            ".l:atp_vmap_bracket_leader."}           {:}" 
	    \."\n ".l:atp_vmap_bracket_leader."\\{              \\{:\\}           ".l:atp_vmap_bracket_leader."\\}         \\{:\\}" 
	    \."\n m ".repeat(" ",len(l:atp_vmap_bracket_leader))."              \\(:\\)           M ".repeat(" ",len(l:atp_vmap_bracket_leader))."         \\[:\\]"
    let help_vmaps_4 =
	    \ " ".l:atp_vmap_big_bracket_leader."(          \\left(:\\right)      ".l:atp_vmap_big_bracket_leader.")     \\left(:\\right)" 
	    \."\n ".l:atp_vmap_big_bracket_leader."[          \\left[:\\right]      ".l:atp_vmap_big_bracket_leader."]     \\left[:\\right]" 
	    \."\n ".l:atp_vmap_big_bracket_leader."{          \\left{:\\right}      ".l:atp_vmap_big_bracket_leader."}     \\left{:\\right}" 
	    \."\n ".l:atp_vmap_big_bracket_leader."\\{        \\left\\{:\\right\\}     ".l:atp_vmap_big_bracket_leader."\\}   \\left\\{:\\right\\}" 
	    \."\n "
	    \."\n ".l:atp_vmap_text_font_leader."f ".repeat(" ",len(l:atp_vmap_big_bracket_leader))."        \\usefont{".g:atp_font_encoding."}{}{}{}\\selectfont" 

    echohl WarningMsg
    echo " <maplocalleader> has value g:atp_vmap_text_font_leader"
    echohl Title
    echo " KEYMAP            TEXT MODE            MATH MODE"
    echohl Normal
    echo help_vmaps_1
    echohl Title
    echo "MODE INDEPENDENT VMAPS:"
    echohl WarningMsg
    echo " <maplocalleader> has value g:atp_vmap_text_font_leader"
    echohl Normal
    echo help_vmaps_2
    echohl WarningMsg
    echo " <maplocalleader> has value g:atp_vmap_bracket_leader"
    echohl Normal
    echo help_vmaps_3
    echohl WarningMsg
    echo " <maplocalleader> has value g:atp_vmap_big_bracket_leader"
    echohl Normal
    echo help_vmaps_4
endfunction
" {{{1 Help IMaps
" function! atplib#helpfunctions#HelpIMaps()
" let tc_imap = maparg("<Tab>  ", 'i') =~# 'atplib#complete#TabCompletion' ? '<Tab>' : 
" 	    \ maparg("<F7>   ", 'i') =~# 'atplib#complete#TabCompletion' ? '<F7>' : ""
" let netc_imap = tc_imap == "<Tab>" ? "<S-Tab>" : tc_imap == "<F7>" ? "<S-F7>" : ""
"     let g:help_imaps = ''
" 	    \."\n <maplocalleader> has value g:atp_vmap_text_font_leader"
" 	    \."\n ".tc_imap."            "."Completion (expert mode)"
" 	    \."\n ".netc_imap."            "."Completion (non-expert mode)"
" endfunction
" silent call atplib#helpfunctions#HelpIMaps()
" command! -buffer HelpIMaps :echo atplib#helpfunctions#HelpIMaps()
" }}}1
" {{{1 MapSearch
function! atplib#helpfunctions#MapSearch(bang,rhs_pattern,...)
    let mode = ( a:0 >= 1 ? a:1 : '' )
    let more = &more
    setl nomore
    redir => maps
	exe "silent ".mode."map"
    redir end
    let &l:more = more
    let list = split(maps, "\n")
    let pure_rhs_list = map(copy(list), 'matchstr(v:val, ''.\s\+\S\+\s\+\zs.*'')')
    let rhs_list  = ( a:bang == "" ?  copy(pure_rhs_list) :
		\ map(copy(list), 'matchstr(v:val, ''.\s\+\zs\S\+\s\+.*'')') )
    if mode == 'i'
	let j=0
	for entry in g:atp_imap_greek_letters
		    \ +g:atp_imap_math_misc
		    \ +g:atp_imap_diacritics
		    \ +g:atp_imap_environments
		    \ +g:atp_imap_math
		    \ +g:atp_imap_fonts 
	    let entry_tab = substitute(entry[4], "\t", '<Tab>', 'g')
	    let entry_tab = substitute(entry_tab, "", '<C-R>', 'g')
	    if index(pure_rhs_list, entry_tab)	== -1 &&
			\ index(pure_rhs_list, "*".entry_tab) == -1 &&
			\ index(pure_rhs_list, "@".entry_tab) == -1 &&
			\ index(pure_rhs_list, "*@".entry_tab) == -1 
		" Debug:
		    let j+=1
		let space = join(map(range(max([12-len(entry[2].entry[3]),1])), "' '"), "")
		call add(list, 'i  '.entry[2].entry[3].space.entry_tab)
		if a:bang == ""
		    call add(rhs_list, entry_tab)
		else
		    call add(rhs_list, 'i  '.entry[2].entry[3].space.entry_tab)
		endif
	    endif
	endfor
    endif
    let i = 0
    let i_list = []
    for rhs in rhs_list
	if rhs =~? a:rhs_pattern
	    call add(i_list, i)
	endif
	let i+=1
    endfor

    let found_maps = []
    for i in i_list
	call add(found_maps, list[i])
    endfor
    if len(found_maps) > 0
	echo join(found_maps, "\n")
    else
	echohl WarningMsg
	echo "No matches found"
	echohl None
    endif
endfunction
" }}}1

" vim:fdm=marker:tw=85:ff=unix:noet:ts=8:sw=4:fdc=1
