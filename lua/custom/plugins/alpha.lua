return {
  'goolord/alpha-nvim',
  dependencies = { 'nvim-tree/nvim-web-devicons' },
  lazy = false,
  config = function()
    local alpha = require 'alpha'
    local dashboard = require 'alpha.themes.dashboard'

    dashboard.section.header.val = {
      '                                                     ',
      '  ███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗ ',
      '  ████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║ ',
      '  ██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║ ',
      '  ██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║ ',
      '  ██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║ ',
      '  ╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝ ',
      '                                                     ',
    }

    local leader = vim.g.mapleader or ' '
    local leader_display = leader == ' ' and 'SPC' or leader

    local function create_button(key, icon, desc, cmd, color)
      local display_key = key:find(leader_display) and key or (leader_display .. ' ' .. key)
      local button_text = string.format('%s  %s', icon, desc)
      local btn = dashboard.button(display_key, button_text, cmd)

      if color then
        btn.opts.hl = color
      end

      return btn
    end

    dashboard.section.buttons.val = {
      create_button('SPC s c', '󰈚', 'Create File', '<cmd>lua vim.api.nvim_feedkeys(" sc", "n", false)<CR>', 'AlphaButtonFile'),
      create_button('SPC s r', '󰅖', 'Remove File', '<cmd>lua vim.api.nvim_feedkeys(" sr", "n", false)<CR>', 'AlphaButtonFile'),

      { type = 'text', val = '', opts = { hl = 'AlphaButtons', position = 'center' } },

      create_button('SPC s f', '󰈞', 'Find File', '<cmd>Telescope find_files<CR>', 'AlphaButtonSearch'),
      create_button('SPC s g', '󰊄', 'Find Word', '<cmd>Telescope live_grep<CR>', 'AlphaButtonSearch'),

      { type = 'text', val = '', opts = { hl = 'AlphaButtons', position = 'center' } },

      create_button('q', '󰅚', 'Quit NVIM', '<cmd>qa<CR>', 'AlphaButtonSystem'),
    }

    local header_padding = math.max(2, math.floor(vim.fn.winheight(0) * 0.15))
    local section_padding = 2

    dashboard.config.layout = {
      { type = 'padding', val = header_padding },
      dashboard.section.header,
      { type = 'padding', val = section_padding },
      dashboard.section.buttons,
    }

    dashboard.section.header.opts.hl = 'AlphaHeader'
    dashboard.section.buttons.opts.hl = 'AlphaButtons'

    dashboard.opts.opts = {
      noautocmd = true,
      margin = 5,
    }

    -- Store original cursor and options
    local original_guicursor = vim.opt.guicursor:get()
    local original_cursorline = vim.opt.cursorline:get()
    local original_cursorcolumn = vim.opt.cursorcolumn:get()

    vim.api.nvim_create_autocmd('User', {
      pattern = 'AlphaReady',
      callback = function()
        -- Hide cursor completely
        vim.opt.guicursor = 'a:block-Cursor/lCursor-blinkwait0-blinkon0-blinkoff0'
        vim.opt.cursorline = false
        vim.opt.cursorcolumn = false

        -- Make buffer non-interactive
        vim.bo.modifiable = false
        vim.bo.readonly = true

        -- Hide cursor highlight
        vim.cmd [[
          hi Cursor blend=100
          hi lCursor blend=100
          hi CursorLine guibg=NONE
          hi CursorColumn guibg=NONE
        ]]

        -- Set up color scheme
        vim.cmd [[
          " Main header - bright blue
          hi AlphaHeader guifg=#7aa2f7 gui=bold
          
          " Individual function colors
          hi AlphaButtonFile guifg=#f7768e gui=bold           " Pink for file creation
          hi AlphaButtonFileWarn guifg=#ff9e64 gui=bold       " Orange for file removal (warning)
          hi AlphaButtonSearch guifg=#9ece6a gui=bold         " Green for search functions
          hi AlphaButtonSystem guifg=#e0af68 gui=bold         " Yellow for system functions
          
          " Default button color (fallback)
          hi AlphaButtons guifg=#bb9af7
        ]]
      end,
    })

    -- Restore cursor when leaving Alpha
    vim.api.nvim_create_autocmd('User', {
      pattern = 'AlphaClosed',
      callback = function()
        vim.opt.guicursor = original_guicursor
        vim.opt.cursorline = original_cursorline
        vim.opt.cursorcolumn = original_cursorcolumn

        -- Restore cursor highlight
        vim.cmd [[
          hi Cursor blend=0
          hi lCursor blend=0
        ]]
      end,
    })

    -- Additional autocmd to handle leaving alpha buffer
    vim.api.nvim_create_autocmd('BufLeave', {
      pattern = '*',
      callback = function()
        if vim.bo.filetype == 'alpha' then
          vim.opt.guicursor = original_guicursor
          vim.opt.cursorline = original_cursorline
          vim.opt.cursorcolumn = original_cursorcolumn

          vim.cmd [[
            hi Cursor blend=0
            hi lCursor blend=0
          ]]
        end
      end,
    })

    alpha.setup(dashboard.opts)
  end,
}
