
if has('nvim') && exists('g:enable_quick_projects_default_mappings')
	echo "hello world"
	lua require('quick_projects')
	nnoremap <leader>tqp <cmd>lua RELOAD('quick_projects.builtins').quickProjects()<cr>
endif
