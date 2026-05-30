local HttpService = game:GetService("HttpService")

local function IsCosmeticApplied(Character: Model, Id: string)
	for _, Descendant in Character:GetDescendants() do
		if Descendant:GetAttribute("CosmeticId") == Id then
			return true
		end
	end

	return false
end

local function ApplyCosmetic(Character: Model, Id: string, Model: Instance): true?
	if IsCosmeticApplied(Character, Id) then
		return
	end

	local InjectionType = Model:GetAttribute("InjectionType")
	if InjectionType == "Accessory" then
		if not Model:IsA("Accessory") then
			warn(`Cosmetic model {Id} has Accessory InjectionType but is not an accessory.`)
			return
		end

		local Humanoid = Character:FindFirstChildOfClass("Humanoid")
		if Humanoid ~= nil then
			Humanoid:AddAccessory(Model)
			return true
		end
	elseif InjectionType == "Path" then
		local InjectionPath = Model:GetAttribute("InjectionPath")
		if typeof(InjectionPath) == "string" then
			local InjectionPathArray = HttpService:JSONDecode(InjectionPath)
			if typeof(InjectionPathArray) == "table" then
				local Descendant = Character :: Instance

				for _, PathStep in InjectionPathArray do
					local NewDescendant = Descendant:FindFirstChild(PathStep)
					if NewDescendant == nil then
						warn(`Cosmetic {Id}'s InjectionPath could not be resolved.`)
						return
					else
						Descendant = NewDescendant
					end
				end

				Model.Parent = Descendant
				return true
			end
		end
	else
		warn(`Cosmetic {Id} has an invalid or missing InjectionType.`)
	end
end

return ApplyCosmetic
