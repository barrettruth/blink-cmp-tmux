# blink-cmp-tmux

Tmux command completion source for
[blink.cmp](https://github.com/saghen/blink.cmp).

![blink-cmp-tmux preview](https://forge.barrettruth.com/attachments/c9f21e59-5ee2-4fcb-bf41-b6cd461e7017)

## Features

- Completes tmux commands with full usage signatures
- Includes alias information for commands
- Shows man page descriptions in documentation

## Requirements

- Neovim 0.10.0+
- [blink.cmp](https://github.com/saghen/blink.cmp)
- tmux

## Installation

With `vim.pack` (Neovim 0.12+):

```lua
vim.pack.add({
  'https://forge.barrettruth.com/barrettruth/blink-cmp-tmux',
})
```

Configure `blink.cmp`:

```lua
require('blink.cmp').setup({
  sources = {
    default = { 'tmux' },
    providers = {
      tmux = {
        name = 'Tmux',
        module = 'blink-cmp-tmux',
      },
    },
  },
})
```
