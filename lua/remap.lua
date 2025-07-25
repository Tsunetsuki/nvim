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
vim.keymap.set("x", ">", ">gv")
vim.keymap.set("x", "<", "<gv")
vim.keymap.set("x", "<Tab>", ">gv")
vim.keymap.set("x", "<S-Tab>", "<gv")
vim.keymap.set("n", "<Tab>", ">>")
vim.keymap.set("n", "<S-Tab>", "<<")

-- diagnostics, and make diag. window focusable so text can be selected from it
vim.keymap.set("n", "<F8>", function() vim.diagnostic.goto_next({ focusable = true }) end)
vim.keymap.set("n", "<F7>", function() vim.diagnostic.goto_prev({ focusable = true }) end)

-- jump between windows
vim.keymap.set("n", "<C-h>", "<C-w>h")
vim.keymap.set("n", "<C-l>", "<C-w>l")
vim.keymap.set("n", "<C-j>", "<C-w>j")
vim.keymap.set("n", "<C-k>", "<C-w>k")

vim.keymap.set("n", "_", "<S-/>") -- search for QWERTZ keyboard

-- don't yank single letters on deletion
vim.keymap.set("n", "x", "\"_x")
vim.keymap.set("n", "s", "\"_s")

vim.keymap.set("n", "E", "ge")

-- make it possible to copy text with ctrl+shift+c
vim.keymap.set("n", "<C-S-c>", "y")

-- os dependent: open terminal, open nvim config
if vim.loop.os_uname().sysname == "Windows_NT" then
  vim.keymap.set("n", "<leader>tt", ":!start cmd.exe<CR>")
  --
  vim.keymap.set("n", "<leader>cc", function()
    vim.cmd('!start cmd.exe /K "cd ' .. vim.fn.stdpath("config") .. ' && nvim ."')
  end, { silent = true })
else
  vim.keymap.set("n", "<leader>tt", ":!kitty &<CR>")
  vim.keymap.set("n", "<leader>cc", function()
    local config_path = vim.fn.stdpath("config")
    vim.fn.jobstart({
      "kitty", "--detach", "sh", "-c", "cd " .. config_path .. " && nvim ."
    }, { detach = true })
  end, { silent = true })
end



-- some project specific stuff, make this on a per-project basis later!
-- vim.keymap.set("n", "<leader>eu", [[:!eas update --channel=preview -m=""<Left>]])
vim.keymap.set("n", "<leader>eu", function()
  vim.cmd("vsplit | terminal")
  vim.fn.feedkeys("i", "n")                                                                      --switch to insert mode inside terminal
  vim.fn.feedkeys("eas update --channel=preview -m=\"\"", "n")
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Left>", true, false, true), 'n', false) --move cursor inside -m=""
end)

-- jk keys: when there is no count attached (e.g. 2j), navigate through wrapped line
vim.api.nvim_set_keymap('n', 'j', "v:count == 0 ? 'gj' : 'j'", { noremap = true, expr = true, silent = true })
vim.api.nvim_set_keymap('n', 'k', "v:count == 0 ? 'gk' : 'k'", { noremap = true, expr = true, silent = true })


-- quickly navigate quickfix lists
vim.keymap.set('n', ']e', '<Cmd>try | cnext | catch | cfirst | catch | endtry<CR>')
vim.keymap.set('n', '[e', '<Cmd>try | cprevious | catch | clast | catch | endtry<CR>')
