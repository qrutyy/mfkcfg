-- ~/.config/nvim/lua/plugins/tools.lua
--
-- Навигация (fzf-native, cscope, flash), git (gitsigns-хоткеи, diffview,
-- neogit) и trouble. Цвета для flash/diffview/neogit/trouble берутся из
-- base46 — интеграции перечислены в chadrc.lua.

local function hl(name)
  pcall(dofile, vim.g.base46_cache .. name)
end

return {
  ---------------------------------------------------------------------------
  -- Telescope: нативный fzf-сортировщик. На live_grep по дереву ядра
  -- lua-сортировщик ощутимо тормозит. Синтаксис запроса: 'exact ^prefix
  -- suffix$ !not.
  ---------------------------------------------------------------------------
  {
    "nvim-telescope/telescope.nvim",
    dependencies = {
      { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
    },
    opts = function(_, opts)
      opts.extensions_list = opts.extensions_list or {}
      table.insert(opts.extensions_list, "fzf")
      opts.extensions = opts.extensions or {}
      opts.extensions.fzf = {
        fuzzy = true,
        override_generic_sorter = true,
        override_file_sorter = true,
        case_mode = "smart_case",
      }
      return opts
    end,
  },

  ---------------------------------------------------------------------------
  -- cscope: кто вызывает функцию, что она вызывает, где присваивается
  -- символ. Работает по индексу, без clangd. Префикс <leader>s.
  -- Базу ядра строит :KernelCscope (lua/kernel.lua), базу проекта — <leader>sb.
  ---------------------------------------------------------------------------
  {
    "dhananjaylatkar/cscope_maps.nvim",
    ft = { "c", "cpp" },
    cmd = { "Cs", "Cscope", "CsStackView" },
    keys = {
      { "<leader>s", desc = "cscope" },
      -- Дерево вызовов для символа под курсором. Заглавные — «древесные»
      -- версии <leader>sc (кто вызывает) и <leader>sd (что вызывает).
      { "<leader>sC", "<cmd>CsStackView open down<cr>", desc = "cscope: callers tree" },
      { "<leader>sD", "<cmd>CsStackView open up<cr>", desc = "cscope: callees tree" },
      { "<leader>sv", "<cmd>CsStackView toggle<cr>", desc = "cscope: reopen last tree" },
    },
    opts = {
      prefix = "<leader>s",
      cscope = {
        -- Функция, а не таблица: база ядра подхватывается, как только
        -- :KernelCscope её построит, без перезапуска nvim.
        db_file = function()
          local db = { "./cscope.out" }
          local src = require("kernel").src()
          if src and vim.uv.fs_stat(vim.fs.joinpath(src, "cscope.out")) then
            -- "::@" — пути в базе относительные, к ним дописывается
            -- каталог, где лежит сама база.
            table.insert(db, vim.fs.joinpath(src, "cscope.out") .. "::@")
          end
          return db
        end,
        exec = "cscope",
        picker = "telescope",
        skip_picker_for_single_result = true,
        -- -R: без него cscope индексирует только файлы текущего каталога.
        db_build_cmd = { script = "default", args = { "-Rbqk" } },
      },
    },
  },

  ---------------------------------------------------------------------------
  -- flash: s + 2 символа + метка — прыжок в любую точку экрана.
  -- S — выделить узел treesitter (функцию, блок, аргумент).
  ---------------------------------------------------------------------------
  {
    "folke/flash.nvim",
    event = "VeryLazy",
    opts = {},
    config = function(_, opts)
      hl "flash"
      require("flash").setup(opts)
    end,
    keys = {
      { "s", mode = { "n", "x", "o" }, function() require("flash").jump() end, desc = "Flash" },
      { "S", mode = { "n", "x", "o" }, function() require("flash").treesitter() end, desc = "Flash treesitter" },
      { "r", mode = "o", function() require("flash").remote() end, desc = "Flash remote" },
      { "R", mode = { "o", "x" }, function() require("flash").treesitter_search() end, desc = "Flash treesitter search" },
      { "<c-s>", mode = "c", function() require("flash").toggle() end, desc = "Flash in / search" },
    },
  },

  ---------------------------------------------------------------------------
  -- Git
  ---------------------------------------------------------------------------
  -- gitsigns уже ставит NvChad; добавляем работу с ханками и blame
  -- (вместо git-blame.nvim, который делал то же самое отдельным плагином).
  {
    "lewis6991/gitsigns.nvim",
    opts = function(_, opts)
      opts.current_line_blame = true
      opts.current_line_blame_opts = { delay = 300, virt_text_pos = "eol" }
      opts.current_line_blame_formatter = " <summary> • <author_time:%d-%m-%Y> • <author>"
      opts.on_attach = function(bufnr)
        local gs = require "gitsigns"
        local function map(mode, lhs, rhs, desc)
          vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, silent = true, desc = "Git " .. desc })
        end

        map("n", "]h", function()
          if vim.wo.diff then
            vim.cmd.normal { "]c", bang = true }
          else
            gs.nav_hunk "next"
          end
        end, "Next hunk")
        map("n", "[h", function()
          if vim.wo.diff then
            vim.cmd.normal { "[c", bang = true }
          else
            gs.nav_hunk "prev"
          end
        end, "Prev hunk")

        map("n", "<leader>gs", gs.stage_hunk, "Stage/unstage hunk")
        map("v", "<leader>gs", function()
          gs.stage_hunk { vim.fn.line ".", vim.fn.line "v" }
        end, "Stage selected lines")
        map("n", "<leader>gr", gs.reset_hunk, "Reset hunk")
        map("v", "<leader>gr", function()
          gs.reset_hunk { vim.fn.line ".", vim.fn.line "v" }
        end, "Reset selected lines")
        map("n", "<leader>gS", gs.stage_buffer, "Stage buffer")
        map("n", "<leader>gR", gs.reset_buffer, "Reset buffer")
        map("n", "<leader>gp", gs.preview_hunk_inline, "Preview hunk")
        map("n", "<leader>gB", function()
          gs.blame_line { full = true }
        end, "Blame line (full)")
        map("n", "<leader>gb", gs.toggle_current_line_blame, "Toggle line blame")
        map("n", "<leader>gw", gs.toggle_word_diff, "Toggle word diff")
        map({ "o", "x" }, "ih", gs.select_hunk, "Select hunk")
      end
      return opts
    end,
  },

  -- diffview: дифф по всем файлам, история файла/ветки, 3-way merge.
  {
    "sindrets/diffview.nvim",
    cmd = { "DiffviewOpen", "DiffviewFileHistory", "DiffviewClose" },
    keys = {
      { "<leader>gd", "<cmd>DiffviewOpen<cr>", desc = "Diffview: working tree" },
      { "<leader>gD", "<cmd>DiffviewOpen HEAD~1<cr>", desc = "Diffview: last commit" },
      { "<leader>gh", "<cmd>DiffviewFileHistory %<cr>", desc = "Diffview: file history" },
      { "<leader>gH", "<cmd>DiffviewFileHistory<cr>", desc = "Diffview: branch history" },
      { "<leader>gh", ":DiffviewFileHistory<cr>", mode = "v", desc = "Diffview: selection history" },
      { "<leader>gq", "<cmd>DiffviewClose<cr>", desc = "Diffview: close" },
    },
    config = function(_, opts)
      hl "diffview"
      require("diffview").setup(opts)
    end,
  },

  -- neogit: магит-подобный интерфейс — stage, commit, rebase, push.
  {
    "NeogitOrg/neogit",
    cmd = "Neogit",
    dependencies = { "nvim-lua/plenary.nvim", "sindrets/diffview.nvim" },
    keys = {
      { "<leader>gg", "<cmd>Neogit<cr>", desc = "Neogit" },
      { "<leader>gc", "<cmd>Neogit commit<cr>", desc = "Neogit commit" },
      { "<leader>gl", "<cmd>Neogit log<cr>", desc = "Neogit log" },
    },
    opts = {
      kind = "tab",
      integrations = { diffview = true, telescope = true },
      graph_style = "unicode",
    },
    config = function(_, opts)
      hl "neogit"
      require("neogit").setup(opts)
    end,
  },

  ---------------------------------------------------------------------------
  -- trouble: списки диагностик, references, quickfix. Префикс <leader>q:
  -- <leader>x у NvChad закрывает буфер.
  ---------------------------------------------------------------------------
  {
    "folke/trouble.nvim",
    cmd = "Trouble",
    opts = {
      focus = true,
    },
    config = function(_, opts)
      hl "trouble"
      require("trouble").setup(opts)
    end,
    keys = {
      { "<leader>qq", "<cmd>Trouble diagnostics toggle<cr>", desc = "Trouble: workspace diagnostics" },
      { "<leader>qb", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>", desc = "Trouble: buffer diagnostics" },
      { "<leader>qs", "<cmd>Trouble symbols toggle focus=false<cr>", desc = "Trouble: symbols" },
      { "<leader>ql", "<cmd>Trouble lsp toggle focus=false win.position=right<cr>", desc = "Trouble: LSP defs/refs" },
      { "<leader>qf", "<cmd>Trouble qflist toggle<cr>", desc = "Trouble: quickfix" },
      { "<leader>qL", "<cmd>Trouble loclist toggle<cr>", desc = "Trouble: loclist" },
      {
        "]q",
        function()
          if require("trouble").is_open() then
            require("trouble").next { skip_groups = true, jump = true }
          else
            pcall(vim.cmd.cnext)
          end
        end,
        desc = "Next trouble/quickfix item",
      },
      {
        "[q",
        function()
          if require("trouble").is_open() then
            require("trouble").prev { skip_groups = true, jump = true }
          else
            pcall(vim.cmd.cprev)
          end
        end,
        desc = "Prev trouble/quickfix item",
      },
    },
  },
}
