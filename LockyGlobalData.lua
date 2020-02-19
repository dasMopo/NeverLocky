--General global variables
RaidMode = true;
NL_DebugMode = false;
LockyFriendFrameWidth = 500;
LockyFriendFrameHeight = 128
LockyFrame_HasInitialized = false; -- Used to prevent reloads from redrawing the ui.
LockyData_HasInitialized = false;
LockyData_Timestamp = 0.0;
LockyFriendsData = {}; -- Global for storing the warlocks and thier assignements.
NeverLockyClocky_UpdateInterval = 1.0; -- How often the OnUpdate code will run (in seconds)
NeverLockySSCD_UpdateInterval = 5.0; -- How often to broadcast / check our SS cooldown.
NeverLockySSCD_BroadcastInterval = 60.0; -- How often to broadcast / check our SS cooldown.
NeverLocky = LibStub("AceAddon-3.0"):NewAddon("NeverLocky", "AceComm-3.0")



function  CreateWarlock(name, curse, banish)
	local Warlock = {}
			Warlock.Name = name
			Warlock.CurseAssignment = curse
			Warlock.BanishAssignment = banish
			Warlock.SSAssignment = "None"
			Warlock.SSCooldown=GetTime()
			Warlock.AcceptedAssignments = "false"
			Warlock.LockyFrameLocation = ""
			Warlock.SSonCD = "false"
	return Warlock
end

--Pulls all of the warlocks in the raid and initilizes thier assignment data.
function RegisterWarlocks()
	local raidInfo = {}
	for i=1, 40 do
		local name, rank, subgroup, level, class, fileName, 
		  zone, online, isDead, role, isML = GetRaidRosterInfo(i);
		if not (name == nil) then
			if fileName == "WARLOCK" then
				--print(name .. "-" .. fileName)
				table.insert(raidInfo, CreateWarlock(name, "None", "None"))
			end
		end		
	end
	return raidInfo
end

-- will merge any newcomers or remove any deserters from the table and return it while leaving assignments intact.
function UpdateWarlocks(LockyTable)
	local Newcomers = RegisterWarlocks();
	--Register Newcomers
	for k, v in Newcomers do
		if WarlockIsInTable(v.Name, LockyTable) then
			--Do nothing I think...
		else
			--Add the newcomer to the data.
			table.insert(LockyTable, CreateWarlock(v.Name, "None", "None"));
		end
	end
	--De-register deserters
	for k, v in LockyTable do
		if WarlockIsInTable(v.Name, Newcomers) then
			--Do nothing I think...
		else
			--Remove the Deserter
			local p = GetLockyFriendIndexByName(LockyFriendsData, v.Name)
			if not (p==nil) then
				table.remove(LockyFriendsData, p)
			end
		end
	end
	return LockyTable;
end

function WarlockIsInTable(LockyName, LockyTable)
	for k, v in LockyTable do
		if (v.Name == LockyName) then
			return true;
		end
	end
	return false;
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


SSTargets = {};

SSTargetFlipperTester = true;



--Function will find main healers in the raid and add them to the SS target dropdown
--Need to make test mode dynamic.
function GetSSTargetsFromRaid()
	if RaidMode then
		--I need to implement this next time I am in a raid.
		local results = {}		
		for i=1, 40 do
			local name, rank, subgroup, level, class, fileName, 
				zone, online, isDead, role, isML = GetRaidRosterInfo(i);
			if not (name == nil) then
				if fileName == "PRIEST" or fileName == "PALADIN" or rank == "Tank" then
					--print(name .. "-" .. fileName .. "-" .. rank)
					table.insert(results, name)
				end
			end		
		end
		table.insert(results,"None")
		return results
	else
		if SSTargetFlipperTester then
			SSTargetFlipperTester = false
			if NL_DebugMode then
				print("Setting SS target set 1.");
			end
			return {
				"Priest1",
				"Priest2",
				"Priest3",
				"Paladin1",
				"Paladin2",				
				"WarriorTank1",
				"None"
			}
		else
			SSTargetFlipperTester = true
			if NL_DebugMode then
				print("Setting SS target set 2.");
			end
			return {
				"PriestA",
				"PriestB",
				"PriestC",
				"PaladinA",
				"PaladinB",				
				"WarriorTankA",
				"None"
			}
		end

	end
end

SSTargets = GetSSTargetsFromRaid();

function GetSSTargets()
	return SSTargets;
end

function UpdateSSTargets()
	SSTargets = GetSSTargetsFromRaid();
end

function GetMyLockyData()
    for k, v in pairs(LockyFriendsData) do
        if v.Name == UnitName("player") then
            return v
        end
    end
end

function  GetLockyDataByName(name)
    for k, v in pairs(LockyFriendsData) do
        if v.Name == name then
            return v
        end
    end
end