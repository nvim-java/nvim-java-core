local class = require('java-core.utils.class')

local JdtlsClient = require('java-core.ls.clients.jdtls-client')

---@class java-core.DebugClient: java-core.JdtlsClient
local DebugClient = class(JdtlsClient)

function DebugClient:_init(client)
	self:super(client)
end

---@class JavaDebugResolveMainClassRecord
---@field mainClass string
---@field projectName string
---@field fileName string

---Returns a list of main classes in the current workspace
---@return JavaDebugResolveMainClassRecord[] # resolved main class
function DebugClient:resolve_main_class()
	return self:workspace_execute_command('vscode.java.resolveMainClass')
end

---Returns module paths and class paths of a given main class
---@param project_name string
---@param main_class string
---@return string[][] # resolved class and module paths
function DebugClient:resolve_classpath(main_class, project_name)
	return self:workspace_execute_command(
		'vscode.java.resolveClasspath',
		{ main_class, project_name }
	)
end

---Returns the path to java executable for a given main class
---@param project_name string
---@param main_class string
---@return string # path to java executable
function DebugClient:resolve_java_executable(main_class, project_name)
	return self:workspace_execute_command('vscode.java.resolveJavaExecutable', {
		main_class,
		project_name,
	})
end

---Returns true if the project settings is the expected
---@param project_name string
---@param main_class string
---@param inheritedOptions boolean
---@param expectedOptions { [string]: any }
---@return boolean # true if the setting is the expected setting
function DebugClient:check_project_settings(
	main_class,
	project_name,
	inheritedOptions,
	expectedOptions
)
	return self:workspace_execute_command(
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
---@return integer # port number of the debug session
function DebugClient:start_debug_session()
	return self:workspace_execute_command('vscode.java.startDebugSession')
end

---@enum CompileWorkspaceStatus
DebugClient.CompileWorkspaceStatus = {
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
---@return CompileWorkspaceStatus # compiled status
function DebugClient:build_workspace(
	main_class,
	project_name,
	file_path,
	is_full_build
)
	return self:workspace_execute_command(
		'vscode.java.buildWorkspace',
		vim.fn.json_encode({
			mainClass = main_class,
			projectName = project_name,
			filePath = file_path,
			isFullBuild = is_full_build,
		})
	)
end

return DebugClient
