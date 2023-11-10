local log = require('java-core.utils.log')
local file = require('java-core.utils.file')
local mason = require('java-core.utils.mason')

local M = {}

---Returns a list of jar files of given plugin
---@param pkg_name string name of the mason package name
---@return string[]
function M.get_plugin_jars(pkg_name, path_to_jars)
	if not mason.is_pkg_installed(pkg_name) then
		log.fmt_debug('plugin %s is not installed', pkg_name)
		return {}
	end

	local path = mason.get_shared_path(pkg_name)

	log.fmt_info('looking for %s plugin files at %s', pkg_name, path)

	local files = file.get_file_list(path .. path_to_jars)

	log.fmt_debug('found %d files for %s plugin ', #files, pkg_name)
	return files
end

---Returns a list of jar files of all the plugins
---@param plugin_list JDTLSPluginPaths
---@return string[]
function M.get_plugins(plugin_list)
	local plugins = {}

	for _, plugin in ipairs(plugin_list) do
		vim.list_extend(plugins, M.get_plugin_jars(plugin.name, plugin.path))
	end

	return plugins
end

return M
