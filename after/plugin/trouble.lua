local ok, trouble = pcall(require, "trouble")
if not ok then
  return
end

trouble.setup({
  auto_preview = false,
  focus = true,
  win = { type = "split", size = 14 },
})

vim.keymap.set("n", "<leader>xx", function()
  trouble.toggle({ mode = "diagnostics", focus = true })
end, { desc = "Toggle diagnostics" })
vim.keymap.set("n", "<leader>xX", function()
  trouble.toggle({ mode = "diagnostics", filter = { buf = 0 }, focus = true })
end, { desc = "Buffer diagnostics" })
vim.keymap.set("n", "<leader>xq", function()
  trouble.toggle({ mode = "quickfix", focus = true })
end, { desc = "Quickfix list" })
vim.keymap.set("n", "<leader>xl", function()
  trouble.toggle({ mode = "loclist", focus = true })
end, { desc = "Location list" })
