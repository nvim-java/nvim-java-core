local M = {}

---Join a given list of paths to one path
---@param ... string paths to join
---@return string # joined path
function M.join(...)
	return table.concat({ ... }, '/')
end

return M
