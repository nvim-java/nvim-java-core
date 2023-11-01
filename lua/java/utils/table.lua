local M = {}

---Inserts a list of values to a given table
---@param tbl List[]
---@param ... any list of values to insert
---@return any
function M.insert(tbl, ...)
	for _, value in ipairs({ ... }) do
		table.insert(tbl, value)
	end

	return tbl
end

return M
