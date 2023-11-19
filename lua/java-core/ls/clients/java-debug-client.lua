local JdtlsClient = require('java-core.ls.clients.jdtls-client')

---@class JavaCoreDebugClient: JavaCoreJdtlsClient
local M = JdtlsClient:new()

---@class JavaDebugResolveMainClassRecord
---@field mainClass string
---@field projectName string
---@field fileName string

---Returns a list of main classes in the current workspace
---@return Promise # Promise<JavaDebugResolveMainClassRecord[]>
function M:resolve_main_class()
	return self:execute_command('vscode.java.resolveMainClass')
end

---Returns module paths and class paths of a given main class
---@param project_name string
---@param main_class string
---@return Promise # Promise<string[][]>
function M:resolve_classpath(main_class, project_name)
	return self:execute_command(
		'vscode.java.resolveClasspath',
		{ main_class, project_name }
	)
end

---Returns the path to java executable for a given main class
---@param project_name string
---@param main_class string
---@return Promise # Promise<string>
function M:resolve_java_executable(main_class, project_name)
	return self:execute_command('vscode.java.resolveJavaExecutable', {
		main_class,
		project_name,
	})
end

---Returns true if the project settings is the expected
---@param project_name string
---@param main_class string
---@param inheritedOptions boolean
---@param expectedOptions { [string]: any }
---@return Promise # Promise<boolean>
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

---Starts a debug session and returns the port number
---@return Promise # Promise<integer>
function M:start_debug_session()
	return self:execute_command('vscode.java.startDebugSession')
end

---@enum CompileWorkspaceStatus
M.CompileWorkspaceStatus = {
	FAILED = 0,
	SUCCEED = 1,
	WITHERROR = 2,
	CANCELLED = 3,
}

---Build the workspace
---@param main_class string
---@param project_name? string
---@param file_path? string
---@param is_full_build boolean
---@return Promise # Promise<CompileWorkspaceStatus>
function M:build_workspace(main_class, project_name, file_path, is_full_build)
	return self:execute_command(
		'vscode.java.buildWorkspace',
		vim.fn.json_encode({
			mainClass = main_class,
			projectName = project_name,
			filePath = file_path,
			isFullBuild = is_full_build,
		})
	)
end

return M
