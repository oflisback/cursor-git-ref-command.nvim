local M = {}
local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local conf = require("telescope.config").values
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")
local extract = require("cursor-git-ref-command.extract")

M.register = function()
	function CherryPick()
		local commit_hash, _ = extract.cursor_hash_and_refs()

		local cherry_pick_cmd = string.format("git cherry-pick %s", commit_hash)
		local result = vim.fn.system(cherry_pick_cmd)

		if vim.v.shell_error ~= 0 then
			print("Failed to cherry-pick commit:", result)
		else
			print("Cherry-picked commit:", commit_hash)
		end
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
		local commit_hash, _ = extract.cursor_hash_and_refs()

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

	local function run_git_command(command, name, target)
		local result = vim.fn.system(command)

		if vim.v.shell_error ~= 0 then
			print(name .. " failed:", result)
		else
			print(name .. " success:", target)
		end
	end

	function CheckOut()
		local commit_hash, refs = extract.cursor_hash_and_refs()

		if not commit_hash or commit_hash == "" then
			print("No valid commit hash or ref found.")
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
						actions.close(prompt_bufnr)

						if selected_ref == nil then
							return
						end

						run_git_command(string.format("git checkout %s", selected_ref), "checkout", selected_ref)
					end)
					return true
				end,
			})
			picker:find()
		else
			run_git_command(string.format("git checkout %s", commit_hash), "checkout", commit_hash)
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
