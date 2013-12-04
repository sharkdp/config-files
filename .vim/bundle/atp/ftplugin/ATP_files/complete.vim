" Author: 	Marcin Szamotulski	
" Description: 	This file contains all the options and functions for completion.
" Note:		This file is a part of Automatic Tex Plugin for Vim.
" Language:	tex
" Last Change: Mon Feb 04, 2013 at 11:41:25  +0000

" Todo: biblatex.sty (recursive search for commands contains strange command \i}.

" TABCOMPLETION VARIABLES:
" {{{ TAB COMPLETION variables
" ( functions are in autoload/atplib.vim )

try 
let g:atp_completion_modes=[ 
	    \ 'commands', 		'labels', 		
	    \ 'tikz libraries', 	'environment names',
	    \ 'close environments' , 	'brackets',
	    \ 'input files',		'bibstyles',
	    \ 'bibitems', 		'bibfiles',
	    \ 'documentclass',		'tikzpicture commands',
	    \ 'tikzpicture',		'tikzpicture keywords',
	    \ 'package names',		'font encoding',
	    \ 'font family',		'font series',
	    \ 'font shape',		'algorithmic',
	    \ 'todonotes',
	    \ 'siunits',		'includegraphics',
	    \ 'color names',		'page styles',
	    \ 'page numberings',	'abbreviations',
	    \ 'package options', 	'documentclass options',
	    \ 'package options values', 'environment options',
	    \ 'command values',		'command optional values'
	    \ ]
lockvar 2 g:atp_completion_modes
catch /E741:/
endtry

if !exists("g:atp_completion_modes_normal_mode")
    unlockvar g:atp_completion_modes_normal_mode
    let g:atp_completion_modes_normal_mode=[ 
		\ 'close environments' , 'brackets', 'algorithmic' ]
    lockvar g:atp_completion_modes_normal_mode
endif

" By defualt all completion modes are ative.
if !exists("g:atp_completion_active_modes")
    let g:atp_completion_active_modes=deepcopy(g:atp_completion_modes)
"     call filter(g:atp_completion_active_modes, "v:val != 'tikzpicture keywords'")
endif
if !exists("g:atp_completion_active_modes_normal_mode")
    let g:atp_completion_active_modes_normal_mode=deepcopy(g:atp_completion_modes_normal_mode)
endif

if !exists("g:atp_sort_completion_list")
    let g:atp_sort_completion_list = 12
endif

" Note: to remove completions: 'inline_math' or 'displayed_math' one has to
" remove also: 'close_environments' /the function atplib#complete#CloseLastEnvironment can
" close math instead of an environment/.

" ToDo: make list of complition commands from the input files.
" ToDo: make complition fot \cite, and for \ref and \eqref commands.

" ToDo: there is second such a list! line 3150
	let g:atp_Environments=['array', 'abstract', 'center', 'corollary', 
		\ 'definition', 'document', 'description', 'displaymath',
		\ 'enumerate', 'example', 'eqnarray', 
		\ 'flushright', 'flushleft', 'figure', 'frame', 'frontmatter', 
		\ 'keywords', 
		\ 'itemize', 'lemma', 'list', 'letter', 'notation', 'minipage', 
		\ 'proof', 'proposition', 'picture', 'theorem', 'tikzpicture',  
		\ 'tabular', 'table', 'tabbing', 'thebibliography', 'titlepage',
		\ 'quotation', 'quote',
		\ 'remark', 'verbatim', 'verse' ]

	let g:atp_amsmath_environments=['align', 'alignat', 'equation', 'gather',
		\ 'multline', 'split', 'substack', 'flalign', 'smallmatrix', 'subeqations',
		\ 'pmatrix', 'bmatrix', 'Bmatrix', 'vmatrix' ]

	" if short name is no_short_name or '' then both means to do not put
	" anything, also if there is no key it will not get a short name.
	let g:atp_shortname_dict = { 'theorem' : 'thm', 
		    \ 'proposition' 	: 'prop', 	'definition' 	: 'defi',
		    \ 'lemma' 		: 'lem',	'array' 	: 'ar',
		    \ 'abstract' 	: 'no_short_name',
		    \ 'tikzpicture' 	: 'tikz',	'tabular' 	: 'table',
		    \ 'table' 		: 'table', 	'proof' 	: 'pr',
		    \ 'corollary' 	: 'cor',	'enumerate' 	: 'enum',
		    \ 'example' 	: 'ex',		'itemize' 	: 'it',
		    \ 'item'		: 'itm',	'algorithmic'	: 'alg',
		    \ 'algorithm'	: 'alg',	'note'		: 'note',
		    \ 'remark' 		: 'rem',	'notation' 	: 'not',
		    \ 'center' 		: '', 		'flushright' 	: '',
		    \ 'flushleft' 	: '', 		'quotation' 	: 'quot',
		    \ 'quot' 		: 'quot',	'tabbing' 	: '',
		    \ 'picture' 	: 'pic',	'minipage' 	: '',	
		    \ 'list' 		: 'list',	'figure' 	: 'fig',
		    \ 'verbatim' 	: 'verb', 	'verse' 	: 'verse',
		    \ 'thebibliography' : '',		'document' 	: 'no_short_name',
		    \ 'titlepave' 	: '', 		'align' 	: 'eq',
		    \ 'alignat' 	: 'eq',		'equation' 	: 'eq',
		    \ 'gather'  	: 'eq', 	'multline' 	: 'eq',
		    \ 'split'		: 'eq', 	'substack' 	: '',
		    \ 'flalign' 	: 'eq',		'displaymath' 	: 'eq',
		    \ 'part'		: 'prt',	'chapter' 	: 'chap',
		    \ 'section' 	: 'sec',	'subsection' 	: 'ssec',
		    \ 'subsubsection' 	: 'sssec', 	'paragraph' 	: 'par',
		    \ 'subparagraph' 	: 'spar',	'subequations'	: 'eq',
		    \ }

	" ToDo: Doc.
	" Usage: \label{l:shorn_env_name . g:atp_separator
	if !exists("g:atp_separator")
	    let g:atp_separator=':'
	endif
	if !exists("g:atp_no_separator")
	    let g:atp_no_separator = 0
	endif
" 	if !g:atp_no_separator
" 	    " This sets iskeyword vim option (see syntax/tex.vim file)
" 	    let g:tex_isk ="48-57,_,@,a-z,A-Z,192-255,".g:atp_separator
" 	endif
	if !exists("g:atp_no_short_names")
	    let g:atp_env_short_names = 1
	endif
	" the separator will not be put after the environments in this list:  
	" the empty string is on purpose: to not put separator when there is
	" no name.
	let g:atp_no_separator_list=['', 'titlepage']

