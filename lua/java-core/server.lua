local util = require('lspconfig.util')
local system = require('java-core.utils.system')
local file = require('java-core.utils.file')
local mason = require('java-core.utils.mason')
local plugin = require('java-core.utils.plugin')
local log = require('java-core.utils.log')
local tbl = require('java-core.utils.table')
local workspace = require('java-core.workspace')

local M = {}

---@class JDTLSPluginPathRecord
---@field name string
---@field path string

---@alias JDTLSPluginPaths JDTLSPluginPathRecord[]
M.plugins = {
	{ name = 'java-test', path = '/*.jar' },
	{ name = 'java-debug-adapter', path = '/*.jar' },
}

---@class JavaGetConfigOptions
---@field root_markers string[] list of files to find the root dir of a project
---Ex:- { 'pom.xml', 'build.gradle', '.git' }

---Returns a configuration for jdtls that you can pass into the setup of nvim-lspconfig
---@param opts JavaGetConfigOptions
---@return LSPSetupConfig # jdtls setup configuration
function M.get_config(opts)
	log.info('generating jdtls config')

	local jdtls_path = mason.get_pkg_path('jdtls')
	local curr_os = system.get_os()
	local plugins = plugin.get_plugins(M.plugins)
	local lombok_path = jdtls_path .. '/lombok.jar'

	local cmd = {
		'java',
		'-Declipse.application=org.eclipse.jdt.ls.core.id1',
		'-Dosgi.bundles.defaultStartLevel=4',
		'-Declipse.product=org.eclipse.jdt.ls.core.product',
		'-Dlog.protocol=true',
		'-Dlog.level=ALL',
		'-Xms1g',
		'--add-modules=ALL-SYSTEM',
		'--add-opens',
		'java.base/java.util=ALL-UNNAMED',
		'--add-opens',
		'java.base/java.lang=ALL-UNNAMED',
		'-jar',
		vim.fn.glob(jdtls_path .. '/plugins/org.eclipse.equinox.launcher_*.jar'),
		'-configuration',
		jdtls_path .. '/config_' .. curr_os,
		'-data',
		workspace.get_default_workspace(),
	}

	if file.is_file(lombok_path) then
		tbl.insert(cmd, '-javaagent:' .. lombok_path)
	end

	local conf = {
		cmd = cmd,
		init_options = {
			bundles = plugins,
			workspace = workspace.get_default_workspace(),
			extendedClientCapabilities = {
				classFileContentsSupport = true,
				generateToStringPromptSupport = true,
				hashCodeEqualsPromptSupport = true,
				advancedExtractRefactoringSupport = true,
				advancedOrganizeImportsSupport = true,
				generateConstructorsPromptSupport = true,
				generateDelegateMethodsPromptSupport = true,
				moveRefactoringSupport = true,
				overrideMethodsPromptSupport = true,
				executeClientCommandSupport = true,
				inferSelectionSupport = {
					'extractMethod',
					'extractVariable',
					'extractConstant',
					'extractVariableAllOccurrence',
				},
			},
		},

		root_dir = M.get_root_finder(opts.root_markers),
		capabilities = vim.lsp.protocol.make_client_capabilities(),
	}

	log.debug('generated config: ', conf)

	return conf
end

---Returns a function that finds the java project root
---@private
---@param root_markers string[] list of files to find the root dir of a project
---@return function
function M.get_root_finder(root_markers)
	return function(file_name)
		log.info('finding the root_dir')
		log.debug('root_markers: ', root_markers)

		local root = util.root_pattern(unpack(root_markers))(file_name)

		if root then
			log.fmt_debug('root of: %s is: %s', file_name, root)
			return root
		end
	end
end

return M
