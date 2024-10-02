" Set leader key to ,
let mapleader = "\<Space>"

" spaces instead of tabs
set expandtab
set shiftwidth=4
set tabstop=4

" Do not show startup message
set shortmess=atIO

" Use the mouse to move the cursor
set mouse=a

" Search settings
set ignorecase
set smartcase

" show current command, matching bracket and mode, line numbers
set noshowmatch
let g:loaded_matchparen=1
set number

" Save undo history permanently
if has('persistent_undo')
    set undodir=~/.vimundo
    set undofile
endif

" show a few lines below the current line
set scrolloff=7

" the same horizontally
set sidescrolloff=5

" Use backspace in normal mode
nnoremap <bs> X

" do not wrap lines automatically
set nowrap

" disable folding everywhere
set nofoldenable

" Use softwrapping in text documents
autocmd FileType text,markdown,tex,html setlocal wrap linebreak
if exists('+breakindent')
    set breakindent
endif

" Use Ctrl-q for quitting, Ctrl-s for saving
noremap <C-Q> :q<CR>
vnoremap <C-Q> <Esc>:q<CR>
inoremap <C-Q> <Esc>:q<CR>

noremap <silent> <C-S>          :write<CR>
vnoremap <silent> <C-S>         <Esc>:write<CR>
inoremap <silent> <C-S>         <Esc>:write<CR>

" Use Ctrl-b to close a buffer
noremap <C-B>   :bd<CR>
vnoremap <C-B>  <Esc>:bd<CR>
inoremap <C-B>  <Esc>:bd<CR>

" remap :W, :Q etc if you press the shift key for too long
cabbrev Q quit
cabbrev W write
cabbrev WQ wq
cabbrev Wq wq


" Plugins
call plug#begin(stdpath('data') . '/plugged')

" This setting must be set before ALE is loaded.
let g:ale_completion_enabled = 1

Plug 'tpope/vim-commentary'
Plug 'tpope/vim-surround'
Plug 'tpope/vim-unimpaired'
Plug 'tpope/vim-repeat'
Plug 'dense-analysis/ale'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'airblade/vim-gitgutter'
Plug 'bronson/vim-trailing-whitespace'
Plug 'terryma/vim-multiple-cursors'
Plug 'bronson/vim-visual-star-search'
Plug 'tommcdo/vim-exchange'
Plug 'wellle/targets.vim'
Plug 'AndrewRadev/sideways.vim'
Plug 'terryma/vim-expand-region'
Plug 'derekwyatt/vim-fswitch'
Plug 'neovim/nvim-lspconfig'

Plug 'sheerun/vim-polyglot'
Plug 'groenewege/vim-less'

Plug 'junegunn/fzf'
Plug 'junegunn/fzf.vim'

Plug 'rhysd/vim-clang-format'
Plug 'psf/black'

" Plug 'tomasr/molokai'
Plug 'joshdick/onedark.vim'

" UltiSnips
Plug 'SirVer/ultisnips'
Plug 'honza/vim-snippets'

call plug#end()


" Syntax highlighting
syntax on
colorscheme onedark

" disable arrow keys :-)
noremap   <Up>     <NOP>
noremap   <Down>   <NOP>
noremap   <Left>   <NOP>
noremap   <Right>  <NOP>

" Clear search highlight (and redraw screen) with C-l
nnoremap <silent> <C-l> :nohlsearch<CR><C-l>

