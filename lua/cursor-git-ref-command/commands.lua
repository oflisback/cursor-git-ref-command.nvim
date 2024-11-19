local M = {}
local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local conf = require("telescope.config").values
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")

M.register = function()
	local function extract_refs(line)
		local refs = {}

		local start_paren = line:find("%(")
		if not start_paren then
			return refs
		end

		local end_paren = line:find("%)", start_paren)
		if not end_paren then
			return refs
		end

		local refs_str = line:sub(start_paren + 1, end_paren - 1)

		for ref in refs_str:gmatch("[^,]+") do
			ref = ref:match("^%s*(.-)%s*$")

			-- If the ref contains " -> ", get the target ref
			local target_ref = ref:match("->%s*(.+)")
			if target_ref then
				ref = target_ref
			end

			if ref ~= "HEAD" and ref ~= "origin/HEAD" then
				table.insert(refs, ref)
			end
		end
		return refs
	end

	local function extract_word(line, start_pos)
		local start = start_pos
		while start > 0 and line:sub(start, start):match("%w") do
			start = start - 1
		end

		local finish = start_pos + 1
		while finish <= #line and line:sub(finish, finish):match("%w") do
			finish = finish + 1
		end

		return line:sub(start + 1, finish - 1), finish
	end

	local function getCursorHash()
		local _, col = unpack(vim.api.nvim_win_get_cursor(0))
		local line = vim.api.nvim_get_current_line()

		local current_word, next_pos = extract_word(line, col)

		local commit_hash = current_word

		if current_word == "commit" then
			local start = next_pos
			while start <= #line and line:sub(start, start):match("%s") do
				start = start + 1
			end
			commit_hash, _ = extract_word(line, start)
		end

		local validate_commit_cmd = string.format("git cat-file -e %s 2>/dev/null", commit_hash)
		local is_valid_commit = vim.fn.system(validate_commit_cmd) == ""

		if not is_valid_commit then
			print("Invalid commit hash or not within a valid git repository: " .. commit_hash)
			return nil, {}
		end

		local refs = extract_refs(line)

		return commit_hash, refs
	end

	function CherryPick()
		local commit_hash, _ = getCursorHash()

		local cherry_pick_cmd = string.format("git cherry-pick %s", commit_hash)
		local result = vim.fn.system(cherry_pick_cmd)

		if vim.v.shell_error ~= 0 then
			print("Failed to cherry-pick commit:", result)
		else
			print("Cherry-picked commit:", commit_hash)
		end
	end

	function Drop()
		local commit_hash, _ = getCursorHash()

		local parent_commit_cmd = string.format("git rev-list --parents -n 1 %s", commit_hash)
		local rev_list_result = vim.fn.system(parent_commit_cmd)

		if vim.v.shell_error ~= 0 then
			print("Failed to get parent commit:", rev_list_result)
			return
		end

		local parent_commit = vim.fn.split(rev_list_result)[2]

		if not parent_commit then
			print("No parent commit found. Likely the first commit.")
			return
		end

		local rebase_onto_cmd = string.format("git rebase --onto %s %s", parent_commit, commit_hash)
		local result = vim.fn.system(rebase_onto_cmd)

		if vim.v.shell_error ~= 0 then
			print("Failed to drop commit:", result)
		else
			print("Dropped commit:", commit_hash)
		end
	end

	GitResetModes = {
		SOFT = "soft",
		HARD = "hard",
		MIXED = "mixed",
	}

	function Reset(mode)
		local commit_hash, _ = getCursorHash()

		if not commit_hash or commit_hash == "" then
			print("No valid commit hash provided.")
			return
		end

		local reset_cmd = string.format("git reset --%s %s", mode, commit_hash)
		local result = vim.fn.system(reset_cmd)

		if vim.v.shell_error ~= 0 then
			print("Failed to reset to commit:", result)
		else
			print(string.format("Reset %s to commit: %s", mode, commit_hash))
		end
	end

	-- This is so close to working. Isn't the commit selected properly? I think it is. Why isn't it checked out
	-- and when done, deduplicate the checkout logic.
	-- and when done with that, also do similar thing for reset functions they should also be able to reset to branches
	function CheckOut()
		local commit_hash, refs = getCursorHash()

		if not commit_hash or commit_hash == "" then
			print("No valid commit hash provided.")
			return
		end

		local selected_ref = nil

		if #refs > 0 then
			-- Create a list of options including the commit hash and all refs
			local options = { commit_hash }
			for _, ref in ipairs(refs) do
				table.insert(options, ref)
			end

			-- Show telescope picker
			local picker = pickers.new({}, {
				prompt_title = "Select ref to checkout",
				finder = finders.new_table({
					results = options,
				}),
				sorter = conf.generic_sorter({}),
				attach_mappings = function(prompt_bufnr)
					actions.select_default:replace(function()
						local selection = action_state.get_selected_entry()
						selected_ref = selection[1]
						print("assigned selected_Ref to: " .. selected_ref)
						actions.close(prompt_bufnr)
					end)
					return true
				end,
			})
			picker:find()
			if selected_ref == nil then
				print("selected_ref is nil")
				return
			end
			print("selected_ref: " .. selected_ref)
			local reset_cmd = string.format("git checkout %s", selected_ref)
			local result = vim.fn.system(reset_cmd)

			if vim.v.shell_error ~= 0 then
				print("Failed to checkout commit:", result)
			else
				print("Checked out:", commit_hash)
			end
		else
			-- deduplicate this
			local reset_cmd = string.format("git checkout %s", commit_hash)
			local result = vim.fn.system(reset_cmd)

			if vim.v.shell_error ~= 0 then
				print("Failed to checkout commit:", result)
			else
				print("Checked out:", commit_hash)
			end
		end
	end
end

vim.cmd("command! CursorCherryPickCommit lua CherryPick()")
vim.cmd("command! CursorCheckOutCommit lua CheckOut()")
vim.cmd("command! CursorDropCommit lua Drop()")
vim.cmd("command! CursorResetCommitSoft lua Reset(GitResetModes.SOFT)")
vim.cmd("command! CursorResetCommitMixed lua Reset(GitResetModes.MIXED)")
vim.cmd("command! CursorResetCommitHard lua Reset(GitResetModes.HARD)")

return M
