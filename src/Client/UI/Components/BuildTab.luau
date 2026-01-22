local Avalog = script.Parent.Parent.Parent.Parent.Parent
local OnyxUI = require(Avalog.Parent.OnyxUI)
local Fusion = require(Avalog.Parent.Fusion)
local ServiceProvider = require(Avalog.SourceCode.Client.ServiceProvider)
local ScaleLimits = require(Avalog.SourceCode.Shared.ScaleLimits)
local StretchNumber = require(Avalog.SourceCode.Shared.Utils.StretchNumber)
local States = require(Avalog.SourceCode.Client.UI.States)

local Children = Fusion.Children
local SliderSetting = require(script.Parent.SliderSetting)

export type Props = {
	Shown: Fusion.UsedAs<boolean>?,
}

return function(Scope: Fusion.Scope<any>, Props: Props)
	local Scope = Fusion.innerScope(Scope, Fusion, OnyxUI.Util, OnyxUI.Components, {
		SliderSetting = SliderSetting,
	})
	local Theme = OnyxUI.Themer.Theme:now()
	local AvatarManager = ServiceProvider:GetAvatarManager()

	local Shown = OnyxUI.Util.Fallback(Props.Shown, false)

	local ScaleProperties = {
		{ Name = "BodyType", Value = Scope:Value(1) },
		{ Name = "Proportion", Value = Scope:Value(1) },
		{ Name = "Height", Value = Scope:Value(1) },
		{ Name = "Width", Value = Scope:Value(1) },
		{ Name = "Depth", Value = Scope:Value(1) },
		{ Name = "Head", Value = Scope:Value(1) },
	}

	for _, ScaleProperty in ipairs(ScaleProperties) do
		Scope:Observer(ScaleProperty.Value):onChange(function()
			AvatarManager:UpdateScale(ScaleProperty.Name, Fusion.peek(ScaleProperty.Value))
		end)
	end

	AvatarManager.Updated:Connect(function()
		if AvatarManager.HumanoidDescriber == nil then return end

		local Data = AvatarManager.HumanoidDescriber:GetData()

		for _, ScaleProperty in ipairs(ScaleProperties) do
			local ExistingScale = Data.Scale[ScaleProperty.Name]
			local ScaleLimit = ScaleLimits[ScaleProperty.Name]
			if ExistingScale then
				ScaleProperty.Value:set(StretchNumber(ExistingScale, ScaleLimit.Min, ScaleLimit.Max))
			end
		end
	end)

	return Scope:Scroller(OnyxUI.Util.CombineProps(Props, {
		Name = script.Name,
		ListEnabled = true,
		ListHorizontalFlex = Enum.UIFlexAlignment.Fill,
		Visible = Shown,
		CanvasSize = UDim2.new(),
		PaddingRight = Scope:Computed(function(Use)
			return UDim.new(0, Use(Theme.Spacing["1"]))
		end),
		Padding = Scope:Computed(function(Use)
			return UDim.new(0, Use(Theme.Spacing["0"]))
		end),

		[Children] = {
			Scope:ForValues(ScaleProperties, function(Use, Scope, ScaleProperty)
				return OnyxUI.Themer.Theme:is(Fusion.peek(States.Theme)):during(function()
					return Scope:SliderSetting {
						Label = ScaleProperty.Name,
						Value = ScaleProperty.Value,
					}
				end)
			end),
		},
	}))
end
