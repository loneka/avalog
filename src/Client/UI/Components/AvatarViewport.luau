local MarketplaceService = game:GetService("MarketplaceService")
local RunService = game:GetService("RunService")

local Avalog = script.Parent.Parent.Parent.Parent.Parent
local OnyxUI = require(Avalog.Parent.OnyxUI)
local Fusion = require(Avalog.Parent.Fusion)
local States = require(Avalog.SourceCode.Client.UI.States)
local ServiceProvider = require(Avalog.SourceCode.Client.ServiceProvider)
local Navigation = require(Avalog.SourceCode.Client.UI.StateExtensions.Navigation)

local Children = Fusion.Children

export type Props = {}

return function(Scope: Fusion.Scope<any>, Props: Props)
	local Scope = Fusion.innerScope(Scope, Fusion, OnyxUI.Util, OnyxUI.Components)
	local Theme = OnyxUI.Themer.Theme:now()
	local AvatarManager = ServiceProvider:GetAvatarManager()

	local ViewportCamera = Scope:New "Camera" {
		CFrame = CFrame.lookAt(Vector3.new(4, 0, -8), Vector3.new(0, 0, 0)),
		CameraType = Enum.CameraType.Scriptable,
	}

	local RotationAngle = 0
	local Dragging = false
	local LastDragPosition = Vector2.new()

	local DragDetector = Scope:New "UIDragDetector" {
		DragStyle = Enum.UIDragDetectorDragStyle.Scriptable,
	}

	DragDetector.DragStart:Connect(function(Position)
		Dragging = true
		LastDragPosition = Position
	end)
	DragDetector.DragEnd:Connect(function()
		Dragging = false
	end)
	DragDetector.DragContinue:Connect(function(Position)
		RotationAngle += (Position - LastDragPosition).X / 50
		LastDragPosition = Position
	end)

	RunService.RenderStepped:Connect(function(DeltaTime)
		if not Dragging then
			RotationAngle += DeltaTime * math.rad(30)
		end

		ViewportCamera.CFrame = CFrame.lookAt(
			Vector3.new(8 * math.cos(RotationAngle), 0, 8 * math.sin(RotationAngle)),
			Vector3.new(0, 0, 0)
		)
	end)

	return Scope:Image(OnyxUI.Util.CombineProps(Props, {
		Name = script.Name,
		MaxSize = Scope:Computed(function(Use)
			local ResolutionValue = Use(States.Screen.Resolution)

			if ResolutionValue.X < 800 then
				return Vector2.new(ResolutionValue.X / 2.5, math.huge)
			elseif ResolutionValue.X > 1000 then
				return Vector2.new(ResolutionValue.X / 3, math.huge)
			else
				return Vector2.new(16 * 24, math.huge)
			end
		end),
		BackgroundTransparency = 0,
		BackgroundColor3 = Theme.Colors.Base.Dark,
		Image = "rbxassetid://140363116814273",
		ScaleType = Enum.ScaleType.Crop,
		AutomaticSize = Enum.AutomaticSize.X,
		ListEnabled = true,
		ListHorizontalFlex = Enum.UIFlexAlignment.Fill,
		ListVerticalFlex = Enum.UIFlexAlignment.Fill,

		[Children] = {
			Scope:Frame {
				Name = "Contents",
				Padding = Scope:Computed(function(Use)
					return UDim.new(0, Use(Theme.Spacing["1"]))
				end),
				AutomaticSize = Enum.AutomaticSize.None,

				[Children] = {
					DragDetector,
					Scope:New "ViewportFrame" {
						Name = "Viewport",
						Size = UDim2.fromScale(1, 1),
						BackgroundTransparency = 1,
						BackgroundColor3 = Color3.fromRGB(0, 0, 0),
						CurrentCamera = ViewportCamera,

						[Children] = {
							Scope:New "WorldModel" {
								[Children] = {
									ViewportCamera,

									Scope:Computed(function(Use)
										local CharacterValue = Use(States.Avatar.Character)

										if RunService:IsRunning() then
											return CharacterValue
										else
											return nil
										end
									end),
								},
							},
						},
					},
					Scope:Frame {
						Name = "Controls",
						Size = UDim2.fromScale(1, 1),
						ListEnabled = true,
						ListHorizontalAlignment = Enum.HorizontalAlignment.Center,
						ListVerticalFlex = Enum.UIFlexAlignment.SpaceBetween,

						[Children] = {
							Scope:Card {
								Name = "TopControls",
								ListEnabled = true,
								ListFillDirection = Enum.FillDirection.Horizontal,
								ListHorizontalFlex = Enum.UIFlexAlignment.Fill,
								ListHorizontalAlignment = Enum.HorizontalAlignment.Center,
								ListPadding = Scope:Computed(function(Use)
									return UDim.new(0, Use(Theme.Spacing["0.5"]))
								end),
								CornerRadius = Scope:Computed(function(Use)
									return UDim.new(0, Use(Theme.CornerRadius["2"]))
								end),
								Padding = Scope:Computed(function(Use)
									return UDim.new(0, Use(Theme.Spacing["0.5"]))
								end),
								BackgroundColor3 = Theme.Colors.Base.Main,

								[Children] = {
									Scope:Button {
										Name = "SaveButton",
										Content = { "rbxassetid://13846738861", "Save" },
										SizeVariant = "Large",
										Disabled = States.Checkout.Loading,

										OnActivated = function()
											States.Checkout.Loading:set(true)
											local UnownedItems = AvatarManager:GetUnownedItems()
											States.Checkout.Loading:set(false)

											if #UnownedItems > 0 then
												local Success = AvatarManager:PromptCheckout(UnownedItems)
												if Success then
													MarketplaceService.PromptBulkPurchaseFinished:Once(
														function(_, Status)
															if
																Status
																== Enum.MarketplaceBulkPurchasePromptStatus.Completed
															then
																task.wait(0.5)
																AvatarManager:SaveAvatar()
															end
														end
													)
												end
											else
												AvatarManager:SaveAvatar()
											end
										end,
									},
									Scope:Button {
										Name = "DoneButton",
										Content = { "rbxassetid://13846852950", "Done" },
										Color = Theme.Colors.Success.Main,
										SizeVariant = "Large",

										OnActivated = function()
											AvatarManager:UpdateServer(Fusion.peek(States.Avatar.Data))

											States.Open:set(false)
										end,
									},
								},
							},
							Scope:Card {
								Name = "BottomControls",
								ListEnabled = true,
								ListFillDirection = Enum.FillDirection.Horizontal,
								ListHorizontalFlex = Enum.UIFlexAlignment.Fill,
								ListHorizontalAlignment = Enum.HorizontalAlignment.Center,
								ListPadding = Scope:Computed(function(Use)
									return UDim.new(0, Use(Theme.Spacing["0.75"]))
								end),
								CornerRadius = Scope:Computed(function(Use)
									return UDim.new(0, Use(Theme.CornerRadius["2"]))
								end),
								Padding = Scope:Computed(function(Use)
									return UDim.new(0, Use(Theme.Spacing["0.5"]))
								end),
								BackgroundColor3 = Theme.Colors.Base.Main,

								[Children] = {
									Scope:Button {
										Content = { "rbxassetid://13846120661" },
										SizeVariant = "ExtraLarge",
										Disabled = Scope:Computed(function(Use)
											local DataHistoryValue = Use(States.Avatar.DataHistory)
											local Category = Use(Navigation.Category)
											return (#DataHistoryValue <= 1) or (Category.Name == "Equipped")
										end),

										OnActivated = function()
											AvatarManager:Undo()
										end,
									},
									Scope:Button {
										Content = { "rbxassetid://13847364382" },
										SizeVariant = "ExtraLarge",
										Color = Theme.Colors.Error.Main,

										OnActivated = function()
											AvatarManager:Reset()
										end,
									},
									Scope:Button {
										Content = { "rbxassetid://13846158505" },
										SizeVariant = "ExtraLarge",
										Disabled = Scope:Computed(function(Use)
											local UndoHistoryValue = Use(States.Avatar.UndoHistory)
											local Category = Use(Navigation.Category)
											return (#UndoHistoryValue == 0) or (Category == "Equipped")
										end),

										OnActivated = function()
											AvatarManager:Redo()
										end,
									},
								},
							},
						},
					},
				},
			},
		},
	}))
end
