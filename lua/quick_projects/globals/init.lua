
QuickProjectsDebugModeOn = false

-- M.setup = function(debug_mode_on)
-- 	M.debug_mode_on = debug_mode_on or false
-- 	-- -- overrides any configs
-- 	-- config = config or {}
-- 	-- M._config = M._config or {}
-- 	-- M._config = vim.tbl_deep_extend("force", M._config, config)
-- end


-- for printing lua tables
P = function(v1, v2)
	local _P = function(v)
		if type(v) == 'table' then
			return vim.inspect(v)
		else
			return v
		end
	end
	-- print(M.debug_mode_on)
	-- print(vim.inspect(M))
	-- print("oiwhehreow")
	-- print(type(v1) == 'string', type(v2))
	-- print("asdf")
	if QuickProjectsDebugModeOn then
		if v2 then
			print(_P(v1), _P(v2))
			return v2
		else
			print(_P(v1))
			return v1
		end
	end
end

-- re sources luafiles
RELOAD = function(package_reload)
	-- so this reloads the imported package, so any updates that you make in the lua file will be shown
	package.loaded[package_reload] = nil
	-- and this imports the package
	return require(package_reload)
end

return M
