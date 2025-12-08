return {
	"stevearc/conform.nvim",
	event = { "BufWritePre" },
	cmd = { "ConformInfo" },
	opts = {
		formatters_by_ft = {
			lua = { "stylua" },
			python = { "black" },
			javascript = { "prettier" },
			typescript = { "prettier" },
			javascriptreact = { "prettier" },
			typescriptreact = { "prettier" },
			svelte = { "prettier" },
			html = { "prettier" },
			css = { "prettier" },
			json = { "prettier" },
			c = { "clang-format" },
			cpp = { "clang-format" },
			cs = { "csharpier" },

			-- Для случаев, когда нужно несколько форматтеров
			-- Используем новый синтаксис с stop_after_first
			markdown = { "prettier", "markdownlint", stop_after_first = true },
		},
		format_on_save = function(bufnr)
			if vim.b[bufnr].noformat then
				return false
			end
			return {
				timeout_ms = 900,
				lsp_fallback = true,
				async = false,
			}
		end,
		log_level = vim.log.levels.WARN,
	},
}
