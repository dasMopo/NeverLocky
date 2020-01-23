RaidMode = false;
LockyFriendFrameWidth = 500;
HasInitialized = false;

LockyFriendsData = {};


local function OnEvent(self, event, isInitialLogin, isReloadingUi)
	if isInitialLogin or isReloadingUi then
		--print("loaded the UI")
		if not HasInitialized then
			InitLockyFrameScrollArea()
			HasInitialized = true
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

function RegisterWarlocks()
	local raidInfo = {}
	for i=1, 40 do
		local name, rank, subgroup, level, class, fileName, 
		  zone, online, isDead, role, isML = GetRaidRosterInfo(i);
		if not (name == nil) then
			if fileName == "WARLOCK" then
				print(name .. "-" .. fileName)

				local Warlock
				Warlock.Name = name
				Warlock.CurseAssignment = "None"
				Warlock.BanishAssignment = "None"
				Warlock.SSAssignment = "None"
				Warlock.SSCooldown=nil
				Warlock.AcceptedAssignments = false
				Warlock.LockyFrameLocation = ""

				table.insert(raidInfo, Warlock)
			end
		end		
	end
	return raidInfo
end

function HideFrame()
	--print("Hiding NeverLockyFrame.")
	NeverLockyFrame:Hide()
end

function Refresh()
	print("Updating a frame....")
	if not (LockyFrame == nil) then		
		--[[
		Ok.... so.....

		My Data is WAY too coupled to the UI.

		So I need to decouple it.

		The best way to do that is to initialize the UI to have up to 10 warlocks.		
		then hide all of the newly created frames.

		Then create a table that is the representation of the data.

		Then I can set up a routine that will set / hide frames as needed.
		]]--


		local testFrame = GetLockyFriendFrameById("3")
		
		print(testFrame.LockyFrameID)


		local Warlock = {}
				Warlock.Name = "SocioPath"
				Warlock.CurseAssignment = "Agony"
				Warlock.BanishAssignment = "Moon"
				Warlock.SSAssignment = "Priest2"
				Warlock.SSCooldown=nil
				Warlock.AcceptedAssignments = false
				Warlock.LockyFrameLocation = ""

		UpdateLockyFrame(Warlock, testFrame)

		local testFrame = GetLockyFriendFrameById("4")
		UpdateLockyFrame(nil, testFrame)
		--testFrame:Hide()

		local testFrame = GetLockyFriendFrameById("5")
		UpdateLockyFrame(nil, testFrame)
		--testFrame:Hide()
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

