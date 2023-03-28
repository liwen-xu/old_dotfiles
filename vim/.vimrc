call plug#begin('~/.vim/plugged')

Plug 'preservim/nerdtree'
Plug 'junegunn/seoul256.vim'
Plug 'junegunn/fzf', { 'do': './install --all' }
Plug 'junegunn/fzf.vim'
Plug 'junegunn/vim-easy-align'

call plug#end()

" Set 7 lines to the cursor
set so=7

" Basic Configuration
set encoding=utf-8
set nu rnu
set ruler
set cursorline
set mouse=a
set modeline
set backspace=indent,eol,start
set whichwrap+=<,>,[,]
set autoindent
set smartindent
set clipboard=unnamed
set autoread
set autochdir
set timeoutlen=1000 ttimeoutlen=10
set laststatus=2
set wildmenu

" No visual bells
set noerrorbells
set novisualbell
set t_vb=
set tm=500

" Turn backup off, since most stuff is in SVN, git anyway...
set nobackup
set nowb
set noswapfile

" Text, tab and indent related
set ts=2 sw=2 sts=2
set expandtab
set autoindent
set smartindent

" Moving around, tabs, windows and buffers
nnoremap <C-n> :bnext<CR>
nnoremap <C-p> :bprevious<CR>

" Colorscheme-related Configuration
set t_Co=256
let g:seoul256_background = 233
colo seoul256
hi clear CursorLine
hi CursorLine gui=underline cterm=underline
hi statusline ctermfg=15 ctermbg=None guifg=white
"hi Normal ctermbg=None guibg=black guifg=white
hi! Normal ctermbg=NONE guibg=NONE

set tags=tags;/

" Remap VIM 0 to first non-blank character
map 0 ^

" Macros
let maplocalleader = "\\"

noremap <silent><leader>; :nohlsearch<cr>
      \:syntax sync fromstart<cr>
      \<c-l>

map <Tab> <C-W>W:cd %:p:h<CR>:<CR>

map <F6> :set nu!<CR>
imap <F6> <ESC>:set nu!<CR>a

nnoremap <space> za
vnoremap <space> zf

vnoremap . :norm.<CR>

" EasyAlign
xmap ga <Plug>(EasyAlign)
nmap ga <Plug>(EasyAlign)
nmap gaa ga_

xmap <Leader>ga <Plug>(LiveEasyAlign)

filetype plugin on
filetype indent on
let vimrplugin_assign = 0

autocmd BufNewFile,BufRead *.ts set syntax=javascript

"strip trailing whitespace from certain files
autocmd BufWritePre *.conf :%s/\s\+$//e
autocmd BufWritePre *.py :%s/\s\+$//e
autocmd BufWritePre *.css :%s/\s\+$//e
autocmd BufWritePre *.html :%s/\s\+$//e

autocmd Filetype rmd inoremap ;m <Space>%>%<Space>
autocmd Filetype rmd nnoremap <Space>H :silent !brave &>/dev/null %<.html &<CR>:redraw!<CR>
autocmd FileType python map <buffer> <leader>x :w<CR>:exec '!python3' shellescape(@%, 1)<CR>
autocmd FileType python imap <buffer> <leader>x <esc>:w<CR>:exec '!python3' shellescape(@%, 1)<CR>
