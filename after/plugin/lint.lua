local ok, lint = pcall(require, "lint")
if not ok then
  return
end

-- kube-linter is not included in nvim-lint's built-in collection, so keep a
-- small JSON adapter here. Kube-linter reports object-level findings rather
-- than exact line numbers; the diagnostic is therefore placed at line 1.
lint.linters.kube_linter = {
  cmd = "kube-linter",
  args = { "lint", "--format", "json", "--with-color=false" },
  stdin = false,
  append_fname = true,
  ignore_exitcode = true,
  parser = function(output)
    if output == "" then
      return {}
    end

    -- kube-linter may prefix JSON with a human-readable stderr line when it
    -- exits non-zero; keep the parser tolerant of either stream being merged.
    local json_start = output:find("{")
    if not json_start then
      return {}
    end
    local json = output:sub(json_start)
    local json_end = json:match(".*()}")
    local decoded = vim.json.decode(json_end and json:sub(1, json_end) or json)
    local diagnostics = {}
    for _, report in ipairs(decoded and decoded.Reports or {}) do
      local object = report.Object or {}
      local object_meta = object.Metadata or {}
      local object_name = object.K8sObject or {}
      local kind = object_name.GroupVersionKind or {}
      table.insert(diagnostics, {
        lnum = 0,
        col = 0,
        severity = vim.diagnostic.severity.WARN,
        source = "kube-linter: " .. (report.Check or "check"),
        message = string.format(
          "%s [%s/%s]",
          report.Diagnostic and report.Diagnostic.Message or "Kubernetes policy violation",
          kind.Kind or "object",
          object_name.Name or object_meta.FilePath or "manifest"
        ),
      })
    end
    return diagnostics
  end,
}

-- These are deliberately complementary to LSP diagnostics: linters catch
-- policy, security, and CI/IaC issues that language servers do not model.
lint.linters_by_ft = {
  python = { "ruff" },
  go = { "golangcilint" },
  terraform = { "tflint" },
  ["terraform-vars"] = { "tflint" },
  yaml = { "yamllint", "kube_linter" },
  ["yaml.ansible"] = { "yamllint", "ansible_lint" },
  ["yaml.ghactions"] = { "actionlint", "yamllint" },
  ["yaml.docker-compose"] = { "yamllint" },
  ["yaml.gitlab"] = { "yamllint" },
  ["yaml.helm-values"] = { "yamllint" },
  dockerfile = { "hadolint" },
  sh = { "shellcheck" },
  bash = { "shellcheck" },
  zsh = { "shellcheck" },
}

local group = vim.api.nvim_create_augroup("ksnvim_lint", { clear = true })
vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave" }, {
  group = group,
  callback = function(args)
    lint.try_lint(nil, { bufnr = args.buf })
  end,
})

vim.keymap.set("n", "<leader>ll", function()
  lint.try_lint(nil, { bufnr = 0 })
end, { desc = "Lint buffer" })

vim.keymap.set("n", "<leader>le", vim.diagnostic.open_float, {
  desc = "Show diagnostics",
})

vim.keymap.set("n", "]d", function()
  vim.diagnostic.jump({ count = 1, float = true })
end, { desc = "Next diagnostic" })

vim.keymap.set("n", "[d", function()
  vim.diagnostic.jump({ count = -1, float = true })
end, { desc = "Previous diagnostic" })
