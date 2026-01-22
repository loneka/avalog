local Avalog = script.Parent.Parent.Parent.Parent.Parent
local OnyxUI = require(Avalog.Parent.OnyxUI)
local Fusion = require(Avalog.Parent.Fusion)
local Config = require(Avalog.Config)
local States = require(Avalog.SourceCode.Client.UI.States)
local Categories = require(Avalog.SourceCode.Shared.Categories)

local Children = Fusion.Children

export type Props = { [string]: any } & {}

return function(Scope: Fusion.Scope<any>, Props: Props)
	local Scope = Fusion.innerScope(Scope, Fusion, OnyxUI.Util, OnyxUI.Components, {
		CatalogItemsTab = require(script.Parent.CatalogItemsTab),
		SkinTab = require(script.Parent.SkinTab),
		BuildTab = require(script.Parent.BuildTab),
		EquippedItemsTab = require(script.Parent.EquippedItemsTab),
		InventoryItemsTab = require(script.Parent.InventoryItemsTab),
		FeaturedItemsTab = require(script.Parent.FeaturedItemsTab),
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
			Scope:FeaturedItemsTab {
				Shown = Scope:Computed(function(Use)
					local ActiveTabValue = Use(ActiveTab)
					return ActiveTabValue == "FeaturedItemsTab"
				end),
			},
			Scope:CatalogItemsTab {
				Shown = Scope:Computed(function(Use)
					local ActiveTabValue = Use(ActiveTab)
					return ActiveTabValue == "CatalogItemsTab"
				end),
			},
			Scope:InventoryItemsTab {
				Shown = Scope:Computed(function(Use)
					local ActiveTabValue = Use(ActiveTab)
					return ActiveTabValue == "InventoryItemsTab"
				end),
			},
			Scope:EquippedItemsTab {
				Shown = Scope:Computed(function(Use)
					local ActiveTabValue = Use(ActiveTab)
					return ActiveTabValue == "EquippedItemsTab"
				end),
			},
			Scope:SkinTab {
				Shown = Scope:Computed(function(Use)
					local ActiveTabValue = Use(ActiveTab)
					return ActiveTabValue == "SkinTab"
				end),
			},
			Scope:BuildTab {
				Shown = Scope:Computed(function(Use)
					local ActiveTabValue = Use(ActiveTab)
					return ActiveTabValue == "BuildTab"
				end),
			},
		},
	}))
end
