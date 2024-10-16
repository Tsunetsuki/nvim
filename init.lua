require("options")
require("remap")
require("config.lazy")

---
-- LSP configuration
---
local lsp_attach = function(client, bufnr)
    local opts = { buffer = bufnr }
    vim.keymap.set('n', 'K', '<cmd>lua vim.lsp.buf.hover()<cr>', opts)
    vim.keymap.set('n', 'gd', '<cmd>lua vim.lsp.buf.definition()<cr>', opts)
    vim.keymap.set('n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<cr>', opts)
    vim.keymap.set('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<cr>', opts)
    vim.keymap.set('n', 'go', '<cmd>lua vim.lsp.buf.type_definition()<cr>', opts)
    vim.keymap.set('n', 'gr', '<cmd>lua vim.lsp.buf.references()<cr>', opts)
    vim.keymap.set('n', 'gs', '<cmd>lua vim.lsp.buf.signature_help()<cr>', opts)
    vim.keymap.set('n', '<F2>', '<cmd>lua vim.lsp.buf.rename()<cr>', opts)
    vim.keymap.set({ 'n', 'x', 'i' }, '<F3>',
        '<cmd>lua vim.lsp.buf.format({async = true, filter = function(client_) return client_.name ~= "ts_ls" end;})<cr>',
        opts)
    vim.keymap.set('n', 'ca', '<cmd>lua vim.lsp.buf.code_action()<cr>', opts)
end


local lsp_zero = require('lsp-zero')
lsp_zero.extend_lspconfig({
    sign_text = true,
    lsp_attach = lsp_attach,
    capabilities = require('cmp_nvim_lsp').default_capabilities()
})

require("mason-lspconfig").setup({
    ensure_installed = { "clangd", "gopls", "jsonls", "lua_ls", "pyright", "ts_ls" }
})
require("mason-lspconfig").setup_handlers({
    function(server_name)
        require("lspconfig")[server_name].setup({})
    end,
})


---
-- Autocompletion setup
---
local cmp = require('cmp')

cmp.setup({
    sources = {
        { name = 'path' },
        { name = 'nvim_lsp' },
        { name = 'luasnip', keyword_length = 2 },
        { name = 'buffer',  keyword_length = 3 },
    },
    window = {
        completion = cmp.config.window.bordered(),
        documentation = cmp.config.window.bordered(),
    },
    snippet = {
        expand = function(args)
            -- You need Neovim v0.10 to use vim.snippet
            vim.snippet.expand(args.body)
        end,
    },
    mapping = cmp.mapping.preset.insert({
        ['<CR>'] = cmp.mapping.confirm({ select = true }),
    }),
    completion = {
        completeopt = 'menu,menuone,noinsert'
    }
})
