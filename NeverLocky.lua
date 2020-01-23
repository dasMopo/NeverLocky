-- Globals Section
RaidMode = false;
LockyFriendFrameWidth = 500;
LockyFriendFrameHeight = 128
HasInitialized = false;

LockyFriendsData = {};

NeverLocky_UpdateInterval = 1.0; -- How often the OnUpdate code will run (in seconds)

-- Functions Section
function NeverLocky_OnUpdate(self, elapsed)
  self.TimeSinceLastUpdate = self.TimeSinceLastUpdate + elapsed; 	

  if (self.TimeSinceLastUpdate > NeverLocky_UpdateInterval) then
    --
    -- Insert your OnUpdate code here
	--
	UpdateLockyClockys()

    self.TimeSinceLastUpdate = 0;
  end
end

local function OnEvent(self, event, isInitialLogin, isReloadingUi)
	--print (event)
	if isInitialLogin or isReloadingUi then
		--print("loaded the UI")
		if not HasInitialized then
			InitLockyFrameScrollArea()
			HasInitialized = true
			LockyFriendsData = InitLockyFriendData()
			LockyFriendsData = SetDefaultAssignments(LockyFriendsData)
			UpdateAllLockyFriendFrames();
		end
		NeverLockyFrame:Show()
	else
		print("zoned between map instances")
	end
end

function Main()
	print("Never Locky has been registered to the WOW UI.")
	--InitLockyFrameScrollArea()
	--NeverLockyFrame:Show()
	NeverLockyFrame:RegisterEvent("ADDON_LOADED")	
	NeverLockyFrame:SetScript("OnEvent", OnEvent)
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
			return RegisterMyTestData()
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
			Warlock.SSonCD = true
	return Warlock
end

--Will set default assignments for curses / banishes and SS.
function SetDefaultAssignments(warlockTable)	
	for k, y in pairs(warlockTable) do
		if(k<3)then
			y.CurseAssignment = CurseOptions[k+1]
		else
			y.CurseAssignment = CurseOptions[1]
		end

		if(k<7) then
			y.BanishAssignment = BanishMarkers[k+1]
		else
			y.BanishAssignment = BanishMarkers[1]
		end

		if(k<=2) then
			local strSS = GetSSTargets()[k]
			--print(strSS)
			y.SSAssignment = strSS
		else
			local targets = GetSSTargets()
			y.SSAssignment = targets[GetTableLength(targets)]
		end
	end	
	return warlockTable
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

function HideFrame()
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
end

function GetLockyFriendFrameById(LockyFrameID)
	for key, value in pairs(LockyFrame.scrollframe.content.LockyFriendFrames) do
		--print(key, " -- ", value["LockyFrameID"])
		if value["LockyFrameID"] == LockyFrameID then
			return value
		end
	end
end


function OnShowFrame()
	print("Frame should be showing now.")	

	if not HasInitialized then		
	--	InitLockyFrameScrollArea()
		HasInitialized = true
	end
	--ok, on show we should register all of the warlocks in the raid using a loop.
	
	-- We should also 
	
	
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


