require('quick_projects.globals')

local M = {}

M.setup = function(config)
	config = config or {}
	M._config = M._config or {
		debug_mode_on = false,
		enable_global_mappings = false,
		builtin_defaults = {
			cwd = "~/.config/.quick_projects/",
			quickProjects = {
				prompt_title =  "quick projects >",
				dir = "projects",
			},
			generalMarks = {
				dir = "marks",
				file = "marks.txt",
				split_character = "@",
			},
			quickMarks = {
				prompt_title =  "quick marks >",
			},
			navMark = {
				idx = 1,
				attempt_vim_session = true,
				tmux = {
					enable = true,
				},
				linux_terminal = {
					enable = true,
					use_tabs = false,
				}
			},
			mappings = {
				{
					mode = 'i',
					key = '<C-s>',
					attempt_vim_session = true,
					tmux = {
						enable = true,
					},
					linux_terminal = {
						enable = true,
						use_tabs = true,
					}
				},
				{
					mode = 'i',
					key = '<C-m>',
					attempt_vim_session = true,
					tmux = {
						enable = true,
						add_mark = true
					},
					linux_terminal = {
						enable = true,
						use_tabs = true,
					}
				}},
			}
		}

		M._config = vim.tbl_deep_extend("force", M._config , config)
		if M._config.enable_global_mappings then
			vim.api.nvim_set_keymap("n", "<Leader>qp", [[ <Esc><Cmd>lua require('quick_projects.builtins').quickProjects()<CR>]], {noremap = true, silent = true, expr = false})
			vim.api.nvim_set_keymap("n", "<Leader>qm", [[ <Esc><Cmd>lua require('quick_projects.builtins').quickMarks()<CR>]], {noremap = true, silent = true, expr = false})
			vim.api.nvim_set_keymap("n", "<Leader>qj", [[ <Esc><Cmd>lua require('quick_projects.builtins').navMark({idx = 1})<CR>]], {noremap = true, silent = true, expr = false})
			vim.api.nvim_set_keymap("n", "<Leader>qk", [[ <Esc><Cmd>lua require('quick_projects.builtins').navMark({idx = 2})<CR>]], {noremap = true, silent = true, expr = false})
			vim.api.nvim_set_keymap("n", "<Leader>ql", [[ <Esc><Cmd>lua require('quick_projects.builtins').navMark({idx = 3})<CR>]], {noremap = true, silent = true, expr = false})
			vim.api.nvim_set_keymap("n", "<Leader>q;", [[ <Esc><Cmd>lua require('quick_projects.builtins').navMark({idx = 4})<CR>]], {noremap = true, silent = true, expr = false})
		end

		require("quick_projects.builtins").setup(M._config.builtin_defaults)
		QuickProjectsDebugModeOn = M._config.debug_mode_on
	end


return M
