set ruler
set nocompatible
set expandtab
set confirm
set nobackup
set nowritebackup
set noswapfile

set clipboard=unnamed
set mouse=a

" move blocks around
vnoremap < <gv
vnoremap > >gv

"jedi-vi


set cindent
set shortmess=aI

set shiftwidth=4
set tabstop=4

set hlsearch
set incsearch
set ignorecase
set smartcase

set smartindent
set smarttab

set shell=bash

set showcmd
set showmatch
set showmode

set undolevels=1000
set hidden

set scrolloff=2
set number

set bs=indent,eol,start

set nowrap
set digraph

map + <C-W>+
map - <C-W>-

map <C-Q> :q<CR>
map <C-S> :w<CR>

cabbrev Q quit
cabbrev W write
cabbrev WQ wq
cabbrev Wq wq

filetype plugin on
set encoding=utf-8

syntax enable
set background=dark
colorscheme solarized
set t_Co=256
let g:solarized_termcolors=256

set listchars=tab:▸\ ,eol:¬

call togglebg#map("<F5>")

execute pathogen#infect()

" disable arrow keys
" inoremap  <Up>     <NOP>
" inoremap  <Down>   <NOP>
" inoremap  <Left>   <NOP>
" inoremap  <Right>  <NOP>
" noremap   <Up>     <NOP>
" noremap   <Down>   <NOP>
" noremap   <Left>   <NOP>
" noremap   <Right>  <NOP>

map <F5> :w<CR>:!make<CR><CR>
