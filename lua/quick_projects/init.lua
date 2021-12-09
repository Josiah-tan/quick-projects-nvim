require('quick_projects.globals')

local M = {}

M.setup = function(config)
	config = config or {}
	M._config = vim.tbl_deep_extend("force", {
		enable_global_mappings = false,
		builtin_defaults = {
			prompt_title =  "quick projects >",
			cwd = "~/.config/.quick_projects/",
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
	P(M._config.builtin_defaults)
	require("quick_projects.builtins").setup(M._config.builtin_defaults)
end


return M
