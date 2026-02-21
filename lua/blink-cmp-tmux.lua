---@class blink-cmp-tmux : blink.cmp.Source
local M = {}

---@type blink.cmp.CompletionItem[]?
local cache = nil

function M.new()
  return setmetatable({}, { __index = M })
end

---@return boolean
function M.enabled()
  return vim.bo.filetype == 'tmux'
end

---@return table<string, string>
local function parse_descriptions()
  local result = vim.system({ 'bash', '-c', 'MANWIDTH=80 man -P cat tmux 2>/dev/null' }):wait()
  local stdout = result.stdout or ''
  local lines = {}
  for line in (stdout .. '\n'):gmatch('(.-)\n') do
    lines[#lines + 1] = line
  end

  local cmd_result = vim.system({ 'tmux', 'list-commands', '-F', '#{command_list_name}' }):wait()
  local cmds = {}
  for name in (cmd_result.stdout or ''):gmatch('[^\n]+') do
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
---@return fun()
function M:get_completions(ctx, callback)
  if not cache then
    local ok, descs = pcall(parse_descriptions)
    if not ok then
      descs = {}
    end
    local result = vim.system({ 'tmux', 'list-commands' }):wait()
    cache = parse(result.stdout or '', descs)
  end

  local before = ctx.line:sub(1, ctx.cursor[2])
  if before:match('^%s*[a-z-]*$') then
    callback({
      is_incomplete_forward = false,
      is_incomplete_backward = false,
      items = vim.deepcopy(cache),
    })
  else
    callback({ items = {} })
  end
  return function() end
end

return M
