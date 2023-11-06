local log = require('java.utils.log')
local lsp = require('java.utils.lsp')
local JavaDebug = require('java.ls.clients.java-debug-client')
local Promise = require('java.utils.promise')

local M = {}

function M.setup_dap_on_attach()
	vim.api.nvim_create_autocmd('LspAttach', {
		pattern = '*',
		callback = function(a)
			local client = vim.lsp.get_client_by_id(a.data.client_id)

			if client.name == 'jdtls' then
				Promise.all({
					M.set_dap_config(),
					M.set_dap_adapter(),
				}):catch(function(err)
					local msg = [[Faild to set DAP configuration & adapter]]

					error(msg, err)
					log.error(msg, err)
				end)
			end
		end,
	})
end

function M.set_dap_config()
	log.info('setting dap configurations for java')

	local dap = require('dap')

	return M.get_dap_config():thenCall(
		---@type JavaDapConfigurationList
		function(res)
			dap.configurations.java = res
		end
	)
end

function M.set_dap_adapter()
	log.info('setting dap adapter for java')

	local dap = require('dap')

	return M.get_dap_adapter():thenCall(
		---@type JavaDapAdapter
		function(res)
			log.debug('adapter settings: ', res)
			dap.adapters.java = res
		end
	)
end

---@class JavaDapAdapter
---@field type string
---@field host string
---@field port integer

---Returns the dap adapter config
---@return Promise
function M.get_dap_adapter()
	log.info('creating dap adapter for java')

	local client = lsp.get_jdtls_client()

	--@TODO when thrown from the function instead of the promise,
	--error handling has to be done in two places
	if not client then
		local msg = 'no active jdtls client was found'

		log.error(msg)
		error(msg)
	end

	local jdtlsClient = JavaDebug:new({
		client = client,
	})

	return jdtlsClient:start_debug_session():thenCall(
		---@param port JavaDebugStartDebugSessionResponse
		function(port)
			return {
				type = 'server',
				host = '127.0.0.1',
				port = port,
			}
		end
	)
end

---@class JavaDapConfiguration
---@field name string
---@field projectName string
---@field mainClass string
---@field javaExec string
---@field modulePaths string[]
---@field classPaths string[]
---@field request string

---@alias JavaDapConfigurationList JavaDapConfiguration[]

---Returns the dap configuration for the current project
---@return Promise
function M.get_dap_config()
	log.info('creating dap configuration for java')

	local client = lsp.get_jdtls_client()

	if not client then
		local msg = 'no active jdtls client was found'

		log.error(msg)
		error(msg)
	end

	local jdtlsClient = JavaDebug:new({
		client = client,
	})

	---@type JavaDebugResolveMainClassResponse
	local main_classes_info_list

	return jdtlsClient
		:resolve_main_class()
		:thenCall(
			---@param main_classes_info JavaDebugResolveMainClassResponse
			function(main_classes_info)
				main_classes_info_list = main_classes_info

				---@type Promise[]
				local classpath_promises = {}
				---@type Promise[]
				local java_exec_promises = {}

				for _, single_class_info in ipairs(main_classes_info) do
					table.insert(
						classpath_promises,
						jdtlsClient:resolve_classpath(
							single_class_info.mainClass,
							single_class_info.projectName
						)
					)

					table.insert(
						java_exec_promises,
						jdtlsClient:resolve_java_executable(
							single_class_info.mainClass,
							single_class_info.projectName
						)
					)
				end

				return Promise.all({
					Promise.all(classpath_promises),
					Promise.all(java_exec_promises),
				})
			end
		)
		:thenCall(function(result)
			return M.__get_dap_java_config(
				main_classes_info_list,
				result[1],
				result[2]
			)
		end)
end

function M.__get_dap_java_config(main_classes, classpaths, java_execs)
	local len = #main_classes
	local dap_config_list = {}

	for i = 1, len do
		local main_class = main_classes[i].mainClass
		local project_name = main_classes[i].projectName
		local module_paths = classpaths[i][1]
		local class_paths = classpaths[i][2]

		table.insert(dap_config_list, {
			name = string.format('%s -> %s', project_name, main_class),
			projectName = project_name,
			mainClass = main_class,
			javaExec = java_execs[i],
			request = 'launch',
			type = 'java',
			modulePaths = module_paths,
			classPaths = class_paths,
		})
	end

	return dap_config_list
end

return M
