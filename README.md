# blink-cmp-tmux

Tmux command completion source for
[blink.cmp](https://github.com/saghen/blink.cmp).

> [!NOTE]
> Due to GitHub's historic unreliability, development, issues, and pull requests
> have moved to
> [Forgejo](https://git.barrettruth.com/barrettruth/blink-cmp-tmux). See
> `:help blink-cmp-tmux-forgejo` for canonical project links.

![blink-cmp-tmux preview](https://github.com/user-attachments/assets/d7b0683b-6e00-4d75-a169-048bf4d80860)

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
  'https://git.barrettruth.com/barrettruth/blink-cmp-tmux',
})
```

Or via [luarocks](https://luarocks.org/modules/barrettruth/blink-cmp-tmux):

```
luarocks install blink-cmp-tmux
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
