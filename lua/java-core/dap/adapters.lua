local M = {}

---Returns the dap config record
---@param main JavaDebugResolveMainClassRecord
---@param classpath string[][]
---@param java_exec string
---@return JavaCoreDapLauncherConfig
function M.get_dap_config(main, classpath, java_exec)
	local project_name = main.projectName
	local main_class = main.mainClass
	local module_paths = classpath[1]
	local class_paths = classpath[2]

	return {
		request = 'launch',
		type = 'java',
		name = string.format('%s -> %s', project_name, main_class),
		projectName = project_name,
		mainClass = main_class,
		javaExec = java_exec,
		modulePaths = module_paths,
		classPaths = class_paths,
	}
end

return M
