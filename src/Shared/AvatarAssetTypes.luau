local AvatarAssetTypes = {
	Types = {
		RigidAccessories = {
			Enum.AvatarAssetType.BackAccessory,
			Enum.AvatarAssetType.FaceAccessory,
			Enum.AvatarAssetType.HairAccessory,
			Enum.AvatarAssetType.NeckAccessory,
			Enum.AvatarAssetType.FrontAccessory,
			Enum.AvatarAssetType.WaistAccessory,
			Enum.AvatarAssetType.ShoulderAccessory,
			Enum.AvatarAssetType.Hat,
		},
		LayeredClothing = {
			Enum.AvatarAssetType.PantsAccessory,
			Enum.AvatarAssetType.ShirtAccessory,
			Enum.AvatarAssetType.TShirtAccessory,
			Enum.AvatarAssetType.ShortsAccessory,
			Enum.AvatarAssetType.DressSkirtAccessory,
			Enum.AvatarAssetType.JacketAccessory,
			Enum.AvatarAssetType.SweaterAccessory,
			Enum.AvatarAssetType.RightShoeAccessory,
			Enum.AvatarAssetType.LeftShoeAccessory,
		},
		ClassicClothing = {
			Enum.AvatarAssetType.Shirt,
			Enum.AvatarAssetType.TShirt,
			Enum.AvatarAssetType.Pants,
		},
		Emotes = {
			Enum.AvatarAssetType.EmoteAnimation,
		},
		Animations = {
			Enum.AvatarAssetType.RunAnimation,
			Enum.AvatarAssetType.FallAnimation,
			Enum.AvatarAssetType.IdleAnimation,
			Enum.AvatarAssetType.WalkAnimation,
			Enum.AvatarAssetType.SwimAnimation,
			Enum.AvatarAssetType.ClimbAnimation,
			Enum.AvatarAssetType.JumpAnimation,
			Enum.AvatarAssetType.MoodAnimation,
		},
		BodyParts = {
			Enum.AvatarAssetType.Torso,
			Enum.AvatarAssetType.LeftArm,
			Enum.AvatarAssetType.RightArm,
			Enum.AvatarAssetType.LeftLeg,
			Enum.AvatarAssetType.RightLeg,
			Enum.AvatarAssetType.DynamicHead,
		},
		FacialFeatures = {
			Enum.AvatarAssetType.EyebrowAccessory,
			Enum.AvatarAssetType.EyelashAccessory,
		},
		Gear = {
			Enum.AvatarAssetType.Gear,
		},
	},
}

function AvatarAssetTypes:Combine(AssetsTypeLists: { { Enum.AvatarAssetType } }): { Enum.AvatarAssetType }
	local CombinedAssetTypes = {}

	for _, AssetTypes in ipairs(AssetsTypeLists) do
		for _, AssetType in ipairs(AssetTypes) do
			if table.find(CombinedAssetTypes, AssetType) == nil then
				table.insert(CombinedAssetTypes, AssetType)
			end
		end
	end

	return CombinedAssetTypes
end

function AvatarAssetTypes:Flatten(AssetTypeCategories: { [string]: { Enum.AvatarAssetType } })
	local AssetsTypeLists = {}

	for _, AssetsTypeList in pairs(AssetTypeCategories) do
		table.insert(AssetsTypeLists, AssetsTypeList)
	end

	return AssetsTypeLists
end

AvatarAssetTypes.Types.All = AvatarAssetTypes:Combine(AvatarAssetTypes:Flatten(AvatarAssetTypes.Types))
AvatarAssetTypes.Types.Clothing =
	AvatarAssetTypes:Combine({ AvatarAssetTypes.Types.ClassicClothing, AvatarAssetTypes.Types.LayeredClothing })
AvatarAssetTypes.Types.Accessories = AvatarAssetTypes:Combine({
	AvatarAssetTypes.Types.RigidAccessories,
	AvatarAssetTypes.Types.LayeredClothing,
	AvatarAssetTypes.Types.FacialFeatures,
})

return AvatarAssetTypes
