return {
    {
        "askfiy/visual_studio_code",
        config = function()
            require("visual_studio_code").setup({
                mode = "dark"
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
                ensure_installed = { "c", "lua", "vim", "vimdoc", "query", "markdown", "markdown_inline", "python", "typescript", "sql", "latex" },

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
    {
        "williamboman/mason.nvim",
        config = function()
            require("mason").setup()
        end,
    },
    {
        "williamboman/mason-lspconfig.nvim",
        dependencies = { "mason.nvim",
            "neovim/nvim-lspconfig",
        },
        config = function()
            require("mason-lspconfig").setup({
                ensure_installed = { "clangd", "jsonls", "lua_ls", "pyright", "ts_ls" },
                handlers = {
                    function(server_name)
                        if server_name == "ltex" then
                            local path = vim.fn.stdpath("config") .. "/spell/en.utf-8.add"
                            local words = {}
                            for word in io.open(path, "r"):lines() do
                                table.insert(words, word)
                            end

                            require("lspconfig").ltex.setup({
                                settings = {
                                    ltex = {
                                        disabledRules = {
                                            ["en-US"] = {
                                                "COMMA_PARENTHESIS_WHITESPACE",
                                                "SMALL_NUMBER_OF",
                                                "LARGE_NUMBER_OF",
                                                "MORFOLOGIK_RULE_EN_US",
                                                "WHETHER",
                                                "Y_ALL",
                                            }
                                        },
                                        dictionary = {
                                            en = words,
                                        },

                                    }
                                }
                            })
                        else
                            require("lspconfig")[server_name].setup({})
                        end
                    end,
                }
            })
        end
    },
    {
        "nvim-tree/nvim-web-devicons"
    },
    {
        "nvim-telescope/telescope.nvim",
        tag = "0.1.8",
        dependencies = { "nvim-lua/plenary.nvim" },
        config = function()
            local builtin = require("telescope.builtin")
            --ignore some file types. pt files are models and will cause telescope to freeze trying to preview
            require('telescope').setup { defaults = { file_ignore_patterns = { "%.ipynb", "%.pt", "%.lock", "%.mp3", "%.png", "%.jpg", "%.jpeg" } } }

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
        build =
        "cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release"
    },

    {
        "VonHeikemen/lsp-zero.nvim",
        branch = "v4.x",
        config = false,
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
            local lsp_defaults = require("lspconfig").util.default_config

            -- Add cmp_nvim_lsp capabilities settings to lspconfig
            -- This should be executed before you configure any language server
            lsp_defaults.capabilities = vim.tbl_deep_extend(
                "force",
                lsp_defaults.capabilities,
                require("cmp_nvim_lsp").default_capabilities()
            )
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
                    vim.keymap.set({ "n", "x", "i" }, "<F3>",
                        '<cmd>lua vim.lsp.buf.format({async = true, filter = function(client_) return client_.name ~= "ts_ls" end;})<cr>',
                        opts)
                    vim.keymap.set("n", " ca", "<cmd>lua vim.lsp.buf.code_action()<cr>", opts)
                end,
            })

            -- These are just examples. Replace them with the language
            -- servers you have installed in your system
            require("lspconfig").gleam.setup({})
            require("lspconfig").ocamllsp.setup({})
        end
    },
    {
        "hrsh7th/cmp-nvim-lsp"
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
                    { name = "buffer",  keyword_length = 3 },
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
                    completeopt = "menu,menuone,noinsert"
                }
            })
        end
    },
    {
        "NMAC427/guess-indent.nvim",
        config = function()
            require("guess-indent").setup {}
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
                }
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
        "linux-cultist/venv-selector.nvim",
        dependencies = {
            "neovim/nvim-lspconfig",
            "mfussenegger/nvim-dap", "mfussenegger/nvim-dap-python", --optional
            { "nvim-telescope/telescope.nvim", branch = "0.1.x", dependencies = { "nvim-lua/plenary.nvim" } },
        },
        lazy = false,
        branch = "regexp", -- This is the regexp branch, use this for the new version
        config = function()
            require("venv-selector").setup({
                settings = {
                    options = {
                        -- notify_user_on_venv_activation = true,
                    }
                }



            })

            function ExecuteCurrentPythonFile()
                local file_path = vim.fn.expand('%:p')
                local dir_path = vim.fn.getcwd() --vim.fn.expand('%:p:h')
                local venv = os.getenv("VIRTUAL_ENV") or os.getenv("CONDA_PREFIX")

                if venv == nil then
                    return
                end

                local venv_activation_string
                if string.find(venv, "conda", 1, true) then
                    venv_activation_string = string.format("conda activate %s", venv)
                else
                    venv_activation_string = string.format("%s\\Scripts\\activate.bat", venv)
                end

                vim.cmd("vsplit | terminal")
                vim.fn.feedkeys("i", "n")
                vim.fn.feedkeys(string.format('cd %s && set PYTHONPATH=. && %s && python %s\n',
                    dir_path,
                    venv_activation_string,
                    file_path))
            end

            vim.api.nvim_set_keymap('n', '<leader><F5>', [[:lua ExecuteCurrentPythonFile()<CR>]],
                { noremap = true, silent = true })
            -- vim.api.nvim_set_keymap('n', '<leader><F5>', function() ExecuteCurrentPythonFile() end,
            --     { noremap = true, silent = true })
        end,
        keys = {
            { '<leader>vs', '<cmd>VenvSelect<cr>' },
        },
    },
    {
        "none-ls-extras.nvim"
    },
    {
        "nvimtools/none-ls.nvim",
        config = function()
            local null_ls = require("null-ls")
            local augroup = vim.api.nvim_create_augroup("LspFormatting", {})

            null_ls.setup({
                sources = {
                    require("none-ls.diagnostics.eslint"), -- requires none-ls-extras.nvim
                    null_ls.builtins.formatting.prettier,
                    -- null_ls.builtins.formatting.prettierd,
                    null_ls.builtins.formatting.black,
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
                                    filter = function(client_) return client_.name ~= "ts_ls" end
                                })
                            end,
                        })
                    end
                end,
            })
        end,
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
                    enable_close = true,          -- Auto close tags
                    enable_rename = true,         -- Auto rename pairs of tags
                    enable_close_on_slash = false -- Auto close on trailing </
                },
                -- Also override individual filetype configs, these take priority.
                -- Empty by default, useful if one of the "opts" global settings
                -- doesn't work well in a specific filetype
                per_filetype = {
                    ["html"] = {
                        enable_close = false
                    }
                }
            })
        end,
    },
    -- {
    --     "ThePrimeagen/harpoon",
    --     branch = "harpoon2",
    --     dependencies = { "nvim-lua/plenary.nvim" },
    --     config = function()
    --         local harpoon = require("harpoon")
    --         harpoon:setup({
    --             settings = {
    --                 save_on_toggle = true,
    --             }
    --         })
    --
    --         vim.keymap.set("n", "<leader>a", function() harpoon:list():add() end)
    --         vim.keymap.set("n", "<C-e>", function() harpoon.ui:toggle_quick_menu(harpoon:list()) end)
    --
    --         vim.keymap.set("n", "<C-h>", function() harpoon:list():select(1) end)
    --         vim.keymap.set("n", "<C-t>", function() harpoon:list():select(2) end)
    --         vim.keymap.set("n", "<C-n>", function() harpoon:list():select(3) end)
    --         vim.keymap.set("n", "<C-s>", function() harpoon:list():select(4) end)
    --
    --         -- Toggle previous & next buffers stored within Harpoon list
    --         vim.keymap.set("n", "<C-S-P>", function() harpoon:list():prev() end)
    --         vim.keymap.set("n", "<C-S-N>", function() harpoon:list():next() end)
    --     end,
    -- },
    {
        "stevanmilic/nvim-lspimport",
        config = function()
            vim.keymap.set("n", "<leader>i", require("lspimport").import, { noremap = true })
        end,
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
        }
    },
    -- {
    --     "luk400/vim-jukit",
    --     config = function()
    --         vim.g._jukit_python_os_cmd = 'python';
    --     end,
    --     -- ft = {"py", "ipynb"},
    -- },
    -- {
    --     "dccsillag/magma-nvim",
    --     lazy = false,
    --     config = function()
    --         require("magma-nvim").setup()
    --         vim.keymap.set('n', '<Leader>r', [[:MagmaEvaluateOperator<CR>]],
    --             { noremap = true, silent = true, expr = true })
    --         vim.keymap.set('n', '<Leader>rr', [[:MagmaEvaluateLine<CR>]], { noremap = true, silent = true })
    --         vim.keymap.set('x', '<Leader>r', [[:<C-u>MagmaEvaluateVisual<CR>]], { noremap = true, silent = true })
    --         vim.keymap.set('n', '<Leader>rc', [[:MagmaReevaluateCell<CR>]], { noremap = true, silent = true })
    --         vim.keymap.set('n', '<Leader>rd', [[:MagmaDelete<CR>]], { noremap = true, silent = true })
    --         vim.keymap.set('n', '<Leader>ro', [[:MagmaShowOutput<CR>]], { noremap = true, silent = true })
    --
    --         vim.g.magma_automatically_open_output = false
    --         vim.g.magma_image_provider = "ueberzug"
    --     end
    -- },
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
        "benlubas/molten-nvim",
        version = "^1.0.0", -- use version <2.0.0 to avoid breaking changes
        build = ":UpdateRemotePlugins",
        init = function()
            -- this is an example, not a default. Please see the readme for more configuration options
            vim.g.molten_output_win_max_height = 12
            -- activate the following line to change neovim's python env, but be careful that this env include ALL necessary packages, even those required by other neovim plugins!
            -- vim.g.python3_host_prog = vim.fn.expand("C:\\Users\\lpaal\\miniconda3\\envs\\neovim\\python")
            vim.keymap.set("n", "<localleader>ip", function()
                local venv = os.getenv("VIRTUAL_ENV") or os.getenv("CONDA_PREFIX")
                print(venv)
                if venv ~= nil then
                    -- in the form of /home/benlubas/.virtualenvs/VENV_NAME
                    venv = string.match(venv, "/.+/(.+)")
                    vim.cmd(("MoltenInit %s"):format(venv))
                else
                    vim.cmd("MoltenInit python3")
                end
            end, { desc = "Initialize Molten for python3", silent = true })

            vim.keymap.set("n", "<localleader>mi", ":MoltenInit<CR>",
                { silent = true, desc = "Initialize the plugin" })
            vim.keymap.set("n", "<localleader>e", ":MoltenEvaluateOperator<CR>",
                { silent = true, desc = "run operator selection" })
            vim.keymap.set("n", "<localleader>rl", ":MoltenEvaluateLine<CR>",
                { silent = true, desc = "evaluate line" })
            vim.keymap.set("n", "<localleader>rr", ":MoltenReevaluateCell<CR>",
                { silent = true, desc = "re-evaluate cell" })
            vim.keymap.set("v", "<localleader>r", ":<C-u>MoltenEvaluateVisual<CR>gv",
                { silent = true, desc = "evaluate visual selection" })
        end,
    },
    -- {
    --     "lervag/vimtex",
    --     lazy = false, -- we don't want to lazy load VimTeX
    --     -- tag = "v2.15", -- uncomment to pin to a specific release
    --     init = function()
    --         -- VimTeX configuration goes here, e.g.
    --
    --         -- vim.g.vimtex_view_general_viewer = 'okular'
    --         -- vim.g.vimtex_view_general_options = '--unique file:@pdf#src:@line@tex'
    --
    --         vim.g.vimtex_view_general_viewer = 'sumatraPDF'
    --         vim.g.vimtex_view_general_options = '-reuse-instance @pdf'
    --
    --         -- vim.g.vimtex_compiler_method = "latexpdf"
    --         -- spellcheck
    --
    --         -- vim.keymap.set("n", "<leader>lr", function()
    --         --     local cwd = vim.fn.getcwd()
    --         --     vim.cmd('!start cmd.exe /K "cd ' .. cwd .. ' && pdflatex Thesis.tex"')
    --         -- end, { silent = true })
    --
    --
    --         vim.api.nvim_create_user_command('RunPdfLatex', function()
    --             local file = vim.fn.expand('%')
    --             if file == '' then
    --                 print("No file to compile!")
    --                 return
    --             end
    --             print("Running pdflatex on " .. file)
    --             vim.fn.jobstart({ 'pdflatex', file }, {
    --                 stdout_buffered = true,
    --                 stderr_buffered = true,
    --                 on_stdout = function(_, data)
    --                     if data then
    --                         print(table.concat(data, '\n'))
    --                     end
    --                 end,
    --                 on_stderr = function(_, data)
    --                     if data then
    --                         vim.notify(table.concat(data, '\n'), vim.log.levels.ERROR)
    --                     end
    --                 end,
    --                 on_exit = function(_, code)
    --                     if code == 0 then
    --                         print("pdflatex compilation succeeded.")
    --                     else
    --                         print("pdflatex compilation failed.")
    --                     end
    --                 end,
    --             })
    --         end, { desc = "Run pdflatex on the current file" })
    --
    --         -- shortcut to rerun pdflatex on current file
    --         vim.api.nvim_set_keymap('n', '<localleader>lr', ':RunPdfLatex<CR>', { noremap = true, silent = true })
    --
    --
    --         vim.api.nvim_create_user_command("CheckThesis", function()
    --             local cmd =
    --             [[java -jar "C:\Program Files\textidote\textidote.jar" --output html Thesis.tex > "C:\Users\lpaal\Downloads\report.html" & cmd /c start "" "C:\Users\lpaal\Downloads\report.html"]]
    --             vim.fn.system(cmd)
    --             print("Textidote check complete! Report opened.")
    --         end, {})
    --
    --         vim.api.nvim_set_keymap('n', '<localleader>lg', ':CheckThesis<CR>', { noremap = true, silent = true })
    --
    --         --
    --         -- vim.g.vimtex_view_general_options_latexmk = '-reuse-instance'
    --         -- vim.g.vimtex_view_method = "sumatrapdf"
    --     end
    -- },
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
    }
    ,
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
    {
        "kiyoon/treesitter-indent-object.nvim",
        keys = {
            {
                "ai",
                function() require 'treesitter_indent_object.textobj'.select_indent_outer() end,
                mode = { "x", "o" },
                desc = "Select context-aware indent (outer)",
            },
            {
                "aI",
                function() require 'treesitter_indent_object.textobj'.select_indent_outer(true) end,
                mode = { "x", "o" },
                desc = "Select context-aware indent (outer, line-wise)",
            },
            {
                "ii",
                function() require 'treesitter_indent_object.textobj'.select_indent_inner() end,
                mode = { "x", "o" },
                desc = "Select context-aware indent (inner, partial range)",
            },
            {
                "iI",
                function() require 'treesitter_indent_object.textobj'.select_indent_inner(true, 'V') end,
                mode = { "x", "o" },
                desc = "Select context-aware indent (inner, entire range) in line-wise visual mode",
            },
        },
    },
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
        "nvim-neorg/neorg",
        lazy = false,  -- Disable lazy loading as some `lazy.nvim` distributions set `lazy = true` by default
        version = "*", -- Pin Neorg to the latest stable release
        config = function()
            require("neorg").setup({
                load = {
                    ["core.defaults"] = {},
                    ["core.concealer"] = {}, -- We added this line!
                }
            })
        end,

    },
    {
        "nvim-treesitter/nvim-treesitter-context",
        config = function()
            require 'treesitter-context'.setup {
                enable = true,           -- Enable this plugin (Can be enabled/disabled later via commands)
                multiwindow = false,     -- Enable multiwindow support.
                max_lines = 0,           -- How many lines the window should span. Values <= 0 mean no limit.
                min_window_height = 0,   -- Minimum editor window height to enable context. Values <= 0 mean no limit.
                line_numbers = true,
                multiline_threshold = 1, -- Maximum number of lines to show for a single context
                trim_scope = 'outer',    -- Which context lines to discard if `max_lines` is exceeded. Choices: 'inner', 'outer'
                mode = 'cursor',         -- Line used to calculate context. Choices: 'cursor', 'topline'
                -- Separator between context and content. Should be a single character string, like '-'.
                -- When separator is set, the context will only show up when there are at least 2 lines above cursorline.
                -- separator = nil,
                separator = '-',
                zindex = 20,     -- The Z-index of the context window
                on_attach = nil, -- (fun(buf: integer): boolean) return false to disable attaching
            }
        end

    },
    {
        "NeogitOrg/neogit",
        dependencies = {
            "nvim-lua/plenary.nvim",  -- required
            "sindrets/diffview.nvim", -- optional - Diff integration

            -- Only one of these is needed.
            "nvim-telescope/telescope.nvim", -- optional
            -- "ibhagwan/fzf-lua",      -- optional
            -- "echasnovski/mini.pick", -- optional
            -- "folke/snacks.nvim",     -- optional
        },
        config = function()
            vim.keymap.set("n", "<leader>g", ":Neogit<CR>")
        end
    }
}
