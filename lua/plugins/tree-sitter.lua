return {
    "nvim-treesitter/nvim-treesitter",
    lazy = false,
    build = ":TSUpdate",
    opts = {
        auto_install = true,
        highlight = {
            enable = true
        }
    }
}
