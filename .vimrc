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
"set mouse=a

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
set showmode
set number
set cmdheight=2

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

" default encoding in UTF-8
filetype plugin on
set encoding=utf-8
"set digraph 

" Syntax highlighting and solarized colorscheme
syntax enable
set background=dark
colorscheme solarized
set t_Co=256
let g:solarized_termcolors=256

set listchars=tab:▸\ ,eol:¬

" Load plugins via pathogen
execute pathogen#infect()

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
