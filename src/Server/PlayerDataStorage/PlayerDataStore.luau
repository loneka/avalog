local Avalog = script.Parent.Parent.Parent.Parent
local Squash = require(Avalog.Parent.Squash)
local DataValidater = require(script.Parent.DataValidater)
local NewPlayerDataStore = require(Avalog.SourceCode.Storage.Utils.PlayerDataStore)
local AvatarDataSerDes = require(script.Parent.SerDes.AvatarData)
local HumanoidDescriber = require(Avalog.Parent.HumanoidDescriber)

export type PlayerData = {
	Avatar: {
		Data: buffer?,
	},
}

local PlayerDataStore = NewPlayerDataStore {
	name = "AvalogPlayerData",
	migrations = {},
	default_data = function()
		return {
			Avatar = {
				Data = nil,
			},
		}
	end,
	schema = DataValidater,
	pull_delay = 60 * 2,
}

local Actions = {
	SetAvatarData = function(Data: PlayerData, AvatarData: HumanoidDescriber.Data)
		assert(AvatarData ~= nil, "Given AvatarData is nil")

		local Cursor = Squash.cursor()
		AvatarDataSerDes.ser(Cursor, AvatarData)

		Data.Avatar.Data = Squash.tobuffer(Cursor)

		return Data
	end,
}

PlayerDataStore.Store:action(Actions.SetAvatarData)

PlayerDataStore.Actions = Actions

return PlayerDataStore
