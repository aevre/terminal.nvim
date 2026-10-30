local Win = require("win")
local config = require("terminal.config")
local registry = require("terminal.registry")
local style = require("terminal.style")
local Terminal = require("terminal.terminal")
local util = require("terminal.util")

---@class terminal.Module
---@overload fun(cmd?: string|string[], opts?: terminal.Opts): terminal
---@type terminal.Module
local M = setmetatable({}, {
	__call = function(t, ...)
		return t.toggle(...)
	end,
})

M.meta = {
	desc = "Create and toggle floating/split terminals",
}

style.setup(Win)

---@param opts? terminal.Config
---@return terminal.Module
function M.setup(opts)
	config.setup(opts)
	return M
end

--- Open a new terminal window.
---@param cmd? string|string[]
---@param opts? terminal.Opts
---@return terminal?
function M.open(cmd, opts)
	return Terminal.open(cmd, config.get(opts))
end

--- Get a terminal id based on command, cwd, environment, and count.
---@param cmd? string|string[]
---@param opts? terminal.Opts
---@return string
function M.tid(cmd, opts)
	return registry.id(cmd, config.get(opts))
end

--- Get or create a terminal window.
---@param cmd? string|string[]
---@param opts? terminal.Opts
---@return terminal? terminal, boolean? created
function M.get(cmd, opts)
	local resolved = config.get(opts)
	local id = M.tid(cmd, resolved)
	local terminal = registry.get(id)
	local created = false
	if not (terminal and terminal:buf_valid()) and resolved.create ~= false then
		local ret = Terminal.open(cmd, resolved)
		if ret then
			ret:on("BufWipeout", function()
				registry.set(id, nil)
			end, { buf = true })
		end
		terminal = registry.get(id)
		assert(terminal, "Terminal was not created")
		created = true
	end
	return terminal, created
end

---@return terminal[]
function M.list()
	return registry.list()
end

--- Select and focus an open terminal.
function M.select()
	---@type terminal.SelectItem[]
	local items = {}
	for i, terminal in ipairs(M.list()) do
		local title = vim.b[terminal.buf].term_title
		local cmd = terminal.cmd or vim.o.shell
		items[i] = {
			index = i,
			terminal = terminal,
			label = title and title ~= "" and not title:find("^term://") and title
				or (type(cmd) == "table" and table.concat(cmd, " ") or cmd),
		}
	end

	vim.ui.select(items, {
		prompt = "Terminals",
		format_item = function(item)
			return item.index .. ". " .. item.label
		end,
	}, function(item)
		if item then
			item.terminal:show():focus()
		end
	end)
end

--- Toggle a terminal window.
---@param cmd? string|string[]
---@param opts? terminal.Opts
---@return terminal
function M.toggle(cmd, opts)
	local terminal, created = M.get(cmd, opts)
	terminal = assert(terminal)
	if created then
		return terminal
	end

	if Terminal.update_win(terminal, opts) and terminal:valid() then
		terminal:hide()
	end
	terminal:toggle()
	return terminal
end

--- Focus a terminal window. If already focused, hide it.
---@param cmd? string|string[]
---@param opts? terminal.Opts
---@return terminal, boolean?
function M.focus(cmd, opts)
	local terminal, created = M.get(cmd, opts)
	local changed = terminal and not created and Terminal.update_win(terminal, opts)
	if terminal and changed and terminal:valid() then
		terminal:hide()
	elseif terminal and not created and vim.api.nvim_get_current_buf() == terminal.buf then
		terminal:hide()
		return terminal, created
	end
	terminal = assert(terminal)
	if not created then
		terminal:show():focus()
	end
	return terminal, created
end

M.parse = util.parse
M.colorize = util.colorize

return M
