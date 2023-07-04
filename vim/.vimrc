call plug#begin('~/.vim/plugged')

Plug 'preservim/nerdtree'
Plug 'junegunn/seoul256.vim'
Plug 'junegunn/fzf', { 'do': './install --all' }
Plug 'junegunn/fzf.vim'
Plug 'junegunn/vim-easy-align'
Plug 'rust-lang/rust.vim'

Plug 'github/copilot.vim'

if has('nvim')
  Plug 'neovim/nvim-lspconfig'
  Plug 'williamboman/nvim-lsp-installer'
  
  " Trouble (lsp diagnostics)
  Plug 'nvim-tree/nvim-web-devicons'
  Plug 'folke/trouble.nvim'

  " Language parser
  Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}
  Plug 'nvim-lua/plenary.nvim'
  "Plug 'nvim-telescope/telescope.nvim'
  Plug 'jose-elias-alvarez/null-ls.nvim'

  " Autocompletion
  Plug 'nvim-lua/completion-nvim'
  Plug 'hrsh7th/cmp-nvim-lsp'
  Plug 'hrsh7th/cmp-buffer'
  Plug 'hrsh7th/cmp-path'
  Plug 'hrsh7th/cmp-cmdline'
  Plug 'hrsh7th/nvim-cmp'
  Plug 'L3MON4D3/LuaSnip'
  Plug 'saadparwaiz1/cmp_luasnip'
endif

call plug#end()

if has('nvim')

lua << EOF

local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require("cmp_nvim_lsp").default_capabilities(capabilities)

-- Use an on_attach function to only map the following keys
-- after the language server attaches to the current buffer
local on_attach = function(client, bufnr)
  local function buf_set_keymap(...) 
    vim.api.nvim_buf_set_keymap(bufnr, ...) 
  end
  local function buf_set_option(...) 
    vim.api.nvim_buf_set_option(bufnr, ...) 
  end

  -- Enable completion triggered by <c-x><c-o>
  vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')

  -- Mappings.
  local opts = { noremap=true, silent=true }

  -- See `:help vim.lsp.*` for documentation on any of the below functions
  vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gd', '<cmd>lua vim.lsp.buf.definition()<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', 'K', '<cmd>lua vim.lsp.buf.hover()<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', '<C-k>', '<cmd>lua vim.lsp.buf.signature_help()<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', '<space>wa', '<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', '<space>wr', '<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', '<space>wl', '<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', '<space>D', '<cmd>lua vim.lsp.buf.type_definition()<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', '<space>rn', '<cmd>lua vim.lsp.buf.rename()<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', '<space>ca', '<cmd>lua vim.lsp.buf.code_action()<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gr', '<cmd>lua vim.lsp.buf.references()<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', '<space>f', '<cmd>lua vim.lsp.buf.formatting()<CR>', opts)

  -- See `:help vim.diagnostic.*` for documentation on any of the below functions
  vim.api.nvim_buf_set_keymap(bufnr, 'n', '<space>e', '<cmd>lua vim.lsp.diagnostic.show_line_diagnostics()<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', '[d', '<cmd>lua vim.lsp.diagnostic.goto_prev()<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', ']d', '<cmd>lua vim.lsp.diagnostic.goto_next()<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', '<space>q', '<cmd>lua vim.lsp.diagnostic.setloclist()<CR>', opts)

end

local nvim_lsp = require("lspconfig")

local servers = { "clangd", "rust_analyzer", "ccls", "pyright", "tsserver" }

require("nvim-lsp-installer").setup({
    ensure_installed = servers,
    automatic_installation = false,
    ui = {
        icons = {
            server_installed = "✓",
            server_pending = "➜",
            server_uninstalled = "✗"
        }
    }
})

for _, lsp in ipairs(servers) do
  nvim_lsp[lsp].setup {
    on_attach = on_attach,
    capabilities = capabilities,
    flags = {
      allow_incremental_sync = false,
      -- This will be the default in neovim 0.7+
      debounce_text_changes = 150
    }
  }
end

local null_ls = require("null-ls")

