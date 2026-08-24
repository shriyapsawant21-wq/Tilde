-- Tilde supplies conservative defaults but does not install language servers.
vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(event)
    local map = function(lhs, rhs, desc)
      vim.keymap.set("n", lhs, rhs, { buffer = event.buf, desc = desc })
    end
    map("gd", vim.lsp.buf.definition, "Go to definition")
    map("gr", vim.lsp.buf.references, "List references")
    map("K", vim.lsp.buf.hover, "Show documentation")
    map("<leader>rn", vim.lsp.buf.rename, "Rename symbol")
    map("<leader>ca", vim.lsp.buf.code_action, "Code action")
  end,
})
