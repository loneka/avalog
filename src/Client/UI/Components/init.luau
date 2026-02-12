local STORY_EXTENSION = ".story"

local Components = {
	CatalogMenu = require(script.CatalogMenu),
	Tabs = require(script.Tabs),
	ItemButton = require(script.ItemButton),
	CustomButton = require(script.CustomButton),
	AvatarViewport = require(script.AvatarViewport),
	CatalogItemsTab = require(script.CatalogItemsTab),
	CategoryBar = require(script.CategoryBar),
	SkinTab = require(script.SkinTab),
	BuildTab = require(script.BuildTab),
	NavigationBar = require(script.NavigationBar),
	TabDisplay = require(script.TabDisplay),
	ItemsTab = require(script.ItemsTab),
	EquippedItemsTab = require(script.EquippedItemsTab),
	SliderSetting = require(script.SliderSetting),
	InventoryItemsTab = require(script.InventoryItemsTab),
	PrimaryItemsTab = require(script.PrimaryItemsTab),
	UpdatesIndicator = require(script.UpdatesIndicator),
}

for _, Child in ipairs(script:GetChildren()) do
	local LastCharacters = string.sub(Child.Name, -string.len(STORY_EXTENSION))
	if LastCharacters ~= STORY_EXTENSION then
		local Success, Result = pcall(function()
			return require(Child)
		end)
		if Success then
			if Components[Child.Name] ~= Result then
				warn(`Component`, Child, `is not listed.`)
			end
		else
			warn(Child, "errored during require.")
		end
	end
end

return Components
