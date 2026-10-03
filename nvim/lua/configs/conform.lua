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

  -- C/C++ на сохранении не трогаем: clangd переформатирует ядерный код
  -- под LLVM-стиль, если рядом нет .clang-format. Руками — <leader>f.
  format_on_save = function(bufnr)
    if vim.tbl_contains({ "c", "cpp" }, vim.bo[bufnr].filetype) then
      return nil
    end
    return { timeout_ms = 500, lsp_format = "fallback" }
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
