local autopairs_ok, autopairs = pcall(require, "nvim-autopairs")
if autopairs_ok then
  autopairs.setup({
    check_ts = true,
    fast_wrap = {},
  })

  local cmp_ok, cmp = pcall(require, "cmp")
  if cmp_ok then
    local cmp_autopairs = require("nvim-autopairs.completion.cmp")
    cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())
  end
end

local mini_ai_ok, mini_ai = pcall(require, "mini.ai")
if mini_ai_ok then
  mini_ai.setup({
    n_lines = 500,
    custom_textobjects = {
      f = mini_ai.gen_spec.treesitter({
        a = "@function.outer",
        i = "@function.inner",
      }),
    },
  })
end

local mini_surround_ok, mini_surround = pcall(require, "mini.surround")
if mini_surround_ok then
  mini_surround.setup()
end

local mini_comment_ok, mini_comment = pcall(require, "mini.comment")
if mini_comment_ok then
  mini_comment.setup()
end

local mini_icons_ok, mini_icons = pcall(require, "mini.icons")
if mini_icons_ok then
  mini_icons.setup()
end

local oil_ok, oil = pcall(require, "oil")
if oil_ok then
  oil.setup({
    default_file_explorer = false,
    columns = { "icon", "permissions", "size", "mtime" },
    view_options = { show_hidden = true },
    float = { padding = 2, max_width = 100, max_height = 30, border = "rounded" },
  })

  vim.keymap.set("n", "<leader>e", "<Cmd>Oil<CR>", { desc = "Open file explorer" })
  vim.keymap.set("n", "-", "<Cmd>Oil<CR>", { desc = "Open parent directory" })
end
