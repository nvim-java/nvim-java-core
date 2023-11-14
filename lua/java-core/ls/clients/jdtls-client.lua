local log = require('java-core.utils.log')
local Promise = require('java-core.utils.promise')

---@class JavaCoreJdtlsClient
---@field client LSPClient
local M = {}

function M:new(o)
	o = o or {}
	setmetatable(o, self)
	self.__index = self
	return o
end

---Executes a workspace/executeCommand and returns the result
---@param command string
---@param arguments? string | string[]
---@param buffer? integer
---@return Promise
function M:execute_command(command, arguments, buffer)
	return Promise.new(function(resolve, reject)
		local cmd_info = {
			command = command,
			arguments = arguments,
		}

		log.debug('workspace/executeCommand: ', cmd_info)

		self.client.request('workspace/executeCommand', cmd_info, function(err, res)
			if err then
				reject(err)
			else
				resolve(res)
			end
		end, buffer)
	end)
end

function M:get_capability(...)
	local capability = self.client.server_capabilities

	for _, value in ipairs({ ... }) do
		if type(capability) ~= 'table' then
			log.fmt_warn('Looking for capability: %s in value %s', value, capability)
			return nil
		end

		capability = capability[value]
	end

	return capability
end

function M:has_command(command_name)
	local commands = self:get_capability('executeCommandProvider', 'commands')

	if not commands then
		return false
	end

	return vim.tbl_contains(commands, command_name)
end

return M
