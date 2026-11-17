local function opencode_pane()
	local ttys = {}
	for _, tty in ipairs(vim.fn.systemlist({ "ps", "-o", "tty=", "-C", "opencode" })) do
		ttys["/dev/" .. vim.trim(tty)] = true
	end
	for _, scope in ipairs({ "-s", "-a" }) do
		local panes = vim.fn.systemlist({
			"tmux",
			"list-panes",
			scope,
			"-F",
			"#{pane_tty}\t#{pane_id}\t#{pane_current_path}",
		})
		for _, line in ipairs(panes) do
			local tty, id, cwd = line:match("^(.-)\t(.-)\t(.*)$")
			if tty and ttys[tty] then
				return id, cwd
			end
		end
	end
end

local function send_reference(range)
	local file = vim.api.nvim_buf_get_name(0)
	if file == "" then
		return
	end
	local pane, cwd = opencode_pane()
	if not pane then
		vim.notify("no opencode pane found in tmux", vim.log.levels.WARN)
		return
	end
	local ref = "@" .. (vim.fs.relpath(cwd, file) or file)
	if range then
		ref = ref .. " lines " .. range
	end
	vim.fn.system({ "tmux", "send-keys", "-t", pane, "-l", ref .. " " })
	vim.fn.system({ "tmux", "switch-client", "-t", pane })
end

vim.keymap.set("n", "<leader>oc", function()
	send_reference()
end, { desc = "Send file reference to opencode" })

vim.keymap.set("x", "<leader>oc", function()
	local first, last = vim.fn.line("v"), vim.fn.line(".")
	if first > last then
		first, last = last, first
	end
	send_reference(first == last and tostring(first) or (first .. "-" .. last))
	vim.api.nvim_feedkeys(vim.keycode("<Esc>"), "n", false)
end, { desc = "Send selected lines reference to opencode" })
