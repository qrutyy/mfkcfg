-- ~/.config/nvim/lua/plugins/rust.lua
--
-- Rust-тулинг. Точка входа — rustaceanvim: он сам поднимает rust-analyzer
-- (без lspconfig) и даёт runnables/testables/debuggables, expandMacro и
-- hover actions. Поэтому rust_analyzer НЕ должен появляться ни в
-- vim.lsp.enable{}, ни в mason ensure_installed — иначе два клиента на буфер.
return {
  {
    "mrcjkb/rustaceanvim",
    version = "^8", -- v9+ требует nvim 0.12, здесь 0.11
    -- Плагин лениво грузится сам (:h lua-plugin-lazy), lazy.nvim мешать не надо.
    lazy = false,
    init = function()
      -- vim.g.rustaceanvim читается при инициализации ftplugin'а,
      -- поэтому задаём до открытия первого .rs.
      vim.g.rustaceanvim = {
        tools = {
          -- Ошибку под курсором разворачиваем в полный текст rustc
          -- (:RustLsp renderDiagnostic), а не в одну строку.
          float_win_config = { border = "rounded" },
        },
        server = {
          on_attach = function(_, bufnr)
            -- Inlay hints: типы let-биндингов и имена параметров. В Rust они
            -- дают больше, чем шума, поэтому включены сразу; <leader>rh гасит.
            vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
          end,
          default_settings = {
            ["rust-analyzer"] = {
              -- clippy вместо голого cargo check на сохранении.
              checkOnSave = true,
              check = {
                command = "clippy",
                extraArgs = { "--no-deps" },
              },
              cargo = {
                -- Отдельный target-dir: иначе clippy от rust-analyzer
                -- забирает лок на target/ и блокирует твой cargo build.
                targetDir = true,
                buildScripts = { enable = true },
                features = "all",
              },
              procMacro = { enable = true },

              -- Автодополнение по всему std и всем зависимостям, а не только
              -- по тому, что уже импортировано в файл.
              completion = {
                -- Предлагает `HashMap` до того, как написан `use` — и
                -- дописывает use сам при выборе.
                autoimport = { enable = true },
                -- Полная сигнатура в меню, а не голое имя.
                fullFunctionSignatures = { enable = true },
                -- Вызов подставляется с аргументами-плейсхолдерами.
                callable = { snippets = "fill_arguments" },
                -- Постфиксы: `x.if`, `vec.iter`, `opt.match`, `e.dbg`.
                postfix = { enable = true },
                -- `.await` и `.iter()` дописываются там, где они нужны по типу.
                autoAwait = { enable = true },
                autoIter = { enable = true },
                -- По умолчанию rust-analyzer режет выдачу; std большой.
                limit = 200,
                termSearch = { enable = true },
              },
              imports = {
                granularity = { group = "module" },
                prefix = "self",
              },
              -- <leader>fw ищет символы не только в проекте, но и в std
              -- и зависимостях.
              workspace = {
                symbol = {
                  search = { scope = "workspace_and_dependencies", kind = "all_symbols" },
                },
              },
              inlayHints = {
                lifetimeElisionHints = { enable = "skip_trivial" },
                closureReturnTypeHints = { enable = "with_block" },
              },
              files = {
                excludeDirs = { ".direnv", ".git", "target" },
              },
            },
          },
        },
        dap = {
          -- codelldb из mason подхватывается автоматически.
        },
      }
    end,
  },

  -- Cargo.toml: версии зависимостей виртуальным текстом, апгрейды,
  -- автодополнение имён крейтов и фич. Работает как in-process LSP,
  -- так что completion идёт через уже настроенный cmp-nvim-lsp.
  {
    "saecki/crates.nvim",
    tag = "v0.7.1",
    event = { "BufRead Cargo.toml" },
    opts = {
      completion = {
        crates = { enabled = true },
      },
      lsp = {
        enabled = true,
        actions = true,
        completion = true,
        hover = true,
      },
    },
    config = function(_, opts)
      local crates = require "crates"
      crates.setup(opts)

      vim.api.nvim_create_autocmd("BufRead", {
        group = vim.api.nvim_create_augroup("UserCratesKeys", { clear = true }),
        pattern = "Cargo.toml",
        callback = function(args)
          local function map(lhs, rhs, desc)
            vim.keymap.set("n", lhs, rhs, { buffer = args.buf, silent = true, desc = "Crates " .. desc })
          end
          map("<leader>cv", crates.show_versions_popup, "Versions")
          map("<leader>cf", crates.show_features_popup, "Features")
          map("<leader>cd", crates.show_dependencies_popup, "Dependencies")
          map("<leader>cu", crates.update_crate, "Update crate")
          map("<leader>cU", crates.upgrade_crate, "Upgrade crate")
          map("<leader>cA", crates.upgrade_all_crates, "Upgrade all")
          map("<leader>ct", crates.toggle, "Toggle crates")
          map("<leader>cR", crates.reload, "Reload")
          map("K", function()
            if crates.popup_available() then
              crates.show_popup()
            else
              vim.lsp.buf.hover()
            end
          end, "Hover / crate popup")
        end,
      })
    end,
  },

  -- nvim-dap уже в дереве (тянется nvim-dap-python), но без UI отладка
  -- сводится к :DapContinue вслепую. dap-ui даёт переменные/стек/точки.
  {
    "rcarriga/nvim-dap-ui",
    dependencies = { "mfussenegger/nvim-dap", "nvim-neotest/nvim-nio" },
    keys = {
      {
        "<leader>Du",
        function()
          require("dapui").toggle()
        end,
        desc = "DAP UI toggle",
      },
      {
        "<leader>Db",
        function()
          require("dap").toggle_breakpoint()
        end,
        desc = "DAP toggle breakpoint",
      },
      {
        "<leader>DB",
        function()
          vim.ui.input({ prompt = "Breakpoint condition: " }, function(cond)
            if cond and cond ~= "" then
              require("dap").set_breakpoint(cond)
            end
          end)
        end,
        desc = "DAP conditional breakpoint",
      },
      {
        "<leader>Dc",
        function()
          require("dap").continue()
        end,
        desc = "DAP continue",
      },
      {
        "<leader>Dt",
        function()
          require("dap").terminate()
          require("dapui").close()
        end,
        desc = "DAP terminate",
      },
      {
        "<leader>De",
        function()
          require("dapui").eval()
        end,
        mode = { "n", "v" },
        desc = "DAP eval",
      },
      {
        "<F5>",
        function()
          require("dap").continue()
        end,
        desc = "DAP continue",
      },
      {
        "<F10>",
        function()
          require("dap").step_over()
        end,
        desc = "DAP step over",
      },
      {
        "<F11>",
        function()
          require("dap").step_into()
        end,
        desc = "DAP step into",
      },
      {
        "<F12>",
        function()
          require("dap").step_out()
        end,
        desc = "DAP step out",
      },
    },
    config = function()
      local dap, dapui = require "dap", require "dapui"
      dapui.setup()

      dap.listeners.before.attach.dapui_config = dapui.open
      dap.listeners.before.launch.dapui_config = dapui.open
      dap.listeners.before.event_terminated.dapui_config = dapui.close
      dap.listeners.before.event_exited.dapui_config = dapui.close

      vim.fn.sign_define("DapBreakpoint", { text = "●", texthl = "DiagnosticError" })
      vim.fn.sign_define("DapStopped", { text = "▶", texthl = "DiagnosticWarn", linehl = "Visual" })
    end,
  },
}
