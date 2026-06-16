local Avalog = script.Parent.Parent.Parent.Parent.Parent

local OnyxUI = require(Avalog.Parent.OnyxUI)
local Fusion = require(Avalog.Parent.Fusion)

local States = require(Avalog.SourceCode.Client.UI.States)
local ServiceProvider = require(Avalog.SourceCode.Client.ServiceProvider)
local Manifest = require(Avalog.SourceCode.Shared.Manifest)

local PromoPopout = require(script.Parent.Parent.Components.PromoPopout)
local CatalogMenu = require(script.Parent.Parent.Components.CatalogMenu)
local AvatarViewport = require(script.Parent.Parent.Components.AvatarViewport)
local ItemDetails = require(script.Parent.Parent.Components.ItemDetails)

local Children = Fusion.Children

export type Props = {
	Parent: Fusion.UsedAs<Instance>?,
}

return function(Scope: Fusion.Scope<any>, Props: Props)
	local Scope = Fusion.innerScope(Scope, OnyxUI.Util, OnyxUI.Components, {
		CatalogMenu = CatalogMenu,
		AvatarViewport = AvatarViewport,
		PromoPopout = PromoPopout,
		ItemDetails = ItemDetails,
	})
	local Theme = OnyxUI.Themer.Theme:now()

	return Scope:New "ScreenGui" {
		Name = script.Name,
		Parent = Props.Parent,
		DisplayOrder = 9,
		Enabled = States.Open,

		[Children] = {
			Scope:New "ScreenGui" {
				Name = "Backdrop",
				DisplayOrder = 9 - 1,
				ScreenInsets = Enum.ScreenInsets.None,

				[Children] = {
					Scope:Frame {
						AnchorPoint = Vector2.new(0.5, 0.5),
						Position = UDim2.fromScale(0.5, 0.5),
						Size = UDim2.fromScale(1, 1),
						BackgroundColor3 = Theme.Colors.Base.Main,
						BackgroundTransparency = Scope:Spring(
							Scope:Computed(function(Use)
								return (Use(States.Open) and 0) or 1
							end),
							Theme.SpringSpeed["1.5"],
							Theme.SpringDampening["1.5"]
						),
						Active = States.Open,
						Interactable = States.Open,
					},
				},
			},
			Scope:Frame {
				Name = "Menu",
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = Scope:Spring(
					Scope:Computed(function(Use)
						if Use(States.Open) then
							return UDim2.fromScale(0.5, 0.5)
						else
							return UDim2.fromScale(0.5, 0.5) + UDim2.fromOffset(0, Use(Theme.Spacing["4"]))
						end
					end),
					Theme.SpringSpeed["0.5"],
					Theme.SpringDampening["1.5"]
				),
				Size = UDim2.fromScale(1, 1),
				AutomaticSize = Enum.AutomaticSize.None,
				ListEnabled = true,
				ListFillDirection = Enum.FillDirection.Horizontal,
				ListVerticalFlex = Enum.UIFlexAlignment.Fill,
				ListPadding = Scope:Computed(function(Use)
					return UDim.new(0, Use(Theme.Spacing["0"]))
				end),
				Active = States.Open,
				Interactable = States.Open,

				[Children] = {
					Scope:CatalogMenu {
						FlexMode = Enum.UIFlexMode.Fill,

						OnExit = function()
							States.Open:set(false)
						end,
					},
					Scope:Frame {
						Size = Scope:Computed(function(Use)
							return UDim2.fromOffset(Use(Theme.StrokeThickness["2"]), 0)
						end),
						BackgroundTransparency = 0,
						BackgroundColor3 = Theme.Colors.Neutral.Main,
					},
					Scope:Frame {
						FlexMode = Enum.UIFlexMode.Fill,
						MaxSize = Scope:Computed(function(Use)
							local ResolutionValue = Use(States.Screen.Resolution)

							if ResolutionValue.X < 800 then
								return Vector2.new(ResolutionValue.X / 2.5, math.huge)
							elseif ResolutionValue.X > 1000 then
								return Vector2.new(ResolutionValue.X / 3, math.huge)
							else
								return Vector2.new(16 * 24, math.huge)
							end
						end),
						AutomaticSize = Enum.AutomaticSize.X,
						ListEnabled = true,
						ListHorizontalFlex = Enum.UIFlexAlignment.Fill,
						ListVerticalFlex = Enum.UIFlexAlignment.Fill,

						[Children] = {
							Scope:AvatarViewport {
								Visible = Scope:Computed(function(Use)
									return not Use(States.ItemDetails.Open)
								end),
							},
							Scope:ItemDetails {
								Visible = States.ItemDetails.Open,
								ItemType = States.ItemDetails.ItemType,
								ItemId = States.ItemDetails.ItemId,
							},
						},
					},
				},
			},
			Scope:PromoPopout {
				Link = "devforum.roblox.com/t/3513102",
				Logo = "rbxassetid://93133319477541",
				UpdateAvailable = Scope:Computed(function(Use)
					return Manifest.Version ~= Use(States.CloudConfig).latestVersion
				end),
				AnchorPoint = Vector2.new(0, 1),
				Position = Scope:Computed(function(Use)
					return UDim2.fromScale(0, 1) + UDim2.fromOffset(Use(Theme.Spacing["1"]), -Use(Theme.Spacing["1"]))
				end),
			},
		},
	}
end
