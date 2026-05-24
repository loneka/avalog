--[[
	Injects the upgraded model counterparts of Avalog Cosmetics.
]]

local Avalog = script.Parent.Parent.Parent
local LuauRoblox = require(Avalog.SourceCode.Storage.Utils.LuauRoblox)
local MaterializeVirtualInstance = require(Avalog.SourceCode.Storage.Utils.MaterializeVirtualInstance)
local Fetch = require(Avalog.Parent.Fetch)

local Cosmetics = {}

function Cosmetics.Start(_self: typeof(Cosmetics))
	local Success, Response = Fetch("http://localhost:3000/cosmetic/135037445384022.rbxm"):Await()

	if Success then
		print(Response.Body)

		local Instances = LuauRoblox.deserializeModel(Response.Body)
		local Model = MaterializeVirtualInstance(Instances[1])

		print(Model)

		Model.Name = "DeserializedModel"
		Model.Parent = workspace
		Model.Position = Vector3.new(0, 10, 0)
	else
		warn(Response)
	end
end

function Cosmetics.Destroy(_self: typeof(Cosmetics)) end

return Cosmetics
