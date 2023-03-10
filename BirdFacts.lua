local addOnName, bFacts = ...

--loading ace3
BirdFacts = LibStub("AceAddon-3.0"):NewAddon("Bird Facts", "AceConsole-3.0", "AceTimer-3.0")
local AC = LibStub("AceConfig-3.0")
local ACD = LibStub("AceConfigDialog-3.0")

local defaults = {
    profile = {
        defaultChannel = "SAY",
    },
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
			values = { ["SAY"] = "Say",
                ["PARTY"] = "Party",
                ["RAID"] = "Raid",
                ["GUILD"] = "Guild",
                ["YELL"] = "Yell",
                ["RAID_WARNING"] = "Raid Warning",
                ["INSTANCE_CHAT"] = "Instance",
            },
            style = "dropdown",
			get = "GetMessage",
			set = "SetMessage",
		},
	},
}

--things to do on initialize
function BirdFacts:OnInitialize()
    self.db = LibStub("AceDB-3.0"):New("BirdFactsDB", defaults, true)
    self:ScheduleTimer("TimerFeedback", 10)


    
    AC:RegisterOptionsTable("BirdFacts_options", options)
    self.optionsFrame = ACD:AddToBlizOptions("BirdFacts_options", "BirdFacts")
end



function BirdFacts:GetMessage(info)
    return self.db.profile.defaultChannel
end

function BirdFacts:SetMessage(info, value)
    self.db.profile.defaultChannel = value
end

--slash commands and their outputs
function BirdFacts:SlashCommand(msg)
    local out = bFacts.fact[math.random(1, #bFacts.fact)]
    local table = {
        ["s"] = "SAY",
        ["p"] = "PARTY",
        ["g"] = "GUILD",
        ["ra"] = "RAID",
        ["rw"] = "RAID_WARNING",
        ["y"] = "YELL",
        ["bg"] = "INSTANCE",
        ["i"] = "INSTANCE",
    }
    local msg = string.lower(msg)
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
        elseif (msg ~= "" or msg == "flags") then
            factError()
        else SendChatMessage(out, self.db.profile.defaultChannel)
 
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
    self:Print("Type \'/bf flags\' to view available channels")
end

SLASH_BIRDFACTS1 = "/bf"
SLASH_BIRDFACTS2 = "/birdfacts"
SlashCmdList["BIRDFACTS"] = function(msg)
    BirdFacts:SlashCommand(msg)
end
