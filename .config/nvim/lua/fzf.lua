-- Plugin-free fzf pickers: the fzf binary runs in a floating :terminal,
-- rg does the listing/searching, selections land in :edit or the quickfix.

-- Keep :grep working the classic way too
vim.o.grepprg = "rg --vimgrep --smart-case --hidden --glob '!.git'"
vim.o.grepformat = "%f:%l:%c:%m"

local function executable(name)
	return vim.fn.executable(name) == 1
end

local bat = (executable("bat") and "bat") or (executable("batcat") and "batcat") or nil

-- Colors derived from the active colorscheme so fzf matches the editor
-- instead of its stock terminal palette.

local function fzf_colors()
	local function hl(name)
		return vim.api.nvim_get_hl(0, { name = name, link = false })
	end
	local function hex(...)
		for _, color in ipairs({ ... }) do
			if color then
				return string.format("#%06x", color)
			end
		end
		return "-1"
	end

	local bg = hex(hl("NormalFloat").bg, hl("Normal").bg)
	local fg = hex(hl("NormalFloat").fg, hl("Normal").fg)
	local comment = hex(hl("Comment").fg)
	local spec = {
		"bg:" .. bg,
		"fg:" .. fg,
		"gutter:" .. bg,
		"bg+:" .. hex(hl("CursorLine").bg),
		"fg+:" .. fg,
		"hl:" .. hex(hl("Function").fg),
		"hl+:" .. hex(hl("Function").fg),
		"prompt:" .. hex(hl("Function").fg),
		"pointer:" .. hex(hl("Statement").fg),
		"marker:" .. hex(hl("String").fg),
		"info:" .. comment,
		"spinner:" .. comment,
		"header:" .. comment,
		"separator:" .. hex(hl("FloatBorder").fg, hl("Comment").fg),
		"scrollbar:" .. hex(hl("FloatBorder").fg, hl("Comment").fg),
		"border:" .. hex(hl("FloatBorder").fg, hl("Comment").fg),
	}
	return "--color=" .. table.concat(spec, ",")
end

-- Floating terminal runner ---------------------------------------------------

local function fzf(cmd, opts)
	local out = vim.fn.tempname()
	local buf = vim.api.nvim_create_buf(false, true)
	local width = math.floor(vim.o.columns * 0.85)
	local height = math.floor(vim.o.lines * 0.85)
	local win = vim.api.nvim_open_win(buf, true, {
		relative = "editor",
		width = width,
		height = height,
		col = math.floor((vim.o.columns - width) / 2),
		row = math.floor((vim.o.lines - height) / 2) - 1,
		style = "minimal",
		border = "rounded",
		title = " " .. opts.title .. " ",
		title_pos = "center",
	})
	-- fzf is the last command in both pickers' pipelines, so appending the
	-- color flags here applies them to fzf itself.
	vim.fn.jobstart(cmd .. " " .. fzf_colors() .. " > " .. vim.fn.shellescape(out), {
		term = true,
		on_exit = function(_, code)
			if vim.api.nvim_win_is_valid(win) then
				vim.api.nvim_win_close(win, true)
			end
			if vim.api.nvim_buf_is_valid(buf) then
				vim.api.nvim_buf_delete(buf, { force = true })
			end
			-- 0 = selected, 1 = no match, 130 = aborted with Esc/ctrl-c
			if code == 0 then
				local lines = vim.fn.readfile(out)
				if #lines > 0 then
					opts.on_select(lines)
				end
			end
			vim.fn.delete(out)
		end,
	})
	vim.cmd.startinsert()
end

local base_opts = "--multi --layout=reverse --info=inline-right --preview-window=border-left"

-- Files ----------------------------------------------------------------------

local file_preview = bat and (bat .. " --color=always --style=numbers -- {}") or "cat -- {}"

