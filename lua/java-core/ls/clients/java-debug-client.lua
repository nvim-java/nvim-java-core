local JDTLSClient = require('java-core.ls.clients.jdtls-client')

---@class JavaDebugClient: JDTLSClient
local M = JDTLSClient:new()

---@class JavaDebugResolveMainClassRecord
---@field mainClass string
---@field projectName string
---@field fileName string

---@alias JavaDebugResolveMainClassResponse JavaDebugResolveMainClassRecord[]

---Returns a list of main classes in the current workspace
---@return Promise
function M:resolve_main_class()
	return self:execute_command('vscode.java.resolveMainClass')
end

---@alias JavaDebugResolveClasspathResponse string[][]

---Returns module paths and class paths of a given main class
---@param project_name string
---@param main_class string
---@return Promise
function M:resolve_classpath(main_class, project_name)
	return self:execute_command(
		'vscode.java.resolveClasspath',
		{ main_class, project_name }
	)
end

---@alias JavaDebugResolveJavaExecutableResponse string

---Returns the path to java executable for a given main class
---@param project_name string
---@param main_class string
---@return Promise
function M:resolve_java_executable(main_class, project_name)
	return self:execute_command('vscode.java.resolveJavaExecutable', {
		main_class,
		project_name,
	})
end

---@alias JavaDebugCheckProjectSettingsResponse boolean

---Returns true if the project settings is the expected
---@param project_name string
---@param main_class string
---@param inheritedOptions boolean
---@param expectedOptions { [string]: any }
---@return Promise
function M:check_project_settings(
	main_class,
	project_name,
	inheritedOptions,
	expectedOptions
)
	return self:execute_command(
		'vscode.java.checkProjectSettings',
		vim.fn.json_encode({
			className = main_class,
			projectName = project_name,
			inheritedOptions = inheritedOptions,
			expectedOptions = expectedOptions,
		})
	)
end

---@alias JavaDebugStartDebugSessionResponse integer

---Starts a debug session and returns the port number
---@return Promise
function M:start_debug_session()
	return self:execute_command('vscode.java.startDebugSession')
end

function M:build_workspace()
	return self:execute_command('vscode.java.buildWorkspace')
end

return M
