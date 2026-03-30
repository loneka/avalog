local Avalog = require(script.Parent.Parent.Avalog)
local Config = require(script.Parent.Config)
local Icon = require(script.Parent.Parent.Avalog.Packages.TopbarPlus)

Avalog.Config:Update(Config)

Avalog:Start()

local AvalogIcon = Icon.new():setImage("rbxassetid://109049301067448"):setLeft():setImageScale(0.55)

AvalogIcon.toggled:Connect(function()
	Avalog:ToggleOpen()
end)
