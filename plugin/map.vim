
if has('nvim') && exists('g:enable_quick_projects_default_mappings')
	lua require('quick_projects')
	nnoremap <leader>qp <cmd>lua RELOAD('quick_projects.builtins').quickProjects()<cr>
endif
