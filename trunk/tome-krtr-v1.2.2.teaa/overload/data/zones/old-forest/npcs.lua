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

if not currentZone.is_crystaline then
	load("/data/general/npcs/bear.lua", rarity(1))
	load("/data/general/npcs/vermin.lua", rarity(3))
	load("/data/general/npcs/canine.lua", rarity(0))
	load("/data/general/npcs/snake.lua", rarity(0))
	load("/data/general/npcs/swarm.lua", rarity(1))
	load("/data/general/npcs/plant.lua", rarity(0))
	load("/data/general/npcs/ant.lua", rarity(2))

	load("/data/general/npcs/all.lua", rarity(4, 35))
else
	load("/data/general/npcs/crystal.lua", rarity(0))
	load("/data/general/npcs/bear.lua", rarity(1))
	load("/data/general/npcs/vermin.lua", rarity(3))
	load("/data/general/npcs/swarm.lua", rarity(1))
	load("/data/general/npcs/plant.lua", rarity(0))
	load("/data/general/npcs/ant.lua", rarity(2))

	load("/data/general/npcs/all.lua", rarity(4, 35))
end

local Talents = require("engine.interface.ActorTalents")

newEntity{ define_as = "SHARDSKIN",
	allow_infinite_dungeon = true,
	type = "giant", subtype = "crystal", unique = true,
	name = "Shardskin",
	kr_name = "수정의 외피",
	display = "%", color=colors.VIOLET,
	image = "npc/immovable_crystal_golden_crystal.png",
	desc = [[사악한 기운이 흐르고 있는 수정화된 구조체로, 수정으로 덮인 표면 안에서는 한때 거대한 나무였던 존재의 흔적을 발견할 수 있습니다.]],
	killer_message = "당신은 수정화된 구조체와 융합되었습니다.",
	level_range = {12, nil}, exp_worth = 2,
	max_life = 200, life_rating = 17, fixed_rating = true,
	stats = { str=15, dex=10, cun=8, mag=20, wil=20, con=20 },
	rank = 4,
	vim_regen = 5,
	size_category = 5,
	infravision = 10,
	instakill_immune = 1,
	move_others=true,

	combat = { dam=resolvers.levelup(27, 1, 0.8), atk=10, apr=0, dammod={mag=1.2}, sound="actions/melee_thud" },

	resists = { [DamageType.NATURE] = -50 },

	body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1 },
	resolvers.equip{ {type="weapon", subtype="staff", defined="CRYSTAL_SHARD", random_art_replace={chance=75}, autoreq=true}, },
	resolvers.drops{chance=100, nb=5, {tome_drops="boss"} },

	resolvers.talents{
		[Talents.T_ARMOUR_TRAINING]={base=4, every=5, max=15},
		[Talents.T_FIRE_STORM]={base=1, every=6, max=6},
		[Talents.T_BLOOD_SPRAY]={base=1, every=6, max=6},
		[Talents.T_BONE_GRAB]={base=1, every=6, max=6},
		[Talents.T_FLAME]={base=1, every=6, max=6},
	},
	inc_damage = { [DamageType.BLIGHT] = -40, [DamageType.FIRE] = -20 },

	autolevel = "caster",
	ai = "tactical", ai_state = { talent_in=1, ai_move="move_astar", },
	ai_tactic = resolvers.tactic"ranged",
	resolvers.inscriptions(1, "rune"),

	on_die = function(self, who)
		game.state:activateBackupGuardian("SNAPROOT", 3, 50, "오래된 숲에, 새로운 악이 나타났다고 하는군!")
		game.player:resolveSource():grantQuest("starter-zones")
		game.player:resolveSource():setQuestStatus("starter-zones", engine.Quest.COMPLETED, "old-forest")
		game.player:resolveSource():setQuestStatus("starter-zones", engine.Quest.COMPLETED, "old-forest-crystal")
	end,
}


