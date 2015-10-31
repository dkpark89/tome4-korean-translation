-- ToME - Tales of Maj'Eyal
-- Copyright (C) 2009 - 2015 Nicolas Casalini
--
-- This program is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.
--
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
--
-- You should have received a copy of the GNU General Public License
-- along with this program.  If not, see <http://www.gnu.org/licenses/>.
--
-- Nicolas Casalini "DarkGod"
-- darkgod@te4.org

load("/data/general/npcs/jelly.lua")
load("/data/general/npcs/ooze.lua")
load("/data/general/npcs/mold.lua")
load("/data/general/npcs/slime.lua")
load("/data/general/npcs/ogre.lua", switchRarity("special_rarity"))

local Talents = require("engine.interface.ActorTalents")

newEntity{
	define_as = "BASE_NPC_VAT", name = "old vats",
	type = "structure", subtype = "vat",
	display = "*", color=colors.GREEN,
	rank = 2,
	size_category = 4,

	defineDisplayCallback = function() end,
	on_added_to_level = function(self)
		self:setEffect(self.EFF_AEONS_STASIS, 1, {})
	end,
	tooltip = function(self, x, y) return mod.class.Grid.tooltip(self, x, y) end,
}

newEntity{
	base = "BASE_NPC_VAT", define_as = "VAT1",
	image = "terrain/ruins/vat_01.png",
	resolvers.nice_tile{tall=1},
	level_range = {1, nil}, exp_worth = 0,
	vat_rarity = 1,
	to_vat = "VAT1",
}

newEntity{
	base = "BASE_NPC_VAT", define_as = "VAT2",
	image = "terrain/ruins/vat_02.png",
	resolvers.nice_tile{tall=1},
	level_range = {1, nil}, exp_worth = 0,
	vat_rarity = 1,
	to_vat = "VAT2",
}


newEntity{ base = "BASE_NPC_OGRE",
	name = "degenerated ogric mass", color=colors.BLUE,
	desc = [[This huge mass of deformed flesh was probably once an ogre, but something had gone wrong.]],
	resolvers.nice_tile{tall=1},
	level_range = {20, nil}, exp_worth = 1,
	special_rarity = 2,
	rank = 2,
	max_life = resolvers.rngavg(110,120), life_rating = 13,

	resolvers.equip{{type="weapon", subtype="greatmaul", forbid_power_source={antimagic=true}, autoreq=true} },
	resolvers.talents{
		[Talents.T_EPIDEMIC]={base=3, every=4, max=8},
		[Talents.T_ROTTING_DISEASE]={base=3, every=4, max=8},
		[Talents.T_WEAPON_COMBAT]={base=3, every=4, max=7},
		[Talents.T_CATALEPSY]={base=4, every=5, max=7},
	},
}

newEntity{ base = "BASE_NPC_OGRE",
	name = "ogric abomination", color=colors.LIGHT_GREY,
	desc = [[This ogre seems to have tried to graft golem parts on its own body. To various interresting results.]],
	resolvers.nice_tile{tall=1},
	level_range = {22, nil}, exp_worth = 1,
	special_rarity = 4,
	rank = 3,
	max_life = resolvers.rngavg(110,120), life_rating = 13,

	resolvers.equip{{type="weapon", subtype="greatmaul", forbid_power_source={antimagic=true}, autoreq=true} },
	resolvers.talents{
		[Talents.T_GOLEM_CRUSH]={base=3, every=4, max=8},
		[Talents.T_GOLEM_KNOCKBACK]={base=3, every=4, max=8},
		[Talents.T_GOLEM_POUND]={base=3, every=4, max=8},
		[Talents.T_GOLEM_REFLECTIVE_SKIN]={base=3, every=4, max=8},
		[Talents.T_WEAPON_COMBAT]={base=3, every=4, max=7},
		[Talents.T_WEAPONS_MASTERY]={base=4, every=5, max=7},
	},
}


------------- Non random

newEntity{ base = "BASE_NPC_OGRE", define_as = "OGRE_SENTRY",
	name = "ogre sentry", color=colors.GREY,
	resolvers.nice_tile{tall=1},
	desc = [[This greatsword-wielding ogre looks at you with contempt and hatred.]],
	level_range = {21, nil}, exp_worth = 1,
	rank = 3,
	max_life = resolvers.rngavg(110,120), life_rating = 13,
	blind_immune = 1,

	resolvers.equip{{type="weapon", subtype="greatsword", forbid_power_source={antimagic=true}, autoreq=true} },
	resolvers.talents{
		[Talents.T_STUNNING_BLOW]={base=3, every=4, max=8},
		[Talents.T_WEAPON_COMBAT]={base=3, every=4, max=7},
		[Talents.T_WEAPONS_MASTERY]={base=4, every=5, max=7},
		[Talents.T_ILLUMINATE]={base=3, every=5, max=7},
	},

	seen_by = function(self, who)
		if not game.party:hasMember(who) then return end
		self.seen_by = nil
		self:removeEffect(self.EFF_AEONS_STASIS, nil, true)
	end,
}

newEntity{ base = "OGRE_SENTRY", define_as = "OGRE_SENTRY2",
	seen_by = function(self, who)
		if not game.party:hasMember(who) then return end
		self.seen_by = nil
		self:removeEffect(self.EFF_AEONS_STASIS, nil, true)

		local Chat = require "engine.Chat"
		local chat = Chat.new("conclave-vault-greeting", self, who)
		chat:invoke()
	end,
}


newEntity{ base = "BASE_NPC_OGRE", define_as = "HEALER_ASTELRID",
	name = "Healer Astelrid", color=colors.VIOLET,
	resolvers.nice_tile{tall=1},
	desc = [[An enormous ogre, clad in a tattered set of robes with an officer's badge.  She clutches a healer's staff, wrapped in casting plaster and scalpels for use as a massive spiked club.]],
	killer_message = "and spliced for experiments",
	level_range = {23, nil}, exp_worth = 2,
	female = 1,
	rank = 4,
	max_life = 170, life_rating = 14, fixed_rating = true,

	stats = { str=20, dex=10, cun=8, mag=25, con=20 },
	instakill_immune = 1,
	move_others=true,

	body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1, TOOL=1 },
	resolvers.equip{
		{defined="ASTELRID_CLUBSTAFF"},
		{type="armor", subtype="cloth", forbid_power_source={antimagic=true}, force_drop=true, tome_drops="boss", autoreq=true},
		{type="armor", subtype="head", forbid_power_source={antimagic=true}, force_drop=true, tome_drops="boss", autoreq=true},
		{type="armor", subtype="feet", forbid_power_source={antimagic=true}, force_drop=true, tome_drops="boss", autoreq=true},
	},
	resolvers.drops{chance=100, nb=1, {defined="NOTE4"} },
	resolvers.drops{chance=100, nb=3, {tome_drops="boss"} },

	resolvers.talents{
		[Talents.T_HEAL]={base=3, every=4, max=8},
		[Talents.T_ARCANE_SHIELD]={base=3, every=4, max=8},
		[Talents.T_AEGIS]={base=3, every=4, max=8},
		[Talents.T_EARTHQUAKE]={base=3, every=4, max=8},
		[Talents.T_RUSH]={base=3, every=4, max=8},
		[Talents.T_STUNNING_BLOW]={base=3, every=4, max=8},
		[Talents.T_LIVING_LIGHTNING]={base=3, every=4, max=8},
	},
	resolvers.inscriptions(2, "rune"),
	resolvers.inscriptions(2, "infusion"),

	autolevel = "warriormage",
	ai = "tactical", ai_state = { talent_in=1, ai_move="move_astar", },
}
