local M = {

}

local function makeDir(project_dir)
	-- every number is "truthy" so 0 = true
	local make_dir = ""
	if vim.fn.isdirectory(vim.fn.expand(project_dir)) == 0 then
		make_dir = "mkdir -p " .. project_dir .. "; "
	end
	return make_dir
end


local function nvimOpenMode(open_session, project_dir)
	local nvim_open_mode = ""
	local sess = project_dir .. "Session.vim"
	if vim.fn.filereadable(vim.fn.expand(sess)) == 1 and open_session then
		nvim_open_mode = "-S Session.vim"
	else
		nvim_open_mode = "."
	end
	return nvim_open_mode
end


local function tmuxSystemCmd(use_tabs, open_session, project_dir)
	local tab = ""
	if use_tabs then
		tab = "w -n "
	else
		tab = "-session -d -s "
	end

	local make_dir = makeDir(project_dir)
	local nvim_open_mode = nvimOpenMode(open_session, project_dir)

	return "tmux new" .. tab .. "\"" .. project_dir .. "\" \"" .. make_dir .. "cd " .. project_dir .. "; nvim " .. nvim_open_mode .."; $SHELL\""
end

local function linuxSystemCmd(use_tabs, open_session, project_dir)
	local tab = ""
	if use_tabs then 
		tab = "--tab " 
	end

	local make_dir = makeDir(project_dir)
	local nvim_open_mode = nvimOpenMode(open_session, project_dir)

	return	"gnome-terminal " .. tab .. "-- bash -c '".. make_dir .. "cd " .. project_dir .. "; nvim " .. nvim_open_mode .. "; $SHELL'"
end

local function selectFolder(prompt_bufnr, map)
	local function newTerminal(use_tabs, open_session)
		local content = require('telescope.actions.state').get_selected_entry(prompt_bufnr)
		local project_dir = content.text

		local system_cmd
		if vim.fn.getenv("TMUX") == vim.NIL then
			system_cmd = linuxSystemCmd(use_tabs, open_session, project_dir)
			print(system_cmd)
		else
			system_cmd = tmuxSystemCmd(use_tabs, open_session, project_dir)
			print(system_cmd)
		end

		vim.fn.system(system_cmd)
		require('telescope.actions').close(prompt_bufnr)
	end


	map('n', '<C-s>', function()
		newTerminal(false, true)
	end)

	map('i', '<C-s>', function()
		newTerminal(true, true)
	end)

	map('i', '<C-t>', function()
		newTerminal(true, false)
	end)

	map('n', '<C-t>', function()
		newTerminal(false, false)
	end)
end


-- TODO:
-- make into a plugin, call it quick-projects-nvim
-- path shortener: some paths could be very long
-- make it so that you don't start a new window and session when the window is already there
-- make it so that you can group windows within the session, as denoted by file-directory paths within the session name
-- 		instead of:
-- 			project.txt
-- 				~/Desktop/..../amme2300
-- 				~/Desktop/..../elec1103
-- 				~/Desktop/..../resumes
-- 		do this:
-- 			uni.txt
-- 				~/Desktop/..../amme2300
-- 				~/Desktop/..../elec1103
-- 			work.txt
-- 				~/Desktop/..../resumes

M.quickProjects = function()
	require("telescope.builtin").live_grep({
		prompt_title =  "quick projects >",
		cwd = "~/.vim/quick_projects/",

		attach_mappings = function(prompt_bufnr, map)
			selectFolder(prompt_bufnr, map)
			return true
		end
	})
end


return M
