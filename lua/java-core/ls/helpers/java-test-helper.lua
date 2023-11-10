local lsp = require('java-core.utils.lsp')
local log = require('java-core.utils.log')
local java_test_adapter = require('java-core.ls.adapters.test-adapter')

local List = require('java-core.utils.list')
local Promise = require('java-core.utils.promise')
local JavaTestClient = require('java-core.ls.clients.java-test-client')
local JavaDebugClient = require('java-core.ls.clients.java-debug-client')

local M = {}

---Runs a given test
---@param test JavaTestDetails
function M.run_test(test) end

function M.run_current_test_file()
	log.info('running the current test file')

	local jdtls = lsp.get_jdtls_client()

	local test_client = JavaTestClient:new({
		client = jdtls,
	})

	---@type JavaDebugClient
	local debug_client = JavaDebugClient:new({
		client = jdtls,
	})

	local buffer = vim.api.nvim_get_current_buf()
	local uri = vim.uri_from_bufnr(buffer)

	---@type JavaTestDetails
	local test_details
	---@type JavaTestJunitLaunchArguments
	local launch_args

	return test_client
		:find_test_types_and_methods(uri)
		:thenCall(
			---@param test_classes JavaTestFindJavaProjectsResponse
			function(test_classes)
				log.debug('following test classses', test_classes)
				test_details = test_classes[1]

				return test_client:resolve_junit_launch_arguments(
					java_test_adapter.get_junit_launch_argument_params(test_details)
				)
			end
		)
		:thenCall(
			---@param res_launch_args JavaTestJunitLaunchArguments
			function(res_launch_args)
				log.debug('generated launch args ', res_launch_args)

				launch_args = res_launch_args

				return debug_client:resolve_java_executable(
					launch_args.mainClass,
					launch_args.projectName
				)
			end
		)
		:thenCall(
			---@param res_java_exec JavaDebugResolveJavaExecutableResponse
			function(res_java_exec)
				log.debug('resolved java executable', res_java_exec)

				local dap_launcher_config = java_test_adapter.get_dap_launcher_config(
					test_details,
					launch_args,
					res_java_exec,
					{
						debug = true,
					}
				)

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

---Returns all test methods in the current workspace
---@return Promise
function M.get_all_test_methods()
	local java_test_client = M.get_java_test_client()

	return java_test_client
		:find_java_projects()
		:thenCall(
			---@param projects JavaTestFindJavaProjectsResponse
			function(projects)
				projects = List:new(projects)

				local pkg_promises = projects:map(function(project)
					return java_test_client:find_test_packages_and_types(
						project.jdtHandler
					)
				end)

				return Promise.all(pkg_promises)
			end
		)
		:thenCall(
			---@param pkgs JavaTestFindTestPackagesAndTypesResponse[]
			function(pkgs)
				---@type List
				local test_promises = List:new(pkgs)
					:flatten()
					:map(function(pkg)
						return pkg.children
					end)
					:flatten()
					:map(function(pkg)
						return java_test_client:find_test_types_and_methods(pkg.uri)
					end)

				return Promise.all(test_promises)
			end
		)
		:thenCall(function(tests)
			tests = List:new(tests)

			return tests
				:flatten()
				:map(function(test_classes)
					return test_classes.children
				end)
				:flatten()
		end)
end

return M
