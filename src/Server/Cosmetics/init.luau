--[[
	Injects the upgraded model counterparts of Avalog Cosmetics.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Avalog = script.Parent.Parent.Parent
local ModelSquash = require(Avalog.Parent.ModelSquash)
local Fetch = require(Avalog.Parent.Fetch)

local BASE_URL = "http://localhost:3000"

local Cosmetics = {
	_ModelStorage = Instance.new("Folder"),
	_Models = {} :: { [string]: string },
}

function Cosmetics.Start(self: typeof(Cosmetics))
	self._ModelStorage.Name = "AVALOG_COSMETICS"
	self._ModelStorage.Parent = ReplicatedStorage

	local Model = self:GetModelAsync("135037445384022")
	print(Model)
end

function Cosmetics.GetModelAsync(self: typeof(Cosmetics), Id: string): Instance?
	local ExistingModel = self._ModelStorage:FindFirstChild(Id)
	if ExistingModel ~= nil then
		return ExistingModel
	end

	local Success, Response = Fetch(BASE_URL .. `/cosmetic/{Id}`, {}):Await()

	if Success and Response.Ok then
		local Success2, Result = pcall(function()
			return ModelSquash.Deserialize(buffer.fromstring(Response.Body))
		end)

		if Success2 then
			if typeof(Result) == "Instance" then
				Result.Name = Id
				Result.Parent = self._ModelStorage

				return Result
			else
				warn(`Returned model for cosmetic {Id} is not an Instance`)
			end
		else
			warn(Result)
		end
	else
		warn(Response)
	end
end

function Cosmetics.Destroy(_self: typeof(Cosmetics)) end

return Cosmetics
