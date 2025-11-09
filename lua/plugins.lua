if vim.g.vscode then
	return {
		{
			"kylechui/nvim-surround",
			config = function()
				require("nvim-surround").setup()
			end,
		},
		{
			"m4xshen/autoclose.nvim",
			config = function()
				require("autoclose").setup({
					options = {
						disable_when_touch = true,
						touch_regex = "[%w(%[{]",
						disable_command_mode = true,
					},
				})
			end,
		},
	}
end

return {
	{
		"askfiy/visual_studio_code",
		config = function()
			require("visual_studio_code").setup({
				mode = "dark",
			})
			vim.cmd.colorscheme("visual_studio_code")
		end,
	},
	-- {
	--     "rebelot/kanagawa.nvim",
	--     config = function()
	--         vim.cmd("colorscheme kanagawa")
	--     end,
	--
	-- },
	{
		"nvim-treesitter/nvim-treesitter",
		config = function()
			require("nvim-treesitter.configs").setup({
				ensure_installed = {
					"c",
					"lua",
					"vim",
					"vimdoc",
					"query",
					"markdown",
					"markdown_inline",
					"python",
					"typescript",
					"sql",
					"latex",
				},

				-- Recommendation: set to false if you don"t have `tree-sitter` CLI installed locally
				auto_install = true,

				highlight = {
					enable = true,
				},
				incremental_selection = {
					enable = true,
					keymaps = {
						init_selection = "<Leader>ss", -- set to `false` to disable one of the mappings
						node_incremental = "<Leader>si",
						scope_incremental = "<Leader>sc",
						node_decremental = "<Leader>sd",
					},
				},
				textobjects = {
					select = {
						enable = true,

						-- Automatically jump forward to textobj, similar to targets.vim
						lookahead = true,

						keymaps = {
							-- You can use the capture groups defined in textobjects.scm
							-- You can optionally set descriptions to the mappings (used in the desc parameter of
							-- nvim_buf_set_keymap) which plugins like which-key display
							["af"] = "@function.outer",
							["if"] = "@function.inner",
							["ac"] = "@class.outer",
							["ic"] = { query = "@class.inner", desc = "Select inner part of a class region" },
							-- You can also use captures from other query groups like `locals.scm`
							["as"] = { query = "@scope", query_group = "locals", desc = "Select language scope" },
							["aq"] = "@parameter.outer",
							["iq"] = "@parameter.inner",

							["ai"] = "@attribute.outer",
							["ii"] = "@attribute.inner",
						},
						selection_modes = {
							["@parameter.outer"] = "v", -- charwise
							["@function.outer"] = "v",
							["@class.outer"] = "v",
						},
						include_surrounding_whitespace = true,
					},
				},
			})
		end,
	},
	{
		"nvim-treesitter/nvim-treesitter-textobjects",
	},
	--------------------------------------------------------LSP SECTION START

	{
		"williamboman/mason.nvim",
		-- config = function()
		-- 	require("mason").setup()
		-- end,
	},
	{
		"neovim/nvim-lspconfig",

		-- options copied from "manual setup" part of https://lsp-zero.netlify.app/docs/guide/lazy-loading-with-lazy-nvim.html
		cmd = "LspInfo",
		event = { "BufReadPre", "BufNewFile" },
		dependencies = {
			{ "hrsh7th/cmp-nvim-lsp" },
		},
		init = function()
			-- Reserve a space in the gutter
			-- This will avoid an annoying layout shift in the screen
			vim.opt.signcolumn = "yes"
		end,
		config = function()
			-- this works
			vim.lsp.config["pyright"] = {
				settings = {
					python = {
						analysis = {
							autoImportCompletions = true,
							diagnosticMode = "workspace", -- <-- analyze all files, not just open ones
							autoSearchPaths = true,
							useLibraryCodeForTypes = true,
						},
					},
				},
			}

			local lsp_defaults = require("lspconfig").util.default_config
			-- local lsp_defaults = vim.lsp.config().util.default_config

			-- require("lspconfig").pyright.setup({
			-- 	settings = {
			-- 		python = {
			-- 			analysis = {
			-- 				autoImportCompletions = true,
			-- 				diagnosticMode = "workspace", -- <-- analyze all files, not just open ones
			-- 				autoSearchPaths = true,
			-- 				useLibraryCodeForTypes = true,
			-- 			},
			-- 		},
			-- 	},
			-- })

			-- vim.lsp.config("black")
			vim.lsp.enable("pyright")
			-- vim.lsp.enable("black")

			-- Add cmp_nvim_lsp capabilities settings to lspconfig
			-- This should be executed before you configure any language server
			lsp_defaults.capabilities =
				vim.tbl_deep_extend("force", lsp_defaults.capabilities, require("cmp_nvim_lsp").default_capabilities())
			vim.api.nvim_create_autocmd("LspAttach", {
				desc = "LSP actions",
				callback = function(event)
					local opts = { buffer = event.buf }

					vim.keymap.set("n", "K", "<cmd>lua vim.lsp.buf.hover()<cr>", opts)
					vim.keymap.set("n", "gd", "<cmd>lua vim.lsp.buf.definition()<cr>", opts)
					vim.keymap.set("n", "gD", "<cmd>lua vim.lsp.buf.declaration()<cr>", opts)
					vim.keymap.set("n", "gi", "<cmd>lua vim.lsp.buf.implementation()<cr>", opts)
					vim.keymap.set("n", "go", "<cmd>lua vim.lsp.buf.type_definition()<cr>", opts)
					vim.keymap.set("n", "gr", "<cmd>lua vim.lsp.buf.references()<cr>", opts)
					vim.keymap.set("n", "gs", "<cmd>lua vim.lsp.buf.signature_help()<cr>", opts)
					vim.keymap.set("n", "<F2>", "<cmd>lua vim.lsp.buf.rename()<cr>", opts)
					vim.keymap.set(
						{ "n", "x", "i" },
						"<F3>",
						'<cmd>lua vim.lsp.buf.format({async = true, filter = function(client_) return client_.name ~= "ts_ls" end;})<cr>',
						opts
					)
					vim.keymap.set("n", "<leader>ca", "<cmd>lua vim.lsp.buf.code_action()<cr>", opts)
				end,
			})
		end,
	},
	{
		"williamboman/mason-lspconfig.nvim",
		dependencies = { "mason.nvim", "neovim/nvim-lspconfig" },
		config = function()
			require("mason").setup()

			require("mason-lspconfig").setup({
				ensure_installed = { "clangd", "jsonls", "lua_ls", "pyright", "ts_ls" },
				automatic_installation = true,

				-- handlers = {
				-- 	function(server_name)
				-- 		if server_name == "ltex" then
				-- 			local path = vim.fn.stdpath("config") .. "/spell/en.utf-8.add"
				-- 			local words = {}
				-- 			for word in io.open(path, "r"):lines() do
				-- 				table.insert(words, word)
				-- 			end
				--
				-- 			require("lspconfig").ltex.setup({
				-- 				settings = {
				-- 					ltex = {
				-- 						disabledRules = {
				-- 							["en-US"] = {
				-- 								"COMMA_PARENTHESIS_WHITESPACE",
				-- 								"SMALL_NUMBER_OF",
				-- 								"LARGE_NUMBER_OF",
				-- 								"MORFOLOGIK_RULE_EN_US",
				-- 								"WHETHER",
				-- 								"Y_ALL",
				-- 							},
				-- 						},
				-- 						dictionary = {
				-- 							en = words,
				-- 						},
				-- 					},
				-- 				},
				-- 			})
				-- 		else
				-- 			require("lspconfig")[server_name].setup({})
				-- 		end
				-- 	end,
				-- },
			})
		end,
	},
	{
		"nvimtools/none-ls.nvim",
		dependencies = {
			"nvimtools/none-ls-extras.nvim",
		},
	},

	{
		"jay-babu/mason-null-ls.nvim",
		event = { "BufReadPre", "BufNewFile" },
		dependencies = {
			"williamboman/mason.nvim",
			"nvimtools/none-ls.nvim",
		},
		config = function()
			-- require("your.null-ls.config") -- require your null-ls config here (example below)
			-- require("nonels").setup()
			require("mason").setup()

			require("mason-null-ls").setup({
				ensure_installed = { "black" },
				automatic_installation = true,
				-- automatic_setup = true,
				handlers = {},
			})

			local augroup = vim.api.nvim_create_augroup("LspFormatting", {})

			local null_ls = require("null-ls")
			null_ls.setup({
				sources = {
					-- require("none-ls.diagnostics.eslint"), -- requires none-ls-extras.nvim
					-- null_ls.builtins.formatting.prettier,
					-- -- null_ls.builtins.formatting.prettierd,
					null_ls.builtins.formatting.black,
					-- null_ls.builtins.formatting.isort, -- for Python imports
					-- null_ls.builtins.formatting.shfmt,
					-- null_ls.builtins.formatting.lua_ls
					-- null_ls.builtins.formatting.stylua,

					-- null_ls.builtins.diagnostics.shellcheck,
					-- null_ls.builtins.code_actions.shellcheck,
				},
				-- you can reuse a shared lspconfig on_attach callback here
				on_attach = function(client, bufnr)
					if client.supports_method("textDocument/formatting") then
						vim.api.nvim_clear_autocmds({ group = augroup, buffer = bufnr })
						-- gets executed when file is saved
						vim.api.nvim_create_autocmd("BufWritePre", {
							group = augroup,
							buffer = bufnr,
							callback = function()
								-- on 0.8, you should use vim.lsp.buf.format({ bufnr = bufnr }) instead
								-- on later neovim version, you should use vim.lsp.buf.format({ async = false }) instead
								vim.lsp.buf.format({
									async = false,
									-- ts_ls conflicts with eslint/prettier, e.g. puts spaces between empty {}
									filter = function(client_)
										return client_.name ~= "ts_ls"
									end,
								})
							end,
						})
					end
				end,
			})
		end,
	},
	--------------------------------------------------------LSP SECTION END
	{
		"nvim-tree/nvim-web-devicons",
	},
	{
		"nvim-telescope/telescope.nvim",
		tag = "0.1.8",
		dependencies = { "nvim-lua/plenary.nvim" },
		config = function()
			local builtin = require("telescope.builtin")
			--ignore some file types. pt files are models and will cause telescope to freeze trying to preview
			require("telescope").setup({
				defaults = {
					file_ignore_patterns = {
						-- "%.ipynb",
						"%.pt",
						"%.lock",
						"%.mp3",
						"%.png",
						"%.jpg",
						"%.jpeg",
						"%.swp",
						"venv/.*",
					},
				},
			})

			vim.keymap.set("n", "<leader>pf", builtin.find_files, { desc = "Telescope find files" })
			vim.keymap.set("n", "<C-p>", builtin.git_files, { desc = "Telescope git files" })
			vim.keymap.set("n", "<leader>fg", builtin.live_grep, { desc = "Telescope live grep" })
			vim.keymap.set("n", "<leader>fb", builtin.buffers, { desc = "Telescope buffers" })
			vim.keymap.set("n", "<leader>fh", builtin.help_tags, { desc = "Telescope help tags" })
			-- project search for string
			vim.keymap.set("n", "<leader>ps", function()
				builtin.grep_string({ search = vim.fn.input("Grep > ") })
			end)
		end,
	},
	{
		"nvim-telescope/telescope-fzf-native.nvim",
		build = "cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release",
	},

	-- lsp-zero: seems redundant due to nonels
	-- {
	-- 	"VonHeikemen/lsp-zero.nvim",
	-- 	branch = "v4.x",
	-- 	config = false,
	-- },

	{
		"hrsh7th/cmp-nvim-lsp",
	},
	{
		"hrsh7th/nvim-cmp",
		config = function()
			---
			-- Autocompletion setup
			---
			local cmp = require("cmp")

			cmp.setup({
				sources = {
					{ name = "path" },
					{ name = "nvim_lsp" },
					{ name = "luasnip", keyword_length = 2 },
					{ name = "buffer", keyword_length = 3 },
				},
				window = {
					completion = cmp.config.window.bordered(),
					documentation = cmp.config.window.bordered(),
				},
				snippet = {
					expand = function(args)
						-- You need Neovim v0.10 to use vim.snippet
						vim.snippet.expand(args.body)
						-- require('luasnip').lsp_expand(args.body)
					end,
				},
				mapping = cmp.mapping.preset.insert({
					["<C-b>"] = cmp.mapping.scroll_docs(-4),
					["<C-f>"] = cmp.mapping.scroll_docs(4),
					["<C-s>"] = cmp.mapping.complete(), -- ctrl-space does not work (seems to be due to cmd)
					["<CR>"] = cmp.mapping.confirm({ select = true }),
				}),
				completion = {
					completeopt = "menu,menuone,noinsert",
				},
			})
		end,
	},
	{
		"NMAC427/guess-indent.nvim",
		config = function()
			require("guess-indent").setup({})
		end,
	},
	{
		-- closes ()[]{}"" etc.
		"m4xshen/autoclose.nvim",
		config = function()
			require("autoclose").setup({
				options = {
					disable_when_touch = true,
					touch_regex = "[%w(%[{]",
					disable_command_mode = true,
				},
			})
		end,
	},
	{
		-- venv-selector is disabled because it breaks none-ls

		-- "linux-cultist/venv-selector.nvim",
		--   dependencies = {
		-- 	"neovim/nvim-lspconfig",
		-- 	{ "nvim-telescope/telescope.nvim", branch = "0.1.x", dependencies = { "nvim-lua/plenary.nvim" } }, -- optional: you can also use fzf-lua, snacks, mini-pick instead.
		--   },
		--   ft = "python", -- Load when opening Python files
		--   keys = {
		-- 	{ "<leader>v", "<cmd>VenvSelect<cr>" }, -- Open picker on keymap
		--   },
		--   opts = {
		-- 	search = {},
		-- 	options = {
		-- 		notify_user_on_venv_activation = true, -- doesnt work anymore
		-- 		on_venv_activate_callback = function(venv_path, venv_python)
		-- 		-- Re-source null-ls after venv change
		-- 			-- Reconfigure none-ls after venv change
		--
		-- 		local null_ls = require("null-ls")
		-- 		null_ls.setup({ sources = { null_ls.builtins.formatting.black }})
		-- 		vim.notify("Reloaded null-ls with new venv", vim.log.levels.INFO)
		-- 	  end,
		--
		-- require_lsp_activation = true
		-- 	}
		--   },
		--
		--
		--
		--
		-- -- config = function()
		-- -- 	require("venv-selector").setup({
		-- -- 		settings = {
		-- -- 			options = {
		-- -- 			},
		-- -- 		},
		-- -- 	})
		-- --
		-- -- 	-- function ExecuteCurrentPythonFile()
		-- -- 	-- 	local file_path = vim.fn.expand("%:p")
		-- -- 	-- 	local dir_path = vim.fn.getcwd() --vim.fn.expand('%:p:h')
		-- -- 	-- 	local venv = os.getenv("VIRTUAL_ENV") or os.getenv("CONDA_PREFIX")
		-- -- 	--
		-- -- 	-- 	if venv == nil then
		-- -- 	-- 		return
		-- -- 	-- 	end
		-- -- 	--
		-- -- 	-- 	local venv_activation_string
		-- -- 	-- 	if string.find(venv, "conda", 1, true) then
		-- -- 	-- 		venv_activation_string = string.format("conda activate %s", venv)
		-- -- 	-- 	else
		-- -- 	-- 		venv_activation_string = string.format("%s\\Scripts\\activate.bat", venv)
		-- -- 	-- 	end
		-- -- 	--
		-- -- 	-- 	vim.cmd("vsplit | terminal")
		-- -- 	-- 	vim.fn.feedkeys("i", "n")
		-- -- 	-- 	vim.fn.feedkeys(
		-- -- 	-- 		string.format(
		-- -- 	-- 			"cd %s && set PYTHONPATH=. && %s && python %s\n",
		-- -- 	-- 			dir_path,
		-- -- 	-- 			venv_activation_string,
		-- -- 	-- 			file_path
		-- -- 	-- 		)
		-- -- 	-- 	)
		-- -- 	-- end
		-- -- 	--
		-- -- 	-- vim.api.nvim_set_keymap(
		-- -- 	-- 	"n",
		-- -- 	-- 	"<leader><F5>",
		-- -- 	-- 	[[:lua ExecuteCurrentPythonFile()<CR>]],
		-- -- 	-- 	{ noremap = true, silent = true }
		-- -- 	-- )
		-- -- 	-- vim.api.nvim_set_keymap('n', '<leader><F5>', function() ExecuteCurrentPythonFile() end,
		-- -- 	--     { noremap = true, silent = true })
		-- -- end,
	},

	{
		"numToStr/Comment.nvim",
		config = function()
			require("Comment").setup()
		end,
	},
	{
		"kylechui/nvim-surround",
		config = function()
			require("nvim-surround").setup()
		end,
	},
	{
		"windwp/nvim-ts-autotag",
		config = function()
			require("nvim-ts-autotag").setup({
				opts = {
					-- Defaults
					enable_close = true, -- Auto close tags
					enable_rename = true, -- Auto rename pairs of tags
					enable_close_on_slash = false, -- Auto close on trailing </
				},
				-- Also override individual filetype configs, these take priority.
				-- Empty by default, useful if one of the "opts" global settings
				-- doesn't work well in a specific filetype
				per_filetype = {
					["html"] = {
						enable_close = false,
					},
				},
			})
		end,
	},

	-- nvim-lspimport: not working
	-- {
	-- 	"stevanmilic/nvim-lspimport",
	-- 	config = function()
	-- 		vim.keymap.set("n", "<leader>i", require("lspimport").import, { noremap = true })
	-- 	end,
	-- },

	{
		"kiyoon/python-import.nvim",
		-- build = "pipx install . --force",
		build = "uv tool install . --force --reinstall",
		keys = {
			{
				"<M-CR>",
				function()
					require("python_import.api").add_import_current_word_and_notify()
				end,
				mode = { "i", "n" },
				silent = true,
				desc = "Add python import",
				ft = "python",
			},
			{
				"<M-CR>",
				function()
					require("python_import.api").add_import_current_selection_and_notify()
				end,
				mode = "x",
				silent = true,
				desc = "Add python import",
				ft = "python",
			},
			{
				"<space>i",
				function()
					require("python_import.api").add_import_current_word_and_move_cursor()
				end,
				mode = "n",
				silent = true,
				desc = "Add python import and move cursor",
				ft = "python",
			},
			{
				"<space>i",
				function()
					require("python_import.api").add_import_current_selection_and_move_cursor()
				end,
				mode = "x",
				silent = true,
				desc = "Add python import and move cursor",
				ft = "python",
			},
			{
				"<space>tr",
				function()
					require("python_import.api").add_rich_traceback()
				end,
				silent = true,
				desc = "Add rich traceback",
				ft = "python",
			},
		},
		opts = {
			-- Example 1:
			-- Default behaviour for `tqdm` is `from tqdm.auto import tqdm`.
			-- If you want to change it to `import tqdm`, you can set `import = {"tqdm"}` and `import_from = {tqdm = vim.NIL}` here.
			-- If you want to change it to `from tqdm import tqdm`, you can set `import_from = {tqdm = "tqdm"}` here.

			-- Example 2:
			-- Default behaviour for `logger` is `import logging`, ``, `logger = logging.getLogger(__name__)`.
			-- If you want to change it to `import my_custom_logger`, ``, `logger = my_custom_logger.get_logger()`,
			-- you can set `statement_after_imports = {logger = {"import my_custom_logger", "", "logger = my_custom_logger.get_logger()"}}` here.
			extend_lookup_table = {
				---@type string[]
				import = {
					-- "tqdm",
				},

				---@type table<string, string|vim.NIL>
				import_as = {
					-- These are the default values. Here for demonstration.
					-- np = "numpy",
					-- pd = "pandas",
				},

				---@type table<string, string|vim.NIL>
				import_from = {
					-- tqdm = vim.NIL,
					-- tqdm = "tqdm",
				},

				---@type table<string, string[]|vim.NIL>
				statement_after_imports = {
					-- logger = { "import my_custom_logger", "", "logger = my_custom_logger.get_logger()" },
				},
			},

			---Return nil to indicate no match is found and continue with the default lookup
			---Return a table to stop the lookup and use the returned table as the result
			---Return an empty table to stop the lookup. This is useful when you want to add to wherever you need to.
			---@type fun(winnr: integer, word: string, ts_node: TSNode?): string[]?
			custom_function = function(winnr, word, ts_node)
				-- if vim.endswith(word, "_DIR") then
				--   return { "from my_module import " .. word }
				-- end
			end,
		},
	},
	{
		"rmagatti/auto-session",
		lazy = false,

		---enables autocomplete for opts
		---@module "auto-session"
		---@diagnostic disable-next-line: undefined-doc-name
		---@type AutoSession.Config
		opts = {
			suppressed_dirs = { "~/", "~/Projects", "~/Downloads", "/" },
			-- log_level = "debug",
		},
		config = function()
			require("auto-session").setup({})
		end,
	},
	{
		"folke/trouble.nvim",
		opts = {}, -- for default options, refer to the configuration section for custom setup.
		cmd = "Trouble",
		keys = {
			{
				"<leader>xx",
				"<cmd>Trouble diagnostics toggle<cr>",
				desc = "Diagnostics (Trouble)",
			},
			{
				"<leader>xX",
				"<cmd>Trouble diagnostics toggle filter.buf=0<cr>",
				desc = "Buffer Diagnostics (Trouble)",
			},
			{
				"<leader>cs",
				"<cmd>Trouble symbols toggle focus=false<cr>",
				desc = "Symbols (Trouble)",
			},
			{
				"<leader>cl",
				"<cmd>Trouble lsp toggle focus=false win.position=right<cr>",
				desc = "LSP Definitions / references / ... (Trouble)",
			},
			{
				"<leader>xL",
				"<cmd>Trouble loclist toggle<cr>",
				desc = "Location List (Trouble)",
			},
			{
				"<leader>xQ",
				"<cmd>Trouble qflist toggle<cr>",
				desc = "Quickfix List (Trouble)",
			},
		},
	},
	{
		"norcalli/nvim-colorizer.lua",
		-- preview hex color values
		config = function()
			require("colorizer").setup()
		end,
	},
	{
		-- multiline cursors
		"mg979/vim-visual-multi",
	},
	-- {
	--     'stevearc/oil.nvim',
	--     ---@module 'oil'
	--     ---@type oil.SetupOpts
	--     opts = {},
	--     -- Optional dependencies
	--     dependencies = { { "echasnovski/mini.icons", opts = {} } },
	--     -- dependencies = { "nvim-tree/nvim-web-devicons" }, -- use if you prefer nvim-web-devicons
	--     -- Lazy loading is not recommended because it is very tricky to make it work correctly in all situations.
	--     lazy = false,
	--     config = function()
	--         require("oil").setup()
	--     end,
	-- }
	-- {
	-- 	"kiyoon/treesitter-indent-object.nvim",
	-- 	keys = {
	-- 		{
	-- 			"ai",
	-- 			function()
	-- 				require("treesitter_indent_object.textobj").select_indent_outer()
	-- 			end,
	-- 			mode = { "x", "o" },
	-- 			desc = "Select context-aware indent (outer)",
	-- 		},
	-- 		{
	-- 			"aI",
	-- 			function()
	-- 				require("treesitter_indent_object.textobj").select_indent_outer(true)
	-- 			end,
	-- 			mode = { "x", "o" },
	-- 			desc = "Select context-aware indent (outer, line-wise)",
	-- 		},
	-- 		{
	-- 			"ii",
	-- 			function()
	-- 				require("treesitter_indent_object.textobj").select_indent_inner()
	-- 			end,
	-- 			mode = { "x", "o" },
	-- 			desc = "Select context-aware indent (inner, partial range)",
	-- 		},
	-- 		{
	-- 			"iI",
	-- 			function()
	-- 				require("treesitter_indent_object.textobj").select_indent_inner(true, "V")
	-- 			end,
	-- 			mode = { "x", "o" },
	-- 			desc = "Select context-aware indent (inner, entire range) in line-wise visual mode",
	-- 		},
	-- 	},
	-- },
	-- {
	--     "valentjn/ltex-ls",
	--     config = function()
	--         local path = vim.fn.stdpath("config") .. "/spell/en.utf-8.add"
	--         local words = {}
	--
	--         for word in io.open(path, "r"):lines() do
	--             table.insert(words, word)
	--         end
	--
	--         require 'lspconfig'.ltex.setup {
	--             settings = {
	--                 ltex = {
	--                     language = "en",                    -- Set the language (e.g., "en" for English)
	--                     diagnosticSeverity = "information", -- Adjust severity levels
	--                     --  "C:\\Users\\lpaal\\AppData\\Local\\nvim\\spell\\en.utf-8.add"llk
	--                     dictionary = {
	--                         en = words,
	--                     },
	--                 }
	--             }
	--         }
	--     end
	-- },
	{
		"nvim-treesitter/nvim-treesitter-context",
		config = function()
			require("treesitter-context").setup({
				enable = true, -- Enable this plugin (Can be enabled/disabled later via commands)
				multiwindow = false, -- Enable multiwindow support.
				max_lines = 0, -- How many lines the window should span. Values <= 0 mean no limit.
				min_window_height = 0, -- Minimum editor window height to enable context. Values <= 0 mean no limit.
				line_numbers = true,
				multiline_threshold = 1, -- Maximum number of lines to show for a single context
				trim_scope = "outer", -- Which context lines to discard if `max_lines` is exceeded. Choices: 'inner', 'outer'
				mode = "cursor", -- Line used to calculate context. Choices: 'cursor', 'topline'
				-- Separator between context and content. Should be a single character string, like '-'.
				-- When separator is set, the context will only show up when there are at least 2 lines above cursorline.
				-- separator = nil,
				separator = "-",
				zindex = 20, -- The Z-index of the context window
				on_attach = nil, -- (fun(buf: integer): boolean) return false to disable attaching
			})
		end,
	},
	{
		"NeogitOrg/neogit",
		dependencies = {
			"nvim-lua/plenary.nvim", -- required
			"sindrets/diffview.nvim", -- optional - Diff integration

			-- Only one of these is needed.
			"nvim-telescope/telescope.nvim", -- optional
			-- "ibhagwan/fzf-lua",      -- optional
			-- "echasnovski/mini.pick", -- optional
			-- "folke/snacks.nvim",     -- optional
		},
		config = function()
			vim.keymap.set("n", "<leader>g", ":Neogit<CR>")
		end,
	},
	{
		"alexghergh/nvim-tmux-navigation",

		config = function()
			local nvim_tmux_nav = require("nvim-tmux-navigation")

			nvim_tmux_nav.setup({
				disable_when_zoomed = true, -- defaults to false
			})

			vim.keymap.set("n", "<C-h>", nvim_tmux_nav.NvimTmuxNavigateLeft)
			vim.keymap.set("n", "<C-j>", nvim_tmux_nav.NvimTmuxNavigateDown)
			vim.keymap.set("n", "<C-k>", nvim_tmux_nav.NvimTmuxNavigateUp)
			vim.keymap.set("n", "<C-l>", nvim_tmux_nav.NvimTmuxNavigateRight)
			-- vim.keymap.set("n", "<C-\\>", nvim_tmux_nav.NvimTmuxNavigateLastActive)
			-- vim.keymap.set("n", "<C-Space>", nvim_tmux_nav.NvimTmuxNavigateNext)
		end,
	},
}
