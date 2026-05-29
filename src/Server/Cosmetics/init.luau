--[[
	Injects the upgraded model counterparts of Avalog Cosmetics.
]]

local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Avalog = script.Parent.Parent.Parent
local ModelSquash = require(Avalog.Parent.ModelSquash)
local Fetch = require(Avalog.Parent.Fetch)
local Avatar = require(script.Parent.Avatar)
local Cloud = require(script.Parent.Cloud)
local UpgradeMeshParts = require(script.UpgradeMeshParts)

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
local function IsCosmeticApplied(Character: Model, Id: string)
	for _, Descendant in Character:GetDescendants() do
		if Descendant:GetAttribute("CosmeticId") == Id then
			return true
		end
	end

	return false
end
local function UpgradeDescendantMeshParts(Model: Instance)
	local MeshParts = {}

	for _, Descendant in Model:GetDescendants() do
		if Descendant:IsA("MeshPart") then
			table.insert(MeshParts, Descendant)
		end
	end

	return UpgradeMeshParts(MeshParts)
end

local Cosmetics = {
	_ModelStorage = Instance.new("Folder"),
}

function Cosmetics.Start(self: typeof(Cosmetics))
	self._ModelStorage.Name = "AVALOG_COSMETICS"
	self._ModelStorage.Parent = ReplicatedStorage

	-- Handle cosmetics for player avatars
	Avatar.DataAppliedToPlayer:Connect(function(Player, Data)
		local AppliedAssetIds = AssetIdsFromAvatarData(Data)
		local CloudConfig = Cloud.Config.Data:Get()
		if CloudConfig and CloudConfig.cosmeticItems then
			for _, Cosmetic in CloudConfig.cosmeticItems do
				if Cosmetic.itemType == "Asset" and table.find(AppliedAssetIds, Cosmetic.itemId) ~= nil then
					Cosmetics:ApplyCosmetic(Player, Cosmetic.itemId)
				end
			end
		end
	end)
end

function Cosmetics.ApplyCosmetic(self: typeof(Cosmetics), Player: Player, Id: string): true?
	local Character = Player.Character
	if Character ~= nil then
		if IsCosmeticApplied(Character, Id) then
			return
		end

		local Model = self:GetModelAsync(Id)
		if Model ~= nil then
			local InjectionType = Model:GetAttribute("InjectionType")
			if InjectionType == "Accessory" then
				if not Model:IsA("Accessory") then
					warn(`Cosmetic model {Id} has Accessory InjectionType but is not an accessory.`)
					return
				end

				local Humanoid = Character:FindFirstChildOfClass("Humanoid")
				if Humanoid ~= nil then
					Humanoid:AddAccessory(Model)
					return true
				end
			elseif InjectionType == "Path" then
				local InjectionPath = Model:GetAttribute("InjectionPath")
				if typeof(InjectionPath) == "string" then
					local InjectionPathArray = HttpService:JSONDecode(InjectionPath)
					if typeof(InjectionPathArray) == "table" then
						local Descendant = Character :: Instance

						for _, PathStep in InjectionPathArray do
							local NewDescendant = Descendant:FindFirstChild(PathStep)
							if NewDescendant == nil then
								warn(`Cosmetic {Id}'s InjectionPath could not be resolved.`)
								return
							else
								Descendant = NewDescendant
							end
						end

						Model.Parent = Descendant
						return true
					end
				end
			else
				warn(`Cosmetic {Id} has an invalid or missing InjectionType.`)
			end
		else
			warn(`Model could not be found for cosmetic {Id}.`)
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
				UpgradeDescendantMeshParts(Result)

				Result.Name = Id
				Result:SetAttribute("CosmeticId", Id)
				Result.Parent = self._ModelStorage

				return Result:Clone()
			else
				warn(`Returned model for cosmetic {Id} is not an Instance`)
			end
		else
			warn(`Issue during cosmetic {Id} deserialization:`, Result)
		end
	else
		warn(Response)
	end
end

function Cosmetics.Destroy(_self: typeof(Cosmetics))
	_self._ModelStorage:Destroy()
end

return Cosmetics
