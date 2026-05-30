local function AssetIdsFromAvatarData(AvatarData): { string }
	local AssetIds = {
		AvatarData.Face,
	}

	for _, Accessory in AvatarData.Accessories do
		table.insert(AssetIds, Accessory.AssetId)
	end
	for _, AssetId in AvatarData.Clothing do
		table.insert(AssetIds, AssetId)
	end
	for _, EmoteAssetIds in AvatarData.Emotes do
		table.insert(AssetIds, EmoteAssetIds[1])
	end

	for Key, Value in AssetIds do
		AssetIds[Key] = tostring(Value)
	end

	return AssetIds
end

return AssetIdsFromAvatarData
