
raidMode = false;

function main()
	print("Never Locky has been registered to the WOW UI.")
	SlashCmdList["DEMO"]("1")
	NeverLockyFrame:Show()	
end

function registerRaid()
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

function registerWarlocks()
	for i=1, 40 do
		local name, rank, subgroup, level, class, fileName, 
		  zone, online, isDead, role, isML = GetRaidRosterInfo(i);
		if not (name == nil) then
			if fileName == "WARLOCK" then
				print(name .. "-" .. fileName)
			end
		end		
	end
end

function HideFrame()
	print("Hiding NeverLockyFrame.")
	NeverLockyFrame:Hide()
end

function OnShow()
	print("Frame should be showing now.")	
	--ok, on show we should register all of the warlocks in the raid using a loop.
	
	-- We should also 
	
	
end


function buildLockyFriendsUI(name, UIParent)
	--Build a frame using CreateFrame("Frame Type as string", "Frame Name as string", UIParent as object)
	local new_LockyFriend = CreateFrame("Frame", "LockyFriend_"..name , UIParent)
	new_LockyFriend:SetSize(400,135)
	
	
end


function Slider_OnValueChanged(self, value, userInput)
	print("Slider value changed")
	print(value)
end

function Slider_Load(self)
	print("slider loaded")	
	print(self)
end

function ScrollBarDown_OnClick()	
	Scroll(1)
end

function ScrollBarUp_OnClick()	
	Scroll(-1)
end

function Scroll(increment)
	local currentIndex = LockyFriends_ScrollBar_Slider:GetValue()
	local minValue, maxValue = LockyFriends_ScrollBar_Slider:GetMinMaxValues()
	
	if (currentIndex+increment > maxValue) then
		LockyFriends_ScrollBar_Slider:SetValue(maxValue)
	elseif currentIndex+increment < minValue then
		LockyFriends_ScrollBar_Slider:SetValue(minValue)
	else
		LockyFriends_ScrollBar_Slider:SetValue(currentIndex+increment)
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

SLASH_DEMO1 = "/demo"
SlashCmdList["DEMO"]= function(msg)
	--parent frame 
	--print("running demo")
	local frame = CreateFrame("Frame", nil, NeverLockyFrame) 
	frame:SetSize(385, 500) 
	frame:SetPoint("CENTER", NeverLockyFrame, "CENTER", -9, 6) 
		
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
	scrollframe = CreateFrame("ScrollFrame", "LockyFriendsScroller_ScrollFrame", frame) 
	scrollframe:SetPoint("TOPLEFT", 2, -2) 
	scrollframe:SetPoint("BOTTOMRIGHT", -2, 2) 
	
	frame.scrollframe = scrollframe 
	--print("Created a Scroll Frame")
	--scrollbar 
	scrollbar = CreateFrame("Slider", nil, scrollframe, "UIPanelScrollBarTemplate") 
	scrollbar:SetPoint("TOPLEFT", frame, "TOPRIGHT", 4, -16) 
	scrollbar:SetPoint("BOTTOMLEFT", frame, "BOTTOMRIGHT", 4, 16) 
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
	frame.scrollbar = scrollbar 
	--print("Created a Scroll Bar")
	
	--content frame 	
	local content = CreateFrame("Frame", nil, scrollframe) 
	content:SetSize(360, 500) 
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
	
	content.LockyFrames = {}
	
	if(raidMode) then
		local RaidyFriends = registerRaid();
		--print(RaidyFriends)
	
	for k, v in pairs(RaidyFriends) do 
		print(k, v) 
		table.insert(content.LockyFrames, GetLockyFriendFrame(v, k-1, content))
	end
	
	else
	
	
	for i=0, 5 do
		table.insert(content.LockyFrames, GetLockyFriendFrame("Brylack", i, content))
	end
	end
	
	
	scrollframe.content = content 
	
	scrollbar:SetMinMaxValues(1, 290)
	
	scrollframe:SetScrollChild(content)
end



--[[
		A dropdown list of curses to assign.
		
		A dropdown list of names for SoulStones... or maybe a text box for the name... 
		
		A timer to keep track of SS targets.
		
		A timer to keep track of SS CDs.
		
		A drop down list of raid markers for banish assignments.	
	]]--
function GetLockyFriendFrame(LockyName, number, scrollframe)	
	--Draws the Locky Friend Component Frame, adds the border, and positions it relative to the number of frames created.
	local LockyFrame = CreateLockyFriendFrame(scrollframe, number)
	
	--Creates a portrait to assist in identifying units.
	LockyFrame.Portrait = CreateLockyFriendPortrait(LockyFrame, LockyName) 
	
	-- Draws the name in the frame.
	LockyFrame.NamePlate = CreateNamePlate(LockyFrame, LockyName)
	
	--Draws the curse dropdown.
	LockyFrame.CurseAssignmentMenu = CreateCurseAssignmentMenu(LockyFrame)
	--Sets a default based on the raid location.
	if(number < 3) then
		UIDropDownMenu_SetSelectedID(LockyFrame.CurseAssignmentMenu, number+2)
	end
	--Draw a BanishAssignment DropDownMenu
	LockyFrame.BanishAssignment = CreateBanishAssignmentMenu(LockyFrame)
	if(number < 6) then
		UIDropDownMenu_SetSelectedID(LockyFrame.BanishAssignment, number+2)
	end
	
	print(LockyName .. " has been assigned " .. GetCurseValueFromDropDownList(LockyFrame.CurseAssignmentMenu))
	UpdateCurseGraphic(LockyFrame.CurseAssignmentMenu, GetCurseValueFromDropDownList(LockyFrame.CurseAssignmentMenu))
	
	return LockyFrame
