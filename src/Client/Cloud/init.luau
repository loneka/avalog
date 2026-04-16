--[[
	Handles ingestion and communication with Avalog Cloud.
]]

local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")

local Avalog = script.Parent.Parent.Parent
local Zap = require(Avalog.SourceCode.Shared.Zap.client)

local MARKETPLACE_PRODUCT_TYPE_ITEM_TYPES = {
	[Enum.MarketplaceProductType.AvatarAsset] = "Asset",
	[Enum.MarketplaceProductType.AvatarBundle] = "Bundle",
}

local Cloud = {}

function Cloud.Start(_self: typeof(Cloud))
	-- Ingest Asset purchases
	MarketplaceService.PromptPurchaseFinished:Connect(function(Player, AssetId, WasPurchased)
		if Player == Players.LocalPlayer and WasPurchased then
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
					if ItemType ~= nil then
						Zap.RecordPurchase.Fire({
							itemId = Item.id,
							itemType = ItemType,
						})
					end
				end
			end
		end
	end)
end

function Cloud.Destroy(_self: typeof(Cloud)) end

return Cloud
