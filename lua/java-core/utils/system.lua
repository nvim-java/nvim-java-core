local M = {}

function M.get_os()
	if vim.fn.has('mac') == 1 then
		return 'mac'
	elseif vim.fn.has('win32') == 1 or vim.fn.has('win64') then
		return 'win'
	else
		return 'linux'
	end
end

return M
