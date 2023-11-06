local lsp = require('java.utils.lsp')
local log = require('java.utils.log')

local M = {}

function M.set_runtime() end

---Change jdtls settings
---@param settings InitializationOptions settings to set
---@return boolean
function M.change_settings(settings)
	log.info('changing settings')

	local client = lsp.get_jdtls_client()

	if not client then
		local msg = 'jdtls client not found'
		log.error(msg)
		error(msg)
	end

	return client.notify('workspace/didChangeConfiguration', {
		settings = settings,
	})
end

return M
