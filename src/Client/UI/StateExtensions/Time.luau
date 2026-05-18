--[[
	Exposes the current unix timestamp as a Fusion.Value
]]

local RunService = game:GetService("RunService")

local States = require(script.Parent.Parent.States)

local Time = {
	_RenderStep = nil :: RBXScriptConnection?,
}

function Time.Start(self: typeof(Time))
	self._RenderStep = RunService.RenderStepped:Connect(function()
		States.UnixTimestamp:set(DateTime.now().UnixTimestampMillis)
	end)
end

function Time.Destroy(self: typeof(Time))
	self._RenderStep:Destroy()
end

return Time
