" This file is a part of ATP.
" Written by Marcin Szamotulski
let g:atp_common_command_values={
	    \ '\\\%(refstepcounter\|addtocounter\|setcounter\|value\|[aA]lph\|arabic\|fnsymbol\|[rR]oman\)\s*{' : [ 'equation', 'part', 'chapter', 'section', 'subsection', 'subsubsection', 'paragraph', 'subparagraph', 'page', 'figure', 'table', 'footnote', 'mpfootnote', 'enumi', 'enumii', 'enumiii', 'enumiv' ],
	    \ '\\includeonly\s*{\%([^}]*,\)\=' : 'ATP_IncludeOnlyFiles'
	    \ }
function! ATP_IncludeOnlyFiles()
    let list =  filter(copy(b:ListOfFiles), "get(b:TypeDict, v:val, '') == 'input'")
    let present = map(split(matchstr(getline(line(".")), '\\includeonly\s*{\zs[^}]*\ze}'), ","), "fnamemodify(v:val, ':p')")
    return filter(list, "index(present,fnamemodify(v:val, ':p')) == -1") 
endfunction
