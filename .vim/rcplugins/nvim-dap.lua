local dap = require("dap")
local dap_vscode = require("dap.ext.vscode")
local json = require("plenary.json")

---@diagnostic disable-next-line: duplicate-set-field
dap_vscode.json_decode = function(str)
	return vim.json.decode(json.json_strip_comments(str, {}))
end

-------------------------------------------
-------------[ FileType Map ]--------------
-------------------------------------------

local ft_mappings = {
	typescript = "javascript",
	typescriptreact = "javascript",
	javascriptreact = "javascript",
	vue = "javascript",
}

-------------------------------------------
--------[ AutoAttach by FileType ]---------
-------------------------------------------

local auto_attach_configs = {
	javascript = function(name, host, port)
		return {
			name = name,
			host = host,
			port = port,
			type = "pwa-node",
			cwd = "${workspaceFolder}",
			sourceMaps = true,
			continueOnAttach = true,
		}
	end,
	python = function(name, host, port)
		return { name = name, host = host, port = port, type = "python" }
	end,
}

-------------------------------------------
---------[ Adapters by FileType ]----------
-------------------------------------------

local adapters = {
	javascript = {
		type = "server",
		host = "localhost",
		port = "${port}",
		executable = {
			command = "js-debug-adapter",
			args = {
				"${port}",
			},
		},
	},
	python = function(cb, config)
		if config.request == "attach" then
			local port = (config.connect or config).port
			local host = (config.connect or config).host or "127.0.0.1"
			-- fix host
			if host == "localhost" then
				host = "127.0.0.1"
			end
			return cb({
				type = "server",
				port = assert(port, "`connect.port` is required for `attach` configuration"),
				host = host,
			})
		end
		return cb({
			type = "executable",
			command = "python",
			args = { "-m", "debugpy.adapter" },
			options = {
				source_filetype = "python",
			},
		})
	end,
}

-------------------------------------------
--------[ Configurations Helpers ]---------
-------------------------------------------

local function pick_process(_)
	local pid = vim.fn["PickProcessID"]()
	return pid or dap.ABORT
end

local function get_url()
	local co = coroutine.running()
	return coroutine.create(function()
		vim.ui.input({ prompt = "Enter URL: ", default = "http://localhost:3000" }, function(url)
			if url == nil or url == "" then
				return
			else
				coroutine.resume(co, url)
			end
		end)
	end)
end

-------------------------------------------
------[ Configurations by FileTypes ]------
-------------------------------------------
local configurations = {}

-- loop for all js filetypes
local js_filetypes = { "javascript" }
for filetype, mapped_ft in pairs(ft_mappings) do
	if mapped_ft == "javascript" then
		table.insert(js_filetypes, filetype)
	end
	-- group others
end

