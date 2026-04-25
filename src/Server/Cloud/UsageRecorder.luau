--[[
	Records in-game usage of Avalog.
]]

local Players = game:GetService("Players")

local Avalog = script.Parent.Parent.Parent.Parent
local Types = require(Avalog.SourceCode.Shared.Types)
local Sift = require(Avalog.Parent.Sift)

export type Session = {
	UserId: number,
	StartTime: number,
	EndTime: number?,
	MenuSessions: {
		{
			StartTime: number,
			EndTime: number,
		}
	},
}

local UsageRecorder = {
	ServerStartTime = os.time(),
	Sessions = {} :: { Session },
}

function UsageRecorder.Start(self: typeof(UsageRecorder))
	Players.PlayerAdded:Connect(function(Player)
		self:_NewSession(Player.UserId)
	end)
	for _, Player in Players:GetPlayers() do
		self:_NewSession(Player.UserId)
	end

	Players.PlayerRemoving:Connect(function(Player)
		local Session = self:_FindLastSession(Player.UserId)
		if Session ~= nil then
			Session.EndTime = os.time()
			self:RecordMenuToggle(Player.UserId, false)
		end
	end)
end

function UsageRecorder._NewSession(self: typeof(UsageRecorder), UserId: number)
	if self:_FindLastSession(UserId) ~= nil then
		return
	end

	table.insert(self.Sessions, {
		UserId = UserId,
		StartTime = os.time(),
		MenuSessions = {},
	})
end

function UsageRecorder._FindLastSession(self: typeof(UsageRecorder), UserId: number): Session?
	for Index = #self.Sessions, 1, -1 do
		local Session = self.Sessions[Index]

		if Session.UserId == UserId then
			return Session
		end
	end
end

function UsageRecorder.RecordMenuToggle(self: typeof(UsageRecorder), UserId: number, Open: boolean)
	local Session = self:_FindLastSession(UserId)

	if Session ~= nil then
		if Open then
			table.insert(Session.MenuSessions, {
				StartTime = os.time(),
			})
		else
			local LastMenuSession = Session.MenuSessions[#Session.MenuSessions]
			if LastMenuSession == nil then
				return
			end
			if LastMenuSession.EndTime ~= nil then
				return
			end

			LastMenuSession.EndTime = os.time()
		end
	end
end

function UsageRecorder.CompileSnapshot(self: typeof(UsageRecorder)): Types.AvalogUsageSnapshot
	local Snapshot: Types.AvalogUsageSnapshot = {
		experienceId = tostring(game.GameId),
		placeId = tostring(game.PlaceId),
		jobId = game.JobId,
		uptime = os.time() - self.ServerStartTime,
		totalMenuOpens = Sift.Array.reduce(self.Sessions, function(Accumulator: number, Session: Session)
			return Accumulator + #Session.MenuSessions
		end, 0),
		totalMenuTime = Sift.Array.reduce(self.Sessions, function(Accumulator: number, Session: Session)
			return Accumulator
				+ Sift.Array.reduce(Session.MenuSessions, function(Accumulator2: number, MenuSession)
					if MenuSession.StartTime and MenuSession.EndTime then
						Accumulator2 += (MenuSession.EndTime - MenuSession.StartTime)
					end

					return Accumulator2
				end, 0)
		end, 0),
		totalUserSessions = #self.Sessions,
		totalUserPlaytime = Sift.Array.reduce(self.Sessions, function(Accumulator: number, Session: Session)
			if Session.StartTime and Session.EndTime then
				Accumulator += (Session.EndTime - Session.StartTime)
			end

			return Accumulator
		end, 0),
	}

	return Snapshot
end

function UsageRecorder.Destroy(_self: typeof(UsageRecorder)) end

return UsageRecorder
