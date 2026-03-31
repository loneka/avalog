local Avalog = script.Parent.Parent.Parent.Parent.Parent
local States = require(Avalog.SourceCode.Client.UI.States)
local OnyxUI = require(Avalog.Parent.OnyxUI)
local Fusion = require(Avalog.Parent.Fusion)

local Children = Fusion.Children

export type Props = { [string]: any } & {
	Options: Fusion.UsedAs<{ string }>?,
	Selection: Fusion.UsedAs<number>?,
}

return function(Scope: Fusion.Scope<any>, Props: Props)
	local Scope = Fusion.innerScope(Scope, Fusion, OnyxUI.Util, OnyxUI.Components)
	local Theme = OnyxUI.Themer.Theme:now()

	local Options = OnyxUI.Util.Fallback(Props.Options, {})
	local Selection = Scope:EnsureValue(OnyxUI.Util.Fallback(Props.Selection, 1))

	Scope:Observer(Options):onChange(function()
		Selection:set(1)
	end)

	local Tabs = Scope:Scroller(OnyxUI.Util.CombineProps(Props, {
		Name = script.Name,
		ListEnabled = true,
		ListFillDirection = Enum.FillDirection.Horizontal,
		ListPadding = Scope:Computed(function(Use)
			return UDim.new(0, Use(Theme.Spacing["0"]))
		end),
		ScrollingDirection = Enum.ScrollingDirection.X,
		AutomaticSize = Enum.AutomaticSize.XY,
		AutomaticCanvasSize = Enum.AutomaticSize.X,
		CanvasSize = UDim2.fromScale(1.5, 0),
		ScrollBarThickness = 0,
		ScrollBarImageTransparency = 1,

		[Children] = {
			Scope:ForValues(Options, function(Use, Scope, Option)
				local OptionsValue = Use(Options)

				return OnyxUI.Themer.Theme:is(Fusion.peek(States.Theme)):during(function()
					return Scope:Button {
						Name = "OptionButton",
						Content = Scope:Computed(function(Use)
							return { Option }
						end),
						Style = Scope:Computed(function(Use)
							if Use(Options)[Use(Selection)] == Option then
								return "Filled"
							else
								return "Ghost"
							end
						end),
						Color = Theme.Colors.BaseContent.Main,
						SizeVariant = "Medium",
						LayoutOrder = Scope:Computed(function()
							return table.find(OptionsValue, Option) or 0
						end),

						OnActivated = function()
							Selection:set(table.find(OptionsValue, Option))
						end,
					}
				end)
			end),
		},
	}))

	Scope:Observer(Options):onChange(function()
		Tabs.CanvasPosition = Vector2.new(0, 0)
	end)

	return Tabs
end
