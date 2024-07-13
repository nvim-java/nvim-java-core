local config = require('java-core.ls.servers.jdtls.config')
local log = require('java-core.utils.log')
local mason = require('java-core.utils.mason')
local mason_reg = require('mason-registry')
local path = require('java-core.utils.path')
local plugins = require('java-core.ls.servers.jdtls.plugins')
local util = require('lspconfig.util')
local utils = require('java-core.ls.servers.jdtls.utils')

local M = {}

---@class JavaCoreGetConfigOptions
---@field root_markers string[] list of files to find the root dir of a project
---Ex:- { 'pom.xml', 'build.gradle', '.git' }
---@field jdtls_plugins string[] list of jdtls plugins to load on start up
---Ex:- { 'java-test', 'java-debug-adapter' }
---@field use_mason_jdk boolean whether to use mason jdk to load jdtls or not

---Returns a configuration for jdtls that you can pass into the setup of nvim-lspconfig
---@param opts JavaCoreGetConfigOptions
---@return vim.lsp.ClientConfig
function M.get_config(opts)
	log.debug('generating jdtls config')

	-- this is the configuration found in the jdtls package. Here, I don't have to
	-- pick the OS at runtime because mason.nvim does that for me at the
	-- installation
	local jdtls_root = mason.get_shared_path('jdtls')
	local lombok_root = mason.get_shared_path('lombok-nightly')

	local jdtls_config = path.join(jdtls_root, 'config')
	local lombok_path = path.join(lombok_root, 'lombok.jar')
	local equinox_launcher =
		path.join(jdtls_root, 'plugins', 'org.eclipse.equinox.launcher.jar')
	local plugin_paths = plugins.get_plugin_paths(opts.jdtls_plugins)
	local base_config = config.get_config()

	base_config.cmd = {
		'java',
		'-Declipse.application=org.eclipse.jdt.ls.core.id1',
		'-Dosgi.bundles.defaultStartLevel=4',
		'-Declipse.product=org.eclipse.jdt.ls.core.product',
		'-Dosgi.checkConfiguration=true',
		'-Dosgi.sharedConfiguration.area=' .. jdtls_config,
		'-Dosgi.sharedConfiguration.area.readOnly=true',
		'-Dosgi.configuration.cascaded=true',
		'-Xms1G',
		'--add-modules=ALL-SYSTEM',

		'--add-opens',
		'java.base/java.util=ALL-UNNAMED',

		'--add-opens',
		'java.base/java.lang=ALL-UNNAMED',

		'-javaagent:' .. lombok_path,

		'-jar',
		equinox_launcher,

		'-configuration',
		utils.get_jdtls_config_path(),

		'-data',
		utils.get_workspace_path(),
	}

	if opts.use_mason_jdk then
		local jdk = mason_reg.get_package('openjdk-17')

		if jdk:is_installed() then
			local java_home =
				vim.fn.glob(path.join(jdk:get_install_path(), '/jdk-17*'))
			local java_bin = path.join(java_home, '/bin')

			base_config.cmd_env = {
				['PATH'] = vim.fn.getenv('PATH') .. ':' .. java_bin,
				['JAVA_HOME'] = java_home,
			}
		end
	end

	---@diagnostic disable-next-line: assign-type-mismatch
	base_config.root_dir = M.get_root_finder(opts.root_markers)
	base_config.init_options.bundles = plugin_paths
	base_config.init_options.workspace = utils.get_workspace_path()

	log.debug('generated jdtls setup config: ', base_config)

	return base_config
end

---Returns a function that finds the java project root
---@private
---@param root_markers string[] list of files to find the root dir of a project
---@return fun(file_name: string): string
function M.get_root_finder(root_markers)
	return function(file_name)
		log.debug('finding the root_dir with root_markers ', root_markers)

		local root = util.root_pattern(unpack(root_markers))(file_name)
		-- vim.fs.root

		if root then
			log.debug('root of ' .. file_name .. ' is ' .. root)
			return root
		else
			local fallback_dir = vim.fn.getcwd()
			log.debug(
				"couldn't find root of "
					.. file_name
					.. ' using fallback dir '
					.. fallback_dir
			)
			return fallback_dir
		end
	end
end

return M
