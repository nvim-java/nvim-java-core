local log = require('java-core.utils.log')
local java_test_adapter = require('java-core.ls.adapters.test-adapter')

local List = require('java-core.utils.list')
local Promise = require('java-core.utils.promise')
local JavaTestClient = require('java-core.ls.clients.java-test-client')
local JavaDebugClient = require('java-core.ls.clients.java-debug-client')
local JavaDap = require('java-core.dap')

---@class JavaCoreTestHelper
---@field client JavaCoreJdtlsClient
---@field debug_client JavaCoreDebugClient
---@field test_client JavaCoreTestClient
local M = {}

---Returns a new test helper client
---@param args { client: LspClient }
---@return JavaCoreTestHelper
function M:new(args)
	local o = {
		client = args.client,
		debug_client = JavaDebugClient:new({
			client = args.client,
		}),
		test_client = JavaTestClient:new({
			client = args.client,
		}),
	}

	setmetatable(o, self)
	self.__index = self
	return o
end

--@TODO all_tests are not running
--https://github.com/nvim-java/java-core/issues/9
---Running all tests
---@return Promise
function M:__run_all()
	log.info('running all tests')

	return self.test_client
		:find_java_projects()
		:thenCall(
			---@param projects JavaTestFindJavaProjectsResponse
			function(projects)
				local test_pkg_promises = List:new(projects):map(
					---@param project JavaTestDetails
					function(project)
						return self.test_client:find_test_packages_and_types(
							project.jdtHandler
						)
					end
				)

				return Promise.all(test_pkg_promises)
			end
		)
		:thenCall(
			---@param test_pkgs JavaTestFindTestPackagesAndTypesResponse[]
			function(test_pkgs)
				local tests = List:new(test_pkgs)
					:flatten()
					:map(
						---@param test JavaTestDetailsWithChildren
						function(test)
							return test.children
						end
					)
					:flatten()

				return self:run_test(tests)
			end
		)
end

---Returns test classes in the given buffer
---@param buffer integer
---@return Promise
function M:get_test_class_by_buffer(buffer)
	log.info('finding test class by buffer')

	return Promise.resolve()
		:thenCall(function()
			if not vim.api.nvim_buf_is_valid(buffer) then
				local msg = ('passed buffer %s is not valid'):format(buffer)

				log.fmt_error(msg)
				error(msg)
			end

			return vim.uri_from_bufnr(buffer)
		end)
		:thenCall(function(uri)
			return self.test_client:find_test_types_and_methods(uri)
		end)
end

---Run the given test
---@param tests JavaTestFindJavaProjectsResponse
---@param config? JavaTestLauncherConfigOverridable config to override the default values in test launcher config
---@return Promise
function M:run_test(tests, config)
	---@type JavaTestJunitLaunchArguments
	local launch_args

	return self.test_client
		:resolve_junit_launch_arguments(
			java_test_adapter.get_junit_launch_argument_params(tests)
		)
		:thenCall(
			---@param _launch_args JavaTestJunitLaunchArguments
			function(_launch_args)
				launch_args = _launch_args

				return self.debug_client:resolve_java_executable(
					launch_args.mainClass,
					launch_args.projectName
				)
			end
		)
		:thenCall(
			---@param java_exec JavaDebugResolveJavaExecutableResponse
			function(java_exec)
				local dap_launcher_config =
					java_test_adapter.get_dap_launcher_config(launch_args, java_exec, {
						debug = true,
						label = 'Launch All Java Tests',
					})

				log.debug('dap launcher config is: ', dap_launcher_config)

				dap_launcher_config =
					vim.tbl_deep_extend('force', dap_launcher_config, config or {})

				return JavaDap.dap_run(dap_launcher_config)
			end
		)
end

return M
