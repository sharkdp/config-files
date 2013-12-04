" Author:	Marcin Szmotulski
" Description:  This file contains abbreviations defined in ATP.
" Note:		This file is a part of Automatic Tex Plugin for Vim.
" Language:	tex
" Last Change:

if exists("g:atp_no_abbreviations") && g:atp_no_abbreviations == 1
    finish
endif

iabbrev <buffer> +- 	\pm
iabbrev <buffer> -+ 	\mp
iabbrev <buffer> +\| 	\dagger
iabbrev <buffer> ++ 	\ddagger

" LaTeX Environments
if empty(maparg(g:atp_iabbrev_leader . "document" . g:atp_iabbrev_leader, "i", 1))
    execute "iabbrev <buffer> ".g:atp_iabbrev_leader."document".g:atp_iabbrev_leader."	\begin{document}<CR>\end{document}<Esc>O"
endif
if empty(maparg(g:atp_iabbrev_leader . "description" . g:atp_iabbrev_leader, "i", 1))
    execute "iabbrev <buffer> ".g:atp_iabbrev_leader."description".g:atp_iabbrev_leader." \begin{description}<CR>\end{description}<Esc>O"
endif
if empty(maparg(g:atp_iabbrev_leader . "letter" . g:atp_iabbrev_leader, "i", 1))
    execute 'iabbrev <buffer> '.g:atp_iabbrev_leader.'letter'.g:atp_iabbrev_leader.'	\begin{letter}<CR>\end{letter}<Esc>O'
endif
if empty(maparg(g:atp_iabbrev_leader . "picture" . g:atp_iabbrev_leader, "i", 1))
    execute 'iabbrev <buffer> '.g:atp_iabbrev_leader.'picture'.g:atp_iabbrev_leader.'	\begin{picture}()()<CR>\end{picture}<Esc><Up>f(a'
endif
if empty(maparg(g:atp_iabbrev_leader . "list" . g:atp_iabbrev_leader, "i", 1))
    execute 'iabbrev <buffer> '.g:atp_iabbrev_leader.'list'.g:atp_iabbrev_leader.'	\begin{list}<CR>\end{list}<Esc>O'
endif
if empty(maparg(g:atp_iabbrev_leader . "minipage" . g:atp_iabbrev_leader, "i", 1))
    execute 'iabbrev <buffer> '.g:atp_iabbrev_leader.'minipage'.g:atp_iabbrev_leader.'	\begin{minipage}<CR>\end{minipage}<Esc><Up>A'
endif
if empty(maparg(g:atp_iabbrev_leader . "titlepage" . g:atp_iabbrev_leader, "i", 1))
    execute 'iabbrev <buffer> '.g:atp_iabbrev_leader.'titlepage'.g:atp_iabbrev_leader.'	\begin{titlepage}<CR>\end{titlepage}<Esc>O'
endif
if empty(maparg(g:atp_iabbrev_leader . "bibliography" . g:atp_iabbrev_leader, "i", 1))
    execute 'iabbrev <buffer> '.g:atp_iabbrev_leader.'bibliography'.g:atp_iabbrev_leader.' \begin{thebibliography}<CR>\end{thebibliography}<Esc><Up>A'
endif
if empty(maparg(g:atp_iabbrev_leader . "thebibliography" . g:atp_iabbrev_leader, "i", 1))
    execute 'iabbrev <buffer> '.g:atp_iabbrev_leader.'thebibliography'.g:atp_iabbrev_leader.' \begin{thebibliography}<CR>\end{thebibliography}<Esc><Up>A'
endif
if empty(maparg(g:atp_iabbrev_leader . "center" . g:atp_iabbrev_leader, "i", 1))
    execute 'iabbrev <buffer> '.g:atp_iabbrev_leader.'center'.g:atp_iabbrev_leader.'	\begin{center}<CR>\end{center}<Esc>O'
