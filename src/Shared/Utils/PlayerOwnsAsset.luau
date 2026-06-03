local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")

local SavedResults = {} :: { [number]: {
	[number]: boolean,
} }

local function GetEntry(Player: Player)
	if SavedResults[Player.UserId] == nil then
		SavedResults[Player.UserId] = {}
	end

	return SavedResults[Player.UserId]
end

--[[
	Checks if the given `Player` owns `AssetId`. Reuses results to reduce API usage.
]]
local function PlayerOwnsAsset(Player: Player, AssetId: number)
	local Entry = GetEntry(Player)

	if Entry[AssetId] ~= nil then
		return Entry[AssetId]
	else
		local OwnsAsset = MarketplaceService:PlayerOwnsAssetAsync(Player, AssetId)
		Entry[AssetId] = OwnsAsset
		return OwnsAsset
	end
end

MarketplaceService.PromptPurchaseFinished:Connect(function(Player, AssetId, Purchased)
	if Purchased then
		local Entry = GetEntry(Player)
		Entry[AssetId] = true
	end
end)

Players.PlayerRemoving:Connect(function(Player)
	SavedResults[Player.UserId] = nil
end)

return PlayerOwnsAsset
