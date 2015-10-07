" Set leader key to ,
let mapleader = "\<Space>"

" vim instead of vi settings
set nocompatible

" spaces instead of tabs
set expandtab
set smarttab
set shiftwidth=4
set tabstop=4

" Use C-style indentation
set autoindent

" Do not show startup message
set shortmess=atIO

" Dont write backup and swap files
set nobackup
set nowritebackup
set noswapfile

" Use the mouse to move the cursor
set mouse=a

" keep the selection when moving blocks in v-mode
" vnoremap < <gv
" vnoremap > >gv

" Search settings
set hlsearch
set incsearch
set ignorecase
set smartcase

" show current command, matching bracket and mode, line numbers
set showcmd
set noshowmatch
set number

" Long undo and command history
set undolevels=1000
set history=200

" Save undo history permanently
if has('persistent_undo')
    set undodir=~/.vimundo
    set undofile
endif

" hide buffers instead of closing
set hidden

" show a few lines below the current line
set scrolloff=7

" the same horizontally
set sidescrolloff=5

" allow backspace to work over everything
set backspace=indent,eol,start

" Use backspace in normal mode
nnoremap <bs> X

" do not wrap lines automatically
set nowrap

" Use softwrapping in text documents
autocmd FileType text,markdown,tex,html setlocal wrap linebreak
set breakindent
set showbreak=┊ 

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

" default encoding in UTF-8
filetype plugin indent on
set encoding=utf-8

" Syntax highlighting
set t_Co=256
syntax enable
colorscheme molokai
hi ColorColumn      ctermbg=232
hi Visual           ctermbg=237

" Visible whitespace with :set list
set listchars=tab:▸\ ,eol:¬

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
set wildignore+=*/dist/*,*.pdf,*/output/*,*/bower_components/*

" Use par to format text
" http://vimcasts.org/episodes/formatting-text-with-par/
set formatprg=par\ -w99

" Hightlight the 100th column
if exists("+colorcolumn")
    set colorcolumn=100
endif

" Decrease dead time after ESC key
set ttimeout
set ttimeoutlen=50

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

" Use '\' as ',' for going backwards through character finds (opposite of ';')
noremap \ ,

" LaTeX helpers
" Add a & to the first = in this line and append '\\' at the end
nmap <Leader>& ml^f=i&<ESC>A \\<ESC>`l
" Only append \\
nmap <Leader>e mlA\\<ESC>`l
" Change a ( .. ) part to \br{ .. }
nmap <Leader>b cs({i\bb<ESC>

" In addition to C-w: delete word around/after the cursor
imap <C-d> <C-o>daw
nmap <C-d> daw

" Use pointfree with 'gq' in haskell files
autocmd BufEnter *.hs set formatprg=xargs\ -0\ pointfree

" Duplicate a line / selection and comment out the first
nmap <Leader>c Ypkgccj
vmap <Leader>c gcgvyPgvgc

" Expand/Shrink visual selection
vmap v <Plug>(expand_region_expand)
vmap <C-v> <Plug>(expand_region_shrink)

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
