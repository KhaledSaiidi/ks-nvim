-- Keep the old Packer package tree from being auto-loaded after migrating to
-- lazy.nvim. The checkouts remain on disk and can be removed later.
local old_packer_start = vim.fn.stdpath("data") .. "/site/pack/packer/start"
vim.opt.runtimepath:remove(old_packer_start)

-- nvim-treesitter/playground is archived and incompatible with current
-- nvim-treesitter.
vim.opt.runtimepath:remove(old_packer_start .. "/playground")

require("ksnvim")
