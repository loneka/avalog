local function GetAppliedCosmetic(Character: Model, Id: string): Instance?
	for _, Descendant in Character:GetDescendants() do
		if Descendant:GetAttribute("CosmeticId") == Id then
			return Descendant
		end
	end

	return nil
end

return GetAppliedCosmetic
