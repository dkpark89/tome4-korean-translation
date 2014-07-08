-- ToME - Tales of Maj'Eyal
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

if not currentZone.is_collapsed then
	load("/data/general/npcs/vermin.lua", rarity(5))
	load("/data/general/npcs/rodent.lua", rarity(5))
	load("/data/general/npcs/canine.lua", rarity(6))
	load("/data/general/npcs/snake.lua", rarity(4))
	load("/data/general/npcs/ooze.lua", rarity(3))
	load("/data/general/npcs/jelly.lua", rarity(3))
	load("/data/general/npcs/ant.lua", rarity(4))
	load("/data/general/npcs/thieve.lua", rarity(0))
	load("/data/general/npcs/minotaur.lua", rarity(0))

	load("/data/general/npcs/all.lua", rarity(4, 35))
else
	load("/data/general/npcs/canine.lua", rarity(6))
	load("/data/general/npcs/snake.lua", rarity(4))
	load("/data/general/npcs/ooze.lua", rarity(3))
	load("/data/general/npcs/jelly.lua", rarity(3))
	load("/data/general/npcs/thieve.lua", rarity(0))
	load("/data/general/npcs/horror-corrupted.lua", rarity(0))
	load("/data/general/npcs/horror_temporal.lua", rarity(1))

	load("/data/general/npcs/all.lua", rarity(4, 35))
end

local Talents = require("engine.interface.ActorTalents")

-- The boss of the maze, no "rarity" field means it will not be randomly generated
newEntity{ define_as = "HORNED_HORROR",
	allow_infinite_dungeon = true,
	type = "horror", subtype = "corrupted", unique = true,
	name = "Horned Horror",
	kr_name = "뿔 달린 공포",
	display = "h", color=colors.VIOLET,
	resolvers.nice_tile{image="invis.png", add_mos = {{image="npc/horror_corrupted_horner_horror.png", display_h=2, display_y=-1}}},
	desc = [[어떤 끔찍한 힘이 이 난폭한 미노타우르스를 보다 공포스러운 존재로 만들었습니다. 거대한 촉수가 이 존재의 뒤에서 파도치고 있으며, 그 강력한 주먹을 쥐었다 폈다 하고 있습니다.]],
	killer_message = "당신은 이성이 없는 공포로 되살아났습니다.",
	level_range = {12, nil}, exp_worth = 2,
	max_life = 250, life_rating = 17, fixed_rating = true,
	stats = { str=20, dex=20, cun=20, mag=10, wil=10, con=20 },
	rank = 4,
	size_category = 4,
	infravision = 10,
	move_others=true,
	instakill_immune = 1,
	blind_immune = 1,
	no_breath = 1,

	body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1, HANDS=1, },
	resolvers.equip{
		{type="armor", subtype="hands", defined="STORM_BRINGER_GAUNTLETS", random_art_replace={chance=75}, autoreq=true},
	},
	resolvers.drops{chance=100, nb=5, {tome_drops="boss"} },

	combat_mindpower = 20,
	resolvers.talents{
		[Talents.T_ARMOUR_TRAINING]={base=3, every=9, max=4},
		[Talents.T_UNARMED_MASTERY]={base=2, every=6, max=5},
		[Talents.T_UPPERCUT]={base=2, every=6, max=5},
		[Talents.T_DOUBLE_STRIKE]={base=2, every=6, max=5},
		[Talents.T_SPINNING_BACKHAND]={base=1, every=6, max=5},
		[Talents.T_FLURRY_OF_FISTS]={base=1, every=6, max=5},
		[Talents.T_VITALITY]={base=2, every=6, max=5},
		[Talents.T_TENTACLE_GRAB]={base=1, every=6, max=5},
	},

	autolevel = "warrior",
	ai = "tactical", ai_state = { talent_in=1, ai_move="move_astar", },
	ai_tactic = resolvers.tactic"melee",
	resolvers.inscriptions(2, {"invisibility rune", "lightning rune"}),

	on_die = function(self, who)
		game.state:activateBackupGuardian("NIMISIL", 2, 40, "자네, 서쪽의 미궁에서 정찰대들이 자꾸 사라진다는 소식 들었나?")
		game.player:resolveSource():grantQuest("starter-zones")
		game.player:resolveSource():setQuestStatus("starter-zones", engine.Quest.COMPLETED, "maze")
		game.player:resolveSource():setQuestStatus("starter-zones", engine.Quest.COMPLETED, "maze-horror")
	end,
}

