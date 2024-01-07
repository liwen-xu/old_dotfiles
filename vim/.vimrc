silent! if plug#begin('~/.vim/plugged')

Plug 'junegunn/seoul256.vim'
Plug 'junegunn/fzf', { 'do': './install --all' }
Plug 'junegunn/fzf.vim'
Plug 'junegunn/vim-easy-align'
Plug 'rust-lang/rust.vim'
"Plug 'github/copilot.vim'
Plug 'preservim/tagbar'
Plug 'tpope/vim-fugitive'
Plug 'dstein64/vim-startuptime'

if has('nvim')
  Plug 'neovim/nvim-lspconfig'
  Plug 'williamboman/nvim-lsp-installer'
  Plug 'nvim-tree/nvim-tree.lua'
  Plug 'nvim-tree/nvim-web-devicons'
  Plug 'folke/trouble.nvim'
  Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}
  Plug 'nvim-lua/plenary.nvim'
  Plug 'jose-elias-alvarez/null-ls.nvim'
  Plug 'MunifTanjim/prettier.nvim'
  "Plug 'nvim-lua/completion-nvim'
  Plug 'hrsh7th/cmp-nvim-lsp'
  Plug 'hrsh7th/cmp-buffer'
  Plug 'hrsh7th/cmp-path'
  Plug 'hrsh7th/cmp-cmdline'
  Plug 'hrsh7th/nvim-cmp'
  Plug 'L3MON4D3/LuaSnip'
  Plug 'saadparwaiz1/cmp_luasnip'
  Plug 'zbirenbaum/copilot.lua'
  Plug 'zbirenbaum/copilot-cmp'
  Plug 'lewis6991/gitsigns.nvim'
endif

call plug#end()
endif

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

  -- Use LspAttach autocommand to only map the following keys
  -- after the language server attaches to the current buffer
  vim.api.nvim_create_autocmd('LspAttach', {
    group = vim.api.nvim_create_augroup('UserLspConfig', {}),
    callback = function(ev)
      -- Enable completion triggered by <c-x><c-o>
      vim.bo[ev.buf].omnifunc = 'v:lua.vim.lsp.omnifunc'

      -- Buffer local mappings.
      -- See `:help vim.lsp.*` for documentation on any of the below functions
      local opts = { buffer = ev.buf }
      vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
      vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
      vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
      vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
      vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, opts)
      vim.keymap.set('n', '<space>wa', vim.lsp.buf.add_workspace_folder, opts)
      vim.keymap.set('n', '<space>wr', vim.lsp.buf.remove_workspace_folder, opts)
      vim.keymap.set('n', '<space>wl', function()
        print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
      end, opts)
      vim.keymap.set('n', '<space>D', vim.lsp.buf.type_definition, opts)
      vim.keymap.set('n', '<space>rn', vim.lsp.buf.rename, opts)
      vim.keymap.set({ 'n', 'v' }, '<space>ca', vim.lsp.buf.code_action, opts)
      vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
      vim.keymap.set('n', '<space>f', function()
        vim.lsp.buf.format { async = true }
      end, opts)
    end,
  })
  
  -- See `:help vim.diagnostic.*` for documentation on any of the below functions
  vim.keymap.set('n', '<space>e', vim.diagnostic.open_float)
  vim.keymap.set('n', '[d', vim.diagnostic.goto_prev)
  vim.keymap.set('n', ']d', vim.diagnostic.goto_next)
  vim.keymap.set('n', '<space>q', vim.diagnostic.setloclist)

end

local nvim_lsp = require("lspconfig")

local servers = { "clangd", "rust_analyzer", "ccls", "pyright", "tsserver", "eslint" }

