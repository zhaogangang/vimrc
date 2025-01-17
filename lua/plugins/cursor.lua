local g = vim.g

local function autopair_multi_line_jump()
    local npairs               = require("nvim-autopairs")
    local cond                 = require('nvim-autopairs.conds')
    local utils                = require('nvim-autopairs.utils')
    local rule                 = require('nvim-autopairs.rule')

    local multiline_close_jump = function(open, close)
        return rule(close, "")
            :with_pair(function()
                local row, col = utils.get_cursor(0)
                local line = utils.text_get_current_line(0)

                if #line ~= col then --not at EOL
                    return false
                end

                local unclosed_count = 0
                for c in line:gmatch("[\\" .. open .. "\\" .. close .. "]") do
                    if c == open then unclosed_count = unclosed_count + 1 end
                    if unclosed_count > 0 and c == close then unclosed_count = unclosed_count - 1 end
                end
                if unclosed_count > 0 then return false end

                local nextrow = row + 1

                if nextrow < vim.api.nvim_buf_line_count(0) and vim.regex("^\\s*" .. close):match_line(0, nextrow) then
                    return true
                end
                return false
            end)
            :with_move(cond.none())
            :with_cr(cond.none())
            :with_del(cond.none())
            :set_end_pair_length(0)
            :replace_endpair(function(opts)
                local row, _ = utils.get_cursor(0)
                local action = vim.regex("^" .. close):match_line(0, row + 1) and "a" or ("0f%sa"):format(opts.char)
                return ("<esc>xj%s"):format(action)
            end)
    end

    npairs.add_rules({
        multiline_close_jump('(', ')'),
        multiline_close_jump('[', ']'),
        multiline_close_jump('{', '}'),
    })
end


local function autopair_insert_space()
    local npairs = require 'nvim-autopairs'
    local rule = require 'nvim-autopairs.rule'
    local cond = require 'nvim-autopairs.conds'

    local brackets = { { '(', ')' }, { '[', ']' }, { '{', '}' } }
    npairs.add_rules {
        rule(' ', ' ')
            :with_pair(function(opts)
                local pair = opts.line:sub(opts.col - 1, opts.col)
                return vim.tbl_contains({
                    brackets[1][1] .. brackets[1][2],
                    brackets[2][1] .. brackets[2][2],
                    brackets[3][1] .. brackets[3][2]
                }, pair)
            end)
            :with_move(cond.none())
            :with_cr(cond.none())
            :with_del(function(opts)
                local col = vim.api.nvim_win_get_cursor(0)[2]
                local context = opts.line:sub(col - 1, col + 2)
                return vim.tbl_contains({
                    brackets[1][1] .. '  ' .. brackets[1][2],
                    brackets[2][1] .. '  ' .. brackets[2][2],
                    brackets[3][1] .. '  ' .. brackets[3][2]
                }, context)
            end)
    }
    for _, bracket in pairs(brackets) do
        rule('', ' ' .. bracket[2])
            :with_pair(cond.none())
            :with_move(function(opts) return opts.char == bracket[2] end)
            :with_cr(cond.none())
            :with_del(cond.none())
            :use_key(bracket[2])
    end
end

local function autopair_pairs()
    local npairs = require('nvim-autopairs')
    local Rule = require('nvim-autopairs.rule')
    local cond = require('nvim-autopairs.conds')
    npairs.add_rules({
        Rule("<", ">", { "rust" })
            :with_pair(cond.not_before_regex(" ", 1))
            :with_move(function(opts)
                if opts.char == "<" then
                    return false
                else
                    return true
                end
            end)
            :with_cr(cond.none())
    }
    )
end

local function autopair_move_past()
    for _, punct in pairs { ",", ";" } do
        require "nvim-autopairs".add_rules {
            require "nvim-autopairs.rule" ("", punct)
                :with_move(function(opts) return opts.char == punct end)
                :with_pair(function() return false end)
                :with_del(function() return false end)
                :with_cr(function() return false end)
                :use_key(punct)
        }
    end
end

return {
    {
        "windwp/nvim-autopairs",
        event = "InsertEnter",
        config = function()
            local npairs = require("nvim-autopairs")
            npairs.setup {
                disable_filetype = { "TelescopePrompt", "spectre_panel" },
                disable_in_macro = false,       -- disable when recording or executing a macro
                disable_in_visualblock = false, -- disable when insert after visual block mode
                disable_in_replace_mode = true,
                ignored_next_char = [=[[%w%%%'%[%"%.%`%$]]=],
                enable_moveright = true,
                enable_afterquote = true,         -- add bracket pairs after quote
                enable_check_bracket_line = true, --- check bracket in same line
                enable_bracket_in_quote = true,   --
                enable_abbr = false,              -- trigger abbreviation
                break_undo = true,                -- switch for basic rule break undo sequence
                check_ts = true,
                map_cr = true,
                map_bs = true,   -- map the <BS> key
                map_c_h = false, -- Map the <C-h> key to delete a pair
                map_c_w = true,  -- map <c-w> to delete a pair if possible
                fast_wrap = {
                    map = '<M-p>',
                    chars = { '{', '[', '(', '"', "'" },
                    pattern = [=[[%'%"%>%]%)%}%,]]=],
                    end_key = '$',
                    keys = 'qwertyuiopzxcvbnmasdfghjkl',
                    check_comma = true,
                    manual_position = false,
                    highlight = 'Search',
                    highlight_grey = 'Comment'
                },
            }

            autopair_multi_line_jump()
            autopair_insert_space()
            autopair_move_past()
            autopair_pairs()
        end,
    },
    {
        'kylechui/nvim-surround',
        keys = {
            { "y",  nil, mode = "n" },
            { "dx", nil, mode = "n" },
            { "cx", nil, mode = "n" },
            { "X",  nil, mode = "x" },
            { "gX", nil, mode = "x" },
        },
        version = "*",
        config = function()
            require("nvim-surround").setup({
                keymaps = {
                    insert = false,
                    insert_line = false,
                    normal = "yx",
                    normal_cur = "yxx",
                    normal_line = "yX",
                    normal_cur_line = "yXX",
                    visual = "X",
                    visual_line = "gX",
                    delete = "dx",
                    change = "cx",
                },
            })
        end
    },
    {
        'junegunn/vim-easy-align',
        keys = {
            { "ga", "<Plug>(EasyAlign)", { noremap = true, silent = true }, mode = { "n", "x" }, desc = "EasyAlign" }
        },
    },
    {
        'mg979/vim-visual-multi',
        keys = {
            { "<leader>v", nil, mode = { "n", "x" }, desc = "VisualMutil One" },
            { "<leader>V", nil, mode = { "n", "x" }, desc = "VisualMutil All" },
            { "<C-Up>",    nil, mode = { "n" },      desc = "VisualMutil Up" },
            { "<C-Down>",  nil, mode = { "n" },      desc = "VisualMutil Down" },
        },
        init = function()
            g.VM_maps = {
                ['Find Under'] = '<leader>v',
                ['Find Subword Under'] = '<leader>v',
                ["Select All"] = '<leader>V',
                ["Visual All"] = '<leader>V',
            }
        end
    },
}
