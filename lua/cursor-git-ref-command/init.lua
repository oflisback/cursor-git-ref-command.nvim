local commands = require("cursor-git-ref-command.commands")
local config = require("cursor-git-ref-command.config")

local M = {}

local configuration = nil

function M.setup(user_config)
	configuration = config.get_final_config(user_config)
	commands.register(configuration)

	return M
end

return M
