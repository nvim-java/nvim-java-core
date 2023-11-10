local log = require('java-core.utils.log')
local java_test_adapter = require('java-core.ls.adapters.test-adapter')

local List = require('java-core.utils.list')
local Promise = require('java-core.utils.promise')
local JavaTestClient = require('java-core.ls.clients.java-test-client')
local JavaDebugClient = require('java-core.ls.clients.java-debug-client')

---@class JavaTestHelper
---@field client JDTLSClient
---@field debug_client JavaDebugClient
---@field test_client JavaTestClient
local M = {}

---Returns a new test helper client
---@param args { client: LSPClient }
---@return JavaTestHelper
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

function M:run_current_test_class()
	local buffer = vim.api.nvim_get_current_buf()
	local uri = vim.uri_from_bufnr(buffer)

	log.info('running current class at: ', uri)

	return self.test_client
		:find_test_types_and_methods(uri)
		:thenCall(function(test_classes)
			return self:run_test(test_classes[1])
		end)
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

function M:run_test(tests)
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

				return M.dap_run(dap_launcher_config)
			end
		)
end

function M.dap_run(config)
	log.info('running dap with config: ', config)

	local function get_stream_reader(conn)
		return vim.schedule_wrap(function(err, buffer)
			assert(not err, err)

			if buffer then
				vim.print(buffer)
			else
				conn:close()
			end
		end)
	end

	---@type uv_tcp_t
	local server

	require('dap').run(config, {
		before = function(conf)
			log.debug('running before dap callback')

			server = assert(vim.loop.new_tcp(), 'uv.new_tcp() must return handle')
			server:bind('127.0.0.1', 0)
			server:listen(128, function(err)
				assert(not err, err)

				local sock = assert(vim.loop.new_tcp(), 'uv.new_tcp must return handle')
				server:accept(sock)
				sock:read_start(get_stream_reader(sock))
			end)

			conf.args =
				conf.args:gsub('-port ([0-9]+)', '-port ' .. server:getsockname().port)

			return conf
		end,

		after = function()
			vim.debug('running after dap callback')

			if server then
				server:shutdown()
				server:close()
			end
		end,
	})
end

return M
