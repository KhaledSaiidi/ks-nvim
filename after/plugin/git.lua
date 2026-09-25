local gitsigns_ok, gitsigns = pcall(require, "gitsigns")
if gitsigns_ok then
  gitsigns.setup({
    current_line_blame = false,
    on_attach = function(bufnr)
      local function map(mode, lhs, rhs, desc)
        vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc })
      end

      map("n", "]c", function()
        if vim.wo.diff then
          return "]c"
        end
        vim.schedule(function()
          gitsigns.next_hunk()
        end)
        return "<Ignore>"
      end, "Next git hunk")

      map("n", "[c", function()
        if vim.wo.diff then
          return "[c"
        end
        vim.schedule(function()
          gitsigns.prev_hunk()
        end)
        return "<Ignore>"
      end, "Previous git hunk")

      map({ "n", "v" }, "<leader>hs", gitsigns.stage_hunk, "Stage hunk")
      map({ "n", "v" }, "<leader>hr", gitsigns.reset_hunk, "Reset hunk")
      map("n", "<leader>hS", gitsigns.stage_buffer, "Stage buffer")
      map("n", "<leader>hu", gitsigns.undo_stage_hunk, "Undo stage hunk")
      map("n", "<leader>hR", gitsigns.reset_buffer, "Reset buffer")
      map("n", "<leader>hp", gitsigns.preview_hunk, "Preview hunk")
      map("n", "<leader>hb", gitsigns.blame_line, "Blame line")
      map("n", "<leader>hd", gitsigns.diffthis, "Diff buffer")
      map("n", "<leader>hD", function()
        gitsigns.diffthis("~")
      end, "Diff against index")
      map("n", "<leader>tb", gitsigns.toggle_current_line_blame, "Toggle line blame")
      map("n", "<leader>td", gitsigns.toggle_deleted, "Toggle deleted lines")
    end,
  })
end

local diffview_ok = pcall(require, "diffview")
if diffview_ok then
  vim.keymap.set("n", "<leader>gdo", "<Cmd>DiffviewOpen<CR>", { desc = "Open diff view" })
  vim.keymap.set("n", "<leader>gdc", "<Cmd>DiffviewClose<CR>", { desc = "Close diff view" })
  vim.keymap.set("n", "<leader>gdh", "<Cmd>DiffviewFileHistory %<CR>", { desc = "File history" })
end
