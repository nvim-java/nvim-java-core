local log = require('java-core.utils.log')
local data_adapters = require('java-core.adapters')

local DebugClient = require('java-core.ls.clients.java-debug-client')
local TestClient = require('java-core.ls.clients.java-test-client')

---@class java_core.TestApi
---@field private client java-core.JdtlsClient
---@field private debug_client java-core.DebugClient
---@field private test_client java-core.TestClient
---@field private runner java-dap.DapRunner
local M = {}

---Returns a new test helper client
---@param args { client: LspClient, runner: java-dap.DapRunner }
---@return java_core.TestApi
function M:new(args)
	local o = {
		client = args.client,
	}

	o.debug_client = DebugClient(args.client)
	o.test_client = TestClient(args.client)
	o.runner = args.runner

	setmetatable(o, self)
	self.__index = self

	return o
end

---Returns a list of test methods
---@param file_uri string uri of the class
---@return java-core.TestDetailsWithRange[] # list of test methods
function M:get_test_methods(file_uri)
	local classes = self.test_client:find_test_types_and_methods(file_uri)
	local methods = {}

	for _, class in ipairs(classes) do
		for _, method in ipairs(class.children) do
			---@diagnostic disable-next-line: inject-field
			method.class = class
			table.insert(methods, method)
		end
	end

	return methods
end

---comment
---@param buffer number
---@param report java_test.JUnitTestReport
---@param config? java-dap.DapLauncherConfigOverridable config to override the default values in test launcher config
function M:run_class_by_buffer(buffer, report, config)
	local tests = self:get_test_class_by_buffer(buffer)
	self:run_test(tests, report, config)
end

---Returns test classes in the given buffer
---@priate
---@param buffer integer
---@return java-core.TestDetailsWithChildrenAndRange # get test class details
function M:get_test_class_by_buffer(buffer)
	log.debug('finding test class by buffer')

	local uri = vim.uri_from_bufnr(buffer)
	return self.test_client:find_test_types_and_methods(uri)
end

---Run the given test
---@param tests java-core.TestDetails[]
---@param report java_test.JUnitTestReport
---@param config? java-dap.DapLauncherConfigOverridable config to override the default values in test launcher config
function M:run_test(tests, report, config)
	local launch_args = self.test_client:resolve_junit_launch_arguments(
		data_adapters.get_junit_launch_argument_params(tests)
	)

	local java_exec = self.debug_client:resolve_java_executable(
		launch_args.mainClass,
		launch_args.projectName
	)

	local dap_launcher_config =
		data_adapters.get_dap_launcher_config(launch_args, java_exec, {
			debug = true,
			label = 'Launch All Java Tests',
		})

	dap_launcher_config =
		vim.tbl_deep_extend('force', dap_launcher_config, config or {})

	self.runner:run_by_config(dap_launcher_config, report)
end

return M
