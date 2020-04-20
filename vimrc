execute pathogen#infect()

call pathogen#helptags()

set nocompatible

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => VIM user interface
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
set ignorecase "Ignore case when searching
set smartcase
set incsearch "Incremental search"
set nolazyredraw "Don't redraw while executing macros"
set hlsearch
set cursorline
set ruler

set vb "no visual bell"
set t_vb= "no visual bell"

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Files, backups and undo
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Turn backup off, since most stuff is in SVN, git anyway...
set nobackup
set nowb
set noswapfile


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Text, tabs and indent related
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
set ts=4 sw=4
set expandtab
set autoindent
set smartindent
autocmd Filetype python setlocal ts=2 sw=2 sts=2 expandtab


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Moving around, tabs and buffers
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
nnoremap <C-n> :bnext<CR>
nnoremap <C-p> :bprevious<CR>


set modeline
set bs=2
set ls=2

set t_Co=256
"colorscheme koehler
let g:seoul256_background=233
colorscheme seoul256
set background=dark

set tags=tags;/

map <F6> :set nu!<CR>
imap <F6> <ESC>:set nu!<CR>a

nnoremap <space> za
vnoremap <space> zf

vnoremap . :norm.<CR>

noremap <silent><c-l> :nohlsearch<cr>
      \:syntax sync fromstart<cr>
      \<c-l>

let maplocalleader = "\\"

syntax on 
filetype plugin on 
filetype indent on 
let vimrplugin_assign = 0

autocmd BufNewFile,BufRead *.ts set syntax=javascript

set mouse=a