" 	let g:atp_package_list=sort(['amsmath', 'amssymb', 'amsthm', 'amstex', 
" 	\ 'babel', 'booktabs', 'bookman', 'color', 'colorx', 'chancery', 'charter', 'courier',
" 	\ 'enumerate', 'euro', 'fancyhdr', 'fancyheadings', 'fontinst', 
" 	\ 'geometry', 'graphicx', 'graphics',
" 	\ 'hyperref', 'helvet', 'layout', 'longtable',
" 	\ 'newcent', 'nicefrac', 'ntheorem', 'palatino', 'stmaryrd', 'showkeys', 'tikz',
" 	\ 'qpalatin', 'qbookman', 'qcourier', 'qswiss', 'qtimes', 'verbatim', 'wasysym'])

	" the command \label is added at the end.
	let g:atp_Commands=["\\begin{", "\\end{", 
	\ "\\cite", "\\nocite{", "\\ref{", "\\pageref{", "\\eqref{", "\\item",
	\ "\\emph{", "\\documentclass{", "\\usepackage{",
	\ "\\section", "\\subsection", "\\subsubsection", "\\part", 
	\ "\\appendix", "\\subparagraph", "\\paragraph",
	\ "\\textbf{", "\\textsf{", "\\textrm{", "\\textit{", "\\texttt{", 
	\ "\\textsc{", "\\textsl{", "\\textup{", "\\textnormal", "\\textcolor{",
	\ "\\bfseries", "\\mdseries", "\\bigskip", "\\bibitem",
	\ "\\tiny",  "\\scriptsize", "\\footnotesize", "\\small",
	\ "\\noindent", "\\normalfont", "\normalsize", "\\normalsize", "\\normal", 
	\ "\hfil", "\\hfill", "\\hspace","\\hline", 
	\ "\\large", "\\Large", "\\LARGE", "\\huge", "\\HUGE",
	\ "\\underline{", 
	\ "\\usefont{", "\\fontsize{", "\\selectfont", "\\fontencoding{", "\\fontfamily{", "\\fontseries{", "\\fontshape{",
	\ "\\familydefault", 
	\ "\\rmdefault", "\\sfdefault", "\\ttdefault", "\\bfdefault", "\\mddefault", "\\itdefault",
	\ "\\sldefault", "\\scdefault", "\\updefault",  "\\renewcommand{", "\\newcommand{",
	\ "\\input", "\\include{", "\\includeonly{", "\\includegraphics{",  
	\ "\\savebox", "\\sbox", "\\usebox", "\\rule", "\\raisebox{", "\\rotatebox{",
	\ "\\parbox{", "\\mbox{", "\\makebox{", "\\framebox{", "\\fbox{",
	\ "\\medskip", "\\smallskip", "\\vskip", "\\vfil", "\\vfill", "\\vspace{", "\\vbox",
	\ "\\hrule", "\\hrulefill", "\\dotfill", "\\hbox",
	\ "\\thispagestyle{", "\\mathnormal", "\\markright{", "\\markleft{", "\\pagestyle{", "\\pagenumbering{",
	\ "\\addtocounter{",
	\ "\\author{", "\\address{", "\\date{", "\\thanks{", "\\title{",
	\ "\\maketitle",
	\ "\\marginpar", "\\indent", "\\par", "\\sloppy", "\\pagebreak", "\\nopagebreak",
	\ "\\newpage", "\\newline", "\\newtheorem{", "\\linebreak", "\\line", "\\linespread{",
	\ "\\hyphenation{", "\\fussy", "\\eject",
	\ "\\enlagrethispage{", "\\centerline{", "\\centering", "\\clearpage", "\\cleardoublepage",
	\ "\\encodingdefault", 
	\ "\\caption{", "\\chapter", 
	\ "\\opening{", "\\name{", "\\makelabels{", "\\location{", "\\closing{", 
	\ "\\signature{", "\\stopbreaks", "\\startbreaks",
	\ "\\newcounter{", "\\refstepcounter{", 
	\ "\\roman{", "\\Roman{", "\\stepcounter{", "\\setcounter{", 
	\ "\\usecounter{", "\\value{", 
	\ "\\newlength{", "\\setlength{", "\\addtolength{", "\\settodepth{", "\\nointerlineskip", 
	\ "\\addcontentsline{", "\\addtocontents",
	\ "\\settoheight{", "\\settowidth{", "\\stretch{",
	\ "\\seriesdefault", "\\shapedefault",
	\ "\\width", "\\height", "\\depth", "\\todo", "\\totalheight",
	\ "\\footnote{", "\\footnotemark", "\\footnotetetext", 
	\ "\\bibliography{", "\\bibliographystyle{", "\\baselineskip",
	\ "\\flushbottom", "\\onecolumn", "\\raggedbottom", "\\twocolumn",  
	\ "\\alph{", "\\Alph{", "\\arabic{", "\\fnsymbol{", "\\reversemarginpar",
	\ "\\exhyphenpenalty", "\\frontmatter", "\\mainmatter", "\\backmatter",
	\ "\\topmargin", "\\oddsidemargin", "\\evensidemargin", "\\headheight", "\\headsep", 
	\ "\\textwidth", "\\textheight", "\\marginparwidth", "\\marginparsep", "\\marginparpush", "\\footskip", "\\hoffset",
	\ "\\voffset", "\\parindent", "\\paperwidth", "\\paperheight", "\\columnsep", "\\columnseprule", 
	\ "\\theequation", "\\thepage", "\\usetikzlibrary{", "\\displaystyle", "\\textstyle", "\\scriptstyle", "\\scriptscriptstyle",
	\ "\\tableofcontents", "\\newfont{", "\\phantom{", "\\DeclareMathOperator",
	\ "\\DeclareRobustCommand", "\\DeclareFixedFont", "\\DeclareMathSymbol", 
	\ "\\DeclareTextFontCommand", "\\DeclareMathVersion", "\\DeclareSymbolFontAlphabet",
	\ "\\DeclareMathDelimiter", "\\DeclareMathAccent", "\\DeclareMathRadical",
	\ "\\SetMathAlphabet", "\\show", "\\CheckCommand", "\\mathnormal",
	\ "\\pounds", "\\magstep{", "\\hyperlink", "\\newenvironment{", 
	\ "\\renewenvironemt{", "\\DeclareFixedFont", "\\layout", "\\parskip",
	\ "\\brokenpenalty", "\\clubpenalty", "\\windowpenalty", "\\hyphenpenalty", "\\tolerance",
	\ "\\frenchspacing", "\\nonfrenchspacing", "\\binoppenalty", "\\exhyphenpenalty", 
	\ "\\displaywindowpenalty", "\\floatingpenalty", "\\interlinepenalty", "\\lastpenalty",
	\ "\\linepenalty", "\\outputpenalty", "\\penalty", "\\postdisplaypenalty", "\\predisplaypenalty", 
	\ "\\repenalty", "\\unpenalty", "\\everymath", "\\DeclareMathSizes{",
	\ "\\abovedisplayskip", "\\belowdisplayskip", "\\abovedisplayshortskip", "\\belowdisplayshortskip", ]

	let g:atp_TexCommands = [
		    \ '\begingroup', '\endgroup', '\bgroup', '\egroup', '\let', '\center',
		    \ '\flushleft', '\endflushleft', '\flushright', '\endflushright',
		    \ '\def', '\edef'
		    \ ]
	call extend(g:atp_Commands, g:atp_TexCommands)
	
	let g:atp_picture_commands=[ "\\put", "\\circle", "\\dashbox", "\\frame{", 
		    \"\\framebox(", "\\line(", "\\linethickness{",
		    \ "\\makebox(", "\\\multiput(", "\\oval(", "\\put", 
		    \ "\\shortstack", "\\vector(" ]
	" ToDo: end writting layout commands. 
	" ToDo: MAKE COMMANDS FOR PREAMBULE.

	let g:atp_math_commands=["\\begin{", "\\end{", "\\forall", "\\exists", "\\emptyset", "\\aleph", "\\partial",
	\ "\\nabla", "\\Box", "\\bot", "\\top", "\\flat", "\\natural",
	\ "\\mathbf{", "\\mathsf{", "\\mathrm{", "\\mathit{", "\\mathtt{", "\\mathcal{", 
	\ "\\mathop{", "\\mathversion", "\\limits", "\\text{", "\\leqslant", "\\leq", "\\geqslant", "\\geq",
	\ "\\gtrsim", "\\lesssim", "\\gtrless", "\\left", "\\right", 
	\ "\\rightarrow", "\\Rightarrow", "\\leftarrow", "\\Leftarrow", "\\infty", "\\iff", 
	\ "\\oplus", "\\otimes", "\\odot", "\\oint",
	\ "\\leftrightarrow", "\\Leftrightarrow", "\\downarrow", "\\Downarrow", 
	\ "\\overline{", "\\underline{", "\\overbrace{", "\\Uparrow",
	\ "\\Longrightarrow", "\\longrightarrow", "\\Longleftarrow", "\\longleftarrow",
	\ "\\overrightarrow{", "\\overleftarrow{", "\\underrightarrow{", "\\underleftarrow{",
	\ "\\uparrow", "\\nearrow", "\\searrow", "\\swarrow", "\\nwarrow", "\\mapsto", "\\longmapsto",
	\ "\\hookrightarrow", "\\hookleftarrow", "\\gets", "\\to", "\\backslash", 
	\ "\\sum", "\\bigsum", "\\cup", "\\bigcup", "\\cap", "\\bigcap", 
	\ "\\prod", "\\coprod", "\\bigvee", "\\bigwedge", "\\wedge",  
	\ "\\int", "\\bigoplus", "\\bigotimes", "\\bigodot", "\\times",  
	\ "\\smile",
	\ "\\dashv", "\\vdash", "\\vDash", "\\Vert", "\\Vdash", "\\models", "\\sim", "\\simeq", 
	\ "\\prec", "\\preceq", "\\preccurlyeq", "\\precapprox", "\\mid",
	\ "\\succ", "\\succeq", "\\succcurlyeq", "\\succapprox", "\\approx", 
	\ "\\ldots", "\\cdot", "\\cdots", "\\vdots", "\\ddots", "\\circ", 
	\ "\\thickapprox", "\\cong", "\\bullet",
	\ "\\lhd", "\\unlhd", "\\rhd", "\\unrhd", "\\dagger", "\\ddager", "\\dag", "\\ddag", 
	\ "\\varinjlim", "\\varprojlim",
	\ "\\vartriangleright", "\\vartriangleleft", 
	\ "\\triangle", "\\triangledown", "\\trianglerighteq", "\\trianglelefteq",
	\ "\\copyright", "\\textregistered", "\\pounds",
	\ "\\big", "\\Big", "\\Bigg", "\\huge", 
	\ "\\bigr", "\\Bigr", "\\biggr", "\\Biggr",
	\ "\\bigl", "\\Bigl", "\\biggl", "\\Biggl", 
	\ "\\hat", "\\grave", "\\bar", "\\acute", "\\mathring", "\\check", 
	\ "\\dots", "\\dot", "\\vec", "\\breve",
	\ "\\tilde", "\\widetilde" , "\\widehat", "\\ddot", 
	\ "\\sqrt{", "\\frac{", "\\binom{", "\\cline", "\\vline", "\\hline", "\\multicolumn{", 
	\ "\\nouppercase", "\\sqsubseteq", "\\sqsubset", "\\sqsupseteq", "\\sqsupset", 
	\ "\\square", "\\blacksquare",  
	\ "\\nexists", "\\varnothing", "\\Bbbk", "\\circledS", 
	\ "\\complement", "\\hslash", "\\hbar", 
	\ "\\eth", "\\rightrightarrows", "\\leftleftarrows", "\\rightleftarrows", "\\leftrighrarrows", 
	\ "\\downdownarrows", "\\upuparrows", "\\rightarrowtail", "\\leftarrowtail", 
	\ "\\rightharpoondown", "\\rightharpoonup", "\\rightleftharpoons", "\\leftharpoondown", "\\leftharpoonup",
	\ "\\twoheadrightarrow", "\\twoheadleftarrow", "\\rceil", "\\lceil", "\\rfloor", "\\lfloor", 
	\ "\\bigtriangledown", "\\bigtriangleup", "\\ominus", "\\bigcirc", "\\amalg", "\\asymp",
	\ "\\vert", "\\Arrowvert", "\\arrowvert", "\\bracevert", "\\lmoustache", "\\rmoustache",
	\ "\\setminus", "\\sqcup", "\\sqcap", "\\bowtie", "\\owns", "\\oslash",
	\ "\\lnot", "\\notin", "\\neq", "\\smile", "\\frown", "\\equiv", "\\perp",
	\ "\\quad", "\\qquad", "\\stackrel", "\\displaystyle", "\\textstyle", "\\scriptstyle", "\\scriptscriptstyle",
	\ "\\langle", "\\rangle", "\\Diamond", "\\lgroup", "\\rgroup", "\\propto", "\\Join", "\\div", 
	\ "\\land", "\\star", "\\uplus", "\\leadsto", "\\rbrack", "\\lbrack", "\\mho", 
	\ "\\diamondsuit", "\\heartsuit", "\\clubsuit", "\\spadesuit", "\\top", "\\ell", 
	\ "\\imath", "\\jmath", "\\wp", "\\Im", "\\Re", "\\prime", "\\ll", "\\gg", "\\Nabla", ]

	let g:atp_math_commands_PRE=[  
		    \ "\\diagdown", "\\diagup", 
		    \ "\\subset", "\\subseteq", 
		    \ "\\supset", "\\supseteq", "\\sharp", 
		    \ "\\underline{", "\\underbrace{",  ] " THEY ARE NOT REALLY AT THE BEGINING.

	let g:atp_greek_letters = ['\alpha', '\beta', '\chi', '\delta', '\epsilon', '\phi', '\gamma', '\eta', '\iota', '\kappa', '\lambda', '\mu', '\nu', '\theta', '\pi', '\rho', '\sigma', '\tau', '\upsilon', '\vartheta', '\xi', '\psi', '\zeta', '\Delta', '\Phi', '\Gamma', '\Lambda', '\Mu', '\Theta', '\Pi', '\Sigma', '\Tau', '\Upsilon', '\Omega', '\Psi']

	if !exists("g:atp_local_completion")
	    " if has("python") then fire LocalCommands on startup (BufEnter) if not
	    " when needed.
	    let g:atp_local_completion = ( has("python") ? 2 : 1 )
	endif


	let g:atp_math_commands_non_expert_mode=[ "\\leqq", "\\geqq", "\\succeqq", "\\preceqq", 
		    \ "\\subseteqq", "\\supseteqq", "\\gtrapprox", "\\lessapprox" ]
	 
	" requiers amssymb package:
	let g:atp_ams_negations=[ "\\nless", "\\ngtr", "\\lneq", "\\gneq", "\\nleq", "\\ngeq", "\\nleqslant", "\\ngeqslant", 
		    \ "\\nsim", "\\nconq", "\\nvdash", "\\nvDash", 
		    \ "\\nsubseteq", "\\nsupseteq", 
		    \ "\\varsubsetneq", "\\subsetneq", "\\varsupsetneq", "\\supsetneq", 
		    \ "\\ntriangleright", "\\ntriangleleft", "\\ntrianglerighteq", "\\ntrianglelefteq", 
		    \ "\\nrightarrow", "\\nleftarrow", "\\nRightarrow", "\\nLeftarrow", 
		    \ "\\nleftrightarrow", "\\nLeftrightarrow", "\\nsucc", "\\nprec", "\\npreceq", "\\nsucceq", 
		    \ "\\precneq", "\\succneq", "\\precnapprox", "\\ltimes", "\\rtimes" ]

	let g:atp_ams_negations_non_expert_mode=[ "\\lneqq", "\\ngeqq", "\\nleqq", "\\ngeqq", "\\nsubseteqq", 
		    \ "\\nsupseteqq", "\\subsetneqq", "\\supsetneqq", "\\nsucceqq", "\\precneqq", "\\succneqq" ] 

	" ToDo: add more amsmath commands.
	let g:atp_amsmath_commands=[ "\\boxed", "\\intertext{", "\\multiligngap", "\\shoveleft{", "\\shoveright{", "\\notag", "\\tag", 
		    \ "\\notag", "\\raistag{", "\\displaybreak", "\\allowdisplaybreaks", "\\numberwithin{",
		    \ "\\hdotsfor{" , "\\mspace{",
		    \ "\\negthinspace", "\\negmedspace", "\\negthickspace", "\\thinspace", "\\medspace", "\\thickspace",
		    \ "\\leftroot{", "\\uproot{", "\\overset{", "\\underset{", "\\substack{", "\\sideset{", 
		    \ "\\dfrac", "\\tfrac", "\\cfrac", "\\dbinom{", "\\tbinom{", "\\smash",
		    \ "\\lvert", "\\rvert", "\\lVert", "\\rVert", "\\DeclareMatchOperator{",
		    \ "\\arccos", "\\arcsin", "\\arg", "\\cos", "\\cosh", "\\cot", "\\coth", "\\csc", "\\deg", "\\det",
		    \ "\\dim", "\\exp", "\\gcd", "\\hom", "\\inf", "\\injlim", "\\ker", "\\lg", "\\lim", "\\liminf", "\\limsup",
		    \ "\\log", "\\min", "\\max", "\\Pr", "\\projlim", "\\sec", "\\sin", "\\sinh", "\\sup", "\\tan", "\\tanh",
		    \ "\\varlimsup", "\\varliminf", "\\varinjlim", "\\varprojlim", "\\mod", "\\bmod", "\\pmod", "\\pod", "\\sideset",
		    \ "\\iint", "\\iiint", "\\iiiint", "\\idotsint", "\\tag",
		    \ "\\varGamma", "\\varDelta", "\\varTheta", "\\varLambda", "\\varXi", "\\varPi", "\\varSigma", 
		    \ "\\varUpsilon", "\\varPhi", "\\varPsi", "\\varOmega" ]
	
	" ToDo: integrate in TabCompletion (amsfonts, euscript packages).
	let g:atp_amsfonts=[ "\\mathbb{", "\\mathfrak{", "\\mathscr{" ]

	" not yet supported: in TabCompletion:
	let g:atp_amsextra_commands=[ "\\sphat", "\\sptilde" ]
	let g:atp_fancyhdr_commands=["\\lfoot{", "\\rfoot{", "\\rhead{", "\\lhead{", 
		    \ "\\cfoot{", "\\chead{", "\\fancyhead{", "\\fancyfoot{",
		    \ "\\fancypagestyle{", "\\fancyhf{}", "\\headrulewidth", "\\footrulewidth",
		    \ "\\rightmark", "\\leftmark", "\\markboth{", 
		    \ "\\chaptermark", "\\sectionmark", "\\subsectionmark",
		    \ "\\fancyheadoffset", "\\fancyfootoffset", "\\fancyhfoffset"]


	" ToDo: remove tikzpicture from above and integrate the
	" tikz_envirnoments variable
	" \begin{pgfonlayer}{background} (complete the second argument as
	" well}
	"
	" Tikz command cuold be accitve only in tikzpicture and after \tikz
	" command! There is a way to do that.
	" 
	let g:atp_tikz_environments=['tikzpicture', 'scope', 'pgfonlayer', 'background' ]
	" ToDo: this should be completed as packages.
	let g:atp_tikz_libraries=sort(['arrows', 'automata', 'backgrounds', 'calc', 'calendar', 'chains', 'decorations', 
		    \ 'decorations.footprints', 'decorations.fractals', 
		    \ 'decorations.markings', 'decorations.pathmorphing', 
		    \ 'decorations.replacing', 'decorations.shapes', 
		    \ 'decorations.text', 'er', 'fadings', 'fit',
		    \ 'folding', 'matrix', 'mindmap', 'scopes', 
		    \ 'patterns', 'pteri', 'plothandlers', 'plotmarks', 
		    \ 'plcaments', 'pgflibrarypatterns', 'pgflibraryshapes',
		    \ 'pgflibraryplotmarks', 'positioning', 'replacements', 
		    \ 'shadows', 'shapes.arrows', 'shapes.callout', 'shapes.geometric', 
		    \ 'shapes.gates.logic.IEC', 'shapes.gates.logic.US', 'shapes.misc', 
		    \ 'shapes.multipart', 'shapes.symbols', 'topaths', 'through', 'trees' ])
	" tikz keywords = begin without '\'!
	" ToDo: add more keywords: done until page 145.
	" ToDo: put them in a correct order!!!
	" ToDo: completion for arguments in brackets [] for tikz commands.
	let g:atp_tikz_commands=[ "\\begin", "\\end", "\\matrix", "\\node", "\\shadedraw", 
		    \ "\\draw", "\\tikz", "\\tikzset",
		    \ "\\path", "\\filldraw", "\\fill", "\\clip", "\\drawclip", "\\foreach", "\\angle", "\\coordinate",
		    \ "\\useasboundingbox", "\\tikztostart", "\\tikztotarget", "\\tikztonodes", "\\tikzlastnode",
		    \ "\\pgfextra", "\\endpgfextra", "\\verb", "\\coordinate", 
		    \ "\\pattern", "\\shade", "\\shadedraw", "\\colorlet", "\\definecolor",
		    \ "\\pgfmatrixnextcell" ]
	let g:atp_tikz_keywords=[ 'draw', 'node', 'matrix', 'anchor=', 'top', 'bottom',  
		    \ 'west', 'east', 'north', 'south', 'at', 'thin', 'thick', 'semithick', 'rounded', 'corners',
		    \ 'controls', 'and', 'circle', 'step', 'grid', 'very', 'style', 'line', 'help',
		    \ 'color', 'arc', 'curve', 'scale', 'parabola', 'line', 'ellipse', 'bend', 'sin', 'rectangle', 'ultra', 
		    \ 'right', 'left', 'intersection', 'xshift=', 'yshift=', 'shift', 'near', 'start', 'above', 'below', 
		    \ 'end', 'sloped', 'coordinate', 'cap', 'shape=', 'label=', 'every', 
		    \ 'edge', 'point=', 'loop', 'join', 'distance', 'sharp', 'rotate=', 'blue', 'red', 'green', 'yellow', 
		    \ 'black', 'white', 'gray', 'name',
		    \ 'text', 'width=', 'inner', 'sep=', 'baseline', 'current', 'bounding', 'box', 
		    \ 'canvas', 'polar', 'radius', 'barycentric', 'angle=', 'opacity', 
		    \ 'solid', 'phase', 'loosly', 'dashed', 'dotted' , 'densly', 
		    \ 'latex', 'diamond', 'double', 'smooth', 'cycle', 'coordinates', 'distance',
		    \ 'even', 'odd', 'rule', 'pattern', 
		    \ 'stars', 'shading', 'ball', 'axis', 'middle', 'outer', 'transorm', 'fill',
		    \ 'fading', 'horizontal', 'vertical', 'light', 'dark', 'button', 'postaction', 'out',
		    \ 'circular', 'shadow', 'scope', 'borders', 'spreading', 'false', 'position', 'midway',
		    \ 'paint', 'from', 'to', 'solution=', 'global', 'delta' ]
	let g:atp_tikz_library_arrows_keywords	= [ 'reversed', 'stealth', 'triangle', 'open', 
		    \ 'hooks', 'round', 'fast', 'cap', 'butt'] 
	let g:atp_tikz_library_automata_keywords=[ 'state', 'accepting', 'initial', 'swap', 
		    \ 'loop', 'nodepart', 'lower', 'upper', 'output']  
	let g:atp_tikz_library_backgrounds_keywords=[ 'background', 'show', 'inner', 'frame', 'framed',
		    \ 'tight', 'loose', 'xsep', 'ysep']

	let g:atp_tikz_library_calendar_commands=[ '\calendar', '\tikzmonthtext' ]
	let g:atp_tikz_library_calendar_keywords=[ 'week list', 'dates', 'day', 'day list', 'month', 'year', 'execute', 
		    \ 'before', 'after', 'downward', 'upward' ]
	let g:atp_tikz_library_chain_commands=[ '\chainin' ]
	let g:atp_tikz_library_chain_keywords=[ 'chain', 'start chain', 'on chain', 'continue chain', 
		    \ 'start branch', 'branch', 'going', 'numbers', 'greek' ]
	let g:atp_tikz_library_decorations_commands=[ '\\arrowreversed' ]
	let g:atp_tikz_library_decorations_keywords=[ 'decorate', 'decoration', 'lineto', 'straight', 'zigzag',
		    \ 'saw', 'random steps', 'bent', 'aspect', 'bumps', 'coil', 'curveto', 'snake', 
		    \ 'border', 'brace', 'segment lenght', 'waves', 'ticks', 'expanding', 
		    \ 'crosses', 'triangles', 'dart', 'shape', 'width=', 'size', 'sep', 'shape backgrounds', 
		    \ 'between', 'along', 'path', 
		    \ 'Koch curve type 1', 'Koch curve type 1', 'Koch snowflake', 'Cantor set', 'footprints',
		    \ 'foot',  'stride lenght', 'foot', 'foot', 'foot of', 'gnome', 'human', 
		    \ 'bird', 'felis silvestris', 'evenly', 'spread', 'scaled', 'star', 'height=', 'text',
		    \ 'mark', 'reset', 'marks' ]
	let g:atp_tikz_library_er_keywords	= [ 'entity', 'relationship', 'attribute', 'key']
	let g:atp_tikz_library_fadings_keywords	= [ 'with', 'fuzzy', 'percent', 'ring' ]
	let g:atp_tikz_library_fit_keywords	= [ 'fit']
	let g:atp_tikz_library_matrix_keywords	= ['matrix', 'of', 'nodes', 'math', 'matrix of math nodes', 
		    \ 'matrix of nodes', 'delimiter', 
		    \ 'rmoustache', 'column sep=', 'row sep=' ] 
	let g:atp_tikz_library_mindmap_keywords	= [ 'mindmap', 'concept', 'large', 'huge', 'extra', 'root', 'level',
		    \ 'connection', 'bar', 'switch', 'annotation' ]
	let g:atp_tikz_library_folding_commands	= ["\\tikzfoldingdodecahedron"]
	let g:atp_tikz_library_folding_keywords	= ['face', 'cut', 'fold'] 
        let g:atp_tikz_library_patterns_keywords	= ['lines', 'fivepointed', 'sixpointed', 'bricks', 'checkerboard',
		    \ 'crosshatch', 'dots']
	let g:atp_tikz_library_petri_commands	= ["\\tokennumber" ]
        let g:atp_tikz_library_petri_keywords	= ['place', 'transition', 'pre', 'post', 'token', 'child', 'children', 
		    \ 'are', 'tokens', 'colored', 'structured' ]
	let g:atp_tikz_library_pgfplothandlers_commands	= ["\\pgfplothandlercurveto", "\\pgfsetplottension",
		    \ "\\pgfplothandlerclosedcurve", "\\pgfplothandlerxcomb", "\\pgfplothandlerycomb",
		    \ "\\pgfplothandlerpolarcomb", "\\pgfplothandlermark{", "\\pgfsetplotmarkpeat{", 
		    \ "\\pgfsetplotmarkphase", "\\pgfplothandlermarklisted{", "\\pgfuseplotmark", 
		    \ "\\pgfsetplotmarksize{", "\\pgfplotmarksize" ]
        let g:atp_tikz_library_plotmarks_keywords	= [ 'asterisk', 'star', 'oplus', 'oplus*', 'otimes', 'otimes*', 
		    \ 'square', 'square*', 'triangle', 'triangle*', 'diamond*', 'pentagon', 'pentagon*']
	let g:atp_tikz_library_shadow_keywords 	= ['general shadow', 'shadow', 'drop shadow', 'copy shadow', 'glow' ]
	let g:atp_tikz_library_shapes_keywords 	= ['shape', 'center', 'base', 'mid', 'trapezium', 'semicircle', 'chord', 'regular polygon', 'corner', 'star', 'isoscales triangle', 'border', 'stretches', 'kite', 'vertex', 'side', 'dart', 'tip', 'tail', 'circular', 'sector', 'cylinder', 'minimum', 'height=', 'width=', 'aspect', 'uses', 'custom', 'body', 'forbidden sign', 'cloud', 'puffs', 'ignores', 'starburst', 'random', 'signal', 'pointer', 'tape', 
		    \ 'single', 'arrow', 'head', 'extend', 'indent', 'after', 'before', 'arrow box', 'shaft', 
		    \ 'lower', 'upper', 'split', 'empty', 'part', 
		    \ 'callout', 'relative', 'absolute', 'shorten',
		    \ 'logic gate', 'gate', 'inputs', 'inverted', 'radius', 'use', 'US style', 'CDH style', 'nand', 'and', 'or', 'nor', 'xor', 'xnor', 'not', 'buffer', 'IEC symbol', 'symbol', 'align', 
		    \ 'cross out', 'strike out', 'length', 'chamfered rectangle' ]
	let g:atp_tikz_library_topath_keywords	= ['line to', 'curve to', 'out', 'in', 'relative', 'bend', 'looseness', 'min', 'max', 'control', 'loop']
	let g:atp_tikz_library_through_keywords	= ['through']
	let g:atp_tikz_library_trees_keywords	= ['grow', 'via', 'three', 'points', 'two', 'child', 'children', 'sibling', 'clockwise', 'counterclockwise', 'edge', 'parent', 'fork'] 

	let g:atp_TodoNotes_commands = [ '\todo{', '\listoftodos', '\missingfigure' ] 
	let g:atp_TodoNotes_todo_options = 
		    \ [ 'disable', 'color=', 'backgroundcolor=', 'linecolor=', 'bordercolor=', 
		    \ 'line', 'noline', 'inline', 'noinline', 'size=', 'list', 'nolist', 
		    \ 'caption=', 'prepend', 'noprepend', 'fancyline' ]   
	"Todo: PackageOptions are not yet done.  
	let g:atp_TodoNotes_packageOptions = [ 'textwidth', 'textsize', 
			    \ 'prependcaption', 'shadow', 'dvistyle', 'figwidth', 'obeyDraft' ]

	let g:atp_TodoNotes_missingfigure_options = [ 'figwidth=' ]
