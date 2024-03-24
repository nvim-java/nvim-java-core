local log = require('java-core.utils.log')
local class = require('java-core.utils.class')
local async = require('java-core.utils.async')
local await = async.wait_handle_error

---@alias jdtls.RequestMethod
---| 'workspace/executeCommand'
---| 'java/inferSelection'
---| 'java/getRefactorEdit'

---@alias jdtls.CodeActionCommand
---| 'extractVariable'
---| 'assignVariable'
---| 'extractVariableAllOccurrence'
---| 'extractConstant'
---| 'extractMethod'
---| 'extractField'
---| 'extractInterface'
---| 'changeSignature'
---| 'assignField'
---| 'convertVariableToField'
---| 'invertVariable'
---| 'introduceParameter'
---| 'convertAnonymousClassToNestedCommand') {

---@class jdtls.RefactorWorkspaceEdit
---@field edit lsp.WorkspaceEdit
---@field command? lsp.Command
---@field errorMessage? string

---@class jdtls.SelectionInfo
---@field name string
---@field length number
---@field offset number
---@field params? string[]

---@class java-core.JdtlsClient
---@field client LspClient
local JdtlsClient = class()

function JdtlsClient:_init(client)
	self.client = client
end

---@param args? { client: LspClient }
---@return java-core.JdtlsClient
function JdtlsClient:new(args)
	local o = {
		client = (args or {}).client,
	}

	setmetatable(o, self)
	self.__index = self
	return o
end

---Sends a LSP request
---@param method jdtls.RequestMethod
---@param params lsp.ExecuteCommandParams
---@param buffer? number
function JdtlsClient:request(method, params, buffer)
	log.debug('sending LSP request: ' .. method)

	return await(function(callback)
		local on_response = function(err, result)
			if err then
				log.error(method .. ' failed! arguments: ', params, ' error: ', err)
			else
				log.debug(method .. ' success! response: ', result)
			end

			callback(err, result)
		end

		return self.client.request(method, params, on_response, buffer)
	end)
end

---Executes a workspace/executeCommand and returns the result
---@param command string workspace command to execute
---@param params? lsp.LSPAny[]
---@param buffer? integer
---@return lsp.LSPAny
function JdtlsClient:workspace_execute_command(command, params, buffer)
	return self:request('workspace/executeCommand', {
		command = command,
		arguments = params,
	}, buffer)
end

---Returns more information about the object the cursor is on
---@param command jdtls.RequestMethod
---@param params lsp.CodeActionParams
---@param buffer? number
---@return jdtls.SelectionInfo[]
function JdtlsClient:java_infer_selection(command, params, buffer)
	return self:request('java/inferSelection', {
		command = command,
		context = params,
	}, buffer)
end

---Returns refactor details
---@param command jdtls.CodeActionCommand
---@param context lsp.CodeActionParams
---@param options lsp.FormattingOptions
---@param command_arguments jdtls.SelectionInfo[];
---@param buffer? number
---@return jdtls.RefactorWorkspaceEdit
function JdtlsClient:java_get_refactor_edit(
	command,
	context,
	options,
	command_arguments,
	buffer
)
	local params = {
		command = command,
		context = context,
		options = options,
		commandArguments = command_arguments,
	}

	return self:request('java/getRefactorEdit', params, buffer)
end

---Returns the decompiled class file content
---@param uri string uri of the class file
---@return string # decompiled file content
function JdtlsClient:java_decompile(uri)
	---@type string
	return self:workspace_execute_command('java.decompile', { uri })
end

function JdtlsClient:get_capability(...)
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
---@return boolean # true if the command is supported
function JdtlsClient:has_command(command_name)
	local commands = self:get_capability('executeCommandProvider', 'commands')

	if not commands then
		return false
	end

	return vim.tbl_contains(commands, command_name)
end

return JdtlsClient
