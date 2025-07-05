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

    -- Simple, reliable startup behavior
    vim.api.nvim_create_autocmd('VimEnter', {
      callback = function()
        -- Always show Neo-tree on startup
        vim.cmd 'Neotree show'

        -- Always show Alpha dashboard on startup
        vim.defer_fn(function()
          vim.cmd 'Alpha'
        end, 100)
      end,
    })

    -- Prevent focus from staying on Neo-tree when entering windows
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

    -- Auto-quit when only Neo-tree is left
    vim.api.nvim_create_autocmd({ 'BufDelete', 'WinClosed' }, {
      callback = function()
        vim.schedule(function()
          local windows = vim.api.nvim_list_wins()
          local non_neotree_windows = {}

          for _, win in ipairs(windows) do
            local buf = vim.api.nvim_win_get_buf(win)
            local filetype = vim.api.nvim_buf_get_option(buf, 'filetype')

            if filetype ~= 'neo-tree' then
              table.insert(non_neotree_windows, win)
            end
          end

          -- If no non-neo-tree windows remain, quit Neovim
          if #non_neotree_windows == 0 and #windows > 0 then
            vim.cmd 'quit'
          end
        end)
      end,
    })
  end,
}
