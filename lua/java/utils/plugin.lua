local file = require('java.utils.file')
local mason = require('java.utils.mason')

local M = {}

---Returns a list of jar files of given plugin
---@param pkg_name string name of the mason package name
---@return string[]
function M.get_plugin_jars(pkg_name)
	if not mason.is_pkg_installed(pkg_name) then
		return {}
	end

	local path = mason.get_pkg_path(pkg_name)

	return file.get_file_list(path .. '/extension/server/*.jar')
end

---Returns a list of jar files of all the plugins
---@return string[]
function M.get_plugins(plugin_list)
	local plugins = {}

	for _, plugin in ipairs(plugin_list) do
		vim.list_extend(plugins, M.get_plugin_jars(plugin))
	end

	return plugins
end

return M
