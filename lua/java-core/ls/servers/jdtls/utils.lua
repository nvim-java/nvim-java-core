local util = require('lspconfig.util')

local join = util.path.join

local M = {}

---Returns the workspace directory path based on the current dir
---@return string
function M.get_workspace_path()
	local project_path = vim.fn.fnamemodify(vim.fn.getcwd(), ':p:h')
	local project_path_hash = string.gsub(project_path, '[/\\:+-]', '_')

	local nvim_cache_path = vim.fn.stdpath('cache')
	return join(nvim_cache_path, 'jdtls', 'workspaces', project_path_hash)
end

---Returns the jdtls config cache directory
---@return string
function M.get_jdtls_config_path()
	return join(vim.fn.stdpath('cache'), 'jdtls', 'config')
end

return M
