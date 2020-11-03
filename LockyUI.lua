
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
	scrollbar:SetMinMaxValues(1, NL_GetMaxValueForScrollBar(content.LockyFriendFrames))
	
	--print(GetTableLength(content.LockyFriendFrames))
	--print(GetMaxValueForScrollBar(content.LockyFriendFrames))

	scrollframe:SetScrollChild(content)

	--UpdateAllLockyFriendFrames()
	NeverLockyFrame.WarningTextFrame = CreateFrame("Frame", nil, NeverLockyFrame);
	NeverLockyFrame.WarningTextFrame:SetSize(250, 30);
	NeverLockyFrame.WarningTextFrame:SetPoint("BOTTOMLEFT", NeverLockyFrame, "BOTTOMLEFT", 0, 0)
	
	NeverLockyFrame.WarningTextFrame.value = NL_AddTextToFrame(NeverLockyFrame.WarningTextFrame, "Warning your addon is out of date!", 240)
	NeverLockyFrame.WarningTextFrame.value:SetPoint("LEFT", NeverLockyFrame.WarningTextFrame, "LEFT", 0, 0);
	NeverLockyFrame.WarningTextFrame:Hide();
end

--Will take in a table object and return a number of pixels 
function NL_GetMaxValueForScrollBar(LockyFrames)
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
    LockyFrame.NamePlate = NL_CreateNamePlate(LockyFrame, LockyName)

    --Draws the curse dropdown.
    LockyFrame.CurseAssignmentMenu = CreateCurseAssignmentMenu(LockyFrame)

    --Draw a BanishAssignment DropDownMenu
    LockyFrame.BanishAssignmentMenu = CreateBanishAssignmentMenu(LockyFrame)	

    --Draw a SS Assignment Menu.
    LockyFrame.SSAssignmentMenu = CreateSSAssignmentMenu(LockyFrame)

    --Draw the SSCooldownTracker
    LockyFrame.SSCooldownTracker = CreateSSCooldownTracker(LockyFrame.SSAssignmentMenu)
	
	LockyFrame.AssignmentAcknowledgement = CreateAckFrame(LockyFrame);

	LockyFrame.Warning = CreateWarningFrame(LockyFrame);

    return LockyFrame
end

--Creates a textframe to display the SS cooldown.
function CreateSSCooldownTracker(ParentFrame)
    local TextFrame = NL_AddTextToFrame(ParentFrame, "Available", 120)
    TextFrame:SetPoint("TOP", ParentFrame, "BOTTOM", 0,0)
    return TextFrame
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

--Builds and sets the banish Icon assignment menu.
function CreateBanishAssignmentMenu(ParentFrame)
	local BanishAssignmentMenu = NL_CreateDropDownMenu(ParentFrame, BanishMarkers, "BANISH")
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
	local Label = NL_AddTextToFrame(ParentFrame, "Banish Assignment", 150)
	Label:SetPoint("BOTTOMLEFT", ParentFrame, "TOPLEFT", 0, 0)
	return Label
end

--Creates and sets the nameplate for the Locky Friends Frame.
function NL_CreateNamePlate(ParentFrame, Text)
	local NameplateFrame = ParentFrame:CreateTexture(nil, "OVERLAY")
	NameplateFrame:SetSize(205, 50)
	NameplateFrame:SetTexture("Interface\\DialogFrame\\UI-DialogBox-Header")
	NameplateFrame:SetPoint("LEFT", ParentFrame, "TOPLEFT", -45, -20)

	local TextFrame = NL_AddTextToFrame(ParentFrame, Text, 90)
	TextFrame:SetPoint("TOPLEFT", 10,-6)

	NameplateFrame.TextFrame = TextFrame

	return NameplateFrame
end

-- Adds text to a frame that is passed in.
-- This text will not be automatically displayed and must be anchored before it will render to the screen.
function NL_AddTextToFrame(ParentFrame, Text, Width)
	local NamePlate = ParentFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
		NamePlate:SetText(Text)
		NamePlate:SetWidth(Width)
		NamePlate:SetJustifyH("CENTER")
		NamePlate:SetJustifyV("CENTER")
		NamePlate:SetTextColor(1,1,1,1)
	return NamePlate
end

--Creates the curse assignment menu.
function CreateCurseAssignmentMenu(ParentFrame)			
	local CurseAssignmentMenu = NL_CreateDropDownMenu(ParentFrame, CurseOptions, "CURSE")
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
			CurseGraphic:SetTexture(GetSpellTexture(GetSpellIdFromDropDownList(CurseListValue)))
			ParentFrame.CurseGraphicFrame.CurseTexture = CurseGraphic
		else
			ParentFrame.CurseGraphicFrame.CurseTexture:SetTexture(GetSpellTexture(GetSpellIdFromDropDownList(CurseListValue)))		
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

-- Function that converts the Option Value to the Spell Name.
-- This is used for setting the appropriate texture in in the sidebar graphic.
-- Acts as a converter from our "Locky Spell Name" to the actual in-game name.
function GetSpellIdFromDropDownList(ListValue)
	if ListValue == "Elements" then
		return 11722
	elseif ListValue == "Shadows" then
		return 17937
	elseif ListValue == "Recklessness" then
		return 11717
	elseif ListValue == "Doom LOL" then
		return 603
	elseif ListValue == "Agony" then
		return 11713
	elseif ListValue == "Tongues" then
		return 11719
	elseif ListValue == "Weakness" then
		return 11708
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
	local Label = NL_AddTextToFrame(ParentFrame, "Curse Assignment", 150)
	Label:SetPoint("BOTTOMLEFT", ParentFrame, "TOPLEFT", 0, 0)
	return Label
