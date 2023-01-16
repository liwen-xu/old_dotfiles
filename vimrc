call plug#begin('~/.vim/plugged')

Plug 'preservim/nerdtree'
Plug 'junegunn/seoul256.vim'
Plug 'junegunn/fzf', { 'do': './install --all' }
Plug 'junegunn/fzf.vim'
Plug 'junegunn/vim-easy-align'
Plug 'jalvesaq/Nvim-R', {'branch': 'stable'}
Plug 'vim-pandoc/vim-pandoc', {'for': 'rmd'}
Plug 'vim-pandoc/vim-pandoc-syntax', {'for': 'rmd'}

call plug#end()

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
set nu rnu 
set so=7
set clipboard=unnamedplus

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
"set ts=4 sw=4 
set ts=2 sw=2 sts=2
set expandtab
set autoindent
set smartindent

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Moving around, tabs and buffers
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
nnoremap <C-n> :bnext<CR>
nnoremap <C-p> :bprevious<CR>


set modeline
set bs=2
set ls=2

set t_Co=256
let g:seoul256_background = 233
let g:seoul256_light_background = 256
colo seoul256

hi clear CursorLine
hi CursorLine gui=underline cterm=underline
"hi statusline ctermfg=15 ctermbg=None guifg=white
hi Normal ctermbg=None guibg=black guifg=white

set tags=tags;/

map <F6> :set nu!<CR>
imap <F6> <ESC>:set nu!<CR>a

nnoremap <space> za
vnoremap <space> zf

vnoremap . :norm.<CR>

let maplocalleader = "\\"

noremap <silent><leader>; :nohlsearch<cr>
      \:syntax sync fromstart<cr>
      \<c-l>

map <Tab> <C-W>W:cd %:p:h<CR>:<CR>

" Start interactive EasyAlign in visual mode
xmap ga <Plug>(EasyAlign)

" Start interactive EasyAlign for a motion/text object
nmap ga <Plug>(EasyAlign)
nmap gaa ga_

xmap <Leader>ga <Plug>(LiveEasyAlign)

filetype plugin on 
filetype indent on 
let vimrplugin_assign = 0

" Nvim-R
let R_rconsole_height = 10
let R_openhtml = 0
let R_after_start = [':norm H']
let R_objbr_place = 'BOTTOM'
nmap <C-j> <Plug>RNextRChunk
nmap <C-k> <Plug>RPreviousRChunk
nmap <C-l> <Plug>RSendChunk
nmap <C-h> <Plug>RDSendLine
vmap <C-h> <Plug>RDSendSelection

let g:pandoc#modules#disabled = ["folding", "spell"]
let g:pandoc#syntax#conceal#use = 0

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
