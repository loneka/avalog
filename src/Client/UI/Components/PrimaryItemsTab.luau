local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local Avalog = script.Parent.Parent.Parent.Parent.Parent
local OnyxUI = require(Avalog.Parent.OnyxUI)
local Fusion = require(Avalog.Parent.Fusion)
local States = require(Avalog.SourceCode.Client.UI.States)
local Sift = require(Avalog.Parent.Sift)
local Config = require(Avalog.Config)

local CONFIG = Config:Get()
local CURATED_SHOWN = (not RunService:IsStudio()) and not (game.CreatorId == Players.LocalPlayer.UserId) -- Only show curated items when relevant

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

local Children = Fusion.Children

local CatalogItemsTab = require(script.Parent.CatalogItemsTab)

export type Props = CatalogItemsTab.Props & {}

return function(Scope: Fusion.Scope<any>, Props: Props)
	local Scope = Fusion.innerScope(Scope, Fusion, OnyxUI.Util, OnyxUI.Components, {
		ItemButton = require(script.Parent.ItemButton),
		CatalogItemsTab = CatalogItemsTab,
		CustomButton = require(script.Parent.CustomButton),
	})
	local Theme = OnyxUI.Themer.Theme:now()

	local CloudConfigLoaded = Scope:Computed(function(Use)
		return Use(States.CloudConfig).latestVersion ~= "0.0.0"
	end)

	return Scope:CatalogItemsTab(OnyxUI.Util.CombineProps(Props, {
		Name = script.Name,
		PrefixItems = Scope:Computed(function(Use)
			if CURATED_SHOWN then
				local PinnedItems = Use(States.CloudConfig).pinnedItems

				for _, Item in PinnedItems do
					Item.Id = tonumber(Item.itemId)
					Item.ItemType = Item.itemType
				end

				return Sift.Array.merge(CONFIG.Featured.Items, PinnedItems)
			end

			return {}
		end),
		LoadItems = CloudConfigLoaded,

		[Children] = {
			Scope:Computed(function(Use)
				local CloudConfigFailedValue = Use(CloudConfigLoaded)

				if CloudConfigFailedValue then
					return
				end

				return Scope:Card {
					BackgroundColor3 = Theme.Colors.Neutral.Main,
					ListEnabled = true,
					CornerRadius = Scope:Computed(function(Use)
						return UDim.new(0, Use(Theme.CornerRadius["1.5"]))
					end),

					[Children] = {
						Scope:Text {
							Text = "Avalog requires access to HTTP requests to function properly.",
						},
						Scope:TextInput {
							Text = "https://devforum.roblox.com/t/3513102/71",
							Color = Theme.Colors.BaseContent.Main,
							TextTransparency = 0,
							TextEditable = false,
						},
					},
				}
			end),
			Scope:Computed(function(Use)
				if CURATED_SHOWN then
					return Scope:CustomButton {
						AutomaticSize = Enum.AutomaticSize.Y,
						Visible = States.Featured.MessageShown,
						ListHorizontalAlignment = Enum.HorizontalAlignment.Left,

						OnActivated = function()
							States.Featured.MessageShown:set(false)
						end,

						[Children] = {
							Scope:IconText {
								Content = {
									"rbxassetid://13850331560",
									"Contains exclusive, curated, and sponsored listings.",
								},
								ListPadding = Scope:Computed(function(Use)
									return UDim.new(0, Use(Theme.Spacing["0.5"]))
								end),
								ListVerticalAlignment = Enum.VerticalAlignment.Center,
							},
						},
					}
				end
			end),
		},
	}))
end
