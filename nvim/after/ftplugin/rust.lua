-- ~/.config/nvim/after/ftplugin/rust.lua
--
-- Маппинги rustaceanvim. Только буферные: :RustLsp существует лишь там,
-- где поднят rust-analyzer.
local bufnr = vim.api.nvim_get_current_buf()

local function map(lhs, rhs, desc, mode)
  vim.keymap.set(mode or "n", lhs, rhs, { buffer = bufnr, silent = true, desc = "Rust " .. desc })
end

local function rust(...)
  local args = { ... }
  return function()
    vim.cmd.RustLsp(#args == 1 and args[1] or args)
  end
end

-- Go to definition. Прыгает и по своему коду, и внутрь std / крейтов из
-- ~/.cargo/registry — для исходников std нужен компонент rust-src
-- (rustup component add rust-src), иначе прыжок в std молча не сработает.
-- Обратно — <C-o>.
map("gd", function()
  require("telescope.builtin").lsp_definitions()
end, "Go to definition")
map("gy", vim.lsp.buf.type_definition, "Go to type definition")

-- Hover с actions: из поповера можно прыгнуть в реализацию/Go to type.
map("K", rust { "hover", "actions" }, "Hover actions")
-- Code actions с группировкой rust-analyzer'а.
map("<leader>ca", rust "codeAction", "Code action")

map("<leader>rr", rust "runnables", "Runnables")
map("<leader>rt", rust "testables", "Testables")
map("<leader>rd", rust "debuggables", "Debuggables")
map("<leader>rl", rust "runnables", "Runnables")

-- Последний выбранный runnable/testable/debuggable — без повторного меню.
map("<leader>rR", function()
  vim.cmd.RustLsp { "runnables", bang = true }
end, "Rerun last runnable")
map("<leader>rT", function()
  vim.cmd.RustLsp { "testables", bang = true }
end, "Rerun last testable")

map("<leader>rm", rust "expandMacro", "Expand macro")
map("<leader>rp", rust "parentModule", "Parent module")
map("<leader>rc", rust "openCargo", "Open Cargo.toml")
map("<leader>rD", rust "openDocs", "Open docs.rs")
-- Полный текст ошибки rustc (E0499 и прочие «смотри развёрнутое объяснение»).
map("<leader>re", rust "explainError", "Explain error")
map("<leader>rx", rust "renderDiagnostic", "Render diagnostic")

map("<leader>rj", rust("moveItem", "down"), "Move item down")
map("<leader>rk", rust("moveItem", "up"), "Move item up")

map("<leader>rh", function()
  vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled { bufnr = bufnr }, { bufnr = bufnr })
end, "Toggle inlay hints")

-- rustfmt по умолчанию держит 100 колонок.
vim.opt_local.colorcolumn = "100"
