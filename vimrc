syntax on
set number
set tabstop=2
set softtabstop=2
set shiftwidth=2
"set expandtab
set wildmenu
set lazyredraw
set showmatch
set incsearch
set hlsearch
set nowrap
set smarttab
set smartcase
set smartindent
set autoindent
set modeline
set ww=<,>,[,]

"colo darkblue

set visualbell
set noerrorbells

set nocompatible
filetype off

set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()

Plugin 'vim-airline/vim-airline'
Plugin 'vim-airline/vim-airline-themes'
Plugin 'airblade/vim-gitgutter'
Plugin 'editorconfig/editorconfig-vim'
Plugin 'itchyny/lightline.vim'
Plugin 'junegunn/fzf'
Plugin 'junegunn/fzf.vim'
Plugin 'mattn/emmet-vim'
Plugin 'scrooloose/nerdtree'
Plugin 'terryma/vim-multiple-cursors'
Plugin 'tpope/vim-eunuch'
Plugin 'tpope/vim-surround'
Plugin 'w0rp/ale'

call vundle#end()
filetype plugin indent on

let g:airline#extensions#tabline#formatter = 'unique_tail'
let g:airline_theme='angr'

nmap <C-o> :NERDTreeToggle<CR>
imap <C-o> <ESC> :NERDTreeToggle<CR>
let g:user_emmet_leader_key='<C-E>'

