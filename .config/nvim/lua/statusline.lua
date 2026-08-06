-- Hand-rolled global statusline (laststatus = 3).
-- Highlights are derived from the active colorscheme, git info is read from
-- .git/HEAD directly (no subprocess), and everything dynamic is cached in
-- buffer variables so the render function stays cheap.

local M = {}

-- Highlights ----------------------------------------------------------------

local function get_hl(name)
	return vim.api.nvim_get_hl(0, { name = name, link = false })
end

local function setup_highlights()
	local normal = get_hl("Normal")
	local stl = get_hl("StatusLine")

	local function accent(name)
		return get_hl(name).fg or normal.fg
	end

	local modes = {
		StlModeNormal = accent("Function"),
		StlModeInsert = accent("String"),
		StlModeVisual = accent("Statement"),
		StlModeReplace = accent("Error"),
		StlModeCommand = accent("Constant"),
		StlModeTerminal = accent("Special"),
	}
	for group, color in pairs(modes) do
		vim.api.nvim_set_hl(0, group, { fg = normal.bg, bg = color, bold = true })
	end

	vim.api.nvim_set_hl(0, "StlGit", { fg = accent("Directory"), bg = stl.bg })
	vim.api.nvim_set_hl(0, "StlDim", { fg = accent("Comment"), bg = stl.bg })
	vim.api.nvim_set_hl(0, "StlMacro", { fg = accent("Error"), bg = stl.bg, bold = true })

	-- Diagnostic* groups have no background, which renders wrong on a
	-- statusline with its own bg; rebuild them on top of the statusline bg.
	for _, kind in ipairs({ "Error", "Warn", "Info", "Hint" }) do
		vim.api.nvim_set_hl(0, "StlDiag" .. kind, { fg = accent("Diagnostic" .. kind), bg = stl.bg })
	end
end

-- Mode ----------------------------------------------------------------------

local mode_map = {
	n = { "NORMAL", "StlModeNormal" },
	no = { "O-PENDING", "StlModeNormal" },
	i = { "INSERT", "StlModeInsert" },
	v = { "VISUAL", "StlModeVisual" },
	V = { "V-LINE", "StlModeVisual" },
	["\22"] = { "V-BLOCK", "StlModeVisual" },
	s = { "SELECT", "StlModeVisual" },
	S = { "S-LINE", "StlModeVisual" },
	["\19"] = { "S-BLOCK", "StlModeVisual" },
	R = { "REPLACE", "StlModeReplace" },
	c = { "COMMAND", "StlModeCommand" },
	r = { "PROMPT", "StlModeCommand" },
	t = { "TERMINAL", "StlModeTerminal" },
	["!"] = { "SHELL", "StlModeTerminal" },
}

-- Git -----------------------------------------------------------------------

local function stl_escape(s)
	return (s:gsub("%%", "%%%%"))
end

local function read_first_line(path)
	local f = io.open(path)
	if not f then
		return nil
	end
	local line = f:read("*l")
	f:close()
	return line
end

local function git_branch(root)
	local gitdir = root .. "/.git"
	if vim.fn.isdirectory(gitdir) == 0 then
		-- Worktree or submodule: .git is a file containing "gitdir: <path>"
		local target = (read_first_line(gitdir) or ""):match("^gitdir: (.+)$")
		if not target then
			return nil
		end
		gitdir = target:sub(1, 1) == "/" and target or vim.fs.normalize(root .. "/" .. target)
	end
	local head = read_first_line(gitdir .. "/HEAD") or ""
	local branch = head:match("^ref: refs/heads/(.+)$")
	if branch then
		return branch
	end
	return head ~= "" and head:sub(1, 7) or nil -- detached HEAD: short hash
end

local function update_buf_info(buf)
	if not vim.api.nvim_buf_is_valid(buf) or vim.bo[buf].buftype ~= "" then
		return
	end
	local file = vim.api.nvim_buf_get_name(buf)
	local root = vim.fs.root(file ~= "" and file or assert(vim.uv.cwd()), ".git")
	if root then
		vim.b[buf].stl_branch = git_branch(root)
		if file:sub(1, #root) == root then
			vim.b[buf].stl_path = stl_escape(file:sub(#root + 2))
		end
	else
		vim.b[buf].stl_branch = nil
		vim.b[buf].stl_path = file ~= "" and stl_escape(vim.fn.fnamemodify(file, ":~:.")) or nil
	end
end

-- Diagnostics ---------------------------------------------------------------

local severity = vim.diagnostic.severity
local diag_defs = {
	{ severity.ERROR, " ", "StlDiagError" },
	{ severity.WARN, " ", "StlDiagWarn" },
	{ severity.INFO, " ", "StlDiagInfo" },
	{ severity.HINT, " ", "StlDiagHint" },
}

local function diagnostics()
	local counts = vim.diagnostic.count(0)
	local out = {}
	for _, d in ipairs(diag_defs) do
		local n = counts[d[1]]
		if n and n > 0 then
			out[#out + 1] = "%#" .. d[3] .. "#" .. d[2] .. n .. "%* "
		end
	end
	return table.concat(out)
end

-- Render --------------------------------------------------------------------

function M.render()
	local raw = vim.fn.mode()
	local mode = mode_map[raw] or mode_map[raw:sub(1, 1)] or { raw:upper(), "StlModeNormal" }
	local parts = { "%#" .. mode[2] .. "# " .. mode[1] .. " %*" }

	local rec = vim.fn.reg_recording()
	if rec ~= "" then
		parts[#parts + 1] = "%#StlMacro# REC @" .. rec .. " %*"
	end

	if vim.b.stl_branch then
		parts[#parts + 1] = "%#StlGit#  " .. stl_escape(vim.b.stl_branch) .. " %*"
	end

	parts[#parts + 1] = " " .. (vim.b.stl_path or "%f") .. " %m%r%<%="
	parts[#parts + 1] = diagnostics()

	if vim.bo.filetype ~= "" then
		parts[#parts + 1] = "%#StlDim#" .. vim.bo.filetype .. " %*"
	end

	parts[#parts + 1] = "%#" .. mode[2] .. "# %l:%c %*"

	return table.concat(parts)
end

-- Setup ---------------------------------------------------------------------

local group = vim.api.nvim_create_augroup("statusline", { clear = true })

vim.api.nvim_create_autocmd("ColorScheme", { group = group, callback = setup_highlights })

vim.api.nvim_create_autocmd({ "BufEnter", "FocusGained", "DirChanged" }, {
	group = group,
	callback = function(args)
		update_buf_info(args.event == "BufEnter" and args.buf or vim.api.nvim_get_current_buf())
	end,
})

vim.api.nvim_create_autocmd({ "DiagnosticChanged", "ModeChanged", "RecordingEnter" }, {
	group = group,
	callback = function()
		vim.cmd.redrawstatus()
	end,
})

-- reg_recording() is still set while RecordingLeave fires; redraw after.
vim.api.nvim_create_autocmd("RecordingLeave", {
	group = group,
	callback = vim.schedule_wrap(function()
		vim.cmd.redrawstatus()
	end),
})

setup_highlights()
update_buf_info(vim.api.nvim_get_current_buf())
vim.o.statusline = "%!v:lua.require'statusline'.render()"

return M
