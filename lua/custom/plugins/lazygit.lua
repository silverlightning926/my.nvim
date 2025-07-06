return {
  'akinsho/toggleterm.nvim',
  version = '*',
  config = function()
    require('toggleterm').setup {
      size = 20,
      open_mapping = [[<c-\>]],
      hide_numbers = true,
      shade_filetypes = {},
      shade_terminals = true,
      shading_factor = 2,
      start_in_insert = true,
      insert_mappings = true,
      persist_size = true,
      direction = 'float',
      close_on_exit = true,
      shell = vim.o.shell,
      float_opts = {
        border = 'curved',
        winblend = 0,
        highlights = {
          border = 'Normal',
          background = 'Normal',
        },
      },
    }

    function _set_terminal_keymaps()
      local opts = { buffer = 0 }

      vim.keymap.set('t', '<ESC>', '<C-\\><C-n>', opts)

      vim.keymap.set('t', '<ESC>', '<C-c>', opts)
    end

    vim.api.nvim_create_autocmd('TermOpen', {
      pattern = '*',
      callback = _set_terminal_keymaps,
    })

    local Terminal = require('toggleterm.terminal').Terminal
    local lazygit = Terminal:new {
      cmd = 'lazygit',
      dir = 'git_dir',
      direction = 'float',
      float_opts = {
        border = 'double',
      },

      on_open = function(term)
        vim.cmd 'startinsert!'
        vim.api.nvim_buf_set_keymap(term.bufnr, 'n', 'q', '<cmd>close<CR>', { noremap = true, silent = true })

        vim.api.nvim_buf_set_keymap(term.bufnr, 'n', '<ESC>', '<cmd>close<CR>', { noremap = true, silent = true })
        vim.api.nvim_buf_set_keymap(term.bufnr, 't', '<ESC>', '<cmd>close<CR>', { noremap = true, silent = true })
      end,

      on_close = function(term)
        vim.cmd 'startinsert!'
      end,
    }

    function _lazygit_toggle()
      lazygit:toggle()
    end

    vim.api.nvim_set_keymap('n', '<leader>go', '<cmd>lua _lazygit_toggle()<CR>', { noremap = true, silent = true, desc = '[G]it UI [O]pen' })
  end,
}
