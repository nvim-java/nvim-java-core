local log = require('java-core.utils.log')
local data_adapters = require('java-core.adapters')

local Promise = require('java-core.utils.promise')
local TestReport = require('java-core.dap.test-report')
local JavaDapRunner = require('java-core.dap.runner')
local JavaDebug = require('java-core.ls.clients.java-debug-client')
local JavaTest = require('java-core.ls.clients.java-test-client')

---@class JavaCoreTestApi
---@field private client JavaCoreJdtlsClient
---@field private debug_client JavaCoreDebugClient
---@field private test_client JavaCoreTestClient
---@field private runner JavaCoreDapRunner
local M = {}

---Returns a new test helper client
---@param args { client: LspClient }
---@return JavaCoreTestApi
function M:new(args)
	local o = {
		client = args.client,
	}

	o.debug_client = JavaDebug:new({
		client = args.client,
	})

	o.test_client = JavaTest:new({
		client = args.client,
	})

	o.runner = JavaDapRunner:new({
		reporter = TestReport:new(),
	})

	setmetatable(o, self)
	self.__index = self

	return o
end

---Runs the test class in the given buffer
---@param buffer integer
---@param config JavaCoreDapLauncherConfigOverridable
---@return Promise
function M:run_class_by_buffer(buffer, config)
	return self:get_test_class_by_buffer(buffer):thenCall(function(tests)
		return self:run_test(tests, config)
	end)
end

---Returns test classes in the given buffer
---@priate
---@param buffer integer
---@return Promise # Promise<JavaCoreTestDetailsWithChildrenAndRange>
function M:get_test_class_by_buffer(buffer)
	log.debug('finding test class by buffer')

	return Promise.resolve():thenCall(function()
		if not vim.api.nvim_buf_is_valid(buffer) then
			local msg = 'passed buffer' .. tostring(buffer) .. ' is not valid'
			log.error(msg)
			error(msg)
		end

		local uri = vim.uri_from_bufnr(buffer)
		return self.test_client:find_test_types_and_methods(uri)
	end)
end

---Run the given test
---@private
---@param tests JavaCoreTestDetails[]
---@param config? JavaCoreDapLauncherConfigOverridable config to override the default values in test launcher config
---@return Promise #
function M:run_test(tests, config)
	---@type JavaCoreTestJunitLaunchArguments
	local launch_args

	return self.test_client
		:resolve_junit_launch_arguments(
			data_adapters.get_junit_launch_argument_params(tests)
		)
		:thenCall(
			---@param _launch_args JavaCoreTestJunitLaunchArguments
			function(_launch_args)
				launch_args = _launch_args

				return self.debug_client:resolve_java_executable(
					launch_args.mainClass,
					launch_args.projectName
				)
			end
		)
		:thenCall(
			---@param java_exec string
			function(java_exec)
				local dap_launcher_config =
					--@TODO I don't know why the hell debug is hard coded here
					data_adapters.get_dap_launcher_config(launch_args, java_exec, {
						debug = true,
						label = 'Launch All Java Tests',
					})

				log.debug('dap launcher config is: ', dap_launcher_config)

				dap_launcher_config =
					vim.tbl_deep_extend('force', dap_launcher_config, config or {})

				return self.runner:run_by_config(dap_launcher_config)
			end
		)
end

return M
