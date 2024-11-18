vim.keymap.set("n", "<leader>pv", vim.cmd.Ex)

vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")

vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")
vim.keymap.set({ "n", "x" }, "<leader>d", "\"_d")
vim.keymap.set("x", "<leader>p", "\"_dp")
vim.keymap.set("x", "<leader>P", "\"_dP")
vim.keymap.set("n", "Q", "<nop>")

-- find and replace word under cursor
vim.keymap.set("n", "<leader>s", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]])

-- after changing indentation: keep visual selection
vim.keymap.set("x", "<", "<gv")
vim.keymap.set("x", ">", ">gv")

-- diagnostics, and make diag. window focusable so text can be selected from it
vim.keymap.set("n", "<F8>", function() vim.diagnostic.goto_next({ focusable = true }) end)
vim.keymap.set("n", "<S-F8>", function() vim.diagnostic.goto_prev({ focusable = true }) end)

vim.keymap.set("n", "_", "<S-/>") -- search for QWERTZ keyboard

-- don't yank single letters on deletion
vim.keymap.set("n", "x", "\"_x")
vim.keymap.set("n", "s", "\"_s")

-- open terminal
vim.keymap.set("n", "<leader>tt", ":!start cmd.exe<CR>")
-- open nvim config
vim.keymap.set("n", "<leader>cc", function()
  vim.cmd('!start cmd.exe /K "cd ' .. vim.fn.stdpath("config") .. ' && nvim ."')
end, { silent = true })
-- some project specific stuff, make this on a per-project basis later!
-- vim.keymap.set("n", "<leader>eu", [[:!eas update --channel=preview -m=""<Left>]])
vim.keymap.set("n", "<leader>eu", function()
  vim.cmd("vsplit | terminal")
  vim.fn.feedkeys("i", "n") --switch to insert mode inside terminal
  vim.fn.feedkeys("eas update --channel=preview -m=\"\"", "n")
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Left>", true, false, true), 'n', false) --move cursor inside -m=""
end)