end


--Builds and sets the banish Icon assignment menu.
--Parent Frame refers to a "LockyFriendFrame"
function CreateSSAssignmentMenu(ParentFrame)

	local SSTargets = GetSSTargets();

	local SSAssignmentMenu = NL_CreateDropDownMenu(ParentFrame, SSTargets, "SS")
	SSAssignmentMenu:SetPoint("CENTER", 140, 20)	
	SSAssignmentMenu.Label = CreateSSAssignmentLabel(SSAssignmentMenu)
	
	return SSAssignmentMenu
end

function CreateAckFrame(ParentFrame)
	local AckFrame = CreateFrame("Frame", nil, ParentFrame)
	AckFrame:SetSize(150,30)
	AckFrame:SetPoint("CENTER", ParentFrame, "CENTER",80,-25)

	AckFrame.label = NL_AddTextToFrame(AckFrame, "Accepted:", 150)
	AckFrame.label:SetPoint("LEFT", AckFrame, "LEFT", 0, 0)

	AckFrame.value = NL_AddTextToFrame(AckFrame, "Not Recieved", 120)
	AckFrame.value:SetPoint("LEFT", AckFrame, "LEFT", 85, 0)
	return AckFrame;
end

function CreateWarningFrame(ParentFrame)
	local NoteFrame = CreateFrame("Frame", nil, ParentFrame)
	NoteFrame:SetSize(150, 30)
	NoteFrame:SetPoint("BOTTOMLEFT", ParentFrame, "BOTTOMLEFT",0,0)
	NoteFrame.value = NL_AddTextToFrame(NoteFrame, "Warning: Addon out of date", 250)
	NoteFrame.value:SetPoint("LEFT", NoteFrame, "LEFT", 0, 0)
	NoteFrame:Hide();
	return NoteFrame;
end

--Create's the "Soul Stone" Label that appears above the soul stone target drop down menu.
function  CreateSSAssignmentLabel(ParentFrame)
	local Label = NL_AddTextToFrame(ParentFrame, "Soul Stone", 130)
	Label:SetPoint("BOTTOMLEFT", ParentFrame, "TOPLEFT", 0, 0)
	return Label
end

local dropdowncount = 0

--Creates and adds a dropdown menu with the passed in option list. 
--Adding a dropdown type further allows for the sidebar graphic to update as well, but is not required.
function NL_CreateDropDownMenu(ParentFrame, OptionList, DropDownType)
    dropdowncount = dropdowncount + 1
    local NewDropDownMenu = CreateFrame("Button", "NL_DropDown0"..dropdowncount, ParentFrame, "UIDropDownMenuTemplate")

    local function OnClick(self)		
        UIDropDownMenu_SetSelectedID(NewDropDownMenu, self:GetID())
    
		local selection = GetValueFromDropDownList(NewDropDownMenu, OptionList)
		if NL_DebugMode then
			print("User changed selection to " .. selection)
		end
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

function UpdateDropDownMenuWithNewOptions(DropDownMenu, OptionList, DropDownType)
	local function OnClick(self)		
        UIDropDownMenu_SetSelectedID(DropDownMenu, self:GetID())
    
		local selection = GetValueFromDropDownList(DropDownMenu, OptionList)
		if NL_DebugMode then
			print("User changed selection to " .. selection)
		end
        UpdateDropDownSideGraphic(DropDownMenu, selection, DropDownType)
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
	
	UIDropDownMenu_Initialize(DropDownMenu, initialize)
    UIDropDownMenu_SetWidth(DropDownMenu, 100);
    UIDropDownMenu_SetButtonWidth(DropDownMenu, 124)
    UIDropDownMenu_SetSelectedID(DropDownMenu, 1)
    UIDropDownMenu_JustifyText(DropDownMenu, "LEFT")
end

