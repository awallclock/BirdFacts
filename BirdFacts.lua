local addOnName, bFacts = ...

-- loading ace3
BirdFacts =
	LibStub("AceAddon-3.0"):NewAddon("Bird Facts", "AceConsole-3.0", "AceTimer-3.0", "AceComm-3.0", "AceEvent-3.0")
AC = LibStub("AceConfig-3.0")
ACD = LibStub("AceConfigDialog-3.0")
_G["bFacts"] = bFacts
BirdFacts.GetAddOnMetadata = C_AddOns and C_AddOns.GetAddOnMetadata or GetAddOnMetadata

BirdFacts.playerGUID = UnitGUID("player")
BirdFacts.playerName = UnitName("player")
BirdFacts._commPrefix = string.upper(addOnName)

local IsInRaid, IsInGroup, IsGUIDInGroup, isOnline = IsInRaid, IsInGroup, IsGUIDInGroup, isOnline
local IsInInstance, IsInGuild = IsInInstance, IsInGuild
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
			maxFactRepeat = 50,
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
	--BirdFacts:BuildOptionsPanel()
	self:ScheduleTimer("TimerFeedback", 10)
	BirdFacts:OutputFactTimer()
	--register chat events
	self:RegisterEvent("CHAT_MSG_RAID", "readChat")
	self:RegisterEvent("CHAT_MSG_PARTY", "readChat")
	self:RegisterEvent("CHAT_MSG_PARTY_LEADER", "readChat")
	self:RegisterEvent("CHAT_MSG_RAID_LEADER", "readChat")
	self:RegisterEvent("CHAT_MSG_GUILD", "readChat")
	self:RegisterEvent("CHAT_MSG_INSTANCE_CHAT", "readChat")
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
		elseif channel == "INSTANCE_CHAT" then
			outChannel = "i"
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

local List = {}
function List.new()
	return { first = 0, last = -1 }
end

function List.pushleft(list, value)
	local first = list.first - 1
	list.first = first
	list[first] = value
end

function List.pushright(list, value)
	local last = list.last + 1
	list.last = last
	list[last] = value
end

function List.popleft(list)
	local first = list.first
	if first > list.last then
		error("list is empty")
	end
	local value = list[first]
	list[first] = nil -- to allow garbage collection
	list.first = first + 1
	return value
end

function List.popright(list)
	local last = list.last
	if list.first > last then
		error("list is empty")
	end
	local value = list[last]
	list[last] = nil -- to allow garbage collection
	list.last = last - 1
	return value
end

--TODO: remove all the junk test files
function BirdFacts:DuplicateChecker(index)
	--returning true means there is a duplicate
	--returning false means there was not a duplicate
	local firstIndex = RecentlyUsedFacts["first"]
	local lastIndex = RecentlyUsedFacts["last"]
	local currentQueueLength = lastIndex - firstIndex
	local maxQueueLength = self.db.profile.maxFactRepeat
	if lastIndex < firstIndex then
		List.pushright(RecentlyUsedFacts, index)
		return false
	end
	while currentQueueLength > maxQueueLength do
		firstIndex = RecentlyUsedFacts["first"]
		lastIndex = RecentlyUsedFacts["last"]
		currentQueueLength = lastIndex - firstIndex
		List.popleft(RecentlyUsedFacts)
	end

	for i = firstIndex, lastIndex, 1 do
		if index == RecentlyUsedFacts[i] then --duplicate found
			return true
		end
	end
	List.pushright(RecentlyUsedFacts, index)
	return false
end

RecentlyUsedFacts = List.new()

