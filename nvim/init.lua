-- Bootstrap lazy.nvim
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

-- Make sure to setup `mapleader` and `maplocalleader` before
-- loading lazy.nvim so that mappings are correct.
-- This is also a good place to setup other settings (vim.opt)
vim.g.mapleader = " "
vim.g.maplocalleader = " "

vim.g.vimtex_compiler_method = 'latexmk'

vim.o.tabstop = 4
vim.o.shiftwidth = 4
vim.o.expandtab = true
vim.o.cmdheight = 0

vim.opt.number = true
vim.opt.relativenumber = false 
vim.opt.cursorline = false
vim.opt.wrap = true
vim.opt.linebreak = true


-- Setup lazy.nvim
require("lazy").setup({
  spec = {
    -- add your plugins here
    {
  "lervag/vimtex",
  lazy = false,     -- we don't want to lazy load VimTeX
  -- tag = "v2.15", -- uncomment to pin to a specific release
  init = function()
    -- VimTeX configuration goes here, e.g.
    vim.g.vimtex_view_method = "skim"
  end
},
  { "catppuccin/nvim", name = "catppuccin", priority = 1000 },
{
  "folke/which-key.nvim",
  event = "VeryLazy",
  opts = {
    -- your configuration comes here
    -- or leave it empty to use the default settings
    -- refer to the configuration section below
  },
  keys = {
    {
      "<leader>?",
      function()
        require("which-key").show({ global = false })
      end,
      desc = "Buffer Local Keymaps (which-key)",
    },
  },
},
{
    "mason-org/mason.nvim",
    opts = {}
}, 

{
    'windwp/nvim-autopairs',
    event = "InsertEnter",
    config = true
    -- use opts = {} for passing setup options
    -- this is equivalent to setup({}) function
},

--snippet shit
  {
    "L3MON4D3/LuaSnip",
    -- follow tutorial for custom snippets
    build = "make install_jsregexp",
    dependencies = { "rafamadriz/friendly-snippets" },
  },

  -- Autocompletion Engine
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "hrsh7th/cmp-buffer", -- buffer completions
      "hrsh7th/cmp-path", -- path completions
      "saadparwaiz1/cmp_luasnip", -- snippet completions
      "hrsh7th/cmp-nvim-lsp", -- LSP completions
    },
  },

  {
      "neovim/nvim-lspconfig"
  },

-- {
--     "evesdropper/luasnip-latex-snippets.nvim",
-- },

{
    'nvim-lualine/lualine.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons' }
},
--telescope

{
'nvim-telescope/telescope.nvim', tag = '0.1.8',
-- or                              , branch = '0.1.x',
  dependencies = { 'nvim-lua/plenary.nvim' }
},

{
    "nvim-telescope/telescope-file-browser.nvim",
    dependencies = { "nvim-telescope/telescope.nvim", "nvim-lua/plenary.nvim" }
}






  },
  -- Configure any other settings here. See the documentation for more details.
  -- colorscheme that will be used when installing plugins.
  install = { colorscheme = { "habamax" } },
  -- automatically check for plugin updates
  checker = { enabled = true },
})
vim.cmd.colorscheme "catppuccin-latte"
--require('lualine').setup({options = {theme = 'auto'}})

--telescope setup
local builtin = require('telescope.builtin')
vim.keymap.set('n', '<leader>ff', builtin.find_files, { desc = 'Telescope find files' })
vim.keymap.set('n', '<leader>fg', builtin.live_grep, { desc = 'Telescope live grep' })
vim.keymap.set('n', '<leader>fb', builtin.buffers, { desc = 'Telescope buffers' })
vim.keymap.set('n', '<leader>fh', builtin.help_tags, { desc = 'Telescope help tags' })
--file browser
vim.keymap.set("n", "<space>ft", ":Telescope file_browser<CR>")

--lsp shit
vim.lsp.enable('basedpyright')
vim.lsp.enable('texlab')
vim.lsp.enable('latexindent')
vim.diagnostic.config({
  signs = false,
})

--luasnip setup with cmp and shit
require("luasnip.loaders.from_vscode").lazy_load()
require("luasnip.loaders.from_lua").load({paths = "~/.config/nvim/LuaSnip/"})


local cmp = require("cmp")
local luasnip = require("luasnip")

require("luasnip").config.set_config({
    enable_autosnippets = true
})

--sketchy ahh chatgpt
vim.keymap.set("n", "<leader>rr", function()
  vim.cmd("source $MYVIMRC")
  vim.notify("Reloaded init.lua", vim.log.levels.INFO)
end, { desc = "Reload Neovim config" })



--some cmp helper shit
local has_words_before = function()
  unpack = unpack or table.unpack
  local line, col = unpack(vim.api.nvim_win_get_cursor(0))
  return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
end

cmp.setup({
  sources = cmp.config.sources({
    { name = "nvim_lsp", priority = 30, max_item_count = 10 },
    { name = "luasnip", priority = 40}, -- Add LuaSnip as a source
    { name = "buffer", priority = 20, max_item_count = 10 },
    { name = "path" },
  }),
  mapping = cmp.mapping.preset.insert({
    ["<S-Tab>"] = cmp.mapping.select_prev_item(),
    -- ["<Tab>"] = cmp.mapping.select_next_item(),
    ['<Tab>'] = cmp.mapping(function(fallback)
  if cmp.visible() then
    if #cmp.get_entries() == 1 then
      cmp.confirm({ select = true })
    else
      cmp.select_next_item()
    end
  --[[ Replace with your snippet engine (see above sections on this page)
  elseif snippy.can_expand_or_advance() then
    snippy.expand_or_advance() ]]
  elseif has_words_before() then
    cmp.complete()
    if #cmp.get_entries() == 1 then
      cmp.confirm({ select = true })
    end
  else
    fallback()
  end
end, { "i", "s" }),
    -- ["<CR>"] = cmp.mapping.confirm({ select = true }),
     ["<CR>"] = cmp.mapping({
   i = function(fallback)
     if cmp.visible() and cmp.get_active_entry() then
       cmp.confirm({ behavior = cmp.ConfirmBehavior.Replace, select = false })
     else
       fallback()
     end
   end,
   s = cmp.mapping.confirm({ select = true }),
   c = cmp.mapping.confirm({ behavior = cmp.ConfirmBehavior.Replace, select = true }),
 }),
    ["<c-j>"] = cmp.mapping(function(fallback)
      if luasnip.expand_or_jumpable() then
        luasnip.expand_or_jump()
      else
        fallback()
      end
    end, { "i", "s" }),
    ["<c-k>"] = cmp.mapping(function(fallback)
      if luasnip.jumpable(-1) then
        luasnip.jump(-1)
      else
        fallback()
      end
    end, { "i", "s" }),
  }),
})



vim.api.nvim_create_autocmd('User', {
  pattern = 'VimtexEventViewReverse',
  group = group,
  command = "call s:TexFocusVim()"
})


--if using neovide 
if vim.g.neovide then
    -- Put anything you want to happen only in Neovide here
    vim.g.neovide_cursor_animation_length = 0.1
    vim.o.guifont = "0xProto Nerd Font"
end
