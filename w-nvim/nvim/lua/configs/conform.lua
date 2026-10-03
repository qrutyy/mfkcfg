-- ~/.config/nvim/lua/configs/conform.lua
local options = {
  formatters_by_ft = {
    lua = { "stylua" },
    css = { "prettier" },
    html = { "prettier" },
    javascript = { "prettier" },
    typescript = { "prettier" },
    json = { "prettier" },
    yaml = { "prettier" },
    markdown = { "prettier" },
    sh = { "shfmt" },
    bash = { "shfmt" },
    zsh = { "shfmt" },
    python = { "black" },
    swift = { "swiftformat" },
    kotlin = { "ktlint" },
  },

  format_on_save = function(bufnr)
    -- lsp_fallback would otherwise silently run clangd's formatter (default
    -- clang-format style) on every C/C++ save. This codebase follows kernel
    -- style enforced by checkpatch, not clang-format's defaults, and letting
    -- clangd reflow the file on save can shift line numbers out from under
    -- you and even drop blank lines. Only auto-format filetypes that have an
    -- explicit formatter above; leave C/C++ alone (use <leader>f to format
    -- deliberately if you ever want to).
    local ft = vim.bo[bufnr].filetype
    if ft == "c" or ft == "cpp" then
      return nil
    end
    return { timeout_ms = 500, lsp_fallback = true }
  end,

  formatters = {
    shfmt = {
      prepend_args = { "-i", "2", "-ci" }, -- 2 пробела, отступ для case
    },
    black = {
      prepend_args = { "--line-length", "88", "--quiet" },
    },
    ktlint = {
      prepend_args = { "--format" },
    },
  },
}

return options
