--Initialization logic for setting up the entire addon
function NeverLockyInit()
	if not LockyFrame_HasInitialized then
		--print("Prepping init")
		InitLockyFrameScrollArea()
		--print("ScrollFrame initialized successfully.")
		RegisterForComms()
		--print("Comms initialized successfully.")
		LockyFrame_HasInitialized = true
		--LockyFriendsData = InitLockyFriendData()
		--print("LockyFriendsData initialized successfully.")
		--LockyFriendsData = SetDefaultAssignments(LockyFriendsData)
		--print("LockyFriendsData Default Assignments Set successfully.")
		UpdateAllLockyFriendFrames();
		
		print("Never Locky has been registered to the WOW UI.")		
		print("Use /nl or /neverlocky to view assignment information.")
		--NeverLockyFrame:Show()
		InitLockyAssignCheckFrame();	
		InitPersonalMonitorFrame();
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
		if NL_DebugMode then
			--print("Updating the UI");
		end
		UpdateLockyClockys()
	end

	self.TimeSinceLastSSCDUpdate = self.TimeSinceLastSSCDUpdate + elapsed;
	self.TimeSinceLastSSCDBroadcast = self.TimeSinceLastSSCDBroadcast + elapsed;
	if(self.TimeSinceLastSSCDUpdate > NeverLockySSCD_UpdateInterval) then		
		self.TimeSinceLastSSCDUpdate = 0;
		if NL_DebugMode then
			print("Checking SSCD");
		end
		CheckSSCD(self)
	end
end

function RegisterRaid()
	local raidInfo = {}
	for i=1, 40 do
		local name, rank, subgroup, level, class, fileName, 
		  zone, online, isDead, role, isML = GetRaidRosterInfo(i);
		if not (name == nil) then
			if NL_DebugMode then
				print(name .. "-" .. fileName)	
			end
			table.insert(raidInfo, name)
		end
	end
	return raidInfo
end

local TestType = {}
TestType.init = "Initialization Test"
TestType.add = "Add Test"
TestType.remove = "Remove Test"
TestType.setDefault = "Default Settings Test"
local testmode = TestType.init

function InitLockyFriendData()
	if(RaidMode) then
		if NL_DebugMode then
			print("Initializing Friend Data")
		end

		return RegisterWarlocks()
	else
		print("Raid mode is not active, running in Test mode.")			
		if testmode == TestType.init then
			print("Initializing with Test Data.")
			testmode = TestType.add
			return RegisterMyTestData()
		elseif testmode == TestType.add then
			print("testing add")
			table.insert(LockyFriendsData, RegisterMyTestData()[1])
			testmode = TestType.remove
			return LockyFriendsData
		elseif testmode == TestType.remove then
			print("testing remove")
			local p = GetLockyFriendIndexByName(LockyFriendsData, "Brylack")
			if not (p==nil) then
				table.remove(LockyFriendsData, p)
			end
			testmode = TestType.setDefault
			return LockyFriendsData
		elseif testmode == TestType.setDefault then
			print ("Setting default selection")
			LockyFriendsData = SetDefaultAssignments(LockyFriendsData)
			testmode = TestType.init
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
			if NL_DebugMode then
				print(value.Name, "is in position", key)
			end
			return key
		end
	end
	if NL_DebugMode then
		print(name, "is not in the list.")
	end
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

function RegisterMySoloData()
	localizedClass, englishClass, classIndex = UnitClass("player");

	local soloData = {}
	if englishClass == "WARLOCK" then
		table.insert(soloData, CreateWarlock(UnitName("player"), "None", "None"));	
	end
	return soloData
end

--This is wired to a button click at present.
function NeverLocky_HideFrame()	
	if IsUIDirty(LockyFriendsData) then
		print("Changes were not saved.")
		PlaySound(SOUNDKIT.IG_MAINMENU_CLOSE)
		NeverLockyFrame:Hide()
	else
		PlaySound(SOUNDKIT.IG_MAINMENU_CLOSE)
		NeverLockyFrame:Hide()
	end
end

function NeverLocky_Commit()
	LockyFriendsData = CommitChanges(LockyFriendsData)
	UpdateAllLockyFriendFrames();
	SendAssignmentReset();
	BroadcastTable(LockyFriendsData)
	print("Changes were sent out.");
	PlaySound(SOUNDKIT.IG_MAINMENU_CLOSE)
	--NeverLockyFrame:Hide()
end

--At this time this is just a test function.
function NL_Test()
	print("Updating a frame....")				
	LockyFriendsData = InitLockyFriendData();
	NLTest_Button.Text:SetText(testmode)
	--UpdateAllLockyFriendFrames();	
	BroadcastTable(LockyFriendsData);
end

-- Event for handling the frame showing.
function NeverLocky_OnShowFrame()
	if not LockyData_HasInitialized then
		LockyFriendsData = InitLockyFriendData()
		--LockyData_Timestamp = 0
		LockyData_HasInitialized = true
		if NL_DebugMode then
			print("Initialization complete");
			
			print("Found " .. GetTableLength(LockyFriendsData) .. " Warlocks in raid." );
		end		
	end

	if NL_DebugMode then
		print("Frame should be showing now.")	
	end
	PlaySound(SOUNDKIT.IG_MAINMENU_OPEN)
	--print("Updating SS targets")
	UpdateSSTargets()
	LockyFriendsData = UpdateWarlocks(LockyFriendsData);
	UpdateAllLockyFriendFrames();	
	RequestAssignments()
	if NL_DebugMode then
		print("Found " .. GetTableLength(LockyFriendsData) .. " Warlocks in raid." );
	end	
	if GetTableLength(LockyFriendsData) == 0 then
		RaidMode = false;
		LockyFriendsData = RegisterMySoloData();
	end
end

-- /command for opening the ui.
SLASH_NL1 = "/nl"
SLASH_NL2 = "/neverlocky"
SlashCmdList["NL"] = function(msg)

	if msg == "debug" then
		if(NL_DebugMode) then
			NL_DebugMode = false
			print("Never Locky Debug Mode OFF")
		else
			NL_DebugMode = true
			print("Never Locky Debug Mode ON")
		end		
	elseif msg == "test" then
		LockyAssignCheckFrame:Show();
	else
		NeverLockyFrame:Show()
	end	
end

--Short hand /command for reloading the ui.
SLASH_RL1 = "/rl"
SlashCmdList["RL"]= function(msg)
	ReloadUI();
end