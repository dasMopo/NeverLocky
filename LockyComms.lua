--Sets up the message channels to send and recieve from.
function RegisterForComms()
    print("Attempting to RegisterForComms")
    print(NeverLocky)
	NeverLocky:RegisterComm("NeverLockyComms")
end

--Message router where reveived messages land.
function NeverLocky:OnCommReceived(prefix, message, distribution, sender)
	-- process the incoming message
	print("The following message was recieved: ", message)
end

--Takes in a table and sends the serialized verion across the wire.
function BroadcastTable(LockyTable)
	--stringify the locky table
	local serializedTable = table.serialize(LockyTable)
	NeverLocky:SendCommMessage("NeverLockyComms", serializedTable, "RAID")
	--NeverLocky:SendCommMessage("NeverLockyComms", serializedTable, "WHISPER", "Brylack")
end