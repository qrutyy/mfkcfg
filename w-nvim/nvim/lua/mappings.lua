-- ~/.config/nvim/lua/mappings.lua
require "nvchad.mappings"

local telescope = require("telescope.builtin")

local map = vim.keymap.set

-- Форматирование
map("n", "<leader>f", function()
  vim.lsp.buf.format { async = true }
end, { desc = "Format buffer" })

-- Линтинг
map("n", "<leader>l", function()
  require("lint").try_lint()
end, { desc = "Trigger linting" })

-- Python virtual environment
map("n", "<leader>vs", "<cmd>VenvSelect<cr>", { desc = "Select Python venv" })

-- Swift/Xbase
map("n", "<leader>xb", "<cmd>XcodeBuild<cr>", { desc = "Xcode build" })
map("n", "<leader>xr", "<cmd>XcodeRun<cr>", { desc = "Xcode run" })

-- Дополнительные маппинги для macOS
map("n", "<D-s>", "<cmd>w<CR>", { desc = "Save file" })  -- Cmd+S для сохранения
map("i", "<D-s>", "<C-o><cmd>w<CR>", { desc = "Save file" })  -- Cmd+S в режиме вставки

-- Диагностика
map("n", "<leader>d", vim.diagnostic.open_float, { desc = "Show diagnostic" })
map("n", "[d", vim.diagnostic.goto_prev, { desc = "Previous diagnostic" })
map("n", "]d", vim.diagnostic.goto_next, { desc = "Next diagnostic" })

-- YAML schema selection
map("n", "<leader>ys", "<cmd>Telescope yaml_schema<cr>", { desc = "YAML schema" })
map('n', '<leader>gb', ':GitBlameToggle<CR>', { noremap = true, silent = true })

-- LSP-based definitions
vim.keymap.set("n", "<leader>fd", telescope.lsp_definitions, { desc = "LSP Definitions" })

-- LSP-based implementations
vim.keymap.set("n", "<leader>fi", telescope.lsp_implementations, { desc = "LSP Implementations" })

-- LSP document symbols
vim.keymap.set("n", "<leader>fs", telescope.lsp_document_symbols, { desc = "LSP Symbols" })

---------------------------------------------------------------------
-- 🔥 BEST REFERENCES SEARCH — hybrid LSP + Ripgrep in Telescope
---------------------------------------------------------------------
map("n", "gr", function()
  require("telescope.builtin").lsp_references({
    show_line = false,
    include_declaration = false,
  })
end, { desc = "LSP References in Telescope" })

map("n", "gR", function()
  local word = vim.fn.expand("<cword>")
  require("telescope.builtin").grep_string({
    search = word,
    prompt_title = "Ripgrep references: " .. word,
    glob_pattern = { "*.c", "*.h" },
    search_dirs = {
      vim.fn.getcwd(),
      "/usr/src/linux-headers-" .. vim.fn.system("uname -r"):gsub("\n", ""),
      "/home/mikhail/linux-6.16",
    }
  })
end, { desc = "RG References (fallback)" })
---------------------------------------------------------------------
-- 🔥 Search inside Linux kernel source
---------------------------------------------------------------------
vim.keymap.set("n", "<leader>fk", function()
  telescope.live_grep({
    prompt_title = "Linux kernel search",
    search_dirs = { "/home/mikhail/linux-6.16/" },
    path_display = { "smart" },
    glob_pattern = { "*.c", "*.h", "Makefile", "Kconfig" },
  })
end, { desc = "Search in Linux kernel sources" })

map("n", "<leader>gk", function()
  local word = vim.fn.expand("<cword>")
  -- Базовый паттерн для поиска определений C (структуры или функции)
  -- Можно упростить просто до search=word, если нужно шире
  require("telescope.builtin").grep_string({
    search = word,
    prompt_title = "Kernel Definition Search: " .. word,
    search_dirs = { "/home/mikhail/linux-6.16/" }, -- Ваш путь к ядру
    path_display = { "smart" },
    -- Опционально: искать только в .c и .h
    glob_pattern = { "*.c", "*.h" },
  })
end, { desc = "Search definition in Kernel (Grep)" })

-- Альтернативный вариант для Kernel Definition, если есть теги (tags)
-- map("n", "<leader>gt", "<cmd>Telescope tags search_dirs={'/home/mikhail/linux-6.16/'}<cr>", { desc = "Search tags in Kernel" })
