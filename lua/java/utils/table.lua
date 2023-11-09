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

---Flatten a table
---@param tbl table
---@return table
function M.flatten(tbl)
	local flatten_tbl = {}

	for _, v1 in ipairs(tbl) do
		for _, v2 in ipairs(v1) do
			table.insert(flatten_tbl, v2)
		end
	end

	return flatten_tbl
end

---Map a given table
---@param tbl table
---@param mapper fun(value: any): any
---@return table
function M.map(tbl, mapper)
	local mapped = {}

	for _, v in ipairs(tbl) do
		table.insert(mapped, mapper(v))
	end

	return mapped
end

return M
