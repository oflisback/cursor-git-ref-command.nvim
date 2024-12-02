local M = {}

M.get_final_config = function(user_config)
	local default_config = {}
	return vim.tbl_extend("keep", user_config or {}, default_config)
end

return M
