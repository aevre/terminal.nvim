local M = {}

--- Parse a shell command into arguments.
---@param cmd string|string[]
---@return string[]
function M.parse(cmd)
	if type(cmd) == "table" then
		return cmd
	end

	local args = {}
	local in_quotes, escape_next, current = false, false, ""
	local function add()
		if #current > 0 then
			args[#args + 1] = current
			current = ""
		end
	end

	for i = 1, #cmd do
		local char = cmd:sub(i, i)
		if escape_next then
			current = current .. ((char == '"' or char == "\\") and "" or "\\") .. char
			escape_next = false
		elseif char == "\\" and in_quotes then
			escape_next = true
		elseif char == '"' then
			in_quotes = not in_quotes
		elseif char:find("[ \t]") and not in_quotes then
			add()
		else
			current = current .. char
		end
	end
	add()
	return args
end

--- Replace ANSI color codes in the current buffer with terminal colors.
function M.colorize()
	vim.wo.number = false
	vim.wo.relativenumber = false
	vim.wo.statuscolumn = ""
	vim.wo.signcolumn = "no"
	vim.opt.listchars = { space = " " }

	local buf = vim.api.nvim_get_current_buf()
	local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
	while #lines > 0 and vim.trim(lines[#lines]) == "" do
		lines[#lines] = nil
	end
	vim.api.nvim_buf_set_lines(buf, 0, -1, false, {})

	vim.api.nvim_chan_send(vim.api.nvim_open_term(buf, {}), table.concat(lines, "\r\n"))
	vim.keymap.set("n", "q", "<cmd>q<cr>", { silent = true, buffer = buf })
	vim.api.nvim_create_autocmd("TextChanged", {
		buffer = buf,
		callback = function()
			pcall(vim.api.nvim_win_set_cursor, 0, { #lines, 0 })
		end,
	})
	vim.api.nvim_create_autocmd("TermEnter", { buffer = buf, command = "stopinsert" })
end

return M
