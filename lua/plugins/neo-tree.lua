return {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    dependencies = {
        "nvim-lua/plenary.nvim",
        "nvim-tree/nvim-web-devicons", -- not strictly required, but recommended
        "MunifTanjim/nui.nvim",
    },
    lazy = false,
    filesystem = {
        -- Включает поиск по частям пути (а не только по точному имени файла)
        search_by_full_path = true,
        -- Использует системные команды поиска (fd/find/rg)
        use_libuv_file_watcher = true,

        filters = {
            max_depth = 99,
        }
    },
    config = function()
        vim.keymap.set('n', '<C-n>', ":Neotree toggle<CR>")
        vim.keymap.set('n', '<leader>n', ":Neotree focus<CR>")
        vim.keymap.set('n', '<leader>cd', function()
            local path = vim.fn.input("Path: ", "", "dir")
            if path ~= "" then
                vim.cmd("Neotree filesystem dir=" .. path)
            end
        end)
    end
}
