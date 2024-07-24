local M = {}

---@return vim.lsp.Client
function M.get_client()
	local clients = vim.lsp.get_clients({ name = 'jdtls' })

	if #clients < 1 then
		local message = 'No jdtls client found!'
		require('java-core.utils.notify').error(message)
		require('java.utils.log').error(message)
		error(message)
	end

	return clients[1]
end

function M.get_jdtls()
	local JdtlsClient = require('java-core.ls.clients.jdtls-client')
	return JdtlsClient(M.get_client())
end

function M.get_debug()
	local DebugClient = require('java-core.ls.clients.java-debug-client')
	return DebugClient(M.get_client())
end

function M.get_test()
	local TestClient = require('java-core.ls.clients.java-test-client')
	return TestClient(M.get_client())
end

return M