if !exists("g:atp_MathOpened")
    let g:atp_MathOpened = 1
endif
" augroup ATP_MathOpened
"     au!
"     au Syntax tex :let g:atp_MathOpened = 1
" augroup END

let g:atp_math_modes=[ ['\%([^\\]\|^\)\%(\\\|\\\{3}\)(','\%([^\\]\|^\)\%(\\\|\\\{3}\)\zs)'],
	    \ ['\%([^\\]\|^\)\%(\\\|\\\{3}\)\[','\%([^\\]\|^\)\%(\\\|\\\{3}\)\zs\]'],	
	    \ ['\\begin{align', '\\end{alig\zsn'], 	['\\begin{gather', '\\end{gathe\zsr'], 
	    \ ['\\begin{falign', '\\end{flagi\zsn'], 	['\\begin[multline', '\\end{multlin\zse'],
	    \ ['\\begin{equation', '\\end{equatio\zsn'],
	    \ ['\\begin{\%(display\)\?math', '\\end{\%(display\)\?mat\zsh'] ] 

" Completion variables for \pagestyle{} and \thispagestyle{} LaTeX commands.
let g:atp_pagestyles = [ 'plain', 'headings', 'empty', 'myheadings' ]
let g:atp_fancyhdr_pagestyles = [ 'fancy' ]