--Creates a scroll area to hold the locky friend frames. 
--This logic was lifted from a snippet from wowprogramming.com I think....
--This needs a refactor.
function InitLockyFrameScrollArea()

	--parent frame 	
	LockyFrame = CreateFrame("Frame", nil, NeverLockyFrame) 
	LockyFrame:SetSize(LockyFriendFrameWidth-52, 500) 
	LockyFrame:SetPoint("CENTER", NeverLockyFrame, "CENTER", -9, 6) 
	
	--scrollframe 
	local scrollframe = CreateFrame("ScrollFrame", "LockyFriendsScroller_ScrollFrame", LockyFrame) 
	scrollframe:SetPoint("TOPLEFT", 2, -2) 
	scrollframe:SetPoint("BOTTOMRIGHT", -2, 2) 
	
	LockyFrame.scrollframe = scrollframe 
	
	--scrollbar 
	local scrollbar = CreateFrame("Slider", nil, scrollframe, "UIPanelScrollBarTemplate") 
	scrollbar:SetPoint("TOPLEFT", LockyFrame, "TOPRIGHT", 4, -16) 
	scrollbar:SetPoint("BOTTOMLEFT", LockyFrame, "BOTTOMRIGHT", 4, 16) 
	scrollbar:SetMinMaxValues(1, 200) 
	scrollbar:SetValueStep(1) 
	scrollbar.scrollStep = 1 
	scrollbar:SetValue(0) 
	scrollbar:SetWidth(16) 
	scrollbar:SetScript("OnValueChanged", 
		function (self, value) 
			self:GetParent():SetVerticalScroll(value) 
		end) 
	local scrollbg = scrollbar:CreateTexture(nil, "BACKGROUND") 
	scrollbg:SetAllPoints(scrollbar) 
	scrollbg:SetTexture(0, 0, 0, 0.8) 
	LockyFrame.scrollbar = scrollbar 
	--print("Created a Scroll Bar")
	
	--content frame 	
	local content = CreateFrame("Frame", nil, scrollframe) 
	content:SetSize(LockyFriendFrameWidth-77, 500) 
	
	content.LockyFriendFrames = {}
		
	--This is poorly optimized, but it is what it is.
	for i=0, 39 do
		table.insert(content.LockyFriendFrames, CreateLockyFriendFrame("Brylack", i, content))
	end

	scrollframe.content = content 
	-- 290 is perfect for housing 6 locky frames.
	-- 410 is perfect for housing 7
	-- 530 is perfect for housing 8
	scrollbar:SetMinMaxValues(1, GetMaxValueForScrollBar(content.LockyFriendFrames))
	
	print(GetTableLength(content.LockyFriendFrames))
	--print(GetMaxValueForScrollBar(content.LockyFriendFrames))

	scrollframe:SetScrollChild(content)

	UpdateAllLockyFriendFrames()
end

--Will take in a table object and return a number of pixels 
function GetMaxValueForScrollBar(LockyFrames)
	local numberOfFrames = GetTableLength(LockyFrames)
	--total frame height is 500 we can probably survive with hardcoding this.
	local _, mod = math.modf(500/LockyFriendFrameHeight)	
	local shiftFactor = ((1-mod)*LockyFriendFrameHeight) + 13 --There is roughly a 13 pixel spacer somewhere but I am having a hard time nailing it down.
	local FrameSupports = math.floor(500/LockyFriendFrameHeight)
	local FirstClippedFrame = math.ceil(500/LockyFriendFrameHeight)

	if numberOfFrames <= FrameSupports then
		return 1
	elseif numberOfFrames == FirstClippedFrame then --this is like a partial frame that wont render all the way.
		return shiftFactor
	elseif numberOfFrames > FirstClippedFrame then
		return (numberOfFrames-FirstClippedFrame)*LockyFriendFrameHeight + shiftFactor
	end
end


--[[
		A dropdown list of curses to assign.
		
		A dropdown list of names for SoulStones... or maybe a text box for the name... 
		
		A drop down list of raid markers for banish assignments.

		A dropdown to keep track of SS targets.
		
		A timer to keep track of SS CDs.

		A status indicator to show if locky friend has accepted the assignment.
	]]--
function CreateLockyFriendFrame(LockyName, number, scrollframe)	
	--Draws the Locky Friend Component Frame, adds the border, and positions it relative to the number of frames created.
	local LockyFrame = CreateLockyFriendContainer(scrollframe, number)
	LockyFrame.LockyFrameID  = "LockyFriendFrame_0"..tostring(number)
	LockyFrame.LockyName = LockyName
	
	--Creates a portrait to assist in identifying units.
	LockyFrame.Portrait = CreateLockyFriendPortrait(LockyFrame, LockyName) 
	
	-- Draws the name in the frame.
	LockyFrame.NamePlate = CreateNamePlate(LockyFrame, LockyName)

	--Draws the curse dropdown.
	LockyFrame.CurseAssignmentMenu = CreateCurseAssignmentMenu(LockyFrame)

	--Draw a BanishAssignment DropDownMenu
	LockyFrame.BanishAssignmentMenu = CreateBanishAssignmentMenu(LockyFrame)	

	--Draw a SS Assignment Menu.
	LockyFrame.SSAssignmentMenu = CreateSSAssignmentMenu(LockyFrame)

	--Draw the SSCooldownTracker
	LockyFrame.SSCooldownTracker = CreateSSCooldownTracker(LockyFrame.SSAssignmentMenu)
	
	return LockyFrame
