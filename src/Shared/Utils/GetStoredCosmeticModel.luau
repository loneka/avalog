local ReplicatedStorage = game:GetService("ReplicatedStorage")

local CosmeticsStorage: Folder? = nil

local function GetModelByDomain(Id: string)
	if CosmeticsStorage == nil then
		CosmeticsStorage = ReplicatedStorage:WaitForChild("AVALOG_COSMETICS")
	end
	if CosmeticsStorage ~= nil then
		return CosmeticsStorage:WaitForChild(Id):Clone()
	end
end

return GetModelByDomain
