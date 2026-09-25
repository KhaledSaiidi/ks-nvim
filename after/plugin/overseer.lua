local ok, overseer = pcall(require, "overseer")
if not ok then
  return
end

overseer.setup({
  output = {
    use_terminal = true,
    preserve_output = true,
  },
  task_list = {
    direction = "bottom",
    min_height = 8,
  },
})

vim.keymap.set("n", "<leader>ot", "<Cmd>OverseerToggle<CR>", {
  desc = "Toggle task list",
})
vim.keymap.set("n", "<leader>or", "<Cmd>OverseerRun<CR>", {
  desc = "Run project task",
})
vim.keymap.set("n", "<leader>oa", "<Cmd>OverseerTaskAction<CR>", {
  desc = "Task action",
})
