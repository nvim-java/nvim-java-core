local log = require('java-core.utils.log')
local List = require('java-core.utils.list')

local M = {}

---Returns the client by name of the language server
---@param name string name of the language server
---@return LSPClient | nil
function M.find_client_by_name(name)
	local clients = List:new(vim.lsp.get_active_clients())

	return clients:find(function(client)
		return client.name == name
	end)
end

---Returns the jdtls client object
---@return LSPClient
function M.get_jdtls_client()
	local client = M.find_client_by_name('jdtls')

	if not client then
		local msg = 'No active jdtls client found'
		log.error(msg)
		error(msg)
	end

	return client
end

return M
