" vim instead of vi settings
set nocompatible

" spaces instead of tabs
set expandtab
set smarttab
set shiftwidth=4
set tabstop=4

" Use C-style indentation
set cindent

" Do not show startup message
set shortmess=aI

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

" using bash as standard shell
set shell=bash

" show current command, matching bracket and mode, line numbers
set showcmd
set showmatch
set noshowmode
set number
" set cmdheight=2

" Long undo and command history
set undolevels=1000
set history=200

" hide buffers instead of closing
set hidden

" show a few lines below the current line
set scrolloff=7

" allow backspace to work over everything
set backspace=indent,eol,start

" Use backspace in normal mode
nnoremap <bs> X

" do not wrap lines automatically
set nowrap

" Use Ctrl-q for quitting, Ctrl-s for saving
map <C-Q> :q<CR>
noremap <silent> <C-S>          :update<CR>
vnoremap <silent> <C-S>         <C-C>:update<CR>
inoremap <silent> <C-S>         <C-O>:update<CR>

" remap :W, :Q etc if you press the shift key for too long
cabbrev Q quit
cabbrev W write
cabbrev WQ wq
cabbrev Wq wq

" Vundle
filetype off  " required to load Vundle

set rtp+=~/.vim/bundle/vundle
call vundle#rc()

" Bundles
Bundle 'gmarik/vundle'
Bundle 'altercation/vim-colors-solarized'
Bundle 'tpope/vim-fugitive'
Bundle 'tpope/vim-commentary'
Bundle 'tpope/vim-surround'
Bundle 'scrooloose/syntastic'
Bundle 'scrooloose/nerdtree'
Bundle 'bling/vim-airline'
Bundle 'airblade/vim-gitgutter'
Bundle 'bronson/vim-trailing-whitespace'
Bundle 'groenewege/vim-less'
Bundle 'coot/atp_vim'
Bundle 'Valloric/YouCompleteMe'
Bundle 'plasticboy/vim-markdown'
Bundle 'terryma/vim-multiple-cursors'

" default encoding in UTF-8
filetype plugin indent on
set encoding=utf-8

" Syntax highlighting and solarized colorscheme
syntax enable
set background=dark
colorscheme solarized
set t_Co=256
let g:solarized_termcolors=256

set listchars=tab:▸\ ,eol:¬

" disable arrow keys :-)
noremap   <Up>     <NOP>
noremap   <Down>   <NOP>
noremap   <Left>   <NOP>
noremap   <Right>  <NOP>

" Set leader key to ,
let mapleader = ","

" Clear search highlight with ,/
nmap <silent> <Leader>/ :nohlsearch<CR>

" Autocompletion in command mode
set wildmenu
set wildmode=list:longest,full

" Syntastic
let g:syntastic_enable_highlighting=0
let g:syntastic_check_on_open=0
let g:syntastic_check_on_wq=0
let g:syntastic_enable_balloons=0
let g:syntastic_python_checkers=['flake8']

" Use par to format text
" http://vimcasts.org/episodes/formatting-text-with-par/
set formatprg=par

" Hightlight the 80th column
set colorcolumn=80

" airline
set laststatus=2
let g:airline_powerline_fonts=1

" Decrease dead time after ESC key
set ttimeout
set ttimeoutlen=50

" Automatic Latex Plugin
nmap <silent> <Leader>s :SyncTex!<CR>
nmap <silent> <Leader>l :Latexmk<CR>

" Call make
nmap <silent> <Leader>m :make<CR>

" Open NERDTree
nmap <Leader>n :NERDTreeToggle<CR>

" Vim Markdown
let g:vim_markdown_folding_disabled=1

" Swap the current word with the next word (which can be on a newline and
" punctuation is skipped):
nmap <silent> gw "_yiw:s/\(\%#\w\+\)\(\_W\+\)\(\w\+\)/\3\2\1/<CR><C-o>:noh<CR>

" Move to beginning/end of line while in insert mode
inoremap <C-a> <C-o>0
inoremap <C-e> <C-o>$
