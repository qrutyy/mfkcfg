require "nvchad.autocmds"

-- Linux kernel coding style для C: табы шириной 8, лимит строки 100.
vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("UserKernelStyle", { clear = true }),
  pattern = { "c", "cpp" },
  callback = function()
    vim.bo.tabstop = 8
    vim.bo.shiftwidth = 8
    vim.bo.softtabstop = 8
    vim.bo.expandtab = false
    vim.bo.textwidth = 100
    vim.opt_local.colorcolumn = "100"
  end,
})
