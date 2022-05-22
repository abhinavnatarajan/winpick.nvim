# winpick

[![Codeberg CI](https://ci.codeberg.org/api/badges/gbrlsnchs/winpick.nvim/status.svg)](https://codeberg.org/gbrlsnchs/winpick.nvim/commits/branch/trunk)

![Example of how winpick works](https://i.imgur.com/4xACRUJ.png)

This is a very simple plugin to help with picking an open window. It basically has two functions:
`select` and `focus`.

If you only want to pick a window and focus it, use `focus`. It will return `true` if you in fact
chose a window.

Now, if you want to do fancier stuff, use `select`. If you in fact selected a window, it will return
the ID of the window you just selected, allowing you to manipulate it as you wish.

## Usage
```lua
local winpick = require("winpick")

local win = winpick.select()
print(win)

local has_focused = winpick.focus()
print(has_focused)
```

### Custom options
Options can be set in `setup` and also as first parameter of `select`:

| Option | Description | Default value |
|--------|-------------|---------------|
| `border` | Border style passed internally to `nvim_open_win`. | `"double"` |
| `buf_excludes` | Set of buffer options that help detecting buffers to avoid. Accepts either single values of lists of values. | `{ buftype = "quickfix" }` |
| `win_excludes` | Set of window options that help detecting windows to avoid. Accepts either single values of lists of values. | `{ previewwindow = true }` |
| `label_func` | Function to render labels for visual cues. Receives the label itself and the window ID.| Function that returns label and buffer name, if available. |

#### Example
```lua
local winpick = require("winpick")

winpick.setup({
	border = "none",
	buf_excludes = {
		buftype = { "quickfix", "terminal" },
		filetype = "NvimTree",
	},
	win_excludes = false, -- won't check window options
})

winpick.focus({
	border = "single",
	buf_excludes = false,
	label_func = function(label, win)
		return string.format("%s at %d", label, win)
	end,
})
```

Scoped options can also be passed to `winpick.select` and `winpick.focus`, which will override the
global config or fall back to it altogether in case nothing is passed.
