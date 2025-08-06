local mason_registry = require('mason-registry')

local M = {}

---Returns the path to the package in mason packages
---@param pkg_name string
---@return string | nil
function M.get_pkg_path(pkg_name)
	local found, pkg = pcall(mason_registry.get_package, pkg_name)
	if not found or not pkg:is_installed() then
		return nil
	end
	return vim.fn.expand('$MASON/packages/' .. pkg_name)
end

---Returns true if the package is installed in mason
---@param pkg_name string
---@return boolean
function M.is_pkg_installed(pkg_name)
	local found, pkg = pcall(mason_registry.get_package, pkg_name)
	return found and pkg:is_installed()
end

---Returns the shared artifact path for a given package
---@param pkg_name string name of the package to get the path of
---@return string # path to the shared artifact directory of the package
function M.get_shared_path(pkg_name)
	return vim.fn.glob('$MASON/share/' .. pkg_name)
end

return M
