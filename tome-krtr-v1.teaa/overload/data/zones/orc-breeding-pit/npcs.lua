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

load("/data/general/npcs/orc.lua", rarity(40))

local Talents = require("engine.interface.ActorTalents")

newEntity{ base = "BASE_NPC_ORC",
	name = "orc baby", color=colors.GREEN,
	kr_display_name = "아기 오크",
	desc = [[손발을 써서 기어다니는 이 녹색 피부의 생명체는 광포한 작은 이빨과 손톱을 가지고 있어 귀여움과는 거리가 멀고, 그 피부에는 아직도 점액이 진득거리고 있습니다.]],
	level_range = {25, nil}, exp_worth = 0,
	resolvers.generic(function(e) if rng.percent(50) then e.female = true end end),
	rarity = 3,
	max_life = resolvers.rngavg(30,50), life_rating = 4,
	rank = 2,
	movement_speed = 0.7,
	melee_project = {[DamageType.SLIME] = resolvers.rngrange(10, 20)},
	on_melee_hit = {[DamageType.SLIME] = resolvers.rngrange(10, 20)},
	combat = { dam=resolvers.levelup(resolvers.rngavg(15,50), 1, 0.5), atk=resolvers.rngavg(15,50), dammod={str=1} },
}

newEntity{ base = "BASE_NPC_ORC",
	name = "orc child", color=colors.LIGHT_GREEN,
	kr_display_name = "어린이 오크",
	desc = [[이 작은 오크는 심술궂고 탐욕스런 눈빛을 가지고 있습니다. 새로운 생명으로 혈관이 꿈틀거리고, 놀라운 속도로 움직이고 있습니다. 완전히 자라지는 않았지만 길고 근육질인 사지가 달렸고, 손가락과 발가락에는 날카로운 손톱과 발톱이 달려있습니다.]],
	resolvers.generic(function(e) if rng.percent(50) then e.female = true end end),
	level_range = {25, nil}, exp_worth = 0,
	rarity = 3,
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
	kr_display_name = "젊은 오크",
	desc = [[이 젊은 오크는 두꺼운 피부와 그 아래로 보이는 단단한 근육으로 볼 때, 거의 성장한 것 같습니다. 더 어린 동족과 지내느라 야생의 기운을 잃고있지만, 그 어두운 눈 속에서는 지혜롭고 차가운 계산이 번뜩이는 것을 알 수 있습니다.]],
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
	kr_display_name = "어미 오크",
	resolvers.nice_tile{image="invis.png", add_mos = {{image="npc/humanoid_orc_orc_mother.png", display_h=2, display_y=-1}}},
	desc = [[당신의 위쪽으로 솟아오른 이 거대하고 부풀어 오른 형상의 존재입니다. 구멍마다 들어있는 점액과 슬라임 덩어리가 동굴 바닥으로 흘러내리고 있습니다. 어린이 오크들이 부푼 젖꼭지를 차지하려고 싸우고 있고, 많은 맥동하는 외음부에서는 작은 아기들이 밀려나오고 있습니다. 이 광경과 냄새는 구역질이 나게 만듭니다.]],
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
		{type="humanoid", subtype="orc", name="orc baby", number=1, hasxp=false},
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
	kr_display_name = "최고 어미 오크",
	resolvers.nice_tile{image="invis.png", add_mos = {{image="npc/humanoid_orc_orc_greatmother.png", display_h=2, display_y=-1}}},
	desc = [[여기 용과 같이 어마어마한 크기의 존재가 있습니다. 두꺼운 주름으로 피부는 부풀어 올랐고, 넓은 모공에서는 끈적한 점액이 스며나오고 있습니다. 수백개의 젖꼭지에서는 젊은 오크들이 다투고 있습니다. 그 중 가장 억센 놈들만이 귀중한 영양분을 획득하며 더 강하게 자라고 있으며, 약한 놈들은 곰팡내나는 바닥에 쳐박혀 있습니다. 수십개의 벌어진 외음부는 짜부라들었다 맥동하면서 놀라운 속도로 새로운 새끼를 밀어냅니다. 이 거대한 몸집의 최상부에서는 기다랗게 엉킨 머리카락으로 덮힌 무력한 머리가 달려있습니다. 응시하는 멍한 눈빛은 슬픔과 고통이 섞여 있었지만, 당신을 보자 분노로 가득찹니다. 이 생물체의 얼굴은 자신의 자식들을 지키려는 거센 욕망으로 일그러집니다.]],
	killer_message = "and given to the children as a plaything",
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
		{type="humanoid", subtype="orc", name="orc baby", number=1, hasxp=false},
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
		game.log("#PURPLE#최고 어미 오크가 무너지자, 당신이 오크들에게 극심한 피해를 끼쳤음을 깨닫습니다.")
		game.state:eastPatrolsReduce()
		world:gainAchievement("GREATMOTHER_DEAD", who)
	end,
}
