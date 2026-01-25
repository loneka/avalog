local Avalog = script.Parent.Parent.Parent.Parent.Parent
local OnyxUI = require(Avalog.Parent.OnyxUI)
local Fusion = require(Avalog.Parent.Fusion)
local States = require(Avalog.SourceCode.Client.UI.States)

local Children = Fusion.Children
local Out = Fusion.Out
local OnChange = Fusion.OnChange

export type Props = { [string]: any } & {
	Shown: Fusion.UsedAs<boolean>?,
	Items: Fusion.UsedAs<{ [string]: any }>?,
	OnReachedEnd: Fusion.UsedAs<() -> ()>?,
}

return function(Scope: Fusion.Scope<any>, Props: Props)
	local Scope = Fusion.innerScope(Scope, Fusion, OnyxUI.Util, OnyxUI.Components, {
		ItemButton = require(script.Parent.ItemButton),
	})
	local Theme = OnyxUI.Themer.Theme:now()

	local Shown = OnyxUI.Util.Fallback(Props.Shown, false)
	local Items = OnyxUI.Util.Fallback(Props.Items, {})
	local OnReachedEnd = OnyxUI.Util.Fallback(Props.OnReachedEnd, function() end)

	local AbsoluteCanvasSize = Scope:Value(Vector2.new())
	local AbsoluteWindowSize = Scope:Value(Vector2.new())

	local LastUpdated = 0

	local ItemsTab = Scope:Hydrate(Scope:Scroller(OnyxUI.Util.CombineProps(Props, {
		Name = script.Name,
		ListEnabled = true,
		ListHorizontalFlex = Enum.UIFlexAlignment.Fill,
		ListPadding = Scope:Computed(function(Use)
			return UDim.new(0, Use(Theme.Spacing["1"]))
		end),
		ScrollBarImageColor3 = Theme.Colors.Neutral.Light,
		ClipsDescendants = false,
		Visible = Shown,
		CanvasSize = UDim2.fromOffset(0, 0),
		Padding = Scope:Computed(function(Use)
			return UDim.new(0, Use(Theme.Spacing["0"]))
		end),
		PaddingRight = Scope:Computed(function(Use)
			return UDim.new(0, Use(Theme.Spacing["1"]))
		end),
	}))) {
		[OnChange "CanvasPosition"] = function(CanvasPosition: Vector2)
			local OnReachedEndValue = Fusion.peek(OnReachedEnd)
			local AbsoluteCanvasSizeValue = Fusion.peek(AbsoluteCanvasSize)
			local AbsoluteWindowSizeValue = Fusion.peek(AbsoluteWindowSize)

			local CanvasHeight = AbsoluteCanvasSizeValue.Y - AbsoluteWindowSizeValue.Y

			if (CanvasPosition.Y >= (CanvasHeight - 500)) and ((os.time() - LastUpdated) > 0.5) then
				LastUpdated = os.time()

				OnReachedEndValue()
			end
		end,
		[Out "AbsoluteCanvasSize"] = AbsoluteCanvasSize,
		[Out "AbsoluteWindowSize"] = AbsoluteWindowSize,

		[Children] = {
			Scope:Frame {
				Name = "Items",
				ListEnabled = true,
				ListFillDirection = Enum.FillDirection.Horizontal,
				ListHorizontalFlex = Enum.UIFlexAlignment.Fill,
				ListWraps = true,
				AutomaticSize = Enum.AutomaticSize.Y,

				[Children] = {
					Scope:ForPairs(Items, function(Use, Scope, Index, Item)
						return Index,
							OnyxUI.Themer.Theme:is(Fusion.peek(States.Theme)):during(function()
								return Scope:ItemButton {
									Id = Item.Id,
									Type = Item.Type,
									Visible = Item.Visible,
									Owned = Item.Owned,
									LayoutOrder = Index,
									Size = UDim2.fromScale(1 / 8, 0),
									AutomaticSize = Enum.AutomaticSize.Y,
									MinSize = Scope:Computed(function(Use)
										return Vector2.new(Use(Theme.Spacing["8"]), 0)
									end),
								}
							end)
					end),
				},
			},
			Scope:Card {
				Name = "NoItemsCard",
				ListEnabled = true,
				ListHorizontalAlignment = Enum.HorizontalAlignment.Center,
				BackgroundTransparency = 1,
				AutomaticSize = Enum.AutomaticSize.Y,
				PaddingTop = Scope:Computed(function(Use)
					return UDim.new(0, Use(Theme.Spacing["8"]))
				end),
				PaddingBottom = Scope:Computed(function(Use)
					return UDim.new(0, Use(Theme.Spacing["8"]))
				end),

				[Children] = {
					Scope:Image {
						Image = "rbxassetid://10480493542",
						BackgroundTransparency = 1,
					},
					Scope:Text {
						Text = "No more items to show!\nRate limits may have been hit.",
						TextWrapped = false,
						TextXAlignment = Enum.TextXAlignment.Center,
					},
				},
			},
		},
	}

	return ItemsTab
end
