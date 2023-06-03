local completion = require('mini.completion')

local fallback_action = function()
  if vim.fn.index({ 'sql', 'mysql', 'plsql' }, vim.bo.filetype) >= 0 then
    local keys = vim.api.nvim_replace_termcodes('<C-g><C-g><C-x><C-o>', true, true, true)
    return vim.api.nvim_feedkeys(keys, 'n', false)
  end
  local keys = vim.api.nvim_replace_termcodes('<C-g><C-g><C-x><C-n>', true, true, true)
  return vim.api.nvim_feedkeys(keys, 'n', false)
end

vim.keymap.set('i', '<Tab>', [[pumvisible() ? "\<C-n>" : "\<Tab>"]], { expr = true })
vim.keymap.set('i', '<S-Tab>', [[pumvisible() ? "\<C-p>" : "\<S-Tab>"]], { expr = true })
local keys = {
  ['cr']        = vim.api.nvim_replace_termcodes('<CR>', true, true, true),
  ['ctrl-y']    = vim.api.nvim_replace_termcodes('<C-y>', true, true, true),
  ['ctrl-y_cr'] = vim.api.nvim_replace_termcodes('<C-y><CR>', true, true, true),
}

local cr_action = function()
  if vim.fn.pumvisible() ~= 0 then
    -- If popup is visible, confirm selected item or add new line otherwise
    local item_selected = vim.fn.complete_info()['selected'] ~= -1
    return item_selected and keys['ctrl-y'] or keys['ctrl-y_cr']
  else
    -- If popup is not visible, use plain `<CR>`
    return keys['cr']
  end
end

vim.keymap.set('i', '<CR>', cr_action, { expr = true })

completion.setup({
  fallback_action = fallback_action
})

