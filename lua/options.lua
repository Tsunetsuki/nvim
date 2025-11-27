vim.g.mapleader = " "
vim.opt.number = true
vim.opt.relativenumber = true

vim.opt.splitbelow = true
vim.opt.splitright = true

vim.opt.expandtab = true
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.wrap = false
vim.opt.clipboard = "unnamedplus"
vim.opt.scrolloff = 999

vim.opt.virtualedit = "block"

-- open preview e.g. for replaces
vim.opt.inccommand = "split"

vim.opt.ignorecase = true

vim.opt.termguicolors = true

vim.opt.smartindent = true
vim.opt.hlsearch = false
vim.opt.incsearch = true
vim.opt.swapfile = false

-- vim.opt.foldmethod = "expr"
-- vim.opt.foldexpr = "nvim_treesitter#foldexpr()"
vim.opt.foldmethod = "indent"
vim.opt.foldenable = false

local autocmd = vim.api.nvim_create_autocmd

autocmd("FileType", {
	pattern = { "tex" },
	callback = function()
		vim.opt_local.wrap = true
		vim.cmd("setlocal spell spelllang=en_us")
		vim.g.vimtex_quickfix_ignore_filters = {
			"Underfull",
			"Overfull",
		}
	end,
})

autocmd("FileType", {
	pattern = "text", -- applies to txt files
	callback = function()
		vim.opt_local.wrap = true
	end,
})

autocmd("FileType", {
	pattern = "py",
	callback = function()
		vim.api.nvim_set_keymap("n", "<leader>r", [[:lua ExecutePythonFile()<CR>]], { noremap = true, silent = true })

		function ExecuteCurrentPythonFile()
			local file_path = vim.fn.expand("%:p")
			local dir_path = vim.fn.expand("%:p:h")

			-- Open a terminal and execute the file
			vim.cmd("split | terminal")
			vim.cmd(
				string.format('call jobsend(&channel, "cd %s && set PYTHONPATH=. && python %s\n")', dir_path, file_path)
			)
		end
	end,
})

autocmd("VimEnter", {
	callback = function()
		--NVIM_ENTER=1
		vim.cmd([[call chansend(v:stderr, "\033]1337;SetUserVar=NVIM_ENTER=MQ==\007")]])
	end,
})

autocmd("VimLeavePre", {
	callback = function()
		--NVIM_ENTER=0
		vim.cmd([[call chansend(v:stderr, "\033]1337;SetUserVar=NVIM_ENTER=MA==\007")]])
	end,
})

-- set neovim's python venv (for molten's python deps)
vim.g.python3_host_prog = vim.fn.expand("~/.virtualenvs/neovim/bin/python3")
