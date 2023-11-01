local List = require('java.utils.list')

local M = {}

---Returns the client by name of the language server
---@param name string name of the language server
---@return object | nil
function M.get_client_by_name(name)
	local clients = List:new(vim.lsp.get_active_clients())

	return clients:find(function(client)
		return client.name == name
	end)
end

---Returns the jdtls client object
---@return LSPClient | nil
function M.get_jdtls_client()
	return M.get_client_by_name('jdtls')
end

return M
