local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node
-- Use fmta for easier formatting, if desired
local fmta = require("luasnip.extras.fmt").fmta 

-- VimTeX mathzone checker (only expand snippets in math mode)
-- local function in_mathzone()
--   return vim.fn["vimtex#syntax#in_mathzone"]() == 1
-- end

local function in_mathzone()
  -- hard guard: if vimtex isn't loaded, this returns false instead of “truthy”
  local ok, fn = pcall(function() return vim.fn["vimtex#syntax#in_mathzone"] end)
  if not ok or fn == nil then return false end
  return fn() == 1
end

local function not_in_mathzone()
  local ok, fn = pcall(function() return vim.fn["vimtex#syntax#in_mathzone"] end)
  if not ok or fn == nil then return true end
  return fn() == 0
end

vim.keymap.set("n", "<leader>rs", function()
  vim.cmd("source $MYVIMRC")
  require("luasnip").cleanup()
  require("luasnip.loaders.from_lua").load({ paths = vim.fn.stdpath("config") .. "/lua/snippets" })
  vim.notify("Reloaded config + snippets", vim.log.levels.INFO)
end, { desc = "Reload config + LuaSnip" })



return {
    s({ trig = "eq", dscr = "Begin/end equation environment (yuli version)" },
        {
            t({"\\begin{equation}", "\t"}),
            i(1),
            t({"", "\\end{equation}"}),
        }
    ),

  s(
    { trig = "pp", dscr = "Partial derivative fraction" },
    fmta([[\frac{\partial <>}{\partial <>}]], { i(1, "f"), i(2, "x") }),
    { condition = in_mathzone, show_condition = in_mathzone }
  ),

  -- 2) n-th order partial derivative: \frac{\partial^{n} f}{\partial x^{n}}
  s(
    { trig = "ppn", dscr = "n-th order partial derivative fraction" },
    fmta([[\frac{\partial^{<>} <>}{\partial <>^{<>}}]], {
      i(1, "n"),
      i(2, "f"),
      i(3, "x"),
      i(4, "n"),
    }),
    { condition = in_mathzone, show_condition = in_mathzone }
  ),

  s({ trig = "prf", dscr = "Begin/end proof environment" }, {
  t({ "\\begin{proof}", "" }),
  i(1),
  t({ "", "\\end{proof}" }),
}),

}

