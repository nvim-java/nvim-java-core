local log = require('java-core.utils.log')
local adapters = require('java-core.ls.adapters.test-adapter')
local List = require('java-core.utils.list')
local JavaDebug = require('java-core.ls.clients.java-debug-client')
local Promise = require('java-core.utils.promise')

---@class JavaCoreDap
---@field client LSPClient
---@field java_debug JavaCoreDebugClient
local M = {}

---Returns a new dap instance
---@param args { client: LSPClient }
---@return JavaCoreDap
function M:new(args)
	local o = {
		client = args.client,
	}

	o.java_debug = JavaDebug:new({
		client = args.client,
	})

	setmetatable(o, self)
	self.__index = self
	return o
end

---@class JavaDapAdapter
---@field type string
---@field host string
---@field port integer

---Returns the dap adapter config
---@return Promise
function M:get_dap_adapter()
	log.info('creating dap adapter for java')

	return self.java_debug:start_debug_session():thenCall(
		---@param port JavaDebugStartDebugSessionResponse
		function(port)
			return {
				type = 'server',
				host = '127.0.0.1',
				port = port,
			}
		end
	)
end

---@alias JavaDapConfigurationList JavaDapConfiguration[]

---Returns the dap configuration for the current project
---@return Promise
function M:get_dap_config()
	log.info('creating dap configuration for java')

	return self.java_debug:resolve_main_class():thenCall(
		---@param mains JavaDebugResolveMainClassResponse
		function(mains)
			local config_promises = List:new(mains):map(function(main)
				return self:get_dap_config_record(main)
			end)

			return Promise.all(config_promises)
		end
	)
end

---Returns the dap config for the given main class
---@param main JavaDebugResolveMainClassRecord
---@return Promise
function M:get_dap_config_record(main)
	return Promise.all({
		self.java_debug:resolve_classpath(main.mainClass, main.projectName),
		self.java_debug:resolve_java_executable(main.mainClass, main.projectName),
	}):thenCall(function(res)
		---@type JavaDebugResolveClasspathResponse
		local classpaths = res[1]

		---@type JavaDebugResolveJavaExecutableResponse
		local java_exec = res[2]

		return adapters.get_dap_config(main, classpaths, java_exec)
	end)
end

---Dap run with given config
---@param config JavaDapConfiguration
function M.dap_run(config)
	log.info('running dap with config: ', config)

	local function get_stream_reader(conn)
		return vim.schedule_wrap(function(err, buffer)
			assert(not err, err)

			if buffer then
				vim.print(buffer)
			else
				conn:close()
			end
		end)
	end

	---@type uv_tcp_t
	local server

	require('dap').run(config, {
		before = function(conf)
			log.debug('running before dap callback')

			server = assert(vim.loop.new_tcp(), 'uv.new_tcp() must return handle')
			server:bind('127.0.0.1', 0)
			server:listen(128, function(err)
				assert(not err, err)

				local sock = assert(vim.loop.new_tcp(), 'uv.new_tcp must return handle')
				server:accept(sock)
				sock:read_start(get_stream_reader(sock))
			end)

			conf.args =
				conf.args:gsub('-port ([0-9]+)', '-port ' .. server:getsockname().port)

			return conf
		end,

		after = function()
			vim.debug('running after dap callback')

			if server then
				server:shutdown()
				server:close()
			end
		end,
	})
end

return M
