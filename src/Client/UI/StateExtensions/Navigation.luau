local Avalog = script.Parent.Parent.Parent.Parent.Parent
local States = require(script.Parent.Parent.States)
local Categories = require(Avalog.SourceCode.Shared.Categories)
local Fusion = require(Avalog.Parent.Fusion)
local Config = require(Avalog.Config)

local Navigation = {}

local Scope = Fusion.scoped(Fusion)

Navigation.Mode = Scope:Computed(function(Use)
	return Config:Get().EditModes[Use(States.Catalog.Mode)]
end)
Navigation.Category = Scope:Computed(function(Use)
	local ActiveModeValue = Use(Navigation.Mode)
	local CategoryValue = Use(States.Catalog.Category)

	return Categories[ActiveModeValue][CategoryValue]
end)
Navigation.SubCategory = Scope:Computed(function(Use)
	local CategoryValue = Use(Navigation.Category)
	local SubCategoryValue = Use(States.Catalog.SubCategory)

	if CategoryValue and CategoryValue.SubCategories then
		return CategoryValue.SubCategories[SubCategoryValue]
	else
		return nil
	end
end)

return Navigation
