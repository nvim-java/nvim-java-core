local server = require('java-core.server')
local config = require('java-core.config')
local lsp = require('java-core.utils.lsp')

---@class Java
---@field config JavaConfig
local M = {}

---Setup the plugin
---@param args JavaConfig
M.setup = function(args)
	config = vim.tbl_deep_extend('force', config, args or {})
end

---Returns the jdtls config
---@param root_markers? string[] list of files to find the root dir of a project
---@return LSPSetupConfig
function M.get_config(root_markers)
	return server.get_config({
		root_markers = root_markers or config.root_markers,
	})
end

M.__run = function()
	print('>>>>>')
end

return M
