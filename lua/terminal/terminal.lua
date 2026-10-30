local Win = require("win")
local registry = require("terminal.registry")
local util = require("terminal.util")

local M = {}

---@param cmd string|string[]
---@param opts? table
---@return integer
local function jobstart(cmd, opts)
	opts = opts or {}
	return vim.fn.jobstart(cmd, vim.tbl_isempty(opts) and vim.empty_dict() or opts)
end

---@param cmd? string|string[]
---@param opts terminal.Opts
---@return terminal?
function M.open(cmd, opts)
	local id = opts.count or vim.v.count1
	local position = cmd and "float" or "bottom"
	if opts.win and opts.win.position then
		position = opts.win.position
	end
	local win_opts = {
		position = position,
	}
	if (position == "left" or position == "right") and (not opts.win or opts.win.width == nil) then
		win_opts.width = 0.3
	end
	opts.win = Win.resolve("terminal", win_opts, opts.win, { show = false })
	opts = vim.deepcopy(opts)

	if opts.override then
		return opts.override(cmd, opts)
	end

	local interactive = opts.interactive ~= false
	local auto_insert = opts.auto_insert or (opts.auto_insert == nil and interactive)
	local start_insert = opts.start_insert or (opts.start_insert == nil and interactive)
	local auto_close = opts.auto_close or (opts.auto_close == nil and interactive)
	local on_buf = opts.win and opts.win.on_buf
	local on_win = opts.win and opts.win.on_win

	---@param self terminal
	opts.win.on_buf = function(self)
		self.cmd = cmd
		vim.b[self.buf].core_terminal = { cmd = cmd, id = id, cwd = opts.cwd, env = opts.env }
		if on_buf then
			on_buf(self)
		end
	end

	---@param self terminal
	opts.win.on_win = function(self)
		if start_insert and vim.api.nvim_get_current_buf() == self.buf then
			vim.cmd.startinsert()
		end
		if on_win then
			on_win(self)
		end
	end

	local terminal = Win(opts.win) --[[@as terminal]]
	local tid = registry.id(cmd, opts)
	registry.set(tid, terminal)

	if auto_insert then
		terminal:on("BufEnter", function()
			vim.cmd.startinsert()
		end, { buf = true })
	end

	if auto_close then
		terminal:on("TermClose", function()
			if type(vim.v.event) == "table" and vim.v.event.status ~= 0 then
				vim.notify(
					"Terminal exited with code " .. vim.v.event.status .. ".\nCheck for any errors.",
					vim.log.levels.ERROR
				)
				return
			end
			terminal:close()
			vim.cmd.checktime()
		end, { buf = true })
	end

	terminal:on("ExitPre", function()
		terminal:close()
	end)

	terminal:on("BufWipeout", function()
		registry.set(tid, nil)
		vim.schedule(function()
			terminal:close()
		end)
	end, { buf = true })

	terminal:show()
	vim.api.nvim_buf_call(terminal.buf, function()
		jobstart(cmd or util.parse(opts.shell or vim.o.shell), {
			cwd = opts.cwd,
			env = opts.env,
			term = true,
		})
	end)

	vim.cmd("noh")
	return terminal
end

---@param terminal terminal
---@param opts? terminal.Opts
---@return boolean
function M.update_win(terminal, opts)
	if not opts or not opts.win then
		return false
	end

	local position = terminal.opts.position
	local target = opts.win.position or position
	local win_opts = vim.deepcopy(opts.win)
	if (target == "left" or target == "right") and win_opts.width == nil then
		win_opts.width = 0.3
	end
	terminal.opts = Win.resolve(terminal.opts, target == "float" and "float" or "split", win_opts)
	local changed = position ~= terminal.opts.position
	if changed then
		local vertical = terminal.opts.position == "left" or terminal.opts.position == "right"
		terminal.opts.wo.winfixheight = not vertical
		terminal.opts.wo.winfixwidth = vertical
	end
	return changed
end

return M
