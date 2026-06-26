local Players = game:GetService("Players")

local SavedResults = {} :: { [number]: {
	[number]: boolean,
} }

local function GetEntry(Player: Player)
	if SavedResults[Player.UserId] == nil then
		SavedResults[Player.UserId] = {}
	end

	return SavedResults[Player.UserId]
end

--[[
	Checks if the given `Player` is a member of `GroupId`. Reuses `true` results to reduce API usage.
]]
local function PlayerIsInGroup(Player: Player, GroupId: number)
	local Entry = GetEntry(Player)

	-- return false

	if Entry[GroupId] == true then
		return true
	else
		local IsInGroup = Player:IsInGroupAsync(GroupId)
		Entry[GroupId] = IsInGroup
		return IsInGroup
	end
end

Players.PlayerRemoving:Connect(function(Player)
	SavedResults[Player.UserId] = nil
end)

return PlayerIsInGroup
