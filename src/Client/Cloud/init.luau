--[[
	Handles ingestion and communication with Avalog Cloud.
]]

local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local Avalog = script.Parent.Parent.Parent
local States = require(Avalog.SourceCode.Client.UI.States)
local Fusion = require(Avalog.Parent.Fusion)
local Types = require(Avalog.SourceCode.Shared.Types)
local Zap: typeof(require(Avalog.SourceCode.Shared.Zap.client))? = nil

if RunService:IsRunning() then
	Zap = require(Avalog.SourceCode.Shared.Zap.client)
end

local MARKETPLACE_PRODUCT_TYPE_ITEM_TYPES = {
	[Enum.MarketplaceProductType.AvatarAsset] = "Asset",
	[Enum.MarketplaceProductType.AvatarBundle] = "Bundle",
}

-- For checking if an item was likely purchased through Avalog
local function IsItemEquipped(Id: string, Type: Types.ItemType)
	if Type == "Asset" then
		local AssetIds = Fusion.peek(States.Avatar.EquippedAssetIds)

		return table.find(AssetIds, tonumber(Id)) ~= nil
	elseif Type == "Bundle" then
		local BundleIds = Fusion.peek(States.Avatar.EquippedBundleIds)

		return table.find(BundleIds, tonumber(Id)) ~= nil
	end
end

local Cloud = {}

function Cloud.Start(_self: typeof(Cloud))
	-- Ingest Asset purchases
	MarketplaceService.PromptPurchaseFinished:Connect(function(Player, AssetId, WasPurchased)
		if not WasPurchased then
			return
		end
		if Player ~= Players.LocalPlayer then
			return
		end
		if not IsItemEquipped(AssetId, "Asset") then
			return
		end

		if Zap ~= nil then
			Zap.RecordPurchase.Fire({
				itemId = tostring(AssetId),
				itemType = "Asset",
			})
		end
	end)

	-- Ingest Bundle purchases
	MarketplaceService.PromptBulkPurchaseFinished:Connect(function(Player, Status, Result)
		if Player == Players.LocalPlayer and Status == Enum.MarketplaceBulkPurchasePromptStatus.Completed then
			for _, Item in Result.Items do
				if Item.status == Enum.MarketplaceItemPurchaseStatus.Success then
					local ItemType = MARKETPLACE_PRODUCT_TYPE_ITEM_TYPES[Item.type]

					if ItemType == nil then
						continue
					end
					if not IsItemEquipped(Item.id, ItemType) then
						continue
					end

					Zap.RecordPurchase.Fire({
						itemId = Item.id,
						itemType = ItemType,
					})
				end
			end
		end
	end)
end

function Cloud.Destroy(_self: typeof(Cloud)) end

return Cloud
