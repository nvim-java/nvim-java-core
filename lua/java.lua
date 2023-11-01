local server = require('java.server')
local config = require('java.config')
local settings = require('java.settings')

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
	settings.change_settings({})
end

return M