local helpers = require('spec.helpers')

local TMUX_COMMANDS = table.concat({
  'bind-key (bind) [-lnrN:T:] key command [arguments]',
  'display-message (display) [-aINpv] [-c target-client] [-d delay] [-t target-pane] [message]',
  'set-option (set) [-aFgopqsuUw] [-t target-pane] option [value]',
}, '\n')

local TMUX_NAMES = 'bind-key\ndisplay-message\nset-option\n'

local MAN_PAGE = table.concat({
  '       bind-key [-lnrN:T:] key command [arguments]',
  '             (alias: bind)',
  '',
  '             Bind a key to a command.',
  '',
  '       display-message [-aINpv] [-c target-client] [-d delay] [-t target-pane] [message]',
  '             (alias: display)',
  '',
  '             Display a message.',
  '',
  '       set-option [-aFgopqsuUw] [-t target-pane] option [value]',
  '             (alias: set)',
  '',
  '             Set a window option.',
}, '\n')

local function mock_system()
  local original_system = vim.system
  local original_schedule = vim.schedule
  ---@diagnostic disable-next-line: duplicate-set-field
  vim.system = function(cmd, _, on_exit)
    local result
    if cmd[1] == 'bash' then
      result = { stdout = MAN_PAGE, code = 0 }
    elseif cmd[1] == 'tmux' and cmd[2] == 'list-commands' then
      if cmd[3] == '-F' then
        result = { stdout = TMUX_NAMES, code = 0 }
      else
        result = { stdout = TMUX_COMMANDS, code = 0 }
      end
    else
      result = { stdout = '', code = 1 }
    end
    if on_exit then
      on_exit(result)
      return {}
    end
    return {
      wait = function()
        return result
      end,
    }
  end
  vim.schedule = function(fn)
    fn()
  end
  return function()
    vim.system = original_system
    vim.schedule = original_schedule
  end
end

describe('blink-cmp-tmux', function()
  local restore

  before_each(function()
    package.loaded['blink-cmp-tmux'] = nil
    restore = mock_system()
  end)

  after_each(function()
    if restore then
      restore()
    end
  end)

  describe('enabled', function()
    it('returns true for tmux filetype', function()
      local bufnr = helpers.create_buffer({}, 'tmux')
      local source = require('blink-cmp-tmux')
      assert.is_true(source.enabled())
      helpers.delete_buffer(bufnr)
    end)

    it('returns false for other filetypes', function()
      local bufnr = helpers.create_buffer({}, 'lua')
      local source = require('blink-cmp-tmux')
      assert.is_false(source.enabled())
      helpers.delete_buffer(bufnr)
    end)
  end)

  describe('get_completions', function()
    it('returns items with Keyword kind', function()
      local source = require('blink-cmp-tmux').new()
      local items
      source:get_completions({ line = '', cursor = { 1, 0 } }, function(response)
        items = response.items
      end)
      assert.is_not_nil(items)
      assert.equals(3, #items)
      for _, item in ipairs(items) do
        assert.equals(14, item.kind)
      end
    end)

    it('returns items on empty line', function()
      local source = require('blink-cmp-tmux').new()
      local items
      source:get_completions({ line = '', cursor = { 1, 0 } }, function(response)
        items = response.items
      end)
      assert.equals(3, #items)
    end)

    it('returns items when typing command prefix', function()
      local source = require('blink-cmp-tmux').new()
      local items
      source:get_completions({ line = 'bind', cursor = { 1, 4 } }, function(response)
        items = response.items
      end)
      assert.is_true(#items > 0)
    end)

    it('returns empty after command arguments', function()
      local source = require('blink-cmp-tmux').new()
      local items
      source:get_completions({ line = 'bind-key -n ', cursor = { 1, 12 } }, function(response)
        items = response.items
      end)
      assert.equals(0, #items)
    end)

    it('includes documentation with man page description', function()
      local source = require('blink-cmp-tmux').new()
      local items
      source:get_completions({ line = '', cursor = { 1, 0 } }, function(response)
        items = response.items
      end)
      local bind = vim.iter(items):find(function(item)
        return item.label == 'bind-key'
      end)
      assert.is_not_nil(bind)
      assert.is_not_nil(bind.documentation)
      assert.is_truthy(bind.documentation.value:find('Bind a key'))
    end)

    it('includes alias in documentation', function()
      local source = require('blink-cmp-tmux').new()
      local items
      source:get_completions({ line = '', cursor = { 1, 0 } }, function(response)
        items = response.items
      end)
      local bind = vim.iter(items):find(function(item)
        return item.label == 'bind-key'
      end)
      assert.is_truthy(bind.documentation.value:find('alias'))
    end)

    it('returns a cancel function', function()
      local source = require('blink-cmp-tmux').new()
      local cancel = source:get_completions({ line = '', cursor = { 1, 0 } }, function() end)
      assert.is_function(cancel)
    end)
  end)
end)
