return {
  'folke/snacks.nvim',
  priority = 1000,
  lazy = false,
  keys = {
    {
      '<leader>dd',
      function()
        for _, win in ipairs(vim.api.nvim_list_wins()) do
          local buf = vim.api.nvim_win_get_buf(win)
          if vim.bo[buf].ft == 'snacks_dashboard' then
            if vim.api.nvim_buf_is_valid(buf) and vim.api.nvim_buf_is_loaded(buf) then
              vim.api.nvim_buf_delete(buf, { force = true })
            end
            return
          end
        end
        Snacks.dashboard()
      end,
      desc = 'Dashboard',
    },

    { '<leader>n', function() Snacks.picker.notifications() end,  desc = 'Notifications' },
    { '<leader>N', function() Snacks.notifier.show_history() end, desc = 'Notification history' },
  },
  ---@type snacks.Config
  opts = {
    indent = {
      enabled = true,
      scope = { enabled = false },
    },
    input = { enabled = true },
    notifier = { enabled = true },
    scope = { enabled = true },
    scroll = { enabled = true },
    words = { enabled = true },

    statuscolumn = {
      left = { 'fold', 'mark' },
      right = { 'sign', 'git' },
      folds = { open = true },
    },

    ---@type snacks.dashboard.Config
    ---@diagnostic disable: missing-fields
    dashboard = {
      sections = {
        {
          header =

            [[
⣇⣿⠘⣿⣿⣿⡿⡿⣟⣟⢟⢟⢝⠵⡝⣿⡿⢂⣼⣿⣷⣌⠩⡫⡻⣝⠹⢿⣿⣿
⡆⣿⣆⠱⣝⡵⣝⢅⠙⣿⢕⢕⢕⢕⢝⣥⢒⠅⣿⣿⣿⡿⣳⣌⠪⡪⣡⢑⢝⣇
⡆⣿⣿⣦⠹⣳⣳⣕⢅⠈⢗⢕⢕⢕⢕⢕⢈⢆⠟⠋⠉⠁⠉⠉⠁⠈⠼⢐⢕⢽
⡗⢰⣶⣶⣦⣝⢝⢕⢕⠅⡆⢕⢕⢕⢕⢕⣴⠏⣠⡶⠛⡉⡉⡛⢶⣦⡀⠐⣕⢕
⡝⡄⢻⢟⣿⣿⣷⣕⣕⣅⣿⣔⣕⣵⣵⣿⣿⢠⣿⢠⣮⡈⣌⠨⠅⠹⣷⡀⢱⢕
⡝⡵⠟⠈⢀⣀⣀⡀⠉⢿⣿⣿⣿⣿⣿⣿⣿⣼⣿⢈⡋⠴⢿⡟⣡⡇⣿⡇⡀⢕
⡝⠁⣠⣾⠟⡉⡉⡉⠻⣦⣻⣿⣿⣿⣿⣿⣿⣿⣿⣧⠸⣿⣦⣥⣿⡇⡿⣰⢗⢄
⠁⢰⣿⡏⣴⣌⠈⣌⠡⠈⢻⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣬⣉⣉⣁⣄⢖⢕⢕⢕
⡀⢻⣿⡇⢙⠁⠴⢿⡟⣡⡆⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣷⣵⣵⣿
⡻⣄⣻⣿⣌⠘⢿⣷⣥⣿⠇⣿⣿⣿⣿⣿⣿⠛⠻⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿
⣷⢄⠻⣿⣟⠿⠦⠍⠉⣡⣾⣿⣿⣿⣿⣿⣿⢸⣿⣦⠙⣿⣿⣿⣿⣿⣿⣿⣿⠟
⡕⡑⣑⣈⣻⢗⢟⢞⢝⣻⣿⣿⣿⣿⣿⣿⣿⠸⣿⠿⠃⣿⣿⣿⣿⣿⣿⡿⠁⣠
⡝⡵⡈⢟⢕⢕⢕⢕⣵⣿⣿⣿⣿⣿⣿⣿⣿⣿⣶⣶⣿⣿⣿⣿⣿⠿⠋⣀⣈⠙
⡝⡵⡕⡀⠑⠳⠿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠿⠛⢉⡠⡲⡫⡪⡪⡣
]]
        },
        {
          icon = '󱌣 ',
          title = 'Actions',
          indent = 2,
          padding = 1,
          {
            icon = ' ',
            desc = 'Find file',
            key = "f",
            action = function()
              require'fzf-lua'.files {fd_opts = '-I -t f -E .git -H'}
            end
          },

          { icon = '󰒲 ', desc = 'Lazy', key = 'l', action = ':Lazy' },
          { icon = ' ', desc = 'Lazy Extras', key = 'x', action = ':LazyExtras' },
          { icon = ' ', desc = 'Exit', key = 'q', action = ':q' },
        },
        { icon = ' ', title = 'Recent Files', section = 'recent_files', indent = 2, padding = 1 },
        { section = 'startup' },
      },

      formats = {
        key = function(item)
          -- return { { '·', hl = 'special' }, { item.key, hl = 'key' }, { '·', hl = 'special' } }
          return { { '⟦', hl = 'special' }, { item.key, hl = 'key' }, { '⟧', hl = 'special' } }
        end,
      },
    },
  },
  config = function(_, opts)
    local notify = vim.notify
    require 'snacks'.setup(opts)
    if require 'lazy.core.config'.spec.plugins['noice.nvim'] then
      vim.notify = notify
    end
  end,
}
