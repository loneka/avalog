local MarketplaceService = game:GetService("MarketplaceService")

local Avalog = script.Parent.Parent.Parent
local Future = require(Avalog.Parent.Future)
local RateLimit = require(Avalog.Parent.RateLimit)
local HumanoidDescriber = require(Avalog.Parent.HumanoidDescriber)
local Zap = require(Avalog.SourceCode.Shared.Zap.server)
local EnumSerDes = require(Avalog.Parent.EnumSerDes)
local PlayerDataStore = require(Avalog.SourceCode.Server.PlayerDataStorage.PlayerDataStore)
local Squash = require(Avalog.Parent.Squash)
local AvatarDataSerDes = require(Avalog.SourceCode.Server.PlayerDataStorage.SerDes.AvatarData)
local Config = require(Avalog.Config)

local CONFIG = Config:Get()
local RATE_LIMITS = {
	Update = RateLimit(1, 1),
	BulkPurchaseItems = RateLimit(1, 2),
}

local Avatar = {
	Avatars = {},
}

function Avatar:HandleProfile(Player: Player, Profile)
	if not Player:HasAppearanceLoaded() then
		Player.CharacterAppearanceLoaded:Wait()
	end

	Player.CharacterAppearanceLoaded:Connect(function()
		local Data = Profile.Data:Get()

		if Data.Avatar.Data ~= nil then
			local Cursor = Squash.frombuffer(Data.Avatar.Data)
			local AvatarData = AvatarDataSerDes.des(Cursor)

			Avatar:ApplyData(Player, AvatarData)
		end
	end)

	Profile.Data:Observe(function(_, Data)
		if Data.Avatar.Data then
			local Cursor = Squash.frombuffer(Data.Avatar.Data)
			local AvatarData = AvatarDataSerDes.des(Cursor)

			Avatar:ApplyData(Player, AvatarData)
		end
	end)
end

function Avatar:BulkPurchaseItems(Player: Player, Items: { { Id: string, Type: Enum.AvatarItemType } })
	Future.Try(function()
		return MarketplaceService:PromptBulkPurchase(Player, Items, {})
	end):After(function(Success, Result)
		if not Success then
			warn(Result)
		end
	end)
end

function Avatar:UpdateData(Player: Player, Data: HumanoidDescriber.Data)
	local Profile = PlayerDataStore:Get(Player)

	if Profile ~= nil then
		Profile.Session:patch(PlayerDataStore.Actions.SetAvatarData, Data)
	else
		Avatar:ApplyData(Player, Data)
	end
end

function Avatar:ApplyData(Player: Player, Data: HumanoidDescriber.Data)
	local _, Humanoid, HumanoidDescription = Avatar:GetCharacterObjects(Player)
	if Humanoid and HumanoidDescription then
		local HumanoidDescriberObject = HumanoidDescriber(HumanoidDescription)

		if Data.Clothing.Shirt == 0 then
			Data.Clothing.Shirt = 855777286
		end
		if Data.Clothing.Pants == 0 then
			Data.Clothing.Pants = 855782781
		end

		HumanoidDescriberObject:UpdateData(function()
			return Data
		end)

		Avatar:Apply(Player, HumanoidDescription):Await()

		HumanoidDescriberObject:Destroy()
	end
end

function Avatar:Apply(Player: Player, HumanoidDescription: HumanoidDescription)
	local Character = Player.Character

	if Character then
		local Humanoid = Character:FindFirstChildOfClass("Humanoid")
		if Humanoid then
			return Future.Try(function()
				Humanoid:ApplyDescriptionReset(HumanoidDescription)
			end)
		end
	end

	return false
end

function Avatar:GetCharacterObjects(Player: Player): (Model?, Humanoid?, HumanoidDescription?)
	local Character = Player.Character

	if Character then
		local Humanoid = Character:FindFirstChildOfClass("Humanoid")
		if Humanoid then
			return Character, Humanoid, Humanoid:FindFirstChildOfClass("HumanoidDescription")
		end
	end

	return nil
end

function Avatar:Start()
	Zap.BulkPurchaseAvatarItems.SetCallback(function(Player, Items)
		if RATE_LIMITS.BulkPurchaseItems(Player.UserId) then
			local SafeItems: HumanoidDescriber.Data = EnumSerDes.DeserializeTree(Items)

			return Avatar:BulkPurchaseItems(Player, SafeItems)
		end
	end)

	Zap.UpdateAvatar.SetCallback(function(Player, Data): ()
		if not CONFIG.AvatarSavingAllowed then
			return
		end

		if RATE_LIMITS.Update(Player.UserId) then
			local SafeData: HumanoidDescriber.Data = EnumSerDes.DeserializeTree(Data)

			return Avatar:UpdateData(Player, SafeData)
		end
	end)

	PlayerDataStore.Loaded:Connect(function(Player, Profile)
		Avatar:HandleProfile(Player, Profile)
	end)

	for Player, Profile in pairs(PlayerDataStore.Profiles) do
		Avatar:HandleProfile(Player, Profile)
	end
end

return Avatar
