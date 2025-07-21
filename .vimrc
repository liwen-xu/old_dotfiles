silent! if plug#begin('~/.vim/plugged')

Plug 'junegunn/seoul256.vim'
if !has('nvim')
  Plug 'junegunn/fzf', { 'do': './install --all' }
  Plug 'junegunn/fzf.vim'
  Plug 'Valloric/YouCompleteMe', { 'do': './install.py --clang-completer --go-completer' }
  Plug 'tpope/vim-fugitive'
  Plug 'neoclide/coc.nvim', {'branch': 'release'}
  Plug 'tpope/vim-fugitive'
endif
Plug 'junegunn/vim-easy-align'
Plug 'rust-lang/rust.vim'
Plug 'preservim/tagbar'
"Plug 'vim-scripts/Zenburn'

if has('nvim')
  Plug 'neovim/nvim-lspconfig'
  Plug 'ibhagwan/fzf-lua'

  "trouble (lsp errors)
  Plug 'nvim-tree/nvim-web-devicons'
  Plug 'folke/trouble.nvim'
  "syntax tree
  Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}
  Plug 'nvim-treesitter/nvim-treesitter-context'
  Plug 'nvim-lua/plenary.nvim'
  "Plug 'jose-elias-alvarez/null-ls.nvim'
  "completion
  Plug 'hrsh7th/cmp-nvim-lsp'
  Plug 'hrsh7th/cmp-buffer'
  Plug 'hrsh7th/cmp-path'
  Plug 'hrsh7th/cmp-cmdline'
  Plug 'hrsh7th/nvim-cmp'
  Plug 'L3MON4D3/LuaSnip'
  Plug 'saadparwaiz1/cmp_luasnip'
  Plug 'nvim-tree/nvim-tree.lua'
  Plug 'zbirenbaum/copilot.lua'
  Plug 'zbirenbaum/copilot-cmp'
  Plug 'lewis6991/gitsigns.nvim'
endif

call plug#end()
endif

if has('nvim')

lua << EOF
-- osc52 clipboard
--vim.g.clipboard = {
--  name = 'osc52',
--  copy = {['+'] = copy, ['*'] = copy},
--  paste = {['+'] = 'tmux save-buffer -', ['*'] = 'tmux save-buffer -'}
--}
vim.g.clipboard = {
  name = 'OSC 52',
  copy = {
    ['+'] = require('vim.ui.clipboard.osc52').copy('+'),
    ['*'] = require('vim.ui.clipboard.osc52').copy('*'),
  },
  paste = {
    ['+'] = require('vim.ui.clipboard.osc52').paste('+'),
    ['*'] = require('vim.ui.clipboard.osc52').paste('*'),
  },
}

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

  -- Mappings
  -- See `:help vim.diagnostic.*` for documentation on any of the below functions
  local opts = { noremap=true, silent=true }
  vim.keymap.set('n', '<space>e', vim.diagnostic.open_float)
  vim.keymap.set('n', '[d', vim.diagnostic.goto_prev)
  vim.keymap.set('n', ']d', vim.diagnostic.goto_next)
  vim.keymap.set('n', '<space>q', vim.diagnostic.setloclist)
  vim.keymap.set('n', '[e', function()
    vim.diagnostic.goto_prev({ severity = vim.diagnostic.severity.ERROR })
  end, opts)
  vim.keymap.set('n', ']e', function()
      vim.diagnostic.goto_next({ severity = vim.diagnostic.severity.ERROR })
  end, opts)
  vim.keymap.set('n', '<space>q', vim.diagnostic.setloclist, opts)


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
  
end

local nvim_lsp = require("lspconfig")
local servers = { 
  "clangd", 
  "rust_analyzer", 
  "ccls",
  "pyright" 
}

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

--local null_ls = require("null-ls")
--
--null_ls.setup({
--  on_attach = function(client, bufnr)
--  -- format on save
--  -- if client.resolved_capabilities.document_formatting then
--  --     vim.cmd([[
--  --     augroup LspFormatting
--  --         autocmd! * <buffer>
--  --         autocmd BufWritePre <buffer> silent noa w | lua vim.lsp.buf.formatting_sync(nil, 30000)
--  --     augroup END
--  --     ]])
--  -- end
--
--  sources = {
--    null_ls.builtins.diagnostics.eslint_d.with({
--      diagnostics_format = '[eslint] #{m}\n(#{c})'
--    }),
--    null_ls.builtins.diagnostics.fish
--  }
--
--  return on_attach(client, bufnr)
--  end,
--  sources = {
--    null_ls.builtins.formatting.trim_whitespace,
--    null_ls.builtins.formatting.trim_newlines,
--    null_ls.builtins.diagnostics.eslint,
--    null_ls.builtins.completion.spell,
--  },
--  debug = true
--})

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
  ensure_installed = { "lua", "cpp", "c", "vim", "vimdoc", "rust", "python" },
  ignore_install = { "help" },

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
  indent = {
    enable = true,
  },
}