for _, js_filetype in ipairs(js_filetypes) do
	configurations[js_filetype] = {
		-- Debug single nodejs files
		{
			name = "Launch file",
			type = "pwa-node",
			request = "launch",
			program = "${file}",
			cwd = "${workspaceFolder}",
			args = { "${file}" },
			sourceMaps = true,
			sourceMapPathOverrides = {
				["./*"] = "${workspaceFolder}/src/*",
			},
		},
		-- Debug nodejs processes (make sure to add --inspect when you run the process)
		{
			name = "Attach port",
			type = "pwa-node",
			request = "attach",
			port = 9229,
			cwd = "${workspaceFolder}",
			sourceMaps = true,
		},
		{
			name = "Attach process",
			type = "pwa-node",
			request = "attach",
			processId = pick_process,
			port = 9229,
			cwd = "${workspaceFolder}",
			sourceMaps = true,
		},
		{
			name = "Debug Jest Tests",
			type = "pwa-node",
			request = "launch",
			runtimeExecutable = "node",
			runtimeArgs = { "${workspaceFolder}/node_modules/.bin/jest", "--runInBand" },
			rootPath = "${workspaceFolder}",
			cwd = "${workspaceFolder}",
			console = "integratedTerminal",
			internalConsoleOptions = "neverOpen",
			-- args = {'${file}', '--coverage', 'false'},
			-- sourceMaps = true,
			-- skipFiles = {'node_internals/**', 'node_modules/**'},
		},
		{
			name = "Debug Vitest Tests",
			type = "pwa-node",
			request = "launch",
			cwd = vim.fn.getcwd(),
			program = "${workspaceFolder}/node_modules/vitest/vitest.mjs",
			args = { "run", "${file}" },
			autoAttachChildProcesses = true,
			smartStep = true,
			skipFiles = { "<node_internals>/**", "node_modules/**" },
		},
		-- Debug web applications (client side)
		{
			name = "Launch & Debug Chrome",
			type = "pwa-chrome",
			request = "launch",
			url = get_url,
			webRoot = vim.fn.getcwd(),
			protocol = "inspector",
			sourceMaps = true,
			userDataDir = false,
			resolveSourceMapLocations = {
				"${workspaceFolder}/**",
				"!**/node_modules/**",
			},

			-- From https://github.com/lukas-reineke/dotfiles/blob/master/vim/lua/plugins/dap.lua
			-- To test how it behaves
			rootPath = "${workspaceFolder}",
			cwd = "${workspaceFolder}",
			console = "integratedTerminal",
			internalConsoleOptions = "neverOpen",
			sourceMapPathOverrides = {
				["./*"] = "${workspaceFolder}/src/*",
			},
		},
		{
			name = "----- ↑ launch.json configs (if available) ↑ -----",
			type = "",
			request = "launch",
		},
	}
end
-------------------------------------------
-------------------------------------------
-------------------------------------------

local adapters_mt = {
	__index = function(_, adapter_name)
		return function(cb, config)
			local ft = vim.tbl_get(ft_mappings, vim.bo.filetype) or vim.bo.filetype
			local adapter_config = vim.tbl_get(adapters, ft)
			if adapter_config == nil then
				vim.notify(
					"Missing adapter for filetype: [" .. ft .. "] and adapter name: [" .. adapter_name .. "]",
					vim.log.levels.ERROR
				)
				return cb(config)
			end
			if type(adapter_config) == "function" then
				return adapter_config(cb, config)
			end
			return cb(adapter_config)
		end
	end,
}
dap.adapters = setmetatable(dap.adapters, adapters_mt)
dap.configurations = configurations

local get_vscode_launch_json = function()
	local launch_json = ".vscode/launch.json"
	local opts = { patterns = { launch_json } }
	local ok, project_root_path = pcall(vim.fn["utils#get_root_dir"], opts)
	if not ok then
		return nil
	end
	local launch_json_path = project_root_path .. "/" .. launch_json
	print("Using: [" .. launch_json_path .. "]")
	return launch_json_path
end

local is_bp_list_opened = function()
	local condition =
		"v:val.quickfix && get(v:val.variables, 'title', get(v:val.variables, 'quickfix_title', '')) == 'DAP Breakpoints'"
	local qf_list = vim.fn.filter(vim.fn.getwininfo(), condition)
	return next(qf_list) ~= nil
end

-- loads vscode configurations if exists on start or continue
local custom_continue = function()
	local session = dap.session()
	if not session then
		local vscode_launch_json = get_vscode_launch_json()
		if vscode_launch_json then
			dap_vscode.load_launchjs(vscode_launch_json)
		end
	end
	dap.continue()
end

-- if session is running, disconnect or terminate depending on request
local custom_close = function()
	local session = dap.session()
	if not session then
		return
	end
	if session["config"] and session["config"].request == "attach" then
		return dap.disconnect()
	end
	return dap.terminate()
end

local toggle_list_breakpoints = function()
	if is_bp_list_opened() then
		return vim.api.nvim_command("cclose")
	end
	return dap.list_breakpoints(true)
end

local custom_session_init = function()
	dap.set_exception_breakpoints("default")
end

local custom_session_cleanup = function()
	dap.repl.close()
	if is_bp_list_opened() then
		vim.api.nvim_command("cclose")
	end
