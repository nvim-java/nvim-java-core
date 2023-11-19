local log = require('java-core.utils.log')
local Promise = require('java-core.utils.promise')

---@class JavaCoreJdtlsClient
---@field client LspClient
local M = {}

---@param args? { client: LspClient }
---@return JavaCoreJdtlsClient
function M:new(args)
	local o = {
		client = (args or {}).client,
	}

	setmetatable(o, self)
	self.__index = self
	return o
end

---Executes a workspace/executeCommand and returns the result
---@param command string
---@param arguments? string | string[]
---@param buffer? integer
---@return Promise # Promise<any>
function M:execute_command(command, arguments, buffer)
	return Promise.new(function(resolve, reject)
		local cmd_info = {
			command = command,
			arguments = arguments,
		}

		log.debug('executing: workspace/executeCommand - ' .. command)

		self.client.request('workspace/executeCommand', cmd_info, function(err, res)
			if err then
				log.error(command .. ' failed! arguments: ', arguments, ' error: ', err)
				reject(err)
			else
				log.debug(command .. ' success! response: ', res)
				resolve(res)
			end
		end, buffer)
	end)
end

---Returns the decompiled class file content
---@param uri string uri of the class file
---@return Promise # Promise<string> - decompiled file content
function M:java_decompile(uri)
	return self:execute_command('java.decompile', { uri })
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

---Returns true if the LS supports the given command
---@param command_name string name of the command
---@return boolean
function M:has_command(command_name)
	local commands = self:get_capability('executeCommandProvider', 'commands')

	if not commands then
		return false
	end

	return vim.tbl_contains(commands, command_name)
end

return M
