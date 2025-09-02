function _G.export_highlights_to_file(colorscheme)
	colorscheme = colorscheme or "exported"
	local filename = colorscheme .. ".vim"
	local hl = vim.api.nvim_get_hl(0, {})
	local lines = {
		"hi clear Normal",
		"",
		"set background=dark",
		"",
		"hi clear",
		"",
		'if exists("syntax_on")',
		"  syntax reset",
		"endif",
		"",
		string.format("let g:colors_name = '%s'", colorscheme),
	}

	-- Sort highlight groups: non-link first, then link groups
	local sorted_groups = {}
	local link_groups = {}
	for group, attrs in pairs(hl) do
		if attrs.link then
			table.insert(link_groups, { group, attrs })
		else
			table.insert(sorted_groups, { group, attrs })
		end
	end
	for _, v in ipairs(link_groups) do
		table.insert(sorted_groups, v)
	end

	for _, group_attrs in ipairs(sorted_groups) do
		local group, attrs = group_attrs[1], group_attrs[2]
		if attrs.link then
			table.insert(lines, string.format("hi! link %s %s", group, attrs.link))
		else
			local base_part = "hi " .. group .. " "
			local parts = {}
			if attrs.fg then
				table.insert(parts, string.format("guifg=#%06x", attrs.fg))
			end
			if attrs.bg then
				table.insert(parts, string.format("guibg=#%06x", attrs.bg))
			end
			if attrs.sp then
				table.insert(parts, string.format("guisp=#%06x", attrs.sp))
			end
			if attrs.ctermfg then
				table.insert(parts, "ctermfg=" .. attrs.ctermfg)
			end
			if attrs.ctermbg then
				table.insert(parts, "ctermbg=" .. attrs.ctermbg)
			end
			if attrs.cterm then
				local cterm_styles = {}
				for k, v in pairs(attrs.cterm) do
					if v then
						table.insert(cterm_styles, k)
					end
				end
				table.insert(parts, "cterm=" .. table.concat(cterm_styles, ","))
			else
				local gui_styles = {}
				local cterm_styles = {}
				for _, style in ipairs({
					"bold",
					"italic",
					"underline",
					"undercurl",
					"strikethrough",
					"reverse",
					"standout",
					"nocombine",
				}) do
					if attrs[style] then
						table.insert(gui_styles, style)
						table.insert(cterm_styles, style)
					end
				end
				if #gui_styles > 0 then
					table.insert(parts, "gui=" .. table.concat(gui_styles, ","))
				end
				if #cterm_styles > 0 then
					table.insert(parts, "cterm=" .. table.concat(cterm_styles, ","))
				end
			end

			if #parts > 0 then
				table.insert(lines, base_part .. table.concat(parts, " "))
			end
		end
	end
	local file = io.open(filename, "w")
	if file then
		file:write(table.concat(lines, "\n"))
		file:close()
		print("Exported highlights to " .. filename)
	else
		print("Failed to write to " .. filename)
	end
end
