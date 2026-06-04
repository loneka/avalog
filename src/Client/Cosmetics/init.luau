--[[
	Handles client previews of cosmetics
]]

local Avalog = script.Parent.Parent.Parent
local LocalAvatar = require(script.Parent.Avatar.LocalAvatar)
local AssetIdsFromAvatarData = require(Avalog.SourceCode.Shared.Utils.AssetIdsFromAvatarData)
local ApplyCosmetic = require(Avalog.SourceCode.Shared.Utils.ApplyCosmetic)
local States = require(Avalog.SourceCode.Client.UI.States)
local Fusion = require(Avalog.Parent.Fusion)
local GetStoredCosmeticModel = require(Avalog.SourceCode.Shared.Utils.GetStoredCosmeticModel)

local Cosmetics = {}

function Cosmetics.Start(_self: typeof(Cosmetics))
	-- Handle cosmetics on avatar update
	local UpdateListener: RBXScriptConnection? = nil
	LocalAvatar.Updated:Connect(function()
		if UpdateListener ~= nil then
			UpdateListener:Disconnect()
			UpdateListener = nil
		end

		UpdateListener = LocalAvatar.Humanoid.ApplyDescriptionFinished:Connect(function()
			local Data = LocalAvatar.HumanoidDescriber:GetData()
			local AppliedAssetIds = AssetIdsFromAvatarData(Data)
			local CloudConfig = Fusion.peek(States.CloudConfig)

			if CloudConfig and CloudConfig.cosmeticItems then
				for _, Cosmetic in CloudConfig.cosmeticItems do
					if Cosmetic.itemType == "Asset" and table.find(AppliedAssetIds, Cosmetic.itemId) ~= nil then
						ApplyCosmetic(LocalAvatar.Character, Cosmetic.itemId, GetStoredCosmeticModel(Cosmetic.itemId))
						LocalAvatar.Humanoid:BuildRigFromAttachments()
					end
				end
			end
		end)
	end)
end

function Cosmetics.Destroy(_self: typeof(Cosmetics)) end

return Cosmetics
