if vim.g.loaded_terminal_nvim then
	return
end
vim.g.loaded_terminal_nvim = true

require("terminal").setup()
