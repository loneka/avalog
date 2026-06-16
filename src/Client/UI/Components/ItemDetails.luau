local Avalog = script.Parent.Parent.Parent.Parent.Parent

local OnyxUI = require(Avalog.Parent.OnyxUI)
local Fusion = require(Avalog.Parent.Fusion)

local States = require(Avalog.SourceCode.Client.UI.States)
local Navigation = require(Avalog.SourceCode.Client.UI.StateExtensions.Navigation)
local Config = require(Avalog.Config)

local CONFIG = Config:Get()

local Children = Fusion.Children

export type Props = {
	ItemId: Fusion.UsedAs<number>,
	ItemType: Fusion.UsedAs<Enum.AvatarItemType>,
}

return function(Scope: Fusion.Scope<any>, Props: Props)
	local Scope = Fusion.innerScope(Scope, Fusion, OnyxUI.Util, OnyxUI.Components)
	local Theme = OnyxUI.Themer.Theme:now()

	local ItemId = OnyxUI.Util.Fallback(Props.ItemId, 1)
	local ItemType = OnyxUI.Util.Fallback(Props.ItemType, Enum.AvatarItemType.Asset)

	return Scope:Frame(OnyxUI.Util.CombineProps(Props, {
		Name = script.Name,
		BackgroundColor3 = Theme.Colors.Base.Main,
		BackgroundTransparency = 0,
		AutomaticSize = Enum.AutomaticSize.X,
		ListEnabled = true,
		ListHorizontalFlex = Enum.UIFlexAlignment.Fill,
		ListVerticalFlex = Enum.UIFlexAlignment.Fill,

		[Children] = {},
	}))
end
