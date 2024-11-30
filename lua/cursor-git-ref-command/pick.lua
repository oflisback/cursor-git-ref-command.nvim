local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local conf = require("telescope.config").values
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")

local pick = {}

function pick.sha_or_ref(commit_hash, refs, callback)
	if #refs > 0 then
		local options = { commit_hash }
		for _, ref in ipairs(refs) do
			table.insert(options, ref)
		end

		local picker = pickers.new({}, {
			prompt_title = "Select ref to checkout",
			finder = finders.new_table({
				results = options,
			}),
			sorter = conf.generic_sorter({}),
			attach_mappings = function(prompt_bufnr)
				actions.select_default:replace(function()
					local selection = action_state.get_selected_entry()
					actions.close(prompt_bufnr)
					callback(selection[1])
				end)
				return true
			end,
		})
		picker:find()
	else
		callback(commit_hash)
	end
end

return pick
