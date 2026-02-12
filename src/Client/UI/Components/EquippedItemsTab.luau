local Avalog = script.Parent.Parent.Parent.Parent.Parent
local OnyxUI = require(Avalog.Parent.OnyxUI)
local Fusion = require(Avalog.Parent.Fusion)
local States = require(Avalog.SourceCode.Client.UI.States)

local ItemsTab = require(script.Parent.ItemsTab)

export type Props = ItemsTab.Props & {}

return function(Scope: Fusion.Scope<any>, Props: Props)
	local Scope = Fusion.innerScope(Scope, Fusion, OnyxUI.Util, OnyxUI.Components, {
		ItemButton = require(script.Parent.ItemButton),
		ItemsTab = require(script.Parent.ItemsTab),
	})

	local Shown = OnyxUI.Util.Fallback(Props.Shown, false)

	local AssetIds = Scope:Value({})

	local function UpdateAssetIds()
		local EquippedAssetIdsValue = Fusion.peek(States.Avatar.EquippedAssetIds)
		AssetIds:set(EquippedAssetIdsValue)
	end

	UpdateAssetIds()

	Scope:Observer(States.Avatar.Loaded):onChange(function()
		UpdateAssetIds()
	end)

	return Scope:ItemsTab(OnyxUI.Util.CombineProps(Props, {
		Name = script.Name,
		Items = Scope:ForValues(AssetIds, function(Use, Scope, AssetId)
			return {
				Id = AssetId,
				Type = Enum.AvatarItemType.Asset,
			}
		end),
	}))
end
