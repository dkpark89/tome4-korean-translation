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

load("/data/general/npcs/rodent.lua", rarity(0))
load("/data/general/npcs/vermin.lua", rarity(2))
load("/data/general/npcs/ghoul.lua", rarity(3))
load("/data/general/npcs/skeleton.lua", rarity(0))
load("/data/general/npcs/bone-giant.lua", function(e) e.rarity = nil end)

local Talents = require("engine.interface.ActorTalents")

newEntity{
	define_as = "NECROMANCER",
	type = "humanoid", subtype = "human",
	display = "p", color=colors.DARK_GREY,
	name = "Necromancer", color=colors.DARK_GREY,
	kr_name = "사령술사",
	desc = [[검은 로브를 입은 인간입니다. 거슬리는 목소리로 뭔가 중얼거리고 있으며, 그는 당신이 그의 노예라고 생각하는 것 같습니다.]],
	level_range = {1, nil}, exp_worth = 1,

	combat = { dam=resolvers.rngavg(5,12), atk=2, apr=6, physspeed=2 },

	body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1, CLOAK=1, QUIVER=1 },
	resolvers.drops{chance=20, nb=1, {} },
	resolvers.drops{chance=10, nb=1, {type="money"} },
	infravision = 10,
	lite = 2,

	rank = 2,
	size_category = 2,

	open_door = true,

	autolevel = "caster",
	ai = "dumb_talented_simple", ai_state = { ai_move="move_complex", talent_in=1, },
	stats = { str=10, dex=8, mag=16, con=6 },

	max_life = resolvers.rngavg(70,80), life_rating = 7,
	resolvers.equip{
		{type="weapon", subtype="staff", forbid_power_source={antimagic=true}, autoreq=true},
		{type="armor", subtype="cloak", defined="CLOAK_DECEPTION", autoreq=true},
	},

	resolvers.talents{
		[Talents.T_SOUL_ROT]=1,
	},

	die = function(self, src)
		self.die = function() end
		local Chat = require "engine.Chat"
		local chat = Chat.new("undead-start-kill", self, game.player)
		chat:invoke()
	end,
}

newEntity{ base = "BASE_NPC_BONE_GIANT", define_as = "HALF_BONE_GIANT",
	allow_infinite_dungeon = true,
	name = "Half-Finished Bone Giant", color=colors.VIOLET, unique=true,
	kr_name = "미완성 해골 거인",
	desc = [[수백 개의 시체에서 꺼낸 뼈로 만들어진, 해골 거인입니다. 부정한 기운이 느껴집니다.
이 시험작은 급히 만들어져, 아직 완성되지 못한 것으로 보입니다.]],
	resolvers.nice_tile{image="invis.png", add_mos = {{image="npc/undead_giant_half_finished_bone_giant.png", display_h=2, display_y=-1}}},
	level_range = {7, nil}, exp_worth = 1,
	rank = 4,
	max_life = resolvers.rngavg(100,120), life_rating = 14,
	combat_armor = 7, combat_def = -3,
	melee_project = {[DamageType.BLIGHT]=resolvers.mbonus(5, 2)},
	resolvers.talents{ [Talents.T_BONE_ARMOUR]=3, [Talents.T_THROW_BONES]=1, },
	resolvers.sustains_at_birth(),
	tier1 = true,

	resolvers.drops{chance=100, nb=3, {tome_drops="boss"} },
	resolvers.drops{chance=100, nb=1, {defined="WINTERTIDE_PHIAL", random_art_replace={chance=75}} },

	ai = "tactical", ai_state = { talent_in=3, ai_move="move_astar", },
	ai_tactic = resolvers.tactic"melee",
	resolvers.inscriptions(1, "rune"),

	on_die = function(self, who)
		game.player:resolveSource():setQuestStatus("start-undead", engine.Quest.COMPLETED)
	end,
}
