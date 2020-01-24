-- Update handler to be used for any animations, is called once per frame, but can be throttled using an update interval.
function NeverLocky_OnUpdate(self, elapsed)
	if (self.TimeSinceLastClockUpdate == nil) then self.TimeSinceLastClockUpdate = 0; end
	if (self.TimeSinceLastSSCDUpdate == nil) then self.TimeSinceLastSSCDUpdate = 0; end

	self.TimeSinceLastClockUpdate = self.TimeSinceLastClockUpdate + elapsed; 	
	if (self.TimeSinceLastClockUpdate > NeverLockyClocky_UpdateInterval) then
		UpdateLockyClockys()
		self.TimeSinceLastClockUpdate = 0;
	end

	self.TimeSinceLastSSCDUpdate = self.TimeSinceLastSSCDUpdate + elapsed;
	if(self.TimeSinceLastSSCDUpdate > NeverLockySSCD_UpdateInterval) then
		--CheckSSCD()
		self.TimeSinceLastSSCDUpdate = 0;
	end
end

function NeverLockyInit()
	print("Never Locky has been registered to the WOW UI.")
	if not LockyFrame_HasInitialized then
		--print("Prepping init")
		InitLockyFrameScrollArea()
		--print("ScrollFrame initialized successfully.")
		RegisterForComms(NeverLocky)
		--print("Comms initialized successfully.")
		LockyFrame_HasInitialized = true
		LockyFriendsData = InitLockyFriendData()
		--print("LockyFriendsData initialized successfully.")
		LockyFriendsData = SetDefaultAssignments(LockyFriendsData)
		--print("LockyFriendsData Default Assignments Set successfully.")

		local str = table.serialize(RegisterRealisicTestData())
		print(str)

		local tab = table.deserialize(str)

		LockyFriendsData = tab;
		UpdateAllLockyFriendFrames();

		print("Initialization Success")
		NeverLockyFrame:Show()
	end	
end

function RegisterRaid()
	local raidInfo = {}
	for i=1, 40 do
		local name, rank, subgroup, level, class, fileName, 
		  zone, online, isDead, role, isML = GetRaidRosterInfo(i);
		if not (name == nil) then
			print(name .. "-" .. fileName)	
			table.insert(raidInfo, name)
		end
	end
	return raidInfo
end

local testmode = "init"

function InitLockyFriendData()
	if(RaidMode) then
		return RegisterWarlocks()
	else
		if testmode == "init"then
			testmode = "add"
			print("testing init")
			return RegisterRealisicTestData()
		elseif testmode == "add" then
			print("testing add")
			table.insert(LockyFriendsData, RegisterMyTestData()[1])
			testmode = "remove"
			return LockyFriendsData
		elseif testmode == "remove" then
			print("testing remove")
			local p = GetLockyFriendIndexByName(LockyFriendsData, "Melon")
			if not (p==nil) then
				table.remove(LockyFriendsData, p)
			end
			testmode = "setdefault"
			return LockyFriendsData
		elseif testmode == "setdefault" then
			print ("Setting default selection")
			LockyFriendsData = SetDefaultAssignments(LockyFriendsData)
			testmode = "init"
			return LockyFriendsData
		else
			return LockyFriendsData
		end
	end
end

function  GetLockyFriendIndexByName(table, name)

	for key, value in pairs(table) do
		--print(key, " -- ", value["LockyFrameID"])
		--print(value.Name)
		if value.Name == name then
			print(value.Name, "is in position", key)
			return key
		end
	end
	print(name, "is not in the list.")
	return nil
end

function RegisterTestData()
	local testData = {}
	for i=1, 5 do
		table.insert(testData, AddAWarlock("Brylack", CurseOptions[math.random(1,GetTableLength(CurseOptions))], BanishMarkers[math.random(1,GetTableLength(BanishMarkers))]));
	end
	return testData
end

function RegisterRealisicTestData()
	local testData = {}
	--table.insert(testData, AddAWarlock("Brylack", CurseOptions[math.random(1,GetTableLength(CurseOptions))], BanishMarkers[math.random(1,GetTableLength(BanishMarkers))]));
	table.insert(testData, AddAWarlock("Giandy", CurseOptions[math.random(1,GetTableLength(CurseOptions))], BanishMarkers[math.random(1,GetTableLength(BanishMarkers))]));
	table.insert(testData, AddAWarlock("Melon", CurseOptions[math.random(1,GetTableLength(CurseOptions))], BanishMarkers[math.random(1,GetTableLength(BanishMarkers))]));
	table.insert(testData, AddAWarlock("Brylack", CurseOptions[math.random(1,GetTableLength(CurseOptions))], BanishMarkers[math.random(1,GetTableLength(BanishMarkers))]));	
	table.insert(testData, AddAWarlock("Itsyrekt", CurseOptions[math.random(1,GetTableLength(CurseOptions))], BanishMarkers[math.random(1,GetTableLength(BanishMarkers))]));
	table.insert(testData, AddAWarlock("Dessian", CurseOptions[math.random(1,GetTableLength(CurseOptions))], BanishMarkers[math.random(1,GetTableLength(BanishMarkers))]));
	table.insert(testData, AddAWarlock("Sociopath", CurseOptions[math.random(1,GetTableLength(CurseOptions))], BanishMarkers[math.random(1,GetTableLength(BanishMarkers))]));
	return testData
end

function RegisterMyTestData()
	local testData = {}
	table.insert(testData, AddAWarlock("Brylack", CurseOptions[math.random(1,GetTableLength(CurseOptions))], BanishMarkers[math.random(1,GetTableLength(BanishMarkers))]));	
	return testData
end

function  AddAWarlock(name, curse, banish)
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




--Pulls all of the warlocks in the raid and initilizes thier assignment data.
function RegisterWarlocks()
	local raidInfo = {}
	for i=1, 40 do
		local name, rank, subgroup, level, class, fileName, 
		  zone, online, isDead, role, isML = GetRaidRosterInfo(i);
		if not (name == nil) then
			if fileName == "WARLOCK" then
				--print(name .. "-" .. fileName)
				table.insert(raidInfo, AddAWarlock(name, "None", "None"))
			end
		end		
	end
	return raidInfo
end

function NeverLocky_HideFrame()
	--print("Hiding NeverLockyFrame.")
	NeverLockyFrame:Hide()
end

--At this time this is just a test function.
function Refresh()
	print("Updating a frame....")
	if not (LockyFrame == nil) then				
		LockyFriendsData = InitLockyFriendData();
		UpdateAllLockyFriendFrames();
	end
	BroadcastTable(LockyFriendsData);
end

function NeverLocky_OnShowFrame()
	print("Frame should be showing now.")	
	PlaySound(SOUNDKIT.IG_MAINMENU_OPEN)
	UpdateAllLockyFriendFrames();
	if not LockyFrame_HasInitialized then		
	--	InitLockyFrameScrollArea()
		LockyFrame_HasInitialized = true
	end
end

SLASH_NL1 = "/nl"
SLASH_NL2 = "/neverlocky"
SlashCmdList["NL"] = function(msg)
	NeverLockyFrame:Show()
end

SLASH_RL1 = "/rl"
SlashCmdList["RL"]= function(msg)
	ReloadUI();
end