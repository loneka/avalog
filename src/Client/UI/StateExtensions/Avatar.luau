local Players = game:GetService("Players")

local Avalog = script.Parent.Parent.Parent.Parent.Parent
local States = require(script.Parent.Parent.States)
local Fusion = require(Avalog.Parent.Fusion)
local CatalogItems = require(Avalog.SourceCode.Client.UI.StateExtensions.CatalogItems)
local ServiceProvider = require(Avalog.SourceCode.Client.ServiceProvider)
local HumanoidDescriber = require(Avalog.Parent.HumanoidDescriber)
local DeepEquals = require(Avalog.SourceCode.Shared.Utils.DeepEquals)

local Avatar = {
	_Connections = {},
}

function Avatar:_LogHistoryEntry(NewData: HumanoidDescriber.Data)
	local HistoryDataValue = Fusion.peek(States.Avatar.DataHistory)

	local AlreadyExists = false
	for _, DataEntry in ipairs(HistoryDataValue) do
		if DeepEquals(DataEntry, NewData) then
			AlreadyExists = true
			break
		end
	end

	if AlreadyExists == false then
		table.insert(HistoryDataValue, NewData)
		States.Avatar.UndoHistory:set({})
	end

	States.Avatar.DataHistory:set(HistoryDataValue)
end

function Avatar:_UpdateEquippedBundles()
	local EquippedAssetIdsValue = Fusion.peek(States.Avatar.EquippedAssetIds)
	local BundleIds = {}

	for _, AssetId in ipairs(EquippedAssetIdsValue) do
		local BundleId = CatalogItems:GetBundleIdFromAsset(AssetId)
		if BundleId and (table.find(BundleIds, BundleId) == nil) then
			table.insert(BundleIds, BundleId)
		end
	end

	States.Avatar.EquippedBundleIds:set(BundleIds)
end

function Avatar:_UpdateEquippedAssetIds()
	local AvatarManager = ServiceProvider:GetAvatarManager()
	local AssetIdsValue = Fusion.peek(States.Avatar.AssetIds)
	local UnequippedAssetIds = {}

	States.Avatar.EquippedAssetIds:set(AssetIdsValue)

	for _, AssetId in ipairs(AssetIdsValue) do
		local CatalogInfo = CatalogItems:GetItem(AssetId, Enum.InfoType.Asset)
		if CatalogInfo and (CatalogInfo.AssetType == Enum.AvatarAssetType.EmoteAnimation) then
			if AvatarManager.HumanoidDescriber:GetEquippedEmote(CatalogInfo.Name) == nil then
				table.insert(UnequippedAssetIds, AssetId)
			end
		end
	end

	for _, AssetId in ipairs(UnequippedAssetIds) do
		local Index = table.find(AssetIdsValue, AssetId)
		if Index ~= nil then
			table.remove(AssetIdsValue, Index)
		end
	end

	States.Avatar.EquippedAssetIds:set(AssetIdsValue)
end

function Avatar:_HandleAvatar()
	local AvatarManager = ServiceProvider:GetAvatarManager()

	if AvatarManager.Character == nil then
		-- Reset all states
		States.Avatar.Character:set(nil)
		States.Avatar.Loaded:set(false)
		States.Avatar.Data:set(nil)
		States.Avatar.DataHistory:set({})
		States.Avatar.UndoHistory:set({})
		States.Avatar.AssetIds:set({})
		States.Avatar.EquippedAssetIds:set({})
		States.Avatar.EquippedBundleIds:set({})
		return
	end

	States.Avatar.Loaded:set(false)

	local Data = AvatarManager.HumanoidDescriber:GetData()

	local function Update(NewData)
		States.Avatar.Data:set(NewData)
		self:_LogHistoryEntry(NewData)

		States.Avatar.AssetIds:set(AvatarManager.HumanoidDescriber:GetAssets())
		self:_UpdateEquippedAssetIds()
		self:_UpdateEquippedBundles()

		AvatarManager:GetUnownedItems()
	end

	States.Avatar.Character:set(AvatarManager.Character)

	AvatarManager.HumanoidDescriber.Updated:Connect(function(_, NewData)
		Update(NewData)
	end)
	task.spawn(function()
		Update(Data)
	end)

	States.Avatar.Loaded:set(true)
end

function Avatar:Stop()
	for _, Connection: RBXScriptConnection in ipairs(self._Connections) do
		Connection:Disconnect()
	end
end

function Avatar:Start()
	local AvatarManager = ServiceProvider:GetAvatarManager()
	table.insert(
		Avatar._Connections,
		AvatarManager.Updated:Connect(function()
			Avatar:_HandleAvatar()
		end)
	)

	Avatar:_HandleAvatar()
end

return Avatar
