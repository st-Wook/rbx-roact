--[[
	This is a simple signal implementation that has a dead-simple API.

		local signal = createSignal()

		local disconnect = signal:connect(function(foo)
			print("Cool foo:", foo)
		end)

		signal:fire("something")

		disconnect()
]]

local function createSignal()
	local connections = {}
	local suspendedConnections = {}

	local firing = false

	local function subscribe(_self, callback)
		assert(typeof(callback) == "function", "Can only connect to signals with a function.")

		local connection = {
			callback = callback,
			disconnected = false,
		}

		-- If the callback is already registered, don't add to the
		-- suspendedConnection. Otherwise, this will disable the existing one.
		if firing and not connections[callback] then
			suspendedConnections[callback] = connection
		else
			connections[callback] = connection
		end

		local function disconnect()
			connection.disconnected = true
			connections[callback] = nil
			suspendedConnections[callback] = nil
		end

		return disconnect
	end

	local function fire(_self, ...)
		firing = true
		for callback, connection in pairs(connections) do
			if not connection.disconnected and not suspendedConnections[callback] then
				callback(...)
			end
		end

		firing = false

		for callback, connection in pairs(suspendedConnections) do
			connections[callback] = connection
		end
		suspendedConnections = {}
	end

	return {
		subscribe = subscribe,
		fire = fire,
	}
end

return createSignal
