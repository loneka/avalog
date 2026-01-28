local Avalog = script.Parent.Parent.Parent
local AvatarAssetTypes = require(script.Parent.AvatarAssetTypes)
local Sift = require(Avalog.Parent.Sift)

export type Category = {
	Name: string,
	SubCategories: { Category }?,
	AssetTypes: { Enum.AvatarAssetType }?,
	BundleTypes: { Enum.BundleType }?,
}

local function PurgeBundles(Categories: { Category }): { Category }
	local Result = {}

	for _, Category in Categories do
		local PurgedSubCategories = nil

		if Category.SubCategories then
			PurgedSubCategories = PurgeBundles(Category.SubCategories)

			if #PurgedSubCategories == 0 then
				PurgedSubCategories = nil
			end
		end

		if Category.AssetTypes or PurgedSubCategories then
			table.insert(Result, {
				Name = Category.Name,
				AssetTypes = Category.AssetTypes,
				BundleTypes = Category.BundleTypes,
				SubCategories = PurgedSubCategories,
			})
		end
	end

	return Result
end

local Categories: { [string]: { Category } } = {
	Marketplace = {
		{
			Name = "Featured",
			AssetTypes = AvatarAssetTypes.Types.All,
			BundleTypes = {
				Enum.BundleType.Animations,
				Enum.BundleType.BodyParts,
				Enum.BundleType.DynamicHead,
				Enum.BundleType.DynamicHeadAvatar,
				Enum.BundleType.Shoes,
			},
		},
		{
			Name = "Body",
			SubCategories = {
				{
					Name = "Characters",
					BundleTypes = {
						Enum.BundleType.BodyParts,
					},
				},
				{
					Name = "Heads",
					BundleTypes = { Enum.BundleType.DynamicHead },
					AssetTypes = { Enum.AvatarAssetType.DynamicHead, Enum.AvatarAssetType.Head },
				},
				{
					Name = "Faces",
					AssetTypes = { Enum.AvatarAssetType.Face },
				},
				{ Name = "Hair", AssetTypes = { Enum.AvatarAssetType.HairAccessory } },
			},
		},
		{
			Name = "Clothing",
			SubCategories = {
				{ Name = "Shirts", AssetTypes = { Enum.AvatarAssetType.ShirtAccessory } },
				{ Name = "T-Shirts", AssetTypes = { Enum.AvatarAssetType.TShirtAccessory } },
				{ Name = "Sweaters", AssetTypes = { Enum.AvatarAssetType.SweaterAccessory } },
				{ Name = "Jackets", AssetTypes = { Enum.AvatarAssetType.JacketAccessory } },
				{ Name = "Pants", AssetTypes = { Enum.AvatarAssetType.PantsAccessory } },
				{ Name = "Dresses & Skirts", AssetTypes = { Enum.AvatarAssetType.DressSkirtAccessory } },
				{ Name = "Shorts", AssetTypes = { Enum.AvatarAssetType.ShortsAccessory } },
				{
					Name = "Shoes",
					AssetTypes = { Enum.AvatarAssetType.LeftShoeAccessory, Enum.AvatarAssetType.RightShoeAccessory },
				},
				{ Name = "Classic Shirts", AssetTypes = { Enum.AvatarAssetType.Shirt } },
				{ Name = "Classic T-Shirts", AssetTypes = { Enum.AvatarAssetType.TShirt } },
				{ Name = "Classic Pants", AssetTypes = { Enum.AvatarAssetType.Pants } },
			},
		},
		{
			Name = "Accessories",
			SubCategories = {
				{ Name = "Head", AssetTypes = { Enum.AvatarAssetType.Hat } },
				{ Name = "Face", AssetTypes = { Enum.AvatarAssetType.FaceAccessory } },
				{ Name = "Neck", AssetTypes = { Enum.AvatarAssetType.NeckAccessory } },
				{ Name = "Shoulder", AssetTypes = { Enum.AvatarAssetType.ShoulderAccessory } },
				{ Name = "Front", AssetTypes = { Enum.AvatarAssetType.FrontAccessory } },
				{ Name = "Back", AssetTypes = { Enum.AvatarAssetType.BackAccessory } },
				{ Name = "Waist", AssetTypes = { Enum.AvatarAssetType.WaistAccessory } },
			},
		},
		{
			Name = "Animation",
			SubCategories = {
				{
					Name = "Bundles",
					BundleTypes = { Enum.BundleType.Animations },
					AssetTypes = AvatarAssetTypes.Types.Animations,
				},
				{ Name = "Emotes", AssetTypes = AvatarAssetTypes.Types.Emotes },
			},
		},
	},
	Inventory = {},
	Customize = { { Name = "Equipped" }, { Name = "Skin" }, { Name = "Build" } },
}

Categories.Inventory = PurgeBundles(Categories.Marketplace)

return Categories
