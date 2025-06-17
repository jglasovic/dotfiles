-- vim.lsp.set_log_level('DEBUG');

local border = "single"
local format_timeout_ms = 5000

vim.diagnostic.config({
	virtual_text = false,
	severity_sort = true,
	float = {
		border = border,
		focusable = false,
		scope = "cursor",
		source = true,
		prefix = " ",
	},
})

-- Show diagnostics in a pop-up window on cursor hold
vim.api.nvim_create_autocmd("CursorHold", {
	group = vim.api.nvim_create_augroup("LspDiagnosticsPopup", { clear = true }),
	callback = function()
		local current_cursor = vim.api.nvim_win_get_cursor(0)
		local last_popup_cursor = vim.w.lsp_diagnostics_last_cursor or { nil, nil }
		-- Show the popup diagnostics window,
		-- but only once for the current cursor location (unless moved afterwards).
		if not (current_cursor[1] == last_popup_cursor[1] and current_cursor[2] == last_popup_cursor[2]) then
			vim.w.lsp_diagnostics_last_cursor = current_cursor
			vim.diagnostic.open_float(nil, { scope = "cursor", focusable = false })
		end
	end,
})

local man_documentation = function()
	if vim.fn.index({ "vim", "help", "lua" }, vim.bo.filetype) >= 0 then
		return vim.cmd("h " .. vim.fn.expand("<cword>"))
	end
	if vim.bo.keywordprg ~= "" then
		return vim.cmd("!" .. vim.bo.keywordprg .. " " .. vim.fn.expand("<cword>"))
	end
	return print("Missing man documentation!")
end

local list_workspaces = function()
	print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
end

local lsp_restart = function()
	vim.diagnostic.reset()
	vim.cmd("LspRestart")
	vim.notify("LSP restarted")
end

vim.keymap.set("n", "<leader>lr", lsp_restart)
vim.keymap.set("n", "<leader>N", function()
	vim.diagnostic.jump({ count = -1, float = true })
end)
vim.keymap.set("n", "<leader>n", function()
	vim.diagnostic.jump({ count = 1, float = true })
end)
vim.keymap.set("n", "<leader>,", vim.diagnostic.setloclist)

-- delete default global mappings if exists
pcall(vim.keymap.del, "n", "grn")
pcall(vim.keymap.del, { "n", "v" }, "gra")
pcall(vim.keymap.del, "n", "grr")
pcall(vim.keymap.del, "n", "gri")
pcall(vim.keymap.del, "n", "gO")

vim.api.nvim_create_autocmd("LspAttach", {
	group = vim.api.nvim_create_augroup("UserLspConfig", { clear = true }),
	callback = function(args)
		local buffer = args.buf
		local client = assert(vim.lsp.get_client_by_id(args.data.client_id))

		if
			not client:supports_method("textDocument/willSaveWaitUntil")
			and client:supports_method("textDocument/formatting")
		then
			vim.api.nvim_create_autocmd("BufWritePre", {
				group = vim.api.nvim_create_augroup("auto_format_lsp", { clear = false }),
				buffer = buffer,
				callback = function()
					vim.lsp.buf.format({ bufnr = buffer, id = client.id, timeout_ms = format_timeout_ms, async = false })
				end,
			})
		end

		-- manually handling sql, mysql autocomplete
		if not vim.tbl_contains({ "sql", "mysql" }, vim.bo.filetype) then
			vim.bo[buffer].omnifunc = "v:lua.MiniCompletion.completefunc_lsp"
		end

		local opts = { buffer = buffer }
		vim.keymap.set("i", "<C-k>", function()
			vim.lsp.buf.signature_help({ border = border })
		end, opts)
		vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
		vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts)
		vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts)
		vim.keymap.set("n", "gt", vim.lsp.buf.type_definition, opts)
		vim.keymap.set("n", "gr", function()
			vim.lsp.buf.references({ includeDeclaration = false })
		end, opts)
		vim.keymap.set("n", "M", man_documentation, opts)
		vim.keymap.set("n", "K", function()
			vim.lsp.buf.hover({ border = border })
		end, opts)
		vim.keymap.set("n", "<leader>cr", vim.lsp.buf.rename, opts)
		vim.keymap.set({ "n", "v" }, "<leader>.", vim.lsp.buf.code_action, opts)
		vim.keymap.set("n", "<leader>cf", function()
			vim.lsp.buf.format({ timeout_ms = format_timeout_ms, async = true })
		end, opts)
		-- workspace
		vim.keymap.set("n", "<leader>wa", vim.lsp.buf.add_workspace_folder, opts)
		vim.keymap.set("n", "<leader>wr", vim.lsp.buf.remove_workspace_folder, opts)
		vim.keymap.set("n", "<leader>wL", list_workspaces, opts)
	end,
})
