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



local function tmuxSystemCmd(attempt_vim_session, project_dir, session_name, window_name)
	local make_dir = makeDir(project_dir)
	local nvim_open_mode = nvimOpenMode(attempt_vim_session, project_dir)

	local has_session = vim.fn.system("tmux has-session -t\"" .. session_name .. "\"")
	local session_not_exist = string.len(has_session) ~= 0

	local has_window = vim.fn.system("tmux has-session -t \"" .. session_name .. ":" .. window_name .. "\"")
	local window_not_exist = string.len(has_window) ~= 0

	local output_system_cmd = ""
	if session_not_exist then
		output_system_cmd = "tmux new -d -s \"" .. session_name .. "\" -n \"" .. window_name .. "\" \"" .. make_dir .. "cd " .. project_dir .. "; nvim " .. nvim_open_mode .."; $SHELL\" && "
	elseif window_not_exist then
		output_system_cmd = "tmux neww -n \"" .. window_name .. "\" -t \"" .. session_name .. ":\" \"" .. make_dir .. "cd " .. project_dir .. "; nvim " .. nvim_open_mode .."; $SHELL\" && "
	end
	output_system_cmd = output_system_cmd .. "tmux switch-client -t \"" .. session_name .. ":" .. window_name .. "\""
	return output_system_cmd
end

local function linuxSystemCmd(use_tabs, attempt_vim_session, project_dir)
	local tab = ""
	if use_tabs then
		tab = "--tab "
	end

	local make_dir = makeDir(project_dir)
	local nvim_open_mode = nvimOpenMode(attempt_vim_session, project_dir)

	return	"gnome-terminal " .. tab .. "-- bash -c '".. make_dir .. "cd " .. project_dir .. "; nvim " .. nvim_open_mode .. "; $SHELL'"
end

local function getSessionName(file_name)
	file_name = vim.fn.substitute(file_name, ".txt", "", "g")
	return vim.fn.substitute(file_name, "./", "", "g")
end

local function compressDirectoryPath(path)
	-- problem: compressing paths may lead to tmux window name collisions
	-- an idea: create a tree for each character, then remove nodes that are not needed, then search through the tree and output the formatted strings to another file (probably a bit naive)
	-- note that in lua [[]] double brackets used to make delimiting backslashes easier
	-- return vim.fn.substitute(path, [[\(/[^/]*/\)$\|\(/\.\?.\)[^/]*]], [[\1\2]], "g")
	return path
end

local function getWindowName(project_dir)
	project_dir = compressDirectoryPath(project_dir)
	-- fixes bug where you try to open a window that has a prefix of another window name
		-- ~/.dotfiles/nvim/.vim/ (assume that this is open)
		-- ~/.dotfiles/ (then try opening this)
	project_dir = project_dir .. " "
	-- fixes bug where . is a special character for tmux
		-- ~/.dotfiles/nvim/.vim/ (this is the original)
		-- ~/.dotfiles/nvim/<dot>vim/ (this is the replaced)
	return vim.fn.substitute(project_dir, "\\.", "<dot>", "g")
end

local function selectProject(prompt_bufnr, map)
	local function switchSession(use_tabs, attempt_vim_session)
		local content = require('telescope.actions.state').get_selected_entry(prompt_bufnr)
		-- P(content)
		local session_name = getSessionName(content.filename)
		local project_dir = content.text
		local window_name = getWindowName(project_dir)

		local system_cmd
		if vim.fn.getenv("TMUX") == vim.NIL then
			system_cmd = linuxSystemCmd(use_tabs, attempt_vim_session, project_dir)
			print(system_cmd)
		else
			system_cmd = tmuxSystemCmd(attempt_vim_session, project_dir, session_name, window_name)
			print(system_cmd)
		end

		P(vim.fn.system(system_cmd))
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
-- path shortener: some paths could be very long

-- finished:
-- make into a plugin, call it quick-projects-nvim
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
		cwd = "~/.config/.quick_projects/",

		attach_mappings = function(prompt_bufnr, map)
			selectProject(prompt_bufnr, map)
			return true
		end
	})
end

return M
