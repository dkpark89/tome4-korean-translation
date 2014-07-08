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

load("/data/general/npcs/xorn.lua", rarity(4))
load("/data/general/npcs/snow-giant.lua", rarity(0))
if not currentZone.is_volcano then
	load("/data/general/npcs/canine.lua", rarity(2))
	load("/data/general/npcs/cold-drake.lua", rarity(2))
else
	load("/data/general/npcs/fire-drake.lua", rarity(2))
	load("/data/general/npcs/faeros.lua", rarity(0))
end

load("/data/general/npcs/all.lua", rarity(4, 35))

local Talents = require("engine.interface.ActorTalents")

newEntity{ define_as = "RANTHA_THE_WORM",
	allow_infinite_dungeon = true,
	type = "dragon", subtype = "ice", unique = true,
	name = "Rantha the Worm",
	kr_name = "해츨링 수호자, 란싸",
	display = "D", color=colors.VIOLET,
	resolvers.nice_tile{image="invis.png", add_mos = {{image="npc/dragon_ice_rantha_the_worm.png", display_h=2, display_y=-1}}},
	desc = [[발톱과 이빨. 얼음과 죽음. 용은 멸종된 것이 아니었습니다...]],
	killer_message = "당신은 해츨링들의 먹잇감이 되었습니다.",
	level_range = {12, nil}, exp_worth = 2,
	max_life = 230, life_rating = 17, fixed_rating = true,
	max_stamina = 85,
	max_mana = 200,
	stats = { str=25, dex=10, cun=8, mag=20, wil=20, con=20 },
	rank = 4,
	size_category = 5,
	combat_armor = 17, combat_def = 14,
	infravision = 10,
	instakill_immune = 1,
	stun_immune = 1,
	move_others=true,

	combat = { dam=resolvers.levelup(resolvers.rngavg(25,110), 1, 2), atk=resolvers.rngavg(25,70), apr=25, dammod={str=1.1} },

	resists = { [DamageType.FIRE] = -20, [DamageType.COLD] = 100 },

	body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1 },
	resolvers.drops{chance=100, nb=1, {defined="FROST_TREADS", random_art_replace={chance=75}}, },
	resolvers.drops{chance=100, nb=3, {tome_drops="boss"} },
	resolvers.drops{chance=100, nb=10, {type="money"} },

	resolvers.talents{
		[Talents.T_KNOCKBACK]=3,

		[Talents.T_ICE_STORM]=2,
		[Talents.T_FREEZE]=3,

		[Talents.T_ICE_CLAW]={base=4, every=6},
		[Talents.T_ICY_SKIN]={base=3, every=7},
		[Talents.T_ICE_BREATH]={base=4, every=5},
	},
	resolvers.sustains_at_birth(),

	autolevel = "warriormage",
	ai = "tactical", ai_state = { talent_in=1, ai_move="move_astar", },
	resolvers.inscriptions(1, "infusion"),

	on_die = function(self, who)
		game.state:activateBackupGuardian("MASSOK", 4, 43, "다이카라에는 용 사냥꾼이 있다고 들었어. 그 용 사냥꾼은 자신의 사냥감을 뺏긴 것에 대해 상당히 안 좋은 감정을 가지고 있는 것 같다는군.")
		game.player:resolveSource():grantQuest("starter-zones")
		game.player:resolveSource():setQuestStatus("starter-zones", engine.Quest.COMPLETED, "daikara")
	end,
}