local function pick_files()
	fzf(
		"rg --files --hidden --glob '!.git' | fzf "
			.. base_opts
			.. " --scheme=path --prompt 'Files> ' --preview "
			.. vim.fn.shellescape(file_preview),
		{
			title = "Files",
			on_select = function(files)
				if #files > 1 then
					vim.fn.setqflist({}, " ", {
						title = "fzf files",
						items = vim.tbl_map(function(f)
							return { filename = f, lnum = 1 }
						end, files),
					})
					vim.cmd.copen()
				end
				vim.cmd.edit(vim.fn.fnameescape(files[1]))
			end,
		}
	)
end

-- Live grep ------------------------------------------------------------------

-- fzf is only the UI here (--disabled): every keystroke re-runs rg via the
-- change:reload binding, so the query is rg's regex syntax, not fzf's.
local grep_reload = "rg --vimgrep --smart-case --hidden --glob '!.git' --color=always -- {q} || true"

-- No ${braces} in here: fzf would parse e.g. ${s} as its own {s} placeholder
local grep_preview = bat and (bat .. " --color=always --highlight-line {2} -- {1}")
	or 'n={2}; s=$((n > 5 ? n - 5 : 1)); sed -n "$s,$((n + 50))p" -- {1}'

local function live_grep()
	fzf(
		-- "true |" so fzf starts with an empty list instead of its default
		-- file listing; results only ever come from the reload binding.
		"true | fzf "
			.. base_opts
			.. " --ansi --disabled --delimiter=: --prompt 'Grep> '"
			.. " --bind " .. vim.fn.shellescape("change:reload:" .. grep_reload)
			.. " --preview " .. vim.fn.shellescape(grep_preview)
			.. " --preview-window " .. vim.fn.shellescape("border-left,+{2}/2"),
		{
			title = "Live grep",
			on_select = function(lines)
				local items = {}
				for _, line in ipairs(lines) do
					local file, lnum, col, text = line:match("^(.-):(%d+):(%d+):(.*)$")
					if file then
						items[#items + 1] =
							{ filename = file, lnum = tonumber(lnum), col = tonumber(col), text = text }
					end
				end
				if #items == 0 then
					return
				end
				if #items > 1 then
					vim.fn.setqflist({}, " ", { title = "fzf grep", items = items })
					vim.cmd.copen()
				end
				vim.cmd.edit(vim.fn.fnameescape(items[1].filename))
				vim.api.nvim_win_set_cursor(0, { items[1].lnum, items[1].col - 1 })
			end,
		}
	)
end

-- Buffers ---------------------------------------------------------------------

local function pick_buffers()
	local bufs = vim.fn.getbufinfo({ buflisted = 1 })
	table.sort(bufs, function(a, b)
		return a.lastused > b.lastused
	end)
	local lines = {}
	for _, b in ipairs(bufs) do
		if b.name ~= "" and b.bufnr ~= vim.api.nvim_get_current_buf() then
			lines[#lines + 1] = b.bufnr .. "\t" .. vim.fn.fnamemodify(b.name, ":~:.")
		end
	end
	if #lines == 0 then
		return
	end
	local input = vim.fn.tempname()
	vim.fn.writefile(lines, input)
	-- bufnr in field 1 (hidden via --with-nth), path in field 2
	local preview = bat and (bat .. " --color=always --style=numbers -- {2}") or "cat -- {2}"
	fzf(
		"fzf "
			.. base_opts
			.. " --delimiter '\\t' --with-nth 2 --prompt 'Buffers> ' --preview "
			.. vim.fn.shellescape(preview)
			.. " < "
			.. vim.fn.shellescape(input),
		{
			title = "Buffers",
			on_select = function(sel)
				local bufnr = tonumber(sel[1]:match("^(%d+)\t"))
				if bufnr and vim.api.nvim_buf_is_valid(bufnr) then
					vim.cmd.buffer(bufnr)
				end
			end,
		}
	)
end

vim.keymap.set("n", "<leader>ff", pick_files, { desc = "Find files (fzf)" })
vim.keymap.set("n", "<leader>fg", live_grep, { desc = "Live grep (fzf)" })
vim.keymap.set("n", "<leader>fb", pick_buffers, { desc = "Buffers (fzf)" })