end

--Creates a textframe.
function CreateSSCooldownTracker(ParentFrame)
	local TextFrame = AddTextToFrame(ParentFrame, "On CD for 24:13", 120)
	TextFrame:SetPoint("TOP", ParentFrame, "BOTTOM", 0,0)
	return TextFrame
end

--This will use the global locky friends data.
function UpdateAllLockyFriendFrames()
	ClearAllLockyFrames()
	ConsolidateFrameLocations()
	for key, value in pairs(LockyFriendsData) do
		UpdateLockyFrame(value, GetLockyFriendFrameById(value.LockyFrameLocation))
	end

	LockyFrame.scrollbar:SetMinMaxValues(1, GetMaxValueForScrollBar(LockyFriendsData))
end

--Loops through and clears all of the data currently loaded.
function  ClearAllLockyFrames()
	--print("Clearing the frames")
	for key, value in pairs(LockyFrame.scrollframe.content.LockyFriendFrames) do

		UpdateLockyFrame(nil, value)
		--print(value.LockyFrameID, "successfully cleared.")
	end
end

--This function will take in the warlock table object and update the frame assignment to make sense.
function  ConsolidateFrameLocations()
	--Need to loop through and assign a locky frame id to a locky friend.
	--print("Setting up FrameLocations for the locky friend data.")
	for key, value in pairs(LockyFriendsData) do		
		--print(value.Name, "will be assigned a frame.")
		value.LockyFrameLocation = LockyFrame.scrollframe.content.LockyFriendFrames[key].LockyFrameID;
		--print("Assigned Frame:",value.LockyFrameLocation)
	end
end

function UpdateLockyClockys()
	--[[
	Go through each lock.
	if SS is on CD then
	Update the CD Tracker Text
	else do nothing.
	]]--

	for k,v in pairs(LockyFriendsData) do
		if(v.SSonCD) then
			-- We have the table item for the SSCooldown			
			local CDLength = 30*60
			local result = SecondsToTime(math.floor(v.SSCooldown + CDLength - GetTime()))			
			--print(result)
			local frame = GetLockyFriendFrameById(v.LockyFrameLocation)
			frame.SSCooldownTracker:SetText("CD "..result)

			if math.floor(v.SSCooldown + CDLength - GetTime()) <=0 then
				v.SSonCD = false
				frame.SSCooldownTracker:SetText("Available")
			end
		end
	end


end

