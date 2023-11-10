local List = require('java.utils.list')
local Set = require('java.utils.set')
local JavaTestClient = require('java.ls.clients.java-test-client')

local M = {}

---@class JavaTestLauncherConfig
---@field name string
---@field type string
---@field request string
---@field mainClass string
---@field projectName string
---@field cwd string
---@field classPaths string[]
---@field modulePaths string[]
---@field vmArgs string
---@field noDebug boolean
---@field javaExec string
---@field args string
---@field env? { [string]: string; }
---@field envFile? string
---@field sourcePaths string[]
---@field preLaunchTask? string
---@field postDebugTask? string

---Returns the launcher config
---@param test_details JavaTestDetails | JavaTestDetails[]
---@param launch_args JavaTestJunitLaunchArguments
---@param java_exec JavaDebugResolveJavaExecutableResponse
---@param config { debug: boolean, label: string }
---@return JavaTestLauncherConfig
function M.get_dap_launcher_config(launch_args, java_exec, config)
	return {
		name = config.label,
		type = 'java',
		request = 'launch',
		mainClass = launch_args.mainClass,
		projectName = launch_args.projectName,
		noDebug = not config.debug,
		javaExec = java_exec,
		cwd = launch_args.workingDirectory,
		classPaths = Set:new(launch_args.classpath),
		modulePaths = Set:new(launch_args.modulepath),
		vmArgs = List:new(launch_args.vmArguments):join(' '),
		args = List:new(launch_args.programArguments):join(' '),
		-- env: config?.env,
		-- envFile: config?.envFile,
		-- sourcePaths: config?.sourcePaths,
		-- preLaunchTask: config?.preLaunchTask,
		-- postDebugTask: config?.postDebugTask,
	}

	-- if test_details.testKind == TestKind.TestNG then
	-- 	path.join(extensionContext.extensionPath, 'server', 'com.microsoft.java.test.runner-jar-with-dependencies.jar'),
	-- end
end

---comment
---@param tests JavaTestDetails | JavaTestDetails[]
function M.get_junit_launch_argument_params(tests)
	if not vim.tbl_islist(tests) then
		return {
			projectName = tests.projectName,
			testLevel = tests.testLevel,
			testKind = tests.testKind,
			testNames = M.get_test_names({ tests }),
		}
	end

	local first_test = tests[1]

	return {
		projectName = first_test.projectName,
		testLevel = first_test.testLevel,
		testKind = first_test.testKind,
		testNames = M.get_test_names(tests),
	}
end

---Returns a list of test names to be passed to test launch arguments resolver
---@param tests JavaTestDetails[]
---@return List
function M.get_test_names(tests)
	return List:new(tests):map(function(test)
		if
			test.testKind == JavaTestClient.TestKind.TestNG
			or test.testLevel == JavaTestClient.TestLevel.Class
		then
			return test.fullName
		end

		return test.jdtHandler
	end)
end

return M
