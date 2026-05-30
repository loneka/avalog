local Avalog = script.Parent.Parent.Parent.Parent
local Fusion = require(Avalog.Parent.Fusion)
local Types = require(Avalog.SourceCode.Shared.Types)

local Scope = Fusion.scoped(Fusion)

local States = {
	Theme = Scope:Value(nil),
	Catalog = {
		SearchQuery = Scope:Value(""),
		Mode = Scope:Value(1),
		Category = Scope:Value(1),
		SubCategory = Scope:Value(1),
	},
	Avatar = {
		Data = Scope:Value(nil),
		DataHistory = Scope:Value({}),
		UndoHistory = Scope:Value({}),
		AssetIds = Scope:Value({}),
		EquippedAssetIds = Scope:Value({}),
		EquippedBundleIds = Scope:Value({}),
		Character = Scope:Value(nil),
		Loaded = Scope:Value(false),
	},
	Checkout = {
		Loading = Scope:Value(false),
	},
	Inventory = {
		AccessAllowed = Scope:Value(false),
	},
	Featured = {
		MessageShown = Scope:Value(true),
		PrefixItems = Scope:Value({}),
		Creators = Scope:Value({}),
	},
	CloudConfig = Scope:Value(Types.AvalogConfig.Fallback) :: Types.AvalogConfig,
	Screen = {
		Resolution = Scope:Value(Vector2.new()),
	},
	UnixTimestamp = Scope:Value(0),
	Open = Scope:Value(false),
}

return States
