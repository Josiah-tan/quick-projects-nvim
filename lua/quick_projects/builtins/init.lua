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



local function tmuxSystemCmd(use_tabs, open_session, project_dir, session_name)
	local make_dir = makeDir(project_dir)
	local nvim_open_mode = nvimOpenMode(open_session, project_dir)

	local has_session = vim.fn.system("tmux has-session -t \":" .. project_dir .. "\"")
	local session_exists = string.len(has_session) == 0

	if session_exists then
		return "tmux switch-client -t \":" .. project_dir .. "\""
	else
		return "tmux neww -n \"".. project_dir .. "\" \"" .. make_dir .. "cd " .. project_dir .. "; nvim " .. nvim_open_mode .."; $SHELL\""
	end
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

local function selectProject(prompt_bufnr, map)
	local function switchSession(use_tabs, open_session)
		local content = require('telescope.actions.state').get_selected_entry(prompt_bufnr)
		-- P(content)
		local session_name = content.filename
		local project_dir = content.text

		local system_cmd
		if vim.fn.getenv("TMUX") == vim.NIL then
			system_cmd = linuxSystemCmd(use_tabs, open_session, project_dir)
			print(system_cmd)
		else
			system_cmd = tmuxSystemCmd(use_tabs, open_session, project_dir, session_name)
			print(system_cmd)
		end

		vim.fn.system(system_cmd)
		require('telescope.actions').close(prompt_bufnr)
	end


	map('n', '<C-s>', function()
		switchSession(false, true)
	end)

	map('i', '<C-s>', function()
		switchSession(true, true)
	end)

	map('i', '<C-t>', function()
		switchSession(true, false)
	end)

	map('n', '<C-t>', function()
		switchSession(false, false)
	end)
end


-- TODO:
-- make it so that you don't start a new window and session when the window is already there
-- path shortener: some paths could be very long
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

-- finished:
-- make into a plugin, call it quick-projects-nvim


M.quickProjects = function()
	require("telescope.builtin").live_grep({
		prompt_title =  "quick projects >",
		cwd = "~/.vim/quick_projects/",

		attach_mappings = function(prompt_bufnr, map)
			selectProject(prompt_bufnr, map)
			return true
		end
	})
end


return M
