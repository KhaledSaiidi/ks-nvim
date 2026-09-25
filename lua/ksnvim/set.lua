vim.opt.termguicolors = true
vim.opt.background = "dark"
vim.opt.winblend = 0
vim.opt.pumblend = 0
vim.opt.fillchars = { eob = " " }
vim.opt.number = true

local set_hl = vim.api.nvim_set_hl
local M = {}

local transparent_groups = {
  "Normal",
  "NormalFloat",
  "SignColumn",
  "EndOfBuffer",
  "StatusLine",
  "StatusLineNC",
  "WinSeparator",
  "FloatBorder",
  "Pmenu",
  "TelescopeNormal",
  "TelescopePromptNormal",
  "TelescopeResultsNormal",
  "TelescopePreviewNormal",
  "TelescopeBorder",
  "TelescopePromptBorder",
  "TelescopeResultsBorder",
  "TelescopePreviewBorder",
}

function M.apply()
  for _, group in ipairs(transparent_groups) do
    set_hl(0, group, { bg = "none" })
  end

  set_hl(0, "Normal", { fg = "#d8dee9", bg = "none" })
  set_hl(0, "NormalFloat", { fg = "#d8dee9", bg = "none" })
  set_hl(0, "Comment", { fg = "#6b7280", italic = true })
  set_hl(0, "CursorLine", { bg = "#111111" })
  set_hl(0, "LineNr", { fg = "#4b5563", bg = "none" })
  set_hl(0, "CursorLineNr", { fg = "#d8dee9", bg = "none", bold = true })
  set_hl(0, "FloatBorder", { fg = "#374151", bg = "none" })
  set_hl(0, "TelescopeBorder", { fg = "#374151", bg = "none" })
  set_hl(0, "TelescopePromptBorder", { fg = "#374151", bg = "none" })
  set_hl(0, "TelescopeResultsBorder", { fg = "#374151", bg = "none" })
  set_hl(0, "TelescopePreviewBorder", { fg = "#374151", bg = "none" })
end

M.apply()

vim.api.nvim_create_autocmd("ColorScheme", {
  group = vim.api.nvim_create_augroup("ksnvim_transparency", { clear = true }),
  callback = M.apply,
})

return M
