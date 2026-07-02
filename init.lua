-- Line numbers
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.signcolumn = "number"

-- Tabs and indentation
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true
vim.opt.smartindent = true

-- Search
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.hlsearch = true
vim.opt.incsearch = true

-- Misc
vim.opt.scrolloff = 8
vim.opt.wrap = false
vim.opt.swapfile = false
vim.opt.undofile = true
vim.opt.clipboard = 'unnamedplus'
vim.opt.updatetime = 300

-- Leader key
vim.g.mapleader = " "
vim.g.maplocalleader = " "


-- Keymaps
local map = vim.keymap.set

-- Clear search highliting with escape
map('n', '<Esc>', ':nohlsearch<CR>')

-- Better window navigation
map('n', '<C-h>', '<C-w>h')
map('n', '<C-j>', '<C-w>j')
map('n', '<C-k>', '<C-w>k')
map('n', '<C-l>', '<C-w>l')

-- Stay in indent mode when indenting in visual mode
map ('v', '<', '<gv')
map ('v', '>', '>gv')

-- Move lines up and down
map('n', '<A-j>', ':m .+1<CR>==')
map('n', '<A-k>', ':m .-2<CR>==')


-- Boostrap lazy.nvim
local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    'git',
    'clone',
    '--filter=blob:none',
    'https://github.com/folke/lazy.nvim.git',
    '--branch=stable',
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- Setup lazy with no plugins for now
require('lazy').setup({
  {
    'jpwol/thorn.nvim',
    lazy = false,
    priority = 1000,
    opts = {
      theme = 'dark',
      background = "warm",
      transparent = false,
      terminal = true,
      styles = {
        keywords = { italic = false, bold = false },
        comments = { italic = false, bold = false },
        strings  = { italic = false, bold = false },
      },
    },
    config = function(_, opts)
      require('thorn').setup(opts)
      vim.cmd.colorscheme('thorn')
    end,
  },
  {
    'nvim-telescope/telescope.nvim',
    dependencies = { 'nvim-lua/plenary.nvim' },
    config = function()
      require('telescope').setup({})

      local map = vim.keymap.set
      map('n', '<leader>ff', require('telescope.builtin').find_files)
      map('n', '<leader>fg', require('telescope.builtin').live_grep)
      map('n', '<leader>fb', require('telescope.builtin').buffers)
      map('n', '<leader>fh', require('telescope.builtin').help_tags)
      map('n', '<leaderfd>', require('telescope.builtin').diagnostics)
    end,
  },
  {
    'nvim-treesitter/nvim-treesitter',
    version = 'v0.9.3',
    build = ':TSUpdate',
    config = function()
      require('nvim-treesitter.configs').setup({
        ensure_installed = { 'lua', 'python', 'rust', 'toml', 'json', 'markdown', 'css', 'javascript', 'html' },
        auto_install = true,
        highlight = {
          enable = true,
        },
        indent = {
          enable = true,
        },
      })
    end,
  },
  {
    'williamboman/mason.nvim',
    config = function()
      require('mason').setup()
    end,
  },
  {
    'williamboman/mason-lspconfig.nvim',
    dependencies = { 'williamboman/mason.nvim' },
    config = function()
      require('mason-lspconfig').setup({
        ensure_installed = { 'pyright', 'rust_analyzer', 'cssls', 'ts_ls', 'html' },
        automatic_installation = true,
      })
    end,
  },
  {
    'neovim/nvim-lspconfig',
    dependencies = { 'williamboman/mason-lspconfig.nvim' },
    config = function()
      vim.lsp.config('pyright', {})
      vim.lsp.config('rust_analyzer', {})
      vim.lsp.config('cssls', {})
      vim.lsp.config('ts_ls', {})
      vim.lsp.config('html', {})

      -- Keymaps that only apply when LSP active
      vim.api.nvim_create_autocmd('LspAttach', {
        callback = function(event)
          local client = vim.lsp.get_client_by_id(event.data.client_id)
          if client and client.supports_method('textDocument/documentHighlight') then
            vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
              buffer = event.buf,
              callback = vim.lsp.buf.document_highlight,
            })
            vim.api.nvim_create_autocmd('CursorMoved', {
              buffer = event.buf,
              callback = vim.lsp.buf.clear_references,
            })
          end
          local map = vim.keymap.set
          map('n', 'gd', vim.lsp.buf.definition)
          map('n', 'K', vim.lsp.buf.hover)
          map('n', '<leader>rn', vim.lsp.buf.rename)
          map('n', '<leader>ca', vim.lsp.buf.code_action)
          map('n', '<leader>e', vim.diagnostic.open_float)
        end,
      })
    end,
  },
  {
    'hrsh7th/nvim-cmp',
    dependencies = {
      'hrsh7th/cmp-nvim-lsp',
      'hrsh7th/cmp-buffer',
      'hrsh7th/cmp-path',
      'L3MON4D3/LuaSnip',
      'saadparwaiz1/cmp_luasnip',
    },
    config = function()
      local cmp = require('cmp')
      local luasnip = require('luasnip')

      cmp.setup({
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end
        },
        mapping = cmp.mapping.preset.insert({
          ['<C-Space>'] = cmp.mapping.complete(),
          ['<C-e>'] = cmp.mapping.abort(),
          ['<CR>'] = cmp.mapping.confirm({ select = true }),
          ['<Tab>'] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.confirm({ select = true })
            elseif luasnip.expand_or_jumpable() then 
              luasnip.expand_or_jump()
            else
              fallback()
            end
          end, {'i', 's' }),
          ['<S-Tab>'] = cmp.mapping(function(fallbacK)
            if cmp.visible() then
              cmp.select_prev_item()
            else
              fallback()
            end
          end, {'i', 's' }),
        }),
        sources = cmp.config.sources({
          { name = 'nvim_lsp' },
          { name = 'luansip' },
          { name = 'buffer' } ,
          { name = 'path' },
        }),
      })
    end,
  },
})

-- Remove italics
vim.api.nvim_set_hl(0, 'Keyword', { italic = false})
vim.api.nvim_set_hl(0, '@keyword', { italic = false})
vim.api.nvim_set_hl(0, '@keyword.function', { fg = '#f9ada0', italic = false })
vim.api.nvim_set_hl(0, '@function.builtin', { italic = false})


-- Specific highlight
vim.api.nvim_set_hl(0, 'Keyword', {fg = '#f9ada0', italic  = false })
vim.api.nvim_set_hl(0, '@keyword.return.python', {fg = '#d2696c', italic = false })

