local RunService = game:GetService("RunService")

local Avalog = script.Parent.Parent.Parent.Parent.Parent
local States = require(script.Parent.Parent.States)
local Sift = require(Avalog.Parent.Sift)
local Types = require(Avalog.SourceCode.Shared.Types)

local Zap
if RunService:IsRunning() then
	Zap = require(Avalog.SourceCode.Shared.Zap.client)
end

local CloudConfig = {}

function CloudConfig.Start()
	if Zap ~= nil then
		Zap.CloudConfigReset.SetCallback(function()
			CloudConfig:FetchData()
		end)

		CloudConfig.FetchData()
	end
end

function CloudConfig.FetchData()
	if Zap == nil then
		return
	end

	local Data = Zap.GetCloudConfig.Call()
	if Data ~= nil then
		local SafeData = Sift.Dictionary.mergeDeep(Types.AvalogConfig.Fallback, Data)
		States.CloudConfig:set(SafeData)
	end
end

return CloudConfig
