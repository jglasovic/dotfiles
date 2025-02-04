vim.g.copilot_enabled = false -- disable copilot suggestions by default

local select = require("CopilotChat.select")

require("CopilotChat").setup {
  selection = function(source)
    return select.visual(source)
  end,
  mappings = {
    complete = {
      insert = '<S-CR>',
    },
    close = {
      normal = '<C-w>',
    },
    reset = {
      normal = '<C-c>',
      insert = '<C-c>',
    },
    submit_prompt = {
      normal = '<CR>',
      insert = '<C-s>',
    },
    toggle_sticky = {
      detail = 'Makes line under cursor sticky or deletes sticky line.',
      normal = 'gr',
    },
    accept_diff = {
      normal = '<C-y>',
      insert = '<C-y>',
    },
    jump_to_diff = {
      normal = 'gj',
    },
    quickfix_diffs = {
      normal = 'gq',
    },
    yank_diff = {
      normal = 'gy',
      register = '"',
    },
    show_diff = {
      normal = 'gd',
    },
    show_info = {
      normal = 'gi',
    },
    show_context = {
      normal = 'gc',
    },
    show_help = {
      normal = 'gh',
    },
  },
}

vim.api.nvim_set_keymap('n', '<leader>cc', ':CopilotChatToggle<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>cd', ":delmarks < ><CR>", { noremap = true, silent = true })
