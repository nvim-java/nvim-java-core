local co = coroutine

local wrap = function(func)
	assert(type(func) == 'function', 'type error :: expected func')
	local factory = function(...)
		local params = { ... }
		local thunk = function(step)
			table.insert(params, step)
			return func(unpack(params))
		end
		return thunk
	end
	return factory
end

local function async(func)
	local error_handler = nil

	local async_thunk_factory = wrap(function(handler, parent_handler_callback)
		assert(type(handler) == 'function', 'type error :: expected func')
		local thread = co.create(handler)
		local step = nil

		step = function(...)
			local ok, thunk = co.resume(thread, ...)

			-- when an error() is thrown after co-routine is resumed, obviously further
			-- processing stops, and resume returns ok(false) and thunk(error) returns
			-- the error message
			if not ok then
				if error_handler then
					error_handler(thunk)
					return
				end

				if parent_handler_callback then
					parent_handler_callback(thunk)
					return
				end

				error('unhandled error ' .. tostring(thunk))
			end

			assert(ok, thunk)
			if co.status(thread) == 'dead' then
				if parent_handler_callback then
					parent_handler_callback(thunk)
				end
			else
				thunk(step)
			end
		end

		step()
	end)

	return setmetatable({}, {
		__call = function(_, ...)
			return async_thunk_factory(func)(...)
		end,
		__index = function(this, key)
			if key == 'catch' then
				return function(loc_error_handler)
					error_handler = loc_error_handler
					return this
				end
			end

			if key == 'run' then
				return function(...)
					return async_thunk_factory(func)(...)
				end
			end

			error('cannot index ' .. key .. ' in async function')
		end,
	})
end

-- many thunks -> single thunk
local join = function(thunks)
	local len = #thunks
	local done = 0
	local acc = {}

	local thunk = function(step)
		if len == 0 then
			return step()
		end
		for i, tk in ipairs(thunks) do
			assert(type(tk) == 'function', 'thunk must be function')
			local callback = function(...)
				acc[i] = { ... }
				done = done + 1
				if done == len then
					step(unpack(acc))
				end
			end
			tk(callback)
		end
	end
	return thunk
end

local await = function(defer)
	return co.yield(defer)
end

local await_handle_error = function(defer)
	local err, value = co.yield(defer)

	if err then
		error(err)
	end

	return value
end

local await_handle_ok = function(defer)
	local ok, value = co.yield(defer)

	if not ok then
		error(value)
	end

	return value
end

local await_all = function(defer)
	assert(type(defer) == 'table', 'type error :: expected table')
	return co.yield(join(defer))
end

return {
	sync = async,
	wait_handle_error = await_handle_error,
	wait_handle_ok = await_handle_ok,
	wait = await,
	wait_all = await_all,
	wrap = wrap,
}
