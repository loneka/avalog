local Avalog = script.Parent.Parent.Parent.Parent.Parent
local OnyxUI = require(Avalog.Parent.OnyxUI)
local Fusion = require(Avalog.Parent.Fusion)

export type Props = {
	Options: Fusion.UsedAs<{ string }>?,
	Selection: Fusion.UsedAs<number>?,
	OnSwap: Fusion.UsedAs<(number) -> ()>?,
}

return function(Scope: Fusion.Scope<any>, Props: Props)
	local Scope = Fusion.innerScope(Scope, Fusion, OnyxUI.Util, OnyxUI.Components)
	local Theme = OnyxUI.Themer.Theme:now()

	local Options = OnyxUI.Util.Fallback(Props.Options, {})
	local Selection = Scope:EnsureValue(OnyxUI.Util.Fallback(Props.Selection, 1))
	local OnSwap = OnyxUI.Util.Fallback(Props.OnSwap, function() end)

	local function RotateSelection(Increment: number)
		local OptionsValue = Fusion.peek(Options)
		local SelectionValue = Fusion.peek(Selection)
		local NewSelection = SelectionValue + Increment

		if NewSelection > #OptionsValue then
			NewSelection = 1
		elseif NewSelection < 1 then
			NewSelection = #OptionsValue
		end

		Selection:set(NewSelection)
	end

	return Scope:IconButton(OnyxUI.Util.CombineProps(Props, {
		Name = script.Name,
		Style = "Ghost",
		Color = Theme.Colors.BaseContent.Main,
		Image = Scope:Computed(function(Use)
			return Use(Options)[Use(Selection)]
		end),

		OnActivated = function()
			local SelectionValue = Fusion.peek(Selection)
			local OnSwapValue = Fusion.peek(OnSwap)

			RotateSelection(1)
			OnSwapValue(SelectionValue, SelectionValue + 1)
		end,
	}))
end
