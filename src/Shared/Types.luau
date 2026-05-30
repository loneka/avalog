export type ItemType = "Asset" | "Bundle"

export type ItemSale = {
	experienceId: string,
	jobId: string,
	itemId: string,
	itemType: ItemType,
	robuxPrice: number,
	unitsSold: number,
}

export type AvalogUsageSnapshot = {
	experienceId: string,
	placeId: string,
	jobId: string,
	uptime: number,
	totalMenuOpens: number,
	totalMenuTime: number,
	totalUserSessions: number,
	totalUserPlaytime: number,
}

export type Item = {
	itemId: string,
	itemType: ItemType,
	tintColor: string?,
}

export type PromotedItem = Item & {
	promotionId: string,
	bid: number,
	startTime: number,
	endTime: number,
}

export type AvalogConfig = {
	latestVersion: string,
	featuredItems: { [number]: Item },
	pinnedItems: { [number]: Item },
	promotedItems: { [number]: PromotedItem },
	cosmeticItems: { [number]: Item },
}

return {
	AvalogConfig = {
		Fallback = {
			latestVersion = "0.0.0",
			featuredItems = {},
			pinnedItems = {},
			promotedItems = {},
			cosmeticItems = {},
		},
	},
}
