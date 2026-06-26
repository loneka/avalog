--[[
	Injects the upgraded model counterparts of Avalog Cosmetics.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Avalog = script.Parent.Parent.Parent

local ModelSquash = require(Avalog.Parent.ModelSquash)
local Fetch = require(Avalog.Parent.Fetch)
local Avatar = require(script.Parent.Avatar)
local Cloud = require(script.Parent.Cloud)

local UpgradeMeshParts = require(script.UpgradeMeshParts)
local PlayerOwnsAsset = require(Avalog.SourceCode.Shared.Utils.PlayerOwnsAsset)
local ApplyCosmetic = require(Avalog.SourceCode.Shared.Utils.ApplyCosmetic)
local AssetIdsFromAvatarData = require(Avalog.SourceCode.Shared.Utils.AssetIdsFromAvatarData)
local PlayerIsInGroup = require(Avalog.SourceCode.Shared.Utils.PlayerIsInGroup)

local BASE_URL = "http://localhost:3000"

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
		if not Player.Character then
			return
		end

		local AppliedAssetIds = AssetIdsFromAvatarData(Data)
		local CloudConfig = Cloud.Config.Data:Get()
		if CloudConfig and CloudConfig.cosmeticItems then
			for _, Cosmetic in CloudConfig.cosmeticItems do
				if Cosmetic.itemType == "Asset" and table.find(AppliedAssetIds, Cosmetic.itemId) ~= nil then
					if not Cosmetic.groupPurchase then
						if not PlayerOwnsAsset(Player, Cosmetic.itemId) then
							continue
						end
					elseif not PlayerIsInGroup(Player, Cosmetic.groupId) then
						continue
					end

					ApplyCosmetic(Player.Character, Cosmetic.itemId, self:GetModelAsync(Cosmetic.itemId))
				end
			end
		end
	end)

	-- Preload cosmetics
	Cloud.Config.Data:Observe(function(_, Data)
		if Data and Data.cosmeticItems then
			for _, Cosmetic in Data.cosmeticItems do
				task.spawn(function()
					local Model = nil :: Instance?
					while Model == nil do
						Model = self:GetModelAsync(Cosmetic.itemId)
						task.wait(10)
					end
				end)
			end
		end
	end)
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
