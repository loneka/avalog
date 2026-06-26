local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")

local Avalog = script.Parent.Parent.Parent.Parent.Parent
local OnyxUI = require(Avalog.Parent.OnyxUI)
local Fusion = require(Avalog.Parent.Fusion)
local States = require(Avalog.SourceCode.Client.UI.States)
local ServiceProvider = require(Avalog.SourceCode.Client.ServiceProvider)
local CatalogItems = require(Avalog.SourceCode.Client.UI.StateExtensions.CatalogItems)
local Future = require(Avalog.Parent.Future)
local ColorUtils = require(Avalog.Parent.ColorUtils)

local Children = Fusion.Children

local ITEM_TYPE_INFO_TYPES = {
	[Enum.AvatarItemType.Asset] = Enum.InfoType.Asset,
	[Enum.AvatarItemType.Bundle] = Enum.InfoType.Bundle,
}

local CustomButton = require(script.Parent.CustomButton)

export type Props = CustomButton.Props & {
	Id: Fusion.UsedAs<number>?,
	Type: Fusion.UsedAs<Enum.AvatarItemType>?,
	Owned: Fusion.UsedAs<boolean>?,
	Featured: Fusion.UsedAs<boolean>?,
	TintColor: Fusion.UsedAs<Color3?>?,
}

return function(Scope: Fusion.Scope<any>, Props: Props)
	local Scope = Fusion.innerScope(Scope, Fusion, OnyxUI.Util, OnyxUI.Components, {
		CustomButton = CustomButton,
	})
	local Theme = OnyxUI.Themer.Theme:now()
	local AvatarManager = ServiceProvider:GetAvatarManager()

	local Id = Scope:EnsureValue(OnyxUI.Util.Fallback(Props.Id, nil))
	local Type = OnyxUI.Util.Fallback(Props.Type, Enum.AvatarItemType.Asset)
	local Featured = OnyxUI.Util.Fallback(Props.Featured, false)
	local TintColor = OnyxUI.Util.Fallback(Props.TintColor, nil)

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
	local Equipped = Scope:Computed(function(Use)
		local IdValue = Use(Id)
		local SafeItemInfoValue = Use(SafeItemInfo)

		if SafeItemInfoValue.Type == Enum.AvatarItemType.Asset then
			local AssetIdsValue = Use(States.Avatar.AssetIds)

			if
				SafeItemInfoValue.AssetType == Enum.AvatarAssetType.EmoteAnimation
				and AvatarManager.HumanoidDescriber ~= nil
			then
				if AvatarManager.HumanoidDescriber:GetEquippedEmote(SafeItemInfoValue.Name) == nil then
					return
				end
			end

			return table.find(AssetIdsValue, IdValue) ~= nil
		else
			local BundleIdsValue = Use(States.Avatar.EquippedBundleIds)

			return table.find(BundleIdsValue, IdValue) ~= nil
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
		Color = Scope:Computed(function(Use)
			local TintColorValue = Use(TintColor)
			local DefaultColorValue = Use(Theme.Colors.Neutral.Main)

			if TintColorValue ~= nil then
				return ColorUtils.Blend.Transparency(DefaultColorValue, TintColorValue, 0.85)
			else
				return DefaultColorValue
			end
		end),
		GradientEnabled = Scope:Computed(function(Use)
			return Use(TintColor) ~= nil
		end),
		GradientColor = ColorSequence.new(Color3.new(1, 1, 1)),
		GradientTransparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0.25),
			NumberSequenceKeypoint.new(0.5, 0),
			NumberSequenceKeypoint.new(1, 0.25),
		}),
		GradientRotation = Scope:Computed(function(Use)
			return Use(States.UnixTimestamp) / 15 % 360 - 180
		end),

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
							local Offset = Use(Theme.TextSize["1"]) * 5
							return UDim2.fromOffset(Offset, Offset)
						end),
					},
					Scope:Frame {
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
								Content = Scope:Computed(function(Use)
									local ItemInfoValue = Use(ItemInfo)
									if ItemInfoValue and ItemInfoValue.Price then
										return {
											"rbxassetid://102562927562320",
											ItemInfoValue.Price,
										}
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
			Scope:Frame {
				AnchorPoint = Vector2.new(0.5, 1),
				Position = UDim2.fromScale(0.5, 1),
				Size = UDim2.fromScale(1, 0),
				Scale = Scope:Spring(
					Scope:Computed(function(Use)
						if Use(Equipped) then
							return 1
						else
							return 0
						end
					end),
					Theme.SpringSpeed["2"],
					Theme.SpringDampening["1.5"]
				),
				Selectable = Equipped,
				ListEnabled = true,
				ListFillDirection = Enum.FillDirection.Horizontal,
				ListVerticalFlex = Enum.UIFlexAlignment.Fill,
				ListPadding = Scope:Computed(function(Use)
					return UDim.new(0, Use(Theme.Spacing["0.5"]))
				end),

				[Children] = {
					Scope:Button {
						Content = { "Buy" },
						Color = Theme.Colors.Success.Main,
						FlexMode = Enum.UIFlexMode.Fill,

						OnActivated = function()
							Future.Try(function()
								local IdValue = Fusion.peek(Id)

								return MarketplaceService:PromptPurchase(Players.LocalPlayer, IdValue)
							end)
						end,
					},
					Scope:IconButton {
						Image = "rbxassetid://13850025424",
						Size = UDim2.fromScale(0, 1),
						Color = Theme.Colors.Secondary.Main,
						AspectRatio = 1,

						OnActivated = function()
							States.ItemDetails.ItemType:set(Fusion.peek(Type))
							States.ItemDetails.ItemId:set(Fusion.peek(Id))
							States.ItemDetails.Open:set(true)
						end,
					},
				},
			},
			Scope:Computed(function(Use)
				if Use(Featured) then
					return Scope:Icon {
						Image = "rbxassetid://13850331560",
						Size = Scope:Computed(function(Use)
							return UDim2.fromOffset(Use(Theme.TextSize["1.25"]), Use(Theme.TextSize["1.25"]))
						end),
					}
				end
			end),
		},
	}))
end
