local mason_registry = require('mason-registry')

local M = {}

---Returns the path to the package in mason packages
---@param pkg_name string
---@return string | nil
function M.get_pkg_path(pkg_name)
  local mason_data_path = vim.fn.stdpath("data") .. "/mason/packages/" .. pkg_name
  return mason_data_path
end

---Returns true if the package is installed in mason
---@param pkg_name string
---@return boolean
function M.is_pkg_installed(pkg_name)
  local ok, pkg = pcall(mason_registry.get_package, pkg_name)
  return ok and pkg:is_installed()
end

---Returns the shared artifact path for a given package
---@param pkg_name string
---@return string
function M.get_shared_path(pkg_name)
  local mason_share_path = vim.fn.stdpath("data") .. "/mason/share/" .. pkg_name
  return mason_share_path
end

return M

