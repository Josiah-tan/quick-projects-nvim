require('quick_projects.globals')

local M = {}

M.setup = function(config)
	config = config or {}
	M._config = vim.tbl_deep_extend("force", {
		debug_mode_on = false,
		enable_global_mappings = false,
		builtin_defaults = {
			prompt_title =  "quick projects >",
			cwd = "~/.config/.quick_projects/",
			quick_projects_dir = "projects",
			quick_marks_dir = "marks",
			quick_marks_file = "marks.txt",
			mark_split_character = "@",
			mark_use_tabs = false,
			attempt_vim_session = true,
			mappings = {
			{
				mode = 'n',
				key = '<C-s>',
				use_tabs = false,
				attempt_vim_session = true
			},
			{
				mode = 'n',
				key = '<C-t>',
				use_tabs = false,
				attempt_vim_session = false
			}}
		},
	}, config)
	if M._config.enable_global_mappings then
		vim.api.nvim_set_keymap("n", "<Leader>qp", [[ <Esc><Cmd>lua require('quick_projects.builtins').quickProjects()<CR>]], {noremap = true, silent = true, expr = false})
	end
	require("quick_projects.builtins").setup(M._config.builtin_defaults)
	QuickProjectsDebugModeOn = M._config.debug_mode_on
	-- require("quick_projects.globals").setup(M._config.debug_mode_on)
	-- P("M._config.builtin_defaults: ", M._config.builtin_defaults)
	-- P(M._config.builtin_defaults)
end


return M
