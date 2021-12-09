require('quick_projects.globals')

local M = {}

M.setup = function(config)
	config = config or {}
	M._config = vim.tbl_deep_extend("force", {
		enable_default_mappings = false
	}, config)
	if M._config.enable_default_mappings then
		vim.api.nvim_set_keymap("n", "<Leader>qp", [[ <Esc><Cmd>lua require('quick_projects.builtins').quickProjects()<CR>]], {noremap = true, silent = true, expr = false})
	end
end

return M
