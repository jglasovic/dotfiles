-- formatter settings: { <formatter name> : config }
local formatter_settings_map = {
	black = {},
	ruff = {},
	phpcsfixer = {},
	-- prettier = {},
	sqlfluff = { extra_args = { "--dialect", "postgres" } },
	stylua = {},
}

-- linter settings: { <linter name> : config }
local linter_settings_map = {
	ruff = {},
	mypy = {},
	phpcs = {},
	phpstan = {},
	-- eslint = {
	-- 	filter = function(diagnostic)
	-- 		return diagnostic.code ~= "prettier/prettier"
	-- 	end,
	-- },
	sqlfluff = { extra_args = { "--dialect", "postgres" } },
}

local get_source = function(type, name)
	local ls_source = type .. "." .. name
	for _, source_prefix in ipairs({ "none-ls.", "null-ls.builtins." }) do
		local path = source_prefix .. ls_source
		local success_lsp_config, source = pcall(require, path)
		if success_lsp_config then
			return source
		end
	end
end

local build_sources = function()
	local sources = {}
	for linter, config in pairs(linter_settings_map) do
		local source = get_source("diagnostics", linter)
		if source then
			table.insert(sources, source.with(config))
		end
	end
	for formatter, config in pairs(formatter_settings_map) do
		local source = get_source("formatting", formatter)
		if source then
			table.insert(sources, source.with(config))
		end
	end
	return sources
end

require("null-ls").setup({
	sources = build_sources(),
	border = "single",
	-- debug = true
})