" Completion variable for \pagenumbering{} LaTeX command.
let g:atp_pagenumbering = [ 'arabic', 'roman', 'Roman', 'alph', 'Alph' ]

" SIunits
let g:atp_siuinits= [
 \ '\addprefix', '\addunit', '\ampere', '\amperemetresecond', '\amperepermetre', '\amperepermetrenp',
 \ '\amperepersquaremetre', '\amperepersquaremetrenp', '\angstrom', '\arad', '\arcminute', '\arcsecond',
 \ '\are', '\atomicmass', '\atto', '\attod', '\barn', '\bbar',
 \ '\becquerel', '\becquerelbase', '\bel', '\candela', '\candelapersquaremetre', '\candelapersquaremetrenp',
 \ '\celsius', '\Celsius', '\celsiusbase', '\centi', '\centid', '\coulomb',
 \ '\coulombbase', '\coulombpercubicmetre', '\coulombpercubicmetrenp', '\coulombperkilogram', '\coulombperkilogramnp', '\coulombpermol',
 \ '\coulombpermolnp', '\coulombpersquaremetre', '\coulombpersquaremetrenp', '\cubed', '\cubic', '\cubicmetre',
 \ '\cubicmetreperkilogram', '\cubicmetrepersecond', '\curie', '\dday', '\deca', '\decad',
 \ '\deci', '\decid', '\degree', '\degreecelsius', '\deka', '\dekad',
 \ '\derbecquerel', '\dercelsius', '\dercoulomb', '\derfarad', '\dergray', '\derhenry',
 \ '\derhertz', '\derjoule', '\derkatal', '\derlumen', '\derlux', '\dernewton',
 \ '\derohm', '\derpascal', '\derradian', '\dersiemens', '\dersievert', '\dersteradian',
 \ '\dertesla', '\dervolt', '\derwatt', '\derweber', '\electronvolt', '\exa',
 \ '\exad', '\farad', '\faradbase', '\faradpermetre', '\faradpermetrenp', '\femto',
 \ '\femtod', '\fourth', '\gal', '\giga', '\gigad', '\gram',
 \ '\graybase', '\graypersecond', '\graypersecondnp', '\hectare', '\hecto', '\hectod',
 \ '\henry', '\henrybase', '\henrypermetre', '\henrypermetrenp', '\hertz', '\hertzbase',
 \ '\hour', '\joule', '\joulebase', '\joulepercubicmetre', '\joulepercubicmetrenp', '\jouleperkelvin',
 \ '\jouleperkelvinnp', '\jouleperkilogram', '\jouleperkilogramkelvin', '\jouleperkilogramkelvinnp', '\jouleperkilogramnp', '\joulepermole',
 \ '\joulepermolekelvin', '\joulepermolekelvinnp', '\joulepermolenp', '\joulepersquaremetre', '\joulepersquaremetrenp', '\joulepertesla',
 \ '\jouleperteslanp', '\katal', '\katalbase', '\katalpercubicmetre', '\katalpercubicmetrenp', '\kelvin',
 \ '\kilo', '\kilod', '\kilogram', '\kilogrammetrepersecond', '\kilogrammetrepersecondnp', '\kilogrammetrepersquaresecond', '\kilogrammetrepersquaresecondnp', '\kilogrampercubicmetre', '\kilogrampercubicmetrecoulomb', '\kilogrampercubicmetrecoulombnp', '\kilogrampercubicmetrenp',
 \ '\kilogramperkilomole', '\kilogramperkilomolenp', '\kilogrampermetre', '\kilogrampermetrenp', '\kilogrampersecond', '\kilogrampersecondcubicmetre',
 \ '\kilogrampersecondcubicmetrenp', '\kilogrampersecondnp', '\kilogrampersquaremetre', '\kilogrampersquaremetrenp', '\kilogrampersquaremetresecond', '\kilogrampersquaremetresecondnp',
 \ '\kilogramsquaremetre', '\kilogramsquaremetrenp', '\kilogramsquaremetrepersecond', '\kilogramsquaremetrepersecondnp', '\kilowatthour', '\liter',
 \ '\litre', '\lumen', '\lumenbase', '\lux', '\luxbase', '\mega',
 \ '\megad', '\meter', '\metre', '\metrepersecond', '\metrepersecondnp', '\metrepersquaresecond',
 \ '\metrepersquaresecondnp', '\micro', '\microd', '\milli', '\millid', '\minute',
 \ '\mole', '\molepercubicmetre', '\molepercubicmetrenp', '\nano', '\nanod', '\neper',
 \ '\newton', '\newtonbase', '\newtonmetre', '\newtonpercubicmetre', '\newtonpercubicmetrenp', '\newtonperkilogram', '\newtonperkilogramnp', '\newtonpermetre', '\newtonpermetrenp', '\newtonpersquaremetre', '\newtonpersquaremetrenp', '\NoAMS', '\no@qsk', '\ohm', '\ohmbase', '\ohmmetre',
 \ '\one', '\paminute', '\pascal', '\pascalbase', '\pascalsecond', '\pasecond',
 \ '\per', '\period@active', '\persquaremetresecond', '\persquaremetresecondnp', '\peta', '\petad',
 \ '\pico', '\picod', '\power', '\@qsk', '\quantityskip', '\rad',
 \  '\radian', '\radianbase', '\radianpersecond', '\radianpersecondnp', '\radianpersquaresecond', '\radianpersquaresecondnp', '\reciprocal', '\rem', '\roentgen', '\rp', '\rpcubed',
 \ '\rpcubic', '\rpcubicmetreperkilogram', '\rpcubicmetrepersecond', '\rperminute', '\rpersecond', '\rpfourth',
 \ '\rpsquare', '\rpsquared', '\rpsquaremetreperkilogram', '\second', '\siemens', '\siemensbase',
 \ '\sievert', '\sievertbase', '\square', '\squared', '\squaremetre', '\squaremetrepercubicmetre',
 \ '\squaremetrepercubicmetrenp', '\squaremetrepercubicsecond', '\squaremetrepercubicsecondnp', '\squaremetreperkilogram', '\squaremetrepernewtonsecond', '\squaremetrepernewtonsecondnp',
 \ '\squaremetrepersecond', '\squaremetrepersecondnp', '\squaremetrepersquaresecond', '\squaremetrepersquaresecondnp', '\steradian', '\steradianbase',
 \ '\tera', '\terad', '\tesla', '\teslabase', '\ton', '\tonne',
 \ '\unit', '\unitskip', '\usk', '\volt', '\voltbase', '\voltpermetre',
 \ '\voltpermetrenp', '\watt', '\wattbase', '\wattpercubicmetre', '\wattpercubicmetrenp', '\wattperkilogram',
 \ '\wattperkilogramnp', '\wattpermetrekelvin', '\wattpermetrekelvinnp', '\wattpersquaremetre', '\wattpersquaremetrenp', '\wattpersquaremetresteradian',
 \ '\wattpersquaremetresteradiannp', '\weber', '\weberbase', '\yocto', '\yoctod', '\yotta',
 \ '\yottad', '\zepto', '\zeptod', '\zetta', '\zettad' ]
 " }}}