function InitLockyAssignCheckFrame()
	LockyAssignCheckFrame =  CreateFrame("Frame", nil, UIParent);

	LockyAssignCheckFrame:SetSize(200, 175) 
	LockyAssignCheckFrame:SetPoint("CENTER", UIParent, "CENTER",0,0) 
	LockyAssignCheckFrame:SetBackdrop({
		bgFile= "Interface\\DialogFrame\\UI-DialogBox-Background",
		edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border", 
		tile = true,
		tileSize = 32,
		edgeSize = 32,
		insets = { left = 5, right = 5, top = 5, bottom = 5 }
	});

	LockyAssignCheckFrame:RegisterForDrag("LeftButton");
	LockyAssignCheckFrame:SetMovable(true);
	LockyAssignCheckFrame:EnableMouse(true);

	LockyAssignCheckFrame:SetScript("OnDragStart", LockyAssignCheckFrame.StartMoving);
	LockyAssignCheckFrame:SetScript("OnDragStop", LockyAssignCheckFrame.StopMovingOrSizing);

	LockyAssignRejectButton = CreateFrame("Button", nil, LockyAssignCheckFrame, "GameMenuButtonTemplate");
	LockyAssignRejectButton:SetSize(70,20);
	LockyAssignRejectButton:SetPoint("BOTTOMRIGHT", LockyAssignCheckFrame, "BOTTOMRIGHT",-15,15)
	LockyAssignRejectButton:SetText("No");
	LockyAssignRejectButton:SetScript("OnClick", LockyAssignRejectClick);

	LockyAssignAcceptButton = CreateFrame("Button", nil, LockyAssignCheckFrame, "GameMenuButtonTemplate");
	LockyAssignAcceptButton:SetSize(70,20);
	LockyAssignAcceptButton:SetPoint("RIGHT", LockyAssignRejectButton, "LEFT",-5,0)
	LockyAssignAcceptButton:SetText("Yes");
	LockyAssignAcceptButton:SetScript("OnClick", LockyAssignAcceptClick);

	LockyAssignCheckFrame.AcceptButton = LockyAssignAcceptButton;
	LockyAssignCheckFrame.RejectButton = LockyAssignRejectButton;

	LockyAssignCheckFrame.Label = NL_AddTextToFrame(LockyAssignCheckFrame, "Your new assignments:", 140)
	LockyAssignCheckFrame.Label:SetPoint("TOPLEFT", LockyAssignCheckFrame, "TOPLEFT", 10, -15)

	LockyAssignCheckFrame.CurseLabel = NL_AddTextToFrame(LockyAssignCheckFrame, "Curse:", 130)
	LockyAssignCheckFrame.CurseLabel:SetPoint("TOPLEFT", LockyAssignCheckFrame, "TOPLEFT", 0, -37)


	local CurseGraphicFrame = CreateFrame("Frame", nil, LockyAssignCheckFrame)
	CurseGraphicFrame:SetSize(30,30)
	CurseGraphicFrame:SetPoint("CENTER", LockyAssignCheckFrame, "LEFT", 105, 42)
	
	LockyAssignCheckFrame.CurseGraphicFrame = CurseGraphicFrame

	LockyAssignCheckFrame.BanishLabel = NL_AddTextToFrame(LockyAssignCheckFrame, "Banish:", 130)
	LockyAssignCheckFrame.BanishLabel:SetPoint("TOPLEFT", LockyAssignCheckFrame, "TOPLEFT", 0, -67)

	local BanishGraphicFrame = CreateFrame("Frame", nil, LockyAssignCheckFrame)
	BanishGraphicFrame:SetSize(30,30)
	BanishGraphicFrame:SetPoint("CENTER", LockyAssignCheckFrame, "LEFT", 105, 12)
	LockyAssignCheckFrame.BanishGraphicFrame = BanishGraphicFrame;

	LockyAssignCheckFrame.SoulStoneLabel = NL_AddTextToFrame(LockyAssignCheckFrame, "SoulStone:", 130)
	LockyAssignCheckFrame.SoulStoneLabel:SetPoint("TOPLEFT", LockyAssignCheckFrame, "TOPLEFT", -8, -97)

	LockyAssignCheckFrame.SoulStoneAssignment = NL_AddTextToFrame(LockyAssignCheckFrame, "", 130)
	LockyAssignCheckFrame.SoulStoneAssignment:SetPoint("TOPLEFT", LockyAssignCheckFrame, "TOPLEFT", 65, -97)

	LockyAssignCheckFrame.Prompt = NL_AddTextToFrame(LockyAssignCheckFrame, "Do you accept?", 130)
	LockyAssignCheckFrame.Prompt:SetPoint("TOPLEFT", LockyAssignCheckFrame, "TOPLEFT", 0, -120)
	
	
	LockyAssignCheckFrame:SetScript("OnShow", LockyAssignFrameOnShow);

	
	LockyAssignCheckFrame:Hide();

	
	--This needs to be removed.	
	--LockyAssignCheckFrame:Show();
end

function SetLockyCheckFrameAssignments(curse, banish, sstarget)
	if NL_DebugMode then
		print(curse,banish, sstarget);
	end
	UpdateCurseGraphic(LockyAssignCheckFrame, curse)
	LockyAssignCheckFrame.pendingCurse = curse;
	UpdateBanishGraphic(LockyAssignCheckFrame, banish)
	UpdateSoulStoneAssignment(sstarget)
	LockyAssignCheckFrame:Show();
end

function LockyAssignFrameOnShow()	
	PlaySound(SOUNDKIT.READY_CHECK)
	if NL_DebugMode then	
		print("Assignment ready check recieved. Assignment check frame should be showing now.");
	end	
end

function LockyAssignAcceptClick()
	PlaySound(SOUNDKIT.IG_MAINMENU_CLOSE);
	LockyAssignCheckFrame:Hide()
	
	if NL_DebugMode then
		print("You clicked Yes.")
	end
	LockyAssignCheckFrame.activeCurse = LockyAssignCheckFrame.pendingCurse;
	if NL_DebugMode then
		print("Attempting to create macro for curse: ".. LockyAssignCheckFrame.activeCurse);		
	end

	NL_SetupAssignmentMacro(LockyAssignCheckFrame.activeCurse);
	SendAssignmentAcknowledgement("true");
end

function LockyAssignRejectClick()
	PlaySound(SOUNDKIT.IG_MAINMENU_CLOSE);
	LockyAssignCheckFrame:Hide()
	if NL_DebugMode then
		print("You clicked No.")
	end
	SendAssignmentAcknowledgement("false");
end

function UpdateSoulStoneAssignment(Assignment)
	LockyAssignCheckFrame.SoulStoneAssignment:SetText(Assignment);
end

