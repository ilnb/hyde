local function lualine_theme()
  local theme = {}
  local color = vim.g.colors_name or ''
  if color:find 'kanagawa' then
    theme = require 'lualine.themes.kanagawa'
  elseif color:find 'catppuccin' then
    theme = require 'lualine.themes.catppuccin-mocha'
  elseif color:find 'kanso' then
    theme = require 'lualine.themes.kanso'
    local palette = require 'kanso.colors'.setup().palette

    ---@type fun(s:string, p:number):string
    local function darker(s, p)
      local r = tonumber(s:sub(2, 3), 16)
      local g = tonumber(s:sub(4, 5), 16)
      local b = tonumber(s:sub(6, 8), 16)
      p = 1 - p -- p% black
      local f = math.floor
      r = f(r * p + 0.5)
      g = f(g * p + 0.5)
      b = f(b * p + 0.5)
      return string.format('#%02X%02X%02X', r, g, b)
    end

    local overrides = {
      normal = {
        b = { bg = darker(palette.inkBlue2, 0.75) }
      },
      insert = {
        b = { bg = darker(palette.springGreen, 0.75) }
      },
      command = {
        b = { bg = darker(palette.inkGray2, 0.75) }
      },
      visual = {
        b = { bg = darker(palette.inkViolet, 0.75) }
      },
      replace = {
        b = { bg = darker(palette.inkOrange, 0.75) }
      },
    }
    for mode, sections in pairs(overrides) do
      theme[mode] = vim.tbl_deep_extend('force', theme[mode] or {}, sections)
    end
  else
    theme = require 'lualine.themes.palenight'
    local overrides = {
      normal = {
        a = { bg = '#82B1FF' }, -- blue
        b = { fg = '#82B1FF' },
      },
      insert = {
        a = { bg = '#C3E88D' }, -- green
        b = { fg = '#C3E88D' },
      },
      visual = {
        a = { bg = '#C792EA' }, -- purple
        b = { fg = '#C792EA' },
      },
      replace = {
        a = { bg = '#FFA066' }, -- orange
        b = { fg = '#FFA066' },
      },
      inactive = {
        a = { bg = '#82B1FF' },
        b = { fg = '#82B1FF' },
        c = { fg = '#697098' },
      },
    }
    for mode, sections in pairs(overrides) do
      theme[mode] = vim.tbl_deep_extend('force', theme[mode] or {}, sections)
    end
  end
  for _, sections in pairs(theme) do
    sections.c = sections.c or {}
    sections.c.bg = 'NONE'
  end
  return theme
end

local function os_icon()
  local distro = 'Arch'
  local handle = io.popen 'cat /etc/*release 2>/dev/null | grep ^NAME='
  if not handle then
    return 'Arch'
  else
    distro = handle:read '*a'
    distro = distro:gsub('^NAME="?(.-)"?$', '%1')
    handle:close()
  end
  if distro:match 'Ubuntu' then
    return ''
  elseif distro:match 'Arch' then
    return ''
  elseif distro:match 'Fedora' then
    return ''
  elseif distro:match 'Debian' then
    return ''
  elseif distro:match 'Mint' then
    return '󰣭'
  end
  return ''
end

return {
  'nvim-lualine/lualine.nvim',
  event = 'VeryLazy',

  init = function()
    vim.g.lualine_laststatus = vim.o.laststatus
    if vim.fn.argc(-1) > 0 then
      -- set an empty statusline till lualine loads
      vim.o.statusline = ' '
    else
      -- hide the statusline on the starter page
      vim.o.laststatus = 0
    end
  end,

  opts = function()
    -- PERF: we don't need this lualine require madness 🤷
    require 'lualine_require'.require = require
    vim.o.laststatus = vim.g.lualine_laststatus

    vim.api.nvim_create_autocmd('ColorScheme', {
      callback = function()
        require 'lualine'.setup {
          options = { theme = lualine_theme() },
        }
      end
    })

    local opts = {
      options = {
        theme = lualine_theme(),
        globalstatus = vim.o.laststatus == 3,
        disabled_filetypes = { statusline = { 'dashboard', 'alpha', 'ministarter', 'snacks_dashboard' } },
      },

      sections = {
        lualine_a = { 'mode' },
        lualine_b = { 'branch' },

        lualine_c = {
          {
            'diagnostics',
            symbols = {
              error = " ",
              warn  = " ",
              info  = " ",
              hint  = " ",
            },
          },

          {
            'filetype',
            icon_only = true,
            separator = "",
            padding = { left = 1, right = 0 }
          },

          'filename',
          {
            function()
              local navic = require 'nvim-navic'
              return navic.get_location()
            end,
            cond = function()
              local ok, navic = pcall(require, 'nvim-navic')
              return ok and navic.is_available()
            end,
            color = 'dynamic',
          }
        },

        lualine_x = {
          Snacks.profiler.status(),
          {
            function() return require 'noice'.api.status.command.get() end,
            cond = function() return package.loaded['noice'] and require 'noice'.api.status.command.has() end,
            color = function() return { fg = Snacks.util.color 'Statement' } end,
          },

          {
            function() return require 'noice'.api.status.mode.get() end,
            cond = function() return package.loaded['noice'] and require 'noice'.api.status.mode.has() end,
            color = function() return { fg = Snacks.util.color 'Constant' } end,
          },

          {
            function() return '  ' .. require 'dap'.status() end,
            cond = function() return package.loaded['dap'] and require 'dap'.status() ~= '' end,
            color = function() return { fg = Snacks.util.color 'Debug' } end,
          },

          {
            require 'lazy.status'.updates,
            cond = require 'lazy.status'.has_updates,
            color = function() return { fg = Snacks.util.color 'Special' } end,
          },

          {
            'diff',
            symbols = {
              added = '+',
              modified = '~',
              removed = '-',
            },

            -- separator = "",
            source = function()
              local gitsigns = vim.b.gitsigns_status_dict
              if gitsigns then
                return {
                  added = gitsigns.added,
                  modified = gitsigns.changed,
                  removed = gitsigns.removed,
                }
              end
            end,
          },

          {
            function() return os_icon() end
          }
        },

        lualine_y = {
          {
            'progress',
            separator = ' ',
            padding = { left = 1, right = 0 },
          },

          {
            'location',
            padding = { left = 0, right = 1 },
          },
        },

        lualine_z = {
          function()
            return ' ' .. os.date '%R'
          end,
        },
      },
      extensions = { 'fzf', 'lazy', 'mason' },
    }

    return opts
  end
}
