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

load("/data/general/npcs/orc.lua", rarity(40))

local Talents = require("engine.interface.ActorTalents")

-- Same as normal orc, but without the loot
newEntity{
	define_as = "BASE_NPC_ORC_SUMMON",
	type = "humanoid", subtype = "orc",
	display = "o", color=colors.UMBER,
	faction = "orc-pride",

	combat = { dam=resolvers.rngavg(5,12), atk=2, apr=6, physspeed=2 },

	body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1, QUIVER=1 },
	infravision = 10,
	lite = 2,

	life_rating = 11,
	rank = 2,
	size_category = 3,

	open_door = true,

	autolevel = "warrior",
	ai = "dumb_talented_simple", ai_state = { ai_move="move_complex", talent_in=3, },
	stats = { str=20, dex=8, mag=6, con=16 },
	resolvers.talents{ [Talents.T_WEAPON_COMBAT]={base=1, every=10, max=5}, },
	ingredient_on_death = "ORC_HEART",
}


newEntity{ base = "BASE_NPC_ORC_SUMMON",
	name = "orc baby", color=colors.GREEN,
	kr_name = "아기 오크",
	desc = [[손발을 써서 기어다니는 녹색 피부의 생명체로, 작지만 날카로운 이빨과 손톱을 가지고 있어 귀여움과는 거리가 먼 존재입니다. 피부에서는 아직도 점액이 진득거리고 있습니다.]],
	level_range = {25, nil}, exp_worth = 0,
	resolvers.generic(function(e) if rng.percent(50) then e.female = true end end),
	rarity = 3,
	faction = "neutral", hard_faction = "neutral",
	max_life = resolvers.rngavg(30,50), life_rating = 4,
	rank = 2,
	movement_speed = 0.7,
	melee_project = {[DamageType.SLIME] = resolvers.rngrange(10, 20)},
	on_melee_hit = {[DamageType.SLIME] = resolvers.rngrange(10, 20)},
	combat = { dam=resolvers.levelup(resolvers.rngavg(15,50), 1, 0.5), atk=resolvers.rngavg(15,50), dammod={str=1} },
}

newEntity{ base = "BASE_NPC_ORC",
	name = "orc child", color=colors.LIGHT_GREEN,
	kr_name = "어린이 오크",
	desc = [[심술궃고 탐욕스러운 눈빛을 가진, 작은 오크입니다. 새로운 생명을 위해 혈관이 꿈틀거리고 있으며, 이 오크는 빠른 속도로 움직이고 있습니다. 완전히 자라지는 않았지만 상당히 근육질의 몸을 하고 있으며, 손가락과 발가락에는 날카로운 손톱과 발톱이 달려있습니다.]],
	resolvers.generic(function(e) if rng.percent(50) then e.female = true end end),
	level_range = {25, nil}, exp_worth = 0,
	rarity = 3,
	faction = "neutral", hard_faction = "neutral",
	max_life = resolvers.rngavg(30,50), life_rating = 9, life_regen = 7,
	movement_speed = 1.3,
	size_category = 1,
	melee_project = {[DamageType.SLIME] = resolvers.rngrange(10, 20)},
	on_melee_hit = {[DamageType.SLIME] = resolvers.rngrange(10, 20)},
	combat = { dam=resolvers.levelup(resolvers.rngavg(15,50), 1, 0.5), atk=resolvers.rngavg(15,50), dammod={str=1} },
	resolvers.talents{
		[Talents.T_RUSH]=4,
	},
}

newEntity{ base = "BASE_NPC_ORC",
	name = "young orc", color=colors.TEAL,
	kr_name = "젊은 오크",
	desc = [[이 젊은 오크는 두꺼운 피부와 그 아래로 보이는 단단한 근육으로 볼 때, 거의 성장한 것 같습니다. 더 어린 동족과 지내느라 야생의 기운은 덜하지만, 그 어두운 눈 속에서는 지혜롭고 차갑고 계산적인 빛이 번뜩이는 것을 알 수 있습니다.]],
	resolvers.generic(function(e) if rng.percent(50) then e.female = true end end),
	level_range = {25, nil}, exp_worth = 0,
	rarity = 3,

	max_life = resolvers.rngavg(70,80),
	resolvers.equip{
		{type="weapon", subtype="waraxe", autoreq=true},
		{type="armor", subtype="shield", autoreq=true},
	},
	resolvers.inscriptions(1, "infusion"),
	size_category = 2,
	combat_armor = 2, combat_def = 0,
	resolvers.talents{ [Talents.T_SHIELD_PUMMEL]={base=1, every=3, max=5}, },
}

