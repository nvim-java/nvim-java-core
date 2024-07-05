local mason = require('java-core.utils.mason')
local file = require('java-core.utils.file')

local List = require('java-core.utils.list')

local M = {}

local plug_jar_map = {
	['java-test'] = {
		'junit-jupiter-api_*.jar',
		'junit-jupiter-engine_*.jar',
		'junit-jupiter-migrationsupport_*.jar',
		'junit-jupiter-params_*.jar',
		'junit-platform-commons_*.jar',
		'junit-platform-engine_*.jar',
		'junit-platform-launcher_*.jar',
		'junit-platform-runner_*.jar',
		'junit-platform-suite-api_*.jar',
		'junit-platform-suite-commons_*.jar',
		'junit-platform-suite-engine_*.jar',
		'junit-vintage-engine_*.jar',
		'org.apiguardian.api_*.jar',
		'org.eclipse.jdt.junit4.runtime_*.jar',
		'org.eclipse.jdt.junit5.runtime_*.jar',
		'org.opentest4j_*.jar',
		'com.microsoft.java.test.plugin-*.jar',
	},
	['java-debug-adapter'] = { '*.jar' },
	['spring-boot-tools'] = { 'jars/*.jar' },
}

---Returns a list of .jar file paths for given list of jdtls plugins
---@param plugin_names string[]
---@return string[] # list of .jar file paths
function M.get_plugin_paths(plugin_names)
	return List:new(plugin_names)
		:map(function(plugin_name)
			local root = mason.get_shared_path(plugin_name)
			return file.resolve_paths(root, plug_jar_map[plugin_name])
		end)
		:flatten()
end

return M
