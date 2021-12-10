local M = {

}

M.setup = function(config)
	-- overrides any configs
	config = config or {}
	M._config = M._config or {}
	M._config = vim.tbl_deep_extend("force", M._config, config)
end


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
	project_dir = string.format("%s ", project_dir)
	-- fixes bug where . is a special character for tmux
		-- ~/.dotfiles/nvim/.vim/ (this is the original)
		-- ~/.dotfiles/nvim/<dot>vim/ (this is the replaced)
	return vim.fn.substitute(project_dir, "\\.", "<dot>", "g")
end

local function GetMarkFile(config)
	config = config or {} -- only happens when called by addQuickMark()
	return vim.fn.expand(config.cwd or M._config.cwd) .. (config.dir or M._config.generalMarks.dir) .. "/" .. (config.file or M._config.generalMarks.file)
end

local function addQuickMark(file_name, text)
	local output = file_name .. M._config.generalMarks.split_character .. text
	-- P("output : ", output )
	local output_file = GetMarkFile()
	vim.fn.writefile({output}, output_file, "a")
	P(string.format('writing "%s" to %s', output, output_file))
end

local function switchSession(tmux, linux_terminal, attempt_vim_session, content)
	local session_name = getSessionName(content.filename)
	local project_dir = content.text
	local window_name = getWindowName(project_dir)

	local system_cmd
	-- tmux gets first priority
	if tmux.enable and vim.fn.getenv("TMUX") ~= vim.NIL then
		system_cmd = tmuxSystemCmd(attempt_vim_session, project_dir, session_name, window_name)
	elseif linux_terminal.enable then
		system_cmd = linuxSystemCmd(linux_terminal.use_tabs, attempt_vim_session, project_dir)
	end
	P("exec system_cmd:", system_cmd)
	if system_cmd then
		local returned = vim.fn.system(system_cmd)
		P("returned:", returned)
	end
end

local function switchSessionFromMarks(tmux, linux_terminal, attempt_vim_session, raw_content)
	local content = {}
	content.filename = vim.fn.substitute(raw_content, M._config.generalMarks.split_character .. '.*', '', '')
	content.text = vim.fn.substitute(raw_content, '.*' .. M._config.generalMarks.split_character, '', '')
	-- for some strange reason there is this pesky d10 ascii character that is on this string
	-- local asc = string.byte(string.sub(content.text, -1))
	-- P("asc : ", asc )
	content.text = vim.fn.substitute(content.text, '[\\d10]$', '', '')
	switchSession(tmux, linux_terminal, attempt_vim_session, content)
end


local function selectProject(prompt_bufnr, map, qualname_builtin)
	local function getContents()
		local content = require('telescope.actions.state').get_selected_entry(prompt_bufnr)
		require('telescope.actions').close(prompt_bufnr)
		return content
	end
	for _, v in pairs(M._config.mappings) do
		map(v.mode, v.key, function()
			local content = getContents()
			if qualname_builtin == "quickProjects" then
				if v.tmux.add_mark then
					addQuickMark(content.filename, content.text)
				end
				switchSession(v.tmux, v.linux_terminal, v.attempt_vim_session, content)
			elseif qualname_builtin == "quickMarks" then
				switchSessionFromMarks(v.tmux, v.linux_terminal, v.attempt_vim_session, content.text)
			end
		end)
	end
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

M.quickProjects = function(config)
	-- update config if necessary
	config = config or {}
	config = vim.tbl_deep_extend("force", M._config.quickProjects, config)

	require("telescope.builtin").live_grep({
		prompt_title =  config.prompt_title,
		cwd = (config.cwd or M._config.cwd) .. config.dir,

		attach_mappings = function(prompt_bufnr, map)
			selectProject(prompt_bufnr, map, "quickProjects")
			return true
		end
	})
end

M.quickMarks = function(config)
	-- update config if necessary
	config = config or {}
	config = vim.tbl_deep_extend("force", M._config.quickMarks, config)

	require("telescope.builtin").live_grep({
		prompt_title =  config.prompt_title,
		cwd = (config.cwd or M._config.cwd) .. (config.dir or M._config.generalMarks.dir),
		attach_mappings = function(prompt_bufnr, map)
			selectProject(prompt_bufnr, map, "quickMarks")
			return true
		end
	})
end

M.navMark = function(config)
	config = config or {}
	config = vim.tbl_deep_extend("force", M._config.navMark, config)
	local output_file = GetMarkFile(config)
	local raw_content = vim.fn.system(string.format('sed -n %dp %s', config.idx, output_file))
	switchSessionFromMarks(config.tmux, config.linux_terminal, config.attempt_vim_session, raw_content)
end

return M
