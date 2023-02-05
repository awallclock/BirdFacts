local addonName, bFacts = ...

factChannel = "SAY"
chatChannel = ""

function factOut()
    local out = bFacts.fact[math.random(1, #bFacts.fact)]
    SendChatMessage(out, factChannel)
end

function generalChatOut()
    local out = bFacts.fact[math.random(1, #bFacts.fact)]
    SendChatMessage(out, "CHANNEL", nil, chatChannel)
end

SLASH_BIRDFACTS1, SLASH_BIRDFACTS2 = '/birdfacts', '/bf'
function SlashCmdList.BIRDFACTS(msg, editBox)
	if (msg == "s" or msg == "say") then
		factChannel = "SAY"
        factOut()
    elseif (msg == "g" or msg == "guild") then
        factChannel = "GUILD"
        factOut()
    elseif (msg == "p" or msg == "party") then
        factChannel = "PARTY"
        factOut()
    elseif (msg == "y" or msg == "yell") then
        factChannel = "YELL"
        factOut()
    elseif (msg == "rw" or msg == "raidwarning") then
        factChannel = "RAID_WARNING"
        factOut()
    elseif (msg == "ra" or msg == "raid") then
        factChannel = "RAID"
        factOut()
    elseif (msg == "1") then
        chatChannel = "1"
        generalChatOut()
    elseif (msg == "2") then
        chatChannel = "2"
        generalChatOut()
    elseif (msg == "3") then
        chatChannel = "3"
        generalChatOut()
    elseif (msg == "4") then
        chatChannel = "3"
        generalChatOut()
    elseif (msg == "5") then
        chatChannel = "5"
        generalChatOut()
    end
end
