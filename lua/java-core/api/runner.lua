local log = require('java-core.utils.log')

local DebugClient = require('java-core.ls.clients.java-debug-client')

--- @class java_core.RunnerApi
--- @field private client java-core.JdtlsClient
--- @field private debug_client java-core.DebugClient
local M = {}

function M:new(args)
	local o = {
		client = args.client,
	}

	o.debug_client = DebugClient(args.client)

	setmetatable(o, self)
	self.__index = self

	return o
end

--- @param callback fun(cmd: string[])
function M:run_app(callback)
	local resolved_main_class_records = self.debug_client:resolve_main_class()
	log.debug(
		'resolved main class records: ' .. vim.inspect(resolved_main_class_records)
	)

	if #resolved_main_class_records == 0 then
		vim.notify('no main class found')
		return
	end
	-- TODO handle multiple main classes
	if #resolved_main_class_records > 1 then
		vim.notify('multiple main classes dosent supported yet')
		return
	end

	local main_class = resolved_main_class_records[1].mainClass
	local project_name = resolved_main_class_records[1].projectName or ''
	local file_path = resolved_main_class_records[1].filePath

	log.debug(
		'main class: '
			.. main_class
			.. ' project name: '
			.. project_name
			.. '  filePath: '
			.. file_path
	)

	local resolved_java_executable =
		self.debug_client:resolve_java_executable(main_class, project_name)
	log.debug('java exec: ' .. resolved_java_executable)

	--- TODO check when build is failed
	self.debug_client:build_workspace(project_name, project_name, file_path, true)

	local classpath = table.concat(
		self.debug_client:resolve_classpath(main_class, project_name)[2],
		':'
	)
	log.debug('classpath: ' .. classpath)

	local cmd = {
		resolved_java_executable,
		'-cp',
		classpath,
		main_class,
	}

	callback(cmd)
end

return M
