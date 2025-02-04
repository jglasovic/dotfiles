local completion = require('mini.completion')


local replace_termcodes = function(code)
  return vim.api.nvim_replace_termcodes(code, true, true, true)
end

local keys = {
  ['cr']        = replace_termcodes('<CR>'),
  ['ctrl-y']    = replace_termcodes('<C-y>'),
  ['ctrl-y_cr'] = replace_termcodes('<C-y><CR>'),
  ['esc']       = replace_termcodes('<ESC>'),
  ['ctrl-e']    = replace_termcodes('<C-e>'),
  ['ctrl-x-o']  = replace_termcodes('<C-x><C-o>'),
  ['ctrl-x-n']  = replace_termcodes('<C-x><C-n>'),
  ['ctrl-x-u']  = replace_termcodes('<C-x><C-u>'),
}

local fallback_action = function()
  -- sql
  if vim.fn.index({ 'sql', 'mysql', 'plsql' }, vim.bo.filetype) >= 0 then
    -- use completefunc
    return vim.api.nvim_feedkeys(keys['ctrl-x-u'], 'n', false)
  end
  return vim.api.nvim_feedkeys(keys['ctrl-x-n'], 'n', false)
end

local cr_action = function()
  if vim.fn.pumvisible() ~= 0 then
    -- If popup is visible, confirm selected item or add new line otherwise
    local item_selected = vim.fn.complete_info()['selected'] ~= -1
    return item_selected and keys['ctrl-y'] or keys['ctrl-y_cr']
  end
  -- If popup is not visible, use plain `<CR>`
  return keys['cr']
end

local esc_action = function()
  if vim.fn.pumvisible() ~= 0 then
    -- If popup is visible and item selected, reset
    local item_selected = vim.fn.complete_info()['selected'] ~= -1
    return item_selected and keys['ctrl-e'] or keys['esc']
  end
  -- If popup is not visible, use plain `<ESC>`
  return keys['esc']
end

vim.keymap.set('i', '<Tab>', [[pumvisible() ? "\<C-n>" : "\<Tab>"]], { expr = true })
vim.keymap.set('i', '<S-Tab>', [[pumvisible() ? "\<C-p>" : "\<Tab>"]], { expr = true })
vim.keymap.set('i', '<CR>', cr_action, { expr = true })
vim.keymap.set('i', '<ESC>', esc_action, { expr = true })

completion.setup({
  lsp_completion = {
    source_func = 'omnifunc',
    auto_setup = false,
    -- process_items = function(items) print(items) end
    process_items = completion.default_process_items
  },
  fallback_action = fallback_action,
})
