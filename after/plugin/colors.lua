function ColorMyPencils(color)
	color = color or "rose-pine"
	vim.cmd.colorscheme(color)
	require("ksnvim.set").apply()
end
ColorMyPencils()
