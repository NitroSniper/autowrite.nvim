# autowrite.nvim

![preview](https://github.com/NitroSniper/autowrite.nvim/blob/main/assets/preview.gif?raw=true)

## What is autowrite.nvim
`autowrite.nvim` automatically save buffers on text changes, allowing you to focus on writing while tools receive the latest changes you make to a file


## Table of Contents

- [Installation](#installation)
- [Usage](#usage)
- [Difference with Autowrite](#difference-with-autowrite)
- [Roadmap](#roadmap)
- [Acknowledgements](#acknowledgements)


## Installation

Using [lazy.nvim](https://github.com/folke/lazy.nvim)
```lua
{
  'NitroSniper/autowrite.nvim',
  opts = {
    -- Default Options

    -- creates :ToggleAutowrite, :EnableAutowrite, :DisableAutowrite command
    create_commands = true,
    -- log any info notifications to the user
    verbose_info = true,
    -- HACK Option: Fix Undo bug that happens on lazy, this is false by default
    undo_hack = true,
  },
}

```
I haven't tested it with other package managers but if any bug occurs please send in an issue
## Usage

If you prefer using mappings instead of commands

```lua
vim.keymap.set('n', '<space>aw', require("autowrite").ToggleAutowrite)
```

### Exposed Commands for use
 - `ToggleAutowrite` - toggles `autowrite` on and off on current buffer
 - `EnableAutowrite` - turns on `autowrite` on current buffer
 - `DisableAutowrite` - turns off `autowrite` on current buffer

## Difference with Autowrite
 - `autowrite.nvim` works on individual buffers whereas 'Autowrite.vim' only works globally
 - `Autowrite.vim` doesn't work well with `lazy.nvim` as undo doesn't work correctly, `autowrite.nvim` has a hack option which resolves this if you are installing via `lazy`
 - `autowrite.nvim` has lua functions you can call instead if you don't want to have commands enabled 

## 

## Roadmap
Features I want to implement in the future if I can

- Implement a global switch alongside working in buffers
- file extensions filtering 

## Acknowledgements
 - [Autowrite.vim](https://github.com/beauwilliams/AutoWrite.vim) - Predecessor of this plugin

