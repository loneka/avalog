--[[
	Handles interaction with external cloud APIs.
]]

local Avalog = script.Parent.Parent.Parent
local Zap = require(Avalog.SourceCode.Shared.Zap.server)
local Fetch = require(Avalog.Parent.Fetch)
local RateLimit = require(Avalog.Parent.RateLimit)
local Stator = require(Avalog.Parent.Stator)

local BASE_URL = "http://loneka.com/api/v1/avalog"
local UPDATE_DELAY = 30 * 60
local FAILED_UPDATE_DELAY = 1 * 60
local RATE_LIMITS = {
	GetCloudConfig = RateLimit(1, 10),
}

local Cloud = {
	HttpEnabled = false,
	Config = {
		Data = Stator(),
	},
}

function Cloud.Start(self: typeof(Cloud))
	self:IsHttpEnabled()

	task.spawn(function()
		while true do
			local Success = self:UpdateConfig()

			if Success then
				task.wait(UPDATE_DELAY)
			else
				task.wait(FAILED_UPDATE_DELAY)
			end
		end
	end)

	Zap.GetCloudConfig.SetCallback(function(Player: Player)
		if RATE_LIMITS.GetCloudConfig(Player) then
			return Cloud.Config.Data:Get()
		end
	end)
end

function Cloud.IsHttpEnabled(self: typeof(Cloud))
	local Success = self:UpdateConfig()

	self.HttpEnabled = Success

	return Success
end

function Cloud.UpdateConfig(_self: typeof(Cloud))
	local Success, Response = Fetch(BASE_URL .. "/app-config", {
		Headers = {
			["Experience-Id"] = tostring(game.GameId),
			["Place-Id"] = tostring(game.PlaceId),
		},
	}):Await()

	if Success and Response.Ok then
		local DecodeSuccess, Data = Response:Json()

		if DecodeSuccess then
			Cloud.Config.Data:Update(function()
				return Data
			end)

			Zap.CloudConfigReset.FireAll()
		end
	else
		warn(Response)
	end

	return Success, Response
end

function Cloud.Destroy(_self: typeof(Cloud)) end

return Cloud
