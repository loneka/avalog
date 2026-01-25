local Avalog = script.Parent.Parent.Parent.Parent.Parent
local States = require(script.Parent.Parent.States)
local Fusion = require(Avalog.Parent.Fusion)
local Zap = require(Avalog.SourceCode.Shared.Zap.client)
local Future = require(Avalog.Parent.Future)
local Sift = require(Avalog.Parent.Sift)
local EnumSerDes = require(Avalog.Parent.EnumSerDes)

local Featured = {}

function Featured:FetchItems(Count: number?): boolean
	if Count == nil then
		Count = 3 * 10
	end

	local StartIndex = #Fusion.peek(States.Featured.Items)

	Future.Try(function()
		return Zap.GetFeaturedItems.Call(StartIndex, StartIndex + Count)
	end):After(function(Success, Result)
		if Success then
			if Result ~= nil then
				Featured:_AddEntries(EnumSerDes.DeserializeTree(Result), States.Featured.Items)

				return true
			end
		else
			warn(Result)
		end
	end)

	return false
end

function Featured:_AddEntries(Entries, EntriesState: Fusion.Value<Fusion.Scope<any>, any>)
	local EntriesValue = Fusion.peek(EntriesState)
	local WantedEntries = Sift.Array.difference(Entries, EntriesValue)

	for _, Entry in ipairs(WantedEntries) do
		table.insert(EntriesValue, Entry)
	end

	EntriesState:set(EntriesValue)
end

function Featured:Start()
	Zap.FeaturedItemsReset.SetCallback(function()
		States.Featured.Items:set({})
		Featured:FetchItems()
	end)
end

return Featured
