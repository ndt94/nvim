-- pnpm add -g oxlint

local OXLINT_CONFIG = { ".oxlintrc.json", "oxlintrc.json" }

return {
	cmd = { "oxc_language_server" },
	filetypes = {
		"javascript",
		"javascriptreact",
		"javascript.jsx",
		"typescript",
		"typescriptreact",
		"typescript.tsx",
	},
	workspace_required = true,
	root_dir = function(bufnr, on_dir)
		local fname = vim.api.nvim_buf_get_name(bufnr)
		on_dir(vim.fs.dirname(vim.fs.find(OXLINT_CONFIG, { path = fname, upward = true })[1]))
	end,
}
