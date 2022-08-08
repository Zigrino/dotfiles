source ~/.config/nvim/rebinds.vim
source ~/.config/nvim/plugins/plugins.vim
source ~/.config/nvim/settings.vim
source ~/.config/nvim/cmp.vim

inoremap jk <Esc>
set mouse=a

colorscheme gruvbox-material




lua << EOF
--language servers
require("nvim-tree").setup()
require("mason").setup()
require("mason-lspconfig").setup({
  ensure_installed = { "summneko_lua", "rust_analyzer", "pyright", "clangd" }
})
require'lspconfig'.pyright.setup{}
require'lspconfig'.clangd.setup{}
require'lspconfig'.jdtls.setup{}
--treesitter stuff
local status_ok, configs = pcall(require, "nvim-treesitter.configs")
if not status_ok then
	return
end

configs.setup({
	highlight = {
		enable = true, -- false will disable the whole extension
		disable = { "css" }, -- list of language that will be disabled
	},
	autopairs = {
		enable = true,
	},
	indent = { enable = true, disable = { "python", "css" } },
})

--treesitter setup autopair stuff
local npairs = require("nvim-autopairs")
local Rule = require('nvim-autopairs.rule')

npairs.setup({
    check_ts = true,
    ts_config = {
        lua = {'string'},-- it will not add a pair on that treesitter node
        javascript = {'template_string'},
        java = false,-- don't check treesitter on java
    }
})




local ts_conds = require('nvim-autopairs.ts-conds')
require("bufferline").setup{
    separator_style = "slant"
        }
require("lualine").setup()
require("which-key").setup {
    -- your configuration comes here
    -- or leave it empty to use the default settings
    -- refer to the configuration section below
  }
require("trouble").setup {
    autoclose = true
    -- your configuration comes here
    -- or leave it empty to use the default settings
    -- refer to the configuration section below
  }


require("telescope").setup{}
require("telescope").load_extension "file_browser"
require("nnn").setup()



EOF







