-- ~/.config/nvim/lua/mappings.lua
require "nvchad.mappings"

local kernel = require "kernel"

-- Telescope ленивый: require на верхнем уровне тянул его на каждом старте.
local function telescope(fn, opts)
  return function()
    require("telescope.builtin")[fn](opts or {})
  end
end

local map = vim.keymap.set

map("n", "<leader>f", function()
  vim.lsp.buf.format { async = true }
end, { desc = "Format file" })

-- Swift/Xbase
map("n", "<leader>xb", "<cmd>XcodeBuild<cr>", { desc = "Xcode build" })
map("n", "<leader>xr", "<cmd>XcodeRun<cr>", { desc = "Xcode run" })

-- Дополнительные маппинги для macOS
map("n", "<D-s>", "<cmd>w<CR>", { desc = "Save file" })  -- Cmd+S для сохранения
map("i", "<D-s>", "<C-o><cmd>w<CR>", { desc = "Save file" })  -- Cmd+S в режиме вставки

-- Диагностика
map("n", "<leader>d", vim.diagnostic.open_float, { desc = "Show diagnostic" })
map("n", "[d", function()
  vim.diagnostic.jump { count = -1, float = true }
end, { desc = "Previous diagnostic" })
map("n", "]d", function()
  vim.diagnostic.jump { count = 1, float = true }
end, { desc = "Next diagnostic" })

-- YAML schema selection
map("n", "<leader>ys", "<cmd>Telescope yaml_schema<cr>", { desc = "YAML schema" })

-- LSP-based definitions
vim.keymap.set("n", "<leader>fd", telescope "lsp_definitions", { desc = "LSP Definitions" })

-- LSP-based implementations
vim.keymap.set("n", "<leader>fi", telescope "lsp_implementations", { desc = "LSP Implementations" })

-- LSP document symbols
vim.keymap.set("n", "<leader>fs", telescope "lsp_document_symbols", { desc = "LSP Symbols" })

---------------------------------------------------------------------
-- 🔥 BEST REFERENCES SEARCH — hybrid LSP + Ripgrep in Telescope
---------------------------------------------------------------------
map("n", "gr", telescope("lsp_references", {
  show_line = false,
  include_declaration = false,
}), { desc = "LSP References in Telescope" })

---------------------------------------------------------------------
-- Поиск по исходникам ядра (путь ищется, а не хардкодится)
---------------------------------------------------------------------
map("n", "gR", function()
  local word = vim.fn.expand "<cword>"
  local dirs = { vim.uv.cwd() }
  local headers = "/usr/src/linux-headers-" .. vim.trim(vim.fn.system "uname -r")
  if vim.uv.fs_stat(headers) then
    table.insert(dirs, headers)
  end
  local src = kernel.src()
  if src then
    table.insert(dirs, src)
  end

  require("telescope.builtin").grep_string {
    search = word,
    prompt_title = "Ripgrep references: " .. word,
    glob_pattern = { "*.c", "*.h" },
    search_dirs = dirs,
  }
end, { desc = "RG References (fallback)" })

map("n", "<leader>fk", function()
  local src = kernel.require_src()
  if not src then
    return
  end
  require("telescope.builtin").live_grep {
    prompt_title = "Linux kernel search",
    search_dirs = { src },
    path_display = { "smart" },
    glob_pattern = { "*.c", "*.h", "Makefile", "Kconfig" },
  }
end, { desc = "Search in Linux kernel sources" })

map("n", "<leader>gk", function()
  local src = kernel.require_src()
  if not src then
    return
  end
  local word = vim.fn.expand "<cword>"
  require("telescope.builtin").grep_string {
    search = word,
    prompt_title = "Kernel Definition Search: " .. word,
    search_dirs = { src },
    path_display = { "smart" },
    glob_pattern = { "*.c", "*.h" },
  }
end, { desc = "Search definition in Kernel (Grep)" })
