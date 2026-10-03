-- Per-directory sessions.
--
-- Раньше сессия была одна на всё (~/.config/nvim/session.vim) и восстанавливалась
-- безусловно, из-за чего в любом проекте открывались буферы из всех остальных.
-- Теперь сессия хранится отдельно для каждого cwd и НЕ восстанавливается сама,
-- пока не выставлен vim.g.auto_restore_session.

local M = {}

local dir = vim.fs.joinpath(vim.fn.stdpath "state", "sessions")

local function session_file(cwd)
  cwd = cwd or vim.uv.cwd()
  return vim.fs.joinpath(dir, (cwd:gsub("[\\/:]+", "%%")) .. ".vim")
end

-- Не сохраняем пустую сессию: иначе один запуск "nvim" без файлов затирает
-- нормальную сессию проекта.
local function has_real_buffers()
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if
      vim.bo[buf].buflisted
      and vim.bo[buf].buftype == ""
      and vim.api.nvim_buf_get_name(buf) ~= ""
    then
      return true
    end
  end
  return false
end

function M.save()
  if not has_real_buffers() then
    return
  end
  vim.fn.mkdir(dir, "p")
  pcall(vim.cmd, "NvimTreeClose")
  pcall(vim.cmd, "mksession! " .. vim.fn.fnameescape(session_file()))
end

function M.restore(cwd)
  local file = session_file(cwd)
  if vim.fn.filereadable(file) == 0 then
    vim.notify("No session for " .. (cwd or vim.uv.cwd()), vim.log.levels.WARN)
    return false
  end
  vim.cmd("silent! source " .. vim.fn.fnameescape(file))
  return true
end

function M.delete()
  local file = session_file()
  if vim.fn.delete(file) == 0 then
    vim.notify("Session removed: " .. file)
  else
    vim.notify("No session for " .. vim.uv.cwd(), vim.log.levels.WARN)
  end
end

-- Восстанавливаем автоматически только когда nvim запущен голым: без файлов
-- в аргументах, без stdin и не в режиме diff.
local function started_bare()
  return vim.fn.argc(-1) == 0 and not vim.g.started_with_stdin and not vim.opt.diff:get()
end

function M.setup()
  -- "options" тянет за собой глобальные опции и конфликтует с конфигом,
  -- "help" восстанавливает окна справки. curdir нужен, чтобы сессия
  -- возвращалась в свой каталог.
  vim.opt.sessionoptions = {
    "buffers",
    "curdir",
    "folds",
    "tabpages",
    "winsize",
    "winpos",
    "localoptions",
  }

  local group = vim.api.nvim_create_augroup("UserSession", { clear = true })

  vim.api.nvim_create_autocmd("StdinReadPre", {
    group = group,
    callback = function()
      vim.g.started_with_stdin = true
    end,
  })

  vim.api.nvim_create_autocmd("VimLeavePre", { group = group, callback = M.save })

  if vim.g.auto_restore_session then
    vim.api.nvim_create_autocmd("VimEnter", {
      group = group,
      nested = true,
      callback = function()
        if started_bare() and vim.fn.filereadable(session_file()) == 1 then
          M.restore()
        end
      end,
    })
  end

  vim.api.nvim_create_user_command("SessionRestore", function()
    M.restore()
  end, { desc = "Restore session for cwd" })
  vim.api.nvim_create_user_command("SessionSave", M.save, { desc = "Save session for cwd" })
  vim.api.nvim_create_user_command("SessionDelete", M.delete, { desc = "Delete session for cwd" })
end

return M
