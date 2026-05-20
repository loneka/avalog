--[[
	Observes and records menu opening and closing.
]]

local RunService = game:GetService("RunService")

local Avalog = script.Parent.Parent.Parent.Parent.Parent
local Fusion = require(Avalog.Parent.Fusion)
local States = require(script.Parent.Parent.States)
local Zap: typeof(require(Avalog.SourceCode.Shared.Zap.client))? = nil

if RunService:IsRunning() then
	Zap = require(Avalog.SourceCode.Shared.Zap.client)
end

local Scope = Fusion.scoped(Fusion)

local UsageRecorder = {}

function UsageRecorder.Start(_self: typeof(UsageRecorder))
	if Zap ~= nil then
		Scope:Observer(States.Open):onChange(function()
			Zap.RecordMenuToggle.Fire(Fusion.peek(States.Open))
		end)
	end
end

function UsageRecorder.Destroy(_self: typeof(UsageRecorder)) end

return UsageRecorder