--Will update a locky friend frame with the warlock data passed in.
--If the warlock object is null it will clear and hide the data from the screen.
function UpdateLockyFrame(Warlock, LockyFriendFrame)
	--print("Updating Locky Frame")	
	if(Warlock == nil) then
		LockyFriendFrame:Hide()
		Warlock = {}
		Warlock.Name = ""
		Warlock.CurseAssignment = "None"
		Warlock.BanishAssignment = "None"
		Warlock.SSAssignment = "None"
		Warlock.SSCooldown=nil
		Warlock.AcceptedAssignments = false
		Warlock.LockyFrameLocation = ""
	else
		LockyFriendFrame:Show()
	end
	--Set the nametag
	--print("Updating Nameplate Text to: ".. Warlock.Name)
	LockyFriendFrame.NamePlate.TextFrame:SetText(Warlock.Name)
	--Set the CurseAssignment
	--print("Updating Curse to: ".. Warlock.CurseAssignment) -- this may need to be done by index.....
	--GetIndexFromTable(CurseOptions, Warlock.CurseAssignment)
	UIDropDownMenu_SetSelectedID(LockyFriendFrame.CurseAssignmentMenu, GetIndexFromTable(CurseOptions, Warlock.CurseAssignment))
	UpdateCurseGraphic(LockyFriendFrame.CurseAssignmentMenu, GetCurseValueFromDropDownList(LockyFriendFrame.CurseAssignmentMenu))
	LockyFriendFrame.CurseAssignmentMenu.Text:SetText(GetCurseValueFromDropDownList(LockyFriendFrame.CurseAssignmentMenu))
	
	--Set the BanishAssignmentMenu
	--print("Updating Banish to: ".. Warlock.BanishAssignment)
	UIDropDownMenu_SetSelectedID(LockyFriendFrame.BanishAssignmentMenu, GetIndexFromTable(BanishMarkers, Warlock.BanishAssignment))
	UpdateBanishGraphic(LockyFriendFrame.BanishAssignmentMenu, GetValueFromDropDownList(LockyFriendFrame.BanishAssignmentMenu, BanishMarkers))
	LockyFriendFrame.BanishAssignmentMenu.Text:SetText(GetValueFromDropDownList(LockyFriendFrame.BanishAssignmentMenu, BanishMarkers))

	--Set the SS Assignment
	--print("Updating SS to: ".. Warlock.SSAssignment)
	UIDropDownMenu_SetSelectedID(LockyFriendFrame.SSAssignmentMenu, GetIndexFromTable(GetSSTargets(),Warlock.SSAssignment))
	LockyFriendFrame.SSAssignmentMenu.Text:SetText(GetValueFromDropDownList(LockyFriendFrame.SSAssignmentMenu, GetSSTargets()))

	--Update the Portrait picture	
	if Warlock.Name=="" then
		LockyFriendFrame.Portrait:Hide()		
	else
		--print("Trying to set diff portrait")
		if(LockyFriendFrame.Portrait.Texture == nil) then
			--print("The obj never existed")
			local PortraitGraphic = LockyFriendFrame.Portrait:CreateTexture(nil, "OVERLAY") 
			PortraitGraphic:SetAllPoints()
			SetPortraitTexture(PortraitGraphic, Warlock.Name)
			LockyFriendFrame.Portrait.Texture = PortraitGraphic
		else
			--print("the obj exists")
			SetPortraitTexture(LockyFriendFrame.Portrait.Texture, Warlock.Name)
		end
		LockyFriendFrame.Portrait:Show()
	end

	return LockyFriendFrame.LockyFrameID
end

function GetIndexFromTable(table, value)
	local index={}
	for k,v in pairs(table) do
	   index[v]=k
	end
	return index[value]
end

--Creates the frame that will act as teh container for the component control.
function CreateLockyFriendContainer(ParentFrame, number)
	local LockyFriendFrame = CreateFrame("Frame", nil, ParentFrame) 
	LockyFriendFrame:SetSize(LockyFriendFrameWidth-67, LockyFriendFrameHeight) 
	--Set up the border around the locky frame.
	LockyFriendFrame:SetBackdrop({
		bgFile= "Interface\\DialogFrame\\UI-DialogBox-Background",
		edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border", 
		tile = true,
		tileSize = 32,
		edgeSize = 32,
		insets = { left = 0, right = 0, top = 0, bottom = 0 }
	})	
	--Calculate where to draw the frame on the screen.
	local yVal = (number*(-LockyFriendFrameHeight))-10
	LockyFriendFrame:SetPoint("TOPLEFT", ParentFrame, "TOPLEFT", 8, yVal)
	
	return LockyFriendFrame
end

--Creates and assigns the player portrait to the individual raiders in the contrl.
function CreateLockyFriendPortrait(ParentFrame, UnitName)
	local portrait = CreateFrame("Frame", nil, ParentFrame) 
		portrait:SetSize(80,80)
		portrait:SetPoint("LEFT", 13, -5)
	local texture = portrait:CreateTexture(nil, "BACKGROUND") 
	texture:SetAllPoints() 
	--texture:SetTexture("Interface\\GLUES\\MainMenu\\Glues-BlizzardLogo") 
	--SetPortraitTexture(texture, UnitName)
	portrait.Texture = texture 
	
	return portrait
end

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