newEntity{ define_as = "WRATHROOT",
	allow_infinite_dungeon = true,
	type = "giant", subtype = "treant", unique = true,
	name = "Wrathroot",
	kr_name = "분노의 뿌리",
	display = "#", color=colors.VIOLET,
	resolvers.nice_tile{image="invis.png", add_mos = {{image="npc/giant_treant_wrathroot.png", display_h=2, display_y=-1}}},
	desc = [[오래된 숲의 지도자이며 고대의 회색 버드나무로, 그는 그의 영역을 불법으로 침입한 자들을 경멸합니다.]],
	sound_moam = "creatures/treant/treeant_2",
	sound_die = {"creatures/treant/treeant_death_%d", 1, 2},
	sound_random = {"creatures/treant/treeant_%d", 1, 3},
	killer_message = "당신은 나무의 양분이 되었습니다.",
	level_range = {12, nil}, exp_worth = 2,
	max_life = 200, life_rating = 17, fixed_rating = true,
	max_stamina = 85,
	max_mana = 200,
	stats = { str=25, dex=10, cun=8, mag=20, wil=20, con=20 },
	rank = 4,
	size_category = 5,
	infravision = 10,
	instakill_immune = 1,
	move_others=true,

	combat = { dam=resolvers.levelup(27, 1, 0.8), atk=10, apr=0, dammod={str=1.2}, sound="actions/melee_thud" },

	resists = { [DamageType.FIRE] = -50 },

	body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1 },
	resolvers.equip{ {type="armor", subtype="shield", defined="WRATHROOT_SHIELD", random_art_replace={chance=75}, autoreq=true}, },
	resolvers.drops{chance=100, nb=5, {tome_drops="boss"} },

	resolvers.talents{
		[Talents.T_ARMOUR_TRAINING]={base=4, every=5, max=15},
		[Talents.T_STUN]={base=2, every=6, max=6},
		[Talents.T_ICE_STORM]={base=1, every=6, max=6},
		[Talents.T_TIDAL_WAVE]={base=1, every=6, max=6},
		[Talents.T_FREEZE]={base=2, every=6, max=6},
	},

	autolevel = "caster",
	ai = "tactical", ai_state = { talent_in=1, ai_move="move_astar", },
	ai_tactic = resolvers.tactic"melee",
	resolvers.inscriptions(1, "infusion"),

	on_die = function(self, who)
		game.state:activateBackupGuardian("SNAPROOT", 3, 50, "오래된 숲에, 새로운 악이 나타났다고 하는군!")
		game.player:resolveSource():grantQuest("starter-zones")
		game.player:resolveSource():setQuestStatus("starter-zones", engine.Quest.COMPLETED, "old-forest")
	end,
}


newEntity{ base = "BASE_NPC_RODENT",
	allow_infinite_dungeon = true,
	name = "cute little bunny", color=colors.SALMON,
	kr_name = "작고 귀여운 토끼",
	desc = [[이 토끼는 작고 귀여운 눈으로 당신을 쳐다보고서는, 날카로운 이빨을 벌리고 당신에게 뛰어오릅니다.]],
	killer_message = "(이 얼마나 불쌍한지고!)",
	level_range = {1, 15}, exp_worth = 3,
	rarity = 200,
	max_life = resolvers.rngavg(15,20),
	combat = { dam=50, atk=15, apr=10 },
	combat_armor = 1, combat_def = 20,
}

newEntity{ define_as = "SNAPROOT", -- backup guardian
	allow_infinite_dungeon = true,
	type = "giant", subtype = "treant", unique = true,
	name = "Snaproot",
	kr_name = "부러진 뿌리",
	display = "#", color=VIOLET,
	sound_moam = "creatures/treants/treeant_2",
	sound_die = {"creatures/treants/treeant_death_%d", 1, 2},
	sound_random = {"creatures/treants/treeant_%d", 1, 3},
	resolvers.nice_tile{image="invis.png", add_mos = {{image="npc/giant_treant_snaproot.png", display_h=2, display_y=-1}}},
	desc = [[이 고대 나무 정령의 나무껍질은 거의 시커멓게 시들어 있습니다. 이것은 인간과 같이 이족보행하는 존재들을, 정화되어야 할 재앙으로 보고 있습니다.]],
	level_range = {50, nil}, exp_worth = 3,

	max_life = 1000, life_rating = 40, fixed_rating = true,
	max_stamina = 200,

	combat = { dam=100, atk=10, apr=0, dammod={str=1.2}, sound="actions/melee_thud" },

	stats = { str=40, dex=10, cun=15, mag=20, wil=38, con=45 },

	rank = 4,
	size_category = 5,
	infravision = 10,
	instakill_immune = 1,
	stun_immune = 1,
	move_others = true,

	resists = { [DamageType.FIRE] = -20, [DamageType.PHYSICAL] = 50, [DamageType.COLD] = 50, [DamageType.NATURE] = 25 },
	body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1 },
	resolvers.drops{chance=100, nb=1, {defined="PETRIFIED_WOOD", random_art_replace={chance=75}}},
	resolvers.drops{chance=100, nb=5, {tome_drops="boss"} },

	resolvers.talents{
		[Talents.T_STUN]=5,
		[Talents.T_GRAB]=5,
		[Talents.T_THROW_BOULDER]=5,
		[Talents.T_CRUSH]=5,
		[Talents.T_TITAN_S_SMASH] = 1, 
		[Talents.T_MASSIVE_BLOW] = 1, 
	},
	autolevel = "warriorwill",
	ai = "tactical", ai_state = { talent_in=2, ai_move="move_astar", },
	ai_tactic = resolvers.tactic"melee",
	resolvers.inscriptions(6, "infusion"),
}
