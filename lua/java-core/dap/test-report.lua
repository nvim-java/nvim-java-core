local log = require('java-core.utils.log')

---@class JavaCoreDapTestReport: JavaCoreDapRunReport
---@field private conn uv_tcp_t
local M = {}

function M:new()
	local o = {}
	setmetatable(o, self)
	self.__index = self
	return o
end

---Returns a stream reader function
---@param conn uv_tcp_t
---@return fun(err: string, buffer: string)
function M:get_stream_reader(conn)
	self.conn = conn

	return vim.schedule_wrap(function(err, buffer)
		if err then
			self:on_error(err)
			self:on_close()

			self.conn:close()
			return
		end

		if buffer then
			self:on_update(buffer)
		else
			self:on_close()
			self.conn:close()
		end
	end)
end

function M:on_update(buffer)
	vim.print(buffer)
end

function M:on_close()
	vim.print('closing')
end

function M:on_error(err)
	log.error('Error while running test', err)
end

return M
