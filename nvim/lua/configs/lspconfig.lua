-- nvim 0.11 + nvim-lspconfig master: конфиги задаются через vim.lsp.config/enable,
-- lspconfig.<server>.setup{} устарел.
--
-- Базовые capabilities и on_init уже проставлены NvChad'ом на "*"
-- (nvchad.configs.lspconfig.defaults()), здесь только отличия.

local kernel = require "kernel"

-- Один on_attach на все серверы. Telescope грузится лениво, внутри колбэка:
-- require на верхнем уровне вытаскивал его на старте.
local function on_attach(client, bufnr)
  local function map(lhs, rhs, desc)
    vim.keymap.set("n", lhs, rhs, { buffer = bufnr, silent = true, desc = "LSP " .. desc })
  end
  local function telescope(fn)
    return function()
      require("telescope.builtin")[fn]()
    end
  end

  map("gd", telescope "lsp_definitions", "Go to definition")
  map("gD", vim.lsp.buf.declaration, "Go to declaration")
  map("gi", telescope "lsp_implementations", "Go to implementation")
  map("gr", telescope "lsp_references", "References")
  map("<leader>rn", vim.lsp.buf.rename, "Rename")

  -- rust-analyzer поднимает rustaceanvim, и он вешает на K и <leader>ca
  -- свои версии (hover actions и сгруппированные code actions) в
  -- after/ftplugin/rust.lua. LspAttach может сработать позже ftplugin'а
  -- на первом открытии буфера, поэтому здесь просто не трогаем эти две
  -- клавиши, иначе они затираются в зависимости от порядка событий.
  if client and client.name == "rust-analyzer" then
    return
  end

  map("K", vim.lsp.buf.hover, "Hover")
  map("<leader>ca", vim.lsp.buf.code_action, "Code action")
end

vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("UserLspAttach", { clear = true }),
  callback = function(args)
    on_attach(vim.lsp.get_client_by_id(args.data.client_id), args.buf)
  end,
})

-- ============================
--      C/C++: clangd
-- ============================
-- Apple clangd из /usr/bin спотыкается на не-Apple тулчейнах, поэтому берём
-- сборку из mason, если она есть.
local mason_clangd = vim.fs.joinpath(vim.fn.stdpath "data", "mason/bin/clangd")
local clangd_bin = vim.uv.fs_stat(mason_clangd) and mason_clangd or "clangd"

-- header_insertion:
--   iwyu — при выборе printf/malloc/memcpy из автодополнения дописывается
--          #include с нужным заголовком; без этого символ из не подключённого
--          заголовка в меню бесполезен.
--   never — для ядра: там правила включения заголовков свои.
-- Ключа для этого в .clangd нет (clangd 20 на Completion.HeaderInsertion
-- отвечает "Unknown Completion key"), так что режим выбирается флагом при
-- запуске процесса — см. автокоманду ниже.
local function clangd_cmd(header_insertion)
  return {
    clangd_bin,
    "--background-index",
    "--background-index-priority=low",
    "--clang-tidy",
    "--header-insertion=" .. header_insertion,
    -- Помечает в меню кандидатов, которые потянут за собой новый #include.
    "--header-insertion-decorators",
    "--all-scopes-completion",
    "--completion-style=detailed",
    "--pch-storage=memory",
    "--function-arg-placeholders=0",
    "-j=4",
    "--log=error",
  }
end

vim.lsp.config("clangd", {
  cmd = clangd_cmd "iwyu",
  -- Флаги сборки берутся из compile_commands.json или .clangd конкретного
  -- проекта. Глобальный --compile-commands-dir на дерево ядра ломал clangd
  -- во всех остальных проектах (и совсем — когда том не смонтирован).
  root_markers = {
    { ".clangd", "compile_commands.json", "compile_flags.txt" },
    { "Kbuild", "Makefile" },
    ".git",
  },
})

-- Ядерный модуль узнаём по .clangd, который пишет :KernelClangd: там
-- -D__KERNEL__. Файл дешевле и надёжнее, чем гадать по пути.
local function is_kernel_tree(bufnr)
  local name = vim.api.nvim_buf_get_name(bufnr)
  local root = vim.fs.root(name ~= "" and name or vim.uv.cwd(), { ".clangd" })
  if not root then
    return false
  end
  for _, line in ipairs(vim.fn.readfile(vim.fs.joinpath(root, ".clangd"))) do
    if line:find("__KERNEL__", 1, true) then
      return true
    end
  end
  return false
end

-- Событие именно BufReadPre/BufNewFile, а не FileType: клиента поднимает
-- автокоманда группы nvim.lsp.enable, её заводит NvChad ещё до этого файла,
-- и на FileType она отрабатывает первой — cmd успевал прочитаться старый.
-- BufReadPre гарантированно раньше FileType для того же буфера.
vim.api.nvim_create_autocmd({ "BufReadPre", "BufNewFile" }, {
  group = vim.api.nvim_create_augroup("UserClangdHeaderInsertion", { clear = true }),
  pattern = { "*.c", "*.h", "*.cpp", "*.cc", "*.cxx", "*.hpp", "*.hh" },
  callback = function(args)
    vim.lsp.config("clangd", { cmd = clangd_cmd(is_kernel_tree(args.buf) and "never" or "iwyu") })
  end,
})

-- Дерево ядра индексируется само по себе: там свой compile_commands.json,
-- сгенерированный `make compile_commands.json`.
local kernel_src = kernel.src()
if kernel_src then
  vim.env.KERNEL_SRC = vim.env.KERNEL_SRC or kernel_src
end

-- ============================
--      Остальные серверы
-- ============================
vim.lsp.config("bashls", {
  settings = {
    bashIde = { globPattern = "*@(.sh|.inc|.bash|.command)" },
  },
})

-- Python: basedpyright вместо pyright. Ванильный pyright индексирует для
-- авто-импорта только свои файлы и установленные пакеты — символ stdlib
-- (Path, defaultdict, sqrt) он не предложит, пока модуль не импортирован
-- руками. packageIndexDepths, который это чинит, есть только в Pylance и
-- basedpyright; basedpyright при этом форк pyright с тем же протоколом и
-- теми же настройками python.analysis.*.
vim.lsp.config("basedpyright", {
  settings = {
    basedpyright = {
      analysis = {
        autoImportCompletions = true,
        useLibraryCodeForTypes = true,
        autoSearchPaths = true,
        diagnosticMode = "openFilesOnly",
        -- Глубина индексации для авто-импорта. "" — корень typeshed/stdlib,
        -- includeAllSymbols тянет не только то, что реэкспортировано в __init__.
        packageIndexDepths = {
          { name = "", depth = 4, includeAllSymbols = true },
        },
      },
      -- basedpyright по умолчанию строже pyright (typeCheckingMode = "all"):
      -- в обычном скрипте это стена diagnostics.
      typeCheckingMode = "standard",
    },
  },
})

vim.lsp.config("yamlls", {
  settings = {
    yaml = {
      schemas = {
        ["https://json.schemastore.org/github-workflow.json"] = "/.github/workflows/*",
        ["https://json.schemastore.org/docker-compose.json"] = "docker-compose*.yml",
      },
    },
  },
})

-- rust_analyzer здесь сознательно отсутствует: его клиент целиком ведёт
-- rustaceanvim (lua/plugins/rust.lua). Включение его тут поднимет второй
-- клиент на тот же буфер.
vim.lsp.enable {
  "clangd",
  "ocamllsp",
  "html",
  "bashls",
  "dockerls",
  "yamlls",
  "jsonls",
  "marksman",
  "cmake",
  "basedpyright",
}