function UpdateAssignedCurseGraphic(CurseGraphicFrame, CurseListValue)

	if not (CurseListValue == nil) then
		if(CurseGraphicFrame.CurseTexture == nil) then
			local CurseGraphic = CurseGraphicFrame:CreateTexture(nil, "OVERLAY") 
			CurseGraphic:SetAllPoints()
			CurseGraphic:SetTexture(GetSpellTexture(GetSpellIdFromDropDownList(CurseListValue)))
			CurseGraphicFrame.CurseTexture = CurseGraphic
		else
			CurseGraphicFrame.CurseTexture:SetTexture(GetSpellTexture(GetSpellIdFromDropDownList(CurseListValue)))
		end		
	else 
		if (CurseGraphicFrame.CurseTexture == nil) then
			local CurseGraphic = CurseGraphicFrame:CreateTexture(nil, "OVERLAY") 
			CurseGraphic:SetAllPoints()
			CurseGraphic:SetTexture(1,0,0,0)
			CurseGraphicFrame.CurseTexture = CurseGraphic
		else
			CurseGraphicFrame.CurseTexture:SetTexture(1,0,0,0);	
		end
	end
end

function UpdateAssignedBanishGraphic(BanishGraphicFrame, BanishListValue)
	if NL_DebugMode then
		print("Updating Banish Graphic to "..BanishListValue..":"..GetAssetLocationFromRaidMarker(BanishListValue))
	end
	if not (BanishListValue == nil) then
		if(BanishGraphicFrame.BanishTexture == nil) then
			local BanishGraphic = BanishGraphicFrame:CreateTexture(nil, "OVERLAY") 
			BanishGraphic:SetAllPoints()
			BanishGraphic:SetTexture(GetAssetLocationFromRaidMarker(BanishListValue))
			BanishGraphicFrame.BanishTexture = BanishGraphic
		else
			BanishGraphicFrame.BanishTexture:SetTexture(GetAssetLocationFromRaidMarker(BanishListValue))	
		end		
	else 
		if (BanishGraphicFrame.BanishTexture == nil) then
			local BanishGraphic = BanishGraphicFrame:CreateTexture(nil, "OVERLAY") 
			BanishGraphic:SetAllPoints()
			BanishGraphic:SetColorTexture(0,0,0,0)
			BanishGraphicFrame.BanishTexture = BanishGraphic
		else
			BanishGraphicFrame.BanishTexture:SetColorTexture(0,0,0,0)
		end
	end
end

function UpdateAssignedSoulstoneGraphic(SoulstoneGraphicFrame, SoulstoneTargetFrame, SoulstoneTarget)
	if NL_DebugMode then
		print("Updating Soulstone")
	end
	if not (SoulstoneTarget == nil) then
		if(SoulstoneGraphicFrame.SoulstoneTexture == nil) then
			local SoulstoneGraphic = SoulstoneGraphicFrame:CreateTexture(nil, "OVERLAY") 
			SoulstoneGraphic:SetAllPoints()
			SoulstoneGraphic:SetTexture(GetItemIcon(16896))
			SoulstoneGraphicFrame.SoulstoneTexture = SoulstoneGraphic
		else
			SoulstoneGraphicFrame.SoulstoneTexture:SetTexture(GetItemIcon(16896))
		end
		UpdateAssignedSoulstoneTarget(SoulstoneTargetFrame, SoulstoneTarget)
	else 
		if(SoulstoneGraphicFrame.SoulstoneTexture == nil) then
			local SoulstoneGraphic = SoulstoneGraphicFrame:CreateTexture(nil, "OVERLAY") 
			SoulstoneGraphic:SetAllPoints()
			SoulstoneGraphic:SetTexture(GetItemIcon(16896))
			SoulstoneGraphicFrame.SoulstoneTexture = SoulstoneGraphic
		else
			SoulstoneGraphicFrame.SoulstoneTexture:SetTexture(GetItemIcon(16896))
		end
		UpdateAssignedSoulstoneTarget(SoulstoneTargetFrame, "Noone.")
	end
end

function UpdateAssignedSoulstoneTarget(SoulstoneTargetFrame, SoulstoneTarget)
	if NL_DebugMode then
		print("Updating Soulstone target to "..SoulstoneTarget)
	end
	SoulstoneTargetFrame.text:SetText(SoulstoneTarget);
end

function UpdateAssignedSoulstoneCooldown(SoulstoneCooldownFrame, lockData)
	if NL_DebugMode then
		-- print("Updating Soulstone CD to "..SoulstoneCooldown)
	end
	
	local CDLength = 30*60
	local timeShift = 0
	
	timeShift = lockData.MyTime - lockData.LocalTime;
	
	local absCD = lockData.SSCooldown+timeShift;

	

	local secondsRemaining = math.floor(absCD + CDLength - GetTime())
	local result = SecondsToTime(secondsRemaining)		
	
	
	SoulstoneCooldownFrame.text:SetText(result);
	if secondsRemaining <=0 or lockData.SSCooldown == 0 then
		lockData.SSonCD = "false"
		SoulstoneCooldownFrame.text:SetText("Available")
	end	
end

