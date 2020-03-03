NL_CommModeWhisper = "WHISPER"
NL_CommTarget = UnitName("player")
NL_CommModeRaid = "RAID";


CommAction = {}
CommAction.SSonCD = "SSonCD"
CommAction.BroadcastTable = "DataRefresh"
CommAction.RequestAssignments = "GetAssignmentData"
CommAction.AssigmentResponse = "AssignmentResponse"
CommAction.AssignmentReset = "AssignmentReset"

function CreateMessageFromTable(action, data, dataAge)
    --print("Creating outbound message.")
    local message = {}
    message.action = action
    message.data = data
    message.dataAge = dataAge
    message.author = UnitName("player")
    message.addonVersion = NL_Version
    local strMessage = table.serialize(message)
    --print("Message created successfully")
    return strMessage
end

function RegisterForComms()   
    NeverLocky:RegisterComm("NeverLockyComms")    
end

--Message router where reveived messages land.
function NeverLocky:OnCommReceived(prefix, message, distribution, sender)
    if NL_DebugMode then
        print("Message Was Recieved by the Router");
    end
    local message = table.deserialize(message)

    local lockyversionstub = GetLockyDataByName(message.author)
    if lockyversionstub ~=nil then
        lockyversionstub.AddonVersion = message.addonVersion
    end

    if message.addonVersion > NL_Version then
        IsMyAddonOutOfDate = true;
        NeverLockyFrame.WarningTextFrame:Show();
        NLCommit_Button:Disable();
    end
    
    -- process the incoming message
    if message.action == CommAction.SSonCD then
        if NL_DebugMode then
            print("SS on CD: ", message.data.Name, message.data.SSCooldown, message.data.SSonCD, message.dataAge)
        end
        local SendingWarlock = GetLockyDataByName(message.author)
            if(SendingWarlock ~= nil) then
                if NL_DebugMode then 
                    print("Updating SS data for", message.author);
                end
                SendingWarlock.LocalTime = message.dataAge
                SendingWarlock.MyTime = GetTime()
                SendingWarlock.SSonCD = "true";
                SendingWarlock.SSCooldown = message.data.SSCooldown
            end
        --UpdateLockySSCDByName(message.data.Name, message.data.SSCooldown)
    elseif message.action == CommAction.BroadcastTable then

        local myData = GetMyLockyData()
        if (myData~=nil)then
            for  lockyindex, lockydata in pairs(message.data) do
                if lockydata.Name == UnitName("player") then
                    if IsMyDataDirty(lockydata) or NL_DebugMode then                    
                        SetLockyCheckFrameAssignments(lockydata.CurseAssignment, lockydata.BanishAssignment, lockydata.SSAssignment)
                    else
                        SendAssignmentAcknowledgement("true");
                    end
                end
            end
        end

        if RaidMode then
            if NL_DebugMode then
                print("Received message from", message.author);
            end
            if message.author == NL_CommTarget then            
                return;
            end
        end
        if NL_DebugMode then
            print("Recieved a broadcast message from", message.author)
        end

        

        if(IsUIDirty(message.data)) then
            for k, v in pairs(message.data)do
                if NL_DebugMode then
                    for lk, lv in pairs(v) do
                        print(lk, lv)                    
                    end                    
                end
            end

            local myData = GetMyLockyData()
            if (myData~=nil)then
                for  lockyindex, lockydata in pairs(message.data) do
                    if lockydata.Name == UnitName("player") then
                        if IsMyDataDirty(lockydata) or NL_DebugMode then                    
                            SetLockyCheckFrameAssignments(lockydata.CurseAssignment, lockydata.BanishAssignment, lockydata.SSAssignment)
                        else
                            SendAssignmentAcknowledgement("true");
                        end
                    end
                end
            end

            --LockyFriendsData = message.data            
            MergeAssignments(message.data);
            LockyFriendsData = UpdateWarlocks(LockyFriendsData);
            UpdateAllLockyFriendFrames()
            if NL_DebugMode then
                print("UI has been refreshed by request of broadcast message.")
            end               
        end        
    elseif message.action == CommAction.RequestAssignments then
        if RaidMode then
            if NL_DebugMode then
                print("Received Assignment Request message from", message.author);
            end
            local myself = GetMyLockyData()
            if myself ~= nil then
                BroadcastSSCooldown(myself)
            end
            if message.author == NL_CommTarget then
                if NL_DebugMode then
                    print("Message was from self, doing nothing.");
                end
                return;
            end
        end
        if NL_DebugMode then
            print("Assignment request recieved, sending out assignments.")
        end
        BroadcastTable(LockyFriendsData)
        
    elseif message.action == CommAction.AssigmentResponse then
        -- When we recieve an assigment response we should stuff with that.
        if NL_DebugMode then 
            print("Recieved an Ack message from", message.author);
        end

        local SendingWarlock = GetLockyDataByName(message.author)
        if SendingWarlock~=nil then
            SendingWarlock.AcceptedAssignments = message.data.acknowledged
            UpdateLockyFrame(SendingWarlock, GetLockyFriendFrameById(SendingWarlock.LockyFrameLocation))
        end

    elseif message.action == CommAction.AssignmentReset then
        if NL_DebugMode then
            print("Recieved assignment reset from", message.author)
        end
        ResetAssignmentAcks(LockyFriendsData);
        
    else
        if NL_DebugMode then
            print("The following message was recieved: ",sender, prefix, message)
        end
    end
