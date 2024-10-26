local M = {}

M.register = function()
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
			return
		end

		return commit_hash
	end

	function CherryPick()
		local commit_hash = getCursorHash()

		local cherry_pick_cmd = string.format("git cherry-pick %s", commit_hash)
		local result = vim.fn.system(cherry_pick_cmd)

		if vim.v.shell_error ~= 0 then
			print("Failed to cherry-pick commit:", result)
		else
			print("Cherry-picked commit:", commit_hash)
		end
	end

	function Drop()
		local commit_hash = getCursorHash()

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
		local commit_hash = getCursorHash()

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

	function CheckOut()
		local commit_hash = getCursorHash()

		if not commit_hash or commit_hash == "" then
			print("No valid commit hash provided.")
			return
		end

		local reset_cmd = string.format("git checkout %s", commit_hash)
		local result = vim.fn.system(reset_cmd)

		if vim.v.shell_error ~= 0 then
			print("Failed to checkout commit:", result)
		else
			print("Checked out:", commit_hash)
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
