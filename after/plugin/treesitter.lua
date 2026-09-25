local languages = {
  "javascript",
  "typescript",
  "go",
  "python",
  "hcl",
  "c",
  "lua",
  "bash",
  "dockerfile",
  "json",
  "markdown",
  "toml",
  "yaml",
}

require("nvim-treesitter").setup {
  install_dir = vim.fn.stdpath("data") .. "/site",
}

require("nvim-treesitter").install(languages)

vim.api.nvim_create_autocmd("FileType", {
  pattern = {
    "javascript",
    "typescript",
    "go",
    "python",
    "hcl",
    "terraform",
    "terraform-vars",
    "c",
    "lua",
    "bash",
    "sh",
    "zsh",
    "dockerfile",
    "json",
    "jsonc",
    "markdown",
    "markdown.mdx",
    "toml",
    "yaml",
    "yaml.ghactions",
    "yaml.ansible",
    "yaml.docker-compose",
    "yaml.gitlab",
    "yaml.helm-values",
  },
  callback = function(args)
    pcall(vim.treesitter.start, args.buf)
  end,
})
