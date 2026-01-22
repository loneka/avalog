local Avalog = script.Parent.Parent.Parent.Parent.Parent
local ServiceProvider = require(Avalog.SourceCode.Client.ServiceProvider)
local OnyxUI = require(Avalog.Parent.OnyxUI)
local Fusion = require(Avalog.Parent.Fusion)

local Children = Fusion.Children

local SliderSetting = require(script.Parent.SliderSetting)

export type Props = { [string]: any } & {
	Shown: Fusion.UsedAs<boolean>?,
}

return function(Scope: Fusion.Scope<any>, Props: Props)
	local Scope = Fusion.innerScope(Scope, Fusion, OnyxUI.Util, OnyxUI.Components, {
		SliderSetting = SliderSetting,
	})
	local AvatarManager = ServiceProvider:GetAvatarManager()

	local Shown = OnyxUI.Util.Fallback(Props.Shown, false)

	local Hue = Scope:Value(1)
	local Saturation = Scope:Value(1)
	local Brightness = Scope:Value(1)

	local function UpdateColor()
		local HueValue = Fusion.peek(Hue)
		local SaturationValue = Fusion.peek(Saturation)
		local BrightnessValue = Fusion.peek(Brightness)

		AvatarManager:SetColor(Color3.fromHSV(HueValue, SaturationValue, BrightnessValue))
	end
	Scope:Observer(Hue):onChange(function()
		UpdateColor()
	end)
	Scope:Observer(Saturation):onChange(function()
		UpdateColor()
	end)
	Scope:Observer(Brightness):onChange(function()
		UpdateColor()
	end)

	return Scope:Frame(OnyxUI.Util.CombineProps(Props, {
		Name = script.Name,
		ListEnabled = true,
		ListHorizontalFlex = Enum.UIFlexAlignment.Fill,
		Visible = Shown,

		[Children] = {
			Scope:SliderSetting {
				Label = "Hue",
				Value = Hue,
			},
			Scope:SliderSetting {
				Label = "Saturation",
				Value = Saturation,
			},
			Scope:SliderSetting {
				Label = "Brightness",
				Value = Brightness,
			},
		},
	}))
end
