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

  format_on_save = {
    -- These options will be passed to conform.format()
    timeout_ms = 500,
    lsp_fallback = true,
  },

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
