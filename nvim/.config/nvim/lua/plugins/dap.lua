-- Debugging via nvim-dap. gdb 14+ speaks DAP natively, so no separate
-- adapter binary is needed for c/c++/rust/zig.
vim.pack.add({ "https://github.com/mfussenegger/nvim-dap" })

local dap = require("dap")

dap.adapters.gdb = {
	type = "executable",
	command = "gdb",
	args = { "--interpreter=dap", "--eval-command", "set print pretty on" },
}

local configurations = {
	{
		name = "Launch executable",
		type = "gdb",
		request = "launch",
		program = function()
			return vim.fn.input("Executable: ", vim.fn.getcwd() .. "/", "file")
		end,
		args = function()
			return vim.split(vim.fn.input("Program args: "), " +", { trimempty = true })
		end,
		cwd = "${workspaceFolder}",
	},
	{
		name = "Attach to process",
		type = "gdb",
		request = "attach",
		pid = function()
			return require("dap.utils").pick_process().pid
		end,
		cwd = "${workspaceFolder}",
	},
}

for _, ft in ipairs({ "c", "cpp", "rust", "zig" }) do
	dap.configurations[ft] = configurations
end

vim.fn.sign_define("DapBreakpoint", { text = "●", texthl = "DiagnosticError" })
vim.fn.sign_define("DapStopped", { text = "▶", texthl = "DiagnosticWarn", linehl = "Visual" })

vim.keymap.set("n", "<F5>", dap.continue, { desc = "Debug: start/continue" })
vim.keymap.set("n", "<F10>", dap.step_over, { desc = "Debug: step over" })
vim.keymap.set("n", "<F11>", dap.step_into, { desc = "Debug: step into" })
vim.keymap.set("n", "<F12>", dap.step_out, { desc = "Debug: step out" })
vim.keymap.set("n", "<leader>db", dap.toggle_breakpoint, { desc = "Debug: toggle breakpoint" })
vim.keymap.set("n", "<leader>dB", function()
	dap.set_breakpoint(vim.fn.input("Breakpoint condition: "))
end, { desc = "Debug: conditional breakpoint" })
vim.keymap.set("n", "<leader>dr", dap.repl.toggle, { desc = "Debug: toggle repl" })
vim.keymap.set("n", "<leader>dq", dap.terminate, { desc = "Debug: terminate" })
vim.keymap.set("n", "<leader>dh", function()
	require("dap.ui.widgets").hover()
end, { desc = "Debug: hover value" })
local widgets = require("dap.ui.widgets")
local scopes_sidebar = widgets.sidebar(widgets.scopes, { width = 40 })
local frames_panel = widgets.sidebar(widgets.frames, { height = 10 }, "belowright split")

dap.listeners.after.event_initialized["dap_windows"] = function()
	scopes_sidebar.open()
	frames_panel.open()
end
for _, event in ipairs({ "event_terminated", "event_exited" }) do
	dap.listeners.before[event]["dap_windows"] = function()
		scopes_sidebar.close()
		frames_panel.close()
	end
end

vim.keymap.set("n", "<leader>ds", scopes_sidebar.toggle, { desc = "Debug: toggle scopes sidebar" })
vim.keymap.set("n", "<leader>df", frames_panel.toggle, { desc = "Debug: toggle call stack" })
