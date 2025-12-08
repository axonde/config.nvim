return {
	-- Mason: Установщик LSP серверов
	{
		"williamboman/mason.nvim",
		config = function()
			require("mason").setup()
		end,
	},

	-- Mason-LSP: Автоустановка серверов
	{
		"williamboman/mason-lspconfig.nvim",
		dependencies = {
			"williamboman/mason.nvim",
			"neovim/nvim-lspconfig",
		},
		config = function()
			require("mason-lspconfig").setup({
				ensure_installed = {
					"lua_ls",
					"clangd",
					"svelte",
					"pyright",
					"emmet_language_server",
					"ts_ls",
				},
			})
		end,
	},

	-- Настройка LSP клиента
	{
		"neovim/nvim-lspconfig",
		dependencies = { "hrsh7th/nvim-cmp" },
		config = function()
			vim.diagnostic.config({
				virtual_text = true,
				update_in_insert = false,
			})

			-- Глобальные keymaps для всех LSP серверов
			vim.api.nvim_create_autocmd("LspAttach", {
				group = vim.api.nvim_create_augroup("UserLspConfig", {}),
				callback = function(args)
					local bufnr = args.buf
					local client = vim.lsp.get_client_by_id(args.data.client_id)

					-- Keymaps для всех LSP серверов
					vim.keymap.set("n", "<leader>i", vim.lsp.buf.hover, { buffer = bufnr, desc = "Hover [I]nfo" })

					vim.keymap.set({ "n", "v" }, "<leader>f", function()
						vim.lsp.buf.format({ async = false })
					end, { buffer = bufnr, desc = "LSP [F]ormat" })

					vim.keymap.set(
						{ "n", "v" },
						"<leader>ca",
						vim.lsp.buf.code_action,
						{ buffer = bufnr, desc = "LSP [C]ode [A]ctions" }
					)

					vim.keymap.set(
						{ "n", "v" },
						"<leader>d",
						vim.diagnostic.open_float,
						{ buffer = bufnr, desc = "LSP [D]iagnostics" }
					)

					-- Дополнительные keymaps по желанию
					vim.keymap.set("n", "gd", vim.lsp.buf.definition, { buffer = bufnr, desc = "[G]o to [d]efinition" })
					vim.keymap.set(
						"n",
						"gD",
						vim.lsp.buf.declaration,
						{ buffer = bufnr, desc = "[G]o to [D]eclaration" }
					)
					vim.keymap.set("n", "gr", vim.lsp.buf.references, { buffer = bufnr, desc = "[G]o to [R]eferences" })
					vim.keymap.set(
						"n",
						"gi",
						vim.lsp.buf.implementation,
						{ buffer = bufnr, desc = "[G]o to [I]mplementation" }
					)
					vim.keymap.set(
						"n",
						"<leader>rn",
						vim.lsp.buf.rename,
						{ buffer = bufnr, desc = "[R]e[N]ame symbol" }
					)
				end,
			})

			--[[ 2. CAPABILITIES ]]
			local capabilities = vim.lsp.protocol.make_client_capabilities()
			local cmp_ok, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
			if cmp_ok then
				capabilities = cmp_nvim_lsp.default_capabilities()
			end

			--[[ 3. НАСТРОЙКА СЕРВЕРОВ ]]

			require("mason-lspconfig").setup({
				function(server)
					vim.lsp.config(server, { capabilities = capabilities })
				end,
			})

			-- [[ 4. Специфичные настройки серверов ]]

			-- Lua
			vim.lsp.config("lua_ls", {
				capabilities = capabilities,
				settings = {
					Lua = {
						telemetry = { enable = false },
						runtime = { version = "LuaJIT" },
						diagnostics = { globals = { "vim" } },
						workspace = { library = vim.api.nvim_get_runtime_file("", true) },
					},
				},
			})
			vim.lsp.enable("lua_ls")

			-- Clangd (C/C++)
			vim.lsp.config("clangd", {
				capabilities = capabilities,
				cmd = {
					"clangd",
					"--background-index",
					"--clang-tidy",
					"--header-insertion=never",
					"--query-driver=/usr/bin/clang*",
				},
				filetypes = { "c", "cpp", "h", "hpp" },
				init_options = {
					compilationDatabasePath = "build",
				},
			})
			vim.lsp.enable("clangd")

			-- ESLint
			vim.lsp.config("eslint", {
				capabilities = capabilities,
				settings = {
					eslint = {
						validate = "on",
						codeAction = { disableRuleComment = { enable = true } },
						experimental = { useFlatConfig = true },
						workingDirectory = { mode = "auto" },
					},
				},
			})
			vim.lsp.enable("eslint")

			-- Svelte
			vim.lsp.config("svelte", {
				capabilities = capabilities,
			})
			vim.lsp.enable("svelte")

			-- TypeScript/JavaScript
			vim.lsp.config("ts_ls", {
				capabilities = capabilities,

				-- Ключевые настройки для JS!
				init_options = {
					preferences = {
						includeCompletionsForModuleExports = true,
						includeCompletionsWithInsertText = true,
						-- Отключаем проверку типов в JS файлах
						disableSuggestions = true,
					},
					-- Форсируем использование JSDoc вместо TS проверок
					plugins = {
						{
							name = "typescript-plugin",
							location = vim.fn.stdpath("data")
								.. "/mason/packages/typescript-language-server/node_modules/typescript-plugin",
							enableForJS = true,
							jsDocParsing = true,
							tsChecker = false, -- Выключаем проверщик типов!
						},
					},
				},
				-- Настройки для разных типов файлов
				filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact" },
				settings = {
					completions = {
						completeFunctionCalls = true,
					},
				},
			})
			vim.lsp.enable("ts_ls")
		end,
	},
}
