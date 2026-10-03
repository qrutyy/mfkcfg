-- ~/.config/nvim/lua/configs/cmp.lua
--
-- Надстройка над nvchad.configs.cmp. Задача — чтобы в меню попадали не только
-- символы текущего файла, но и API стандартных библиотек (std у Rust, typeshed
-- у Python, системные заголовки у C) плюс конструкции языка из friendly-snippets.
--
-- Экспортируется функцией (opts-хук lazy.nvim): NvChad отдаёт готовую таблицу,
-- мы её дополняем, а не переписываем — иначе теряются маппинги и тема.
local cmp = require "cmp"
local compare = require "cmp.config.compare"

return function(_, opts)
  -- Полный fuzzy: `hmap` находит HashMap, `unwrp` — unwrap_or_else.
  -- disallow_prefix_unmatching = false — главное здесь: без него кандидат
  -- обязан начинаться с того, что ты набрал.
  opts.matching = {
    disallow_fuzzy_matching = false,
    disallow_fullfuzzy_matching = false,
    disallow_partial_fuzzy_matching = false,
    disallow_partial_matching = false,
    disallow_prefix_unmatching = false,
  }

  -- Фильтрация по большому индексу std бывает тяжёлой, поэтому ограничиваем
  -- не количество кандидатов, а число отрисованных строк.
  opts.performance = vim.tbl_extend("force", opts.performance or {}, {
    max_view_entries = 40,
    fetching_timeout = 250,
  })

  opts.sorting = {
    priority_weight = 2,
    comparators = {
      compare.offset,
      compare.exact,
      compare.score,
      -- Точные совпадения регистра выше: Ok выше ok_or.
      function(a, b)
        local da, db = a.completion_item.deprecated, b.completion_item.deprecated
        if da ~= db then
          return not da
        end
      end,
      compare.recently_used,
      compare.locality,
      compare.kind,
      compare.length,
      compare.order,
    },
  }

  opts.sources = cmp.config.sources {
    -- Основной источник символов: сюда приходят std/крейты/typeshed/заголовки.
    { name = "nvim_lsp", priority = 1000, max_item_count = 50 },
    -- Конструкции языка: match/impl/fn/for у Rust, for/while/struct у C,
    -- class/def/with у Python — friendly-snippets, грузится NvChad'ом.
    { name = "luasnip", priority = 900, max_item_count = 10 },
    -- Сигнатуры вызываемой функции прямо в меню.
    { name = "nvim_lsp_signature_help", priority = 850 },
    { name = "nvim_lua", priority = 800 },
    {
      name = "buffer",
      priority = 400,
      keyword_length = 3,
      max_item_count = 8,
      -- Слова из всех загруженных буферов, а не только текущего.
      option = {
        get_bufnrs = function()
          local bufs = {}
          for _, b in ipairs(vim.api.nvim_list_bufs()) do
            -- Мегабайтные файлы (vendored-исходники, логи) не индексируем.
            if vim.api.nvim_buf_is_loaded(b) and vim.api.nvim_buf_line_count(b) < 20000 then
              bufs[#bufs + 1] = b
            end
          end
          return bufs
        end,
      },
    },
    { name = "async_path", priority = 300 },
  }

  return opts
end
