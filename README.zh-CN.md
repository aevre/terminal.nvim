# terminal.nvim

一个独立的 Neovim 终端管理插件。它基于 [win.nvim](https://github.com/aevre/win.nvim)，创建可复用的浮动终端或分屏终端窗口。

[English](README.md)

## 环境要求

- Neovim 0.10 或更新版本。
- [win.nvim](https://github.com/aevre/win.nvim)。

## 安装

同时托管于 Codeberg：<https://codeberg.org/aevre/terminal.nvim> 和 GitHub：<https://github.com/aevre/terminal.nvim>。

使用 lazy.nvim：

```lua
{
  "https://github.com/aevre/terminal.nvim",
  dependencies = {
    "https://github.com/aevre/win.nvim",
  },
  opts = {},
}
```

`terminal.nvim` 与 `win.nvim` 是两个独立插件。依赖关系显式声明，以确保配置 terminal 时窗口模块已经可用。

## 使用

```lua
local terminal = require("terminal")

-- 复用或创建默认终端。
terminal.toggle()

-- 复用由命令标识的终端。
terminal.toggle({ "git", "status" })

-- 使用本次调用的窗口配置打开终端。
terminal.open(nil, {
  win = { position = "float", border = "rounded" },
})

-- 聚焦已有终端，不存在时创建。
terminal.focus("lazygit")

-- 选择一个已打开的终端。
terminal.select()
```

命令可以是字符串或参数数组。插件会根据命令、工作目录、环境变量和 count 复用已有终端。复用终端时传入不同的 `win.position`，会将原终端 buffer 和进程切换到新布局。

## 配置

使用 `setup()` 设置默认值。传给 `open()`、`toggle()` 或 `focus()` 的选项会覆盖默认值。

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

常用选项：

| 选项 | 说明 |
| --- | --- |
| `win` | `win.nvim` 窗口配置，默认使用 `terminal` 样式。 |
| `shell` | 未指定命令时使用的 shell，默认为 `vim.o.shell`。 |
| `cwd` | 进程工作目录。 |
| `env` | 传给进程的环境变量。 |
| `count` | 用于复用的终端槽位，默认为 `vim.v.count1`。 |
| `start_insert` | 进程打开后进入插入模式。 |
| `auto_insert` | 进入终端 buffer 时进入插入模式。 |
| `auto_close` | 进程成功退出后关闭终端窗口。 |
| `interactive` | 同时启用上述三个交互选项，默认为 `true`。 |
| `override` | 替换内置终端实现的函数。 |

终端窗口使用由 `win.nvim` 注册的 `terminal` 样式，包含终端 filetype、分屏堆叠、双击 Escape 和 `q` 隐藏等行为。

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

- `open()` 始终创建新的终端窗口。
- `get()` 返回匹配的终端对象以及是否新建。
- `list()` 返回当前仍有效的终端对象。
- `select()` 使用 `vim.ui.select()` 选择终端，并按其原窗口样式聚焦。
- `toggle()` 隐藏已有终端，否则创建终端。
- `focus()` 聚焦终端；若已经聚焦则隐藏，否则创建终端。
- `tid()` 计算终端复用标识。
- `parse()` 将 shell 字符串解析为参数数组，并保留引号中的空格和转义字符。
- `colorize()` 为当前 buffer 应用终端彩色输出，适用于命令管道场景。

每个终端对象都是 `win.nvim` 窗口对象，并额外包含 terminal 的 `cmd` 和 `opts` 字段。

## 开发

在仓库根目录运行 `make check`。带 guard 的 `plugin/terminal.lua` 入口只应用默认配置，终端行为保留在 `lua/terminal/`。插件管理器随后以用户选项再次调用 `setup()` 时必须保持安全。
