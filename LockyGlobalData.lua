--General global variables
NL = {};
NL.RaidMode = true;
NL.DebugMode = false;
NL.Version = 113
NL.LockyFriendFrameWidth = 500;
NL.LockyFriendFrameHeight = 128
NL.LockyFrame_HasInitialized = false; -- Used to prevent reloads from redrawing the ui.
NL.LockyData_HasInitialized = false;
NL.LockyData_Timestamp = 0.0;
NL.LockyFriendsData = {}; -- Global for storing the warlocks and thier assignements.
NL.NeverLockyClocky_UpdateInterval = 1.0; -- How often the OnUpdate code will run (in seconds)
NL.NeverLockySSCD_UpdateInterval = 5.0; -- How often to broadcast / check our SS cooldown.
NL.NeverLockySSCD_BroadcastInterval = 60.0; -- How often to broadcast / check our SS cooldown.
if NeverLocky == nil then
	NeverLocky = LibStub("AceAddon-3.0"):NewAddon("NeverLocky", "AceComm-3.0")
end
NL.LockyAssignCheckFrame={}
NL.IsMyAddonOutOfDate=false;
NL.MacroName =  "CurseAssignment";


function  NL.CreateWarlock(name, curse, banish)
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
function NL.RegisterWarlocks()
	local raidInfo = {}
	for i=1, 40 do
		local name, rank, subgroup, level, class, fileName, 
		  zone, online, isDead, role, isML = GetRaidRosterInfo(i);
		if not (name == nil) then
			if fileName == "WARLOCK" then
				if NL.DebugMode then
					print(name .. "-" .. fileName)
				end
				table.insert(raidInfo, NL.CreateWarlock(name, "None", "None"))
			end
		end		
	end
	if NL.GetTableLength(raidInfo) == 0 then
		NL.RaidMode = false;
		return NL.RegisterMySoloData();
	else
		NL.RaidMode = true;
	end

	return raidInfo
end

function  NL.IsLockyTableDirty(LockyData)
	for k,v in pairs(LockyData) do
		local lock = NL.GetLockyDataByName(v.Name);
		if lock.CurseAssignment ~= v.CurseAssignment or
		lock.BanishAssignment ~= v.BanishAssignment or 
		lock.SSAssignment ~= v.SSAssignment then
			return true;
		end
	end
	return false;
end


function NL.IsMyDataDirty(lockyData)
	local myData = NL.GetMyLockyData();
	if myData.CurseAssignment ~= lockyData.CurseAssignment or
		myData.BanishAssignment ~= lockyData.BanishAssignment or
		myData.SSAssignment ~= lockyData.SSAssignment then
			return true;
	end

	return false;
end

-- will merge any newcomers or remove any deserters from the table and return it while leaving assignments intact.
function NL.UpdateWarlocks(LockyTable)
	local Newcomers = NL.RegisterWarlocks();	
	--Register Newcomers
	for k, v in pairs(Newcomers) do
		if NL.WarlockIsInTable(v.Name, LockyTable) then
			--Do nothing I think...
		else
			if NL.DebugMode then
				print("Newcomer detected")
			end

			--Add the newcomer to the data.
			table.insert(LockyTable, NL.CreateWarlock(v.Name, "None", "None"));
		end
	end
	--De-register deserters
	for k, v in pairs(LockyTable) do
		if NL.WarlockIsInTable(v.Name, Newcomers) then
			--Do nothing I think...
		else
			--Remove the Deserter
			if NL.DebugMode then
				print("Deserter detected")
			end
			local p = NL.GetLockyFriendIndexByName(NL.LockyFriendsData, v.Name)
			if not (p==nil) then
				table.remove(NL.LockyFriendsData, p)
			end
		end
	end
	return LockyTable;
end

function NL.MergeAssignments(LockyTable)
	for k,v in pairs(LockyTable) do 
		local lock = NL.GetLockyDataByName(v.Name);
		lock.SSAssignment = v.SSAssignment;
		lock.CurseAssignment = v.CurseAssignment;
		lock.BanishAssignment = v.BanishAssignment;
	end
