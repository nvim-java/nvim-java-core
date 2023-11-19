local util = require('lspconfig.util')
local path = require('java-core.utils.path')
local mason = require('java-core.utils.mason')
local plugins = require('java-core.ls.servers.jdtls.plugins')
local log = require('java-core.utils.log')
local workspace = require('java-core.ls.servers.jdtls.workspace')
local config = require('java-core.ls.servers.jdtls.config')

local M = {}

---@class JavaCoreGetConfigOptions
---@field root_markers string[] list of files to find the root dir of a project
---Ex:- { 'pom.xml', 'build.gradle', '.git' }
---@field jdtls_plugins string[] list of jdtls plugins to load on start up
---Ex:- { 'java-test', 'java-debug-adapter' }

---Returns a configuration for jdtls that you can pass into the setup of nvim-lspconfig
---@param opts JavaCoreGetConfigOptions
---@return LspSetupConfig # jdtls setup configuration
function M.get_config(opts)
	log.debug('generating jdtls config')

	local jdtls_path = mason.get_pkg_path('jdtls')
	local lombok_path = path.join(jdtls_path, 'lombok.jar')
	local jdtls_cache_path = path.join(vim.fn.stdpath('cache'), 'jdtls')
	local plugin_paths = plugins.get_plugin_paths(opts.jdtls_plugins)

	local base_config = config.get_config()

	base_config.cmd = {
		'jdtls',
		'-configuration',
		jdtls_cache_path,
		'-data',
		workspace.get_default_workspace(),
		'-javaagent:' .. lombok_path,
	}

	base_config.root_dir = M.get_root_finder(opts.root_markers)
	base_config.init_options.bundles = plugin_paths
	base_config.init_options.workspace = workspace.get_default_workspace()

	log.debug('generated jdtls setup config: ', base_config)

	return base_config
end

---Returns a function that finds the java project root
---@private
---@param root_markers string[] list of files to find the root dir of a project
---@return fun(file_name: string): string | nil
function M.get_root_finder(root_markers)
	return function(file_name)
		log.debug('finding the root_dir with root_markers ', root_markers)

		local root = util.root_pattern(unpack(root_markers))(file_name)

		if root then
			log.debug('root of ' .. file_name .. ' is ' .. root)
			return root
		end
	end
end

return M
