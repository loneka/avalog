--[[
	Injects the upgraded model counterparts of Avalog Cosmetics.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Avalog = script.Parent.Parent.Parent
local ModelSquash = require(Avalog.Parent.ModelSquash)
local Fetch = require(Avalog.Parent.Fetch)
local Avatar = require(script.Parent.Avatar)
local Cloud = require(script.Parent.Cloud)

local BASE_URL = "http://localhost:3000"

local function AssetIdsFromAvatarData(AvatarData): { string }
	local AssetIds = {
		AvatarData.Face,
	}

	for _, Accessory in AvatarData.Accessories do
		table.insert(AssetIds, Accessory.AssetId)
	end
	for _, AssetId in AvatarData.Clothing do
		table.insert(AssetIds, AssetId)
	end
	for _, EmoteAssetIds in AvatarData.Emotes do
		table.insert(AssetIds, EmoteAssetIds[1])
	end

	for Key, Value in AssetIds do
		AssetIds[Key] = tostring(Value)
	end

	return AssetIds
end

local Cosmetics = {
	_ModelStorage = Instance.new("Folder"),
}

function Cosmetics.Start(self: typeof(Cosmetics))
	self._ModelStorage.Name = "AVALOG_COSMETICS"
	self._ModelStorage.Parent = ReplicatedStorage

	-- Handle cosmetics in player avatars
	Avatar.DataAppliedToPlayer:Connect(function(Player, Data)
		local AppliedAssetIds = AssetIdsFromAvatarData(Data)
		local CosmeticItems = Cloud.Config.Data:Get().cosmeticItems

		for _, Cosmetic in CosmeticItems do
			if Cosmetic.itemType == "Asset" and table.find(AppliedAssetIds, Cosmetic.itemId) ~= nil then
				Cosmetics:ApplyCosmetic(Player, Cosmetic.itemId)
			end
		end
	end)
end

function Cosmetics.ApplyCosmetic(self: typeof(Cosmetics), Player: Player, Id: string)
	local Character = Player.Character
	if Character ~= nil then
		local Model = self:GetModelAsync(Id)
		if Model ~= nil then
			Model.Parent = Character
		end
	end
end

function Cosmetics.GetModelAsync(self: typeof(Cosmetics), Id: string): Instance?
	local ExistingModel = self._ModelStorage:FindFirstChild(Id)
	if ExistingModel ~= nil then
		return ExistingModel:Clone()
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

				return Result:Clone()
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

function Cosmetics.Destroy(_self: typeof(Cosmetics))
	_self._ModelStorage:Destroy()
end

return Cosmetics