--Builds and sets the banish Icon assignment menu.
function CreateBanishAssignmentMenu(ParentFrame)
	local BanishAssignmentMenu = CreateDropDownMenu(ParentFrame, BanishMarkers, "BANISH")
	BanishAssignmentMenu:SetPoint("CENTER", -50, -30)	
	BanishAssignmentMenu.Label = CreateBanishAssignmentLabel(BanishAssignmentMenu)


	local BanishGraphicFrame = CreateFrame("Frame", nil, ParentFrame)
	BanishGraphicFrame:SetSize(30,30)
	BanishGraphicFrame:SetPoint("LEFT", BanishAssignmentMenu, "RIGHT", -12, 8)
	
	BanishAssignmentMenu.BanishGraphicFrame = BanishGraphicFrame
	
	return BanishAssignmentMenu
end

--Creates and sets the Banish Assignment Label as part of the banish assignment control.
function CreateBanishAssignmentLabel(ParentFrame)
	local Label = AddTextToFrame(ParentFrame, "Banish Assignment", 150)
	Label:SetPoint("BOTTOMLEFT", ParentFrame, "TOPLEFT", 0, 0)
	return Label
end

--Creates and sets the nameplate for the Locky Friends Frame.
function CreateNamePlate(ParentFrame, Text)
	local NameplateFrame = ParentFrame:CreateTexture(nil, "OVERLAY")
	NameplateFrame:SetSize(205, 50)
	NameplateFrame:SetTexture("Interface\\DialogFrame\\UI-DialogBox-Header")
	NameplateFrame:SetPoint("LEFT", ParentFrame, "TOPLEFT", -45, -20)

	local TextFrame = AddTextToFrame(ParentFrame, Text, 90)
	TextFrame:SetPoint("TOPLEFT", 10,-6)

	NameplateFrame.TextFrame = TextFrame

	return NameplateFrame
end

-- Adds text to a frame that is passed in.
-- This text will not be automatically displayed and must be anchored before it will render to the screen.
function AddTextToFrame(ParentFrame, Text, Width)
	local NamePlate = ParentFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
		NamePlate:SetText(Text)
		NamePlate:SetWidth(Width)
		NamePlate:SetJustifyH("CENTER")
		NamePlate:SetJustifyV("CENTER")
		NamePlate:SetTextColor(1,1,1,1)
	return NamePlate
end

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

--Creates the curse assignment menu.
function CreateCurseAssignmentMenu(ParentFrame)			
	local CurseAssignmentMenu = CreateDropDownMenu(ParentFrame, CurseOptions, "CURSE")
	CurseAssignmentMenu:SetPoint("CENTER", -50, 20)	
	CurseAssignmentMenu.Label = CreateCurseAssignmentLabel(CurseAssignmentMenu)
	
	local CurseGraphicFrame = CreateFrame("Frame", nil, ParentFrame)
		CurseGraphicFrame:SetSize(30,30)
		CurseGraphicFrame:SetPoint("LEFT", CurseAssignmentMenu, "RIGHT", -12, 8)
	
	CurseAssignmentMenu.CurseGraphicFrame = CurseGraphicFrame
	
	return CurseAssignmentMenu
end

--Parent Frame is the drop down control.
--Curse List Value should be the plain text version of the selected curse option.
function UpdateCurseGraphic(ParentFrame, CurseListValue)
	--print("Updating Curse Graphic to " .. CurseListValue)
	if not (CurseListValue == nil) then
		if(ParentFrame.CurseGraphicFrame.CurseTexture == nil) then
			local CurseGraphic = ParentFrame.CurseGraphicFrame:CreateTexture(nil, "OVERLAY") 
			CurseGraphic:SetAllPoints()
			CurseGraphic:SetTexture(GetSpellTexture(GetSpellNameFromDropDownList(CurseListValue)))
			ParentFrame.CurseGraphicFrame.CurseTexture = CurseGraphic
		else
			ParentFrame.CurseGraphicFrame.CurseTexture:SetTexture(GetSpellTexture(GetSpellNameFromDropDownList(CurseListValue)))		
		end		
	else 
		if not (ParentFrame.CurseGraphicFrame.CurseTexture == nil) then
			local CurseGraphic = ParentFrame.CurseGraphicFrame:CreateTexture(nil, "OVERLAY") 
			CurseGraphic:SetAllPoints()
			CurseGraphic:SetTexture(0,0,0,0)
			ParentFrame.CurseGraphicFrame.CurseTexture = CurseGraphic
		else
			ParentFrame.CurseGraphicFrame.CurseTexture:SetTexture(0,0,0,0)		
		end
	end