newEntity{ define_as = "VARSHA_THE_WRITHING",
	allow_infinite_dungeon = true,
	type = "dragon", subtype = "fire", unique = true,
	name = "Varsha the Writhing",
	kr_name = "몸부림 치는 바르샤",
	display = "D", color=colors.VIOLET,
	resolvers.nice_tile{image="invis.png", add_mos = {{image="npc/dragon_fire_varsha_the_writhing.png", display_h=2, display_y=-1}}},
	desc = [[발톱과 이빨. 화염과 죽음. 용은 멸종된 것이 아니었습니다...]],
	killer_message = "당신은 해츨링들의 먹잇감이 되었습니다.",
	level_range = {12, nil}, exp_worth = 2,
	max_life = 230, life_rating = 17, fixed_rating = true,
	max_stamina = 85,
	max_mana = 200,
	stats = { str=25, dex=10, cun=8, mag=20, wil=20, con=20 },
	rank = 4,
	size_category = 5,
	combat_armor = 17, combat_def = 14,
	infravision = 10,
	instakill_immune = 1,
	stun_immune = 1,
	move_others=true,

	combat = { dam=resolvers.levelup(resolvers.rngavg(25,110), 1, 2), atk=resolvers.rngavg(25,70), apr=25, dammod={str=1.1} },

	resists = { [DamageType.COLD] = -20, [DamageType.FIRE] = 100 },

	body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1 },
	resolvers.drops{chance=100, nb=1, {defined="VARSHA_CLAW", random_art_replace={chance=75}}, },
	resolvers.drops{chance=100, nb=3, {tome_drops="boss"} },
	resolvers.drops{chance=100, nb=10, {type="money"} },

	resolvers.talents{
		[Talents.T_KNOCKBACK]=3,

		[Talents.T_FIRE_STORM]=3,

		[Talents.T_WING_BUFFET]={base=4, every=6},
		[Talents.T_BELLOWING_ROAR]={base=3, every=7},
		[Talents.T_FIRE_BREATH]={base=4, every=5},
	},
	resolvers.sustains_at_birth(),

	autolevel = "warriormage",
	ai = "tactical", ai_state = { talent_in=1, ai_move="move_astar", },
	resolvers.inscriptions(1, "infusion"),

	on_die = function(self, who)
		game.state:activateBackupGuardian("MASSOK", 4, 43, "다이카라에는 용 사냥꾼이 있다고 들었어. 그 용 사냥꾼은 자신의 사냥감을 뺏긴 것에 대해 상당히 안 좋은 감정을 가지고 있는 것 같다는군.")
		game.player:resolveSource():grantQuest("starter-zones")
		game.player:resolveSource():setQuestStatus("starter-zones", engine.Quest.COMPLETED, "daikara")
		game.player:resolveSource():setQuestStatus("starter-zones", engine.Quest.COMPLETED, "daikara-volcano")
	end,
}

newEntity{ base="BASE_NPC_ORC_GRUSHNAK", define_as = "MASSOK",
	allow_infinite_dungeon = true,
	name = "Massok the Dragonslayer", color=colors.VIOLET, unique = true,
	kr_name = "용 사냥꾼, 마속",
	resolvers.nice_tile{image="invis.png", add_mos = {{image="npc/humanoid_orc_massok_the_dragonslayer.png", display_h=2, display_y=-1}}},
	desc = [[거대한 검을 들고 있으며, 크고 깊은 상처가 있는 오크입니다. 그의 투구는 용의 두개골로 만든 것 같습니다.]],
	level_range = {45, nil}, exp_worth = 3,
	rank = 4,
	max_life = 500, life_rating = 25, fixed_rating = true,
	infravision = 10,
	stats = { str=15, dex=10, cun=12, wil=45, mag=16, con=14 },
	move_others=true,

	instakill_immune = 1,
	stun_immune = 1,
	blind_immune = 1,
	combat_armor = 10, combat_def = 10,
	stamina_regen = 40,

	open_door = true,

	autolevel = "warrior",
	ai = "tactical", ai_state = { talent_in=1, ai_move="move_astar", },
	ai_tactic = resolvers.tactic"melee",
	resolvers.inscriptions(4, {"wild infusion", "healing infusion", "regeneration infusion", "heroism infusion"}),

	body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1, HEAD=1, FEET=1, FINGER=2, NECK=1 },

	resists = { [DamageType.COLD] = 100 },

	resolvers.equip{
		{type="weapon", subtype="battleaxe", force_drop=true, tome_drops="boss", autoreq=true},
		{type="armor", subtype="massive", force_drop=true, tome_drops="boss", autoreq=true},
		{type="armor", subtype="head", defined="DRAGON_SKULL", random_art_replace={chance=75}, autoreq=true},
		{type="armor", subtype="feet", force_drop=true, tome_drops="boss", autoreq=true},
	},
	resolvers.drops{chance=100, nb=5, {tome_drops="boss"} },

	resolvers.talents{
		[Talents.T_WEAPON_COMBAT]=4,
		[Talents.T_ARMOUR_TRAINING]=4,
		[Talents.T_WEAPONS_MASTERY]=4,
		[Talents.T_RUSH]=9,
		[Talents.T_BATTLE_CALL]=5,
		[Talents.T_STUNNING_BLOW]=4,
		[Talents.T_JUGGERNAUT]=5,
		[Talents.T_SHATTERING_IMPACT]=5,
		[Talents.T_BATTLE_SHOUT]=5,
		[Talents.T_BERSERKER]=5,
		[Talents.T_UNSTOPPABLE]=5,
		[Talents.T_MORTAL_TERROR]=5,
		[Talents.T_BLOODBATH]=5,
		[Talents.T_MASSIVE_BLOW] = 1,
	},
	resolvers.sustains_at_birth(),
}
