--All of these functions are related to updating the ui from the data or vice versa.

--Will take in the string ID and return the appropriate Locky Frame
function GetLockyFriendFrameById(LockyFrameID)
	for key, value in pairs(LockyFrame.scrollframe.content.LockyFriendFrames) do
		--print(key, " -- ", value["LockyFrameID"])
		if value["LockyFrameID"] == LockyFrameID then
			return value
		end
	end
end

--Will take in a string name and return the appropriate Locky Frame.
function GetLockyFriendFrameByName(LockyName)
	for key, value in pairs(LockyFrame.scrollframe.content.LockyFriendFrames) do
		--print(key, " -- ", value["LockyFrameID"])
		if value["LockyName"] == LockyName then
			return value
		end
	end
end

--Will update a locky friend frame with the warlock data passed in.
--If the warlock object is null it will clear and hide the data from the screen.
function UpdateLockyFrame(Warlock, LockyFriendFrame)
	--print("Updating Locky Frame")	
	if(Warlock == nil) then
		LockyFriendFrame:Hide()
		Warlock = CreateWarlock("", "None", "None")
	else
		LockyFriendFrame:Show()
	end
	--Set the nametag
    --print("Updating Nameplate Text to: ".. Warlock.Name)
    LockyFriendFrame.LockyName = Warlock.Name
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
	UpdateDropDownMenuWithNewOptions(LockyFriendFrame.SSAssignmentMenu, GetSSTargets(), "SSAssignments");
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

--This will use the global locky friends data.
function UpdateAllLockyFriendFrames()
	if NL_DebugMode then
		print("Updating all frames.")
	end
    ClearAllLockyFrames()
   -- print("All frames Cleared")
    ConsolidateFrameLocations()
    --print("Frame Locations Consolidated")
	for key, value in pairs(LockyFriendsData) do
		UpdateLockyFrame(value, GetLockyFriendFrameById(value.LockyFrameLocation))
	end
	if NL_DebugMode then
		print("Frames updated successfully.")
	end
    LockyFrame.scrollbar:SetMinMaxValues(1, GetMaxValueForScrollBar(LockyFriendsData))
  --  print("ScrollRegion size updated successfully")
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
		if(v.SSonCD=="true") then
			-- We have the table item for the SSCooldown			
			local CDLength = 30*60
			local timeShift = GetTime()-v.LocalTime;
			local result = SecondsToTime(math.floor(v.SSCooldown + CDLength - v.LocalTime - timeShift))			
			--print(result)
			local frame = GetLockyFriendFrameById(v.LockyFrameLocation)
			frame.SSCooldownTracker:SetText("CD "..result)

			if math.floor(v.SSCooldown + CDLength - GetTime()) <=0 then
				v.SSonCD = "false"
				frame.SSCooldownTracker:SetText("Available")
			end
		end
	end
end

--Will set default assignments for curses / banishes and SS.
function SetDefaultAssignments(warlockTable)	
	for k, y in pairs(warlockTable) do
		if(k<=3)then
			y.CurseAssignment = CurseOptions[k+1]
		else
			y.CurseAssignment = CurseOptions[1]
		end

		if(k<=7) then
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

-- Gets the index of the frame that currently houses a particular warlock. 
-- This is used for force removal and not much else that I can recall.
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

--Checks to see if the SS is on CD, and broadcasts if it is to all everyone.
function CheckSSCD(self)
    local startTime, duration, enable = GetItemCooldown(16896)
    --if my CD in never locky is different from the what I am aware of then I need to update.
    local myself = GetMyLockyData()
    if(myself.SSCooldown~=startTime) then
		myself.SSCooldown = startTime
		myself.LocalTime = GetTime()
        myself.SSonCD = "true"
    end    
    --print(startTime, duration, enable, myself.Name)
    --If the SS is on CD then we broadcast that.
    
    --If the CD is on cooldown AND we have not broadcast in the last minute we will broadcast.
    if(startTime > 0 and self.TimeSinceLastSSCDBroadcast > NeverLockySSCD_BroadcastInterval) then
        self.TimeSinceLastSSCDBroadcast=0
        BroadcastSSCooldown(myself)
    end
end

--Updates the cooldown of a warlock in the ui.
function UpdateLockySSCDByName(name, cd, localtime)
    local warlock = GetLockyDataByName(name)
    if warlock.SSCooldown~=cd then
        warlock.SSCooldown = cd        
	end    
	if warlock.LocalTime ~= localtime then 
		warlock.LocalTime = localtime
	end
end

--Returns a warlock table object from the LockyFrame
--This function is used to determine if unsaved UI changes have been made.
--This will be used by the is dirty function to determine if the frame is dirty.
function GetWarlockFromLockyFrame(LockyName)
    local LockyFriendFrame = GetLockyFriendFrameByName(LockyName)
    local Warlock = CreateWarlock(LockyFriendFrame.LockyName,
        GetCurseValueFromDropDownList(LockyFriendFrame.CurseAssignmentMenu),
        GetValueFromDropDownList(LockyFriendFrame.BanishAssignmentMenu, BanishMarkers))                
    Warlock.SSAssignment = GetValueFromDropDownList(LockyFriendFrame.SSAssignmentMenu, GetSSTargets())         
    Warlock.LockyFrameLocation = LockyFriendFrame.LockyFrameID       
    return Warlock   
end

--Returns true if changes have been made but have not been saved.
function IsUIDirty(LockyData)
    for k, v in pairs(LockyData) do
        local uiLock = GetWarlockFromLockyFrame(v.Name)
        if(v.CurseAssignment~=uiLock.CurseAssignment or
        v.BanishAssignment ~= uiLock.BanishAssignment or
        v.SSAssignment ~= uiLock.SSAssignment) then
            return true
        end        
    end
    return false
end

--Commits any UI changes to the global LockyFriendsDataModel
function CommitChanges(LockyFriendsData)
    
    for k, v in pairs(LockyFriendsData) do
        local uiLock = GetWarlockFromLockyFrame(v.Name)
        if NL_DebugMode then
			print("Old: ", v.CurseAssignment, "New: ", uiLock.CurseAssignment)
			print("Old: ", v.BanishAssignment, "New: ", uiLock.BanishAssignment)
			print("Old",v.SSAssignment , "New:", uiLock.SSAssignment)
		end
        v.CurseAssignment = uiLock.CurseAssignment
        v.BanishAssignment = uiLock.BanishAssignment
        v.SSAssignment = uiLock.SSAssignment
    end
    LockyData_Timestamp = GetTime()
    return LockyFriendsData
end