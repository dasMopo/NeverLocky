--General global variables
RaidMode = true;
NL_DebugMode = false;
NL_Version = 113
LockyFriendFrameWidth = 500;
LockyFriendFrameHeight = 128
LockyFrame_HasInitialized = false; -- Used to prevent reloads from redrawing the ui.
LockyData_HasInitialized = false;
LockyData_Timestamp = 0.0;
LockyFriendsData = {}; -- Global for storing the warlocks and thier assignements.
NeverLockyClocky_UpdateInterval = 1.0; -- How often the OnUpdate code will run (in seconds)
NeverLockySSCD_UpdateInterval = 5.0; -- How often to broadcast / check our SS cooldown.
NeverLockySSCD_BroadcastInterval = 60.0; -- How often to broadcast / check our SS cooldown.
if NeverLocky == nil then
	NeverLocky = LibStub("AceAddon-3.0"):NewAddon("NeverLocky", "AceComm-3.0")
end
LockyAssignCheckFrame={}
IsMyAddonOutOfDate=false;



function  CreateWarlock(name, curse, banish)
	local Warlock = {}
			Warlock.Name = name
			Warlock.CurseAssignment = curse
			Warlock.BanishAssignment = banish
			Warlock.SSAssignment = "None"
			Warlock.SSCooldown=0
			Warlock.AcceptedAssignments = "nil"
			Warlock.LockyFrameLocation = ""
			Warlock.SSonCD = "false"
			Warlock.LocalTime= 0
			Warlock.MyTime = 0
			Warlock.AddonVersion = 0
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
				if NL_DebugMode then
					print(name .. "-" .. fileName)
				end
				table.insert(raidInfo, CreateWarlock(name, "None", "None"))
			end
		end		
	end
	if GetTableLength(raidInfo) == 0 then
		RaidMode = false;
		return RegisterMySoloData();
	else
		RaidMode = true;
	end

	return raidInfo
end

function  IsLockyTableDirty(LockyData)
	for k,v in pairs(LockyData) do
		local lock = GetLockyDataByName(v.Name);
		if lock.CurseAssignment ~= v.CurseAssignment or
		lock.BanishAssignment ~= v.BanishAssignment or 
		lock.SSAssignment ~= v.SSAssignment then
			return true;
		end
	end
	return false;
end


function IsMyDataDirty(lockyData)
	local myData = GetMyLockyData();
	if myData.CurseAssignment ~= lockyData.CurseAssignment or
		myData.BanishAssignment ~= lockyData.BanishAssignment or
		myData.SSAssignment ~= lockyData.SSAssignment then
			return true;
	end

	return false;
end

-- will merge any newcomers or remove any deserters from the table and return it while leaving assignments intact.
function UpdateWarlocks(LockyTable)
	local Newcomers = RegisterWarlocks();	
	--Register Newcomers
	for k, v in pairs(Newcomers) do
		if WarlockIsInTable(v.Name, LockyTable) then
			--Do nothing I think...
		else
			if NL_DebugMode then
				print("Newcomer detected")
			end

			--Add the newcomer to the data.
			table.insert(LockyTable, CreateWarlock(v.Name, "None", "None"));
		end
	end
	--De-register deserters
	for k, v in pairs(LockyTable) do
		if WarlockIsInTable(v.Name, Newcomers) then
			--Do nothing I think...
		else
			--Remove the Deserter
			if NL_DebugMode then
				print("Deserter detected")
			end
			local p = GetLockyFriendIndexByName(LockyFriendsData, v.Name)
			if not (p==nil) then
				table.remove(LockyFriendsData, p)
			end
		end
	end
	return LockyTable;
end

function MergeAssignments(LockyTable)
	for k,v in pairs(LockyTable) do 
		local lock = GetLockyDataByName(v.Name);
		lock.SSAssignment = v.SSAssignment;
		lock.CurseAssignment = v.CurseAssignment;
		lock.BanishAssignment = v.BanishAssignment;
	end
end

function  ResetAssignmentAcks(LockyTable)
	for k,v in pairs(LockyTable) do 
		local lock = GetLockyDataByName(v.Name);
		lock.AcceptedAssignments = "nil";
	end
end

function WarlockIsInTable(LockyName, LockyTable)
	for k, v in pairs(LockyTable) do
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
		--print("Raid MODE!!")
		--I need to implement this next time I am in a raid.
		local results = {}		
		for i=1, 40 do
			local name, rank, subgroup, level, class, fileName, 
				zone, online, isDead, role, isML, combatRole = GetRaidRosterInfo(i);
			if not (name == nil) then
				--print(name .. "-" .. fileName .. "-" .. rank .. role)
				if fileName == "PRIEST" or fileName == "PALADIN" or fileName == "SHAMAN" or role == "MAINTANK" then
					table.insert(results, name)
				end
			end		
		end
		table.insert(results,"None")
		return results
	else
		if NL_DebugMode then
			print("Registering Test SS target data.");
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
		else
			--print("Not in debug mode, solo mode enabled no targets");
			return {"None"};
		end
	end
end

SSTargets = GetSSTargetsFromRaid();

function GetSSTargets()
	return SSTargets;
end

function UpdateSSTargets()
	SSTargets = GetSSTargetsFromRaid();
--	print ("SS Targets Updated success.")
end

function GetMyLockyData()
	for k, v in pairs(LockyFriendsData) do
		if NL_DebugMode then
			--print(v.Name, " vs ", UnitName("player"));
		end
        if v.Name == UnitName("player") then
            return v
        end
	end	
end

function GetMyLockyDataFromTable(lockyDataTable)
	for k, v in pairs(lockyDataTable) do
		if NL_DebugMode then
			--print(v.Name, " vs ", UnitName("player"));
		end
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