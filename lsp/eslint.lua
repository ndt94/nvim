local util = require("utils.lsp")
local lsp = vim.lsp

return {
	cmd = { "vscode-eslint-language-server", "--stdio" },
	filetypes = {
		"javascript",
		"javascriptreact",
		"javascript.jsx",
		"typescript",
		"typescriptreact",
		"typescript.tsx",
		"vue",
		"svelte",
		"astro",
		"htmlangular",
	},
	workspace_required = true,
	on_attach = function(client, bufnr)
		vim.api.nvim_buf_create_user_command(bufnr, "LspEslintFixAll", function()
			client:request_sync("workspace/executeCommand", {
				command = "eslint.applyAllFixes",
				arguments = {
					{
						uri = vim.uri_from_bufnr(bufnr),
						version = lsp.util.buf_versions[bufnr],
					},
				},
			}, nil, bufnr)
		end, {})
	end,
	root_dir = function(bufnr, on_dir)
		local fname = vim.api.nvim_buf_get_name(bufnr)

		local workspace_root_patterns = {
			".git",
			"pnpm-workspace.yaml",
			"turbo.json",
			"rush.json",
			"lerna.json",
			"nx.json",
			"package.json",
		}

		local workspace_root = vim.fs.dirname(vim.fs.find(workspace_root_patterns, { path = fname, upward = true })[1])

		if not workspace_root then
			workspace_root = vim.fn.getcwd()
		end

		on_dir(workspace_root)
	end,
	settings = {
		validate = "on",
		packageManager = nil,
		useESLintClass = false,
		experimental = {
			useFlatConfig = false,
		},
		codeActionOnSave = {
			enable = false,
			mode = "all",
		},
		format = true,
		quiet = false,
		onIgnoredFiles = "off",
		rulesCustomizations = {},
		run = "onType",
		problems = {
			shortenToSingleLine = false,
		},
		nodePath = "",
		codeAction = {
			disableRuleComment = {
				enable = true,
				location = "separateLine",
			},
			showDocumentation = {
				enable = true,
			},
		},
	},
	before_init = function(_, config)
		local root_dir = config.root_dir

		if root_dir then
			config.settings = config.settings or {}
			config.settings.workspaceFolder = {
				uri = root_dir,
				name = vim.fn.fnamemodify(root_dir, ":t"),
			}

			-- Find the nearest ESLint config from the current file
			local fname = vim.api.nvim_buf_get_name(0)
			local eslint_config_patterns = {
				".eslintrc",
				".eslintrc.js",
				".eslintrc.cjs",
				".eslintrc.yaml",
				".eslintrc.yml",
				".eslintrc.json",
				"eslint.config.js",
				"eslint.config.mjs",
				"eslint.config.cjs",
				"eslint.config.ts",
				"eslint.config.mts",
				"eslint.config.cts",
			}

			-- Add package.json with eslintConfig to patterns
			eslint_config_patterns = util.insert_package_json(eslint_config_patterns, "eslintConfig", fname)

			local nearest_config = vim.fs.find(eslint_config_patterns, { path = fname, upward = true })[1]
			local config_dir = nearest_config and vim.fs.dirname(nearest_config) or root_dir

			-- Set working directory to where the ESLint config is found
			-- This is crucial for monorepos where config might be in a subdirectory
			config.settings.workingDirectory = {
				mode = "location",
				location = config_dir,
			}

			-- Support flat config
			local flat_config_files = {
				"eslint.config.js",
				"eslint.config.mjs",
				"eslint.config.cjs",
				"eslint.config.ts",
				"eslint.config.mts",
				"eslint.config.cts",
			}

			for _, file in ipairs(flat_config_files) do
				if vim.fn.filereadable(config_dir .. "/" .. file) == 1 then
					config.settings.experimental = config.settings.experimental or {}
					config.settings.experimental.useFlatConfig = true
					break
				end
			end
		end
	end,
	handlers = {
		["eslint/openDoc"] = function(_, result)
			if result then
				vim.ui.open(result.url)
			end
			return {}
		end,
		["eslint/confirmESLintExecution"] = function(_, result)
			if not result then
				return
			end
			return 4 -- approved
		end,
		["eslint/probeFailed"] = function()
			vim.notify("[lspconfig] ESLint probe failed.", vim.log.levels.WARN)
			return {}
		end,
	},
}
