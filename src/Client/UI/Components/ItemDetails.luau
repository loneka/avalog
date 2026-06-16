local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")

local Avalog = script.Parent.Parent.Parent.Parent.Parent

local OnyxUI = require(Avalog.Parent.OnyxUI)
local Fusion = require(Avalog.Parent.Fusion)

local CatalogItems = require(Avalog.SourceCode.Client.UI.StateExtensions.CatalogItems)
local States = require(Avalog.SourceCode.Client.UI.States)

local Children = Fusion.Children

local ITEM_TYPE_INFO_TYPES = {
	[Enum.AvatarItemType.Asset] = Enum.InfoType.Asset,
	[Enum.AvatarItemType.Bundle] = Enum.InfoType.Bundle,
}

export type Props = {
	ItemId: Fusion.UsedAs<number>,
	ItemType: Fusion.UsedAs<Enum.AvatarItemType>,
}

return function(Scope: Fusion.Scope<any>, Props: Props)
	local Scope = Fusion.innerScope(Scope, Fusion, OnyxUI.Util, OnyxUI.Components)
	local Theme = OnyxUI.Themer.Theme:now()

	local ItemId = OnyxUI.Util.Fallback(Props.ItemId, 1)
	local ItemType = OnyxUI.Util.Fallback(Props.ItemType, Enum.AvatarItemType.Asset)

	local ItemInfo = Scope:Value(nil)
	local function UpdateItemInfo()
		task.spawn(function()
			local FetchedItemInfo =
				CatalogItems:GetItem(Fusion.peek(ItemId), ITEM_TYPE_INFO_TYPES[Fusion.peek(ItemType)])
			if FetchedItemInfo then
				ItemInfo:set(FetchedItemInfo)
			end
		end)
	end
	Scope:Observer(ItemId):onChange(function()
		UpdateItemInfo()
	end)
	UpdateItemInfo()

	local SafeItemInfo = Scope:Computed(function(Use)
		if Use(ItemInfo) then
			return Use(ItemInfo)
		else
			return {
				Id = Use(ItemId),
				Name = "Name",
				Price = 0,
				Offsale = false,
				Type = Enum.AvatarItemType.Asset,
				AssetType = Enum.AvatarAssetType.Hat,
				Description = "aliqua cillum ex consequat nulla nulla dolore deserunt duis laboris tempor quis velit ut cillum in ipsum id amet pariatur adipisicing proident ex cupidatat nostrud fugiat sunt id exercitation eu cillum amet",
				Creator = {
					Id = 1,
					Type = "User",
					Name = "Creator",
					Verified = false,
				},
			}
		end
	end)

	return Scope:Frame(OnyxUI.Util.CombineProps(Props, {
		Name = script.Name,
		BackgroundColor3 = Theme.Colors.Base.Main,
		BackgroundTransparency = 0,
		AutomaticSize = Enum.AutomaticSize.X,
		ListEnabled = true,
		ListHorizontalFlex = Enum.UIFlexAlignment.Fill,
		Padding = Scope:Computed(function(Use)
			return UDim.new(0, Use(Theme.Spacing["0.75"]))
		end),

		[Children] = {
			Scope:Frame {
				ListEnabled = true,
				ListHorizontalFlex = Enum.UIFlexAlignment.Fill,
				FlexMode = Enum.UIFlexMode.Fill,

				[Children] = {
					Scope:Image {
						Image = Scope:Computed(function(Use)
							local SafeItemInfoValue = Use(SafeItemInfo)
							local ItemTypeToType = {
								[Enum.AvatarItemType.Bundle] = "BundleThumbnail",
								[Enum.AvatarItemType.Asset] = "Asset",
							}

							return `rbxthumb://id={SafeItemInfoValue.Id}&type={(ItemTypeToType[SafeItemInfoValue.Type] or "Asset")}&w=150&h=150`
						end),
						BackgroundTransparency = 1,
						ScaleType = Enum.ScaleType.Fit,
						CornerRadius = Scope:Computed(function(Use)
							return UDim.new(0, Use(Theme.CornerRadius["1.5"]))
						end),
						AspectRatio = 16 / 9,
					},
					Scope:Frame {
						ListEnabled = true,
						ListPadding = Scope:Computed(function(Use)
							return UDim.new(0, Use(Theme.Spacing["0.5"]))
						end),
						AutoLocalize = false,

						[Children] = {
							Scope:Heading {
								Text = Scope:Computed(function(Use)
									return Use(SafeItemInfo).Name
								end),
								HeadingSize = 1.3,
								TextWrapped = false,
								TextTruncate = Enum.TextTruncate.AtEnd,
							},
							Scope:Text {
								Text = Scope:Computed(function(Use)
									if Use(SafeItemInfo).Creator.Verified then
										return Use(SafeItemInfo).Creator.Name
									else
										return `{Use(SafeItemInfo).Creator.Name} {utf8.char(0xE000)}`
									end
								end),
								TextSize = Theme.TextSize["1.125"],
							},
						},
					},
					Scope:Text {
						Text = Scope:Computed(function(Use)
							return Use(SafeItemInfo).Description
						end),
						AutoLocalize = false,
						TextTruncate = Enum.TextTruncate.AtEnd,
						AutomaticSize = Enum.AutomaticSize.X,
						ClipsDescendants = true,
						FlexMode = Enum.UIFlexMode.Fill,
					},
				},
			},
			Scope:Frame {
				ListEnabled = true,
				ListFillDirection = Enum.FillDirection.Horizontal,
				ListHorizontalFlex = Enum.UIFlexAlignment.Fill,
				ListPadding = Scope:Computed(function(Use)
					return UDim.new(0, Use(Theme.Spacing["0.5"]))
				end),

				[Children] = {
					Scope:Button {
						Content = { "Back" },
						ContentSize = Theme.TextSize["1"],
						SizeVariant = "ExtraLarge",

						OnActivated = function()
							States.ItemDetails.Open:set(false)
						end,
					},
					Scope:Button {
						Content = { "Buy" },
						ContentSize = Theme.TextSize["1"],
						SizeVariant = "ExtraLarge",
						Color = Theme.Colors.Primary.Main,

						OnActivated = function()
							if Players.LocalPlayer == nil then
								return
							end
							MarketplaceService:PromptPurchase(Players.LocalPlayer, Fusion.peek(ItemId))
						end,
					},
				},
			},
		},
	}))
end
