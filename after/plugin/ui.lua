local lualine_ok, lualine = pcall(require, "lualine")
if lualine_ok then
  lualine.setup({
    options = {
      theme = "auto",
      globalstatus = true,
      component_separators = { left = "", right = "" },
      section_separators = { left = "", right = "" },
      disabled_filetypes = { "NvimTree", "oil" },
    },
    sections = {
      lualine_a = { "mode" },
      lualine_b = { "branch", "diff", "diagnostics" },
      lualine_c = { { "filename", path = 1 } },
      lualine_x = { "encoding", "fileformat", "filetype" },
      lualine_y = { "progress" },
      lualine_z = { "location" },
    },
  })
end

local which_key_ok, which_key = pcall(require, "which-key")
if which_key_ok then
  which_key.setup({
    preset = "modern",
    delay = 300,
    icons = { mappings = true },
    win = { border = "rounded" },
  })

  which_key.add({
    { "<leader>p", group = "find/search" },
    { "<leader>g", group = "git" },
    { "<leader>h", group = "hunks" },
    { "<leader>l", group = "language/format" },
    { "<leader>x", group = "diagnostics" },
  })
end