" Scan packge file:
let g:atp_package_dict={}
function! g:atp_package_dict.ScanPackage(package_name,...) dict "{{{1
    " Todo: add { if the command takes an argument {} but only if it doesn't have
    " arguments [].
    " Fails to find options in geometry.sty since there options are defined using:
    " \define@key{Gm}{option_name}... macro defined in keyval.sty.

if get(self, a:package_name, {}) == {} 
    let self[a:package_name]={}
endif
" a:1 = [ 'options', 'commands' ] (list of things to scan if
" a:1 = [ 'options!' ] then make scan even if the value exists.
let modes = ( !a:0 ? [ 'options', 'commands', 'environments' ] : a:1 )
" a:2 == 1 : recursive search (\RequirePackage, \input)
let recursive = ( a:0 < 2 ? 0 : a:1 )
let modes_dict = {'options' : 0, 'commands' : 0, 'environments': 0}
for mode in modes
    let m = matchstr(mode, '\w*\ze!\?')
    let modes_dict[m]= get(self[a:package_name], m, ['@']) == ['@'] || ( mode != m )
endfor
if modes_dict['options'] == 0 && modes_dict['commands'] == 0 && modes_dict['environments'] == 0
    return self
endif
if !has("python")
    return {'options' : []}
endif
python << EOF
import vim
import re
import subprocess
import os.path

