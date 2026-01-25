local AvatarEditorService = game:GetService("AvatarEditorService")

local Avalog = script.Parent.Parent.Parent.Parent.Parent
local OnyxUI = require(Avalog.Parent.OnyxUI)
local Fusion = require(Avalog.Parent.Fusion)
local Navigation = require(Avalog.SourceCode.Client.UI.StateExtensions.Navigation)
local States = require(Avalog.SourceCode.Client.UI.States)
local Inventory = require(Avalog.SourceCode.Client.UI.StateExtensions.Inventory)

export type Props = {
	Shown: Fusion.UsedAs<boolean>?,
}

return function(Scope: Fusion.Scope<any>, Props: Props)
	local Scope = Fusion.innerScope(Scope, Fusion, OnyxUI.Util, OnyxUI.Components, {
		ItemsTab = require(script.Parent.ItemsTab),
	})

	local Shown = OnyxUI.Util.Fallback(Props.Shown, false)

	local DeepestCategory = Scope:Computed(function(Use)
		local CategoryValue = Use(Navigation.Category)
		local SubCategoryValue = Use(Navigation.SubCategory)

		if SubCategoryValue ~= nil then
			return SubCategoryValue
		else
			return CategoryValue
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

	local Search = Scope:Value(nil)
	local Results = Scope:Value({})

	local function UpdateSearch()
		if not Fusion.peek(Shown) then
			return
		end
		if not Fusion.peek(States.Inventory.AccessAllowed) then
			return
		end

		local AssetTypesValue = Fusion.peek(AssetTypes)

		local SearchObject = Inventory.Search(AssetTypesValue)

		SearchObject.Updated:Connect(function()
			Results:set(SearchObject.Results)
		end)

		Search:set(SearchObject)
		Results:set(SearchObject.Results)
	end
	Scope:Observer(AssetTypes):onChange(function()
		UpdateSearch()
	end)
	Scope:Observer(States.Inventory.AccessAllowed):onChange(function()
		UpdateSearch()
	end)
	UpdateSearch()

	local ShownResults = Scope:ForValues(Results, function(Use, Scope, Result)
		local SearchQueryValue = Use(States.Catalog.SearchQuery)

		if
			(utf8.len(SearchQueryValue) > 0)
			and (string.find(string.lower(Result.Name), string.lower(SearchQueryValue), 1, true) == nil)
		then
			return nil
		else
			return Result
		end
	end)

	Scope:Observer(Shown):onChange(function()
		local ShownValue = Fusion.peek(Shown)
		local AccessAllowedValue = Fusion.peek(States.Inventory.AccessAllowed)

		if ShownValue and not AccessAllowedValue then
			AvatarEditorService:PromptAllowInventoryReadAccess()
		end
	end)
	AvatarEditorService.PromptAllowInventoryReadAccessCompleted:Connect(function(Result)
		local ShownValue = Fusion.peek(Shown)
		local ModeValue = Fusion.peek(States.Catalog.Mode)

		if ShownValue and (Result ~= Enum.AvatarPromptResult.Success) then
			States.Catalog.Mode:set(ModeValue + 1)
		end
	end)

	return Scope:ItemsTab(OnyxUI.Util.CombineProps(Props, {
		Name = script.Name,
		Items = Scope:ForValues(ShownResults, function(Use, Scope, Result)
			return {
				Id = Result.AssetId,
				Type = Enum.AvatarItemType.Asset,
				Owned = true,
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
