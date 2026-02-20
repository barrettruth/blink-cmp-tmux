# blink-cmp-tmux

Tmux command completion source for
[blink.cmp](https://github.com/saghen/blink.cmp).

## Features

- Completes tmux commands with full usage signatures
- Includes alias information for commands
- Shows man page descriptions in documentation

## Requirements

- Neovim 0.10.0+
- [blink.cmp](https://github.com/saghen/blink.cmp)
- tmux

## Installation

Install via
[luarocks](https://luarocks.org/modules/barrettruth/blink-cmp-tmux):

```
luarocks install blink-cmp-tmux
```

Or with lazy.nvim:

```lua
{
  'saghen/blink.cmp',
  dependencies = {
    'barrettruth/blink-cmp-tmux',
  },
  opts = {
    sources = {
      default = { 'tmux' },
      providers = {
        tmux = {
          name = 'Tmux',
          module = 'blink-cmp-tmux',
        },
      },
    },
  },
}
```