package = vim.eval("a:package_name")

# Pattern to find declared options:
option_pat = re.compile('\\\\(?:KOMA@|X)?Declare(?:Void|Local|(?:Bi)?Bool(?:ean)?|String|Standard|Switch|Type|Unicode|Entry|Bibliography|Caption|Complementary|Quote)?Option(?:Beamer)?X?\*?(?:<\w+>)?\s*(?:%\s*\n\s)?{((?:\w|\d|-|_|\*)+)}|\\\\Declare(?:Exclusive|Local|Void)?Options\*?\s*{((?:\n|[^}])+)}')
# This adds \define@key{}{}[]{} command (keyval) but this might be used not only for package options:
# option_pat = re.compile('\\\\(?:KOMA@|X)?Declare(?:Void|Local|(?:Bi)?Bool(?:ean)?|String|Standard|Switch|Type|Unicode|Entry|Bibliography|Caption|Complementary|Quote)?Option(?:Beamer)?X?\*?(?:<\w+>)?\s*(?:%\s*\n\s)?{((?:\w|\d|-|_|\*)+)}|\\\\Declare(?:Exclusive|Local|Void)?Options\*?\s*{((?:\n|[^}])+)}|\\\\define@key\s*{[^}]*}\s*{\s*([^}]*)\s*}')

