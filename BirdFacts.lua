local addOnName, bFacts = ...

--loading ace3
BirdFacts = LibStub("AceAddon-3.0"):NewAddon("Bird Facts", "AceConsole-3.0", "AceTimer-3.0")

--things to do on initialize
function BirdFacts:OnInitialize()
    self:ScheduleTimer("TimerFeedback", 10)
    self:RegisterChatCommand("bf", "SlashCommand")
    self:RegisterChatCommand("birdfact", "SlashCommand")
end

--slash commands and their outputs
function BirdFacts:SlashCommand(msg)
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
    elseif (msg == "i" or msg == "instance" or msg == "bg") then
        factChannel = "INSTANCE_CHAT"
        factOut()
    elseif (msg == "w" or msg == "t") then
        whisperOut()
    elseif (msg == "r") then
        replyOut()
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
    elseif (msg == "") then
        factOut()
    elseif (msg ~= "" or msg == "options") then
        factError()
    end
end

--error message
function factError()
    BirdFacts:Print("\'/bf s\' to send a fact to /say")
    BirdFacts:Print("\'/bf p\' to send a fact to /party")
    BirdFacts:Print("\'/bf g\' to send a fact to /guild")
    BirdFacts:Print("\'/bf ra\' to send a fact to /raid")
    BirdFacts:Print("\'/bf rw\' to send a fact to /raidwarning")
    BirdFacts:Print("\'/bf i\' to send a fact to /instance")
    BirdFacts:Print("\'/bf y\' to send a fact to /yell")
    BirdFacts:Print("\'/bf r\' to send a fact to the last person whispered")
    BirdFacts:Print("\'/bf t\' to send a fact to your target")
    BirdFacts:Print("\'/bf <1-5>\' to send a fact to general channels")
end


function BirdFacts:TimerFeedback()
    self:Print("Type \'/bf options\' to view available channels")
end


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

function whisperOut()
    local out = bFacts.fact[math.random(1, #bFacts.fact)]
    if (UnitName("target")) then
        SendChatMessage(out, "WHISPER", nil, UnitName("target"))
    else
        factOut()
    end
end


function replyOut()
    local out = bFacts.fact[math.random(1, #bFacts.fact)]
    SendChatMessage(out, "WHISPER", nil, ChatFrame1EditBox:GetAttribute("tellTarget"));
end