newEntity{ base = "BASE_NPC_ORC",
	name = "orc mother", color=colors.YELLOW,
	kr_name = "어미 오크",
	resolvers.nice_tile{image="invis.png", add_mos = {{image="npc/humanoid_orc_orc_mother.png", display_h=2, display_y=-1}}},
	desc = [[거대하게 부풀어 오른 형상을 한 존재입니다. 온 몸의 구멍에서 점액과 끈적한 덩어리가 흘러내려 동굴 바닥을 적시고 있습니다. 어린 오크들이 부푼 젖꼭지를 차지하려고 싸우고 있고, 접혀진 살 사이로 작은 아기들이 밀려나오고 있습니다. 구역질이 나오는 광경이자 냄새입니다.
여기 용과 같이 어마어마한 크기의 존재가 있습니다. 두꺼운 주름이 진 피부는 부풀어 올랐고, 넓은 모공에서는 끈적한 점액이 스며나오고 있습니다. 수백 개의 젖꼭지에서는 어린 오크들이 다투고 있습니다. 그 중 가장 억센 놈들만이 귀중한 영양분을 획득하며 더 강하게 자라고 있으며, 약한 놈들은 곰팡내 나는 바닥에 쳐박혀 있습니다. 이 거대한 몸집의 최상부에서는 기다랗게 엉킨 머리카락으로 덮힌 무력한 머리가 달려있습니다. 그 멍한 눈빛에서는 슬픔과 고통이 섞여있었지만, 당신을 보자 눈빛이 분노로 가득 차오르기 시작했습니다. 이 생명체의 얼굴은 자신의 자식들을 지키려는 거센 욕망으로 일그러집니다.]],
	level_range = {25, nil}, exp_worth = 1,
	female = true,
	rarity = 8,
	never_move = 1,
	stun_immune = 1,
	size_category = 4,

	max_life = resolvers.rngavg(350,430), life_rating = 22,
	rank = 3,

	melee_project = {[DamageType.SLIME] = resolvers.rngrange(10, 20)},
	on_melee_hit = {[DamageType.SLIME] = resolvers.rngrange(10, 20)},

	summon = {
		{type="humanoid", subtype="orc", name="orc baby", number=1, hasxp=false, no_summoner_set=true},
	},

--	ai = "tactical",

	combat_armor = 45, combat_def = 0,

	talent_cd_reduction={[Talents.T_SUMMON]=-3, },
	resolvers.talents{
		[Talents.T_SUMMON]=10,
		[Talents.T_SLIME_SPIT]={base=3, every=5, max=8},
	},
}

newEntity{ base="BASE_NPC_ORC", define_as = "GREATMOTHER",
	name = "Orc Greatmother", color=colors.VIOLET, unique = true,
	kr_name = "오크 대모",
	resolvers.nice_tile{image="invis.png", add_mos = {{image="npc/humanoid_orc_orc_greatmother.png", display_h=2, display_y=-1}}},
	desc = [[거대하게 부풀어 오른 형상을 한 존재입니다. 온 몸의 구멍에서 점액과 끈적한 덩어리가 흘러내려 동굴 바닥을 적시고 있습니다. 어린 오크들이 부푼 젖꼭지를 차지하려고 싸우고 있고, 접혀진 살 사이로 작은 아기들이 밀려나오고 있습니다. 구역질이 나오는 광경이자 냄새입니다.
여기 용과 같이 어마어마한 크기의 존재가 있습니다. 두꺼운 주름이 진 피부는 부풀어 올랐고, 넓은 모공에서는 끈적한 점액이 스며나오고 있습니다. 수백 개의 젖꼭지에서는 어린 오크들이 다투고 있습니다. 그 중 가장 억센 놈들만이 귀중한 영양분을 획득하며 더 강하게 자라고 있으며, 약한 놈들은 곰팡내 나는 바닥에 쳐박혀 있습니다. 이 거대한 몸집의 최상부에서는 기다랗게 엉킨 머리카락으로 덮힌 무력한 머리가 달려있습니다. 그 멍한 눈빛에서는 슬픔과 고통이 섞여있었지만, 당신을 보자 눈빛이 분노로 가득 차오르기 시작했습니다. 이 생명체의 얼굴은 자신의 자식들을 지키려는 거센 욕망으로 일그러집니다.]],
	killer_message = "당신은 오크 아기들의 장난감이 되었습니다.",
	level_range = {40, nil}, exp_worth = 1,
	female = true,
	rank = 5,
	max_life = 700, life_rating = 25, fixed_rating = true,
	infravision = 10,
	move_others=true,
	never_move = 1,
	size_category = 5,

	instakill_immune = 1,
	stun_immune = 1,

	open_door = true,

	resolvers.inscriptions(2, "infusion"),

	body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1, HEAD=1, FEET=1, FINGER=2, NECK=1 },

	resolvers.drops{chance=100, nb=5, {tome_drops="boss"} },
	resolvers.drops{chance=100, nb=1, {unique=true, not_properties={"lore"}} },

	make_escort = {
		{type="humanoid", subtype="orc", name="orc baby", number=4, hasxp=false},
	},
	summon = {
		{type="humanoid", subtype="orc", name="orc baby", number=1, hasxp=false, no_summoner_set=true},
	},

	resolvers.talents{
		[Talents.T_SUMMON]=10,
		[Talents.T_SLIME_SPIT]={base=3, every=5, max=8},
		[Talents.T_BATTLE_CALL]=5,
		[Talents.T_BONE_GRAB]=4,
		[Talents.T_BONE_SPEAR]={base=4, every=3, max=12},
		[Talents.T_SHATTERING_SHOUT]=5,
		[Talents.T_UNSTOPPABLE]=5,
	},
	resolvers.sustains_at_birth(),

	on_die = function(self, who)
		game.log("#PURPLE#당신은 모든 오크들의 대모를 죽여, 오크들에게 엄청난 피해를 주었습니다.")
		game.state:eastPatrolsReduce()
		world:gainAchievement("GREATMOTHER_DEAD", who)
		who:setQuestStatus("orc-breeding-pits", engine.Quest.COMPLETED, "genocide")
		who:setQuestStatus("orc-breeding-pits", engine.Quest.COMPLETED)
	end,
}
