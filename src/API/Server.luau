local SOURCE = script.Parent.SourceCode
local PACKAGES = script.Parent.Parent
local SERVER = SOURCE.Server

local Config = require(script.Parent.Config)
local Bootloader = require(PACKAGES.Bootloader)

local function GetModules()
	local Modules = {}

	for _, Child in ipairs(SERVER:GetChildren()) do
		if Child:IsA("ModuleScript") then
			table.insert(Modules, Child)
		end
	end

	return Modules
end

--[=[
	@class AvalogServer

	The server-side module of Avalog.
]=]
local AvalogServer = {
	Config = Config,
	Bootloader = Bootloader(GetModules()),
	Started = false,
}

--[=[
	Starts Avalog on the server.
]=]
function AvalogServer:Start()
	assert(not self.Started, "Avalog already started.")
	self.Started = true

	AvalogServer.Bootloader:Initialize()
	AvalogServer.Bootloader:Start()
end

--[=[
	Configures Avalog with the given config.

	@param NewConfig Config
]=]
function AvalogServer:Configure(NewConfig: Config.Config)
	AvalogServer.Config:Update(NewConfig)
end

--[=[
	Sets whether or not a player is prevented from changing their avatar.

	@param Player Player
	@param Locked boolean
]=]
function AvalogServer:SetCustomizationLocked(Player: Player, Locked: boolean)
	Player:SetAttribute("AvalogCustomizationLocked", if Locked then true else nil)
end

return AvalogServer
