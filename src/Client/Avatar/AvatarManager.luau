-- An AvatarManager represents an avatar and operations that can be performed on this avatar.

local Avalog = script.Parent.Parent.Parent.Parent
local HumanoidDescriber = require(Avalog.Parent.HumanoidDescriber)
local Signal = require(Avalog.Parent.Signal)

export type CatalogItem = {
	Id: number,
	Type: Enum.AvatarItemType,
	AssetType: Enum.AvatarAssetType,
	Name: string,
}

export type AvatarManager = {
	Character: Model?,
	Humanoid: Humanoid?,
	HumanoidDescriber: HumanoidDescriber.HumanoidDescriber?,
	Updated: Signal.Signal<nil>,

	-- Limits the number of accessories the avatar has on.
	ApplyLimits: (AvatarManager) -> (),
	UpdateScale: (AvatarManager, Property: string, Value: number) -> (),
	SetColor: (AvatarManager, Color: Color3) -> (),

	GetUnownedItems: (AvatarManager) -> (),
	ToggleCatalogItem: (AvatarManager, CatalogItem: CatalogItem) -> (),
	Reset: () -> AvatarManager,
	Apply: () -> AvatarManager,
	SetCharacter: (AvatarManager, Character: Model) -> (),
	Clear: (AvatarManager) -> (),

	--[[ The follow methods are only used on the client (not plugin) ]]

	-- Updates the avatar on the server.
	UpdateServer: (AvatarManager, Data: HumanoidDescriber.Data) -> (),

	Redo: (AvatarManager) -> (),
	Undo: (AvatarManager) -> (),
	SaveAvatar: (AvatarManager) -> (),
	PromptCheckout: (AvatarManager, Items: any) -> (),
}

return {}
