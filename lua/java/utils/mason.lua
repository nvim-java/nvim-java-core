local M = {}

---Returns the path to the package in mason packages
---@param pkg_name string
---@return string | nil
function M.get_pkg_path(pkg_name)
	return require('mason-registry').get_package(pkg_name):get_install_path()
end

---Returns true if the package in installed in mason
---@param pkg_name string
---@return boolean
function M.is_pkg_installed(pkg_name)
	return require('mason-registry').get_package(pkg_name):is_installed()
end

return M