-- The boss of the maze, no "rarity" field means it will not be randomly generated
newEntity{ define_as = "MINOTAUR_MAZE",
	allow_infinite_dungeon = true,
	type = "giant", subtype = "minotaur", unique = true,
	name = "Minotaur of the Labyrinth",
	kr_name = "미궁의 미노타우르스",
	display = "H", color=colors.VIOLET,
	resolvers.nice_tile{image="invis.png", add_mos = {{image="npc/giant_minotaur_minotaur_of_the_labyrinth.png", display_h=2, display_y=-1}}},
	desc = [[소의 머리를 가진, 무시무시한 괴물입니다. 강력한 도끼를 휘두르며, 그와 마주치는 모두에게 저주를 퍼붓습니다.]],
	killer_message = "당신은 벽에 달린 가시에 장식용으로 매달렸습니다.",
	level_range = {12, nil}, exp_worth = 2,
	max_life = 250, life_rating = 17, fixed_rating = true,
	max_stamina = 200,
	stats = { str=25, dex=10, cun=8, mag=20, wil=20, con=20 },
	rank = 4,
	size_category = 4,
	infravision = 10,
	move_others=true,
	instakill_immune = 1,

	body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1, HEAD=1, },
	resolvers.equip{
		{type="weapon", subtype="battleaxe", force_drop=true, tome_drops="boss", autoreq=true},
		{type="armor", subtype="head", defined="HELM_OF_GARKUL", random_art_replace={chance=75}, autoreq=true},
	},
	resolvers.drops{chance=100, nb=5, {tome_drops="boss"} },

	resolvers.talents{
		[Talents.T_ARMOUR_TRAINING]={base=1, every=9, max=4},
		[Talents.T_STAMINA_POOL]={base=1, every=6, max=5},
		[Talents.T_WARSHOUT]={base=1, every=6, max=5},
		[Talents.T_STUNNING_BLOW]={base=1, every=6, max=5},
		[Talents.T_SUNDER_ARMOUR]={base=1, every=6, max=5},
		[Talents.T_SUNDER_ARMS]={base=1, every=6, max=5},
		[Talents.T_CRUSH]={base=1, every=6, max=5},
	},

	autolevel = "warrior",
	ai = "tactical", ai_state = { talent_in=1, ai_move="move_astar", },
	ai_tactic = resolvers.tactic"melee",
	resolvers.inscriptions(2, "infusion"),

	on_die = function(self, who)
		game.state:activateBackupGuardian("NIMISIL", 2, 40, "자네, 서쪽의 미궁에서 정찰대들이 자꾸 사라진다는 소식 들었나?")
		game.player:resolveSource():grantQuest("starter-zones")
		game.player:resolveSource():setQuestStatus("starter-zones", engine.Quest.COMPLETED, "maze")
	end,
}

newEntity{ base = "BASE_NPC_SPIDER", define_as = "NIMISIL",
	unique = true,
	allow_infinite_dungeon = true,
	name = "Nimisil", color=colors.VIOLET,
	kr_name = "니미실",
	desc = [[스스로 빛을 내는 털과 돌기로 덮힌 이 으스스한 거미는, 미궁의 조용한 통로에서 주로 출몰합니다.]],
	level_range = {43, nil}, exp_worth = 3,
	max_life = 520, life_rating = 21, fixed_rating = true,
	rank = 4,
	negative_regen = 40,
	positive_regen = 40,

	move_others=true,
	instakill_immune = 1,

	resolvers.drops{chance=100, nb=5, {tome_drops="boss"} },
	resolvers.drops{chance=100, nb=1, {defined="LUNAR_SHIELD", random_art_replace={chance=75}} },

	combat_armor = 25, combat_def = 33,

	combat = {dam=80, atk=30, apr=15, dammod={mag=1.1}, damtype=DamageType.ARCANE},

	autolevel = "caster",
	ai = "tactical", ai_state = { talent_in=1, ai_move="move_astar", },
	resolvers.inscriptions(5, {}),
	inc_damage = {all=40},

	resolvers.talents{
		[Talents.T_SPIDER_WEB]={base=5, every=5, max=7},
		[Talents.T_LAY_WEB]={base=5, every=5, max=7},
		[Talents.T_PHASE_DOOR]={base=5, every=5, max=7},

		[Talents.T_HYMN_OF_MOONLIGHT]={base=5, every=5, max=7},
		[Talents.T_MOONLIGHT_RAY]={base=5, every=5, max=7},
		[Talents.T_SHADOW_BLAST]={base=5, every=5, max=7},

		[Talents.T_SEARING_LIGHT]={base=5, every=5, max=7},
	},
}
