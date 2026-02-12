local RunService = game:GetService("RunService")

local Avalog = script.Parent.Parent.Parent.Parent.Parent
local OnyxUI = require(Avalog.Parent.OnyxUI)
local Fusion = require(Avalog.Parent.Fusion)
local Featured = require(Avalog.SourceCode.Client.UI.StateExtensions.Featured)
local States = require(Avalog.SourceCode.Client.UI.States)
local Sift = require(Avalog.Parent.Sift)
local Config = require(Avalog.Config)

local CONFIG = Config:Get()

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

	Scope:Observer(States.Open):onChange(function()
		local OpenValue = Fusion.peek(States.Open)

		if OpenValue == true then
			Featured:FetchItems()
		end
	end)

	local AdDisclaimerShown = Scope:Value(true)

	return Scope:CatalogItemsTab(OnyxUI.Util.CombineProps(Props, {
		Name = script.Name,
		PrefixItems = Scope:Computed(function(Use)
			if not RunService:IsStudio() then
				local FeaturedItemsValue = Use(States.Featured.Items)

				return Sift.Array.merge(CONFIG.Featured.Items, FeaturedItemsValue)
			end

			return {}
		end),

		OnReachedEnd = function()
			task.spawn(function()
				Featured:FetchItems()
			end)
		end,

		[Children] = {
			Scope:Computed(function(Use)
				if not RunService:IsStudio() then
					return Scope:CustomButton {
						AutomaticSize = Enum.AutomaticSize.Y,
						Visible = AdDisclaimerShown,
						ListHorizontalAlignment = Enum.HorizontalAlignment.Left,

						OnActivated = function()
							AdDisclaimerShown:set(false)
						end,

						[Children] = {
							Scope:IconText {
								Content = {
									"rbxassetid://13848466137",
									"Contains exclusive, curated, and paid listings.",
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