endif
if empty(maparg(g:atp_iabbrev_leader . "flushright" . g:atp_iabbrev_leader, "i", 1))
    execute 'iabbrev <buffer> '.g:atp_iabbrev_leader.'flushright'.g:atp_iabbrev_leader.'	\begin{flushright}<CR>\end{flushright}<Esc>O'
endif
if empty(maparg(g:atp_iabbrev_leader . "flushleft" . g:atp_iabbrev_leader, "i", 1))
    execute 'iabbrev <buffer> '.g:atp_iabbrev_leader.'flushleft'.g:atp_iabbrev_leader.'	\begin{flushleft}<CR>\end{flushleft}<Esc>O'
endif
if empty(maparg(g:atp_iabbrev_leader . "tikzpicture" . g:atp_iabbrev_leader, "i", 1))
    execute 'iabbrev <buffer> '.g:atp_iabbrev_leader.'tikzpicture'.g:atp_iabbrev_leader.'	\begin{tikzpicture}<CR>\end{tikzpicture}<Esc>O'
endif
if empty(maparg(g:atp_iabbrev_leader . "frame" . g:atp_iabbrev_leader, "i", 1))
    execute 'iabbrev <buffer> '.g:atp_iabbrev_leader.'frame'.g:atp_iabbrev_leader.'	\begin{frame}<CR>\end{frame}<Esc>O'
endif
if empty(maparg(g:atp_iabbrev_leader . "itemize" . g:atp_iabbrev_leader, "i", 1))
    execute 'iabbrev <buffer> '.g:atp_iabbrev_leader.'itemize'.g:atp_iabbrev_leader.'	\begin{itemize}<CR>\end{itemize}<Esc>O'
endif
if empty(maparg(g:atp_iabbrev_leader . "enumerate" . g:atp_iabbrev_leader, "i", 1))
    execute 'iabbrev <buffer> '.g:atp_iabbrev_leader.'enumerate'.g:atp_iabbrev_leader.'	\begin{enumerate}<CR>\end{enumerate}<Esc>O'
endif
if empty(maparg(g:atp_iabbrev_leader . "quote" . g:atp_iabbrev_leader, "i", 1))
    execute 'iabbrev <buffer> '.g:atp_iabbrev_leader.'quote'.g:atp_iabbrev_leader.'	\begin{quote}<CR>\end{quote}<Esc>O'
endif
if empty(maparg(g:atp_iabbrev_leader . "quotation" . g:atp_iabbrev_leader, "i", 1))
    execute 'iabbrev <buffer> '.g:atp_iabbrev_leader.'quotation'.g:atp_iabbrev_leader.'	\begin{quotation}<CR>\end{quotation}<Esc>O'
endif
if empty(maparg(g:atp_iabbrev_leader . "verse" . g:atp_iabbrev_leader, "i", 1))
    execute 'iabbrev <buffer> '.g:atp_iabbrev_leader.'verse'.g:atp_iabbrev_leader.'	\begin{verse}<CR>\end{verse}<Esc>O'
endif
if empty(maparg(g:atp_iabbrev_leader . "abstract" . g:atp_iabbrev_leader, "i", 1))
    execute 'iabbrev <buffer> '.g:atp_iabbrev_leader.'abstract'.g:atp_iabbrev_leader.'	\begin{abstract}<CR>\end{abstract}<Esc>O'
endif
if empty(maparg(g:atp_iabbrev_leader . "verbatim" . g:atp_iabbrev_leader, "i", 1))
    execute 'iabbrev <buffer> '.g:atp_iabbrev_leader.'verbatim'.g:atp_iabbrev_leader.'	\begin{verbatim}<CR>\end{verbatim}<Esc>O'
endif
if empty(maparg(g:atp_iabbrev_leader . "figure" . g:atp_iabbrev_leader, "i", 1))
    execute 'iabbrev <buffer> '.g:atp_iabbrev_leader.'figure'.g:atp_iabbrev_leader.'	\begin{figure}<CR>\end{figure}<Esc>O'