end

function CreateLockyFriendFrame(ParentFrame, number)
	local LockyFriendFrame = CreateFrame("Frame", nil, ParentFrame) 
	LockyFriendFrame:SetSize(370, 128) 
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

function CreateLockyFriendPortrait(ParentFrame, UnitName)
	local portrait = CreateFrame("Frame", nil, ParentFrame) 
		portrait:SetSize(80,80)
		portrait:SetPoint("LEFT", 13, -5)
	local texture = portrait:CreateTexture(nil, "BACKGROUND") 
	texture:SetAllPoints() 
	--texture:SetTexture("Interface\\GLUES\\MainMenu\\Glues-BlizzardLogo") 
	SetPortraitTexture(texture, UnitName)
	portrait.texture = texture 
	
	return portrait
end

function CreateBanishAssignmentMenu(ParentFrame)
	local items = {
		"None",
	    "Diamond",
		"Star",
		"Triangle",
		"Circle",
		"Square",
		"Moon"
	}
	
	local BanishAssignmentMenu = CreateDropDownMenu(ParentFrame, items)
	BanishAssignmentMenu:SetPoint("CENTER", -25, -30)	
	BanishAssignmentMenu.Label = CreateBanishAssignmentLabel(BanishAssignmentMenu)
	
	return BanishAssignmentMenu
end

function CreateBanishAssignmentLabel(ParentFrame)
	local Label = AddTextToFrame(ParentFrame, "Banish Assignment", 150)
	Label:SetPoint("BOTTOMLEFT", ParentFrame, "TOPLEFT", 0, 0)
	return Label
end

function CreateNamePlate(ParentFrame, Text)
	local TextFrame = AddTextToFrame(ParentFrame, Text, 90)
	TextFrame:SetPoint("TOPLEFT", 0,-15)
	return TextFrame
end


function AddTextToFrame(ParentFrame, Text, Width)
	local NamePlate = ParentFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
		NamePlate:SetText(Text)
		NamePlate:SetWidth(Width)
		NamePlate:SetJustifyH("CENTER")
		NamePlate:SetJustifyV("CENTER")
		NamePlate:SetTextColor(1,1,1,1)
	return NamePlate
end


CurseOptions = {
	"None",
   "Elements",
   "Shadows",
   "Recklessness",
   "Tongues",
   "Doom LOL",
   "Agony"
}



function CreateCurseAssignmentMenu(ParentFrame)	
		
	local CurseAssignmentMenu = CreateDropDownMenu(ParentFrame, CurseOptions)
	CurseAssignmentMenu:SetPoint("CENTER", -25, 20)	
	CurseAssignmentMenu.Label = CreateCurseAssignmentLabel(CurseAssignmentMenu)
	
	local CurseGraphicFrame = CreateFrame("Frame", nil, ParentFrame)
		CurseGraphicFrame:SetSize(30,30)
		CurseGraphicFrame:SetPoint("LEFT", CurseAssignmentMenu, "RIGHT", -12, 8)
	
--[[
	local CurseGraphic = CurseGraphicFrame:CreateTexture(nil, "OVERLAY") 
	CurseGraphic:SetAllPoints()
	CurseGraphic:SetTexture(GetSpellTexture("Curse of the Elements"))
	--CurseGraphicFrame:SetTexture(CurseGraphic)
	]]--	
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


function GetCurseValueFromDropDownList(DropDownMenu)
	local selectedValue = UIDropDownMenu_GetSelectedID(DropDownMenu)
	return CurseOptions[selectedValue]
end

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
	end
	return nil
end


function CreateCurseAssignmentLabel(ParentFrame)
	local Label = AddTextToFrame(ParentFrame, "Curse Assignment", 150)
	Label:SetPoint("BOTTOMLEFT", ParentFrame, "TOPLEFT", 0, 0)
	return Label
end

function CreateDropDownMenu(ParentFrame, OptionList)
	local DropDownMenu = CreateFrame("Button", nil, ParentFrame, "UIDropDownMenuTemplate")

	local function OnClick(self)		
	   UIDropDownMenu_SetSelectedID(DropDownMenu, self:GetID())
	   
		local selection = GetCurseValueFromDropDownList(DropDownMenu)
		--print("User changed selection to " .. selection)
		UpdateCurseGraphic(DropDownMenu, selection)
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
	
	return DropDownMenu
end