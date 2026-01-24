local Avalog = script.Parent.Parent.Parent.Parent.Parent
local OnyxUI = require(Avalog.Parent.OnyxUI)
local Fusion = require(Avalog.Parent.Fusion)
local CatalogSearch = require(Avalog.SourceCode.Client.UI.StateExtensions.CatalogSearch)
local AvatarAssetTypes = require(Avalog.SourceCode.Shared.AvatarAssetTypes)
local Featured = require(Avalog.SourceCode.Client.UI.StateExtensions.Featured)
local States = require(Avalog.SourceCode.Client.UI.States)
local Sift = require(Avalog.Parent.Sift)
local Config = require(Avalog.Config)

local Children = Fusion.Children

local ItemsTab = require(script.Parent.ItemsTab)

export type Props = ItemsTab.Props & {}

return function(Scope: Fusion.Scope<any>, Props: Props)
	local Scope = Fusion.innerScope(Scope, Fusion, OnyxUI.Util, OnyxUI.Components, {
		ItemButton = require(script.Parent.ItemButton),
		ItemsTab = require(script.Parent.ItemsTab),
		CustomButton = require(script.Parent.CustomButton),
	})
	local Theme = OnyxUI.Themer.Theme:now()

	local Shown = OnyxUI.Util.Fallback(Props.Shown, false)

	local Search = Scope:Value(nil)
	local CatalogResults = Scope:Value({})
	local CatalogResultItems = Scope:ForValues(CatalogResults, function(Use, Scope, Result)
		return {
			Id = Result.Id,
			Type = Enum.AvatarItemType[Result.ItemType],
		}
	end)

	local function UpdateCatalogSearch()
		if not Fusion.peek(Shown) then
			return
		end

		local SearchObject = CatalogSearch.Search({
			BundleTypes = {
				Enum.BundleType.Animations,
				Enum.BundleType.BodyParts,
				Enum.BundleType.DynamicHead,
				Enum.BundleType.DynamicHeadAvatar,
				Enum.BundleType.Shoes,
			},
			AssetTypes = AvatarAssetTypes.Types.All,
		})

		SearchObject.Updated:Connect(function()
			CatalogResults:set(SearchObject.Results)
		end)

		CatalogResults:set(SearchObject.Results)
		Search:set(SearchObject)
	end

	Scope:Observer(States.Open):onChange(function()
		UpdateCatalogSearch()
		Featured:FetchItems()
	end)

	local AdDisclaimerShown = Scope:Value(true)

	return Scope:ItemsTab(OnyxUI.Util.CombineProps(Props, {
		Name = script.Name,
		Items = Scope:Computed(function(Use)
			local FeaturedItemsValue = Use(States.Featured.Items)
			local CatalogResultItemsValue = Use(CatalogResultItems)
			local DeveloperFeaturedItems = Config:Get().Featured.Items

			return Sift.Array.merge(DeveloperFeaturedItems, FeaturedItemsValue, CatalogResultItemsValue)
		end),

		OnReachedEnd = function()
			task.spawn(function()
				Featured:FetchItems()
			end)

			local SearchValue = Fusion.peek(Search)
			if SearchValue ~= nil then
				SearchValue:LoadNextPage()
			end
		end,

		[Children] = {
			Scope:CustomButton {
				AutomaticSize = Enum.AutomaticSize.Y,
				Visible = AdDisclaimerShown,
				ListHorizontalAlignment = Enum.HorizontalAlignment.Left,

				OnActivated = function()
					AdDisclaimerShown:set(false)
				end,

				[Children] = {
					Scope:IconText {
						Content = { "rbxassetid://13848466137", "Contains exclusive, curated, and paid listings." },
						ListPadding = Scope:Computed(function(Use)
							return UDim.new(0, Use(Theme.Spacing["0.5"]))
						end),
						ListVerticalAlignment = Enum.VerticalAlignment.Center,
					},
				},
			},
		},
	}))
end
