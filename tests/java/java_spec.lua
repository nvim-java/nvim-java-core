local java = require('java')

describe('setup', function()
	it('get_config API is available', function()
		assert(java.get_config, 'get_config API not found')
	end)
end)
