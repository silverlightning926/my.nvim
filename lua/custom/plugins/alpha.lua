return {
    'goolord/alpha-nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    lazy = false,
    config = function()
        local alpha = require 'alpha'
        local dashboard = require 'alpha.themes.dashboard'

        dashboard.section.header.val = {
            '                                                     ',
            '  ███╗   ██╗███████╗ ██████╗ ██╗   ██╗██║███╗   ███╗ ',
            '  ████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║ ',
            '  ██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║ ',
            '  ██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║ ',
            '  ██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║ ',
            '  ╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝ ',
            '                                                     ',
        }

        local leader = vim.g.mapleader or ' '
        local leader_display = leader == ' ' and 'SPC' or leader

        local function create_button(key, icon, desc, color, command)
            local display_key = key:find(leader_display) and key or (leader_display .. ' ' .. key)
            local button_text = string.format('%s  %s', icon, desc)
            -- Use actual command instead of empty string
            local btn = dashboard.button(display_key, button_text, command or '')

            if color then
                btn.opts.hl = color
            end

            return btn
        end

        -- Create file function
        local function create_file_command()
            return function()
                local builtin = require 'telescope.builtin'
                local actions = require 'telescope.actions'
                local action_state = require 'telescope.actions.state'
                local finders = require 'telescope.finders'
                local pickers = require 'telescope.pickers'
                local conf = require('telescope.config').values

                pickers.new({}, {
                    prompt_title = 'Select Directory to Create File',
                    finder = finders.new_oneshot_job({ 'find', '.', '-type', 'd' }, {
                        entry_maker = function(entry)
                            return {
                                value = entry,
                                display = entry,
                                ordinal = entry,
                                path = entry,
                            }
                        end,
                    }),
                    sorter = conf.generic_sorter {},
                    attach_mappings = function(prompt_bufnr, map)
                        actions.select_default:replace(function()
                            local selection = action_state.get_selected_entry()
                            if selection then
                                local dir_path = selection.path or selection.value
                                actions.close(prompt_bufnr)
                                vim.ui.input({
                                    prompt = 'Enter filename: ',
                                    completion = 'file',
                                }, function(filename)
                                    if filename and filename ~= '' then
                                        local file_path = dir_path .. '/' .. filename
                                        local parent_dir = vim.fn.fnamemodify(file_path, ':h')
                                        vim.fn.mkdir(parent_dir, 'p')
                                        local file = io.open(file_path, 'w')
                                        if file then
                                            file:close()
                                            vim.cmd('edit ' .. vim.fn.fnameescape(file_path))
                                            print('Created and opened: ' .. file_path)
                                        else
                                            print('Failed to create: ' .. file_path)
                                        end
                                    end
                                end)
                            end
                        end)
                        return true
                    end,
                }):find()
            end
        end

        -- Remove file function
        local function remove_file_command()
            return function()
                local builtin = require 'telescope.builtin'
                local actions = require 'telescope.actions'
                local action_state = require 'telescope.actions.state'

                builtin.find_files {
                    prompt_title = 'Remove File',
                    attach_mappings = function(prompt_bufnr, map)
                        actions.select_default:replace(function()
                            local selection = action_state.get_selected_entry()
                            if selection then
                                local file_path = selection.path or selection.value
                                actions.close(prompt_bufnr)
                                vim.ui.select({ 'Yes', 'No' }, {
                                    prompt = 'Delete ' .. file_path .. '?',
                                }, function(choice)
                                    if choice == 'Yes' then
                                        local success = os.remove(file_path)
                                        if success then
                                            print('Removed: ' .. file_path)
                                            local buf = vim.fn.bufnr(file_path)
                                            if buf ~= -1 then
                                                vim.cmd('bdelete! ' .. buf)
                                            end
                                        else
                                            print('Failed to remove: ' .. file_path)
                                        end
                                    end
                                end)
                            end
                        end)
                        return true
                    end,
                }
            end
        end

        dashboard.section.buttons.val = {
            create_button('SPC s c', '󰈚', '> Create File', 'AlphaButtonFile', create_file_command()),
            create_button('SPC s r', '󰅖', '> Remove File', 'AlphaButtonFile', remove_file_command()),

            { type = 'text', val = '', opts = { hl = 'AlphaButtons', position = 'center' } },

            create_button('SPC s f', '󰈞', '> Find File', 'AlphaButtonSearch', '<cmd>Telescope find_files<CR>'),
            create_button('SPC s g', '󰊄', '> Find Word', 'AlphaButtonSearch', '<cmd>Telescope live_grep<CR>'),

            { type = 'text', val = '', opts = { hl = 'AlphaButtons', position = 'center' } },

            create_button('q', '󰅚', '> Quit NVIM', 'AlphaButtonSystem', '<cmd>quit<CR>'),
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
                -- Don't make buffer readonly - allow normal keymaps to work
                vim.bo.modifiable = true
                vim.bo.readonly = false

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

        alpha.setup(dashboard.opts)
    end,
}
