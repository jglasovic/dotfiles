-- formatter settings: { <formatter name> : config }
local formatter_settings_map = {
  black = {},
  ruff = {},
  phpcsfixer = {},
  prettier = {},
}

-- linter settings: { <linter name> : config }
local linter_settings_map = {
  ruff = {},
  mypy = {},
  phpcs = {},
  phpstan = {},
  eslint = {}
}

local get_source = function(type, name)
  local ls_source = '-ls.' .. type .. '.' .. name
  for _, source_prefix in ipairs({ "none", "null" }) do
    local success_lsp_config, source = pcall(require, source_prefix .. ls_source)
    if success_lsp_config then
      return source
    end
  end
end

local build_sources = function()
  local sources = {}
  for linter, config in pairs(linter_settings_map) do
    local source = get_source('diagnostics', linter)
    if source then
      table.insert(sources, source.with(config))
    end
  end
  for formatter, config in pairs(formatter_settings_map) do
    local source = get_source('formatting', formatter)
    if source then
      table.insert(sources, source.with(config))
    end
  end
  return sources
end

-- format on save
local on_attach = function(client, bufnr)
  local augroup = vim.api.nvim_create_augroup("LspFormatting", { clear = true })
  if client.supports_method("textDocument/formatting") then
    vim.api.nvim_clear_autocmds({ group = augroup, buffer = bufnr })
    vim.api.nvim_create_autocmd("BufWritePre", {
      group = augroup,
      buffer = bufnr,
      callback = function()
        vim.lsp.buf.format({ async = false })
      end,
    })
  end
end

require("null-ls").setup({
  on_attach = on_attach,
  sources = build_sources(),
  border = "single",
  -- debug = true
})
