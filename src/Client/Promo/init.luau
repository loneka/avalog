local RunService = game:GetService("RunService")

local Avalog = script.Parent.Parent.Parent
local Version = require(Avalog.SourceCode.Shared.Version)

local Promo = {}

function Promo:Start()
	if not RunService:IsStudio() then
		print(`Running Avalog {Version} 🛠️\n> https://devforum.roblox.com/t/3513102`)
	end
end

return Promo
