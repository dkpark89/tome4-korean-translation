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

-- last updated: 9:25 AM 2/5/2010

local Talents = require("engine.interface.ActorTalents")

newEntity{
	define_as = "BASE_NPC_THIEF",
	type = "humanoid", subtype = "human",
	display = "p", color=colors.BLUE,

	body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1 },
	resolvers.drops{chance=20, nb=1, {} },
	resolvers.equip{
		{type="weapon", subtype="dagger", autoreq=true},
		{type="weapon", subtype="dagger", autoreq=true},
		{type="armor", subtype="light", autoreq=true}
	},
	resolvers.drops{chance=100, nb=2, {type="money"} },
	infravision = 10,

	max_stamina = 100,
	rank = 2,
	size_category = 3,

	resolvers.racial(),
	resolvers.sustains_at_birth(),

	open_door = true,

	resolvers.inscriptions(1, "infusion"),

	autolevel = "rogue",
	ai = "dumb_talented_simple", ai_state = { ai_move="move_complex", talent_in=5, },
	stats = { str=8, dex=15, mag=6, cun=15, con=7 },

	resolvers.talents{
		[Talents.T_LETHALITY]={base=1, every=6, max=5},
		[Talents.T_KNIFE_MASTERY]={base=0, every=6, max=6},
		[Talents.T_WEAPON_COMBAT]={base=0, every=6, max=6},
	},
	power_source = {technique=true},
}

newEntity{ base = "BASE_NPC_THIEF",
	name = "cutpurse", color_r=0, color_g=0, color_b=resolvers.rngrange(235, 255),
	kr_name = "소매치기",
	desc = [[가장 낮은 수준의 도둑입니다. 소매치기 기술을 막 배운 상태입니다.]],
	level_range = {1, nil}, exp_worth = 1,
	rarity = 1,
	combat_armor = 1, combat_def = 5,
	max_life = resolvers.rngavg(60,80),
	resolvers.talents{  },
}

newEntity{ base = "BASE_NPC_THIEF",
	name = "rogue", color_r=0, color_g=0, color_b=resolvers.rngrange(215, 235),
	kr_name = "도둑",
	desc = [[소매치기보다는 강력한, 한 단계 진급한 도둑입니다.]],
	level_range = {2, nil}, exp_worth = 1,
	rarity = 1,
	combat_armor = 2, combat_def = 5,
	resolvers.talents{ [Talents.T_STEALTH]={base=1, every=6, max=7}, [Talents.T_SWITCH_PLACE]={last=8, base=0, every=6, max=5},  },
	max_life = resolvers.rngavg(70,90),
}

newEntity{ base = "BASE_NPC_THIEF",
	name = "thief", color_r=0, color_g=0, color_b=resolvers.rngrange(195, 215),
	kr_name = "날도둑",
	desc = [[그가 당신과 당신의 소지품을 동시에 보더니, 사라집니다... 흠, 왜 갑자기 짐이 가벼워진 것 같은 느낌이 날까요?]],
	level_range = {3, nil}, exp_worth = 1,
	rarity = 1,
	combat_armor = 3, combat_def = 5,
	resolvers.talents{
		[Talents.T_STEALTH]={base=2, every=6, max=8},
		[Talents.T_DISARM]={base=2, every=6, max=6},
		[Talents.T_VILE_POISONS]={base=0, every=6, max=5},
		[Talents.T_VENOMOUS_STRIKE]={last=15, base=0, every=6, max=5},
	},
	max_life = resolvers.rngavg(70,90),
}

newEntity{ base = "BASE_NPC_THIEF", define_as = "THIEF_BANDIT",
	name = "bandit", color_r=0, color_g=0, color_b=resolvers.rngrange(175, 195),
	kr_name = "강도",
	desc = [[도둑질을 넘어, 무식한 힘을 쓰기 시작한 악당입니다. 하지만 훔치는 것 역시 여전히 능숙합니다.]],
	level_range = {5, nil}, exp_worth = 1,
	rarity = 2,
	combat_armor = 4, combat_def = 6,
	resolvers.talents{
		[Talents.T_STEALTH]={base=3, every=6, max=9},
		[Talents.T_LETHALITY]={base=2, every=6, max=6},
		[Talents.T_VICIOUS_STRIKES]={base=1, every=7, max=6},
	},
	max_life = resolvers.rngavg(80,100),
}

