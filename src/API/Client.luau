local SOURCE = script.Parent.SourceCode
local PACKAGES = script.Parent.Parent
local CLIENT = SOURCE.Client

local Players = game:GetService("Players")

local States = require(SOURCE.Client.UI.States)
local Fusion = require(PACKAGES.Fusion)
local Bootloader = require(PACKAGES.Bootloader)
local Config = require(script.Parent.Config)
local ServiceProvider = require(CLIENT.ServiceProvider)
local LocalAvatar = require(CLIENT.Avatar.LocalAvatar)

local function GetModules()
	local Modules = {}

	for _, Child in ipairs(CLIENT:GetChildren()) do
		if Child:IsA("ModuleScript") then
			table.insert(Modules, Child)
		end
	end

	return Modules
end

local function IsLocked(): boolean
	return Players.LocalPlayer:GetAttribute("AvalogCustomizationLocked") == true
end

--[=[
	@class AvalogClient

	The client-side module of Avalog.
]=]
local AvalogClient = {
	Config = Config,
	Started = false,
	_Bootloader = Bootloader(GetModules()),
	_ServiceProvider = ServiceProvider,
}

--[=[
	Starts Avalog on the client.
]=]
function AvalogClient:Start()
	assert(not self.Started, "Avalog already started.")
	self.Started = true

	AvalogClient._ServiceProvider:Setup({
		AvatarManager = LocalAvatar,
	})

	AvalogClient._Bootloader:Initialize()
	AvalogClient._Bootloader:Start()

	Players.LocalPlayer:GetAttributeChangedSignal("AvalogCustomizationLocked"):Connect(function()
		if IsLocked() then
			States.Open:set(false)
		end
	end)
end

--[=[
	Configures Avalog with the given config.

	@param NewConfig Config
]=]
function AvalogClient:Configure(NewConfig: Config.Config)
	AvalogClient.Config:Update(NewConfig)
end

--[=[
	Toggles whether or not Avalog is open. Avalog can't be opened while customization is locked.
]=]
function AvalogClient:ToggleOpen()
	States.Open:set(not Fusion.peek(States.Open) and not IsLocked())
end

--[=[
	Sets whether or not Avalog is open. Avalog can't be opened while customization is locked.

	@param Open boolean
]=]
function AvalogClient:SetOpen(Open: boolean)
	States.Open:set(Open and not IsLocked())
end

--[=[
	Prompts the player to purchase the items they are wearing but don't own.

	@return boolean -- Whether or not a prompt was shown.
]=]
function AvalogClient:PromptPurchaseOutfit(): boolean
	return LocalAvatar:PromptCheckout(LocalAvatar:GetUnownedItems())
end

return AvalogClient
