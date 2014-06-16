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

load("/data/general/npcs/spider.lua", rarity(0))

load("/data/general/npcs/all.lua", rarity(4, 35))

local Talents = require("engine.interface.ActorTalents")

newEntity{ define_as = "UNGOLE", base = "BASE_NPC_SPIDER",
	allow_infinite_dungeon = true,
	name = "Ungolë", color=colors.VIOLET, unique = true,
	kr_name = "운골뢰",
	resolvers.nice_tile{image="invis.png", add_mos = {{image="npc/spiderkin_spider_ungole.png", display_h=2, display_y=-1}}},
	desc = [[어둠의 장막을 두른 거대한 거미로, 붉게 빛나는 눈은 당신을 뚫어져라 쳐다보고 있습니다. 매우 배고파 보입니다.]],
	killer_message = "당신은 태양의 기사와 함께 잡아먹혔습니다.",
	level_range = {30, nil}, exp_worth = 2,
	female = 1,
	max_life = 450, life_rating = 15, fixed_rating = true,
	stats = { str=25, dex=10, cun=47, mag=10, con=20 },
	rank = 4,
	size_category = 4,
	move_others=true,
	infravision = 10,
	instakill_immune = 1,

	combat_armor = 17, combat_def = 17,
	resists = { [DamageType.FIRE] = 20, [DamageType.ACID] = 20, [DamageType.COLD] = 20, [DamageType.LIGHTNING] = 20, },

	combat = { dam=resolvers.levelup(resolvers.rngavg(40,58), 1, 1), atk=16, apr=9, damtype=DamageType.NATURE, dammod={str=0.8} },

	body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1 },
	resolvers.drops{chance=100, nb=5, {tome_drops="boss"} },
	resolvers.drops{chance=100, nb=1, {defined="ROD_SPYDRIC_POISON"} },
	resolvers.drops{chance=100, nb=1, {unique=true} },

	resolvers.talents{
		[Talents.T_KNOCKBACK]={base=4, every=5, max=7},
		[Talents.T_DARKNESS]={base=5, every=5, max=8},
		[Talents.T_SPIT_POISON]={base=5, every=5, max=8},
		[Talents.T_SPIDER_WEB]={base=5, every=5, max=8},
		[Talents.T_LAY_WEB]={base=5, every=5, max=8},

		[Talents.T_CORROSIVE_VAPOUR]={base=5, every=5, max=8},
		[Talents.T_PHANTASMAL_SHIELD]={base=5, every=5, max=8},
	},
	resolvers.sustains_at_birth(),

	ai = "tactical", ai_state = { talent_in=1, ai_move="move_astar", },
	resolvers.inscriptions(5, "infusion"),

	on_die = function(self, who)
		local Chat = require"engine.Chat"
		local chat = Chat.new("ardhungol-end", {name="Sun Paladin Rashim", kr_name="태양의 기사 라심"}, game.player:resolveSource())
		chat:invoke()
	end,
}
