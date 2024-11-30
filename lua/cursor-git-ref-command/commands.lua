local M = {}
local extract = require("cursor-git-ref-command.extract")
local pick = require("cursor-git-ref-command.pick")

M.register = function()
	local function run_git_command(command, name)
		local result = vim.fn.system(command)

		if vim.v.shell_error ~= 0 then
			print(name .. " failed:", result)
		end
	end

	function CherryPick()
		local commit_hash, _ = extract.cursor_hash_and_refs()

		run_git_command(string.format("git cherry-pick %s", commit_hash), "cherry-pick")
	end

	function Drop()
		local commit_hash, _ = extract.cursor_hash_and_refs()

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

		run_git_command(string.format("git rebase --onto %s %s", parent_commit, commit_hash), "drop")
	end

	GitResetModes = {
		SOFT = "soft",
		HARD = "hard",
		MIXED = "mixed",
	}

	function Reset(mode)
		local commit_hash, refs = extract.cursor_hash_and_refs()

		if not commit_hash or commit_hash == "" then
			print("No valid commit hash provided.")
			return
		end

		pick.sha_or_ref(commit_hash, refs, function(sha_or_ref)
			run_git_command(string.format("git reset --%s %s", mode, sha_or_ref), "reset")
		end)
	end

	function CheckOut()
		local commit_hash, refs = extract.cursor_hash_and_refs()

		if not commit_hash or commit_hash == "" then
			print("No valid commit hash or ref found.")
			return
		end
		pick.sha_or_ref(commit_hash, refs, function(sha_or_ref)
			run_git_command(string.format("git checkout %s", sha_or_ref), "checkout")
		end)
	end
end

vim.cmd("command! CursorCherryPickCommit lua CherryPick()")
vim.cmd("command! CursorCheckOutCommit lua CheckOut()")
vim.cmd("command! CursorDropCommit lua Drop()")
vim.cmd("command! CursorResetCommitSoft lua Reset(GitResetModes.SOFT)")
vim.cmd("command! CursorResetCommitMixed lua Reset(GitResetModes.MIXED)")
vim.cmd("command! CursorResetCommitHard lua Reset(GitResetModes.HARD)")

return M
