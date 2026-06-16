--[[
	Handles client previews and purchase prompting of cosmetics
]]

local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")

local Avalog = script.Parent.Parent.Parent

local EnumSerDes = require(Avalog.Parent.EnumSerDes)
local Fusion = require(Avalog.Parent.Fusion)

local LocalAvatar = require(script.Parent.Avatar.LocalAvatar)
local AssetIdsFromAvatarData = require(Avalog.SourceCode.Shared.Utils.AssetIdsFromAvatarData)
local ApplyCosmetic = require(Avalog.SourceCode.Shared.Utils.ApplyCosmetic)
local States = require(Avalog.SourceCode.Client.UI.States)
local GetStoredCosmeticModel = require(Avalog.SourceCode.Shared.Utils.GetStoredCosmeticModel)
local PlayerOwnsAsset = require(Avalog.SourceCode.Shared.Utils.PlayerOwnsAsset)
local Zap = require(Avalog.SourceCode.Shared.Zap.client)

type BulkLineItem = {
	Type: Enum.MarketplaceProductType,
	Id: string,
}

local function GetCosmeticAssetIdsFromAvatarData()
	local CosmeticAssetIds = {}

	local Data = LocalAvatar.HumanoidDescriber:GetData()
	local AppliedAssetIds = AssetIdsFromAvatarData(Data)
	local CloudConfig = Fusion.peek(States.CloudConfig)

	if CloudConfig and CloudConfig.cosmeticItems then
		for _, Cosmetic in CloudConfig.cosmeticItems do
			if Cosmetic.itemType == "Asset" and table.find(AppliedAssetIds, Cosmetic.itemId) ~= nil then
				table.insert(CosmeticAssetIds, Cosmetic.itemId)
			end
		end
	end

	return CosmeticAssetIds
end
local function FilterAssetIdsByUnowned(AssetIds: { string }): { string }
	local UnownedAssetIds = {}

	for _, AssetId in AssetIds do
		if not PlayerOwnsAsset(Players.LocalPlayer, AssetId) then
			table.insert(UnownedAssetIds, AssetId)
		end
	end

	return UnownedAssetIds
end

local Cosmetics = {
	_Scope = Fusion.scoped(Fusion),
}

function Cosmetics.Start(_self: typeof(Cosmetics))
	-- Handle cosmetics on avatar update
	local UpdateListener: RBXScriptConnection? = nil
	LocalAvatar.Updated:Connect(function()
		if UpdateListener ~= nil then
			UpdateListener:Disconnect()
			UpdateListener = nil
		end

		UpdateListener = LocalAvatar.Humanoid.ApplyDescriptionFinished:Connect(function()
			local CosmeticAssetIds = GetCosmeticAssetIdsFromAvatarData()

			for _, AssetId in CosmeticAssetIds do
				ApplyCosmetic(LocalAvatar.Character, AssetId, GetStoredCosmeticModel(AssetId))
				LocalAvatar.Humanoid:BuildRigFromAttachments()
			end
		end)
	end)

	-- Prompt purchase for cosmetics on exit
	Cosmetics._Scope:Observer(States.Open):onChange(function()
		if not Players.LocalPlayer then
			return
		end

		if not Fusion.peek(States.Open) then
			local CosmeticAssetIds = GetCosmeticAssetIdsFromAvatarData()
			local UnownedAssetIds = FilterAssetIdsByUnowned(CosmeticAssetIds)

			if #UnownedAssetIds >= 1 then
				States.ItemDetails.ItemType:set(Enum.AvatarItemType.Asset)
				States.ItemDetails.ItemId:set(UnownedAssetIds[1])
				States.ItemDetails.Open:set(true)
			end
		end
	end)
end

function Cosmetics.Destroy(_self: typeof(Cosmetics)) end

return Cosmetics
