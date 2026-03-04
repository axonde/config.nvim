-- MY CUSTOMIZATION
vim.o.expandtab = true
vim.o.tabstop = 4
vim.o.softtabstop = 4
vim.o.shiftwidth = 4

-- SHORTCUTS
vim.keymap.set("n", "<leader>h", "<C-w>h")
vim.keymap.set("n", "<leader>j", "<C-w>j")
vim.keymap.set("n", "<leader>k", "<C-w>k")
vim.keymap.set("n", "<leader>l", "<C-w>l")

-- Russian keyboard settings
vim.opt.keymap = "russian-jcukenwin"
vim.opt.iminsert = 0
_G.keyboard_layout = "EN"

local function change_cursor_color_lnk_keyboard()
    if vim.fn.has("macunix") ~= 1 or vim.fn.has("gui_running") == 1 then
        return
    end
    local color = _G.keyboard_layout == "RU" and "6D37FF" or "00FF00"
    local escape_seq = string.format("\27]Pl%s\27\\", color)
    vim.fn.chansend(vim.v.stderr, escape_seq)
end

local function toggle_keyboard_layout()
    local new_iminsert = vim.o.iminsert == 0 and 1 or 0
    vim.o.iminsert = new_iminsert
    _G.keyboard_layout = new_iminsert == 1 and "RU" or "EN"
    change_cursor_color_lnk_keyboard()

    if vim.fn.has("gui_running") == 1 then
        vim.cmd("redraw")
    end

    local current_mode = vim.fn.mode()

    if current_mode == "i" then
        vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>a", true, false, true), "n", false)
    end

    if package.loaded["lualine"] then
        require("lualine").refresh()
    end
end

vim.api.nvim_create_autocmd("VimLeave", {
    callback = function()
        if vim.o.iminsert == 1 then
            toggle_keyboard_layout()
        end
    end,
})

vim.api.nvim_set_keymap("i", "<C-Space>", "", {
    noremap = true,
    silent = true,
    callback = toggle_keyboard_layout,
})
vim.api.nvim_set_keymap("n", "<C-Space>", "", {
    noremap = true,
    silent = true,
    callback = toggle_keyboard_layout,
})
vim.api.nvim_set_keymap("x", "<C-Space>", "", {
    noremap = true,
    silent = true,
    callback = toggle_keyboard_layout,
})

-- Lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
    local lazyrepo = "https://github.com/folke/lazy.nvim.git"
    local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
    if vim.v.shell_error ~= 0 then
        vim.api.nvim_echo({
            { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
            { out,                            "WarningMsg" },
            { "\nPress any key to exit..." },
        }, true, {})
        vim.fn.getchar()
        os.exit(1)
    end
end
vim.opt.rtp:prepend(lazypath)

-- Setup lazy.nvim (all plugins are in lua/plugins.lua)
require("lazy").setup("plugins")
