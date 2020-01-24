NL_CommMode = "WHISPER"
NL_CommTarget = UnitName("player")

if RaidMode then
    NL_CommMode = "RAID"    
end

CommAction = {}
CommAction.SSonCD = "SSonCD"

function CreateMessageFromTable(action, data)
    --print("Creating outbound message.")
    local message = {}
    message.action = action
    message.data = data
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
    else
        print("The following message was recieved: ",sender, prefix, message)
    end
end

--Takes in a table and sends the serialized verion across the wire.
function BroadcastTable(LockyTable)
	--stringify the locky table
    local serializedTable = table.serialize(LockyTable)    
	NeverLocky:SendCommMessage("NeverLockyComms", serializedTable, "RAID")
	--NeverLocky:SendCommMessage("NeverLockyComms", serializedTable, "WHISPER", "Brylack")
end

function BroadcastSSCooldown(myself)
    local serializedTable = CreateMessageFromTable(CommAction.SSonCD, myself)
	NeverLocky:SendCommMessage("NeverLockyComms", serializedTable, NL_CommMode, NL_CommTarget)
end