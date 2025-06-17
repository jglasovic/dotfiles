local mason = require("mason")
local mason_registry = require("mason-registry")

mason.setup({ ui = { border = "single" } })
vim.keymap.set("n", "<leader>m", "<CMD>Mason<CR>", { silent = true })

local require_installed = {
	"basedpyright",
	"gopls",
	"intelephense",
	"js-debug-adapter",
	"json-lsp",
	"lua-language-server",
	"php-cs-fixer",
	"php-debug-adapter",
	"phpcbf",
	"phpcs",
	"phpstan",
	"pyright",
	"sqlfluff",
	"typescript-language-server",
	"vim-language-server",
}

for _, package_name in ipairs(require_installed) do
	local ok, pkg = pcall(mason_registry.get_package, package_name)
	if ok and not pkg:is_installed() then
		pkg:install()
	end
end
