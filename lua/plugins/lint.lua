return {
	{
		"mfussenegger/nvim-lint",
		event = { "BufWritePost", "BufReadPost" },
		config = function()
			require("lint").linters_by_ft = {
				python = { "flake8" },
			}

			-- Создаем таблицу для отслеживания состояния диагностики по буферам
			local lint_disable_buffers = {}

			-- Функция для переключения состояния диагностики
			local function toggle_lint()
				local bufnr = vim.api.nvim_get_current_buf()
				lint_disable_buffers[bufnr] = not lint_disable_buffers[bufnr]

				if lint_disable_buffers[bufnr] then
					vim.diagnostic.enable(false)
					vim.notify("Lint отключен для этого буфера", vim.log.levels.INFO)
				else
					vim.diagnostic.enable()
					vim.notify("Lint включен для этого буфера", vim.log.levels.INFO)
				end
			end

			-- Создаем пользовательские команды
			vim.api.nvim_create_user_command("LintDisable", function()
				local bufnr = vim.api.nvim_get_current_buf()
				lint_disable_buffers[bufnr] = true
				vim.diagnostic.enable(false)
				vim.notify("Lint отключен для этого буфера", vim.log.levels.INFO)
			end, {})

			vim.api.nvim_create_user_command("LintEnable", function()
				local bufnr = vim.api.nvim_get_current_buf()
				lint_disable_buffers[bufnr] = false
				vim.diagnostic.enable()
				require("lint").try_lint() -- Запускаем проверку после включения
				vim.notify("Lint включен для этого буфера", vim.log.levels.INFO)
			end, {})

			vim.api.nvim_create_user_command("LintToggle", toggle_lint, {})

			-- Модифицируем автопроверку с учетом состояния
			vim.api.nvim_create_autocmd({ "BufWritePost" }, {
				callback = function()
					local bufnr = vim.api.nvim_get_current_buf()
					if not lint_disable_buffers[bufnr] then
						require("lint").try_lint()
					end
				end,
			})
		end,
	},
	{
		"rshkarin/mason-nvim-lint",
		dependencies = {
			"mfussenegger/nvim-lint",
			"https://github.com/williamboman/mason.nvim",
		},
		config = function()
			require("mason-nvim-lint").setup({
				ensure_installed = { "eslint_d" },
			})
		end,
	},
}