newEntity{ base = "BASE_NPC_THIEF",
	name = "bandit lord", color_r=resolvers.rngrange(75, 85), color_g=0, color_b=resolvers.rngrange(235, 255),
	kr_name = "강도 두목",
	desc = [[강도 무리의 두목입니다. 부하들을 지키기 위해 주변을 경계하고 있습니다.]],
	level_range = {8, nil}, exp_worth = 1,
	rarity = 5,
	combat_armor = 5, combat_def = 7,
	max_life = resolvers.rngavg(90,100),
	combat = { dam=resolvers.rngavg(6,7), atk=10, apr=4},
	make_escort = {
		{type="humanoid", subtype="human", name="bandit", number=2},
		{type="humanoid", subtype="human", name="thief", number=2},
		{type="humanoid", subtype="human", name="rogue", number=2},
	},
	summon = {
		{type="humanoid", subtype="human", name="bandit", number=1, hasxp=false},
		{type="humanoid", subtype="human", name="bandit", number=1, hasxp=false},
		{type="humanoid", subtype="human", name="thief", number=1, hasxp=false},
		{type="humanoid", subtype="human", name="rogue", number=2, hasxp=false},
	},
	resolvers.talents{
		[Talents.T_STEALTH]={base=3, every=6, max=7},
		[Talents.T_SUMMON]=1,
		[Talents.T_LETHALITY]={base=3, every=6, max=6},
		[Talents.T_TOTAL_THUGGERY]={base=1, every=5, max=7},
	},
}

newEntity{ base = "BASE_NPC_THIEF", define_as = "THIEF_ASSASSIN",
	name = "assassin", color_r=resolvers.rngrange(0, 10), color_g=resolvers.rngrange(0, 10), color_b=resolvers.rngrange(0, 10),
	kr_name = "암살자",
	desc = [[어렴풋하게 눈이 보이더니... 강철이 번뜩거리고... 죽습니다.]],
	level_range = {12, nil}, exp_worth = 1,
	rarity = 3,
	combat_armor = 3, combat_def = 10,
	resolvers.talents{
		[Talents.T_STEALTH]={base=3, every=6, max=7},
		[Talents.T_PRECISION]={base=3, every=6, max=7},
		[Talents.T_DUAL_WEAPON_TRAINING]={base=2, every=6, max=6},
		[Talents.T_DUAL_WEAPON_DEFENSE]={base=2, every=6, max=6},
		[Talents.T_DUAL_STRIKE]={base=1, every=6, max=6},
		[Talents.T_SWEEP]={base=1, every=6, max=6},
		[Talents.T_SHADOWSTRIKE]={base=2, every=6, max=6},
		[Talents.T_LETHALITY]={base=5, every=6, max=8},
		[Talents.T_DISARM]={base=3, every=6, max=6},
	},
	max_life = resolvers.rngavg(70,90),

	resolvers.sustains_at_birth(),
	autolevel = "rogue",
}

newEntity{ base = "BASE_NPC_THIEF", define_as = "THIEF_ASSASSIN",
	name = "shadowblade", color_r=resolvers.rngrange(0, 10), color_g=resolvers.rngrange(0, 10), color_b=resolvers.rngrange(100, 120),
	kr_name = "그림자 칼잡이",
	desc = [[속임수로 승리를 획득하려 하는 은밀한 투사입니다. 조심하지 않으면, 당신의 생명을 도둑맞을지도 모릅니다!]],
	level_range = {14, nil}, exp_worth = 1,
	rarity = 4,
	combat_armor = 3, combat_def = 10,
	resolvers.talents{
		[Talents.T_STEALTH]={base=3, every=5, max=8},
		[Talents.T_DUAL_WEAPON_TRAINING]={base=2, every=6, max=6},
		[Talents.T_DUAL_WEAPON_DEFENSE]={base=2, every=6, max=6},
		[Talents.T_DUAL_STRIKE]={base=1, every=6, max=6},
		[Talents.T_SHADOWSTRIKE]={base=2, every=6, max=6},
		[Talents.T_SHADOWSTEP]={base=2, every=6, max=6},
		[Talents.T_LETHALITY]={base=5, every=6, max=8},
		[Talents.T_SHADOW_LEASH]={base=1, every=6, max=6},
		[Talents.T_SHADOW_AMBUSH]={base=1, every=6, max=6},
		[Talents.T_SHADOW_COMBAT]={base=1, every=6, max=6},
		[Talents.T_SHADOW_VEIL]={last=20, base=0, every=6, max=6},
		[Talents.T_INVISIBILITY]={last=30, base=0, every=6, max=6},
	},
	max_life = resolvers.rngavg(70,90),

	resolvers.sustains_at_birth(),
	autolevel = "rogue",
	power_source = {technique=true, arcane=true},
}
