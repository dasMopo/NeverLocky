NL_CommMode = "WHISPER"
NL_CommTarget = UnitName("player")

if RaidMode then
    NL_CommMode = "RAID"    
end

CommAction = {}
CommAction.SSonCD = "SSonCD"
CommAction.BroadcastTable = "DataRefresh"
CommAction.RequestAssignments = "GetAssignmentData"

function CreateMessageFromTable(action, data, dataAge)
    --print("Creating outbound message.")
    local message = {}
    message.action = action
    message.data = data
    message.dataAge = dataAge
    message.author = UnitName("player")
    local strMessage = table.serialize(message)
    --print("Message created successfully")
    return strMessage
end

function RegisterForComms()   
    NeverLocky:RegisterComm("NeverLockyComms")
    --NeverLocky:RegisterComm("NeverLockySSCooldown")
end

--Message router where reveived messages land.
function NeverLocky:OnCommReceived(prefix, message, distribution, sender)
    print("Message Was Recieved");
    local message = table.deserialize(message)
    
    -- process the incoming message
    if message.action == CommAction.SSonCD then
        if NL_DebugMode then
            print("SS on CD: ", message.data.Name, message.data.SSCooldown)
        end
        UpdateLockySSCDByName(message.data.Name, message.data.SSCooldown)
    elseif message.action == CommAction.BroadcastTable then
        if NL_DebugMode then
            print("Recieved a broadcast message")
        end
        if(LockyData_Timestamp <= message.dataAge) then
            for k, v in pairs(message.data)do
                if NL_DebugMode then
                    for lk, lv in pairs(v) do
                        print(lk, lv)                    
                    end                    
                end
            end
            LockyData_Timestamp = message.dataAge
            LockyFriendsData = message.data
            UpdateAllLockyFriendFrames()
            if NL_DebugMode then
                print("UI has been refreshed by request of broadcast message.")
            end
        else
            if NL_DebugMode then
                print("Data was recieved but the timestamp showed that the data was stale.")
            end
        end
    elseif message.action == CommAction.RequestAssignments then
        if NL_DebugMode then
            print("Assignment request recieved, sending out assignments.")
        end
        BroadcastTable(LockyFriendsData)
    else
        if NL_DebugMode then
            print("The following message was recieved: ",sender, prefix, message)
        end
    end
end

--Takes in a table and sends the serialized verion across the wire.
function BroadcastTable(LockyTable)
    --stringify the locky table
    if NL_DebugMode then
        print("Sending out the assignment table")
    end
    local serializedTable = CreateMessageFromTable(CommAction.BroadcastTable, LockyTable, LockyData_Timestamp) 
    if RaidMode then
        NeverLocky:SendCommMessage("NeverLockyComms", serializedTable, NL_CommMode)
    else
        NeverLocky:SendCommMessage("NeverLockyComms", serializedTable, NL_CommMode, NL_CommTarget)
    end
	--NeverLocky:SendCommMessage("NeverLockyComms", serializedTable, "WHISPER", "Brylack")
end

function BroadcastSSCooldown(myself)    
    local serializedTable = CreateMessageFromTable(CommAction.SSonCD, myself, GetTime())
    if RaidMode then
        NeverLocky:SendCommMessage("NeverLockyComms", serializedTable, NL_CommMode)
    else
        NeverLocky:SendCommMessage("NeverLockyComms", serializedTable, NL_CommMode, NL_CommTarget)
    end
end

function RequestAssignments()
    if NL_DebugMode then
        print("Requesting Updated Assignment Table")
    end
    local message = CreateMessageFromTable(CommAction.RequestAssignments, {},GetTime() )
    if RaidMode then
        NeverLocky:SendCommMessage("NeverLockyComms", message, NL_CommMode)
    else
        NeverLocky:SendCommMessage("NeverLockyComms", message, NL_CommMode, NL_CommTarget)
    end
end