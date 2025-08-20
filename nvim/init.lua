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

-- Decrease update time
vim.o.updatetime = 250

-- Decrease mapped sequence wait time
vim.o.timeoutlen = 300

-- Search settings
vim.opt.ignorecase = true
vim.opt.smartcase = true

-- UI settings
vim.opt.showmatch = false
vim.g.loaded_matchparen = 1
vim.opt.number = true

-- Undo history
vim.opt.undofile = true

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
    name = "ty",
    cmd = { '/home/shark/.cargo-target/debug/ty', 'server' },
    filetypes = { 'python' },
    root_dir = function(fname)
      return require('lspconfig.util').root_pattern('pyproject.toml', 'knot.toml')(fname)
        or vim.fs.dirname(vim.fs.find('.git', { path = fname, upward = true })[1])
    end,
    single_file_support = true,
    settings = {},
    -- on_attach = function(client, bufnr)
    --   vim.lsp.completion.enable(true, client.id, bufnr, {
    --     autotrigger = true,
    --     convert = function(item)
    --       return { abbr = item.label:gsub('%b()', '') }
    --     end,
    --   })
    -- end,
  },
}

lspconfig.ty.setup {}

-- Key mappings
vim.keymap.set('n', '<Leader>n', vim.diagnostic.goto_next, { desc = 'Next diagnostic' })
vim.keymap.set('n', '<Leader>g', vim.lsp.buf.definition, { desc = 'Go to definition' })
vim.keymap.set('n', '<Leader>t', vim.lsp.buf.type_definition, { desc = 'Go to type definition' })

-- Format on save, auto-completion
vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('my.lsp', {}),
  callback = function(args)
    local client = assert(vim.lsp.get_client_by_id(args.data.client_id))
    if client:supports_method('textDocument/implementation') then
      -- Create a keymap for vim.lsp.buf.implementation ...
    end
    -- Enable auto-completion. Note: Use CTRL-Y to select an item. |complete_CTRL-Y|
    if client:supports_method('textDocument/completion') then
      -- Autoselect the first item but don't insert it.
      -- Allows quick use, just write something and enter to select the first one.
      vim.opt.completeopt = { "menu", "menuone", "noinsert" }

      -- Optional: trigger autocompletion on EVERY keypress. May be slow!
      local chars = {}; for i = 32, 126 do table.insert(chars, string.char(i)) end
      client.server_capabilities.completionProvider.triggerCharacters = chars
      vim.lsp.completion.enable(true, client.id, args.buf, {autotrigger = true})
    end
    -- Auto-format ("lint") on save.
    -- Usually not needed if server supports "textDocument/willSaveWaitUntil".
    if not client:supports_method('textDocument/willSaveWaitUntil')
        and client:supports_method('textDocument/formatting') then
      vim.api.nvim_create_autocmd('BufWritePre', {
        group = vim.api.nvim_create_augroup('my.lsp', {clear=false}),
        buffer = args.buf,
        callback = function()
          vim.lsp.buf.format({ bufnr = args.buf, id = client.id, timeout_ms = 1000 })
        end,
      })
    end
  end,
})

-- Numbat

if not configs.numbat_lsp then
  configs.numbat_lsp = {
    default_config = {
      cmd = { 'numbat-lsp' }, -- Assumes numbat-lsp is in PATH
      filetypes = { 'numbat' },
      root_dir = lspconfig.util.root_pattern('.git', '.'),
      settings = {},
      init_options = {},
    },
    docs = {
      description = 'Numbat Language Server Protocol implementation',
      default_config = {
        root_dir = [[root_pattern('.git', '.')]],
      },
    },
  }
end

lspconfig.numbat_lsp.setup({
  on_attach = function(client, bufnr)
    -- Your usual LSP keybindings and setup
    local opts = { noremap = true, silent = true, buffer = bufnr }

    vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
    vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
    vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, opts)
    vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, opts)
    vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
    vim.keymap.set('n', '<leader>f', function()
      vim.lsp.buf.format { async = true }
    end, opts)

    -- Enable diagnostics
    vim.diagnostic.config({
      virtual_text = true,
      signs = true,
      underline = true,
      update_in_insert = false,
    })
  end,
  -- capabilities = require('cmp_nvim_lsp').default_capabilities(), -- If using nvim-cmp
})

vim.filetype.add({
  extension = {
    nbt = 'numbat',
  },
})

-- Plugins
require("lazy").setup({
  spec = {
    {
      {
        "NMAC427/guess-indent.nvim" -- Detect tabstop and shiftwidth automatically
      },

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
        'nvim-telescope/telescope.nvim',
        dependencies = { 'nvim-lua/plenary.nvim' },
        keys = {
          { '<C-p>', '<cmd>Telescope find_files<cr>', desc = 'Find files' }
        },
        config = function()
          require('telescope').setup({
            -- Your Telescope configuration here
          })
        end
      },

      { -- Adds git related signs to the gutter, as well as utilities for managing changes
        'lewis6991/gitsigns.nvim',
        opts = {
          signs = {
            add = { text = '+' },
            change = { text = '~' },
            delete = { text = '_' },
            topdelete = { text = '‾' },
            changedelete = { text = '~' },
          },
        },
        config = function()
          require('gitsigns').setup({
            -- Your existing gitsigns configuration
          })

          -- Map the exact same keys as before
          vim.keymap.set('n', '<Leader>j', function() require('gitsigns').next_hunk() end, { desc = 'Next Git hunk' })
          vim.keymap.set('n', '<Leader>k', function() require('gitsigns').prev_hunk() end, { desc = 'Previous Git hunk' })
          vim.keymap.set('n', '<Leader>r', function() require('gitsigns').undo_stage_hunk() end, { desc = 'Undo stage hunk' })
          vim.keymap.set('n', '<Leader>a', function() require('gitsigns').stage_hunk() end, { desc = 'Stage Git hunk' })
          vim.keymap.set('n', '<Leader>v', function() require('gitsigns').preview_hunk() end, { desc = 'Preview Git hunk' })
        end
      },
    },
  },
  -- colorscheme that will be used when installing plugins.
  install = { colorscheme = { "habamax" } },
  -- automatically check for plugin updates
  checker = {
    enabled = false,
  },
})

require('lualine').setup()
