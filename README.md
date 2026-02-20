# blink-cmp-tmux

Tmux command completion source for
[blink.cmp](https://github.com/saghen/blink.cmp).

<img width="1920" height="1200" alt="blink-cmp-tmux preview" src="https://github.com/user-attachments/assets/d7b0683b-6e00-4d75-a169-048bf4d80860" />

## Features

- Completes tmux commands with full usage signatures
- Includes alias information for commands
- Shows man page descriptions in documentation

## Requirements

- Neovim 0.10.0+
- [blink.cmp](https://github.com/saghen/blink.cmp)
- tmux

## Installation

Install via [luarocks](https://luarocks.org/modules/barrettruth/blink-cmp-tmux):

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
