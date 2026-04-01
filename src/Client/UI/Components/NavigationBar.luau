local Avalog = script.Parent.Parent.Parent.Parent.Parent
local OnyxUI = require(Avalog.Parent.OnyxUI)
local Fusion = require(Avalog.Parent.Fusion)
local Config = require(Avalog.Config)
local States = require(Avalog.SourceCode.Client.UI.States)
local IconSwap = require(script.Parent.IconSwap)
local Tabs = require(script.Parent.Tabs)
local CategoryBar = require(script.Parent.CategoryBar)
local Sift = require(Avalog.Parent.Sift)

local Children = Fusion.Children

local CONFIG = Config:Get()
local EDIT_MODE_ICONS = {
	Marketplace = "rbxassetid://13846120661",
	Inventory = "rbxassetid://13846738861",
	Customize = "rbxassetid://13846852950",
}

export type Props = { [string]: any } & {
	OnExit: () -> (),
}
return function(Scope: Fusion.Scope<any>, Props: Props)
	local Scope = Fusion.innerScope(Scope, Fusion, OnyxUI.Util, OnyxUI.Components, {
		Tabs = Tabs,
		CategoryBar = CategoryBar,
		IconSwap = IconSwap,
	})
	local Theme = OnyxUI.Themer.Theme:now()
	local Modes = Config:Get().EditModes

	local SearchBarText = Scope:Value("")

	return Scope:Frame(OnyxUI.Util.CombineProps(Props, {
		Name = script.Name,
		BackgroundColor3 = Theme.Colors.Base.Main,
		BackgroundTransparency = 0,
		ListEnabled = true,
		ListFillDirection = Enum.FillDirection.Horizontal,
		ListHorizontalFlex = Enum.UIFlexAlignment.Fill,

		[Children] = {
			Scope:Frame {
				ListEnabled = true,
				ListFillDirection = Enum.FillDirection.Horizontal,
				ListHorizontalAlignment = Enum.HorizontalAlignment.Center,
				ListVerticalAlignment = Enum.VerticalAlignment.Center,
				AutomaticSize = Enum.AutomaticSize.Y,
				Padding = Scope:Computed(function(Use)
					return UDim.new(0, Use(Theme.Spacing["0.25"]))
				end),
				PaddingTop = Scope:Computed(function(Use)
					return UDim.new(0, Use(Theme.Spacing["0.75"]))
				end),

				[Children] = {
					Scope:IconSwap {
						Options = Sift.Array.map(CONFIG.EditModes, function(EditMode)
							return EDIT_MODE_ICONS[EditMode]
						end),
						Selection = States.Catalog.Mode,
						ContentSize = Theme.TextSize["1.5"],
						Color = Theme.Colors.NeutralContent.Main,
					},
					Scope:TextInput {
						PlaceholderText = "Search",
						MaxSize = Scope:Computed(function(Use)
							return Vector2.new(Use(Theme.Spacing["16"]), math.huge)
						end),
						FlexMode = Enum.UIFlexMode.Fill,
						AutomaticSize = Enum.AutomaticSize.XY,
						Text = SearchBarText,
						CornerRadius = Scope:Computed(function(Use)
							return UDim.new(0, Use(Theme.CornerRadius["1.5"]))
						end),

						OnFocusLost = function()
							States.Catalog.SearchQuery:set(Fusion.peek(SearchBarText))
						end,
					},
				},
			},
		},
	}))
end
