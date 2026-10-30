---@class terminal: win
---@field cmd? string|string[]
---@field opts win.Config
---@overload fun(cmd?: string|string[], opts?: terminal.Opts): terminal

---@class terminal.Config
---@field win? win.Config|{}
---@field shell? string|string[] Shell used when no command is supplied. Defaults to `vim.o.shell`.
---@field override? fun(cmd?: string|string[], opts?: terminal.Opts): terminal?
---@field cwd? string
---@field count? integer
---@field env? table<string, string>
---@field interactive? boolean Shortcut for `start_insert`, `auto_close`, and `auto_insert` (default: true).
---@field start_insert? boolean Start insert mode when opening the terminal.
---@field auto_insert? boolean Start insert mode when entering the terminal buffer.
---@field auto_close? boolean Close the terminal buffer after a successful process exit.

---@class terminal.Opts: terminal.Config
---@field create? boolean Create a terminal in `get()` when none exists (default: true).

---@class terminal.SelectItem
---@field index integer
---@field terminal terminal
---@field label string
