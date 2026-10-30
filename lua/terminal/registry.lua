local M = {}

---@type table<string, terminal>
local terminals = setmetatable({}, { __mode = "v" })

---@param cmd? string|string[]
---@param opts? terminal.Opts
---@return string
function M.id(cmd, opts)
	opts = opts or {}
	return vim.inspect({
		cmd = type(cmd) == "table" and cmd or { cmd },
		cwd = opts.cwd or vim.fn.getcwd(0),
		env = opts.env,
		count = opts.count or vim.v.count1,
	})
end

---@param id string
---@return terminal?
function M.get(id)
	return terminals[id]
end

---@param id string
---@param terminal terminal?
function M.set(id, terminal)
	terminals[id] = terminal
end

---@return terminal[]
function M.list()
	local ret = {}
	for _, terminal in pairs(terminals) do
		if terminal:buf_valid() then
			ret[#ret + 1] = terminal
		end
	end
	table.sort(ret, function(a, b)
		return a.buf < b.buf
	end)
	return ret
end

return M