function BirdFacts:GetFact()
	local rf = self.db.profile.realFake
	local duplicateLimit = self.db.profile.maxFactRepeat
	local out = ""
	local factIndex = math.random(1, #bFacts.fact)
	local wowIndex = math.random(1, #bFacts.wow)

	--check index against duplicates before grabbing fact
	--if true, re run fact grabbing
	if duplicateLimit > 0 then
		if BirdFacts:DuplicateChecker(factIndex) then
			return BirdFacts:GetFact()
		end
	end
	if rf == "REAL" then
		out = bFacts.fact[factIndex]
	elseif rf == "WOW" then
		out = bFacts.wow[wowIndex]
	elseif rf == "BOTH" then
		local bothFactsLength = #bFacts.fact + #bFacts.wow
		local num = math.random(1, bothFactsLength)
		if num < #bFacts.fact then
			out = bFacts.fact[factIndex]
		elseif num > #bFacts.fact then
			out = bFacts.wow[wowIndex]
		end
	end
	return out
end

function BirdFacts:OnCommReceived(prefix, message, distribution, sender)
	--BirdFacts:Print("pre comm receive" .. self.db.profile.leader)
	if prefix ~= BirdFacts._commPrefix or sender == self.playerName then
		return
	end
	if distribution == "PARTY" or distribution == "RAID" or distribution == "INSTANCE_CHAT" then
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
		commDistro = "PARTY"
	elseif IsInRaid() then
		commDistro = "RAID"
	elseif IsInInstance() then
		commDistro = "INSTANCE_CHAT"
	end
	BirdFacts:SendCommMessage(BirdFacts._commPrefix, leader, commDistro)
	--BirdFacts:Print("Leader is " .. leader)
end

-- slash commands and their outputs
function BirdFacts:SlashCommand(arg)
	local function findKeyFromValue(table, input)
		for key, value in pairs(table) do
			if value == input then
				return key
			end
		end
	end
	local chatChannelDict = {
		["s"] = "SAY", -- requires group
		["p"] = "PARTY", -- rquires party
		["g"] = "GUILD", -- requires guild
		["ra"] = "RAID", -- requires raid
		["rw"] = "RAID_WARNING", --requires raid and assist
		["y"] = "YELL", -- requires group
		["bg"] = "INSTANCE_CHAT", --requires being in instancej
		["i"] = "INSTANCE_CHAT", --rquires bein in instance
		["o"] = "OFFICER", --requires guild
		["r"] = "WHISPER",
		["w"] = "WHISPER",
		["t"] = "WHISPER",
		["1"] = "CHANNEL",
		["2"] = "CHANNEL",
		["3"] = "CHANNEL",
		["4"] = "CHANNEL",
		["5"] = "CHANNEL",
	}

	local msg
	local out = BirdFacts:GetFact()
	local default = findKeyFromValue(chatChannelDict, self.db.profile.defaultChannel)
	local defaultAuto = findKeyFromValue(chatChannelDict, self.db.profile.defaultAutoChannel)
	if arg == "" or arg == nil then
		msg = default
	else
		msg = string.lower(arg)
	end
	BirdFacts:BroadcastLead(self.playerName)

	if msg == "test" then
		BirdFacts:Print(out)
		return
	end

	if msg == "opt" or msg == "options" then
		BirdFacts:OpenSettings()
		return
	elseif msg == "auto" then
		BirdFacts:SlashCommand(defaultAuto)
	elseif not chatChannelDict[msg] then
		BirdFacts:Print("Not a valid command. Type '/bf opt' to view available commands.")
		return
	end

	if msg == "s" or msg == "y" then
		SendChatMessage(out, chatChannelDict[msg])
		return
	end

	if IsInGroup() then
		if msg == "p" then
			SendChatMessage(out, chatChannelDict[msg])
			return
		end
	end

	if IsInRaid() then
		if msg == "ra" or msg == "rw" then
			SendChatMessage(out, chatChannelDict[msg])
			return
		end
	end

	if IsInInstance() then
		if msg == "bg" or msg == "i" then
			SendChatMessage(out, chatChannelDict[msg])
			return
		end
	end

	if IsInGuild() then
		if msg == "g" or msg == "o" then
			SendChatMessage(out, chatChannelDict[msg])
			return
		end
	end

	if msg == "r" and ChatFrame1EditBox:GetAttribute("tellTarget") then
		SendChatMessage(out, chatChannelDict[msg], nil, ChatFrame1EditBox:GetAttribute("tellTarget"))
	elseif (msg == "w" or msg == "t") and UnitName("target") then
		if UnitName("target") then
			SendChatMessage(out, chatChannelDict[msg], nil, UnitName("target"))
		else
			SendChatMessage(out, default)
		end
	elseif msg == "1" or msg == "2" or msg == "3" or msg == "4" or msg == "5" then
		SendChatMessage(out, chatChannelDict[msg], nil, msg)
		--elseif msg == "auto" then
		--	BirdFacts:SlashCommand(defaultAuto)
		--	else
		--		if default == "1" or default == "2" or default == "3" or default == "4" or default == "5" then
		--			SendChatMessage(out, chatChannelDict[msg], nil, default)
		--		else
		--			BirdFacts:SlashCommand(default)
		--		end
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
	self:Print("Type '/bf options' to view the options/commands panel")
end