" Autocompletion in command mode
set wildmenu
set wildmode=list:longest,full
set wildignore+=*/dist/*,*.pdf,*/output/*,*/bower_components/*,*/target/*,Cargo.lock

" Use par to format text
" http://vimcasts.org/episodes/formatting-text-with-par/
set formatprg=par\ -w99

" Call make
nmap <silent> <Leader>m :make<CR>

" Swap the current word with the next word (which can be on a newline and
" punctuation is skipped):
nmap <silent> gw "_yiw:s/\(\%#\w\+\)\(\_W\+\)\(\w\+\)/\3\2\1/<CR><C-o>:noh<CR>

" Move to beginning/end of line while in insert mode
inoremap <C-a> <C-o>0
inoremap <C-e> <C-o>$

" Go in and out of paste mode with F10
set pastetoggle=<F10>

" Remember last position when reopening files
set viminfo='10,\"100,:20,%,n~/.viminfo
if has("autocmd")
    au BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif
endif

" Do not insert comment leaders automatically
autocmd FileType * setlocal formatoptions-=c formatoptions-=r formatoptions-=o

" Bubble-move (inspired by http://vimcasts.org/episodes/bubbling-text/)
nmap <C-k> [e`]        " single lines
nmap <C-j> ]e`]
vmap <C-k> [e`[V`]     " visual mode
vmap <C-j> ]e`[V`]

" Switch off octal/hex number detection for <C-a>, <C-x>
set nrformats=

" In addition to C-w: delete word around/after the cursor
imap <C-d> <C-o>daw
nmap <C-d> daw

" Duplicate a line / selection and comment out the first
nmap <Leader>c Ypkgccj
vmap <Leader>c gcgvyPgvgc

" Typing gcc is too much
nmap <C-e> gcc
imap <C-e> <C-o>gcc
vmap <C-e> gc

" Copy and paste to system clipboard with <Leader>p and <Leader>y
vmap <Leader>y "+y
vmap <Leader>d "+d
nmap <Leader>p "+p
nmap <Leader>P "+P
vmap <Leader>p "+p
vmap <Leader>P "+P

" Gnuplot
autocmd BufNewFile,BufRead *.gp set filetype=gnuplot
autocmd FileType gnuplot set commentstring=#\ %s

" Ale
" let g:ale_statusline_format = ['⨉ %d', '⚠ %d', '⬥ ok']
let g:ale_python_flake8_options = '--max-line-length=100'
let g:ale_linters = {
\ 'markdown': [],
\ 'cpp': ['clang', 'clangcheck', 'clangtidy'],
\ 'rust': ['analyzer'],
\ 'python': ['mypy'],
\}
" \ 'rust': [],
let g:ale_fixers = {
\ 'rust': ['rustfmt', 'trim_whitespace', 'remove_trailing_lines']
\}
let g:ale_cpp_clang_options = '--std=c++11 -Wall -Iinclude -I/usr/include/eigen3/ -I/home/shark/Informatik/c++/dbg-macro -DDBG_MACRO_NO_WARNING=1'
let g:ale_cpp_clangtidy_options = '-Wall -std=c++11 -x c++ -Iinclude -I/usr/include/eigen3 -I/home/shark/Informatik/c++/dbg-macro -DDBG_MACRO_NO_WARNING=1 -extra-arg -Xanalyzer -extra-arg -analyzer-output=text'
let g:ale_cpp_clangcheck_options = '-extra-arg -Xanalyzer -extra-arg -analyzer-output=text -- -Wall -std=c++11 -x c++ -Iinclude -I/usr/include/eigen3 -I/home/shark/Informatik/c++/dbg-macro -DDBG_MACRO_NO_WARNING=1'

nmap <Leader>n :ALENext<CR>
nmap <Leader>g :ALEGoToDefinition<CR>

" airline
set laststatus=2
let g:airline_powerline_fonts=1
let g:airline_theme='onedark'
set noshowmode  " airline already shows it

" Synctex forward searching
" See http://tex.stackexchange.com/a/10374/42128
" Configure okular to call "vim --servername VIM --remote +'%l' '%f'"
" for backward searching (vim needs to run in server mode).
function! SynctexShow()
    let synctex = glob("*.synctex.gz", 1)
    if strlen(synctex) == 0
        let synctex = glob("dist/*.synctex.gz", 1)
        if strlen(synctex) == 0
            echo "No synctex file found."
            return 0
        end
    end

    let pdffile = substitute(synctex, "synctex.gz", "pdf", "")
    let execline = printf(":silent !okular --noraise --unique '%s\\#src:%d %s' > /dev/null 2> /dev/null &", shellescape(pdffile), line("."), shellescape(expand("%:p")))
    exec execline
    :redraw!
endfunction

" Vim Markdown
let g:vim_markdown_folding_disabled=1

" Faster TeX syntax highlighting (disables some highlighting features)
let g:tex_fast="M"

" Use english messages
language en_US.UTF-8

" Align with respect to = or : with <Leader>= and <Leader>:
nmap <Leader>= :Tabularize /=<CR>
vmap <Leader>= :Tabularize /=<CR>
nmap <Leader>: :Tabularize /:\zs<CR>
vmap <Leader>: :Tabularize /:\zs<CR>

" Ultisnips
let g:UltiSnipsExpandTrigger="<tab>"
let g:UltiSnipsJumpForwardTrigger="<tab>"
let g:UltiSnipsJumpBackwardTrigger="<s-tab>"

" Add quick mappings for sideways.vim that allow shifting of arguments
nmap <Leader>h :SidewaysLeft<CR>
nmap <Leader>l :SidewaysRight<CR>

" Use sideways.vim with Haskell
autocmd FileType haskell let b:sideways_definitions = [
      \   {
      \     'start':       '::\s*',
      \     'end':         '^$',
      \     'delimiter':   '^\s*->\s*',
      \     'skip':        '^\s',
      \     'brackets':    ['(', ')'],
      \   },
      \ ]

" GitGutter keymappings
nmap <Leader>j <Plug>(GitGutterNextHunk)
nmap <Leader>k <Plug>(GitGutterPrevHunk)
nmap <Leader>r <Plug>(GitGutterUndoHunk)
nmap <Leader>a <Plug>(GitGutterStageHunk)
nmap <Leader>v <Plug>(GitGutterPreviewHunk)

let g:tex_flavor='latex'

" Help in detecting the filetype of config files
au BufRead,BufNewFile bashrc.symlink set filetype=sh
au BufRead,BufNewFile alias.symlink set filetype=sh
au BufRead,BufNewFile shellrc.symlink set filetype=sh

" Jedi
let g:jedi#popup_on_dot = 0
let g:jedi#rename_command = "<leader>f"  " reFactor

" CartoCSS
autocmd BufNewFile,BufRead *.mss set filetype=less

" jshint
autocmd BufNewFile,BufRead .jshintrc set filetype=json

" LaTeX class files
autocmd BufNewFile,BufRead *.cls set filetype=tex

" Octave
autocmd FileType octave set commentstring=%\ %s

" SSH config
autocmd BufNewFile,BufRead .ssh/config set filetype=sshconfig

" Special indentation for some files
au FileType purescript setl sw=2
au FileType html setl sw=2
au FileType markdown setl sw=2
au FileType haskell setl sw=2
au FileType javascript setl sw=2
au FileType yaml setl sw=2
au FileType cpp setl sw=2

" Insert current date
map <Leader>i "=strftime("%b %d, %Y")<CR>p

" Switch between corresponding files
map <Leader>z :FSHere<CR>

autocmd! BufEnter *.purs let b:fswitchdst = 'js'
autocmd! BufEnter *.js   let b:fswitchdst = 'purs'

" Switch between more files
autocmd! BufEnter *.cpp let b:fswitchdst = 'h'   | let b:fswitchlocs = '../h'
autocmd! BufEnter *.h   let b:fswitchdst = 'cpp' | let b:fswitchlocs = '../src'

autocmd! BufEnter *.buildconf   let b:fswitchdst = 'rebuildconf' | let b:fswitchlocs = './'
autocmd! BufEnter *.rebuildconf let b:fswitchdst = 'buildconf'   | let b:fswitchlocs = './'

" Scons
map <Leader>s :!scons -D -j1<CR>

" Other ~/ip files
autocmd BufNewFile,BufRead SConscript,SConstruct set filetype=python
autocmd BufNewFile,BufRead *.buildconf,*.rebuildconf set filetype=python
autocmd BufNewFile,BufRead .reporter set filetype=python

" ctags
set tags=TAGS;/

" fzf
nnoremap <C-p> :FZF<cr>

" gitgutter update time [ms]
set updatetime=300

" Autoformat
nnoremap <Leader>b :Black<CR>

"Use 24-bit (true-color) mode in Vim/Neovim when outside tmux.
"If you're using tmux version 2.2 or later, you can remove the outermost $TMUX check and use tmux's 24-bit color support
"(see < http://sunaku.github.io/tmux-24bit-color.html#usage > for more information.)
if (empty($TMUX))
  if (has("nvim"))
    "For Neovim 0.1.3 and 0.1.4 < https://github.com/neovim/neovim/pull/2198 >
    let $NVIM_TUI_ENABLE_TRUE_COLOR=1
  endif
  "For Neovim > 0.1.5 and Vim > patch 7.4.1799 < https://github.com/vim/vim/commit/61be73bb0f965a895bfb064ea3e55476ac175162 >
  "Based on Vim patch 7.4.1770 (`guicolors` option) < https://github.com/vim/vim/commit/8a633e3427b47286869aa4b96f2bfc1fe65b25cd >
  " < https://github.com/neovim/neovim/wiki/Following-HEAD#20160511 >
  if (has("termguicolors"))
    set termguicolors
  endif
endif

au BufNewFile,BufRead *.nbt set filetype=numbat
