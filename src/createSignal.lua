--!strict

local function createSignal()
	local subscriptions = {}
	local suspendedSubscriptions = {}

	local firing = false

	local function subscribe(_self, callback)
		local subscription = {
			callback = callback,
			unsubscribed = false,
		}

		-- If the callback is already registered, don't add to the
		-- suspendedConnection. Otherwise, this will disable the existing one.
		if firing and not subscriptions[callback] then
			suspendedSubscriptions[callback] = subscription
		else
			subscriptions[callback] = subscription
		end

		local function unsubscribe(_self)
			subscription.unsubscribed = true
			subscriptions[callback] = nil
			suspendedSubscriptions[callback] = nil
		end

		return {
			unsubscribe = unsubscribe,
		}
	end

	local function fire(value)
		firing = true
		for callback, subscription in subscriptions do
			if not subscription.unsubscribed and not suspendedSubscriptions[callback] then
				callback(value)
			end
		end

		firing = false
		for callback, subscription in suspendedSubscriptions do
			subscriptions[callback] = subscription
		end
		table.clear(suspendedSubscriptions)
	end

	return {
		subscribe = subscribe,
	}, fire
end

return createSignal