function InitMonitorFrame()
	--LockyPersonalAnchorButton = CreateFrame("Button", nil, UIParent)
	--LockyPersonalAnchorButton:SetSize(30,30)
	--LockyPersonalAnchorButton:SetPoint("CENTER", UIParent, "CENTER")

	LockyMonitorFrame = CreateFrame("Frame", nil, UIParent);
	LockyMonitorFrame:SetSize(100, 34) 
	LockyMonitorFrame:SetPoint("TOP", UIParent, "TOP",0,-75) 

	-- background setting for the whole frame
	LockyMonitorFrame:SetBackdrop({
	 	bgFile= "Interface\\DialogFrame\\UI-DialogBox-Background",
	 	edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border", 
	 	tile = true,
	 	tileSize = 32,
	 	edgeSize = 24,
	 	insets = { left = 0, right = 0, top = 0, bottom = 0 }
	 });

	-- mouse drag handling
	LockyMonitorFrame:RegisterForDrag("LeftButton");
	LockyMonitorFrame:SetMovable(true);
	LockyMonitorFrame:EnableMouse(true);

	LockyMonitorFrame:SetScript("OnDragStart", LockyMonitorFrame.StartMoving);
	LockyMonitorFrame:SetScript("OnDragStop", LockyMonitorFrame.StopMovingOrSizing);

	-- provide a button for manual update
	updateButton = CreateFrame("Button", "UpdateButton", LockyMonitorFrame, "UIPanelButtonTemplate", 0)
	updateButton:SetSize(32,32)
	updateButton:SetPoint("TOP", LockyMonitorFrame, "TOPLEFT", 0, 32)
	--updateButton:SetBackdrop({
	 	--bgFile= "Interface\\DialogFrame\\UI-DialogBox-Background",
	 	--edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border", 
	 	--tile = true,
	 	--tileSize = 32,
	 	--edgeSize = 24,
	 	--insets = { left = 0, right = 0, top = 0, bottom = 0 }
	 --});
	 updateButton:SetText("U")
	 updateButton:SetScript("OnClick", function(self) UpdateMonitorFrame() end)
	 
	-- provide a button to hide the panel
	hideButton = CreateFrame("Button", "UpdateButton", LockyMonitorFrame, "UIPanelButtonTemplate", 0)
	hideButton:SetSize(32,32)
	hideButton:SetPoint("TOP", LockyMonitorFrame, "TOPRIGHT", 0, 32)
	--updateButton:SetBackdrop({
	 	--bgFile= "Interface\\DialogFrame\\UI-DialogBox-Background",
	 	--edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border", 
	 	--tile = true,
	 	--tileSize = 32,
	 	--edgeSize = 24,
	 	--insets = { left = 0, right = 0, top = 0, bottom = 0 }
	 --});
	 hideButton:SetText("H")
	 hideButton:SetScript("OnClick", function(self) LockyMonitorFrame:Hide() end)	 
	 

--     local LockyAnchorFrame = LockyMonitorFrame;
--     
--     for i=0, 4 do
--         LockyAnchorFrame.CurseGraphicFrame = CreateFrame("Frame", "CurseGraphicFrame_"..i, LockyAnchorFrame)
--         LockyAnchorFrame.CurseGraphicFrame:SetSize(30,30)
--         LockyAnchorFrame.CurseGraphicFrame:SetPoint("TOP", LockyAnchorFrame, "TOPLEFT", 26, (-65*i)-30)
-- 
--         LockyAnchorFrame.BanishGraphicFrame = CreateFrame("Frame", "BanishGraphicFrame_"..i, LockyAnchorFrame)
--         LockyAnchorFrame.BanishGraphicFrame:SetSize(30,30)
--         LockyAnchorFrame.BanishGraphicFrame:SetPoint("LEFT", LockyAnchorFrame.CurseGraphicFrame, "RIGHT", 5, 0)
--         
--         LockyAnchorFrame.SoulstoneGraphicFrame = CreateFrame("Frame", "SoulstoneGraphicFrame_"..i, LockyAnchorFrame)
--         LockyAnchorFrame.SoulstoneGraphicFrame:SetSize(30,30)
--         LockyAnchorFrame.SoulstoneGraphicFrame:SetPoint("LEFT", LockyAnchorFrame.BanishGraphicFrame, "RIGHT", 35, 0)
--         
--         LockyAnchorFrame.SoulstoneCooldownFrame = CreateFrame("Frame", "SoulstoneCooldownFrame_"..i, LockyAnchorFrame)
--         LockyAnchorFrame.SoulstoneCooldownFrame:SetSize(30,30)
--         LockyAnchorFrame.SoulstoneCooldownFrame:SetPoint("CENTER", LockyAnchorFrame.SoulstoneGraphicFrame, "LEFT", 10, 0)
--         
--         LockyAnchorFrame.SoulstoneCooldownFrame.text = LockyAnchorFrame.SoulstoneCooldownFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal") 
--         LockyAnchorFrame.SoulstoneCooldownFrame.text:SetPoint("CENTER", LockyAnchorFrame.SoulstoneCooldownFrame,"TOP", 2, -35)
--         LockyAnchorFrame.SoulstoneCooldownFrame.text:SetText("Unknown.")
-- 
--         LockyAnchorFrame.SoulstoneTargetFrame = CreateFrame("Frame", "SoulstoneTargetFrame_"..i, LockyAnchorFrame)
--         LockyAnchorFrame.SoulstoneTargetFrame:SetSize(30,30)
--         LockyAnchorFrame.SoulstoneTargetFrame:SetPoint("CENTER", LockyAnchorFrame.SoulstoneGraphicFrame, "LEFT", 5, 0) 
--         
--         LockyAnchorFrame.SoulstoneTargetFrame.text = LockyAnchorFrame.SoulstoneTargetFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
--         LockyAnchorFrame.SoulstoneTargetFrame.text:SetPoint("CENTER", LockyAnchorFrame.SoulstoneTargetFrame,"TOP", 2, 10)
--         LockyAnchorFrame.SoulstoneTargetFrame.text:SetText("Noone.")        
--         
--         LockyAnchorFrame.TextAnchorFrame = CreateFrame("Frame", "TextAnchorFrame_"..i, LockyAnchorFrame)
--         LockyAnchorFrame.TextAnchorFrame:SetSize(5,30)
--         LockyAnchorFrame.TextAnchorFrame:SetPoint("LEFT", LockyAnchorFrame.SoulstoneGraphicFrame, "RIGHT", 2, 0)
--         
--         LockyAnchorFrame.TextAnchorFrame.text = LockyAnchorFrame.TextAnchorFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
--         LockyAnchorFrame.TextAnchorFrame.text:SetFont("Fonts\\FRIZQT__.TTF", 16);
--         LockyAnchorFrame.TextAnchorFrame.text:SetPoint("LEFT", LockyAnchorFrame.TextAnchorFrame,"RIGHT", 10, 0)
--         LockyAnchorFrame.TextAnchorFrame.text:SetText("No Locks in raid.")
--         
--         print(LockyAnchorFrame.TextAnchorFrame:GetName());
-- 
--         -- LockyAnchorFrame = LockyAnchorFrame.CurseGraphicFrame;
--         
-- 	end
	
	if NL_DebugMode then
		local children = {LockyMonitorFrame:GetChildren() }
		for i, child in ipairs(children) do
			print("   "..child:GetName());
		end
	end
    
	LockyMonitorFrame:SetSize(300, 350)     
    
    
    -- LockyMonitorFrame.TextAnchorFrame_0.NamePlate:SetText("Ima no dummy.");
    
