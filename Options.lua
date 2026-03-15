local addOnName, bFacts = ...

_G["bFacts"] = bFacts

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
				name = "                |cFF36F7BC"
					.. "Bird Facts: v"
					.. BirdFacts.GetAddOnMetadata("BirdFacts", "Version"),
			},
			authorText = {
				type = "description",
				fontSize = "medium",
				order = 2,
				name = "|TInterface\\AddOns\\BirdFacts\\Media\\Icon64:64:64:0:20|t |cFFFFFFFFMade with love by |cFFC41E3AShadowcrankr-Nightslayer|r \n |cFFFFFFFFMake sure to check out AnimalFacts on Curse for facts about more animals!",
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
						desc = "Pick from having the option to only have real bird facts, facts about World of Warcraft birds, or both",
						order = 1.2,
						values = {
							["REAL"] = "Only real facts",
							["WOW"] = "Only World of Warcraft bird facts",
							["BOTH"] = "Both real and World of Warcraft facts",
						},
						get = function()
							return self.db.profile.realFake
						end,
						set = function(_, value)
							self.db.profile.realFake = value
							BirdFacts:OutputFactTimer()
						end,
					},
					repeatCheck = {
						type = "range",
						name = "Repeat frequency",
						order = 1.3,
						desc = "Set the frequency for how often a fact repeats. ie. If set to 50, a fact will not repeat for the next 50 facts",
						min = 0,
						max = 100,
						step = 10,
						get = function()
							return self.db.profile.maxFactRepeat
						end,
						set = function(_, value)
							self.db.profile.maxFactRepeat = value
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
