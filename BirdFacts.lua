local addOnName, bFacts = ...

-- loading ace3
BirdFacts = LibStub("AceAddon-3.0"):NewAddon("Bird Facts", "AceConsole-3.0", "AceTimer-3.0")
local AC = LibStub("AceConfig-3.0")
local ACD = LibStub("AceConfigDialog-3.0")

local defaults = {
    profile = {
        defaultChannel = "SAY",
        realFake = "REAL",
        timerToggle = false,
        factTimer = "0",
    }
}

local options = {
    name = "BirdFacts",
    handler = BirdFacts,
    type = "group",
    args = {
        channel = {
            type = "select",
            name = "Default channel",
            desc = "The default bird fact channel",
            values = {
                ["SAY"] = "Say",
                ["PARTY"] = "Party",
                ["RAID"] = "Raid",
                ["GUILD"] = "Guild",
                ["YELL"] = "Yell",
                ["RAID_WARNING"] = "Raid Warning",
                ["INSTANCE_CHAT"] = "Instance"
            },
            style = "dropdown",
            get = "GetMessage",
            set = "SetMessage"
        },
        fakeFacts = {
            type = "select",
            name = "Fact types",
            desc = "Pick from having the option to only have real bird facts, facts about fictional birds, or both",
            values = {
                ["REAL"] = "Only real facts",
                ["FAKE"] = "Only fictional facts",
                ["BOTH"] = "Both real and fictional facts"
            },
            get = "GetRealFake",
            set = "SetRealFake",
        },
        factTimerToggle = {
            type = "toggle",
            name = "Toggle Personal Auto-Fact Timer",
            desc = "Turns on/off the Auto-Fact Timer. This will only print a message to the chatbox. No other players will see it",
            set = "SetToggleTimer",
            get = "GetToggleTimer",
        },
        factTimer = {
            type = "range",
            name = "Personal Auto Fact-Timer",
            desc = "Set the time in minutes to automatically output a bird fact. This only prints a message to the chatbox. No other players will see it",
            order = 1,
            min = 1,
            max = 60,
            step = 1,
            set = "SetFactTimer",
            get = "GetFactTimer",
        },
    }
}

-- things to do on initialize
function BirdFacts:OnInitialize()
    self.db = LibStub("AceDB-3.0"):New("BirdFactsDB", defaults, true)
    self:ScheduleTimer("TimerFeedback", 10)
    BirdFacts:OutputFactTimer()
    AC:RegisterOptionsTable("BirdFacts_options", options)
    self.optionsFrame = ACD:AddToBlizOptions("BirdFacts_options", "BirdFacts")
end



function BirdFacts:OutputFactTimer()
self:CancelTimer(self.timer)
    self.timeInMinutes = self.db.profile.factTimer * 60
    if self.db.profile.toggleTimer == true then
        self.timer = self:ScheduleRepeatingTimer("SlashCommand", self.timeInMinutes, "self", "SlashCommand")
  
    end
end

-- all the stupid get/set functions that i can't get working in the options panel, idk why they don't work
function BirdFacts:GetMessage(info)
    return self.db.profile.defaultChannel
end
function BirdFacts:SetMessage(info, value)
    self.db.profile.defaultChannel = value
end
function BirdFacts:GetRealFake(info)
    return self.db.profile.realFake
end
function BirdFacts:SetRealFake(info, value)
    self.db.profile.realFake = value
    BirdFacts:OutputFactTimer()
end
function BirdFacts:SetToggleTimer(info, value)
    self.db.profile.toggleTimer = value
    BirdFacts:OutputFactTimer()
end
function BirdFacts:GetToggleTimer(info)
    return self.db.profile.toggleTimer 
end
function BirdFacts:SetFactTimer(info, value)
    self.db.profile.factTimer = value
    BirdFacts:OutputFactTimer()
end
function BirdFacts:GetFactTimer(info)
    return self.db.profile.factTimer
end


-- slash commands and their outputs
function BirdFacts:SlashCommand(msg)
    local rf = self.db.profile.realFake
    local out = ""
    if (rf == "REAL") then
        out = bFacts.fact[math.random(1, #bFacts.fact)]
    elseif (rf == "FAKE") then
        out = bFacts.fake[math.random(1, #bFacts.fake)]
    elseif (rf == "BOTH") then
        local bothFactsLength = #bFacts.fact + #bFacts.fake
        local num = math.random(1, bothFactsLength)
        if (num < #bFacts.fact) then
            out = bFacts.fact[math.random(1, #bFacts.fact)]
        elseif (num > #bFacts.fact) then
            out = bFacts.fake[math.random(1, #bFacts.fake)]
        end
    end

    local table = {
        ["s"] = "SAY",
        ["p"] = "PARTY",
        ["g"] = "GUILD",
        ["ra"] = "RAID",
        ["rw"] = "RAID_WARNING",
        ["y"] = "YELL",
        ["bg"] = "INSTANCE",
        ["i"] = "INSTANCE"
    }


    if (msg == "r") then
        SendChatMessage(out, "WHISPER", nil, ChatFrame1EditBox:GetAttribute("tellTarget"))
    elseif (msg == "s" or msg == "p" or msg == "g" or msg == "ra" or msg == "rw" or msg == "y" or msg == "bg" or msg == "i") then
        SendChatMessage(out, table[msg])
    elseif (msg == "w" or msg == "t") then
        if (UnitName("target")) then
            SendChatMessage(out, "WHISPER", nil, UnitName("target"))
        else
            SendChatMessage(out, self.db.profile.defaultChannel)
        end
    elseif (msg == "1" or msg == "2" or msg == "3" or msg == "4" or msg == "5") then
        SendChatMessage(out, "CHANNEL", nil, msg)
    elseif (msg == "opt" or msg == "options") then
        InterfaceOptionsFrame_OpenToCategory(self.optionsFrame)
        InterfaceOptionsFrame_OpenToCategory(self.optionsFrame)
    elseif (msg == "self") then
        BirdFacts:Print(out)
    elseif (msg ~= "" or msg == "flags") then
        factError()
    else
        SendChatMessage(out, self.db.profile.defaultChannel)
    end
end
-- error message
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
    self:Print("Type \'/bf flags\' to view available channels")
end

SLASH_BIRDFACTS1 = "/bf"
SLASH_BIRDFACTS2 = "/birdfacts"
SlashCmdList["BIRDFACTS"] = function(msg)
    BirdFacts:SlashCommand(msg)
end