function InitLockyFrameScrollArea()
	--parent frame 
	--print("running demo")
	LockyFrame = CreateFrame("Frame", nil, NeverLockyFrame) 
	LockyFrame:SetSize(LockyFriendFrameWidth-52, 500) 
	LockyFrame:SetPoint("CENTER", NeverLockyFrame, "CENTER", -9, 6) 
		
	--[[frame:SetBackdrop({
		bgFile= "Interface\\DialogFrame\\UI-DialogBox-Background",
		edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border", 
		tile = true,
		tileSize = 32,
		edgeSize = 32,
		insets = { left = 0, right = 0, top = 0, bottom = 0 }
	})
	frame:SetBackdropColor(0,0,0,1);
	]]--
	
	--scrollframe 
	local scrollframe = CreateFrame("ScrollFrame", "LockyFriendsScroller_ScrollFrame", LockyFrame) 
	scrollframe:SetPoint("TOPLEFT", 2, -2) 
	scrollframe:SetPoint("BOTTOMRIGHT", -2, 2) 
	
	LockyFrame.scrollframe = scrollframe 
	--print("Created a Scroll Frame")
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
	--[[	
	content:SetBackdrop({
		bgFile= "Interface\\DialogFrame\\UI-DialogBox-Background",
		edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border", 
		tile = true,
		tileSize = 32,
		edgeSize = 32,
		insets = { left = 0, right = 0, top = 0, bottom = 0 }
	})
	]]--
	
	content.LockyFriendFrames = {}
	
	if(RaidMode) then
		local RaidyFriends = RegisterRaid();
		for k, v in pairs(RaidyFriends) do 
			print(k, v) 
			table.insert(content.LockyFriendFrames, CreateLockyFriendFrame(v, k-1, content))
		end
	else
		for i=0, 5 do
			table.insert(content.LockyFriendFrames, CreateLockyFriendFrame("Brylack", i, content))
		end
	end
	
	
	scrollframe.content = content 
	
	scrollbar:SetMinMaxValues(1, 290)
	
	scrollframe:SetScrollChild(content)
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
	LockyFrame.LockyFrameID  = tostring(number)
	LockyFrame.LockyName = LockyName
	
	--Creates a portrait to assist in identifying units.
	LockyFrame.Portrait = CreateLockyFriendPortrait(LockyFrame, LockyName) 
	
	-- Draws the name in the frame.
	LockyFrame.NamePlate = CreateNamePlate(LockyFrame, LockyName)
	
	--Interesting enough, if you attempt to set the selected ID After creating another box, then it ends up doing something weird and crossing wires...
	--Not sure how to get around that at this time...

	--Draws the curse dropdown.
	LockyFrame.CurseAssignmentMenu = CreateCurseAssignmentMenu(LockyFrame)
	--Sets a default suggested curse assignment.
	if(number < 3) then
		UIDropDownMenu_SetSelectedID(LockyFrame.CurseAssignmentMenu, number+2)
	end

	--Draw a BanishAssignment DropDownMenu
	LockyFrame.BanishAssignmentMenu = CreateBanishAssignmentMenu(LockyFrame)
	--Sets a default suggested banish target.
	if(number < 7) then
		UIDropDownMenu_SetSelectedID(LockyFrame.BanishAssignmentMenu, number+2)
	end	

	--Draw a SS Assignment Menu.
	LockyFrame.SSAssignmentMenu = CreateSSAssignmentMenu(LockyFrame)
	--Sets a default suggested SS target.
	UIDropDownMenu_SetSelectedID(LockyFrame.SSAssignmentMenu, number+1)
	
	--I am not sure if this should be handled here....
	UpdateCurseGraphic(LockyFrame.CurseAssignmentMenu, GetCurseValueFromDropDownList(LockyFrame.CurseAssignmentMenu))	
	UpdateBanishGraphic(LockyFrame.BanishAssignmentMenu, GetValueFromDropDownList(LockyFrame.BanishAssignmentMenu, BanishMarkers))

	LockyFrame.ClearData = function ()
		UpdateLockyFrame(nil, LockyFrame)
	end

	return LockyFrame
end


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
	print("Updating SS to: ".. Warlock.SSAssignment)
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
	LockyFriendFrame:SetSize(LockyFriendFrameWidth-67, 128) 
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
	local yVal = (number*(-128))-10
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
	SetPortraitTexture(texture, UnitName)
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

--Creates and sets the nameplate for the Locky Friends.
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
function UpdateDropDownSideGraphic(DropDownMenu, SelectedValue, DropDownType)
	if DropDownType == "CURSE" then
		UpdateCurseGraphic(DropDownMenu, SelectedValue)
	elseif DropDownType == "BANISH" then
		UpdateBanishGraphic(DropDownMenu, SelectedValue)
	end
end

-- OBSOLETE -- Gets the selected value of the cures from the drop down list.
-- Use GetValueFromDropDownList instead.
function GetCurseValueFromDropDownList(DropDownMenu)
	local selectedValue = UIDropDownMenu_GetSelectedID(DropDownMenu)
	return CurseOptions[selectedValue]
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
function CreateSSAssignmentMenu(ParentFrame)

	local SSTargets = GetSSTargets();

	local SSAssignmentMenu = CreateDropDownMenu(ParentFrame, SSTargets, "SS")
	SSAssignmentMenu:SetPoint("CENTER", 140, 20)	
	SSAssignmentMenu.Label = CreateSSAssignmentLabel(SSAssignmentMenu)
	
	return SSAssignmentMenu
end

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