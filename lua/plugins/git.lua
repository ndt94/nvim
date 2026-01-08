vim.pack.add({
	"https://github.com/lewis6991/gitsigns.nvim",
	-- "https://github.com/sindrets/diffview.nvim",
	"https://github.com/esmuellert/codediff.nvim",
})

-- Setup gitsigns.nvim
require("gitsigns").setup({
	current_line_blame = true,
	signs = {
		add = { text = "▎" },
		change = { text = "▎" },
		delete = { text = "" },
		topdelete = { text = "" },
		changedelete = { text = "▎" },
		untracked = { text = "▎" },
	},
	signs_staged = {
		add = { text = "▎" },
		change = { text = "▎" },
		delete = { text = "" },
		topdelete = { text = "" },
		changedelete = { text = "▎" },
	},
	on_attach = function(buffer)
		local gs = package.loaded.gitsigns

		local function map(mode, lhs, rhs, desc)
			vim.keymap.set(mode, lhs, rhs, { buffer = buffer, desc = desc })
		end

		map("n", "]h", function()
			if vim.wo.diff then
				vim.cmd.normal({ "]c", bang = true })
			else
				gs.nav_hunk("next")
			end
		end, "Next Hunk")

		map("n", "[h", function()
			if vim.wo.diff then
				vim.cmd.normal({ "[c", bang = true })
			else
				gs.nav_hunk("prev")
			end
		end, "Prev Hunk")

		map("n", "]H", function()
			gs.nav_hunk("last")
		end, "Last Hunk")
		map("n", "[H", function()
			gs.nav_hunk("first")
		end, "First Hunk")

		map({ "n", "v" }, "<leader>ghs", ":Gitsigns stage_hunk<CR>", "Stage Hunk")
		map({ "n", "v" }, "<leader>ghr", ":Gitsigns reset_hunk<CR>", "Reset Hunk")

		map("n", "<leader>ghS", gs.stage_buffer, "Stage Buffer")
		map("n", "<leader>ghu", gs.undo_stage_hunk, "Undo Stage Hunk")
		map("n", "<leader>ghR", gs.reset_buffer, "Reset Buffer")
		map("n", "<leader>ghp", gs.preview_hunk_inline, "Preview Hunk Inline")
		map("n", "<leader>ghb", function()
			gs.blame_line({ full = true })
		end, "Blame Line")
		map("n", "<leader>ghB", function()
			gs.blame()
		end, "Blame Buffer")
		map("n", "<leader>ghd", gs.diffthis, "Diff This")
		map("n", "<leader>ghD", function()
			gs.diffthis("~")
		end, "Diff This ~")

		map({ "o", "x" }, "ih", ":<C-U>Gitsigns select_hunk<CR>", "GitSigns Select Hunk")
	end,
})

-- toggles
vim.keymap.set("n", "<leader>uG", function()
	local gs = require("gitsigns")
	local cfg = require("gitsigns.config").config
	local current = cfg.signcolumn
	gs.toggle_signs(not current)
end, { desc = "Toggle Git Signs" })

require("codediff").setup({
	-- Highlight configuration
	highlights = {
		-- Line-level: accepts highlight group names or hex colors (e.g., "#2ea043")
		line_insert = "DiffAdd", -- Line-level insertions
		line_delete = "DiffDelete", -- Line-level deletions

		-- Character-level: accepts highlight group names or hex colors
		-- If specified, these override char_brightness calculation
		char_insert = nil, -- Character-level insertions (nil = auto-derive)
		char_delete = nil, -- Character-level deletions (nil = auto-derive)

		-- Brightness multiplier (only used when char_insert/char_delete are nil)
		-- nil = auto-detect based on background (1.4 for dark, 0.92 for light)
		char_brightness = nil, -- Auto-adjust based on your colorscheme

		-- Conflict sign highlights (for merge conflict views)
		-- Accepts highlight group names or hex colors (e.g., "#f0883e")
		-- nil = use default fallback chain
		conflict_sign = nil, -- Unresolved: DiagnosticSignWarn -> #f0883e
		conflict_sign_resolved = nil, -- Resolved: Comment -> #6e7681
		conflict_sign_accepted = nil, -- Accepted: GitSignsAdd -> DiagnosticSignOk -> #3fb950
		conflict_sign_rejected = nil, -- Rejected: GitSignsDelete -> DiagnosticSignError -> #f85149
	},

	-- Diff view behavior
	diff = {
		disable_inlay_hints = true, -- Disable inlay hints in diff windows for cleaner view
		max_computation_time_ms = 5000, -- Maximum time for diff computation (VSCode default)
		hide_merge_artifacts = false, -- Hide merge tool temp files (*.orig, *.BACKUP.*, *.BASE.*, *.LOCAL.*, *.REMOTE.*)
	},

	-- Explorer panel configuration
	explorer = {
		position = "left", -- "left" or "bottom"
		width = 40, -- Width when position is "left" (columns)
		height = 15, -- Height when position is "bottom" (lines)
		indent_markers = true, -- Show indent markers in tree view (│, ├, └)
		icons = {
			folder_closed = "", -- Nerd Font folder icon (customize as needed)
			folder_open = "", -- Nerd Font folder-open icon
		},
		view_mode = "list", -- "list" or "tree"
		file_filter = {
			ignore = {}, -- Glob patterns to hide (e.g., {"*.lock", "dist/*"})
		},
	},

	-- Keymaps in diff view
	keymaps = {
		view = {
			quit = "q", -- Close diff tab
			toggle_explorer = "<leader>b", -- Toggle explorer visibility (explorer mode only)
			next_hunk = "]c", -- Jump to next change
			prev_hunk = "[c", -- Jump to previous change
			next_file = "]f", -- Next file in explorer mode
			prev_file = "[f", -- Previous file in explorer mode
			diff_get = "do", -- Get change from other buffer (like vimdiff)
			diff_put = "dp", -- Put change to other buffer (like vimdiff)
		},
		explorer = {
			select = "<CR>", -- Open diff for selected file
			hover = "K", -- Show file diff preview
			refresh = "R", -- Refresh git status
			toggle_view_mode = "i", -- Toggle between 'list' and 'tree' views
		},
		conflict = {
			accept_incoming = "<leader>ct", -- Accept incoming (theirs/left) change
			accept_current = "<leader>co", -- Accept current (ours/right) change
			accept_both = "<leader>cb", -- Accept both changes (incoming first)
			discard = "<leader>cx", -- Discard both, keep base
			next_conflict = "]x", -- Jump to next conflict
			prev_conflict = "[x", -- Jump to previous conflict
			diffget_incoming = "2do", -- Get hunk from incoming (left/theirs) buffer
			diffget_current = "3do", -- Get hunk from current (right/ours) buffer
		},
	},
})