# for example geometry.sty uses the followin commands to set options:
# \def\Gm@setkeys{\setkeys{Gm}}%	THIS SETS THE Gm SET OF KEYS
# \def\Gm@processconfig{%
#   \let\Gm@origExecuteOptions\ExecuteOptions
#   \let\ExecuteOptions\Gm@setkeys%	AND HERE IT IS EXECUTED
#   \InputIfFileExists{geometry.cfg}{}{}
#   \let\ExecuteOptions\Gm@origExecuteOptions}%

# This pattern is not working with:
# \KOMA@DeclareStandardOption%
#   {oneside}{twoside=false}
# /usr/local/texlive/2011/texmf-dist/tex/latex/koma-script/scrbook.cls

# Pattern to find command name without the leading '\':
command_pat = re.compile(r'(?:^\s*\\e?def|\\(?:newcommand|Declare(?:Document|Uni|(?:Multi)?Cite|Page|Url|Robust|Text(?:Font|Composite)?|OldFont|)Command(?:Default)?\*?))\s*(?:{\\([^}]*)|\\([^#\[{]*))', re.MULTILINE)
# only accept \def and \edef statements at the begining of a line. This excludes internal variables (inside groups: {...}).

# How to work with this :
# /usr/local/texlive/2011/texmf-dist/tex/latex/biblatex/biblatex.sty
#\DeclareRangeCommands{%
#  \ \,\space\nobreakspace\addspace\addnbspace
#  \addthinspace\addnbthinspace\addlowpenspace
#  \addhighpenspace\addlpthinspace\addhpthinspace
#  \adddotspace\addabbrvspace\&\psq\psqq
#  \bibrangedash\bibdatedash\textendash\textemdash}
#\DeclarePageCommands{\pno\ppno}
#
# Another problem in babel.def:
# \ifx\@undefined\DeclareTextFontCommand
#    \DeclareRobustCommand{\textlatin}[1]{\leavevmode{\latintext #1}}
# puts \DeclareRobustCommand to defined commands.
#
# /usr/local/texlive/2011/texmf-dist/tex/latex/index/index.sty
# it is \RequirePackage by /usr/local/texlive/2011/texmf-dist/tex/latex/index/bibref.sty
# it uses \def to define commands.
environment_pat = re.compile(r'^\s*\\newenvironment\s*{\s*([^}]*)\s*}', re.MULTILINE)