endif
if empty(maparg(g:atp_iabbrev_leader . "array" . g:atp_iabbrev_leader, "i", 1))
    execute 'iabbrev <buffer> '.g:atp_iabbrev_leader.'array'.g:atp_iabbrev_leader.'	\begin{array}<CR>\end{array}<Esc>O'
endif
if empty(maparg(g:atp_iabbrev_leader . "table" . g:atp_iabbrev_leader, "i", 1))
    execute 'iabbrev <buffer> '.g:atp_iabbrev_leader.'table'.g:atp_iabbrev_leader.'	\begin{table}<CR>\end{table}<Esc>O'
endif
if empty(maparg(g:atp_iabbrev_leader . "tabular" . g:atp_iabbrev_leader, "i", 1))
    execute 'iabbrev <buffer> '.g:atp_iabbrev_leader.'tabular'.g:atp_iabbrev_leader.'	\begin{tabular}<CR>\end{tabular}<Esc><Up>A'
endif

" AMS Stuff
if empty(maparg(g:atp_iabbrev_leader . "equation" . g:atp_iabbrev_leader, "i", 1))
    execute 'iabbrev <buffer> '.g:atp_iabbrev_leader.'equation'.g:atp_iabbrev_leader.'	\begin{equation}<CR>\end{equation}<Esc>O'
endif
if empty(maparg(g:atp_iabbrev_leader . "equation\\*" . g:atp_iabbrev_leader, "i", 1))
    execute 'iabbrev <buffer> '.g:atp_iabbrev_leader.'equation*'.g:atp_iabbrev_leader.'	\begin{equation*}<CR>\end{equation*}<Esc>O'
endif
if empty(maparg(g:atp_iabbrev_leader . "align" . g:atp_iabbrev_leader, "i", 1))
    execute 'iabbrev <buffer> '.g:atp_iabbrev_leader.'align'.g:atp_iabbrev_leader.'	\begin{align}<CR>\end{align}<Esc>O'
endif
if empty(maparg(g:atp_iabbrev_leader . "align\\*" . g:atp_iabbrev_leader, "i", 1))
    execute 'iabbrev <buffer> '.g:atp_iabbrev_leader.'align*'.g:atp_iabbrev_leader.'	\begin{align*}<CR>\end{align*}<Esc>O'
endif
if empty(maparg(g:atp_iabbrev_leader . "alignat" . g:atp_iabbrev_leader, "i", 1))
    execute 'iabbrev <buffer> '.g:atp_iabbrev_leader.'alignat'.g:atp_iabbrev_leader.'	\begin{alignat}<CR>\end{alignat}<Esc>O'
endif
if empty(maparg(g:atp_iabbrev_leader . "alignat\\*" . g:atp_iabbrev_leader, "i", 1))
    execute 'iabbrev <buffer> '.g:atp_iabbrev_leader.'alignat*'.g:atp_iabbrev_leader.'	\begin{alignat*}<CR>\end{alignat*}<Esc>O'
endif
if empty(maparg(g:atp_iabbrev_leader . "gather" . g:atp_iabbrev_leader, "i", 1))
    execute 'iabbrev <buffer> '.g:atp_iabbrev_leader.'gather'.g:atp_iabbrev_leader.'	\begin{gather}<CR>\end{gather}<Esc>O'
endif
if empty(maparg(g:atp_iabbrev_leader . "gather\\*" . g:atp_iabbrev_leader, "i", 1))
    execute 'iabbrev <buffer> '.g:atp_iabbrev_leader.'gather*'.g:atp_iabbrev_leader.'	\begin{gather*}<CR>\end{gather*}<Esc>O'
endif
if empty(maparg(g:atp_iabbrev_leader . "multline" . g:atp_iabbrev_leader, "i", 1))
    execute 'iabbrev <buffer> '.g:atp_iabbrev_leader.'multline'.g:atp_iabbrev_leader.'	\begin{multline}<CR>\end{multline}<Esc>O'
