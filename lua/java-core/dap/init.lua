local log = require('java-core.utils.log')
local adapters = require('java-core.dap.adapters')
local JavaDebug = require('java-core.ls.clients.java-debug-client')

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
---@return JavaCoreDapAdapter # dap adapter details
function M:get_dap_adapter()
	log.debug('creating dap adapter for java')

	local port = self.java_debug:start_debug_session()

	return {
		type = 'server',
		host = '127.0.0.1',
		port = port,
	}
end

---Returns the dap configuration for the current project
---@return JavaCoreDapLauncherConfig[] # dap configuration details
function M:get_dap_config()
	log.info('creating dap configuration for java')

	local mains = self.java_debug:resolve_main_class()
	local config = {}

	for _, main in ipairs(mains) do
		table.insert(config, self:get_dap_config_record(main))
	end

	return config
end

---Returns the dap config for the given main class
---@param main JavaDebugResolveMainClassRecord
---@return JavaCoreDapLauncherConfig # dap launch configuration record
function M:get_dap_config_record(main)
	local classpaths =
		self.java_debug:resolve_classpath(main.mainClass, main.projectName)

	local java_exec =
		self.java_debug:resolve_java_executable(main.mainClass, main.projectName)

	return adapters.get_dap_config(main, classpaths, java_exec)
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
