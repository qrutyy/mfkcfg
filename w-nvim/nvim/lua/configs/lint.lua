local lint = require "lint"

-- Настройка линтеров для разных типов файлов
lint.linters_by_ft = {
  sh = { "shellcheck" },
  bash = { "shellcheck" },
  zsh = { "shellcheck" },
  dockerfile = { "hadolint" },
  yaml = { "yamllint" },
  yml = { "yamllint" },
  markdown = { "markdownlint" },
  make = { "checkmake" },
  makefile = { "checkmake" },
  json = { "jsonlint" },
  python = { "flake8" },
  swift = { "swiftlint" },
  kotlin = { "ktlint" },
}

-- Настройка специальных линтеров
lint.linters.checkmake = {
  cmd = "checkmake",
  stdin = false,
  args = { "--format", "{{.LineNumber}}:{{.Rule}}:{{.Violation}}" },
  ignore_exitcode = true,
  parser = function(output)
    local diagnostics = {}
    for line in output:gmatch("[^\n]+") do
      local row, rule, message = line:match("(%d+):([^:]+):(.+)")
      if row and rule and message then
        table.insert(diagnostics, {
          lnum = tonumber(row) - 1,
          col = 0,
          message = string.format("[%s] %s", rule, message),
          severity = vim.diagnostic.severity.WARN,
          source = "checkmake",
        })
      end
    end
    return diagnostics
  end,
}

-- Настройка actionlint для GitHub Actions
lint.linters.actionlint = {
  cmd = "actionlint",
  stdin = false,
  args = { "-format", "{{range $err := .}}{{$err.Filepath}}:{{$err.Line}}:{{$err.Column}}:{{$err.Message}}{{end}}" },
  ignore_exitcode = true,
  parser = function(output)
    local diagnostics = {}
    for line in output:gmatch("[^\n]+") do
      local file, row, col, message = line:match("([^:]+):(%d+):(%d+):(.+)")
      if row and col and message then
        table.insert(diagnostics, {
          lnum = tonumber(row) - 1,
          col = tonumber(col) - 1,
          message = message,
          severity = vim.diagnostic.severity.ERROR,
          source = "actionlint",
        })
      end
    end
    return diagnostics
  end,
}

-- Специальная настройка для GitHub Actions файлов
vim.api.nvim_create_autocmd({"BufRead", "BufNewFile"}, {
  pattern = {".github/workflows/*.yml", ".github/workflows/*.yaml"},
  callback = function()
    lint.linters_by_ft.yaml = lint.linters_by_ft.yaml or {}
    table.insert(lint.linters_by_ft.yaml, "actionlint")
  end,
})

-- Автоматический запуск линтеров
local lint_augroup = vim.api.nvim_create_augroup("lint", { clear = true })

vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave" }, {
  group = lint_augroup,
  callback = function()
    lint.try_lint()
  end,
})
