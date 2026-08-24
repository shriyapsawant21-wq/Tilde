local map = vim.keymap.set
local silent = { silent = true }

map("n", "<leader>w", "<cmd>write<cr>", { desc = "Write file" })
map("n", "<leader>q", "<cmd>quit<cr>", { desc = "Quit window" })
map("n", "<leader>e", "<cmd>Explore<cr>", { desc = "File explorer" })
map("n", "<leader>ff", "<cmd>Files<cr>", { desc = "Find files" })
map("n", "<leader>fg", "<cmd>Rg<cr>", { desc = "Search text" })
map("n", "<leader>gg", function()
  vim.cmd("botright new")
  vim.cmd("terminal lazygit")
  vim.cmd("startinsert")
end, { desc = "Lazygit" })

-- Seamless tmux navigation sends these keys to Neovim when a split is active.
map("n", "<C-h>", "<C-w>h", silent)
map("n", "<C-j>", "<C-w>j", silent)
map("n", "<C-k>", "<C-w>k", silent)
map("n", "<C-l>", "<C-w>l", silent)

map("n", "<Esc>", "<cmd>nohlsearch<cr>", silent)
