local Avalog = script.Parent.Parent.Parent.Parent.Parent
local OnyxUI = require(Avalog.Parent.OnyxUI)
local Fusion = require(Avalog.Parent.Fusion)
local Config = require(Avalog.Config)
local States = require(Avalog.SourceCode.Client.UI.States)
local Navigation = require(Avalog.SourceCode.Client.UI.StateExtensions.Navigation)

local Children = Fusion.Children

export type Props = { [string]: any } & {
	OnExit: () -> (),
}

return function(Scope: Fusion.Scope<any>, Props: Props)
	local Scope = Fusion.innerScope(Scope, Fusion, OnyxUI.Util, OnyxUI.Components, {
		Tabs = require(script.Parent.Tabs),
		CategoryBar = require(script.Parent.CategoryBar),
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
				Name = "Controls",
				ListEnabled = true,
				ListFillDirection = Enum.FillDirection.Horizontal,
				ListHorizontalFlex = Enum.UIFlexAlignment.SpaceBetween,
				ListVerticalAlignment = Enum.VerticalAlignment.Center,
				AutomaticSize = Enum.AutomaticSize.Y,

				[Children] = {
					Scope:IconButton {
						Name = "ExitButton",
						Image = "rbxassetid://13846120661",
						SizeVariant = "ExtraLarge",
						Style = "Ghost",
						Color = Theme.Colors.BaseContent.Main,
						PaddingLeft = Scope:Computed(function(Use)
							return UDim.new(0, Use(Theme.Spacing["1"]))
						end),
						PaddingRight = Scope:Computed(function(Use)
							return UDim.new(0, Use(Theme.Spacing["1"]))
						end),
						PaddingTop = Scope:Computed(function(Use)
							return UDim.new(0, Use(Theme.Spacing["1"]))
						end),
						PaddingBottom = Scope:Computed(function(Use)
							return UDim.new(0, Use(Theme.Spacing["1"]))
						end),

						OnActivated = Props.OnExit,
					},
					Scope:SwapInput {
						Name = "ModeSwapper",
						Options = Modes,
						Selection = States.Catalog.Mode,
						Visible = Scope:Computed(function(Use)
							return not Use(States.Catalog.Searching)
						end),
						AutomaticSize = Enum.AutomaticSize.XY,
						FlexMode = Enum.UIFlexMode.Fill,
						ClipsDescendants = true,
						MaxSize = Scope:Computed(function(Use)
							return Vector2.new(Use(Theme.Spacing["16"]), Use(Theme.TextSize["3"]))
						end),
					},
					Scope:TextInput {
						Name = "SearchBar",
						PlaceholderText = "Search",
						Visible = States.Catalog.Searching,
						MaxSize = Scope:Computed(function(Use)
							return Vector2.new(Use(Theme.Spacing["16"]), math.huge)
						end),
						FlexMode = Enum.UIFlexMode.Fill,
						AutomaticSize = Enum.AutomaticSize.XY,
						Text = SearchBarText,

						OnFocusLost = function()
							States.Catalog.SearchQuery:set(Fusion.peek(SearchBarText))
						end,
					},
					Scope:IconButton {
						Name = "SearchButton",
						Image = "rbxassetid://13850026502",
						SizeVariant = "ExtraLarge",
						Style = "Ghost",
						Color = Theme.Colors.BaseContent.Main,
						PaddingLeft = Scope:Computed(function(Use)
							return UDim.new(0, Use(Theme.Spacing["1"]))
						end),
						PaddingRight = Scope:Computed(function(Use)
							return UDim.new(0, Use(Theme.Spacing["1"]))
						end),
						PaddingTop = Scope:Computed(function(Use)
							return UDim.new(0, Use(Theme.Spacing["1"]))
						end),
						PaddingBottom = Scope:Computed(function(Use)
							return UDim.new(0, Use(Theme.Spacing["1"]))
						end),
						Disabled = Scope:Computed(function(Use)
							local CategoryValue = Use(Navigation.Category)
							local ModeValue = Use(Navigation.Mode)
							local AcceptedModes = { "Marketplace" }

							if table.find(AcceptedModes, ModeValue) == nil then
								return true
							elseif CategoryValue.Name == "Featured" then
								return true
							else
								return false
							end
						end),

						OnActivated = function()
							local SearchingValue = Fusion.peek(States.Catalog.Searching)
							States.Catalog.Searching:set(not SearchingValue)
						end,
					},
				},
			},
		},
	}))
end