require'treesitter-context'.setup{
  enable = true, -- Enable this plugin (Can be enabled/disabled later via commands)
  max_lines = 1, -- How many lines the window should span. Values <= 0 mean no limit.
  min_window_height = 0, -- Minimum editor window height to enable context. Values <= 0 mean no limit.
  line_numbers = true,
  multiline_threshold = 20, -- Maximum number of lines to show for a single context
  trim_scope = 'outer', -- Which context lines to discard if `max_lines` is exceeded. Choices: 'inner', 'outer'
  mode = 'cursor',  -- Line used to calculate context. Choices: 'cursor', 'topline'
  -- Separator between context and content. Should be a single character string, like '-'.
  -- When separator is set, the context will only show up when there are at least 2 lines above cursorline.
  separator = nil,
  zindex = 20, -- The Z-index of the context window
  on_attach = nil, -- (fun(buf: integer): boolean) return false to disable attaching
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

require('gitsigns').setup{
  on_attach = function(bufnr)
    local gitsigns = require('gitsigns')

    local function map(mode, l, r, opts)
      opts = opts or {}
      opts.buffer = bufnr
      vim.keymap.set(mode, l, r, opts)
    end

    -- Navigation
    map('n', ']c', function()
      if vim.wo.diff then
        vim.cmd.normal({']c', bang = true})
      else
        gitsigns.nav_hunk('next')
      end
    end)

    map('n', '[c', function()
      if vim.wo.diff then
        vim.cmd.normal({'[c', bang = true})
      else
        gitsigns.nav_hunk('prev')
      end
    end)

    -- Actions
    map('n', '<leader>hs', gitsigns.stage_hunk)
    map('n', '<leader>hr', gitsigns.reset_hunk)
    map('v', '<leader>hs', function() gitsigns.stage_hunk {vim.fn.line('.'), vim.fn.line('v')} end)
    map('v', '<leader>hr', function() gitsigns.reset_hunk {vim.fn.line('.'), vim.fn.line('v')} end)
    map('n', '<leader>hS', gitsigns.stage_buffer)
    map('n', '<leader>hu', gitsigns.undo_stage_hunk)
    map('n', '<leader>hR', gitsigns.reset_buffer)
    map('n', '<leader>hp', gitsigns.preview_hunk)
    map('n', '<leader>hb', function() gitsigns.blame_line{full=true} end)
    map('n', '<leader>tb', gitsigns.toggle_current_line_blame)
    map('n', '<leader>hd', gitsigns.diffthis)
    map('n', '<leader>hD', function() gitsigns.diffthis('~') end)
    map('n', '<leader>td', gitsigns.toggle_deleted)

    -- Toggles
    map('n', '<leader>tb', gitsigns.toggle_current_line_blame)
    map('n', '<leader>tw', gitsigns.toggle_word_diff)

    -- Text object
    map({'o', 'x'}, 'ih', ':<C-U>Gitsigns select_hunk<CR>')
  end
}

function _G.encoding_head()
  local fenc = vim.bo.fenc
  return (fenc ~= '' and fenc:sub(1,1):upper()) or '-'
end

function _G.file_flags()
  local ro = vim.bo.readonly
  local mod = vim.bo.modified
  if ro and mod then return '%*'
  elseif mod then return '**'
  elseif ro then return '%%'
  else return '--'
  end
end

function _G.status_diagnostic()
  local info = vim.diagnostic.get(0, { severity = { min = vim.diagnostic.severity.HINT } }) or {}
  if vim.tbl_isempty(info) then return '' end
  local msgs = {}
  if info.error and info.error > 0 then
    table.insert(msgs, 'E' .. info.error)
  end
  if info.warning and info.warning > 0 then
    table.insert(msgs, 'W' .. info.warning)
  end
  return table.concat(msgs, ' ') .. ' ' .. (vim.lsp.status or '')
end

function _G.gitsigns_status()
  local gs = package.loaded.gitsigns
  if not gs then return '' end

  local status = vim.b.gitsigns_status or ''
  local head = vim.b.gitsigns_head or ''
  local ft = vim.bo.filetype or ''
  local branch_symbol = '⎇ '

  local components = { ft }

  if head ~= '' then
    table.insert(components, branch_symbol)
    table.insert(components, head)
  end

  if status ~= '' then
    table.insert(components, status)
  end

  return '(' .. table.concat(components, ' ') .. ')'
end

"vim.opt.statusline = table.concat({
"  ' %{v:lua.encoding_head()}',
"  ':',
"  '%{v:lua.file_flags()}',
"  ' %f',
"  ' %{v:lua.gitsigns_status()}',
"  '%=',
"  ' %P',
"  ' (%l,%c)',
"  '%{v:lua.status_diagnostic()} ',
"}, '')

require('fzf-lua').setup({'fzf-vim'})
vim.keymap.set({ "n" }, '<Leader>f', 
  function()
    require("fzf-lua").complete_file({
      cmd = "rg --files",
      winopts = { preview = { hidden = true } }
    })
  end, { silent = true })

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
set nu "rnu
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
"set autochdir
set timeoutlen=1000 ttimeoutlen=10
set laststatus=2
set wildmenu
set ignorecase
set termguicolors
if has('nvim')
  set signcolumn=yes:1
end

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
"set smartindent

" Moving around, tabs, windows and buffers
nnoremap <C-n> :bnext<CR>
nnoremap <C-p> :bprevious<CR>

" Colorscheme-related configuration
set t_Co=256
let g:seoul256_background = 233
silent! colo seoul256

"colo zenburn

hi clear CursorLine
hi CursorLine gui=underline cterm=underline

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
let g:rg_command = '
  \ rg --column --line-number --no-heading --fixed-strings --ignore-case --no-ignore --hidden --follow --color "always"
  \ -g "*.{js,json,php,md,styl,jade,html,config,py,cpp,c,go,hs,rb,conf}"
  \ -g "!*.{min.js,swp,o,zip}" 
  \ -g "!{.git,node_modules,vendor}/*" '

"command! -bang -nargs=* Rg call fzf#vim#grep("rg --column --line-number --no-heading --color=always --smart-case ".shellescape(<q-args>), 1, {'options': '--delimiter : --nth 4..'}, <bang>0)
command! -bang -nargs=* F call fzf#vim#grep(g:rg_command .shellescape(<q-args>), 1, <bang>0)
nnoremap <silent> <Leader>f :Rg<CR>

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
let g:python_recommended_style = 0
au Filetype python setlocal ts=2 sts=0 sw=2

" save with sudo using w!!
cmap w!! w !sudo tee > /dev/null %

"if !has('nvim')
"  function! StatusDiagnostic() abort
"    let info = get(b:, 'coc_diagnostic_info', {})
"    if empty(info) | return '' | endif
"    let msgs = []
"    if get(info, 'error', 0)
"      call add(msgs, 'E' . info['error'])
"    endif
"    if get(info, 'warning', 0)
"      call add(msgs, 'W' . info['warning'])
"    endif
"    return join(msgs, ' '). ' ' . get(g:, 'coc_status', '')
"  endfunction
"  set statusline=\ %{strlen(&fenc)?toupper(&fenc[0]):'-'}:%{&readonly&&&modified?'%*':&modified?'**':&readonly?'%%':'--'}\ %f\ (%{&ft})%*
"  set statusline+=%=%{strlen(FugitiveHead())?'⎇\ '.FugitiveHead():''}\ %P\ (%l,%c)\ %{StatusDiagnostic()}%*
"
"  let g:ycm_global_ycm_extra_conf = expand('$HOME/bin/ycm_global_extra_conf.py')
"  let g:ycm_autoclose_preview_window_after_insertion = 1
"  set cscopetag
"endif
function! s:statusline_expr()
  let mod = "%{&modified ? '[+] ' : !&modifiable ? '[x] ' : ''}"
  let ro  = "%{&readonly ? '[RO] ' : ''}"
  let ft  = "%{len(&filetype) ? '['.&filetype.'] ' : ''}"
  let fug = "%{exists('g:loaded_fugitive') ? fugitive#statusline() : ''}"
  let sep = ' %= '
  let pos = ' %-12(%l : %c%V%) '
  let pct = ' %P'

  return '[%n] %F %<'.mod.ro.ft.fug.sep.pos.'%*'.pct
endfunction
let &statusline = s:statusline_expr()
