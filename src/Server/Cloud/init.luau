--[[
	Handles interaction with external cloud APIs.
]]

local MarketplaceService = game:GetService("MarketplaceService")
local RunService = game:GetService("RunService")

local Avalog = script.Parent.Parent.Parent
local Zap = require(Avalog.SourceCode.Shared.Zap.server)
local Fetch = require(Avalog.Parent.Fetch)
local RateLimit = require(Avalog.Parent.RateLimit)
local Stator = require(Avalog.Parent.Stator)
local Types = require(Avalog.SourceCode.Shared.Types)

local BASE_URL = "http://loneka.com/api/v1/avalog"
local UPDATE_DELAY = 30 * 60
local FAILED_UPDATE_DELAY = 1 * 60
local RATE_LIMITS = {
	GetCloudConfig = RateLimit(1, 10),
}
local ITEM_TYPE_INFO_TYPES = {
	Asset = Enum.InfoType.Asset,
	Bundle = Enum.InfoType.Bundle,
}

local function GetItemPriceInRobux(Id: string, Type: Types.ItemType): number
	local ProductInfo = MarketplaceService:GetProductInfoAsync(Id, ITEM_TYPE_INFO_TYPES[Type])

	if ProductInfo ~= nil then
		return ProductInfo.PriceInRobux or 0
	end

	return 0
end

local Cloud = {
	HttpEnabled = false,
	Config = {
		Data = Stator(),
	},
}

function Cloud.Start(self: typeof(Cloud))
	-- Initial HTTP ability check
	self:IsHttpEnabled()

	-- Periodically update cloud config
	task.spawn(function()
		while true do
			local Success = self:UpdateConfig()

			if Success then
				task.wait(UPDATE_DELAY)
			else
				task.wait(FAILED_UPDATE_DELAY)
			end
		end
	end)

	-- Serve cloud config upon client request
	Zap.GetCloudConfig.SetCallback(function(Player)
		if RATE_LIMITS.GetCloudConfig(Player) then
			return Cloud.Config.Data:Get()
		end
	end)

	-- Ingest item sales
	Zap.RecordPurchase.SetCallback(function(Player, Item)
		-- Don't record mock transactions from Roblox Studio
		if RunService:IsStudio() then
			return
		end

		if Item.itemType == "Asset" then
			if MarketplaceService:PlayerOwnsAssetAsync(Player, Item.itemId) then
				Cloud:RecordItemSale(Player, Item)
			end
		elseif Item.itemType == "Bundle" then
			if MarketplaceService:PlayerOwnsBundleAsync(Player, Item.itemId) then
				Cloud:RecordItemSale(Player, Item)
			end
		end
	end)
end

function Cloud.IsHttpEnabled(self: typeof(Cloud))
	local Success = self:UpdateConfig()

	self.HttpEnabled = Success

	return Success
end

function Cloud.UpdateConfig(_self: typeof(Cloud))
	local Success, Response = Fetch(BASE_URL .. "/app-config", {
		Headers = {
			["Experience-Id"] = tostring(game.GameId),
			["Place-Id"] = tostring(game.PlaceId),
		},
	}):Await()

	if Success and Response.Ok then
		local DecodeSuccess, Data = Response:Json()

		if DecodeSuccess then
			Cloud.Config.Data:Update(function()
				return Data
			end)

			Zap.CloudConfigReset.FireAll()
		end
	else
		warn(Response)
	end

	return Success, Response
end

function Cloud.RecordItemSale(_self: typeof(Cloud), Player: Player, Item: Types.Item)
	local ItemSale: Types.ItemSale = {
		experienceId = tostring(game.GameId),
		itemId = Item.itemId,
		itemType = Item.itemType,
		jobId = game.JobId,
		robuxPrice = GetItemPriceInRobux(Item.itemId, Item.itemType),
		unitsSold = 1,
	}

	Fetch(BASE_URL .. "/sale", {
		Method = "POST",
		Body = ItemSale,
	}):After(function(Success, Response)
		if not Success or not Response.Ok then
			warn(Response:Json())
		end
	end)
end

function Cloud.Destroy(_self: typeof(Cloud)) end

return Cloud
