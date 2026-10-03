-- Импортируем стандартные настройки NvChad
local nvchad_on_attach = require("nvchad.configs.lspconfig").on_attach
local on_init = require("nvchad.configs.lspconfig").on_init
local capabilities = require("nvchad.configs.lspconfig").capabilities

local lspconfig = require("lspconfig")
local telescope = require("telescope.builtin")

-- Создаем отдельную функцию on_attach ТОЛЬКО для clangd
local clangd_on_attach = function(client, bufnr)
  -- 1. Сначала вызываем стандартный функционал NvChad (чтобы не сломать UI и фичи)
  nvchad_on_attach(client, bufnr)

  -- 2. Теперь добавляем ваши кастомные бинды поверх
  local opts = { noremap = true, silent = true, buffer = bufnr }
  vim.keymap.set("n", "gd", telescope.lsp_definitions, opts)
  vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts)
  vim.keymap.set("n", "gi", telescope.lsp_implementations, opts)
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
  on_attach = clangd_on_attach, -- Используем НАШУ объединенную функцию
  capabilities = capabilities,
  on_init = on_init,
  
  root_dir = require("lspconfig.util").root_pattern("compile_commands.json", ".git"),
  
  on_new_config = function(new_config, new_root_dir)
    local lsp_util = require("lspconfig.util")
    local local_db = lsp_util.path.join(new_root_dir, "compile_commands.json")
    
    -- Указываем правильный путь к ядру 6.19
    local kernel_dir = "/home/mikhail/linux/linux-6.19/"
    local kernel_db = lsp_util.path.join(kernel_dir, "compile_commands.json")
    
    if not lsp_util.path.exists(local_db) and lsp_util.path.exists(kernel_db) then
      local cmd = vim.deepcopy(new_config.cmd) or {}
      table.insert(cmd, "--compile-commands-dir=" .. kernel_dir)
      table.insert(cmd, "--query-driver=/usr/bin/gcc,/usr/bin/clang")
      new_config.cmd = cmd
      
      -- Уведомление, чтобы вы точно знали, что ядро подхватилось
      vim.notify("Using Kernel 6.19 compile_commands", vim.log.levels.INFO, { title = "LSP Clangd" })
    end
  end,
  cmd = {
    "clangd",
    "--background-index",
    "--clang-tidy",
    "--completion-style=detailed",
    "--header-insertion=never",
    "--all-scopes-completion",
    "--log=error",
	"--query-driver=/usr/bin/gcc,/usr/bin/clang",
  },
  settings = {
    clangd = {
      fallbackFlags = { "-std=c11" }
    }
  }
})

-- ============================
--      Остальные серверы
-- ============================
-- Передаем им стандартный nvchad_on_attach, чтобы ничего не ломалось

local servers = {
  "ocamllsp", "html", "dockerls", "jsonls", "marksman", "cmake", "pyright"
}

for _, server in ipairs(servers) do
  lspconfig[server].setup({
    on_attach = nvchad_on_attach,
    on_init = on_init,
    capabilities = capabilities,
  })
end

-- Bash Language Server
lspconfig.bashls.setup({
    on_attach = nvchad_on_attach,
    on_init = on_init,
    capabilities = capabilities,
    settings = {
        bashIde = { globPattern = "*@(.sh|.inc|.bash|.command)" }
    }
})

-- YAML Language Server
lspconfig.yamlls.setup({
    on_attach = nvchad_on_attach,
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
