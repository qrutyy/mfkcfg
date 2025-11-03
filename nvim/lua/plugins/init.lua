-- ~/.config/nvim/lua/plugins/init.lua
return {
  {
    "stevearc/conform.nvim",
    event = 'BufWritePre',
    config = function()
      require "configs.conform"
    end,
  },

  {
    "mfussenegger/nvim-lint",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      require "configs.lint"
    end,
  },
  {
    "qrutyy/checkpatch.nvim",
    -- or: dir = "/absolute/path/to/checkpatch.nvim" for a local checkout
    ft = { "c" },
    cmd = { "Checkpatch" },
    opts = {
      -- you can override default keymaps here
      -- mappings = { run = { keys = "<leader>cp" }, next = { keys = "," }, prev = { keys = "<" } }
    },
    config = function(_, opts)
      require("plugins.checkpatch").setup(opts)
    end,
  },
  {
    "f-person/git-blame.nvim",
    event = "VeryLazy",
    config = function()
	-- включить сразу при старте
	vim.g.gitblame_enabled = 1

	-- шаблон сообщения
	vim.g.gitblame_message_template = " <summary> • <date> • <author> • <<sha>>"

	-- формат даты
	vim.g.gitblame_date_format = "%m-%d-%Y %H:%M:%S"

	-- колонка для виртуального текста (1 = сразу после кода)
	vim.g.gitblame_virtual_text_column = 1
    end,
  },  
  {
    "neovim/nvim-lspconfig",
    config = function()
      require("nvchad.configs.lspconfig").defaults()
      require "configs.lspconfig"
    end,
  },

  -- GitHub Actions support
  {
    "someone-stole-my-name/yaml-companion.nvim",
    ft = { "yaml" },
    dependencies = {
      "neovim/nvim-lspconfig",
      "nvim-lua/plenary.nvim",
      "nvim-telescope/telescope.nvim",
    },
    config = function()
      require("telescope").load_extension("yaml_schema")
    end,
  },

  -- Swift support
  {
    "xbase-lab/xbase",
    ft = { "swift" },
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-telescope/telescope.nvim",
    },
    config = function()
      require("xbase").setup({})
    end,
  },

  -- Kotlin support
  {
    "udalov/kotlin-vim",
    ft = { "kotlin" },
  },

  -- Python support
  {
    "linux-cultist/venv-selector.nvim",
    ft = { "python" },
    dependencies = {
      "neovim/nvim-lspconfig", 
      "nvim-telescope/telescope.nvim",
      "mfussenegger/nvim-dap-python"
    },
    config = function()
      require("venv-selector").setup()
    end,
  },

  {
    "williamboman/mason.nvim",
    opts = {
      ensure_installed = {
        -- Language Servers
        "lua-language-server",
        "html-lsp",
        "css-lsp",
        "clangd",
        "ocaml-lsp",
        "bash-language-server",
        "dockerfile-language-server",
        "yaml-language-server",
        "json-lsp",
        "marksman",  -- Markdown LSP
        "cmake-language-server",
        "kotlin-language-server",
        "sourcekit-lsp",  -- Swift LSP
        "pyright",  -- Python LSP
        
        -- Formatters
        "stylua",
        "prettier",
        "shfmt",  -- Shell formatter
        "black",   -- Python formatter
        
        -- Linters
        "shellcheck",
        "hadolint",  -- Dockerfile linter
        "yamllint",
        "markdownlint",
        "jsonlint",
        "swiftlint",
        "actionlint",  -- GitHub Actions linter
        "ktlint",  -- Kotlin linter
        "flake8",  -- Python linter
      },
    },
  },

  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = {
        "vim",
        "lua",
        "vimdoc",
        "html",
        "css",
        "c",
        "cpp",
        "ocaml",
        "bash",
        "dockerfile",
        "yaml",
        "json",
        "markdown",
        "markdown_inline",
        "make",
        "cmake",
        "python",
        "swift",
        "kotlin",
      },
    },
  },
}

