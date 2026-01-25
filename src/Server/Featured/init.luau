local HttpService = game:GetService("HttpService")

local Avalog = script.Parent.Parent.Parent
local EnumSerDes = require(Avalog.Parent.EnumSerDes)
local Sift = require(Avalog.Parent.Sift)
local Future = require(Avalog.Parent.Future)
local Fetch = require(Avalog.Parent.Fetch)
local Signal = require(Avalog.Parent.Signal)
local Stator = require(Avalog.Parent.Stator)
local Zap = require(Avalog.SourceCode.Shared.Zap.server)
local RateLimit = require(Avalog.Parent.RateLimit)

export type FeaturedListing = {
	TransactionHash: string,
	Bid: number,
	StartTime: number,
	EndTime: number,
	Power: number?,
}
export type FeaturedItem = FeaturedListing & {
	Id: number,
	ItemType: Enum.AvatarItemType,
}
export type FeaturedCreator = FeaturedListing & {
	Id: number,
	CreatorType: Enum.CreatorType,
}
export type FeaturedData = {
	Items: { FeaturedItem },
	Creators: { FeaturedCreator },
}

local function CamelToPascal(Dictionary: { [string]: any })
	return Sift.Dictionary.map(Dictionary, function(Value, Key)
		if typeof(Value) == "table" then
			Value = CamelToPascal(Value)
		end
		if typeof(Key) == "string" then
			Key = Key:gsub("(%l)(%w*)", function(a, b)
				return a:upper() .. b
			end)
		end

		return Value, Key
	end)
end

local GITHUB_REPO = "UseAvalog/Featured"
local UPDATE_DELAY = 30 * 60
local FAILED_UPDATE_DELAY = 1 * 60
local SECONDS_PER_DAY = 86400
local RATE_LIMITS = {
	GetFeaturedItems = RateLimit(1, 1),
}

local Featured = {
	LastUpdated = nil,
	Data = Stator({
		Items = {},
	}, {}),

	Updated = Signal.new(),
}

function Featured:GetItems(Start: number, End: number): { FeaturedItem }
	local Data = Featured.Data:Get()

	return Sift.Array.filter(Data.Items, function(_, Key)
		return Key > Start and Key < End
	end)
end

function Featured:SpawnUpdateLoop()
	return task.spawn(function()
		while true do
			local Success = Featured:Update()

			if Success then
				task.wait(UPDATE_DELAY)
			else
				task.wait(FAILED_UPDATE_DELAY)
			end
		end
	end)
end

function Featured:Update()
	local Success, Result = Featured:_FetchLatestVersion():Await()

	if Success then
		if (Result ~= nil) and (Result ~= Featured.LastUpdated) then
			local Success2, Result2 = Featured:_FetchLatestData():Await()

			if Success2 then
				Featured.Data:Update(function()
					return Result2
				end)

				Featured.LastUpdated = Result
				Featured.Updated:Fire(Result2)
				Zap.FeaturedItemsReset:FireAll()

				return true, Result2
			else
				warn(Result2)
				return false, Result2
			end
		end
	else
		warn(Result)
		return false, Result
	end
end

function Featured:_FetchLatestData()
	return Future.Try(function()
		local Success, Response =
			Fetch(`https://github.com/{GITHUB_REPO}/releases/latest/download/featured.json`):Await()

		if Success and Response.Ok then
			local Data = HttpService:JSONDecode(Response.Body)

			if typeof(Data) == "table" then
				return Featured.FixData(Data)
			end
		else
			warn(Response)
		end

		return {
			Items = {},
		}
	end)
end

function Featured:_FetchLatestVersion()
	return Future.Try(function()
		local Success, Response = Fetch(`https://api.github.com/repos/{GITHUB_REPO}/releases/latest`):Await()

		if Success and Response.Ok then
			local Body = HttpService:JSONDecode(Response.Body)
			if Body then
				return Body["published_at"]
			end
		else
			warn(Response)
		end

		return nil
	end)
end

function Featured:Start()
	Featured:SpawnUpdateLoop()

	Zap.GetFeaturedItems.SetCallback(function(Player: Player, Start: number, End: number): { Zap.FeaturedItem }?
		assert((End - Start) <= 3 * 10, `Client requested too many ({End - Start}) items`)

		if RATE_LIMITS.GetFeaturedItems(Player.UserId) then
			return EnumSerDes.SerializeTree(Featured:GetItems(Start, End))
		else
			return nil
		end
	end)
end

function Featured.FixData(Data: FeaturedData)
	Data = CamelToPascal(Data)

	for _, Item in ipairs(Data.Items) do
		Item.ItemType = Enum.AvatarItemType[Item.ItemType]
	end

	for _, Creator in ipairs(Data.Creators) do
		Creator.CreatorType = Enum.CreatorType[Creator.CreatorType]
	end

	for _, Item in ipairs(Data.Items) do
		Item.Power = Item.Bid / ((Item.EndTime - Item.StartTime) / SECONDS_PER_DAY)
	end

	for _, Creator in ipairs(Data.Creators) do
		Creator.Power = Creator.Bid / ((Creator.EndTime - Creator.StartTime) / SECONDS_PER_DAY)
	end

	Data.Items = Sift.Array.sort(Data.Items, function(ItemA, ItemB)
		return ItemA.Power > ItemB.Power
	end)
	Data.Creators = Sift.Array.sort(Data.Creators, function(CreatorA, CreatorB)
		return CreatorA.Power > CreatorB.Power
	end)

	return Data
end

return Featured
