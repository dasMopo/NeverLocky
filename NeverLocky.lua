--Initialization logic for setting up the entire addon
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
		--print(str)

		local tab = table.deserialize(str)

		LockyFriendsData = tab;
		UpdateAllLockyFriendFrames();

		print("Initialization Success")
		NeverLockyFrame:Show()
	end	
end

-- Update handler to be used for any animations, is called once per frame, but can be throttled using an update interval.
function NeverLocky_OnUpdate(self, elapsed)
	if (self.TimeSinceLastClockUpdate == nil) then self.TimeSinceLastClockUpdate = 0; end
	if (self.TimeSinceLastSSCDUpdate == nil) then self.TimeSinceLastSSCDUpdate = 0; end
	if (self.TimeSinceLastSSCDBroadcast == nil) then self.TimeSinceLastSSCDBroadcast = 0; end

	self.TimeSinceLastClockUpdate = self.TimeSinceLastClockUpdate + elapsed; 	
	if (self.TimeSinceLastClockUpdate > NeverLockyClocky_UpdateInterval) then
		self.TimeSinceLastClockUpdate = 0;
		UpdateLockyClockys()
	end

	self.TimeSinceLastSSCDUpdate = self.TimeSinceLastSSCDUpdate + elapsed;
	self.TimeSinceLastSSCDBroadcast = self.TimeSinceLastSSCDBroadcast + elapsed;
	if(self.TimeSinceLastSSCDUpdate > NeverLockySSCD_UpdateInterval) then		
		self.TimeSinceLastSSCDUpdate = 0;
		CheckSSCD(self)
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

--Generates a series of test data to populate the ui.
function RegisterTestData()
	local testData = {}
	for i=1, 5 do
		table.insert(testData, CreateWarlock("Brylack", CurseOptions[math.random(1,GetTableLength(CurseOptions))], BanishMarkers[math.random(1,GetTableLength(BanishMarkers))]));
	end
	return testData
end

--Generates test data that more closly mimics what one could see in an actual raid.
function RegisterRealisicTestData()
	local testData = {}
	--table.insert(testData, AddAWarlock("Brylack", CurseOptions[math.random(1,GetTableLength(CurseOptions))], BanishMarkers[math.random(1,GetTableLength(BanishMarkers))]));
	table.insert(testData, CreateWarlock("Giandy", CurseOptions[math.random(1,GetTableLength(CurseOptions))], BanishMarkers[math.random(1,GetTableLength(BanishMarkers))]));
	table.insert(testData, CreateWarlock("Melon", CurseOptions[math.random(1,GetTableLength(CurseOptions))], BanishMarkers[math.random(1,GetTableLength(BanishMarkers))]));
	table.insert(testData, CreateWarlock("Brylack", CurseOptions[math.random(1,GetTableLength(CurseOptions))], BanishMarkers[math.random(1,GetTableLength(BanishMarkers))]));	
	table.insert(testData, CreateWarlock("Itsyrekt", CurseOptions[math.random(1,GetTableLength(CurseOptions))], BanishMarkers[math.random(1,GetTableLength(BanishMarkers))]));
	table.insert(testData, CreateWarlock("Dessian", CurseOptions[math.random(1,GetTableLength(CurseOptions))], BanishMarkers[math.random(1,GetTableLength(BanishMarkers))]));
	table.insert(testData, CreateWarlock("Sociopath", CurseOptions[math.random(1,GetTableLength(CurseOptions))], BanishMarkers[math.random(1,GetTableLength(BanishMarkers))]));
	return testData
end

--Generates just my data and returns it in a table.
function RegisterMyTestData()
	local testData = {}
	table.insert(testData, CreateWarlock("Brylack", CurseOptions[math.random(1,GetTableLength(CurseOptions))], BanishMarkers[math.random(1,GetTableLength(BanishMarkers))]));	
	return testData
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

--This is wired to a button click at present.
function NeverLocky_HideFrame()	
	PlaySound(SOUNDKIT.IG_MAINMENU_CLOSE)
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

-- Event for handling the frame showing.
function NeverLocky_OnShowFrame()
	print("Frame should be showing now.")	
	PlaySound(SOUNDKIT.IG_MAINMENU_OPEN)
	UpdateAllLockyFriendFrames();	
end

-- /command for opening the ui.
SLASH_NL1 = "/nl"
SLASH_NL2 = "/neverlocky"
SlashCmdList["NL"] = function(msg)
	NeverLockyFrame:Show()
end

--Short hand /command for reloading the ui.
SLASH_RL1 = "/rl"
SlashCmdList["RL"]= function(msg)
	ReloadUI();
end