local log = require('java-core.utils.log')
local JdtlsClient = require('java-core.ls.clients.jdtls-client')

---@class JavaCoreTestDetails: Configuration
---@field fullName string
---@field id string
---@field jdtHandler string
---@field label string
---@field projectName string
---@field testKind integer
---@field testLevel integer
---@field uri string

---@class JavaCoreTestDetailsWithRange: JavaCoreTestDetails
---@field range Range

---@class JavaCoreTestDetailsWithChildren: JavaCoreTestDetails
---@field children JavaCoreTestDetailsWithRange[]

---@class JavaCoreTestDetailsWithChildrenAndRange: JavaCoreTestDetails
---@field range Range
---@field children JavaCoreTestDetailsWithRange[]

---@class Range
---@field start CursorPoint
---@field end CursorPoint

---@class CursorPoint
---@field line integer
---@field character integer

---@class JavaCoreTestClient: JavaCoreJdtlsClient
local M = JdtlsClient:new()

---Returns a list of project details in the current root
---@return JavaCoreTestDetails[] # test details of the projects
function M:find_java_projects()
	return self:execute_command(
		'vscode.java.test.findJavaProjects',
		{ vim.uri_from_fname(self.client.config.root_dir) }
	)
end

---Returns a list of test package details
---@param handler string
---@param token? string
---@return JavaCoreTestDetailsWithChildren[] # test package details
function M:find_test_packages_and_types(handler, token)
	return self:execute_command(
		'vscode.java.test.findTestPackagesAndTypes',
		{ handler, token }
	)
end

---Returns test informations in a given file
---@param file_uri string
---@param token? string
---@return JavaCoreTestDetailsWithChildrenAndRange[] # test details
function M:find_test_types_and_methods(file_uri, token)
	return self:execute_command(
		'vscode.java.test.findTestTypesAndMethods',
		{ file_uri, token }
	)
end

---@class JavaCoreTestJunitLaunchArguments
---@field classpath string[]
---@field mainClass string
---@field modulepath string[]
---@field programArguments string[]
---@field projectName string
---@field vmArguments string[]
---@field workingDirectory string

---@class JavaCoreTestResolveJUnitLaunchArgumentsParams
---@field project_name string
---@field test_names string[]
---@field test_level JavaCoreTestLevel
---@field test_kind JavaCoreTestKind

---Returns junit launch arguments
---@param args JavaCoreTestResolveJUnitLaunchArgumentsParams
---@return JavaCoreTestJunitLaunchArguments # junit launch arguments
function M:resolve_junit_launch_arguments(args)
	local launch_args = self:execute_command(
		'vscode.java.test.junit.argument',
		vim.fn.json_encode(args)
	)

	if not launch_args.body then
		local msg = 'Failed to retrive JUnit launch arguments'

		log.error(msg, launch_args)
		error(msg)
	end

	return launch_args.body
end

---@enum JavaCoreTestKind
M.TestKind = {
	JUnit5 = 0,
	JUnit = 1,
	TestNG = 2,
	None = 100,
}

---@enum JavaCoreTestLevel
M.TestLevel = {
	Root = 0,
	Workspace = 1,
	WorkspaceFolder = 2,
	Project = 3,
	Package = 4,
	Class = 5,
	Method = 6,
	Invocation = 7,
}

return M