null_ls.setup({
  on_attach = function(client, bufnr)
    -- format on save
    -- if client.resolved_capabilities.document_formatting then
    --     vim.cmd([[
    --     augroup LspFormatting
    --         autocmd! * <buffer>
    --         autocmd BufWritePre <buffer> silent noa w | lua vim.lsp.buf.formatting_sync(nil, 30000)
    --     augroup END
    --     ]])
    -- end

    return on_attach(client, bufnr)
  end,
  sources = {
    null_ls.builtins.formatting.trim_whitespace,
    null_ls.builtins.formatting.trim_newlines,
    null_ls.builtins.formatting.stylua,
    null_ls.builtins.diagnostics.eslint,
    null_ls.builtins.completion.spell,
  },
  debug = true
})

vim.lsp.handlers['window/showMessage'] = function(_, result, ctx)
  local client = vim.lsp.get_client_by_id(ctx.client_id)
  local lvl = ({
    'ERROR',
    'WARN',
    'INFO',
    'DEBUG',
  })[result.type]
end

-- Autocompletion
vim.opt.completeopt = { "menu", "menuone", "noselect" }

local luasnip = require("luasnip")
local cmp = require("cmp")
cmp.setup({
  snippet = {
    expand = function(args)
      luasnip.lsp_expand(args.body)
    end,
  },
  mapping = {
    ["<C-p>"] = cmp.mapping.select_prev_item(),
    ["<C-n>"] = cmp.mapping.select_next_item(),
    ["<C-d>"] = cmp.mapping.scroll_docs(-4),
    ["<C-f>"] = cmp.mapping.scroll_docs(4),
    ["<C-Space>"] = cmp.mapping.complete(),
    ["<C-e>"] = cmp.mapping.close(),
    ["<CR>"] = cmp.mapping.confirm({
      behavior = cmp.ConfirmBehavior.Replace,
    }),
    ["<Tab>"] = function(fallback)
      if cmp.visible() then
        cmp.select_next_item()
      elseif luasnip.expand_or_jumpable() then
        luasnip.expand_or_jump()
      else
        fallback()
      end
    end,
    ["<S-Tab>"] = function(fallback)
      if cmp.visible() then
        cmp.select_prev_item()
      elseif luasnip.jumpable(-1) then
        luasnip.jump(-1)
      else
        fallback()
      end
    end,
  },
  sources = {
    { name = "nvim_lsp" },
    { name = "luasnip" },
    { name = "buffer" },
  },
})

-- Tree-sitter
require'nvim-treesitter.configs'.setup {
  -- A list of parser names, or "all"
  ensure_installed = { "lua", "cpp", "c", "help", "vim" },

  -- Install parsers synchronously (only applied to `ensure_installed`)
  sync_install = false,

  highlight = {
    enable = true,
    -- Setting this to true will run `:h syntax` and tree-sitter at the same time.
    -- Set this to `true` if you depend on 'syntax' being enabled (like for indentation).
    -- Using this option may slow down your editor, and you may see some duplicate highlights.
    -- Instead of true it can also be a list of languages
    additional_vim_regex_highlighting = false,
  },
}

require("trouble").setup {
  -- your configuration comes here
  -- or leave it empty to use the default settings
  -- refer to the configuration section below
}

EOF
endif

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
set ignorecase

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

" Copilot
imap <silent> <C-j> <Plug>(copilot-next)
imap <silent> <C-k> <Plug>(copilot-previous)
imap <silent> <C-\> <Plug>(copilot-dismiss)

" EasyAlign
xmap ga <Plug>(EasyAlign)
nmap ga <Plug>(EasyAlign)
nmap gaa ga_

xmap <Leader>ga <Plug>(LiveEasyAlign)

" Trouble
nnoremap <silent> <leader>t :TroubleToggle<CR>

" fzf
nnoremap <silent> <Leader>f :Rg<CR>
command! -bang -nargs=* Rg call fzf#vim#grep("rg --column --line-number --no-heading --color=always --smart-case ".shellescape(<q-args>), 1, {'options': '--delimiter : --nth 4..'}, <bang>0)

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

" save with sudo using w!!
cmap w!! w !sudo tee > /dev/null %
