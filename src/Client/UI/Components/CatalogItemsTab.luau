local Avalog = script.Parent.Parent.Parent.Parent.Parent
local OnyxUI = require(Avalog.Parent.OnyxUI)
local Fusion = require(Avalog.Parent.Fusion)
local CatalogSearch = require(Avalog.SourceCode.Client.UI.StateExtensions.CatalogSearch)
local Navigation = require(Avalog.SourceCode.Client.UI.StateExtensions.Navigation)
local States = require(Avalog.SourceCode.Client.UI.States)
local Sift = require(Avalog.Parent.Sift)

export type Props = {
	PrefixItems: Fusion.UsedAs<{ [string]: any }>?,
	Shown: Fusion.UsedAs<boolean>?,
}

return function(Scope: Fusion.Scope<any>, Props: Props)
	local Scope = Fusion.innerScope(Scope, Fusion, OnyxUI.Util, OnyxUI.Components, {
		ItemsTab = require(script.Parent.ItemsTab),
	})

	local Shown = OnyxUI.Util.Fallback(Props.Shown, false)
	local PrefixItems = OnyxUI.Util.Fallback(Props.PrefixItems, {})

	local DeepestCategory = Scope:Computed(function(Use)
		local CategoryValue = Use(Navigation.Category)
		local SubCategoryValue = Use(Navigation.SubCategory)

		if SubCategoryValue ~= nil then
			return SubCategoryValue
		else
			return CategoryValue
		end
	end)
	local BundleTypes = Scope:Computed(function(Use)
		local DeepestCategoryValue = Use(DeepestCategory)

		if DeepestCategoryValue and DeepestCategoryValue.BundleTypes then
			return DeepestCategoryValue.BundleTypes
		else
			return {}
		end
	end)
	local AssetTypes = Scope:Computed(function(Use)
		local DeepestCategoryValue = Use(DeepestCategory)

		if DeepestCategoryValue and DeepestCategoryValue.AssetTypes then
			return DeepestCategoryValue.AssetTypes
		else
			return {}
		end
	end)
	local SearchQuery = Scope:Computed(function(Use)
		local SearchQueryValue = Use(States.Catalog.SearchQuery)
		local SearchingValue = Use(States.Catalog.Searching)

		return (SearchingValue and SearchQueryValue) or nil
	end)

	local Search = Scope:Value(nil)
	local Results = Scope:Value({})

	local function UpdateSearch()
		if not Fusion.peek(Shown) then
			return
		end

		local BundleTypesValue = Fusion.peek(BundleTypes)
		local AssetTypesValue = Fusion.peek(AssetTypes)
		local SearchQueryValue = Fusion.peek(SearchQuery)
		local DeepestCategoryValue = Fusion.peek(DeepestCategory)

		local Searching = string.len((SearchQueryValue or "")) == 0

		local SearchObject = CatalogSearch.Search({
			BundleTypes = BundleTypesValue,
			AssetTypes = AssetTypesValue,
			SearchKeyword = SearchQueryValue,
			CategoryFilter = (Searching and DeepestCategoryValue.CategoryFilter) or nil,
		})

		SearchObject.Updated:Connect(function()
			Results:set(SearchObject.Results)
		end)

		Search:set(SearchObject)
		Results:set(SearchObject.Results)
	end
	Scope:Observer(BundleTypes):onChange(function()
		UpdateSearch()
	end)
	Scope:Observer(AssetTypes):onChange(function()
		UpdateSearch()
	end)
	Scope:Observer(SearchQuery):onChange(function()
		UpdateSearch()
	end)
	UpdateSearch()

	local CombinedItems = Scope:Computed(function(Use)
		local ResultsValue = Use(Results)
		local PrefixItemsValue = Use(PrefixItems)
		local SearchQueryValue = Use(SearchQuery)

		if (SearchQueryValue == nil) or (SearchQueryValue == "") then
			return Sift.Array.concat(PrefixItemsValue, ResultsValue)
		else
			return ResultsValue
		end
	end)

	return Scope:ItemsTab(OnyxUI.Util.CombineProps(Props, {
		Name = script.Name,
		Items = Scope:ForValues(CombinedItems, function(Use, Scope, Item)
			if typeof(Item.ItemType) == "string" then
				Item.ItemType = Enum.AvatarItemType[Item.ItemType]
			end

			return {
				Id = Item.Id,
				Type = Item.ItemType,
			}
		end),

		OnReachedEnd = function()
			local SearchValue = Fusion.peek(Search)

			if SearchValue ~= nil then
				SearchValue:LoadNextPage()
			end
		end,
	}))
end
