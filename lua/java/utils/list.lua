---@class List<T>: { [integer]: T }
local M = {}

function M:new(o)
	o = o or {}
	setmetatable(o, self)
	self.__index = self
	return o
end

---Appends a value into to the list
---@generic T
---@param value T
function M:push(value)
	table.insert(self, value)
end

---Finds the matching value in a list
---@generic T
---@generic ListItem: any
---@param finder function
---@return T | nil
function M:find(finder)
	for _, value in ipairs(self) do
		if finder(value) then
			return value
		end
	end

	return nil
end

return M