end

local attach_debugger = function(name, host, port)
	local ft = vim.tbl_get(ft_mappings, vim.bo.filetype) or vim.bo.filetype
	local cb = vim.tbl_get(auto_attach_configs, ft)
	if cb == nil then
		vim.notify("Missing attach configuration for [" .. ft .. "]", vim.log.levels.ERROR)
		return
	end
	local config = cb(name, host, port)
	config["request"] = "attach"
	-- Amount of times the client should attempt to
	-- connect before erroring out.
	-- There is a 250ms delay between each retry
	-- Defaults to 14 (3.5 seconds)
	config["max_retries"] = 40 -- 10 seconds
	return dap.run(config)
end

local custom_attach = function()
	-- custom attach cache
	if vim.g.nvim_dap_custom_attach_cache == nil then
		vim.g.nvim_dap_custom_attach_cache = {
			port = 5678,
			host = "localhost",
		}
	end
	local prev_host = vim.g.nvim_dap_custom_attach_cache.host
	local prev_port = vim.g.nvim_dap_custom_attach_cache.port
	local host = vim.fn.input("Add host: ", prev_host)
	if host == "" then
		return print("Abort!")
	end
	local port = vim.fn.input("Add port: ", prev_port)
	if host == "" then
		return print("Abort!")
	end
	vim.g.nvim_dap_custom_attach_cache.port = port
	vim.g.nvim_dap_custom_attach_cache.host = host
	local name = vim.fn.expand("%:t")
	return attach_debugger(name, host, port)
end

-- on session init and cleanup
dap.listeners.after.event_initialized["dap_init"] = custom_session_init
dap.listeners.before.event_terminated["dap_cleanup"] = custom_session_cleanup
dap.listeners.before.event_exited["dap_cleanup"] = custom_session_cleanup
dap.defaults.fallback.terminal_win_cmd = "50vsplit new"
dap.defaults.fallback.external_terminal = {
	command = "tmux",
	args = { "split-window", "-h", "-n", "Debug", "-c", "${workspaceFolder}" },
}
dap.defaults.fallback.force_external_terminal = true

-- keymaps - there are more but I mostly just use REPL
vim.keymap.set("n", "<leader>dd", custom_continue)
vim.keymap.set("n", "<leader>da", custom_attach)
vim.keymap.set("n", "<leader>dx", custom_close)
vim.keymap.set("n", "<leader>dh", dap.toggle_breakpoint)
vim.keymap.set("n", "<leader>dA", toggle_list_breakpoints)
vim.keymap.set("n", "<leader>dc", dap.clear_breakpoints)
vim.keymap.set("n", "<leader>dE", function()
	dap.set_exception_breakpoints({ "all" })
end)
vim.keymap.set("n", "<leader>d?", function()
	require("dap.ui.widgets").hover()
end)
vim.keymap.set("n", "<leader>di", function()
	local widgets = require("dap.ui.widgets")
	widgets.centered_float(widgets.scopes)
end)
vim.keymap.set("n", "<leader>dr", function()
	dap.repl.toggle({}, "vsplit")
end)

local dap_repl_group = vim.api.nvim_create_augroup("DapReplGroup", { clear = true })
vim.api.nvim_create_autocmd("FileType", {
	group = dap_repl_group,
	pattern = "dap-repl",
	callback = function()
		require("dap.ext.autocompl").attach()
	end,
	desc = "Enable DAP autocompletion for dap-repl filetype",
})

vim.api.nvim_create_user_command("AttachDebugger", function(opts)
	local args = opts.fargs
	local port = tonumber(vim.tbl_get(args, 1)) or 5678
	local host = vim.tbl_get(args, 2) or "localhost"
	local name = vim.tbl_get(args, 3) or vim.fn.expand("%:t")
	attach_debugger(name, host, port)
end, {
	nargs = "*",
	desc = "Attach the debugger to a specified host and port. Supported optional args in order: name, host, and port",
})
