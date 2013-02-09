-- ToME - Tales of Maj'Eyal
-- Copyright (C) 2009, 2010, 2011, 2012 Nicolas Casalini
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

load("/data/general/npcs/all.lua", rarity(0))

local Talents = require("engine.interface.ActorTalents")

newEntity{ base = "BASE_NPC_SKELETON", define_as = "TUTORIAL_NPC_MAGE", image="npc/skeleton_mage.png",
	name = "skeleton mage", color=colors.LIGHT_RED,
	kr_display_name = "스켈레톤 마법사",
	level_range = {1, nil}, exp_worth = 1,
	max_life = resolvers.rngavg(50,60),
	max_mana = resolvers.rngavg(70,80),
	combat_armor = 3, combat_def = 1,
	stats = { str=10, dex=12, cun=14, mag=14, con=10 },
	resolvers.talents{ [Talents.T_MANATHRUST]=3 },

	resolvers.equip{ {type="weapon", subtype="staff", forbid_power_source={antimagic=true}, autoreq=true} },

	autolevel = "caster",
	ai = "dumb_talented_simple", ai_state = { talent_in=1, },
}

newEntity{ base = "BASE_NPC_TROLL", define_as = "TUTORIAL_NPC_TROLL",
	name = "half-dead forest troll", color=colors.YELLOW_GREEN,
	kr_display_name = "반죽어있는 숲 트롤",
	desc = [[못 생겼고 녹색 피부를 가진, 이 거대한 영장류는 사마귀로 덮힌 녹색 주먹을 꽉 쥐고 당신을 쳐다보고 있습니다.
지금 많이 다친 상태로 보입니다.]],
	level_range = {1, nil}, exp_worth = 1,
	max_life = resolvers.rngavg(10,20),
	combat_armor = 3, combat_def = 0,
}

newEntity{ base = "BASE_NPC_CANINE", define_as = "TUTORIAL_NPC_LONE_WOLF",
	name = "Lone Wolf", color=colors.VIOLET, unique=true,
	kr_display_name = "외로운 한 마리 늑대",
	resolvers.nice_tile{image="invis.png", add_mos = {{image="npc/animal_canine_lone_wolf.png", display_h=2, display_y=-1}}},
	desc = [[보통의 늑대보다 3배 밖에 크지 않은, 교활함으로 가득찬 눈을 가진 커다란 늑대입니다. 배가 고파 보입니다. 당신이 맛있게 보이나 본데요!]],
	level_range = {3, nil}, exp_worth = 2,
	rank = 4,
	size_category = 4,
	max_life = 220,
	combat_armor = 8, combat_def = 0,
	combat = { dam=20, atk=15, apr=4 },
	no_rod_recall = 1,

	stats = { str=25, dex=20, cun=15, mag=10, con=15 },

	resolvers.talents{
		[Talents.T_GLOOM]=1,
		[Talents.T_RUSH]=1,
		[Talents.T_CRIPPLE]=1,
	},
	resolvers.sustains_at_birth(),

	ai = "dumb_talented_simple", ai_state = { talent_in=4, ai_move="move_astar", },

	on_die = function(self, who)
		game.player:resolveSource():setQuestStatus("tutorial", engine.Quest.COMPLETED)
		local d = require("engine.dialogs.ShowText").new("연습게임: 완료", "tutorial/done")
		game:registerDialog(d)
	end,
}
