local RunService = game:GetService("RunService")

local Avalog = script.Parent.Parent.Parent.Parent.Parent
local OnyxUI = require(Avalog.Parent.OnyxUI)
local Fusion = require(Avalog.Parent.Fusion)
local States = require(Avalog.SourceCode.Client.UI.States)
local Categories = require(Avalog.SourceCode.Shared.Categories)
local AvatarAssetTypes = require(Avalog.SourceCode.Shared.AvatarAssetTypes)

local Children = Fusion.Children

-- Avalog cannot develop w/o featured tab
if RunService:IsStudio() then
	if Categories.Marketplace[1].Name ~= "Featured" then
		table.insert(Categories.Marketplace, 1, {
			Name = "Featured",
			CategoryFilter = Enum.CatalogCategoryFilter.Recommended,
			AssetTypes = AvatarAssetTypes.Types.All,
			BundleTypes = {
				Enum.BundleType.Animations,
				Enum.BundleType.BodyParts,
				Enum.BundleType.DynamicHead,
				Enum.BundleType.DynamicHeadAvatar,
				Enum.BundleType.Shoes,
			},
		})
	end
end

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
			Scope:Computed(function(Use, Scope)
				-- Clean menu when closed, improving passive game performance
				if Use(States.Open) then
					return OnyxUI.Themer.Theme:is(Theme):during(function()
						return Scope:TabDisplay {}
					end)
				end
			end),
		},
	}))
end