end

--Takes in a table and sends the serialized verion across the wire.
function BroadcastTable(LockyTable)
    if(IsMyAddonOutOfDate)then
        return;
    end
    --stringify the locky table
    if NL_DebugMode then
        print("Sending out the assignment table")
    end
    local serializedTable = CreateMessageFromTable(CommAction.BroadcastTable, LockyTable, LockyData_Timestamp) 
    if RaidMode then
        NeverLocky:SendCommMessage("NeverLockyComms", serializedTable, NL_CommModeRaid)
    else
        NeverLocky:SendCommMessage("NeverLockyComms", serializedTable, NL_CommModeWhisper, NL_CommTarget)
    end
	--NeverLocky:SendCommMessage("NeverLockyComms", serializedTable, "WHISPER", "Brylack")
end

function BroadcastSSCooldown(myself)    
    ForceUpdateSSCD();
    local serializedTable = CreateMessageFromTable(CommAction.SSonCD, myself, GetTime())
    if RaidMode then
        NeverLocky:SendCommMessage("NeverLockyComms", serializedTable, NL_CommModeRaid)
    else
        NeverLocky:SendCommMessage("NeverLockyComms", serializedTable, NL_CommModeWhisper, NL_CommTarget)
    end
end

function RequestAssignments()
    if NL_DebugMode then
        print("Requesting Updated Assignment Table")
    end
    local message = CreateMessageFromTable(CommAction.RequestAssignments, {},GetTime() )
    if RaidMode then
        NeverLocky:SendCommMessage("NeverLockyComms", message, NL_CommModeRaid)
    else
        NeverLocky:SendCommMessage("NeverLockyComms", message, NL_CommModeWhisper, NL_CommTarget)
    end
end

function  SendAssignmentAcknowledgement(answer)
    if NL_DebugMode then
        print("Sending assignment acknowledgement:", answer)
    end    
    local message = CreateMessageFromTable(CommAction.AssigmentResponse, {acknowledged = answer}, GetTime());
    if RaidMode then
        NeverLocky:SendCommMessage("NeverLockyComms", message, NL_CommModeRaid)
    else
        NeverLocky:SendCommMessage("NeverLockyComms", message, NL_CommModeWhisper, NL_CommTarget)
    end
end

function SendAssignmentReset()
    if NL_DebugMode then
        print("Sending assignment reset command")
    end    
    local message = CreateMessageFromTable(CommAction.AssignmentReset, {}, GetTime());
    if RaidMode then
        NeverLocky:SendCommMessage("NeverLockyComms", message, NL_CommModeRaid)
    else
        NeverLocky:SendCommMessage("NeverLockyComms", message, NL_CommModeWhisper, NL_CommTarget)
    end
end

function CheckInstallVersion()
    
end