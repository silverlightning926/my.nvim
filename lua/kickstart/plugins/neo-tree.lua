return {
  'nvim-neo-tree/neo-tree.nvim',
  version = '*',
  dependencies = {
    'nvim-lua/plenary.nvim',
    'nvim-tree/nvim-web-devicons',
    'MunifTanjim/nui.nvim',
    'nvim-telescope/telescope.nvim',
  },
  lazy = false,
  config = function()
    require('neo-tree').setup {
      window = {
        width = 35,
        resizable = false,
        position = 'left',
      },
      filesystem = {
        filtered_items = {
          visible = true,
          hide_dotfiles = false,
          hide_gitignored = true,
        },
        follow_current_file = {
          enabled = true,
          leave_dirs_open = false,
        },
        use_libuv_file_watcher = true,
      },
      default_component_configs = {
        indent = {
          indent_size = 2,
          padding = 1,
          with_markers = true,
          indent_marker = '│',
          last_indent_marker = '└',
          highlight = 'NeoTreeIndentMarker',
        },
        icon = {
          folder_closed = '→',
          folder_open = '↓',
          default = '*',
          highlight = 'NeoTreeFileIcon',
          folder_empty = '',
          folder_empty_open = '-',
        },
        modified = {
          symbol = '[+]',
          highlight = 'NeoTreeModified',
        },
        name = {
          trailing_slash = false,
          use_git_status_colors = true,
          highlight = 'NeoTreeFileName',
        },
        git_status = {
          symbols = {
            added = '△',
            modified = '◇',
            deleted = '▽',
            renamed = '⇌',
            untracked = '◦',
            ignored = '⊘',
            unstaged = '◯',
            staged = '◉',
            conflict = '⊗',
          },
        },
      },
    }

    vim.api.nvim_create_autocmd('VimEnter', {
      callback = function()
        vim.cmd 'Neotree show'

        vim.defer_fn(function()
          for _, win in ipairs(vim.api.nvim_list_wins()) do
            local buf = vim.api.nvim_win_get_buf(win)
            local filetype = vim.api.nvim_buf_get_option(buf, 'filetype')
            if filetype ~= 'neo-tree' then
              vim.api.nvim_set_current_win(win)
              break
            end
          end
        end, 50)
      end,
    })

    vim.api.nvim_create_autocmd('WinEnter', {
      callback = function()
        if vim.bo.filetype == 'neo-tree' then
          for _, win in ipairs(vim.api.nvim_list_wins()) do
            local buf = vim.api.nvim_win_get_buf(win)
            local filetype = vim.api.nvim_buf_get_option(buf, 'filetype')
            if filetype ~= 'neo-tree' then
              vim.api.nvim_set_current_win(win)
              break
            end
          end
        end
      end,
    })
  end,
}
