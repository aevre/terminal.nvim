---@class terminal.Configuration
local M = {}

---@type terminal.Config
local defaults = {
	win = {
		style = "terminal",
		wo = {
			winhighlight = "Normal:NormalFloat,NormalNC:NormalFloat,FloatBorder:FloatBorder,FloatTitle:FloatTitle",
		},
	},
}

---@type terminal.Config
local config = {}

---@param opts? terminal.Config
---@return terminal.Config
function M.setup(opts)
	config = vim.tbl_deep_extend("force", config, vim.deepcopy(opts or {}))
	return M.get()
end

---@param opts? terminal.Opts
---@return terminal.Opts
function M.get(opts)
	local ret = vim.tbl_deep_extend("force", vim.deepcopy(defaults), vim.deepcopy(config), vim.deepcopy(opts or {}))
	---@cast ret terminal.Opts
	return ret
end

return M
