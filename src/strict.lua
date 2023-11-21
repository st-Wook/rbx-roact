--!strict
local function strict(t: { [any]: any }, name: string?)
	-- FIXME Luau: Need to define a new variable since reassigning `name = ...`
	-- doesn't narrow the type
	local newName = name or tostring(t)

	return setmetatable(t, {
		__index = function(_self, key)
			local message = string.format("%q (%s) is not a valid member of %s", tostring(key), typeof(key), newName)

			error(message, 2)
		end,

		__newindex = function(_self, key, _value)
			local message = string.format("%q (%s) is not a valid member of %s", tostring(key), typeof(key), newName)

			error(message, 2)
		end,
	})
end

return strict
