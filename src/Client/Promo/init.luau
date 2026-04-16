local RunService = game:GetService("RunService")

local Avalog = script.Parent.Parent.Parent
local Manifest = require(Avalog.SourceCode.Shared.Manifest)

local Promo = {}

function Promo:Start()
	if not RunService:IsStudio() then
		print(`Running Avalog {Manifest.Version} 🛠️\n> https://devforum.roblox.com/t/3513102`)
	end
end

return Promo
