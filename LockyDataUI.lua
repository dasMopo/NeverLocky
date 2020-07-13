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

	--Update acknowledged Update that text:
	if(Warlock.AcceptedAssignments == "true")then
		LockyFriendFrame.AssignmentAcknowledgement.value:SetText("Yes")
	elseif Warlock.AcceptedAssignments == "false" then
		LockyFriendFrame.AssignmentAcknowledgement.value:SetText("No")
	else
		LockyFriendFrame.AssignmentAcknowledgement.value:SetText("Not Received")
	end

	if(Warlock.AddonVersion == 0) then
		LockyFriendFrame.Warning.value:SetText("Warning: Addon not installed")
		LockyFriendFrame.Warning:Show();		
	elseif (Warlock.AddonVersion< NL_Version) then
		LockyFriendFrame.Warning.value:SetText("Warning: Addon out of date")
		LockyFriendFrame.Warning:Show();
	else
		LockyFriendFrame.Warning:Hide();
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
    NL_ConsolidateFrameLocations()
    --print("Frame Locations Consolidated")
	for key, value in pairs(LockyFriendsData) do
		UpdateLockyFrame(value, GetLockyFriendFrameById(value.LockyFrameLocation))
	end
	if NL_DebugMode then
		print("Frames updated successfully.")
	end
    LockyFrame.scrollbar:SetMinMaxValues(1, NL_GetMaxValueForScrollBar(LockyFriendsData))
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
function  NL_ConsolidateFrameLocations()
	--Need to loop through and assign a locky frame id to a locky friend.
	--print("Setting up FrameLocations for the locky friend data.")
	for key, value in pairs(LockyFriendsData) do		
		--print(value.Name, "will be assigned a frame.")
		value.LockyFrameLocation = LockyFrame.scrollframe.content.LockyFriendFrames[key].LockyFrameID;
		--print("Assigned Frame:",value.LockyFrameLocation)
	end
end

--[[
	Go through each lock.
	if SS is on CD then
	Update the CD Tracker Text
	else do nothing.
	]]--
function UpdateLockyClockys()
	for k,v in pairs(LockyFriendsData) do
		if (NL_DebugMode) then
			--print(v.Name, "on cooldown =", v.SSonCD)
		end
		if(v.SSonCD=="true") then
			-- We have the table item for the SSCooldown			
			local CDLength = 30*60
			local timeShift = 0
			
			timeShift = v.MyTime - v.LocalTime;
			
			local absCD = v.SSCooldown+timeShift;

			

			local secondsRemaining = math.floor(absCD + CDLength - GetTime())
			local result = SecondsToTime(secondsRemaining)			
			if(NL_DebugMode and v.SSCooldown~=0) then
				--print(v.Name,"my time:", v.MyTime, "localtime:", v.LocalTime, "timeShift:", timeShift, "LocalCD", v.SSCooldown, "Abs CD:",absCD, "Time Remaining:",secondsRemaining)
			end
			local frame = GetLockyFriendFrameById(v.LockyFrameLocation)
			frame.SSCooldownTracker:SetText("CD "..result)

			if secondsRemaining <=0 or v.SSCooldown == 0 then
				v.SSonCD = "false"
				frame.SSCooldownTracker:SetText("Available")
			end
		end
	end
end

--Will set default assignments for curses / banishes and SS.
function NL_SetDefaultAssignments(warlockTable)	
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
	if myself ~= nil then
		if(myself.SSCooldown~=startTime) then
			if NL_DebugMode then
				print("Personal SSCD detected.")
			end
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
	else
		if NL_DebugMode then
			print("Something went horribly wrong.")
		end
	end
end

function ForceUpdateSSCD()
	if NL_DebugMode then
		print("Forcing SSCD cache update.")
	end

	local startTime, duration, enable = GetItemCooldown(16896)
    --if my CD in never locky is different from the what I am aware of then I need to update.
	local myself = GetMyLockyData()
	if myself ~= nil then
		if(myself.SSCooldown~=startTime) then
			if NL_DebugMode then
				print("Personal SSCD detected.")
			end
			myself.SSCooldown = startTime
			myself.LocalTime = GetTime()
			myself.SSonCD = "true"
		end    	
	else
		if NL_DebugMode then
			print("Something went horribly wrong.")
		end
	end
end

--Updates the cooldown of a warlock in the ui.
function UpdateLockySSCDByName(name, cd)
	local warlock = GetLockyDataByName(name)
	if NL_DebugMode then
		print("Attempting to update SS CD for", name);
	end
    --if warlock.SSCooldown~=cd then
		warlock.SSCooldown = cd      
		if NL_DebugMode then
			print("Updated SS CD for", name,"successfully.");
		end  
	--end
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
function NL_IsUIDirty(LockyData)
	if(not LockyData_HasInitialized) then	
		LockyFriendsData = InitLockyFriendData();
		LockyData_HasInitialized = true;
		return true;
	end
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
function NL_CommitChanges(LockyFriendsData)
    
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
		v.AcceptedAssignments = "nil"
    end
    LockyData_Timestamp = GetTime()
    return LockyFriendsData
end

function AnnounceAssignments()
	local AnnounceOption = 	GetValueFromDropDownList(LockyAnnouncerOptionMenu, AnnouncerOptions);
	for k, v in pairs(LockyFriendsData) do
		local message = ""
		if v.CurseAssignment ~= "None"  or v.BanishAssignment ~= "None" or v.SSAssignment~="None" then
			message = v.Name .. ": ";
		end
		if v.CurseAssignment~="None" then
			message = message.."Curse -> ".. v.CurseAssignment .." ";
		end
		if v.BanishAssignment~="None" then
			message = message.."Banish -> {".. v.BanishAssignment .."} ";
		end
		if v.SSAssignment~="None" then
			message = message.."SS -> "..v.SSAssignment .." ";
		end		
		
		if AnnounceOption == "Addon Only" then
			if NL_DebugMode then					
				print(message)
			end
		elseif AnnounceOption == "Raid" then
			SendChatMessage(message, "RAID", nil, nil)
		elseif AnnounceOption == "Party" then
			SendChatMessage(message, "PARTY", nil, nil)
		elseif AnnounceOption == "Whisper" then
			SendChatMessage(message, "WHISPER", nil, v.Name)
		end
	end		
end