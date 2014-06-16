﻿-- ToME - Tales of Maj'Eyal
-- Copyright (C) 2009 - 2014 Nicolas Casalini
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

load("/data/general/npcs/orc.lua", rarity(3))
load("/data/general/npcs/orc-vor.lua", rarity(0))
load("/data/general/npcs/bone-giant.lua", function(e) if e.rarity then e.bonegiant_rarity = e.rarity; e.rarity = nil end end)

load("/data/general/npcs/all.lua", rarity(4, 35))

local Talents = require("engine.interface.ActorTalents")

newEntity{ base="BASE_NPC_ORC_VOR", define_as = "VOR",
	allow_infinite_dungeon = true,
	name = "Vor, Grand Geomancer of the Pride", color=colors.VIOLET, unique = true,
	kr_name = "오크 긍지의 위대한 대지술사, 보르",
	desc = [[늙은 오크로, 다양한 색이 섞인 로브를 입고 있습니다. 얼음 파편이 그의 주변을 날아다니고, 그 궤적으로 불이 타오르며 번개가 분출됩니다.]],
	killer_message = "당신은 견습 마법사들의 표적이 되었습니다.",
	level_range = {40, nil}, exp_worth = 1,
	rank = 5,
	max_life = 250, life_rating = 19, fixed_rating = true,
	infravision = 10,
	stats = { str=12, dex=10, cun=12, mag=21, con=14 },
	move_others=true,

	combat_armor = 10, combat_def = 10,

	open_door = true,

	autolevel = "caster",
	ai = "tactical", ai_state = { talent_in=1, ai_move="move_astar", },
	ai_tactic = resolvers.tactic"ranged",
	resolvers.inscriptions(1, {"manasurge rune"}),
	resolvers.inscriptions(4, "rune"),
	max_inscriptions = 5,

	body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1, HEAD=1 },

	resolvers.equip{
		{type="weapon", subtype="staff", force_drop=true, tome_drops="boss", forbid_power_source={antimagic=true}, autoreq=true},
		{type="armor", subtype="cloth", force_drop=true, tome_drops="boss", forbid_power_source={antimagic=true}, autoreq=true},
		{type="armor", subtype="head", defined="CROWN_ELEMENTS", random_art_replace={chance=75}, autoreq=true},
	},
	resolvers.drops{chance=100, nb=1, {defined="ORB_ELEMENTS"} },
	resolvers.drops{chance=20, nb=1, {defined="JEWELER_TOME"} },
	resolvers.drops{chance=100, nb=1, {defined="NOTE_LORE"} },
	resolvers.drops{chance=100, nb=5, {tome_drops="boss"} },

	in_damages = {all=25},

	resolvers.talents{
		[Talents.T_FLAME]={base=5, every=7, max=7},
		[Talents.T_FLAMESHOCK]={base=5, every=7, max=7},
		[Talents.T_FIREFLASH]={base=5, every=7, max=7},
		[Talents.T_INFERNO]={base=5, every=7, max=7},
		[Talents.T_BLASTWAVE]={base=5, every=7, max=7},
		[Talents.T_CLEANSING_FLAMES]={base=5, every=7, max=7},
		[Talents.T_BURNING_WAKE]={base=5, every=7, max=7},

		[Talents.T_FREEZE]={base=5, every=7, max=7},
		[Talents.T_ICE_STORM]={base=5, every=7, max=7},
		[Talents.T_TIDAL_WAVE]={base=5, every=7, max=7},
		[Talents.T_ICE_SHARDS]={base=5, every=7, max=7},
		[Talents.T_FROZEN_GROUND]={base=5, every=7, max=7},

		[Talents.T_LIGHTNING]={base=5, every=7, max=7},
		[Talents.T_CHAIN_LIGHTNING]={base=5, every=7, max=7},

		[Talents.T_SPELLCRAFT]={base=5, every=7, max=7},
		[Talents.T_ESSENCE_OF_SPEED]={base=1, every=6, max=7},

		[Talents.T_METEORIC_CRASH]=1,
		[Talents.T_ELEMENTAL_SURGE]=1,
	},
	resolvers.sustains_at_birth(),

	on_die = function(self, who)
		game.player:resolveSource():setQuestStatus("orc-pride", engine.Quest.COMPLETED, "vor")
		if not game.player:hasQuest("pre-charred-scar") then
			game.player:grantQuest("pre-charred-scar")
		end
	end,
}
