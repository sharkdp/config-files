---- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

-- Set leader key to space
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Spaces instead of tabs
vim.opt.expandtab = true
vim.opt.shiftwidth = 4
vim.opt.tabstop = 4

-- Do not show startup message
vim.opt.shortmess:append({ a = true, t = true, I = true, O = true })

-- Search settings
vim.opt.ignorecase = true
vim.opt.smartcase = true

-- UI settings
vim.opt.showmatch = false
vim.g.loaded_matchparen = 1
vim.opt.number = true

-- Undo history
if vim.fn.has('persistent_undo') == 1 then
    vim.opt.undodir = vim.fn.expand('~/.vimundo')
    vim.opt.undofile = true
end

-- Scroll offsets
vim.opt.scrolloff = 7
vim.opt.sidescrolloff = 5

-- Key mappings
vim.keymap.set('n', '<bs>', 'X', { noremap = true })

-- Quit/save mappings
vim.keymap.set('n', '<C-Q>', ':q<CR>', { noremap = true })
vim.keymap.set('v', '<C-Q>', '<Esc>:q<CR>', { noremap = true })
vim.keymap.set('i', '<C-Q>', '<Esc>:q<CR>', { noremap = true })

vim.keymap.set('n', '<C-S>', ':write<CR>', { silent = true, noremap = true })
vim.keymap.set('v', '<C-S>', '<Esc>:write<CR>', { silent = true, noremap = true })
vim.keymap.set('i', '<C-S>', '<Esc>:write<CR>', { silent = true, noremap = true })

-- Buffer close
vim.keymap.set('n', '<C-B>', ':bd<CR>', { noremap = true })
vim.keymap.set('v', '<C-B>', '<Esc>:bd<CR>', { noremap = true })
vim.keymap.set('i', '<C-B>', '<Esc>:bd<CR>', { noremap = true })

-- Delete word around/after cursor (in addition to C-w)
vim.keymap.set('i', '<C-d>', '<C-o>daw', { noremap = true })
vim.keymap.set('n', '<C-d>', 'daw', { noremap = true })

-- Duplicate and comment
vim.keymap.set('n', '<Leader>c', 'Ypkgccj', { noremap = true })
vim.keymap.set('v', '<Leader>c', 'gcgvyPgvgc', { noremap = true })

-- Quick comment toggling
vim.keymap.set('n', '<C-e>', 'gcc', { remap = true })
vim.keymap.set('i', '<C-e>', '<C-o>gcc', { remap = true })
vim.keymap.set('v', '<C-e>', 'gc', { remap = true })

-- System clipboard operations
vim.keymap.set('v', '<Leader>y', '"+y', { noremap = true })
vim.keymap.set('v', '<Leader>d', '"+d', { noremap = true })
vim.keymap.set('n', '<Leader>p', '"+p', { noremap = true })
vim.keymap.set('n', '<Leader>P', '"+P', { noremap = true })
vim.keymap.set('v', '<Leader>p', '"+p', { noremap = true })
vim.keymap.set('v', '<Leader>P', '"+P', { noremap = true })

-- Set up LSP
local lspconfig = require('lspconfig')

vim.diagnostic.config({ virtual_text = true })

vim.keymap.set("n", '<leader>i', 
  function() 
    vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({0}),{0}) 
  end
)

---- Common capabilities
-- lspconfig.pyright.setup({ capabilities = capabilities })
lspconfig.rust_analyzer.setup({ capabilities = capabilities })

require('lspconfig').ruff.setup({
  init_options = {
    settings = {
      logLevel = 'debug',
    }
  }
})

local configs = require('lspconfig.configs')
configs.ty = {
  default_config = {
    cmd = { 'ty', 'server' },
    filetypes = { 'python' },
    root_dir = function(fname)
      return require('lspconfig.util').root_pattern('pyproject.toml', 'knot.toml')(fname)
        or vim.fs.dirname(vim.fs.find('.git', { path = fname, upward = true })[1])
    end,
    single_file_support = true,
    settings = {},
  },
}

lspconfig.ty.setup {}

-- Key mappings
vim.keymap.set('n', '<Leader>n', vim.diagnostic.goto_next, { desc = 'Next diagnostic' })
vim.keymap.set('n', '<Leader>g', vim.lsp.buf.definition, { desc = 'Go to definition' })
vim.keymap.set('n', '<Leader>t', vim.lsp.buf.type_definition, { desc = 'Go to type definition' })

-- Format on save
vim.api.nvim_create_autocmd('BufWritePre', {
  pattern = { '*.rs', '*.py', '*.cpp', '*.h' },
  callback = function()
    vim.lsp.buf.format({ async = false })
  end
})

-- Plugins
require("lazy").setup({
  spec = {
    {
      {
        "sainnhe/sonokai",
        lazy = false, -- make sure we load this during startup if it is your main colorscheme
        priority = 1000, -- make sure to load this before all the other start plugins
        config = function()
          -- load the colorscheme here
          vim.cmd([[colorscheme sonokai]])
        end,
      },

      {
          'nvim-lualine/lualine.nvim',
          dependencies = { 'nvim-tree/nvim-web-devicons' }
      },

      {
        "hrsh7th/nvim-cmp",
        -- load cmp on InsertEnter
        event = "InsertEnter",
        -- these dependencies will only be loaded when cmp loads
        -- dependencies are always lazy-loaded unless specified otherwise
        dependencies = {
          "hrsh7th/cmp-nvim-lsp",
          "hrsh7th/cmp-buffer",
        },
        config = function()
          -- ...
        end,
      },
    },
  },
    -- Configure any other settings here. See the documentation for more details.
  -- colorscheme that will be used when installing plugins.
  install = { colorscheme = { "habamax" } },
  -- automatically check for plugin updates
  checker = { enabled = true },
})

require('lualine').setup()
