local Avalog = script.Parent.Parent.Parent.Parent.Parent
local OnyxUI = require(Avalog.Parent.OnyxUI)
local Fusion = require(Avalog.Parent.Fusion)

local Children = Fusion.Children

export type Props = { [string]: any } & {
	Value: Fusion.UsedAs<number>?,
	Label: Fusion.UsedAs<string>?,
}

return function(Scope: Fusion.Scope<any>, Props: Props)
	local Scope = Fusion.innerScope(Scope, Fusion, OnyxUI.Util, OnyxUI.Components)
	local Theme = OnyxUI.Themer.Theme:now()

	local Label = OnyxUI.Util.Fallback(Props.Label, "Setting")
	local Value = OnyxUI.Util.Fallback(Props.Value, 1)

	return Scope:Frame(OnyxUI.Util.CombineProps(Props, {
		Name = script.Name,
		ListEnabled = true,
		ListPadding = Scope:Computed(function(Use)
			return UDim.new(0, Use(Theme.Spacing["0.75"]))
		end),
		ListHorizontalFlex = Enum.UIFlexAlignment.Fill,

		[Children] = {
			Scope:Heading {
				Text = Label,
				HeadingSize = 1.25,
				TextWrapped = false,
			},
			Scope:Slider {
				Value = Value,
				Color = Theme.Colors.BaseContent.Main,
			},
		},
	}))
end
