local Avalog = script.Parent.Parent.Parent.Parent.Parent
local OnyxUI = require(Avalog.Parent.OnyxUI)
local Fusion = require(Avalog.Parent.Fusion)
local Version = require(Avalog.SourceCode.Shared.Version)

local Children = Fusion.Children

export type Props = {
	Open: Fusion.UsedAs<boolean>?,
	Link: Fusion.UsedAs<string>?,
	Logo: Fusion.UsedAs<string>?,
	UpdateAvailable: Fusion.UsedAs<boolean>?,
} & { [string]: any }

return function(Scope: Fusion.Scope<any>, Props: Props)
	local Scope = Fusion.innerScope(Scope, Fusion, OnyxUI.Util, OnyxUI.Components)
	local Theme = OnyxUI.Themer.Theme:now()

	local Open = Scope:EnsureValue(OnyxUI.Util.Fallback(Props.Open, false))
	local Link = OnyxUI.Util.Fallback(Props.Link, "https://devforum.com")
	local Logo = OnyxUI.Util.Fallback(Props.Logo, "")
	local UpdateAvailable = OnyxUI.Util.Fallback(Props.UpdateAvailable, false)
	local Color = OnyxUI.Util.Fallback(Props.Color, Theme.Colors.Neutral.Main)

	return Scope:Frame(OnyxUI.Util.CombineProps(Props, {
		Name = script.Name,
		ListEnabled = true,
		ListFillDirection = Enum.FillDirection.Horizontal,
		ListVerticalAlignment = Enum.VerticalAlignment.Center,
		ListPadding = Scope:Computed(function(Use)
			return UDim.new(0, Use(Theme.Spacing["0.25"]))
		end),

		[Children] = {
			Scope:IconButton {
				Image = Logo,
				ContentSize = Theme.TextSize["1.5"],
				Color = Scope:Computed(function(Use)
					local UpdateAvailable = Use(UpdateAvailable)

					if UpdateAvailable then
						return Use(Theme.Colors.Warning.Dark)
					else
						return Use(Theme.Colors.Neutral.Main)
					end
				end),
				PaddingLeft = Scope:Computed(function(Use)
					return UDim.new(0, Use(Theme.Spacing["0.5"]))
				end),
				PaddingRight = Scope:Computed(function(Use)
					return UDim.new(0, Use(Theme.Spacing["0.5"]))
				end),
				PaddingTop = Scope:Computed(function(Use)
					return UDim.new(0, Use(Theme.Spacing["0.5"]))
				end),
				PaddingBottom = Scope:Computed(function(Use)
					return UDim.new(0, Use(Theme.Spacing["0.5"]))
				end),
				CornerRadius = Scope:Computed(function(Use)
					return UDim.new(0, Use(Theme.CornerRadius["Full"]))
				end),
				StrokeThickness = Theme.StrokeThickness["1"],
				StrokeEnabled = true,
				StrokeColor = Theme.Colors.Neutral.Dark,

				OnActivated = function()
					local OpenValue = Fusion.peek(Open)

					Open:set(not OpenValue)
				end,
			},
			Scope:TextInput {
				Text = Scope:Computed(function(Use)
					local LinkValue = Use(Link)

					return `Avalog {Version} • {LinkValue}`
				end),
				TextTransparency = 0,
				TextEditable = false,
				Disabled = true,
				BackgroundColor3 = Theme.Colors.Neutral.Main,
				BackgroundTransparency = 0,
				CornerRadius = Scope:Computed(function(Use)
					return UDim.new(0, Use(Theme.CornerRadius["Full"]))
				end),
				Scale = Scope:Spring(
					Scope:Computed(function(Use)
						local OpenValue = Use(Open)

						if OpenValue == true then
							return 1
						else
							return 0
						end
					end),
					Theme.SpringSpeed["2"],
					Theme.SpringDampening["1"]
				),
			},
		},
	}))
end
