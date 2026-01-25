local AvatarEditorService = game:GetService("AvatarEditorService")

local Avalog = script.Parent.Parent.Parent.Parent.Parent
local Future = require(Avalog.Parent.Future)
local Signal = require(Avalog.Parent.Signal)
local CatalogItems = require(script.Parent.CatalogItems)

export type SearchParams = {
	SearchKeyword: string?,
	MinPrice: number?,
	MaxPrice: number?,
	SortType: Enum.CatalogSortType?,
	SortAggregation: Enum.CatalogSortAggregation?,
	CategoryFilter: Enum.CatalogCategoryFilter?,
	SalesTypeFilter: Enum.SalesTypeFilter?,
	BundleTypes: { Enum.BundleType }?,
	AssetTypes: { Enum.AvatarAssetType }?,
	IncludeOffSale: boolean?,
	CreatorName: string?,
	Limit: number?,
}

local CatalogSearch = {
	Searches = {},
}

function CatalogSearch.Search(Params: SearchParams)
	local Search = {
		Results = {},
		Pages = nil,
		Updated = Signal.new(),
	}

	function Search:LoadNextPage()
		return Future.Try(function()
			assert(self.Pages ~= nil, "Pages does not exist.")

			self.Pages:AdvanceToNextPageAsync()

			return self.Pages:GetCurrentPage()
		end):After(function(Success, Result)
			if Success and Result then
				self:_LoadPage(Result)
			end
		end)
	end

	function Search:_LoadPage(Page: { [number]: any })
		for _, Entry in ipairs(Page) do
			local Tables = {
				Asset = CatalogItems.KnownAssets,
				Bundle = CatalogItems.KnownBundles,
			}
			local AppropriateTable = Tables[Entry.ItemType]

			if AppropriateTable then
				local Item: CatalogItems.CatalogItem = {
					Id = Entry.Id,
					Name = Entry.Name,
					Price = Entry.Price,
					Offsale = Entry.IsOffSale,
					Type = Enum.AvatarItemType[Entry.ItemType],
					AssetType = (Entry.AssetType and Enum.AvatarAssetType[Entry.AssetType]) or nil,
				}

				AppropriateTable[Entry.Id] = Item
			end

			table.insert(self.Results, Entry)
		end

		self.Updated:Fire()
	end

	function Search:Destroy()
		self.Results = {}
		self.Updated:Destroy()

		if self.Pages ~= nil then
			self.Pages:Destroy()
		end
	end

	CatalogSearch.Pages(Params):After(function(Success, Result)
		if Success then
			Search.Pages = Result
			Search:_LoadPage(Result:GetCurrentPage())
		end
	end)

	return Search
end

function CatalogSearch.Pages(Params: SearchParams)
	local CatalogSearchParams = CatalogSearch.Params(Params)

	return Future.Try(function()
		return AvatarEditorService:SearchCatalog(CatalogSearchParams)
	end)
end

function CatalogSearch.Params(Params: SearchParams)
	local CatalogSearchParams = CatalogSearchParams.new()

	for Key, Value in pairs(Params) do
		CatalogSearchParams[Key] = Value
	end

	return CatalogSearchParams
end

function CatalogSearch:Stop()
	for Hash, Search in pairs(self.Searches) do
		Search:Destroy()
		self.Searches[Hash] = nil
	end
end

return CatalogSearch