-- codediff keymaps (single character mappings)
-- Most common: diff explorer/status (both gv and gd)
vim.keymap.set("n", "<leader>gv", "<cmd>CodeDiff<cr>", { desc = "Diff: View explorer (git status)" })
vim.keymap.set("n", "<leader>gd", "<cmd>CodeDiff<cr>", { desc = "Diff: View explorer (git status)" })

-- Current file vs HEAD (both gV and gD)
vim.keymap.set("n", "<leader>gV", "<cmd>CodeDiff file HEAD<cr>", { desc = "Diff: View current file vs HEAD" })
vim.keymap.set("n", "<leader>gD", "<cmd>CodeDiff file HEAD<cr>", { desc = "Diff: View current file vs HEAD" })

-- Compare with revisions (prompts)
vim.keymap.set("n", "<leader>gc", function()
	vim.ui.input({ prompt = "Compare revision (ex. main, HEAD~5, or 'main HEAD'): " }, function(refs)
		if refs and refs:match("%S") then
			vim.cmd(("CodeDiff %s"):format(refs))
		end
	end)
end, { desc = "Diff: Compare with revision" })

vim.keymap.set("n", "<leader>gC", function()
	vim.ui.input({ prompt = "Compare file with revision (ex. HEAD~1, main): " }, function(rev)
		if rev and rev:match("%S") then
			vim.cmd(("CodeDiff file %s"):format(rev))
		end
	end)
end, { desc = "Diff: Compare file with revision" })

-- Smart compare vs default branch (auto-detects main or master using gitsigns)
vim.keymap.set("n", "<leader>gm", function()
	local gs_status = vim.b.gitsigns_status_dict
	local default_branch = nil
	
	-- Use gitsigns to get git root, then check for default branch
	if gs_status and gs_status.root then
		local git_dir = gs_status.root
		-- Use gitsigns internal git commands (fast, async-capable)
		local gs = require("gitsigns")
		
		-- Try to read .git/refs/remotes/origin/HEAD
		local origin_head = vim.fn.readfile(git_dir .. "/.git/refs/remotes/origin/HEAD", "", 1)
		if #origin_head > 0 then
			default_branch = origin_head[1]:match("ref: refs/remotes/origin/(.+)")
		end
	end
	
	-- Fallback: check which common branch exists
	if not default_branch then
		-- Quick check using vim.fn.filereadable for .git/refs/heads/
		if gs_status and gs_status.root then
			local git_dir = gs_status.root .. "/.git/refs/heads/"
			if vim.fn.filereadable(git_dir .. "main") == 1 then
				default_branch = "main"
			elseif vim.fn.filereadable(git_dir .. "master") == 1 then
				default_branch = "master"
			elseif vim.fn.filereadable(git_dir .. "develop") == 1 then
				default_branch = "develop"
			else
				default_branch = "main" -- final fallback
			end
		else
			default_branch = "main" -- no git repo detected
		end
	end
	
	vim.cmd(("CodeDiff %s"):format(default_branch))
end, { desc = "Diff: vs default branch (auto-detect)" })

-- Compare two arbitrary files
vim.keymap.set("n", "<leader>g2", function()
	vim.ui.input({ prompt = "First file: " }, function(file1)
		if not file1 or not file1:match("%S") then
			return
		end
		vim.ui.input({ prompt = "Second file: " }, function(file2)
			if file2 and file2:match("%S") then
				vim.cmd(("CodeDiff file %s %s"):format(file1, file2))
			end
		end)
	end)
end, { desc = "Diff: Compare 2 files" })
