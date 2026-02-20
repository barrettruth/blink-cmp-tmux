rockspec_format = '3.0'
package = 'blink-cmp-tmux'
version = 'scm-1'

source = {
  url = 'git+https://github.com/barrettruth/blink-cmp-tmux.git',
}

description = {
  summary = 'Tmux command completion source for blink.cmp',
  homepage = 'https://github.com/barrettruth/blink-cmp-tmux',
  license = 'MIT',
}

dependencies = {
  'lua >= 5.1',
}

test_dependencies = {
  'nlua',
  'busted >= 2.1.1',
}

test = {
  type = 'busted',
}

build = {
  type = 'builtin',
}
