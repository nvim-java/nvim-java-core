---@class List
local M = {}

---Returns a new list
---@param o? table
---@return List
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
	local mapped = M:new()

	for i, v in ipairs(self) do
		mapped:push(mapper(v))
	end

	return mapped
end

---Flatten a list
---@return List
function M:flatten()
	local flatten = M:new()

	for _, v1 in ipairs(self) do
		for _, v2 in ipairs(v1) do
			flatten:push(v2)
		end
	end

	return flatten
end

---Merge a given list values to current list
---@param list any[]
---@return List
function M:concat(list)
	local new_list = M:new()

	for _, v in ipairs(self) do
		new_list:push(v)
	end

	for _, v in ipairs(list) do
		new_list:push(v)
	end

	return new_list
end

function M:includes(value)
	for _, v in ipairs(self) do
		if v == value then
			return true
		end
	end

	return false
end

---Join list items to a string
---@param separator string
---@return string
function M:join(separator)
	return table.concat(self, separator)
end

return M
