local Avalog = script.Parent.Parent.Parent
local PlayerDataStore = require(script.PlayerDataStore)
local Config = require(Avalog.Config)

local CONFIG = Config:Get()

local PlayerDataStorage = {
	Store = PlayerDataStore,
}

function PlayerDataStorage:Start()
	if CONFIG.DataStoreEnabled then
		PlayerDataStore:Start()
	end
end

return PlayerDataStorage
