local M = {}

function M.check()
  vim.health.start('blink-cmp-tmux')

  local ok = pcall(require, 'blink.cmp')
  if ok then
    vim.health.ok('blink.cmp is installed')
  else
    vim.health.error('blink.cmp is not installed')
  end

  local bin = vim.fn.exepath('tmux')
  if bin ~= '' then
    vim.health.ok('tmux executable found: ' .. bin)
  else
    vim.health.error('tmux executable not found')
    return
  end

  local result = vim.system({ 'tmux', 'list-commands' }):wait()
  if result.code == 0 and result.stdout and result.stdout ~= '' then
    vim.health.ok('tmux list-commands produces output')
  else
    vim.health.warn('tmux list-commands failed (completions will be unavailable)')
  end

  local man_bin = vim.fn.exepath('man')
  if man_bin ~= '' then
    vim.health.ok('man executable found: ' .. man_bin)
  else
    vim.health.warn('man executable not found (command descriptions will be unavailable)')
  end
end

return M
