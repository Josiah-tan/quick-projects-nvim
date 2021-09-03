# What Is quick-projects-nvim?

This is a neovim plugin used to navigate quickly between projects 

Here is a screening of the functionality that this plugin provides (TODO)

# Plugin Dependencies

- this requires you to get telescope and its own dependencies
	- Note that telescope is neovim 0.5 + only
		- so build your neovim from source, or get the latest release!
- I'm also assuming that you are using vim-plug here
	- but feel free to use whatever package manager that you like!

```viml
" This is a requirement, which implements some useful window management
"   items for neovim
Plug 'nvim-lua/popup.nvim'
Plug 'nvim-lua/plenary.nvim'

" fuzzy finder etc...
Plug 'nvim-telescope/telescope.nvim'	
" compiled fzy sorter (hence faster)
Plug 'nvim-telescope/telescope-fzy-native.nvim'

"Plugin for quick_projects
Plug 'Josiah-tan/quick-projects-nvim'
```

# Usage (Easy)
## Enabling Mappings

- assuming that you have downloaded this plugin (and it's dependencies), you can now enable the mappings!
	- by default the mappings are disabled
- the mapping to open up quick projects is:
	- <leader>qp

```viml
let g:enable_quick_projects_default_mappings = 1
```

## Creating Project Paths

- create a folder structure that looks like this:

- ~/.vim/quick\_projects
	- university.txt
		- ~/Desktop/uni/mechanics/
		- ~/Desktop/uni/electrical/
	- work.txt
		- ~/Desktop/work/resumes/
		- ~/Desktop/work/lectures/
	- personal.txt
		- ~/Desktop/personal/code/
		- ~/Desktop/personal/google_kickstart/

- when you run <leader>qp, and type "google" and you will see it pop up in the options

- After this press ctrl + s:
	- to open this up as a session
- After this press ctrl + t:
	- to open this up as a directory view

- if you selected "\~/Desktop/personal/google\_kickstart/", then it will create / change to a tmux session with name "personal", and window name "\~/Desktop/personal/google\_kickstart/"

# Usage (medium)

- if you want to you set your own remaps
- here is a remap that does the same thing:

```viml
if has('nvim')
	nnoremap <leader>qp <cmd>lua require('quick_projects.builtins').quickProjects()<cr>
end
```

# Usage (advanced)

- if you want to set your own remaps within the quickProject builtin you can (TODO)

# Configuring Telescope (Optional)

- you can checkout telescope's repository for all the defaults that are used
- however here are some defaults that I personally use

```viml
lua << EOF
local actions = require("telescope.actions")
require('telescope').setup {
	defaults = {
		file_sorter = require('telescope.sorters').get_fzy_sorter,
		prompt_prefix = ' >',
		color_devicons = true,

		file_previewer = require('telescope.previewers').vim_buffer_cat.new,
		grep_previewer = require('telescope.previewers').vim_buffer_vimgrep.new,
		qflist_previewer = require('telescope.previewers').vim_buffer_qflist.new,

		mappings = {
			i = {
				["<C-x>"] = false,
				["<C-q>"] = actions.send_to_qflist,
			},
		}
	},
	extensions = {
		fzy_native = {
			override_generic_sorter = false,
			override_file_sorter = true,
		}
	}
}

require('telescope').load_extension('fzy_native')
EOF

```

# Guidelines For Developers

- remove the plugin?
	- currently I'm doing this, but I'm sure there's a better way of managing everything
- set rtp (runtime path) to the repository

```viml
" here's an example of how you could do this
set rtp+=~/Desktop/josiah/neovim/quick_projects/
```

- then use a custom mapping like this to develop and test the code

```viml
nnoremap <leader>qp <cmd>lua RELOAD('quick_projects.builtins').quickProjects()<cr>
```

# TODO (README)

- add some testing procedures
- add links to other repositories
- add screening
- add customisation

