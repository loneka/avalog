local Avalog = script.Parent.Parent.Parent.Parent.Parent
local OnyxUI = require(Avalog.Parent.OnyxUI)
local Fusion = require(Avalog.Parent.Fusion)
local States = require(Avalog.SourceCode.Client.UI.States)
local ServiceProvider = require(Avalog.SourceCode.Client.ServiceProvider)
local CatalogItems = require(Avalog.SourceCode.Client.UI.StateExtensions.CatalogItems)

local Children = Fusion.Children

local ITEM_TYPE_INFO_TYPES = {
	[Enum.AvatarItemType.Asset] = Enum.InfoType.Asset,
	[Enum.AvatarItemType.Bundle] = Enum.InfoType.Bundle,
}

export type Props = { [string]: any } & {
	Id: Fusion.UsedAs<number>?,
	Type: Fusion.UsedAs<Enum.AvatarItemType>?,
}

return function(Scope: Fusion.Scope<any>, Props: Props)
	local Scope = Fusion.innerScope(Scope, Fusion, OnyxUI.Util, OnyxUI.Components, {
		CustomButton = require(script.Parent.CustomButton),
	})
	local Theme = OnyxUI.Themer.Theme:now()
	local AvatarManager = ServiceProvider:GetAvatarManager()

	local Id = Scope:EnsureValue(OnyxUI.Util.Fallback(Props.Id, nil))
	local Type = OnyxUI.Util.Fallback(Props.Type, Enum.AvatarItemType.Asset)

	local ItemInfo = Scope:Value(nil)
	local function UpdateItemInfo()
		local IdValue = Fusion.peek(Id)
		local TypeValue = Fusion.peek(Type)

		task.spawn(function()
			local FetchedItemInfo = CatalogItems:GetItem(IdValue, ITEM_TYPE_INFO_TYPES[TypeValue])
			if FetchedItemInfo then
				ItemInfo:set(FetchedItemInfo)
			end
		end)
	end
	Scope:Observer(Id):onChange(function()
		UpdateItemInfo()
	end)
	UpdateItemInfo()

	local SafeItemInfo = Scope:Computed(function(Use)
		local ItemInfoValue = Use(ItemInfo)
		local IdValue = Use(Id)

		if ItemInfoValue then
			return ItemInfoValue
		else
			return {
				Id = IdValue,
				Name = "Name",
				Price = 0,
				Offsale = false,
				Type = Enum.AvatarItemType.Asset,
				AssetType = Enum.AvatarAssetType.Hat,
			}
		end
	end)
	local Equippable = Scope:Computed(function(Use)
		local SafeItemInfoValue = Use(SafeItemInfo)
		return SafeItemInfoValue.Type == Enum.AvatarItemType.Asset
	end)
	local Equipped = Scope:Computed(function(Use)
		local AssetIdsValue = Use(States.Avatar.AssetIds)
		local IdValue = Use(Id)
		local SafeItemInfoValue = Use(SafeItemInfo)

		if SafeItemInfoValue.AssetType == Enum.AvatarAssetType.EmoteAnimation and AvatarManager.HumanoidDescriber then
			return AvatarManager.HumanoidDescriber:GetEquippedEmote(SafeItemInfoValue.Name) ~= nil
		else
			return table.find(AssetIdsValue, IdValue) ~= nil
		end
	end)

	local EquippedValueState = Scope:Value(Fusion.peek(Equipped))
	Scope:Observer(Equipped):onChange(function()
		EquippedValueState:set(Fusion.peek(Equipped))
	end)

	return Scope:CustomButton(OnyxUI.Util.CombineProps(Props, {
		Name = script.Name,
		StrokeEnabled = Equipped,
		StrokeThickness = Theme.StrokeThickness["2"],
		StrokeColor = Theme.Colors.BaseContent.Main,
		ListEnabled = false,

		OnActivated = function()
			local ItemInfoValue = Fusion.peek(ItemInfo)

			if ItemInfoValue then
				AvatarManager:ToggleCatalogItem(ItemInfoValue)
			end
		end,

		[Children] = {
			Scope:Frame {
				Name = "Details",
				ListEnabled = true,
				ListFillDirection = Enum.FillDirection.Vertical,
				ListHorizontalFlex = Enum.UIFlexAlignment.Fill,
				ListPadding = Scope:Computed(function(Use)
					return UDim.new(0, Use(Theme.Spacing["0.5"]))
				end),
				Padding = Scope:Computed(function(Use)
					return UDim.new(0, Use(Theme.Spacing["0.5"]))
				end),
				Size = UDim2.fromScale(1, 0),

				[Children] = {
					Scope:Image {
						BackgroundTransparency = 1,
						Image = Scope:Computed(function(Use)
							local SafeItemInfoValue = Use(SafeItemInfo)
							local ItemTypeToType = {
								[Enum.AvatarItemType.Bundle] = "BundleThumbnail",
								[Enum.AvatarItemType.Asset] = "Asset",
							}

							return `rbxthumb://id={SafeItemInfoValue.Id}&type={(ItemTypeToType[SafeItemInfoValue.Type] or "Asset")}&w=150&h=150`
						end),
						ScaleType = Enum.ScaleType.Fit,
						CornerRadius = Scope:Computed(function(Use)
							return UDim.new(0, Use(Theme.CornerRadius["1"]))
						end),
						Size = Scope:Computed(function(Use)
							local Offset = Use(Theme.Spacing["8"])
							return UDim2.fromOffset(Offset, Offset)
						end),
					},
					Scope:Frame {
						Name = "Text",
						ListEnabled = true,
						ListFillDirection = Enum.FillDirection.Vertical,
						ListHorizontalFlex = Enum.UIFlexAlignment.Fill,
						ListPadding = Scope:Computed(function(Use)
							return UDim.new(0, Use(Theme.Spacing["0.5"]))
						end),

						[Children] = {
							Scope:Text {
								Text = Scope:Computed(function(Use)
									local SafeItemInfoValue = Use(SafeItemInfo)
									return SafeItemInfoValue.Name
								end),
								Size = Scope:Computed(function(Use)
									return UDim2.fromOffset(0, Use(Theme.TextSize["1"]) * 2)
								end),
								AutomaticSize = Enum.AutomaticSize.None,
								ClipsDescendants = true,
								RichText = false,
								AutoLocalize = false,
							},
							Scope:IconText {
								Name = "Price",
								Content = Scope:Computed(function(Use)
									local ItemInfoValue = Use(ItemInfo)
									if ItemInfoValue and ItemInfoValue.Price then
										return { "rbxassetid://102562927562320", ItemInfoValue.Price }
									else
										return { "Offsale" }
									end
								end),
								ListPadding = Scope:Computed(function(Use)
									return UDim.new(0, Use(Theme.Spacing["0.25"]))
								end),
								ListWraps = false,
								ContentWrapped = false,
								AutoLocalize = false,
							},
						},
					},
				},
			},
			Scope:Checkbox {
				Name = "EquippedMarker",
				Checked = EquippedValueState,
				AnchorPoint = Vector2.new(1, 0),
				Position = UDim2.fromScale(1, 0),
				Active = false,
				Selectable = false,
				Visible = Equippable,
			},
		},
	}))
end
