local addOnName, bFacts = ...

-- loading ace3
local BirdFacts =
	LibStub("AceAddon-3.0"):NewAddon("Bird Facts", "AceConsole-3.0", "AceTimer-3.0", "AceComm-3.0", "AceEvent-3.0")
local AC = LibStub("AceConfig-3.0")
local ACD = LibStub("AceConfigDialog-3.0")
_G["bFacts"] = bFacts
local GetAddOnMetadata = C_AddOns and C_AddOns.GetAddOnMetadata or GetAddOnMetadata

BirdFacts.playerGUID = UnitGUID("player")
BirdFacts.playerName = UnitName("player")
BirdFacts._commPrefix = string.upper(addOnName)

local IsInRaid, IsInGroup, IsGUIDInGroup, isOnline = IsInRaid, IsInGroup, IsGUIDInGroup, isOnline
local _G = _G

--yoinked from RankSentinel, sorry :(
-- cache relevant unitids once so we don't do concat every call
local raidUnit, raidUnitPet = {}, {}
local partyUnit, partyUnitPet = {}, {}
for i = 1, _G.MAX_RAID_MEMBERS do
	raidUnit[i] = "raid" .. i
	raidUnitPet[i] = "raidpet" .. i
end
for i = 1, _G.MAX_PARTY_MEMBERS do
	partyUnit[i] = "party" .. i
	partyUnitPet[i] = "partypet" .. i
end

function BirdFacts:BuildOptionsPanel()
	local channelNames = {}
	for i = 1, 5, 1 do
		local _, temp = GetChannelName(i)
		if temp ~= nil then
			channelNames[i] = i .. "." .. temp
		end
	end
	local options = {
		name = "BirdFacts",
		handler = BirdFacts,
		type = "group",
		args = {

			titleText = {
				type = "description",
				fontSize = "large",
				order = 1,
				name = "                |cFF36F7BC" .. "Bird Facts: v" .. GetAddOnMetadata("BirdFacts", "Version"),
			},
			authorText = {
				type = "description",
				fontSize = "medium",
				order = 2,
				name = "|TInterface\\AddOns\\BirdFacts\\Media\\Icon64:64:64:0:20|t |cFFFFFFFFMade with love by  |cFFC41E3AHylly/Hogcrankr-Faerlina|r \n |cFFFFFFFFMake sure to check out AnimalFacts on Curse for facts about more animals!",
			},

			main = {
				name = "General Options",
				type = "group",
				order = 1,
				args = {
					generalHeader = {
						name = "General",
						type = "header",
						width = "full",
						order = 1.0,
					},
					channel = {
						type = "select",
						name = "Default channel",
						desc = "The default bird fact channel",
						order = 1.1,
						values = {
							["SAY"] = "Say",
							["PARTY"] = "Party",
							["RAID"] = "Raid",
							["GUILD"] = "Guild",
							["YELL"] = "Yell",
							["RAID_WARNING"] = "Raid Warning",
							["INSTANCE_CHAT"] = "Instance / Battleground",
							["OFFICER"] = "Officer",
							["1"] = channelNames[1],
							["2"] = channelNames[2],
							["3"] = channelNames[3],
							["4"] = channelNames[4],
							["5"] = channelNames[5],
						},
						style = "dropdown",
						get = function()
							return self.db.profile.defaultChannel
						end,
						set = function(_, value)
							self.db.profile.defaultChannel = value
						end,
					},
					fakeFacts = {
						type = "select",
						name = "Fact types",
						desc = "Pick from having the option to only have real bird facts, facts about fictional birds, or both",
						order = 1.2,
						values = {
							["REAL"] = "Only real facts",
							["FAKE"] = "Only fictional facts",
							["BOTH"] = "Both real and fictional facts",
						},
						get = function()
							return self.db.profile.realFake
						end,
						set = function(_, value)
							self.db.profile.realFake = value
							BirdFacts:OutputFactTimer()
						end,
					},
					selfTimerHeader = {
						name = "Auto Fact Timer",
						type = "header",
						width = "full",
						order = 2.0,
					},
					factTimerToggle = {
						type = "toggle",
						name = "Toggle Auto-Facts",
						order = 2.1,
						desc = "Turns on/off the Auto-Fact Timer. ",
						get = function()
							return self.db.profile.toggleTimer
						end,
						set = function(_, value)
							self.db.profile.toggleTimer = value
							BirdFacts:OutputFactTimer()
						end,
					},
					factTimer = {
						type = "range",
						name = "Auto-Fact Timer",
						order = 2.2,
						desc = "Set the time in minutes to automatically output a bird fact.",
						min = 1,
						max = 60,
						step = 1,
						get = function()
							return self.db.profile.factTimer
						end,
						set = function(_, value)
							self.db.profile.factTimer = value
							BirdFacts:OutputFactTimer()
						end,
					},
					autoChannel = {
						type = "select",
						name = "Auto-Fact channel",
						desc = "The output channel for the Auto-Fact timer. |cF0FF0000NOTE:|r Say and Yell ONLY work while inside an instance",
						order = 2.3,
						values = {
							["SAY"] = "Say",
							["PARTY"] = "Party",
							["RAID"] = "Raid",
							["GUILD"] = "Guild",
							["YELL"] = "Yell",
							["RAID_WARNING"] = "Raid Warning",
							["INSTANCE_CHAT"] = "Instance / Battleground",
							["OFFICER"] = "Officer",
						},
						style = "dropdown",
						get = function()
							return self.db.profile.defaultAutoChannel
						end,
						set = function(_, value)
							self.db.profile.defaultAutoChannel = value
						end,
					},
				},
			},
			info = {
				name = "Information",
				type = "group",
				order = 2,
				args = {
					infoText = {
						type = "description",
						fontSize = "medium",
						name = "A simple dumb addon that allows you to say / yell / raid warning a random bird fact\n"
							.. "How to use:\n"
							.. "|cFFF5A242/bf|r |cFF42BEF5<command>|r  OR  |cFFF5A242/birdfacts|r |cFF42BEF5<command>|r\n\n"
							.. "List of commands:\n"
							.. "|cFF42BEF5s|r: Sends fact to the /say channel.\n\n"
							.. "|cFF42BEF5p|r: Sends fact to the /party channel.\n\n"
							.. "|cFF42BEF5ra|r: Sends fact to the /raid channel.\n\n"
							.. "|cFF42BEF5rw|r: Sends fact to the /raidwarning channel.\n\n"
							.. "|cFF42BEF5g|r: Sends fact to the /guild channel.\n\n"
							.. "|cFF42BEF5i|r or |cFF42BEF5bg|r: Sends a bird fact to /instance or /bg channel.\n\n"
							.. "|cFF42BEF5w|r or |cFF42BEF5t|r: Whispers a bird fact to your current target\n\n"
							.. "|cFF42BEF5r|r: Whispers a bird fact to your last reply. Or you can start a new whisper and type '|cFFF5A242/bf|r |cFF42BEF5r|r' to send them a fact\n\n"
							.. "|cFF42BEF51-5|r: Use the numbers 1 through 5 to send a bird fact to global channels ('|cFFF5A242/bf|r |cFF42BEF51|r' for example)\n\n"
							.. "Also responds when people say |cFF42BEF5!bf|r in chat (party and raid)",
					},
				},
			},
		},
	}
	BirdFacts.optionsFrame = ACD:AddToBlizOptions("BirdFacts_options", "BirdFacts")
	AC:RegisterOptionsTable("BirdFacts_options", options)
end

-- things to do on initialize
function BirdFacts:OnInitialize()
	local defaults = {
		profile = {
			defaultChannel = "SAY",
			realFake = "REAL",
			timerToggle = false,
			factTimer = "10",
			defaultAutoChannel = "PARTY",
			leader = "",
			pleader = "",
		},
	}
	SLASH_BIRDFACTS1 = "/bf"
	SLASH_BIRDFACTS2 = "/birdfacts"
	SlashCmdList["BIRDFACTS"] = function(msg)
		BirdFacts:SlashCommand(msg)
	end
	self.db = LibStub("AceDB-3.0"):New("BirdFactsDB", defaults, true)
end

function BirdFacts:OnEnable()
	self:RegisterComm(self._commPrefix)
	BirdFacts:BuildOptionsPanel()
	self:ScheduleTimer("TimerFeedback", 10)
	BirdFacts:OutputFactTimer()
	--register chat events
	self:RegisterEvent("CHAT_MSG_RAID", "readChat")
	self:RegisterEvent("CHAT_MSG_PARTY", "readChat")
	self:RegisterEvent("CHAT_MSG_PARTY_LEADER", "readChat")
	self:RegisterEvent("CHAT_MSG_RAID_LEADER", "readChat")
	self:RegisterEvent("CHAT_MSG_GUILD", "readChat")
	self:RegisterEvent("GROUP_ROSTER_UPDATE")
end

function BirdFacts:OnDisable()
	self:CancelTimer(self.timer)
end

function BirdFacts:OutputFactTimer()
	self:CancelTimer(self.timer)
	self.timeInMinutes = self.db.profile.factTimer * 60
	if self.db.profile.toggleTimer == true then
		self.timer = self:ScheduleRepeatingTimer("SlashCommand", self.timeInMinutes, "auto", "SlashCommand")
	end
end

--register the events for chat messages, (Only for Raid and Party), and read the messages for the command "!bf", and then run the function BirdFacts:SlashCommand
function BirdFacts:readChat(event, msg, _, _, _, sender)
	local msgLower = string.lower(msg)
	local leader = self.db.profile.leader
	local channel = event:match("CHAT_MSG_(%w+)")
	local outChannel = ""

	if msgLower == "!bf" and leader == self.playerName then
		if channel == "RAID" or channel == "RAID_LEADER" then
			outChannel = "ra"
		elseif channel == "PARTY" or channel == "PARTY_LEADER" then
			outChannel = "p"
		elseif channel == "GUILD" then
			outChannel = "g"
		end
		BirdFacts:SlashCommand(outChannel)
	end
end

function BirdFacts:GROUP_ROSTER_UPDATE()
	if not BirdFacts:IsLeaderInGroup() then
		BirdFacts:BroadcastLead(self.playerName)
	end
end

function BirdFacts:IsLeaderInGroup()
	local leader = self.db.profile.leader
	if self.playerName == leader then
		return true
	elseif IsInGroup() then
		if not IsInRaid() then
			for i = 1, GetNumSubgroupMembers() do
				if leader == UnitName(partyUnit[i]) and UnitIsConnected(partyUnit[i]) then
					return true
				end
			end
		else
			for i = 1, GetNumGroupMembers() do
				if leader == UnitName(raidUnit[i]) and UnitIsConnected(raidUnit[i]) then
					return true
				end
			end
		end
	end
end

function BirdFacts:GetFact()
	local rf = self.db.profile.realFake
	local out = ""
	if rf == "REAL" then
		out = bFacts.fact[math.random(1, #bFacts.fact)]
	elseif rf == "FAKE" then
		out = bFacts.fake[math.random(1, #bFacts.fake)]
	elseif rf == "BOTH" then
		local bothFactsLength = #bFacts.fact + #bFacts.fake
		local num = math.random(1, bothFactsLength)
		if num < #bFacts.fact then
			out = bFacts.fact[math.random(1, #bFacts.fact)]
		elseif num > #bFacts.fact then
			out = bFacts.fake[math.random(1, #bFacts.fake)]
		end
	end
	return out
end

function BirdFacts:OnCommReceived(prefix, message, distribution, sender)
	--BirdFacts:Print("pre comm receive" .. self.db.profile.leader)
	if prefix ~= BirdFacts._commPrefix or sender == self.playerName then
		return
	end
	if distribution == "PARTY" or distribution == "RAID" then
		self.db.profile.leader = message
	end
	--BirdFacts:Print("post comm receive" .. self.db.profile.leader)
end

function BirdFacts:BroadcastLead(playerName)
	local leader = playerName
	self.db.profile.leader = leader

	--if player is in party but not a raid, do one thing, if player is in raid, do another
	local commDistro = ""
	if IsInGroup() then
		if IsInRaid() then
			commDistro = "RAID"
		else
			commDistro = "PARTY"
		end
	end
	BirdFacts:SendCommMessage(BirdFacts._commPrefix, leader, commDistro)
	--BirdFacts:Print("Leader is " .. leader)
end

-- slash commands and their outputs
function BirdFacts:SlashCommand(msg)
	local msg = string.lower(msg)
	local out = BirdFacts:GetFact()
	local default = self.db.profile.defaultChannel
	local defaultAuto = self.db.profile.defaultAutoChannel
	BirdFacts:BroadcastLead(self.playerName)

	local table = {
		["s"] = "SAY",
		["p"] = "PARTY",
		["g"] = "GUILD",
		["ra"] = "RAID",
		["rw"] = "RAID_WARNING",
		["y"] = "YELL",
		["bg"] = "INSTANCE_CHAT",
		["i"] = "INSTANCE_CHAT",
		["o"] = "OFFICER",
	}

	if msg == "r" then
		SendChatMessage(out, "WHISPER", nil, ChatFrame1EditBox:GetAttribute("tellTarget"))
	elseif
		msg == "s"
		or msg == "p"
		or msg == "g"
		or msg == "ra"
		or msg == "rw"
		or msg == "y"
		or msg == "bg"
		or msg == "i"
		or msg == "o"
	then
		SendChatMessage(out, table[msg])
	elseif msg == "w" or msg == "t" then
		if UnitName("target") then
			SendChatMessage(out, "WHISPER", nil, UnitName("target"))
		else
			SendChatMessage(out, default)
		end
	elseif msg == "1" or msg == "2" or msg == "3" or msg == "4" or msg == "5" then
		SendChatMessage(out, "CHANNEL", nil, msg)
	elseif msg == "opt" or msg == "options" then
		Settings.OpenToCategory(addOnName)
	elseif msg == "auto" then
		SendChatMessage(out, defaultAuto)
	elseif msg ~= "" or msg == "help" then
		BirdFacts:factError()
	else
		if default == "1" or default == "2" or default == "3" or default == "4" or default == "5" then
			SendChatMessage(out, "CHANNEL", nil, default)
		else
			SendChatMessage(out, default)
		end
	end
end

-- error message
function BirdFacts:factError()
	BirdFacts:Print("'/bf s' to send a fact to /say")
	BirdFacts:Print("'/bf p' to send a fact to /party")
	BirdFacts:Print("'/bf g' to send a fact to /guild")
	BirdFacts:Print("'/bf ra' to send a fact to /raid")
	BirdFacts:Print("'/bf rw' to send a fact to /raidwarning")
	BirdFacts:Print("'/bf i' to send a fact to /instance")
	BirdFacts:Print("'/bf y' to send a fact to /yell")
	BirdFacts:Print("'/bf r' to send a fact to the last person whispered")
	BirdFacts:Print("'/bf t' to send a fact to your target")
	BirdFacts:Print("'/bf <1-5>' to send a fact to general channels")
end

function BirdFacts:TimerFeedback()
	self:Print("Type '/bf help' to view available commands or '/bf options' to view the options panel")
end
