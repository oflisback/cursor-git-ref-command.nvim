local commands = require("cursor-git-ref-command.commands")

local M = {}

function M.setup()
	commands.register()

	return M
end

return M