def remove_duplicates(seq, idfun=None):
    # found at http://www.peterbe.com/plog/uniqifiers-benchmark
    # order preserving
    if idfun is None:
	def idfun(x): return x
    seen = {}
    result = []
    for item in seq:
	marker = idfun(item)
	if marker in seen: continue
	seen[marker] = 1
	result.append(item)
    return result

def Kpsewhich(package):
    kpsewhich = subprocess.Popen(['kpsewhich', package], stdout=subprocess.PIPE)
    kpsewhich.wait()
    if kpsewhich.returncode == 0:
        return os.path.abspath(re.match('(.*)\n', kpsewhich.stdout.read()).group(1))
    else:
        return ''


def ScanPackage(package, o=True, c=True, e=True):

    options = []
    commands = []
    environments = []

    package_file = Kpsewhich(package)
    # check the variable: @classoptionslist
    if package_file != '':
        vim.command("let path='%s'" % str(package_file))
        if package_file[-1] in ['\n', '\r']:
            package_file = package_file[:-1]
	try:
            with open(package_file, 'r') as fo:
		package_f  = fo.read()
        except IOError as err:
            vim.command('echom "[ATP:] (%r) error: [%s]"' % (package_file,err))
            package_f = ""
        if o:
            # We can cut the package_f variable at \ProcessOptions:
            o_match = re.match('((?:.|\n)*)\\\\ProcessOptions', package_f)
            # how to do that more efficiently (find the regexp and cut at its byte position)?
            if o_match:
                o_f = o_match.group(1)
            else:
                o_f = package_f
            matches = re.findall(option_pat, o_f)
            for match in matches:
                option_list = re.sub('\n|\s|%', '', ",".join(match)).split(",")
                option_list = [item for item in option_list if re.match('(?:\w|\d|-|_|\*)+$',item)]
                options+=option_list
        if c:
            vim.command("echomsg '[ATP]: processing commands from %s'" % package)
            matches = re.findall(command_pat, package_f)
            for match in matches:
                for m in match:
                    if (not '@' in m and not '\\' in m and
			not re.match('Declare\w*(?:Command|Option)', m) and m != ''):
                        commands.append(re.match('(\S*)', m).group(1))
	if e:
            vim.command("echomsg '[ATP]: processing environments from %s'" % package)
            matches = re.findall(environment_pat, package_f)
            for match in matches:
                environments.append(match)
    return [options, remove_duplicates(commands), remove_duplicates(environments)]

require_package_pat = re.compile(r'\\RequirePackage\s*{([^}]*)}')
def RequiredPackage(package):
    #scan package for input files
    package_file = Kpsewhich(package)
    with open(package_file, 'r') as fo:
        package_f = fo.read()
    matches = re.findall(require_package_pat, package_f)
    input_files = []
    for match in matches:
        m=match
        [ base, ext ] = os.path.splitext(m)
        if ext == '':
            m += '.sty'
        input_files.append(m)
    return input_files

# List of all commands: 
re_commands=[]
re_environments=[]
# dictionary { package_name : (commands, environments) }:
recursive_dict = {}
# do not scan files twice:
did_files=[]
def RecursiveSearch(package):
    # recursive search for options and commands

    global re_commands
    global recursive_dict
    global did_files
    i_files = RequiredPackage(Kpsewhich(package))
    did_files.append(package)
    re_commands_add, re_environments_add = ScanPackage(package, o=False, c=True, e=True)[1:]
    recursive_dict[package]=(remove_duplicates(re_commands_add),
                            remove_duplicates(re_environments_add))
    for c in re_commands_add:
	if not c in re_commands:
            re_commands.append(c)
    for e in re_environments_add:
        if not e in re_environments:
            re_environments.append(e)
    for p in i_files:
	if not p in did_files:
            RecursiveSearch(p)


if vim.eval("recursive") == '0':
    o = ( str(vim.eval("modes_dict['options']")) == '1' )
    c = ( str(vim.eval("modes_dict['commands']")) == '1' )
    e = ( str(vim.eval("modes_dict['environments']")) == '1')
    [options, commands, environments]=ScanPackage(package, o, c, e)
else:
    RecursiveSearch(package)
    import json
    vim.command("let recursive_dict="+json.dmup(recursive_dict))
    commands = re_commands
    environments = re_environments
    # print("re_commands="+str(re_commands))
    o = ( str(vim.eval("modes_dict['options']")) == '1' )
    if o:
        options=ScanPackage(package, o, c=False, e=False)[0]
    else:
        options=[]


vim.command("let options = "+str(options))
vim.command("let commands= "+str(commands))
vim.command("let environments= "+str(environments))
EOF
if exists('path')
    let self[a:package_name]['path'] = path
endif
if exists('options') && modes_dict['options']
    let self[a:package_name]['options']=options
endif
if exists('commands') && modes_dict['commands']
    let self[a:package_name]['commands']=map(commands, "'\\'.v:val")
endif
if exists('environments') && modes_dict['environments']
    let self[a:package_name]['environments']=environments
endif
if exists('recursive_dict')
    call map(recursive_dict, 'map(v:val, "''\\''.v:val")')
    for key in keys(recursive_dict)
	if get(self, key, {}) == {}
	    let self[key]={}
	endif
	let self[key]['commands']=recursive_dict[key]
    endfor
endif
return self
endfunction "}}}1

if exists('##CompleteDone')
    fun! ATPCompleteDone()
	if !exists('g:atp_completion_method')
	    return
	endif
	if g:atp_completion_method == 'package'
	    let package = matchstr(getline(line('.')), '[^,{]*$')
	    let package = matchstr(package, '\s*\zs.*\ze\s*')
	    if index(g:atp_LatexPackages, package) != -1 && index(g:atp_packages, package) == -1
		echom '[ATP:] '.package.' added to g:atp_packages.'
		call add(g:atp_packages, package)
	    endif
	endif
    endfun

    augroup ATP_CompeletDone
	au!
	au CompleteDone * call ATPCompleteDone()
    augroup END
endif

function! <SID>ReadPackageFiles() " {{{1
    " Read Package/Documentclass Files
    " This is run by an autocommand group ATP_Packages which is after ATP_LocalCommands
    " b:atp_LocalColors are used in some package files.
    let time=reltime()
    let package_files = split(globpath(&rtp, "ftplugin/ATP_files/packages/*"), "\n")
    let g:atp_packages = map(copy(package_files), 'fnamemodify(v:val, ":t:r")')
    for file in package_files
	" We cannot restrict here to not source some files - because the completion
	" variables might be needed later. I need to find another way of using this files
	" as additional scripts running syntax ... commands for example only if the
	" packages are defined.
	execute "source ".file
    endfor
    let g:source_time_package_files=reltimestr(reltime(time))
endfunction
call <SID>ReadPackageFiles()

" vim:fdm=marker:tw=85:ff=unix:noet:ts=8:sw=4:fdc=1
