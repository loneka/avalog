local Avalog = script.Parent.Parent.Parent.Parent.Parent
local OnyxUI = require(Avalog.Parent.OnyxUI)
local Fusion = require(Avalog.Parent.Fusion)
local Config = require(Avalog.Config)
local States = require(Avalog.SourceCode.Client.UI.States)
local Categories = require(Avalog.SourceCode.Shared.Categories)

local Children = Fusion.Children

local CatalogItemsTab = require(script.Parent.CatalogItemsTab)
local SkinTab = require(script.Parent.SkinTab)
local BuildTab = require(script.Parent.BuildTab)
local EquippedItemsTab = require(script.Parent.EquippedItemsTab)
local InventoryItemsTab = require(script.Parent.InventoryItemsTab)
local FeaturedItemsTab = require(script.Parent.FeaturedItemsTab)

local TAB_COMPONENTS = {
	CatalogItemsTab = CatalogItemsTab,
	SkinTab = SkinTab,
	BuildTab = BuildTab,
	EquippedItemsTab = EquippedItemsTab,
	InventoryItemsTab = InventoryItemsTab,
	FeaturedItemsTab = FeaturedItemsTab,
}

export type Props = { [string]: any } & {}

return function(Scope: Fusion.Scope<any>, Props: Props)
	local Scope = Fusion.innerScope(Scope, Fusion, OnyxUI.Util, OnyxUI.Components, {
		CatalogItemsTab = CatalogItemsTab,
		SkinTab = SkinTab,
		BuildTab = BuildTab,
		EquippedItemsTab = EquippedItemsTab,
		InventoryItemsTab = InventoryItemsTab,
		FeaturedItemsTab = FeaturedItemsTab,
	})
	local Theme = OnyxUI.Themer.Theme:now()
	local Modes = Config:Get().EditModes

	local ActiveMode = Scope:Computed(function(Use)
		local ModeValue = Use(States.Catalog.Mode)
		return Modes[ModeValue]
	end)
	local ActiveCategory = Scope:Computed(function(Use)
		local ActiveModeValue = Use(ActiveMode)
		local CategoryValue = Use(States.Catalog.Category)

		return Categories[ActiveModeValue][CategoryValue]
	end)
	local ActiveTab = Scope:Computed(function(Use)
		local ActiveModeValue = Use(ActiveMode)
		local CategoryValue = Use(ActiveCategory)

		if ActiveModeValue == "Marketplace" then
			if CategoryValue.Name == "Featured" then
				return "FeaturedItemsTab"
			else
				return "CatalogItemsTab"
			end
		elseif ActiveModeValue == "Inventory" then
			return "InventoryItemsTab"
		elseif ActiveModeValue == "Customize" then
			if CategoryValue and CategoryValue.Name then
				if CategoryValue.Name == "Skin" then
					return "SkinTab"
				elseif CategoryValue.Name == "Build" then
					return "BuildTab"
				elseif CategoryValue.Name == "Equipped" then
					return "EquippedItemsTab"
				end
			end
		end

		return nil
	end)

	return Scope:Frame(OnyxUI.Util.CombineProps(Props, {
		Name = "Tab",
		FlexMode = Enum.UIFlexMode.Fill,
		Padding = Scope:Computed(function(Use)
			return UDim.new(0, Use(Theme.Spacing["1"]))
		end),
		ListEnabled = true,
		ListHorizontalFlex = Enum.UIFlexAlignment.Fill,
		ListVerticalFlex = Enum.UIFlexAlignment.Fill,
		ClipsDescendants = true,

		[Children] = {
			-- Only render the active tab
			Scope:Computed(function(Use, Scope)
				local TabComponent = TAB_COMPONENTS[Use(ActiveTab)]

				if TabComponent then
					return TabComponent(Scope, {
						Shown = true,
					})
				end
			end),
		},
	}))
end
