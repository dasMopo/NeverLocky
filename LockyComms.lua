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
    print("Message was recived.")    
    local message = table.deserialize(message)
    -- process the incoming message
    if message.action == CommAction.SSonCD then
        print("SS on CD: ", message.data.Name, message.data.SSCooldown)
        UpdateLockySSCDByName(message.data.Name, message.data.SSCooldown)
    elseif message.action == CommAction.BroadcastTable then
        print("Recieved a broadcast message")

        if(LockyData_Timestamp <= message.dataAge) then
            for k, v in pairs(message.data)do
                print(k, v)
            end
            LockyData_Timestamp = message.dataAge
            LockyFriendsData = message.data
            UpdateAllLockyFriendFrames()
            print("UI has been refreshed.")
        else
            print("Data was recieved but the timestamp showed that the data was stale.")
        end
    elseif message.action == CommAction.RequestAssignments then
        BroadcastTable(LockyFriendsData)
    else
        print("The following message was recieved: ",sender, prefix, message)
    end
end

--Takes in a table and sends the serialized verion across the wire.
function BroadcastTable(LockyTable)
    --stringify the locky table
    print("Sending out the table")
    local serializedTable = CreateMessageFromTable(CommAction.BroadcastTable, LockyTable, LockyData_Timestamp) 
	NeverLocky:SendCommMessage("NeverLockyComms", serializedTable, NL_CommMode, NL_CommTarget)
	--NeverLocky:SendCommMessage("NeverLockyComms", serializedTable, "WHISPER", "Brylack")
end

function BroadcastSSCooldown(myself)    
    local serializedTable = CreateMessageFromTable(CommAction.SSonCD, myself, GetTime())
	NeverLocky:SendCommMessage("NeverLockyComms", serializedTable, NL_CommMode, NL_CommTarget)
end

function RequestAssignments()
    print("Requesting Updated Assignment Table")
    local message = CreateMessageFromTable(CommAction.RequestAssignments, {},GetTime() )
    NeverLocky:SendCommMessage("NeverLockyComms", message, NL_CommMode, NL_CommTarget)
end