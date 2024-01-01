local spy = require('luassert.spy')
local DebugClient = require('java-core.ls.clients.java-debug-client')

local mock_client = { jdtls_args = {} }
local runner = require('java-core.api.runner')
local RunnerApi = runner:new({ client = mock_client })

describe('java-core.api.runner', function()
	it('RunnerApi:new', function()
		local mock_debug_client = DebugClient(mock_client)

		assert.same(RunnerApi.client, mock_client)
		assert.same(RunnerApi.debug_client, mock_debug_client)
	end)

	it('RunnerApi:run_app when no main class found', function()
		RunnerApi.debug_client.resolve_main_class = function()
			return {}
		end

		local callback_spy = spy.new(function(_) end)
		RunnerApi:run_app(callback_spy)

		assert.spy(callback_spy).was_not_called()
	end)

	it('RunnerApi:run_app when multiple main classes found', function()
		RunnerApi.debug_client.resolve_main_class = function()
			return {
				{
					mainClass = 'mainClass',
					projectName = 'projectName',
					filePath = 'filePath',
				},
				{
					mainClass = 'mainClass',
					projectName = 'projectName',
					filePath = 'filePath',
				},
			}
		end

		local callback_spy = spy.new(function(_) end)
		RunnerApi:run_app(callback_spy)

		assert.spy(callback_spy).was_not_called()
	end)

	it('RunnerApi:run_app', function()
		local test_cases = {
			{
				name = 'when "projectName" property is present',
				dataset = {
					resolved_main_class = {
						{
							mainClass = 'com.mock.Main',
							projectName = 'mock',
							filePath = 'home/user/mock/Main.java',
						},
					},
				},
			},
			{
				name = 'when "projectName" property is not present',
				dataset = {
					resolved_main_class = {
						{
							mainClass = 'com.mock.Main',
							filePath = 'home/user/mock/Main.java',
						},
					},
				},
			},
		}

		for _, test_case in ipairs(test_cases) do
			it(test_case.name, function()
				RunnerApi.debug_client.resolve_main_class = function()
					return test_case.dataset.resolved_main_class
				end

				RunnerApi.debug_client.resolve_java_executable = function()
					return '/path/to/java_executable'
				end

				RunnerApi.debug_client.resolve_classpath = function()
					return { {}, { 'path1', 'path2' } }
				end

				RunnerApi.debug_client.build_workspace = function()
					return {}
				end

				local callback_spy = spy.new(function(_) end)
				RunnerApi:run_app(callback_spy)

				assert.spy(callback_spy).was_called_with({
					'/path/to/java_executable',
					'-cp',
					'path1:path2',
					'com.mock.Main',
				})
			end)
		end
	end)
end)