endif
if empty(maparg(g:atp_iabbrev_leader . "multline\\*" . g:atp_iabbrev_leader, "i", 1))
    execute 'iabbrev <buffer> '.g:atp_iabbrev_leader.'multline*'.g:atp_iabbrev_leader.'	\begin{multline*}<CR>\end{multline*}<Esc>O'
endif
if empty(maparg(g:atp_iabbrev_leader . "split" . g:atp_iabbrev_leader, "i", 1))
    execute 'iabbrev <buffer> '.g:atp_iabbrev_leader.'split'.g:atp_iabbrev_leader.'	\begin{split}<CR>\end{split}<Esc>O'
endif
if empty(maparg(g:atp_iabbrev_leader . "flalign" . g:atp_iabbrev_leader, "i", 1))
    execute 'iabbrev <buffer> '.g:atp_iabbrev_leader.'flalign'.g:atp_iabbrev_leader.'	\begin{flalign}<CR>\end{flalign}<Esc>O'
endif
if empty(maparg(g:atp_iabbrev_leader . "flalign\\*" . g:atp_iabbrev_leader, "i", 1))
    execute 'iabbrev <buffer> '.g:atp_iabbrev_leader.'flalign*'.g:atp_iabbrev_leader.'	\begin{flalign*}<CR>\end{flalign*}<Esc>O'
endif

if empty(maparg(g:atp_iabbrev_leader . "corollary" . g:atp_iabbrev_leader, "i", 1))
    execute 'iabbrev <buffer> '.g:atp_iabbrev_leader.'corollary'.g:atp_iabbrev_leader.'	\begin{corollary}<CR>\end{corollary}<Esc>O'
endif
if empty(maparg(g:atp_iabbrev_leader . "theorem" . g:atp_iabbrev_leader, "i", 1))
    execute 'iabbrev <buffer> '.g:atp_iabbrev_leader.'theorem'.g:atp_iabbrev_leader.'	\begin{theorem}<CR>\end{theorem}<Esc>O'
endif
if empty(maparg(g:atp_iabbrev_leader . "proposition" . g:atp_iabbrev_leader, "i", 1))
    execute 'iabbrev <buffer> '.g:atp_iabbrev_leader.'proposition'.g:atp_iabbrev_leader.'	\begin{proposition}<CR>\end{proposition}<Esc>O'
endif
if empty(maparg(g:atp_iabbrev_leader . "lemma" . g:atp_iabbrev_leader, "i", 1))
    execute 'iabbrev <buffer> '.g:atp_iabbrev_leader.'lemma'.g:atp_iabbrev_leader.'	\begin{lemma}<CR>\end{lemma}<Esc>O'
endif
if empty(maparg(g:atp_iabbrev_leader . "definition" . g:atp_iabbrev_leader, "i", 1))
    execute 'iabbrev <buffer> '.g:atp_iabbrev_leader.'definition'.g:atp_iabbrev_leader.'	\begin{definition}<CR>\end{definition}<Esc>O'
endif
if empty(maparg(g:atp_iabbrev_leader . "proof" . g:atp_iabbrev_leader, "i", 1))
    execute 'iabbrev <buffer> '.g:atp_iabbrev_leader.'proof'.g:atp_iabbrev_leader.'	\begin{proof}<CR>\end{proof}<Esc>O'
endif
if empty(maparg(g:atp_iabbrev_leader . "remark" . g:atp_iabbrev_leader, "i", 1))
    execute 'iabbrev <buffer> '.g:atp_iabbrev_leader.'remark'.g:atp_iabbrev_leader.'	\begin{remark}<CR>\end{remark}<Esc>O'
endif
if empty(maparg(g:atp_iabbrev_leader . "example" . g:atp_iabbrev_leader, "i", 1))
    execute 'iabbrev <buffer> '.g:atp_iabbrev_leader.'example'.g:atp_iabbrev_leader.'	\begin{example}<CR>\end{example}<Esc>O'
endif
