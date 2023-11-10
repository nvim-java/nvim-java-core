local log = require('java-core.utils.log')
local JDTLSClient = require('java-core.ls.clients.jdtls-client')

---@class JavaTestDetails: Configuration
---@field fullName string
---@field id string
---@field jdtHandler string
---@field label string
---@field projectName string
---@field testKind integer
---@field testLevel integer
---@field uri string

---@class JavaTestDetailsWithRange: JavaTestDetails
---@field range Range

---@class JavaTestDetailsWithChildren: JavaTestDetails
---@field children JavaTestDetailsWithRange[]

---@class JavaTestDetailsWithChildrenAndRange: JavaTestDetails
---@field range Range
---@field children JavaTestDetailsWithRange[]

---@class Range
---@field start CursorPoint
---@field end CursorPoint

---@class CursorPoint
---@field line integer
---@field character integer

---@class JavaTestClient: JDTLSClient
local M = JDTLSClient:new()

---@alias JavaTestFindJavaProjectsResponse JavaTestDetails[]

---Returns a list of project details in the current root
---@return Promise
function M:find_java_projects()
	return self:execute_command(
		'vscode.java.test.findJavaProjects',
		{ vim.uri_from_fname(self.client.config.root_dir) }
	)
end

---@alias JavaTestFindTestPackagesAndTypesResponse JavaTestDetailsWithChildren[]

---Returns a list of test package details
---@param token any
---@return Promise
function M:find_test_packages_and_types(handler, token)
	return self:execute_command(
		'vscode.java.test.findTestPackagesAndTypes',
		{ handler, token }
	)
end

---@alias JavaTestFindTestTypesAndMethodsResponse JavaTestDetailsWithChildrenAndRange[]

---Returns test informations in a given file
---@param file_uri string
---@param token any
---@return Promise
function M:find_test_types_and_methods(file_uri, token)
	return self:execute_command(
		'vscode.java.test.findTestTypesAndMethods',
		{ file_uri, token }
	)
end

---@class JavaTestJunitLaunchArguments
---@field classpath string[]
---@field mainClass string
---@field modulepath string[]
---@field programArguments string[]
---@field projectName string
---@field vmArguments string[]
---@field workingDirectory string

---@class JavaTestResolveJUnitLaunchArgumentsParams
---@field project_name string
---@field test_names string[]
---@field test_level TestLevel
---@field test_kind TestKind

---Returns junit launch arguments
---@param args JavaTestResolveJUnitLaunchArgumentsParams
---@return Promise
function M:resolve_junit_launch_arguments(args)
	return self
		:execute_command(
			'vscode.java.test.junit.argument',
			vim.fn.json_encode(args)
		)
		:thenCall(

			---@class JavaTestJunitLaunchArgumentsResponse
			---@field body JavaTestJunitLaunchArguments
			---@field status integer

			---@param res JavaTestJunitLaunchArgumentsResponse
			function(res)
				if not res.body then
					local msg = 'Failed to retrive JUnit launch arguments'

					log.error(msg, res)
					error(msg)
				end

				return res.body
			end
		)
end

---@enum TestKind
M.TestKind = {
	JUnit5 = 0,
	JUnit = 1,
	TestNG = 2,
	None = 100,
}

---@enum TestLevel
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
