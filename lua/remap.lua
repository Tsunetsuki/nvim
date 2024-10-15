vim.keymap.set("n", "<leader>pv", vim.cmd.Ex)

vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")

vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")
vim.keymap.set({ "n", "x" }, "<leader>d", "\"_d")
vim.keymap.set("x", "<leader>p", "\"_dP")
vim.keymap.set("n", "Q", "<nop>")

vim.keymap.set("n", "<leader>s", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]])
vim.keymap.set("x", "<", "<gv")
vim.keymap.set("x", ">", ">gv")
vim.keymap.set("n", "<F8>", function() vim.diagnostic.goto_next({ focusable = true }) end)
vim.keymap.set("n", "<S-F8>", function() vim.diagnostic.goto_prev({ focusable = true }) end)
vim.keymap.set("n", "_", "<S-/>") -- search for QWERTZ keyboard
vim.keymap.set("n", "<leader>t", ":!start cmd.exe<CR>")
vim.keymap.set("n", "<leader>c", function()
    vim.cmd('!start cmd.exe /K "cd ' ..  vim.fn.stdpath("config") .. ' && nvim ."')
end, { silent = true })
