local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
local uv = vim.uv or vim.loop

if not uv.fs_stat(lazypath) then
  local result = vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "--branch=stable",
    "https://github.com/folke/lazy.nvim.git",
    lazypath,
  })

  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to install lazy.nvim:\n", "ErrorMsg" },
      { result, "WarningMsg" },
    }, true, {})
    return
  end
end

vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  -- Keep startup behavior equivalent to the previous Packer setup. These
  -- plugins can be lazy-loaded later, but this migration does not change when
  -- they become available.
  defaults = {
    lazy = false,
  },

  {
    "mason-org/mason.nvim",
  },

  -- Completion, formatting, diagnostics, Git, and editor UX.
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "hrsh7th/cmp-cmdline",
    },
  },

  {
    "stevearc/conform.nvim",
  },

  {
    "mfussenegger/nvim-lint",
  },

  {
    "stevearc/overseer.nvim",
  },

  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
  },

  {
    "folke/which-key.nvim",
  },

  {
    "lewis6991/gitsigns.nvim",
  },

  {
    "sindrets/diffview.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
  },

  {
    "folke/trouble.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
  },

  {
    "b0o/SchemaStore.nvim",
  },

  {
    "windwp/nvim-autopairs",
  },

  {
    "echasnovski/mini.ai",
  },

  {
    "echasnovski/mini.surround",
  },

  {
    "echasnovski/mini.comment",
  },

  {
    "echasnovski/mini.icons",
  },

  {
    "stevearc/oil.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
  },

  {
    "nvim-telescope/telescope.nvim",
    version = "v0.2.2",
    dependencies = { "nvim-lua/plenary.nvim" },
  },

  {
    "rose-pine/neovim",
    name = "rose-pine",
    priority = 1000,
    config = function()
      vim.cmd.colorscheme("rose-pine")
    end,
  },

  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    dependencies = {
      "nvim-treesitter/nvim-treesitter-textobjects",
    },
  },

  {
    "theprimeagen/harpoon",
  },

  {
    "mbbill/undotree",
  },

  {
    "tpope/vim-fugitive",
  },
}, {
  -- None of the configured plugins require LuaRocks. Avoid an unnecessary
  -- hererocks bootstrap and keep plugin installation Git-based.
  rocks = {
    enabled = false,
  },
  install = {
    colorscheme = { "rose-pine" },
  },
  change_detection = {
    notify = false,
  },
})