end

--Parent Frame is the drop down control.
function UpdateBanishGraphic(ParentFrame, BanishListValue)
	--print("Updating Banish Graphic to " .. BanishListValue)
	if not (BanishListValue == nil) then
		if(ParentFrame.BanishGraphicFrame.BanishTexture == nil) then
			local BanishGraphic = ParentFrame.BanishGraphicFrame:CreateTexture(nil, "OVERLAY") 
			BanishGraphic:SetAllPoints()
			BanishGraphic:SetTexture(GetAssetLocationFromRaidMarker(BanishListValue))
			ParentFrame.BanishGraphicFrame.BanishTexture = BanishGraphic
		else
			--print("|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_1|t")
			ParentFrame.BanishGraphicFrame.BanishTexture:SetTexture(GetAssetLocationFromRaidMarker(BanishListValue))
		end
	else 
		if not (ParentFrame.BanishGraphicFrame.BanishTexture == nil) then
			local BanishGraphic = ParentFrame.BanishGraphicFrame:CreateTexture(nil, "OVERLAY") 
			BanishGraphic:SetAllPoints()
			BanishGraphic:SetColorTexture(0,0,0,0)
			ParentFrame.BanishGraphicFrame.BanishTexture = BanishGraphic
		else
			ParentFrame.BanishGraphicFrame.BanishTexture:SetColorTexture(0,0,0,0)		
		end
	end
end

--Generic function that will get called by any drop down to update the graphic that is displayed next to it.
-- This event is what is fired when a box is changed manually. 
-- This event does not fire when the dropdown selection is changed programmatically.
-- This acts as a router to determine which menu was changed, if the menu is not of a certain "DropDownType" then this function does nothing.
function UpdateDropDownSideGraphic(DropDownMenu, SelectedValue, DropDownType)
	if DropDownType == "CURSE" then
		UpdateCurseGraphic(DropDownMenu, SelectedValue)
	elseif DropDownType == "BANISH" then
		UpdateBanishGraphic(DropDownMenu, SelectedValue)
	end
end

-- Gets the selected value of the cures from the drop down list.
-- Use GetValueFromDropDownList instead.
function GetCurseValueFromDropDownList(DropDownMenu)
	local selectedValue = UIDropDownMenu_GetSelectedID(DropDownMenu)
	return CurseOptions[selectedValue]
end

-- Gets the selected value of the banish target from the drop down list.
-- This is arguably an easier way than referencing the getvalue from dropdown list function.
function GetBanishValueFromDropDownList(DropDownMenu)
	local selectedValue = UIDropDownMenu_GetSelectedID(DropDownMenu)
	return BanishMarkers[selectedValue]
end

-- Returns the value of the selected option in a drop down menu.
-- This exists because the built in UIDropDownMenu_GetSelectedValue appears to be broken.
-- Of course, it is probable that I am using the drop down menu incorrectly in this case.
function GetValueFromDropDownList(DropDownMenu, OptionList)
	local selectedValue = UIDropDownMenu_GetSelectedID(DropDownMenu)
	return OptionList[selectedValue]
end

-- Function that converts the Option Value to the Spell Name.
-- This is used for setting the appropriate texture in in the sidebar graphic.
-- Acts as a converter from our "Locky Spell Name" to the actual in-game name.
function GetSpellNameFromDropDownList(ListValue)
	if ListValue == "Elements" then
		return "Curse of the Elements"
	elseif ListValue == "Shadows" then
		return "Curse of Shadow"
	elseif ListValue == "Recklessness" then
		return "Curse of Recklessness"
	elseif ListValue == "Doom LOL" then
		return "Curse of Doom"
	elseif ListValue == "Agony" then
		return "Curse of Agony"
	elseif ListValue == "Tongues" then
		return "Curse of Tongues"
	elseif ListValue == "Weakness" then
		return "Curse of Weakness"
	end
	return nil
end

