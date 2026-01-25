opt casing = "PascalCase"
opt remote_scope = "AVALOG"

type SerEnumItem = struct {
    EnumType: string,
    Value: u16,
}

type AvatarItem = struct {
    Id: f64,
    Type: SerEnumItem,
    AssetType: SerEnumItem,
    Name: string,
}

type BulkPurchaseAvatarItem = struct {
	Id: string,
	Type: SerEnumItem,
}

type CatalogItem = struct {
	AssetId: f64,
	Name: string,
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
	Name: string,
	Slot: u16,
}
type HumanoidDescriberData = struct {
	Accessories: AccessorySpec[],
	Emotes: map {
		[string]: f64[]
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
type FeaturedItem = struct {
	TransactionHash: string,
	Bid: f64,
	StartTime: f64,
	EndTime: f64,
	Power: f64,
	Id: f64,
	ItemType: SerEnumItem,
}
type FeaturedCreator = struct {
	TransactionHash: string,
	Bid: f64,
	StartTime: f64,
	EndTime: f64,
	Power: f64,
	Id: f64,
	CreatorType: SerEnumItem,
}
type FeaturedData = struct {
	Items: FeaturedItem[],
	Creators: FeaturedCreator[],
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

funct GetFeaturedItems = {
	call: Async,
	args: (u32, u32),
	rets: (FeaturedItem[]?),
}

event FeaturedItemsReset = {
    from: Server,
    type: Reliable,
    call: SingleAsync,
}