--     LockyMonitorFrame.TextAnchorFrame.text:SetText("Ima no dummy.")
    
--     -- dummy data
--     for num=0, 4 do    
--         --_G["TextAnchorFrame_"..i].text:SetText("#"..i.." All work and no play ...")
--  		_G["TextAnchorFrame_"..num].text:SetText("#"..num.." Warlock_"..num)
-- 		UpdateAssignedCurseGraphic(_G["CurseGraphicFrame_"..num], "Doom LOL")
-- 		UpdateAssignedBanishGraphic(_G["BanishGraphicFrame_"..num], "Skull")
-- 		UpdateAssignedSoulstoneGraphic(_G["SoulstoneGraphicFrame_"..num], _G["SoulstoneTargetFrame_"..num], "Noone")
--     end
    

	LockyMonitorFrame.MainLabel = NL_AddTextToFrame(LockyMonitorFrame,"Global Lock Assigns:", 175);
	LockyMonitorFrame.MainLabel:SetPoint("BOTTOM", LockyMonitorFrame, "TOP", 0, 0);

	--LockyMonitorFrame:Hide();
    
    -- LockyMonitorFrame.SSAssignmentText:SetText("Ima no dummy.");
    -- TextAnchorFrame_2:SetText("Ima no dummy.");
    
    --_G["TextAnchorFrame_0"..2].SSAssignmentText:SetText("Ima no dummy.");
	
	--UpdateCurseGraphic(LockyMonitorFrame, "Agony")
	--print("Personal Monitor loaded.")
	--print(LockyMonitorFrame.CurseGraphicFrame.CurseTexture)
	
	UpdateMonitorFrame()
	
	LockyMonitorFrame:SetScript("OnUpdate", LockyMonitorFrame_OnUpdate)
    
end

-- The minimum number of seconds between each update
local LockyMonitorFrame_OnUpdate_Interval = 2	

-- The number of seconds since the last update
local LockyMonitorFrame_TimeSinceLastUpdate = 0

function LockyMonitorFrame_OnUpdate(self, elapsed)
	LockyMonitorFrame_TimeSinceLastUpdate = LockyMonitorFrame_TimeSinceLastUpdate + elapsed
	if LockyMonitorFrame_TimeSinceLastUpdate >= LockyMonitorFrame_OnUpdate_Interval then
		LockyMonitorFrame_TimeSinceLastUpdate = 0
		if NL_DebugMode then		
			print("LockyMonitorFrame_OnUpdate")
		end
		UpdateMonitorFrame()
	end
end

function UpdateMonitorFrame()

	if NL_DebugMode then
		print("Updating monitor frame.")
	end

    if not (LockyData_HasInitialized) then
        LockyFriendsData = InitLockyFriendData()
        --LockyData_Timestamp = 0
        LockyData_HasInitialized = true
        if NL_DebugMode then
            print("Initialization complete");
        end		
        print("Found " .. GetTableLength(LockyFriendsData) .. " Warlocks in raid." );
	end
        
	local num = 0;
	for key, value in pairs(LockyFriendsData) do
		if NL_DebugMode then
			print ("#"..num..":"..value.Name.." C:"..value.CurseAssignment.." B:"..value.BanishAssignment)
		end
        if (_G["CurseGraphicFrame_"..num] == nil) then
            AddMonitorFrameItem(num)
        end
		_G["TextAnchorFrame_"..num].text:SetText("#"..num.." "..value.Name)
		UpdateAssignedCurseGraphic(_G["CurseGraphicFrame_"..num], value.CurseAssignment)
		UpdateAssignedBanishGraphic(_G["BanishGraphicFrame_"..num], value.BanishAssignment)
		UpdateAssignedSoulstoneGraphic(_G["SoulstoneGraphicFrame_"..num], _G["SoulstoneTargetFrame_"..num], value.SSAssignment)
		UpdateAssignedSoulstoneCooldown(_G["SoulstoneCooldownFrame_"..num], value);
		num = num + 1
	end