-- Function provides the asset location of the raid targetting icon.
-- E.X. Converts "Star" to - Interface\\TargetingFrame\\UI-RaidTargetingIcon_1
function GetAssetLocationFromRaidMarker(raidMarker)
	if(raidMarker == "Skull") then
		return "Interface\\TargetingFrame\\UI-RaidTargetingIcon_8"
	elseif raidMarker == "Star" then
		return "Interface\\TargetingFrame\\UI-RaidTargetingIcon_1"
	elseif raidMarker == "Circle" then
		return "Interface\\TargetingFrame\\UI-RaidTargetingIcon_2"
	elseif raidMarker == "Diamond" then
		return "Interface\\TargetingFrame\\UI-RaidTargetingIcon_3"
	elseif raidMarker == "Triangle" then
		return "Interface\\TargetingFrame\\UI-RaidTargetingIcon_4"
	elseif raidMarker == "Moon" then
		return "Interface\\TargetingFrame\\UI-RaidTargetingIcon_5"
	elseif raidMarker == "Square" then
		return "Interface\\TargetingFrame\\UI-RaidTargetingIcon_6"
	elseif raidMarker == "Cross" then
		return "Interface\\TargetingFrame\\UI-RaidTargetingIcon_7"
	end
	return nil
end

--Creates the label for the curse assignment. This may not need to have been encapsulated as such but it made sense to me at the time.
function CreateCurseAssignmentLabel(ParentFrame)
	local Label = AddTextToFrame(ParentFrame, "Curse Assignment", 150)
	Label:SetPoint("BOTTOMLEFT", ParentFrame, "TOPLEFT", 0, 0)
	return Label
end

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

--Builds and sets the banish Icon assignment menu.
--Parent Frame refers to a "LockyFriendFrame"
function CreateSSAssignmentMenu(ParentFrame)

	local SSTargets = GetSSTargets();

	local SSAssignmentMenu = CreateDropDownMenu(ParentFrame, SSTargets, "SS")
	SSAssignmentMenu:SetPoint("CENTER", 140, 20)	
	SSAssignmentMenu.Label = CreateSSAssignmentLabel(SSAssignmentMenu)
	
	return SSAssignmentMenu
end

--Create's the "Soul Stone" Label that appears above the soul stone target drop down menu.
function  CreateSSAssignmentLabel(ParentFrame)
	local Label = AddTextToFrame(ParentFrame, "Soul Stone", 130)
	Label:SetPoint("BOTTOMLEFT", ParentFrame, "TOPLEFT", 0, 0)
	return Label
end

local dropdowncount = 0

--Creates and adds a dropdown menu with the passed in option list. 
--Adding a dropdown type further allows for the sidebar graphic to update as well, but is not required.
function CreateDropDownMenu(ParentFrame, OptionList, DropDownType)
	dropdowncount = dropdowncount + 1
	local NewDropDownMenu = CreateFrame("Button", "DropDown0"..dropdowncount, ParentFrame, "UIDropDownMenuTemplate")

	local function OnClick(self)		
	    UIDropDownMenu_SetSelectedID(NewDropDownMenu, self:GetID())
	   
		local selection = GetValueFromDropDownList(NewDropDownMenu, OptionList)
		print("User changed selection to " .. selection)
		UpdateDropDownSideGraphic(NewDropDownMenu, selection, DropDownType)
	end
	
	

	local function initialize(self, level)
	   local info = UIDropDownMenu_CreateInfo()
	   for k,v in pairs(OptionList) do
		  info = UIDropDownMenu_CreateInfo()
		  info.text = v
		  info.value = v
		  info.func = OnClick
		  UIDropDownMenu_AddButton(info, level)
	   end
	end
	UIDropDownMenu_Initialize(NewDropDownMenu, initialize)
	UIDropDownMenu_SetWidth(NewDropDownMenu, 100);
	UIDropDownMenu_SetButtonWidth(NewDropDownMenu, 124)
	UIDropDownMenu_SetSelectedID(NewDropDownMenu, 1)
	UIDropDownMenu_JustifyText(NewDropDownMenu, "LEFT")
	
	return NewDropDownMenu
end

function GetTableLength(T)
	local count = 0
	for _ in pairs(T) do count = count + 1 end
	return count
end