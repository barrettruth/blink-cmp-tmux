---@class blink-cmp-tmux : blink.cmp.Source
local M = {}

---@type blink.cmp.CompletionItem[]?
local cache = nil
local loading = false
---@type {ctx: blink.cmp.Context, callback: fun(response: blink.cmp.CompletionResponse)}[]
local pending = {}

function M.new()
  return setmetatable({}, { __index = M })
end

---@return boolean
function M.enabled()
  return vim.bo.filetype == 'tmux'
end

---@param man_stdout string
---@param names_stdout string
---@return table<string, string>
local function parse_descriptions(man_stdout, names_stdout)
  local lines = {}
  for line in (man_stdout .. '\n'):gmatch('(.-)\n') do
    lines[#lines + 1] = line
  end

  local cmds = {}
  for name in names_stdout:gmatch('[^\n]+') do
    cmds[name] = true
  end

  local defs = {}
  for i, line in ipairs(lines) do
    local cmd = line:match('^       ([a-z][a-z-]+)')
    if cmd and cmds[cmd] then
      local rest = line:sub(8 + #cmd)
      if rest == '' or rest:match('^%s+%[') or rest:match('^%s%s+') then
        defs[#defs + 1] = { line = i, cmd = cmd }
      end
    end
  end

  local descs = {}
  for idx, def in ipairs(defs) do
    local block_end = (defs[idx + 1] and defs[idx + 1].line or #lines) - 1
    local j = def.line + 1
    while j <= block_end do
      local l = lines[j]
      if l:match('^%s+%(alias:') or vim.trim(l) == '' then
        j = j + 1
      elseif l:match('^               ') then
        local stripped = vim.trim(l)
        if stripped == '' or stripped:match('[%[%]]') then
          j = j + 1
        else
          break
        end
      else
        break
      end
    end

    local desc_lines = {}
    for k = j, block_end do
      desc_lines[#desc_lines + 1] = lines[k]
    end
    local paragraphs = { {} }
    for _, dl in ipairs(desc_lines) do
      local stripped = vim.trim(dl)
      if stripped == '' then
        if #paragraphs[#paragraphs] > 0 then
          paragraphs[#paragraphs + 1] = {}
        end
      else
        local para = paragraphs[#paragraphs]
        para[#para + 1] = stripped
      end
    end
    local parts = {}
    for _, para in ipairs(paragraphs) do
      if #para > 0 then
        parts[#parts + 1] = table.concat(para, ' ')
      end
    end
    local desc = table.concat(parts, '\n\n')
    desc = desc:gsub(string.char(0xe2, 0x80, 0x90) .. ' ', '')
    desc = desc:gsub('  +', ' ')
    if desc ~= '' then
      descs[def.cmd] = desc
    end
  end
  return descs
end

---@param output string
---@param descs table<string, string>
---@return blink.cmp.CompletionItem[]
local function parse(output, descs)
  local Kind = require('blink.cmp.types').CompletionItemKind
  local items = {}
  for line in output:gmatch('[^\n]+') do
    local name, alias = line:match('^([a-z-]+)%s+%(([a-z-]+)%)')
    if not name then
      name = line:match('^([a-z-]+)')
    end
    if name then
      local doc_parts = {}
      if alias then
        doc_parts[#doc_parts + 1] = ('**alias**: `%s`\n'):format(alias)
      end
      doc_parts[#doc_parts + 1] = '```\n' .. line .. '\n```'
      if descs[name] then
        doc_parts[#doc_parts + 1] = '\n---\n\n' .. descs[name]
      end
      items[#items + 1] = {
        label = name,
        kind = Kind.Keyword,
        documentation = {
          kind = 'markdown',
          value = table.concat(doc_parts),
        },
      }
    end
  end
  return items
end

---@param ctx blink.cmp.Context
---@param callback fun(response: blink.cmp.CompletionResponse)
local function respond(ctx, callback)
  local before = ctx.line:sub(1, ctx.cursor[2])
  if before:match('^%s*[a-z-]*$') then
    callback({
      is_incomplete_forward = false,
      is_incomplete_backward = false,
      items = cache,
    })
  else
    callback({ items = {} })
  end
end

---@param ctx blink.cmp.Context
---@param callback fun(response: blink.cmp.CompletionResponse)
---@return fun()
function M:get_completions(ctx, callback)
  if cache then
    respond(ctx, callback)
    return function() end
  end

  pending[#pending + 1] = { ctx = ctx, callback = callback }
  if not loading then
    loading = true
    local man_out, names_out, cmds_out
    local remaining = 3

    local function on_all_done()
      remaining = remaining - 1
      if remaining > 0 then
        return
      end
      vim.schedule(function()
        local ok, descs = pcall(parse_descriptions, man_out, names_out)
        if not ok then
          descs = {}
        end
        cache = parse(cmds_out, descs)
        loading = false
        for _, p in ipairs(pending) do
          respond(p.ctx, p.callback)
        end
        pending = {}
      end)
    end

    vim.system({ 'bash', '-c', 'MANWIDTH=80 man -P cat tmux 2>/dev/null' }, {}, function(result)
      man_out = result.stdout or ''
      on_all_done()
    end)
    vim.system({ 'tmux', 'list-commands', '-F', '#{command_list_name}' }, {}, function(result)
      names_out = result.stdout or ''
      on_all_done()
    end)
    vim.system({ 'tmux', 'list-commands' }, {}, function(result)
      cmds_out = result.stdout or ''
      on_all_done()
    end)
  end
  return function() end
end

return M
