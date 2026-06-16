local AssetService = game:GetService("AssetService")
local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")

local Avalog = script.Parent.Parent.Parent.Parent.Parent
local Future = require(Avalog.Parent.Future)
local AssetTypeFromId = require(Avalog.SourceCode.Shared.Utils.AssetTypeFromId)

export type CatalogItem = {
	Id: number,
	Name: string,
	Type: Enum.AvatarItemType,
	AssetType: Enum.AvatarAssetType?,
	Price: number,
	Offsale: boolean,
	Description: string,
	Creator: {
		Id: number,
		Type: string,
		Name: string,
		Verified: boolean,
	},
}

local INFO_TYPE_TABLES = {
	[Enum.InfoType.Asset] = "KnownAssets",
	[Enum.InfoType.Bundle] = "KnownBundles",
}
local INFO_TYPE_AVATAR_ITEM_TYPES = {
	[Enum.InfoType.Asset] = Enum.AvatarItemType.Asset,
	[Enum.InfoType.Bundle] = Enum.AvatarItemType.Bundle,
}

local CatalogItems = {
	KnownAssets = {},
	KnownBundles = {},
	OwnedAssets = {},
	OwnedBundles = {},
	BundleDetails = {},
	BundleAssets = {},
}

function CatalogItems:GetBundleIdFromAsset(AssetId: number)
	for BundleId, AssetIds in pairs(self.BundleAssets) do
		if table.find(AssetIds, AssetId) ~= nil then
			return BundleId
		end
	end

	return nil
end

function CatalogItems:GetBundle(BundleId: number)
	if self.BundleDetails[BundleId] == nil then
		local Success, Result = Future.Try(function()
			return AssetService:GetBundleDetailsAsync(BundleId)
		end):Await()

		if Success then
			self.BundleAssets[BundleId] = {}
			for _, Item in ipairs(Result.Items) do
				if Item.Type == "Asset" then
					table.insert(self.BundleAssets[BundleId], Item.Id)
				end
			end

			self.BundleDetails[BundleId] = Result
		end
	end

	return self.BundleDetails[BundleId]
end

function CatalogItems:OwnsItem(Id: number, Type: Enum.AvatarItemType)
	local ItemTypeTables = {
		[Enum.AvatarItemType.Asset] = self.OwnedAssets,
		[Enum.AvatarItemType.Bundle] = self.OwnedBundles,
	}
	local RelevantTable = ItemTypeTables[Type]

	if RelevantTable then
		if table.find(RelevantTable, Id) == nil then
			local Success, Result = Future.Try(function()
				if Type == Enum.AvatarItemType.Asset then
					return MarketplaceService:PlayerOwnsAsset(Players.LocalPlayer, Id)
				elseif Type == Enum.AvatarItemType.Bundle then
					return MarketplaceService:PlayerOwnsBundle(Players.LocalPlayer, Id)
				else
					return nil
				end
			end):Await()
			if Success and Result then
				table.insert(RelevantTable, Id)
			end
		end

		return table.find(RelevantTable, Id) ~= nil
	end

	return false
end

function CatalogItems:GetItem(Id: number, InfoType: Enum.InfoType): CatalogItem?
	local RelevantTable = self[INFO_TYPE_TABLES[InfoType]]
	local AvatarItemType = INFO_TYPE_AVATAR_ITEM_TYPES[InfoType]

	local ExistingEntry = self:GetExistingItem(Id, InfoType)

	if ExistingEntry then
		return ExistingEntry
	else
		local Success, Result = Future.Try(function()
			return MarketplaceService:GetProductInfo(Id, InfoType)
		end):Await()
		if Success then
			local Item = {
				Id = Result.AssetId,
				Name = Result.Name,
				Price = Result.PriceInRobux,
				Type = AvatarItemType,
				AssetType = AssetTypeFromId(Result.AssetTypeId),
				Offsale = not Result.IsForSale,
				Description = Result.Description,
				Creator = {
					Id = Result.Creator.CreatorTargetId,
					Type = Result.Creator.CreatorType,
					Name = Result.Creator.Name,
					Verified = Result.Creator.HasVerifiedBadge,
				},
			}

			RelevantTable[Id] = Item
			return Item
		end
	end

	return nil
end

function CatalogItems:GetExistingItem(Id: number, InfoType: Enum.InfoType): CatalogItem?
	local RelevantTable = self[INFO_TYPE_TABLES[InfoType]]
	local AvatarItemType = INFO_TYPE_AVATAR_ITEM_TYPES[InfoType]

	if RelevantTable and AvatarItemType then
		local KnownEntry = RelevantTable[Id]
		if KnownEntry then
			return KnownEntry
		end
	end

	return nil
end

return CatalogItems
