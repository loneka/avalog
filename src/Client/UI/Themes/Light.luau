local Avalog = script.Parent.Parent.Parent.Parent.Parent
local OnyxUI = require(Avalog.Parent.OnyxUI)
local Fusion = require(Avalog.Parent.Fusion)
local ColorUtils = require(Avalog.Parent.ColorUtils)

local Util = OnyxUI.Util
local Themer = OnyxUI.Themer

local Scope = Fusion.scoped(Fusion)

return Themer.NewTheme(Scope, {
	Colors = {
		Primary = {
			Main = Color3.fromHex("#0A0B14"),
		},
		Secondary = {
			Main = Color3.fromHex("#0A0B14"),
		},
		Accent = {
			Main = Color3.fromHex("#0A0B14"),
		},

		Neutral = {
			Main = Color3.fromHex("#e3e2e6"),
			Light = Util.Colors.Stone["50"],
			Dark = Util.Colors.Stone["100"],
		},
		NeutralContent = {
			Main = Util.Colors.Stone["800"],
			Dark = ColorUtils.Darken(Util.Colors.Stone["800"], 0.2),
		},

		Base = {
			Main = Color3.fromHex("#FBFAFD"),
		},
		BaseContent = {
			Main = Color3.fromHex("#0A0B14"),
		},

		Success = {
			Main = Util.Colors.Green["500"],
		},
		Error = {
			Main = Util.Colors.Red["500"],
		},
		Warning = {
			Main = Util.Colors.Amber["500"],
		},
		Info = {
			Main = Util.Colors.Blue["400"],
		},
	},
	Font = {
		Body = "rbxasset://fonts/families/Montserrat.json",
		Heading = "rbxasset://fonts/families/Montserrat.json",
		Monospace = "rbxasset://fonts/families/Montserrat.json",
	},
	FontWeight = {
		Body = Enum.FontWeight.SemiBold,
		Bold = Enum.FontWeight.Bold,
		Heading = Enum.FontWeight.Bold,
	},
	TextSize = {
		Base = 18,
	},
	CornerRadius = {
		Base = 6,
	},
	StrokeThickness = {
		Base = 1,
	},
	Spacing = {
		Base = 16,
	},
	SpringSpeed = {
		Base = 60,
	},
	SpringDampening = {
		Base = 1.25,
	},
	Sound = {
		Hover = Scope:New "Sound" {
			SoundId = "rbxassetid://10066936758",
			Volume = 0,
		},
		Click = Scope:New "Sound" {
			SoundId = "rbxassetid://16480549841",
			Volume = 0,
		},
		Focus = Scope:New "Sound" {
			SoundId = "rbxassetid://16480549841",
			Volume = 0,
		},
		Switch = Scope:New "Sound" {
			SoundId = "rbxassetid://9119713951",
			Volume = 0,
		},
	},
	Emphasis = {
		Light = 0.1,
		Regular = 0.15,
		Strong = 0.5,
		Contrast = 1,
	},
})