end

function AddMonitorFrameItem(i)
    
        LockyMonitorFrame.CurseGraphicFrame = CreateFrame("Frame", "CurseGraphicFrame_"..i, LockyMonitorFrame)
        LockyMonitorFrame.CurseGraphicFrame:SetSize(30,30)
        LockyMonitorFrame.CurseGraphicFrame:SetPoint("TOP", LockyMonitorFrame, "TOPLEFT", 26, (-65*i)-30)

        LockyMonitorFrame.BanishGraphicFrame = CreateFrame("Frame", "BanishGraphicFrame_"..i, LockyMonitorFrame)
        LockyMonitorFrame.BanishGraphicFrame:SetSize(30,30)
        LockyMonitorFrame.BanishGraphicFrame:SetPoint("LEFT", LockyMonitorFrame.CurseGraphicFrame, "RIGHT", 5, 0)
        
        LockyMonitorFrame.SoulstoneGraphicFrame = CreateFrame("Frame", "SoulstoneGraphicFrame_"..i, LockyMonitorFrame)
        LockyMonitorFrame.SoulstoneGraphicFrame:SetSize(30,30)
        LockyMonitorFrame.SoulstoneGraphicFrame:SetPoint("LEFT", LockyMonitorFrame.BanishGraphicFrame, "RIGHT", 35, 0)
        
        LockyMonitorFrame.SoulstoneCooldownFrame = CreateFrame("Frame", "SoulstoneCooldownFrame_"..i, LockyMonitorFrame)
        LockyMonitorFrame.SoulstoneCooldownFrame:SetSize(30,30)
        LockyMonitorFrame.SoulstoneCooldownFrame:SetPoint("CENTER", LockyMonitorFrame.SoulstoneGraphicFrame, "LEFT", 10, 0)
        
        LockyMonitorFrame.SoulstoneCooldownFrame.text = LockyMonitorFrame.SoulstoneCooldownFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal") 
        LockyMonitorFrame.SoulstoneCooldownFrame.text:SetPoint("CENTER", LockyMonitorFrame.SoulstoneCooldownFrame,"TOP", 2, -35)
        LockyMonitorFrame.SoulstoneCooldownFrame.text:SetText("Unknown.")

        LockyMonitorFrame.SoulstoneTargetFrame = CreateFrame("Frame", "SoulstoneTargetFrame_"..i, LockyMonitorFrame)
        LockyMonitorFrame.SoulstoneTargetFrame:SetSize(30,30)
        LockyMonitorFrame.SoulstoneTargetFrame:SetPoint("CENTER", LockyMonitorFrame.SoulstoneGraphicFrame, "LEFT", 5, 0) 
        
        LockyMonitorFrame.SoulstoneTargetFrame.text = LockyMonitorFrame.SoulstoneTargetFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        LockyMonitorFrame.SoulstoneTargetFrame.text:SetPoint("CENTER", LockyMonitorFrame.SoulstoneTargetFrame,"TOP", 2, 10)
        LockyMonitorFrame.SoulstoneTargetFrame.text:SetText("Noone.")        
        
        LockyMonitorFrame.TextAnchorFrame = CreateFrame("Frame", "TextAnchorFrame_"..i, LockyMonitorFrame)
        LockyMonitorFrame.TextAnchorFrame:SetSize(5,30)
        LockyMonitorFrame.TextAnchorFrame:SetPoint("LEFT", LockyMonitorFrame.SoulstoneGraphicFrame, "RIGHT", 2, 0)
        
        LockyMonitorFrame.TextAnchorFrame.text = LockyMonitorFrame.TextAnchorFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        LockyMonitorFrame.TextAnchorFrame.text:SetFont("Fonts\\FRIZQT__.TTF", 16);
        LockyMonitorFrame.TextAnchorFrame.text:SetPoint("LEFT", LockyMonitorFrame.TextAnchorFrame,"RIGHT", 10, 0)
        LockyMonitorFrame.TextAnchorFrame.text:SetText("No Locks in raid.")
    
end

