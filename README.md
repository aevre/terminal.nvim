# terminal.nvim

A standalone terminal window manager for Neovim, built on [win.nvim](https://codeberg.org/aevre/win.nvim).

## Installation

```lua
{
  "https://codeberg.org/aevre/terminal.nvim",
  dependencies = { "https://codeberg.org/aevre/win.nvim" },
}
```

## Usage

```lua
local terminal = require("terminal")
terminal.toggle()
terminal.toggle({ "git", "status" })
terminal.focus(nil, { win = { position = "float", border = "rounded" } })
```

The module provides `open`, `get`, `list`, `toggle`, `focus`, `parse`, and `colorize`. Configure defaults with `require("terminal").setup(opts)`.
