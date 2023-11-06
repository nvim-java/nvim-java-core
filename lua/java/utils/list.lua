---@class List
local M = {}

function M:new(o)
	o = o or {}
	setmetatable(o, self)
	self.__index = self
	return o
end

---Appends a value into to the list
---@param value any
function M:push(value)
	table.insert(self, value)
end

---Finds the matching value in a list
---@param finder fun(value: any): boolean
---@return any
function M:find(finder)
	for _, value in ipairs(self) do
		if finder(value) then
			return value
		end
	end

	return nil
end

---Returns a list of mapped values
---@param mapper fun(value: any): any
---@return List
function M:map(mapper)
	local mapped_list = M:new()

	for _, value in ipairs(self) do
		mapped_list:push(mapper(value))
	end

	return mapped_list
end

return M
