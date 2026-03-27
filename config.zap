opt casing = "PascalCase"
opt remote_scope = "AVALOG"

type ItemType = enum {
	"Asset",
	"Bundle",
}

type SerEnumItem = struct {
    EnumType: string.binary,
    Value: u16,
}

type AvatarItem = struct {
    Id: f64,
    Type: SerEnumItem,
    AssetType: SerEnumItem,
    Name: string.binary,
}

type BulkPurchaseAvatarItem = struct {
	Id: string.binary,
	Type: SerEnumItem,
}

type CatalogItem = struct {
	AssetId: f64,
	Name: string.binary,
	Type: SerEnumItem,
	AssetType: SerEnumItem,
}
type AccessorySpec = struct {
	AssetId: f64,
	AccessoryType: SerEnumItem,
	Order: u16?,
	Puffiness: f32?,
	IsLayered: boolean?,
	Position: Vector3?,
	Rotation: Vector3?,
	Scale: Vector3?,
}
type EquippedEmote = struct {
	Name: string.binary,
	Slot: u16,
}
type HumanoidDescriberData = struct {
	Accessories: AccessorySpec[],
	Emotes: map {
		[string.binary]: f64[]
	},
	EquippedEmotes: EquippedEmote[],
	Face: f64,
	Scale: struct {
		BodyType: f32,
		Depth: f32,
		Head: f32,
		Height: f32,
		Proportion: f32,
		Width: f32,
	},
	Animations: struct {
		Walk: f64,
		Run: f64,
		Fall: f64,
		Climb: f64,
		Swim: f64,
		Idle: f64,
		Mood: f64,
		Jump: f64,
	},
	BodyParts: struct {
		Head: f64,
		Torso: f64,
		LeftArm: f64,
		RightArm: f64,
		LeftLeg: f64,
		RightLeg: f64,
	},
	BodyPartColors: struct {
		Head: Color3,
		Torso: Color3,
		LeftArm: Color3,
		RightArm: Color3,
		LeftLeg: Color3,
		RightLeg: Color3,
	},
	Clothing: struct {
		Shirt: f64,
		TShirt: f64,
		Pants: f64,
	},
}

type Item = struct {
	itemId: string.binary,
	itemType: ItemType,
	tintColor: string.binary?,
}
type PromotedItem = struct {
    itemId: string.binary,
	itemType: ItemType,
	tintColor: string.binary?,
	promotionId: string.binary,
	bid: f32,
	startTime: f32,
	endTime: f32,
}
type CloudConfig = struct {
    latestVersion: string.binary,
    featuredItems: Item[],
    pinnedItems: Item[],
    promotedItems: PromotedItem[]
}


event BulkPurchaseAvatarItems = {
    from: Client,
    type: Reliable,
    call: SingleAsync,
    data: BulkPurchaseAvatarItem[1..20],
}

event UpdateAvatar = {
    from: Client,
    type: Reliable,
    call: SingleAsync,
    data: HumanoidDescriberData
}

funct GetCloudConfig = {
	call: Async,
	args: (),
	rets: (CloudConfig?),
}

event CloudConfigReset = {
    from: Server,
    type: Reliable,
    call: SingleAsync
}
