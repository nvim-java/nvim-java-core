local log = require('java-core.utils.log')

---@class JavaCoreDapRunner
---@field reporter JavaCoreDapRunReport
---@field private server uv_tcp_t
local M = {}

---@param args { reporter: JavaCoreDapRunReport }
---@return JavaCoreDapRunner
function M:new(args)
	local o = {
		reporter = args.reporter,
		server = nil,
	}

	setmetatable(o, self)
	self.__index = self
	return o
end

---Dap run with given config
---@param config JavaCoreDapLauncherConfig
function M:run_by_config(config)
	log.debug('running dap with config: ', config)

	require('dap').run(config --[[@as Configuration]], {
		before = function(conf)
			return self:before(conf)
		end,

		after = function()
			return self:after()
		end,
	})
end

---Runs before the dap run
---@private
---@param conf JavaCoreDapLauncherConfig
---@return JavaCoreDapLauncherConfig
function M:before(conf)
	log.debug('running "before" callback')

	self.server = assert(vim.loop.new_tcp(), 'uv.new_tcp() must return handle')
	self.server:bind('127.0.0.1', 0)
	self.server:listen(128, function(err)
		assert(not err, err)

		local sock = assert(vim.loop.new_tcp(), 'uv.new_tcp must return handle')
		self.server:accept(sock)
		local success = sock:read_start(self.reporter:get_stream_reader(sock))
		assert(success == 0, 'failed to listen to reader')
	end)

	-- replace the port number in the generated args
	conf.args =
		conf.args:gsub('-port ([0-9]+)', '-port ' .. self.server:getsockname().port)

	return conf
end

---Runs aafter the dap run
---@private
function M:after()
	vim.debug('running "after" callback')

	if self.server then
		self.server:shutdown()
		self.server:close()
	end
end

return M

---@class JavaCoreDapRunReport
---@field get_stream_reader fun(self: JavaCoreDapRunReport, conn: uv_tcp_t): fun(err: string|nil, buffer: string|nil)
