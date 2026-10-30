local M = {}

---@param Win win
function M.setup(Win)
	Win.style.add("terminal", {
		bo = {
			filetype = "core_terminal",
		},
		wo = {
			winbar = "",
		},
		stack = true,
		keys = {
			q = "hide",
			gf = function(self)
				local cfile = vim.fn.expand("<cfile>")
				if type(cfile) == "table" then
					cfile = cfile[1] or ""
				end

				local file = vim.fn.findfile(cfile, "**")
				if file == "" then
					vim.notify("No file under cursor", vim.log.levels.WARN)
				else
					self:hide()
					vim.schedule(function()
						vim.cmd.edit(file)
					end)
				end
			end,
			term_normal = {
				"<esc>",
				function(self)
					self.meta.esc_timer = self.meta.esc_timer or vim.uv.new_timer()
					if self.meta.esc_timer:is_active() then
						self.meta.esc_timer:stop()
						vim.cmd("stopinsert")
					else
						self.meta.esc_timer:start(200, 0, function() end)
						return "<esc>"
					end
				end,
				mode = "t",
				expr = true,
				desc = "Double escape to normal mode",
			},
		},
	})
end

return M
