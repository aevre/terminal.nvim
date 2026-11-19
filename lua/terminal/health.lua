local M = {}

local health = vim.health
local start = health.start or health.report_start
local ok = health.ok or health.report_ok
local error = health.error or health.report_error

function M.check()
	start("terminal.nvim")
	if vim.fn.has("nvim-0.10") == 1 then
		ok("Neovim 0.10+ is available")
	else
		error("Neovim 0.10+ is required")
	end

	if pcall(require, "win") then
		ok("Module `win` is available")
	else
		error("Module `win` is required")
	end

	if vim.fn.exists("*jobstart") == 1 then
		ok("Neovim job control is available")
	else
		error("Neovim job control is required")
	end
end

return M
