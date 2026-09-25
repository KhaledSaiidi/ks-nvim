local ok, conform = pcall(require, "conform")
if not ok then
  return
end

conform.setup({
  formatters_by_ft = {
    python = { "ruff_format" },
    go = { "gofumpt" },
    javascript = { "prettier" },
    javascriptreact = { "prettier" },
    typescript = { "prettier" },
    typescriptreact = { "prettier" },
    json = { "prettier" },
    jsonc = { "prettier" },
    yaml = { "yamlfmt" },
    ["yaml.ghactions"] = { "yamlfmt" },
    ["yaml.docker-compose"] = { "yamlfmt" },
    ["yaml.gitlab"] = { "yamlfmt" },
    ["yaml.helm-values"] = { "yamlfmt" },
    terraform = { "terraform_fmt" },
    ["terraform-vars"] = { "terraform_fmt" },
    hcl = { "hcl" },
    sh = { "shfmt" },
    bash = { "shfmt" },
    zsh = { "shfmt" },
    lua = { "stylua" },
    toml = { "taplo" },
  },
  format_on_save = function(bufnr)
    -- Keep formatting predictable in large or generated files.
    if vim.b[bufnr].disable_autoformat then
      return
    end

    return {
      timeout_ms = 3000,
      lsp_format = "fallback",
    }
  end,
})

vim.keymap.set({ "n", "v" }, "<leader>lf", function()
  conform.format({
    async = true,
    lsp_format = "fallback",
  })
end, { desc = "Format buffer" })

vim.api.nvim_create_user_command("FormatDisable", function(args)
  vim.b.disable_autoformat = args.bang and false or true
  vim.notify(vim.b.disable_autoformat and "Format on save disabled" or "Format on save enabled")
end, {
  bang = true,
  desc = "Toggle format on save for the current buffer",
})
