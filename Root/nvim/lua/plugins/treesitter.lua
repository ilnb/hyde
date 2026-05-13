return {
  {
    'folke/which-key.nvim',
    opts = {
      spec = {
        { '<BS>',      desc = 'Decrement Selection', mode = 'x' },
        { '<c-space>', desc = 'Increment Selection', mode = { 'x', 'n' } },
      },
    },
  },

  {
    'nvim-treesitter/nvim-treesitter',
    build = ':TSUpdate',
    event = { 'BufReadPre', 'BufNewFile' },
    dependencies = {
      {
        'nvim-treesitter/nvim-treesitter-textobjects',
        event = { 'BufReadPre', 'BufNewFile' },
      }
    },
    opts_extend = { 'ensure' },
    opts = {
      ignore = { 'csv' },
      ensure = {
        'asm', 'bash', 'c', 'cpp', 'css', 'diff',
        'html', 'hyprlang', 'javascript', 'jsdoc',
        'json', 'lua', 'luadoc', 'luap',
        'markdown', 'markdown_inline', 'python',
        'query', 'regex', 'toml', 'typescript',
        'typst', 'vim', 'vimdoc', 'xml', 'yaml',
        'zig', 'desktop',
      },
    },
    config = function(_, opts)
      local ok, ts = pcall(require, 'nvim-treesitter')
      if not ok then return end
      ts.setup(opts)

      local langs = vim.tbl_filter(function(l)
        return not vim.tbl_contains(opts.ignore or {}, l)
      end, opts.ensure)

      local have = ts.get_installed()
      local they_have = ts.get_available()

      local function attach(buf)
        local ft = vim.bo[buf].filetype
        if ft == '' or not vim.tbl_contains(langs, ft) then return end

        pcall(vim.treesitter.start, buf)
        if vim.bo[buf].indentexpr == '' then
          vim.bo[buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
        end
      end

      local to_install = vim.tbl_filter(function(l)
        return not vim.tbl_contains(have, l) and vim.tbl_contains(they_have, l)
      end, langs)

      if #to_install > 0 then
        ts.install(to_install):await(function()
          for _, buf in ipairs(vim.api.nvim_list_bufs()) do
            attach(buf)
          end
        end)
      end

      vim.api.nvim_create_autocmd('FileType', {
        group = vim.api.nvim_create_augroup('treesitter_attach', { clear = true }),
        pattern = langs,
        callback = function(ev)
          attach(ev.buf)
        end,
      })

      for _, buf in ipairs(vim.api.nvim_list_bufs()) do
        attach(buf)
      end

      local map = vim.keymap.set

      local move = require 'nvim-treesitter-textobjects.move'
      local move_tbl = { f = '@function.outer', c = '@class.outer', a = '@parameter.inner' }
      for key, capture in pairs(move_tbl) do
        map('n', ']' .. key, function() move.goto_next_start(capture, 'textobjects') end)
        map('n', ']' .. key:upper(), function() move.goto_next_end(capture, 'textobjects') end)
        map('n', '[' .. key, function() move.goto_previous_start(capture, 'textobjects') end)
        map('n', '[' .. key:upper(), function() move.goto_previous_end(capture, 'textobjects') end)
      end

      local swap = require 'nvim-treesitter-textobjects.swap'
      map('n', '<a-l>', function() swap.swap_next '@parameter.inner' end)
      map('n', '<a-h>', function() swap.swap_previous '@parameter.inner' end)
    end,
  },
}
