--[[
	Constructs a physical Instance from a luau-roblox virtual instance.
]]
local function MaterializeVirtualInstance(VirtualInstance)
	local Instance = Instance.new(VirtualInstance["@instance"].className)

	for Key, Value in VirtualInstance["@instance"].properties do
		Instance[Key] = Value.value
	end

	return Instance
end

return MaterializeVirtualInstance
