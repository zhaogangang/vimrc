local api = vim.api
local km = vim.keymap

local function load_autocmd()
    api.nvim_create_autocmd(
        { "BufWinLeave" },
        {
            pattern = { "*.*" },
            command = "mkview",
            group = custom_auto_cmd,
        }
    )
    api.nvim_create_autocmd(
        { "BufWinEnter" },
        {
            pattern = { "*.*" },
            command = "silent! loadview",
            group = custom_auto_cmd,
        }
    )
end

local function load_custom_map()
    km.set({ 'i' }, "<A-d>", "<esc>lcw", { noremap = true, silent = true, desc = "delete next word" })
    km.set({ 'i' }, "<c-j>", "<Down>", { noremap = true, silent = true, desc = "jump to next line" })
    km.set({ 'i' }, "<c-k>", "<Up>", { noremap = true, silent = true, desc = "jump to prev line" })
    km.set({ 'i' }, "<c-e>", "<End>", { noremap = true, silent = true, desc = "jump to end of current line" })
    km.set({ 'i' }, "<c-a>", "<esc>I", { noremap = true, silent = true, desc = "jump to start of current line" })
    km.set({ 'i' }, "<c-s>", "<cmd>w<cr>", { noremap = true, silent = true, desc = "save current buffer" })
    km.set({ 'i', 'c' }, "<c-d>", "<del>", { noremap = true, silent = false, desc = "delete next char" })
    km.set({ 'i', 'c' }, "<c-h>", "<left>", { noremap = true, silent = false, desc = "left char" })
    km.set({ 'i', 'c' }, "<c-l>", "<right>", { noremap = true, silent = false, desc = "right char" })
    km.set({ 'i', 'c' }, "<A-h>", "<c-Left>", { noremap = true, silent = false, desc = "left word" })
    km.set({ 'i', 'c' }, "<A-l>", "<c-Right>", { noremap = true, silent = false, desc = "right word" })

    km.set({ 'c' }, "<c-a>", "<Home>", { noremap = true, silent = false, desc = "jump to start of cmdline" })
    km.set({ 'c' }, "<A-d>", "<c-right><c-w>", { noremap = true, silent = false, desc = "delete next word" })

    km.set({ 'n' }, "<c-h>", "<c-w>h", { noremap = true, silent = true, desc = "jump to left window" })
    km.set({ 'n' }, "<c-j>", "<c-w>j", { noremap = true, silent = true, desc = "jump to right window" })
    km.set({ 'n' }, "<c-k>", "<c-w>k", { noremap = true, silent = true, desc = "jump to up window" })
    km.set({ 'n' }, "<c-l>", "<c-w>l", { noremap = true, silent = true, desc = "jump to down window" })
end

local function load()
    load_custom_map()
    load_autocmd()
end

load()
