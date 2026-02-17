local on_attach = require("nvchad.configs.lspconfig").on_attach
local on_init = require("nvchad.configs.lspconfig").on_init
local capabilities = require("nvchad.configs.lspconfig").capabilities

local lspconfig = require "lspconfig"
local telescope_builtin = require("telescope.builtin") -- Подключаем Telescope

-- Clangd setup для macOS
local on_attach = function(_, bufnr)
  local opts = { noremap = true, silent = true, buffer = bufnr }
  local telescope = require("telescope.builtin")
  vim.keymap.set("n", "gd", telescope.lsp_definitions, opts)
  vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts)
  vim.keymap.set("n", "gi", telescope.lsp_implementations, opts)

  -- GR через Telescope удобен, но если хотите обычный список - замените на vim.lsp.buf.references
  vim.keymap.set("n", "gr", telescope.lsp_references, opts)

  vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
  vim.keymap.set("n", "<leader>f", function() vim.lsp.buf.format({ async = true }) end, opts)
  vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
  vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
end

-- ============================
--      C/C++: clangd
-- ============================
lspconfig.clangd.setup({
  on_attach = on_attach,
  capabilities = capabilities,
  on_init = on_init,

  root_dir = require("lspconfig.util").root_pattern("compile_commands.json", ".git"),
	on_new_config = function(new_config, new_root_dir)
	local lsp_util = require("lspconfig.util")
	local local_db = lsp_util.path.join(new_root_dir, "compile_commands.json")
	local kernel_dir = "/home/mikhail/linux-6.16/"
	local kernel_db = lsp_util.path.join(kernel_dir, "compile_commands.json")
	if not lsp_util.path.exists(local_db) and lsp_util.path.exists(kernel_db) then
	  -- Важно: делаем копию cmd, чтобы не испортить настройки для других сессий
	  local cmd = vim.deepcopy(new_config.cmd) or {}

	  -- Добавляем аргумент, указывающий путь к базе ядра
	  table.insert(cmd, "--compile-commands-dir=" .. kernel_dir)

	  -- Опционально: разрешаем clangd индексировать файлы за пределами проекта (нужно для хедеров)
	  table.insert(cmd, "--query-driver=/usr/bin/gcc,/usr/bin/clang")

	  new_config.cmd = cmd

	  -- Уведомление, чтобы вы знали, что подключилось ядро (можно убрать потом)
	  vim.notify("Using Kernel " .. kernel_dir .. " compile_commands", vim.log.levels.INFO, { title = "LSP Clangd" })
	end
  end,
  cmd = {
    "clangd",
    "--background-index",
    "--clang-tidy",
    "--completion-style=detailed",
    "--header-insertion=never",
    "--all-scopes-completion", -- искать символы везде
    "--log=error",
  },

  settings = {
    clangd = {
      fallbackFlags = { "-std=c11" }
    }
  }
})

-- OCaml Setup
lspconfig.ocamllsp.setup({
    cmd = {"ocamllsp"},
    on_attach = on_attach,
    on_init = on_init,
    capabilities = capabilities
})

-- HTML Setup
lspconfig.html.setup({
    on_attach = on_attach,
    on_init = on_init,
    capabilities = capabilities
})

-- Bash Language Server
lspconfig.bashls.setup({
    on_attach = on_attach,
    on_init = on_init,
    capabilities = capabilities,
    settings = {
        bashIde = {
            globPattern = "*@(.sh|.inc|.bash|.command)"
        }
    }
})

-- Dockerfile Language Server
lspconfig.dockerls.setup({
    on_attach = on_attach,
    on_init = on_init,
    capabilities = capabilities
})

-- YAML Language Server
lspconfig.yamlls.setup({
    on_attach = on_attach,
    on_init = on_init,
    capabilities = capabilities,
    settings = {
        yaml = {
            schemas = {
                ["https://json.schemastore.org/github-workflow.json"] = "/.github/workflows/*",
                ["https://json.schemastore.org/docker-compose.json"] = "docker-compose*.yml"
            }
        }
    }
})

-- JSON Language Server
lspconfig.jsonls.setup({
    on_attach = on_attach,
    on_init = on_init,
    capabilities = capabilities
})

-- Markdown Language Server
lspconfig.marksman.setup({
    on_attach = on_attach,
    on_init = on_init,
    capabilities = capabilities
})

-- CMake Language Server
lspconfig.cmake.setup({
    on_attach = on_attach,
    on_init = on_init,
    capabilities = capabilities
})

-- Python Language Server
lspconfig.pyright.setup({
    on_attach = on_attach,
    on_init = on_init,
    capabilities = capabilities,
})