end

function  NL.ResetAssignmentAcks(LockyTable)
	for k,v in pairs(LockyTable) do 
		local lock = NL.GetLockyDataByName(v.Name);
		lock.AcceptedAssignments = "nil";
	end
end

function NL.WarlockIsInTable(LockyName, LockyTable)
	for k, v in pairs(LockyTable) do
		if (v.Name == LockyName) then
			return true;
		end
	end
	return false;
end

--Global List of banish markers
NL.BanishMarkers = {
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
NL.CurseOptions = {
	"None",
   "Elements",
   "Shadows",
   "Recklessness",
   "Tongues",
   "Weakness",
   "Doom LOL",
   "Agony"
}

NL.AnnouncerOptions = {
	"Addon Only",
	"Raid",
	"Party",
	"Whisper"
}

NL.SSTargets = {};

NL.SSTargetFlipperTester = true;

--Function will find main healers in the raid and add them to the SS target dropdown
--Need to make test mode dynamic.
function NL.GetSSTargetsFromRaid()
	if NL.RaidMode then
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
		if NL.DebugMode then
			print("Registering Test SS target data.");
			if NL.SSTargetFlipperTester then
				NL.SSTargetFlipperTester = false
				if NL.DebugMode then
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
				NL.SSTargetFlipperTester = true
				if NL.DebugMode then
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

NL.SSTargets = NL.GetSSTargetsFromRaid();

function NL.GetSSTargets()
	return NL.SSTargets;
end

function NL.UpdateSSTargets()
	NL.SSTargets = NL.GetSSTargetsFromRaid();
--	print ("SS Targets Updated success.")
end

function NL.GetMyLockyData()
	for k, v in pairs(NL.LockyFriendsData) do
		if NL.DebugMode then
			--print(v.Name, " vs ", UnitName("player"));
		end
        if v.Name == UnitName("player") then
            return v
        end
	end	
end

function NL.GetMyLockyDataFromTable(lockyDataTable)
	for k, v in pairs(lockyDataTable) do
		if NL.DebugMode then
			--print(v.Name, " vs ", UnitName("player"));
		end
        if v.Name == UnitName("player") then
            return v
        end
    end
end

function  NL.GetLockyDataByName(name)
    for k, v in pairs(NL.LockyFriendsData) do
        if v.Name == name then
            return v
        end
    end
end

function NL.SetupAssignmentMacro(CurseAssignment)
	
	-- If macro exists?
	local macroIndex = GetMacroIndexByName(NL.MacroName)
	if (macroIndex == 0) then
		macroIndex = CreateMacro(NL.MacroName, "INV_MISC_QUESTIONMARK", "/stopcast;", 1);
		if NL.DebugMode then
			print("Never Locky macro did not exist, creating a new one with ID" .. macroIndex);
		end
	end
	
	--print('anything working?');
	local curseName = NL.GetSpellNameFromDropDownList(CurseAssignment);
	--print(curseName .. 'vs None');
	if (curseName == nil) then	
		if NL.DebugMode then
			print("No update applied because no curse selected");
		end
	else
		if NL.DebugMode then
			print("Updating macro ".. macroIndex .. " to the new assigment " .. curseName);
		end

		EditMacro(macroIndex, NL.MacroName, GetSpellTexture(NL.GetSpellIdFromDropDownList(CurseAssignment)), NL.BuildMacroTexe(curseName), 1, 1);
		
		if NL.DebugMode then
			print("Update success!!!!!");
		end
	end
	-- CreateMacro("MyMacro", "INV_MISC_QUESTIONMARK", "/script CastSpellById(1);", 1);
	-- I think I can just pass in the texture in param 2?
end

function  NL.BuildMacroTexe(curseName)
	return "#showtooltip "..
	 curseName ..
	 "\n/stopcasting" ..
	 "\n/Cast [@mouseover,exists,harm,nodead][]"..
	 curseName ..";"
end