function InitPersonalMonitorFrame()
	--LockyPersonalAnchorButton = CreateFrame("Button", nil, UIParent)
	--LockyPersonalAnchorButton:SetSize(30,30)
	--LockyPersonalAnchorButton:SetPoint("CENTER", UIParent, "CENTER")


	LockyPersonalMonitorFrame = CreateFrame("Frame", nil, UIParent);

	LockyPersonalMonitorFrame:SetSize(66, 34) 
	LockyPersonalMonitorFrame:SetPoint("TOP", UIParent, "TOP",0,-25) 

	--LockyPersonalMonitorFrame:SetBackdrop({
	-- 	bgFile= "Interface\\DialogFrame\\UI-DialogBox-Background",
	-- 	edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border", 
	-- 	tile = true,
	-- 	tileSize = 32,
	-- 	edgeSize = 12,
	-- 	insets = { left = 0, right = 0, top = 0, bottom = 0 }
	-- });

	LockyPersonalMonitorFrame:RegisterForDrag("LeftButton");
	LockyPersonalMonitorFrame:SetMovable(true);
	LockyPersonalMonitorFrame:EnableMouse(true);

	LockyPersonalMonitorFrame:SetScript("OnDragStart", LockyPersonalMonitorFrame.StartMoving);
	LockyPersonalMonitorFrame:SetScript("OnDragStop", LockyPersonalMonitorFrame.StopMovingOrSizing);

	LockyPersonalMonitorFrame.CurseGraphicFrame = CreateFrame("Frame", nil, LockyPersonalMonitorFrame)
	LockyPersonalMonitorFrame.CurseGraphicFrame:SetSize(30,30)
	LockyPersonalMonitorFrame.CurseGraphicFrame:SetPoint("LEFT", LockyPersonalMonitorFrame, "LEFT", 2, 0)

	LockyPersonalMonitorFrame.BanishGraphicFrame = CreateFrame("Frame", nil, LockyPersonalMonitorFrame)
	LockyPersonalMonitorFrame.BanishGraphicFrame:SetSize(30,30)
	LockyPersonalMonitorFrame.BanishGraphicFrame:SetPoint("LEFT", LockyPersonalMonitorFrame.CurseGraphicFrame, "RIGHT", 2, 0)

	LockyPersonalMonitorFrame.SSAssignmentText = NL_AddTextToFrame(LockyPersonalMonitorFrame, "", 75);
	LockyPersonalMonitorFrame.SSAssignmentText:SetPoint("LEFT", LockyPersonalMonitorFrame.BanishGraphicFrame,"RIGHT", 5, 0)
	LockyPersonalMonitorFrame.SSAssignmentText:SetJustifyH("LEFT")

	LockyPersonalMonitorFrame.MainLabel = NL_AddTextToFrame(LockyPersonalMonitorFrame,"Lock Assigns:", 125);
	LockyPersonalMonitorFrame.MainLabel:SetPoint("BOTTOM", LockyPersonalMonitorFrame, "TOP");

	LockyPersonalMonitorFrame:Hide();
	--UpdateCurseGraphic(LockyPersonalMonitorFrame, "Agony")
	print("Personal Monitor loaded.")
	--print(LockyPersonalMonitorFrame.CurseGraphicFrame.CurseTexture)
end

function UpdatePersonalSSAssignment(ParentFrame, SSAssignment)
	if SSAssignment ~= "None" then
		ParentFrame.SSAssignmentText:SetText(SSAssignment);
		else
			ParentFrame.SSAssignmentText:SetText("");
	end
end

function UpdatePersonalMonitorFrame()
	local myData = GetMyLockyData()
	UpdateBanishGraphic(LockyPersonalMonitorFrame, myData.BanishAssignment);
	UpdateCurseGraphic(LockyPersonalMonitorFrame, myData.CurseAssignment);
	UpdatePersonalSSAssignment(LockyPersonalMonitorFrame, myData.SSAssignment);

	--Need to resize the frame accordingly.
	UpdatePersonalMonitorSize(myData);

	--Need to shift stuff around since this display is wrong.
	--if myData.CurseAssignment ~= "None" and myData.BanishAssignment ~= "None" then
	--This just resets to default locations.
		LockyPersonalMonitorFrame.CurseGraphicFrame:SetPoint("LEFT", LockyPersonalMonitorFrame, "LEFT", 2, 0)
		LockyPersonalMonitorFrame.BanishGraphicFrame:SetPoint("LEFT", LockyPersonalMonitorFrame.CurseGraphicFrame, "RIGHT", 2, 0)
		LockyPersonalMonitorFrame.SSAssignmentText:SetPoint("LEFT", LockyPersonalMonitorFrame.BanishGraphicFrame,"RIGHT", 5, 0)
	--end
	if myData.CurseAssignment == "None" and myData.BanishAssignment ~= "None" then
		-- We shift stuff left.
		LockyPersonalMonitorFrame.BanishGraphicFrame:SetPoint("LEFT", LockyPersonalMonitorFrame, "LEFT", 2, 0)
		LockyPersonalMonitorFrame.SSAssignmentText:SetPoint("LEFT", LockyPersonalMonitorFrame.BanishGraphicFrame,"RIGHT", 5, 0)
	end
	if myData.BanishAssignment == "None" and myData.CurseAssignment ~= "None" then
		--we only need to shift the SSAssignmentText to be next to the curse graphic.
		LockyPersonalMonitorFrame.SSAssignmentText:SetPoint("LEFT", LockyPersonalMonitorFrame.CurseGraphicFrame,"RIGHT", 5, 0)
	end
	if myData.CurseAssignment == "None" and myData.BanishAssignment == "None" then
		-- we can make the SSAssignmentText shif all the way left.
		LockyPersonalMonitorFrame.SSAssignmentText:SetPoint("LEFT", LockyPersonalMonitorFrame, "LEFT", 2, 0)
	end

	
end

function UpdatePersonalMonitorSize(myData)
	local picframesize = 34
	local buffcount = 0;
	if myData.CurseAssignment ~= "None" then
		buffcount = buffcount+1;
	end
	if myData.BanishAssignment ~= "None" then
		buffcount = buffcount+1;
	end
	local textLength = 0
	if myData.SSAssignment ~="None" then
		textLength = 75;
	end
	LockyPersonalMonitorFrame:SetSize((picframesize*buffcount)+textLength, 34)

	
end

function InitAnnouncerOptionFrame()
	LockyAnnouncerOptionMenu = NL_CreateDropDownMenu(NLAnnouncerContainer, AnnouncerOptions, "CHAT")
	LockyAnnouncerOptionMenu:SetPoint("CENTER", NLAnnouncerContainer, "CENTER", 0,0);
end
