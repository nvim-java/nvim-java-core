local log = require('java-core.utils.log')
local adapters = require('java-core.dap.adapters')
local List = require('java-core.utils.list')
local JavaDebug = require('java-core.ls.clients.java-debug-client')
local Promise = require('java-core.utils.promise')

---@class JavaCoreDap
---@field client LspClient
---@field java_debug JavaCoreDebugClient
local M = {}

---Returns a new dap instance
---@param args { client: LspClient }
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

---@class JavaCoreDapAdapter
---@field type string
---@field host string
---@field port integer

---Returns the dap adapter config
---@return Promise # Promise<JavaCoreDapAdapter>
function M:get_dap_adapter()
	log.info('creating dap adapter for java')

	return self.java_debug:start_debug_session():thenCall(
		---@param port integer
		function(port)
			return {
				type = 'server',
				host = '127.0.0.1',
				port = port,
			}
		end
	)
end

---Returns the dap configuration for the current project
---@return Promise # Promise<JavaDapConfiguration[]>
function M:get_dap_config()
	log.info('creating dap configuration for java')

	return self.java_debug:resolve_main_class():thenCall(
		---@param mains JavaDebugResolveMainClassRecord[]
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
---@return Promise # Promise<JavaCoreDapLauncherConfig>
function M:get_dap_config_record(main)
	return Promise.all({
		self.java_debug:resolve_classpath(main.mainClass, main.projectName),
		self.java_debug:resolve_java_executable(main.mainClass, main.projectName),
	}):thenCall(function(res)
		---@type string[][]
		local classpaths = res[1]

		---@type string
		local java_exec = res[2]

		return adapters.get_dap_config(main, classpaths, java_exec)
	end)
end

return M

---@class JavaCoreDapLauncherConfigOverridable
---@field name? string
---@field type? string
---@field request? string
---@field mainClass? string
---@field projectName? string
---@field cwd? string
---@field classPaths? string[]
---@field modulePaths? string[]
---@field vmArgs? string
---@field noDebug? boolean
---@field javaExec? string
---@field args? string
---@field env? { [string]: string; }
---@field envFile? string
---@field sourcePaths? string[]
---@field preLaunchTask? string
---@field postDebugTask? string

---@class JavaCoreDapLauncherConfig
---@field name string
---@field type string
---@field request string
---@field mainClass string
---@field projectName string
---@field cwd string
---@field classPaths string[]
---@field modulePaths string[]
---@field vmArgs string
---@field noDebug boolean
---@field javaExec string
---@field args string
---@field env? { [string]: string; }
---@field envFile? string
---@field sourcePaths string[]
---@field preLaunchTask? string
---@field postDebugTask? string
