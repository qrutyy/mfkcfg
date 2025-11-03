-- ~/.config/nvim/lua/mappings.lua
require "nvchad.mappings"

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

