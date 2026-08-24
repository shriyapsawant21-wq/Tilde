local M = {}

local function executable(name)
  if vim.fn.executable(name) == 1 then
    return true
  end
  vim.notify("Tilde: required command not found: " .. name, vim.log.levels.ERROR)
  return false
end

function M.files()
  if not (executable("fd") and executable("fzf")) then return end
  local selection = vim.fn.systemlist({ "sh", "-c", "fd --type f --hidden --exclude .git | fzf --height=80% --layout=reverse --border" })
  if vim.v.shell_error == 0 and selection[1] and selection[1] ~= "" then
    vim.cmd.edit(vim.fn.fnameescape(selection[1]))
  end
end

function M.grep()
  if not (executable("rg") and executable("fzf")) then return end
  local query = vim.fn.input("Search: ")
  if query == "" then return end
  local command = "rg --line-number --column --no-heading --color=always --smart-case -- "
    .. vim.fn.shellescape(query)
    .. " . | fzf --ansi --delimiter=: --nth=1,2,4.. --height=80% --layout=reverse --border"
  local selection = vim.fn.systemlist({ "sh", "-c", command })
  if vim.v.shell_error ~= 0 or not selection[1] then return end
  local plain = selection[1]:gsub("\27%[[0-9;]*m", "")
  local file, line = plain:match("^([^:]+):(%d+):")
  if file and line then
    vim.cmd.edit(vim.fn.fnameescape(file))
    vim.api.nvim_win_set_cursor(0, { tonumber(line), 0 })
  end
end

vim.api.nvim_create_user_command("Files", M.files, {})
vim.api.nvim_create_user_command("Rg", M.grep, {})

return M
