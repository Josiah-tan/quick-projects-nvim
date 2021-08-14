-- for printing lua tables
P = function(v)
	print(vim.inspect(v))
	return v
end

-- re sources luafiles
RELOAD = function(package_reload)
	-- so this reloads the imported package, so any updates that you make in the lua file will be shown
	package.loaded[package_reload] = nil
	-- and this imports the package
	return require(package_reload)
end
