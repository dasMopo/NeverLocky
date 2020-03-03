
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
	
	--print(GetTableLength(content.LockyFriendFrames))
	--print(GetMaxValueForScrollBar(content.LockyFriendFrames))

	scrollframe:SetScrollChild(content)

	--UpdateAllLockyFriendFrames()
	NeverLockyFrame.WarningTextFrame = CreateFrame("Frame", nil, NeverLockyFrame);
	NeverLockyFrame.WarningTextFrame:SetSize(250, 30);
	NeverLockyFrame.WarningTextFrame:SetPoint("BOTTOMLEFT", NeverLockyFrame, "BOTTOMLEFT", 0, 0)
	
	NeverLockyFrame.WarningTextFrame.value = AddTextToFrame(NeverLockyFrame.WarningTextFrame, "Warning your addon is out of date!", 240)
	NeverLockyFrame.WarningTextFrame.value:SetPoint("LEFT", NeverLockyFrame.WarningTextFrame, "LEFT", 0, 0);
	NeverLockyFrame.WarningTextFrame:Hide();
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
	
	LockyFrame.AssignmentAcknowledgement = CreateAckFrame(LockyFrame);

	LockyFrame.Warning = CreateWarningFrame(LockyFrame);

    return LockyFrame
end

--Creates a textframe to display the SS cooldown.
function CreateSSCooldownTracker(ParentFrame)
    local TextFrame = AddTextToFrame(ParentFrame, "Available", 120)
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
	local Label = AddTextToFrame(ParentFrame, "Curse Assignment", 150)
	Label:SetPoint("BOTTOMLEFT", ParentFrame, "TOPLEFT", 0, 0)
	return Label
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

function CreateAckFrame(ParentFrame)
	local AckFrame = CreateFrame("Frame", nil, ParentFrame)
	AckFrame:SetSize(150,30)
	AckFrame:SetPoint("CENTER", ParentFrame, "CENTER",80,-25)

	AckFrame.label = AddTextToFrame(AckFrame, "Accepted:", 150)
	AckFrame.label:SetPoint("LEFT", AckFrame, "LEFT", 0, 0)

	AckFrame.value = AddTextToFrame(AckFrame, "Not Recieved", 120)
	AckFrame.value:SetPoint("LEFT", AckFrame, "LEFT", 85, 0)
	return AckFrame;
end

function CreateWarningFrame(ParentFrame)
	local NoteFrame = CreateFrame("Frame", nil, ParentFrame)
	NoteFrame:SetSize(150, 30)
	NoteFrame:SetPoint("BOTTOMLEFT", ParentFrame, "BOTTOMLEFT",0,0)
	NoteFrame.value = AddTextToFrame(NoteFrame, "Warning: Addon out of date", 250)
	NoteFrame.value:SetPoint("LEFT", NoteFrame, "LEFT", 0, 0)
	NoteFrame:Hide();
	return NoteFrame;
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

	LockyAssignCheckFrame.Label = AddTextToFrame(LockyAssignCheckFrame, "Your new assignments:", 140)
	LockyAssignCheckFrame.Label:SetPoint("TOPLEFT", LockyAssignCheckFrame, "TOPLEFT", 10, -15)

	LockyAssignCheckFrame.CurseLabel = AddTextToFrame(LockyAssignCheckFrame, "Curse:", 130)
	LockyAssignCheckFrame.CurseLabel:SetPoint("TOPLEFT", LockyAssignCheckFrame, "TOPLEFT", 0, -37)


	local CurseGraphicFrame = CreateFrame("Frame", nil, LockyAssignCheckFrame)
	CurseGraphicFrame:SetSize(30,30)
	CurseGraphicFrame:SetPoint("CENTER", LockyAssignCheckFrame, "LEFT", 105, 42)
	
	LockyAssignCheckFrame.CurseGraphicFrame = CurseGraphicFrame

	LockyAssignCheckFrame.BanishLabel = AddTextToFrame(LockyAssignCheckFrame, "Banish:", 130)
	LockyAssignCheckFrame.BanishLabel:SetPoint("TOPLEFT", LockyAssignCheckFrame, "TOPLEFT", 0, -67)

	local BanishGraphicFrame = CreateFrame("Frame", nil, LockyAssignCheckFrame)
	BanishGraphicFrame:SetSize(30,30)
	BanishGraphicFrame:SetPoint("CENTER", LockyAssignCheckFrame, "LEFT", 105, 12)
	LockyAssignCheckFrame.BanishGraphicFrame = BanishGraphicFrame;

	LockyAssignCheckFrame.SoulStoneLabel = AddTextToFrame(LockyAssignCheckFrame, "SoulStone:", 130)
	LockyAssignCheckFrame.SoulStoneLabel:SetPoint("TOPLEFT", LockyAssignCheckFrame, "TOPLEFT", -8, -97)

	LockyAssignCheckFrame.SoulStoneAssignment = AddTextToFrame(LockyAssignCheckFrame, "", 130)
	LockyAssignCheckFrame.SoulStoneAssignment:SetPoint("TOPLEFT", LockyAssignCheckFrame, "TOPLEFT", 65, -97)

	LockyAssignCheckFrame.Prompt = AddTextToFrame(LockyAssignCheckFrame, "Do you accept?", 130)
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
	--print("Updating Curse Graphic to " .. CurseListValue)
	if not (CurseListValue == nil) then
		if(CurseGraphicFrame.CurseTexture == nil) then
			local CurseGraphic = CurseGraphicFrame:CreateTexture(nil, "OVERLAY") 
			CurseGraphic:SetAllPoints()
			CurseGraphic:SetTexture(GetSpellTexture(11713))
			CurseGraphicFrame.CurseTexture = CurseGraphic
		else
			CurseGraphicFrame.CurseTexture:SetTexture(GetSpellTexture(11713))		
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