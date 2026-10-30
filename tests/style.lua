vim.opt.runtimepath:prepend(vim.fn.getcwd())
vim.opt.runtimepath:prepend(vim.fn.getcwd() .. "/../win.nvim")

local jobstart = vim.fn.jobstart
---@diagnostic disable-next-line: duplicate-set-field
vim.fn.jobstart = function()
	local channel = vim.api.nvim_open_term(0, {})
	vim.b.term_title = "term://~/project//123:/usr/bin/zsh"
	return channel
end

local ok, err = pcall(function()
	local Terminal = require("terminal")
	assert(vim.deep_equal(Terminal.parse([[cmd "two words" "a\"b" "c\\d"]]), {
		"cmd",
		"two words",
		'a"b',
		"c\\d",
	}))
	assert(vim.deep_equal(Terminal.parse("cmd trailing\\"), { "cmd", "trailing\\" }))
	local args = { "cmd", "two words" }
	assert(Terminal.parse(args) == args)

	---@param terminal terminal
	---@param expected string
	local function check(terminal, expected)
		assert(vim.wo[terminal.win].winbar == expected, "unexpected terminal winbar")
	end

	---@param opts terminal.Opts
	---@return terminal
	local function open(opts)
		return assert(Terminal.open(nil, opts))
	end

	for count, position in ipairs({ "bottom", "top", "left", "right", "float" }) do
		local terminal = open({ count = count, interactive = false, win = { position = position } })
		check(terminal, "")
		local buf = terminal.buf
		terminal:hide()
		terminal:show()
		assert(terminal.buf == buf)
		check(terminal, "")
		terminal:close()
	end

	local opts = { count = 10, interactive = false, win = { position = "bottom" } }
	local original = vim.deepcopy(opts)
	local terminal = open(opts)
	assert(vim.deep_equal(opts, original), "caller options were mutated")
	local buf = terminal.buf
	for _, position in ipairs({ "float", "right", "bottom" }) do
		Terminal.focus(nil, { count = 10, win = { position = position } })
		assert(terminal:valid() and terminal.buf == buf)
		check(terminal, "")
	end
	terminal:close()

	Terminal.setup({ count = 11, cwd = vim.fn.getcwd(), win = { wo = { winbar = "Setup title" } } })
	terminal = assert(Terminal.get(nil, { interactive = false }), "setup reuse options should create a terminal")
	check(terminal, "Setup title")
	terminal:close()
	terminal = open({ count = 12, interactive = false, win = { wo = { winbar = "Custom title" } } })
	check(terminal, "Custom title")
	Terminal.focus(nil, { count = 12, win = { position = "float" } })
	check(terminal, "Custom title")
	terminal:close()
end)

vim.fn.jobstart = jobstart
assert(ok, err)
print("Terminal style checks passed")
