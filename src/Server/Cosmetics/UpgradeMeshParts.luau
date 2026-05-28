local AssetService = game:GetService("AssetService")
local ReflectionService = game:GetService("ReflectionService")

local MESH_PART_PROPS = ReflectionService:GetPropertiesOfClass("MeshPart")

--[[
	Reinstantiates the given `MeshParts` to have valid mesh content.
]]
local function UpgradeMeshParts(MeshParts: { MeshPart }): { MeshPart }
	local UpgradedMeshParts = {}

	for _, OldMeshPart in MeshParts do
		assert(OldMeshPart:IsA("MeshPart"), "Instance is not a MeshPart")

		-- Collect data from old MeshPart
		local Properties = {}
		local PropertyAttributes = {}

		for Key, Value in OldMeshPart:GetAttributes() do
			local Property = string.match(Key, "^PROPERTY_(.+)")
			if Property ~= nil then
				PropertyAttributes[Property] = Value
			end
		end

		-- Conversion is pointless if there's no MeshId
		if PropertyAttributes["MeshId"] == nil then
			continue
		end

		for _, ReflectedProperty in MESH_PART_PROPS do
			pcall(function()
				Properties[ReflectedProperty.Name] = OldMeshPart[ReflectedProperty.Name]
			end)
		end

		-- Construct new MeshPart w/ proper mesh data
		local UpgradedMeshPart = AssetService:CreateMeshPartAsync(PropertyAttributes["MeshId"], {
			RenderFidelity = PropertyAttributes["RenderFidelity"],
			CollisionFidelity = PropertyAttributes["CollisionFidelity"],
			FluidFidelity = PropertyAttributes["FluidFidelity"],
		})

		for Key, Value in Properties do
			if PropertyAttributes[Key] == nil then
				pcall(function()
					UpgradedMeshPart[Key] = Value
				end)
			end
		end

		-- Migrate references to old MeshPart
		for _, Descendant in OldMeshPart:GetDescendants() do
			for _, ReflectedProperty in ReflectionService:GetPropertiesOfClass(Descendant.ClassName) do
				pcall(function()
					if Descendant[ReflectedProperty.Name] == OldMeshPart then
						Descendant[ReflectedProperty.Name] = UpgradedMeshPart
					end
				end)
			end
		end

		-- Migrate attributes
		for Key, Value in OldMeshPart:GetAttributes() do
			UpgradedMeshPart:SetAttribute(Key, Value)
		end

		-- Migrate CollectionService tags
		for _, Tag in OldMeshPart:GetTags() do
			UpgradedMeshPart:AddTag(Tag)
		end

		OldMeshPart:Destroy()
		table.insert(UpgradedMeshParts, UpgradedMeshPart)
	end

	return UpgradedMeshParts
end

return UpgradeMeshParts
