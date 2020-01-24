--General global variables
RaidMode = false;
LockyFriendFrameWidth = 500;
LockyFriendFrameHeight = 128
LockyFrame_HasInitialized = false; -- Used to prevent reloads from redrawing the ui.
LockyFriendsData = {}; -- Global for storing the warlocks and thier assignements.
NeverLockyClocky_UpdateInterval = 1.0; -- How often the OnUpdate code will run (in seconds)
NeverLockySSCD_UpdateInterval = 5.0; -- How often to broadcast / check our SS cooldown.
NeverLocky = LibStub("AceAddon-3.0"):NewAddon("NeverLocky", "AceComm-3.0")

function  CreateWarlock(name, curse, banish)
	local Warlock = {}
			Warlock.Name = name
			Warlock.CurseAssignment = curse
			Warlock.BanishAssignment = banish
			Warlock.SSAssignment = "None"
			Warlock.SSCooldown=GetTime()
			Warlock.AcceptedAssignments = false
			Warlock.LockyFrameLocation = ""
			Warlock.SSonCD = "true"
	return Warlock
end


--Global List of banish markers
BanishMarkers = {
	"None",
	"Diamond",
	"Star",
	"Triangle",
	"Circle",
	"Square",
	"Moon",	
	"Skull",
	"Cross"
}

--Global list of curse options to be displayed in the curse assignment menu.
CurseOptions = {
	"None",
   "Elements",
   "Shadows",
   "Recklessness",
   "Tongues",
   "Weakness",
   "Doom LOL",
   "Agony"
}

--Function will find main healers in the raid and add them to the SS target dropdown
--Need to make test mode dynamic.
function GetSSTargets()
	if RaidMode then
		--I need to implement this next time I am in a raid.
		local results = {}		
		for i=1, 40 do
			local name, rank, subgroup, level, class, fileName, 
				zone, online, isDead, role, isML = GetRaidRosterInfo(i);
			if not (name == nil) then
				if fileName == "PRIEST" or fileName == "PALADIN" or rank == "Tank" then
					print(name .. "-" .. fileName)
					table.insert(results, name)
				end
			end		
		end
		table.insert(results,"None")
		return results
	else
		return {
			"Priest1",
			"Priest2",
			"Priest3",
			"Paladin1",
			"Paladin2",				
			"WarriorTank1",
			"None"
		}
	end
end