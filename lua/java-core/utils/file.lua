local M = {}

---Return true if the given path is a directory
---@param path string
---@return boolean
function M.is_dir(path)
	return vim.fn.isdirectory(path) == 1
end

---Returns true if the given path is a file
---@param path string
---@return boolean
function M.is_file(path)
	return vim.fn.filereadable(path) == 1
end

---Returns true if the given path is an executable
---@param path string
---@return boolean
function M.is_exec(path)
	return vim.fn.executable(path) == 1
end

---Returns a list of files from a path with wildcards
---@param path string path with the wildcards
---@return string[]
function M.get_file_list(path)
	return vim.fn.glob(path, true, true)
end

---Creates a directory in the given path
---@param path string
---@param opts JavaDirCreateFlags
function M.mkdir(path, opts)
	local flags = ''

	if opts.create_intermediate then
		flags = flags .. 'p'
	end

	vim.fn.mkdir(path, flags)
end

return M

---@class JavaDirCreateFlags
---@field create_intermediate boolean whether the intermediate directories should be created in the process
