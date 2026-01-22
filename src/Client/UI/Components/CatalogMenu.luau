local Avalog = script.Parent.Parent.Parent.Parent.Parent
local OnyxUI = require(Avalog.Parent.OnyxUI)
local Fusion = require(Avalog.Parent.Fusion)

local Children = Fusion.Children

export type Props = {
	OnExit: () -> (),
}

return function(Scope: Fusion.Scope<any>, Props: Props)
	local Scope = Fusion.innerScope(Scope, Fusion, OnyxUI.Util, OnyxUI.Components, {
		CategoryBar = require(script.Parent.CategoryBar),
		NavigationBar = require(script.Parent.NavigationBar),
		TabDisplay = require(script.Parent.TabDisplay),
	})
	local Theme = OnyxUI.Themer.Theme:now()

	return Scope:Frame(OnyxUI.Util.CombineProps(Props, {
		Name = "CatalogMenu",
		BackgroundTransparency = 0,
		BackgroundColor3 = Theme.Colors.Base.Main,
		ListEnabled = true,
		ListHorizontalFlex = Enum.UIFlexAlignment.Fill,
		ListPadding = Scope:Computed(function(Use)
			return UDim.new(0, Use(Theme.Spacing["0"]))
		end),

		[Children] = {
			Scope:NavigationBar {
				OnExit = Props.OnExit,
			},
			Scope:CategoryBar {},
			Scope:TabDisplay {},
		},
	}))
end
