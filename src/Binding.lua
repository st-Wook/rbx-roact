local Symbol = require(script.Parent.Symbol)
local Type = require(script.Parent.Type)
local createSignal = require(script.Parent.createSignal)

local config = require(script.Parent.GlobalConfig).get()

local BindingImpl = Symbol.named("BindingImpl")

local BindingInternalApi = {}

local bindingPrototype = {}

function bindingPrototype:getValue()
	return BindingInternalApi.getValue(self)
end

function bindingPrototype:map(predicate)
	return BindingInternalApi.map(self, predicate)
end

local BindingPublicMeta = {
	__index = bindingPrototype,
	__tostring = function(self)
		return string.format("RoactBinding(%s)", tostring(self:getValue()))
	end,
}

function BindingInternalApi.update(binding, newValue)
	return binding[BindingImpl].update(newValue)
end

function BindingInternalApi.connect(binding, callback)
	return binding[BindingImpl].connect(callback)
end

function BindingInternalApi.getValue(binding)
	return binding[BindingImpl].getValue()
end

function BindingInternalApi.create(initialValue)
	local impl = {
		value = initialValue,
		changeSignal = createSignal(),
	}

	function impl.connect(callback)
		return impl.changeSignal:connect(callback)
	end

	function impl.update(newValue)
		impl.value = newValue
		impl.changeSignal:fire(newValue)
	end

	function impl.getValue()
		return impl.value
	end

	return setmetatable({
		[Type] = Type.Binding,
		[BindingImpl] = impl,
	}, BindingPublicMeta), impl.update
end

function BindingInternalApi.map(upstreamBinding, predicate)
	if config.typeChecks then
		assert(Type.of(upstreamBinding) == Type.Binding, "Expected arg #1 to be a binding")
		assert(typeof(predicate) == "function", "Expected arg #1 to be a function")
	end

	local impl = {}

	function impl.connect(callback)
		return BindingInternalApi.connect(upstreamBinding, function(newValue)
			callback(predicate(newValue))
		end)
	end

	function impl.update(_newValue)
		error("Bindings created by Binding:map(fn) cannot be updated directly", 2)
	end

	function impl.getValue()
		return predicate(upstreamBinding:getValue())
	end

	return setmetatable({
		[Type] = Type.Binding,
		[BindingImpl] = impl,
	}, BindingPublicMeta)
end

function BindingInternalApi.join(upstreamBindings)
	if config.typeChecks then
		assert(typeof(upstreamBindings) == "table", "Expected arg #1 to be of type table")

		for key, value in pairs(upstreamBindings) do
			if Type.of(value) ~= Type.Binding then
				local message = string.format(
					"Expected arg #1 to contain only bindings, but key %q had a non-binding value",
					tostring(key)
				)
				error(message, 2)
			end
		end
	end

	local impl = {}

	local function getValue()
		local value = {}

		for key, upstream in pairs(upstreamBindings) do
			value[key] = upstream:getValue()
		end

		return value
	end

	function impl.connect(callback)
		local disconnects = {}

		for key, upstream in pairs(upstreamBindings) do
			disconnects[key] = BindingInternalApi.connect(upstream, function(_newValue)
				callback(getValue())
			end)
		end

		return function()
			if disconnects == nil then
				return
			end

			for _, disconnect in pairs(disconnects) do
				disconnect()
			end

			disconnects = nil :: any
		end
	end

	function impl.update(_newValue)
		error("Bindings created by joinBindings(...) cannot be updated directly", 2)
	end

	function impl.getValue()
		return getValue()
	end

	return setmetatable({
		[Type] = Type.Binding,
		[BindingImpl] = impl,
	}, BindingPublicMeta)
end

return BindingInternalApi