require("nvim-lsp-installer").setup({
    ensure_installed = servers,
    automatic_installation = false,
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

nvim_lsp.tsserver.setup {
  on_attach = on_attach,
  filetypes = { "typescript", "typescriptreact", "typescript.tsx", "javascript" },
  cmd = { "typescript-language-server", "--stdio" }
}

--- npm i -g vscode-langservers-extracted
--- npm i -g typescript-language-server
nvim_lsp.eslint.setup({
  on_attach = function(client, bufnr)
    vim.api.nvim_create_autocmd("BufWritePre", {
      buffer = bufnr,
      command = "EslintFixAll",
    })
  end,
})

require'lspconfig'.eslint.setup{}

local prettier = require("prettier")

prettier.setup({
  bin = 'prettierd',
  filetypes = {
    "css",
    "graphql",
    "html",
    "javascript",
    "javascriptreact",
    "json",
    "less",
    "markdown",
    "scss",
    "typescript",
    "typescriptreact",
    "yaml",
  },
})

prettier.setup({
  cli_options = {
    arrow_parens = "always",
    bracket_spacing = true,
    bracket_same_line = false,
    embedded_language_formatting = "auto",
    end_of_line = "lf",
    html_whitespace_sensitivity = "css",
    -- jsx_bracket_same_line = false,
    jsx_single_quote = false,
    print_width = 80,
    prose_wrap = "preserve",
    quote_props = "as-needed",
    semi = true,
    single_attribute_per_line = false,
    single_quote = false,
    tab_width = 2,
    trailing_comma = "es6",
    use_tabs = false,
    vue_indent_script_and_style = false,
  },
})

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

  sources = {
    null_ls.builtins.diagnostics.eslint_d.with({
      diagnostics_format = '[eslint] #{m}\n(#{c})'
    }),
    null_ls.builtins.diagnostics.fish
  }

  return on_attach(client, bufnr)
  end,
  sources = {
    null_ls.builtins.formatting.trim_whitespace,
    null_ls.builtins.formatting.trim_newlines,
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

-- completion
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
      select = false,
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
    { name = "copilot" },
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

-- nvim-tree 
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1
vim.g.netrw_liststyle = 3

vim.opt.termguicolors = true

require("nvim-tree").setup({
  disable_netrw = true,
  update_focused_file = {
    enable = true,
  },
  diagnostics = {
    enable = true,
  },
  sort_by = "case_sensitive",
  view = {
    width = 50,
  },
  renderer = {
    group_empty = true,
    icons = {
      show = {
        folder = false,
        file = false,
        git = false,
        folder_arrow = false,
      }
    }
  },
  filters = {
    dotfiles = true,
  },
  actions = {
    open_file = {
      quit_on_open = true,
    },
  },
})

require('gitsigns').setup()

-- Copilot
vim.g.copilot_assume_mapped = true
require('copilot').setup({
  suggestion = {enabled = false},
  panel = {enabled = false},
})

require('copilot_cmp').setup()

EOF
endif

" Basic Configuration
set encoding=utf-8
set ffs=unix,dos,mac
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

" Colorscheme-related configuration
set t_Co=256
let g:seoul256_background = 233
colo seoul256

hi clear CursorLine
hi CursorLine gui=underline cterm=underline
"hi statusline ctermfg=15 ctermbg=None guifg=white
set statusline+=%{get(b:,'gitsigns_status','')}
"hi Normal ctermbg=None guibg=black guifg=white
hi! Normal ctermbg=NONE guibg=NONE

set tags=tags;/

" Remap VIM 0 to first non-blank character
map 0 ^

" Macros
let maplocalleader = "\\"

" make shifts keep selection
vnoremap < <gv
vnoremap > >gv

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

nnoremap <silent> <Leader>e :NvimTreeToggle<CR>
nnoremap <Leader>E :TagbarToggle<CR>

filetype plugin on
filetype indent on
let vimrplugin_assign = 0

autocmd BufNewFile,BufRead *.ts set syntax=javascript

autocmd BufEnter *.cs :setlocal tabstop=4 shiftwidth=4 expandtab

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
