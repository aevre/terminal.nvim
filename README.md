# terminal.nvim

A standalone terminal manager for Neovim. It creates reusable floating or split terminal windows and is built on [win.nvim](https://github.com/aevre/win.nvim).

[简体中文](README.zh-CN.md)

- [Installation](#installation)
- [Usage](#usage)
- [Configuration](#configuration)
- [API](#api)

## Requirements

- Neovim 0.10 or newer.
- [win.nvim](https://github.com/aevre/win.nvim).

## Installation

Available on Codeberg: <https://codeberg.org/aevre/terminal.nvim> and GitHub: <https://github.com/aevre/terminal.nvim>.

With lazy.nvim:

```lua
{
  "https://github.com/aevre/terminal.nvim",
  dependencies = {
    "https://github.com/aevre/win.nvim",
  },
  opts = {},
}
```

`terminal.nvim` is a separate plugin from `win.nvim`; the dependency is declared explicitly so the window API is available before terminals are configured.

## Usage

```lua
local terminal = require("terminal")

-- Reuse or create the default terminal.
terminal.toggle()

-- Reuse a terminal identified by its command.
terminal.toggle({ "git", "status" })

-- Open a terminal with per-call window options.
terminal.open(nil, {
  win = { position = "float", border = "rounded" },
})

-- Focus an existing terminal, or create it when necessary.
terminal.focus("lazygit")

-- Select an open terminal.
terminal.select()
```

The command can be a string or an argument list. Terminals are reused according to command, working directory, environment, and count. Passing a different `win.position` when reusing a terminal moves the existing terminal buffer and process to that layout.

## Configuration

Use `setup()` to define defaults. Options passed to `open()`, `toggle()`, or `focus()` override these defaults.

```lua
require("terminal").setup({
  win = {
    position = "bottom",
    height = 12,
    border = "top",
  },
  shell = vim.o.shell,
  interactive = true,
})
```

Important options:

| Option | Description |
| --- | --- |
| `win` | A `win.nvim` window configuration. The default uses the `terminal` style. |
| `shell` | Shell command used when no command is supplied. Defaults to `vim.o.shell`. |
| `cwd` | Working directory for the process. |
| `env` | Environment variables passed to the process. |
| `count` | Terminal slot used for reuse. Defaults to `vim.v.count1`. |
| `start_insert` | Start insert mode when the process opens. |
| `auto_insert` | Start insert mode when entering the terminal buffer. |
| `auto_close` | Close the terminal window after a successful process exit. |
| `interactive` | Shortcut enabling `start_insert`, `auto_insert`, and `auto_close`; defaults to `true`. |
| `override` | Function that replaces the built-in terminal implementation. |

Terminal windows use the `terminal` style registered with `win.nvim`. The style includes terminal filetype, stacked splits, a double-escape mapping, and `q` to hide.

## API

```lua
local terminal = require("terminal")

terminal.open(cmd?, opts?)
terminal.get(cmd?, opts?)
terminal.list()
terminal.select()
terminal.toggle(cmd?, opts?)
terminal.focus(cmd?, opts?)
terminal.tid(cmd?, opts?)
terminal.parse(command)
terminal.colorize()
```

- `open()` always creates a terminal window.
- `get()` returns the matching terminal and whether it was created.
- `list()` returns currently valid terminal objects.
- `select()` uses `vim.ui.select()` to focus an open terminal in its original window style.
- `toggle()` hides an existing terminal or opens it.
- `focus()` focuses an existing terminal, hides it when already focused, or opens it.
- `tid()` calculates the reuse identifier.
- `parse()` converts a shell string into an argument list, preserving quoted spaces and escaped characters.
- `colorize()` applies terminal color output to the current buffer when used by a command pipeline.

Each terminal object is a `win.nvim` window object with terminal-specific `cmd` and `opts` fields.

## Development

Run `make check` from the repository root. The guarded `plugin/terminal.lua` entrypoint only applies defaults; terminal behavior stays under `lua/terminal/`. Keep `setup()` safe when a plugin manager calls it again with user options.
