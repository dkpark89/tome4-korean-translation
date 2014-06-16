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

load("/data/general/npcs/yaech.lua", function(e) if e.name then e.inc_damage.all = -35 end end)
load("/data/general/npcs/aquatic_critter.lua", rarity(2))

local Talents = require("engine.interface.ActorTalents")

newEntity{ base = "BASE_NPC_YAECH", define_as = "MURGOL",
	unique = true,
	name = "Murgol, the Yaech Lord",
	kr_name = "야크 군주, 무르골",
	color=colors.VIOLET,
	desc = [[이 야크로부터, 강한 염동적 파동이 퍼져 나오고 있습니다.]],
	killer_message = "당신은 바다 밖으로 버려졌습니다.",
	level_range = {7, nil}, exp_worth = 2,
	max_life = 100, life_rating = 13, fixed_rating = true,
	psi_regen = 10,
	infravision = 10,
	stats = { str=10, dex=10, cun=15, mag=16, wil=16, con=10 },
	move_others=true,

	instakill_immune = 1,
	blind_immune = 1,
	no_breath = 1,
	rank = 4,
	tier1 = true,

	resists = { [DamageType.BLIGHT] = 40 },

	body = { INVEN = 10, BODY=1, MAINHAND=1 },

	resolvers.equip{
		{type="weapon", subtype="trident", autoreq=true, special_rarity="trident_rarity"},
		{type="armor", subtype="light", defined="EEL_SKIN", random_art_replace={chance=65}, autoreq=true},
	},
	resolvers.drops{chance=100, nb=3, {tome_drops="boss"} },

	resolvers.talents{
		[Talents.T_PYROKINESIS]=2,
		[Talents.T_MINDLASH]=2,
		[Talents.T_MINDHOOK]=2,
		[Talents.T_KINETIC_SHIELD]=3,
		[Talents.T_THERMAL_SHIELD]=3,
	},
	resolvers.sustains_at_birth(),

	autolevel = "wildcaster",
	ai = "tactical", ai_state = { talent_in=2, },

	on_die = function(self, who)
		game.player:setQuestStatus("start-yeek", engine.Quest.COMPLETED, "murgol")
	end,
}

if currentZone.is_invaded then

newEntity{
	define_as = "BASE_NPC_NAGA",
	type = "humanoid", subtype = "naga",
	display = "n", color=colors.AQUAMARINE,

	combat = { dam=resolvers.rngavg(5,12), atk=2, apr=6, physspeed=2 },

	body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1, QUIVER=1 },
	resolvers.drops{chance=20, nb=1, {} },
	resolvers.drops{chance=10, nb=1, {type="money"} },
	infravision = 10,
	can_breath={water=1},

	faction = "vargh-republic",
	life_rating = 11,
	rank = 2,
	size_category = 3,

	inc_damage = {all = -35},

	resolvers.racial(),

	open_door = true,
	resolvers.inscriptions(1, "rune"),

	autolevel = "warrior",
	ai = "dumb_talented_simple", ai_state = { ai_move="move_complex", talent_in=3, },
	stats = { str=15, dex=15, mag=15, con=10 },
	ingredient_on_death = "NAGA_TONGUE",
}

newEntity{ base = "BASE_NPC_NAGA", define_as = "NAGA_TIDEWARDEN",
	name = "naga tidewarden", color=colors.DARK_UMBER,
	kr_name = "파도를 감시하는 나가",
	resolvers.nice_tile{image="invis.png", add_mos = {{image="npc/humanoid_naga_naga_tidewarden.png", display_h=2, display_y=-1}}},
	level_range = {1, nil}, exp_worth = 3,
	rarity = 1,
	max_life = resolvers.rngavg(100,120), life_rating = 13,
	resolvers.equip{
		{type="weapon", subtype="trident", autoreq=true, force_drop=true, special_rarity="trident_rarity"},
	},
	resolvers.talents{
		[Talents.T_SPIT_POISON]={base=1, every=10, max=5},
	},
}

newEntity{ base = "BASE_NPC_NAGA", define_as = "NAGA_TIDECALLER",
	name = "naga tidecaller", color=colors.BLUE,
	kr_name = "파도를 타는 나가",
	resolvers.nice_tile{image="invis.png", add_mos = {{image="npc/humanoid_naga_naga_tidecaller.png", display_h=2, display_y=-1}}},
	desc = [[이 기이한 생명체는 움직일 때마다 미끄러지는 소리를 흘리며, 그 뱀과도 같은 꼬리는 아름다운 엘프의 형상을 한 여성의 상체를 들어올리고 있습니다. 그녀가 섬세한 손동작을 취하면 땅에서 물줄기가 솟아나며, 당신은 이 존재가 단순한 괴물이 아닌, 두려운 힘을 가진 하나의 생명체라는 것을 느낍니다.]],
	level_range = {2, nil}, exp_worth = 3, female = true,
	rarity = 1,
	max_life = resolvers.rngavg(50,60), life_rating = 10,
	autolevel = "caster",
	resolvers.equip{
		{type="weapon", subtype="staff", autoreq=true},
	},
	resolvers.talents{
		[Talents.T_SPIT_POISON]={base=2, every=7, max=5},
		[Talents.T_WATER_JET]={base=2, every=7, max=5},
	},
}

newEntity{ base = "BASE_NPC_NAGA",
	name = "naga nereid", color=colors.YELLOW,
	kr_name = "나가 바다의 요정",
	desc = [[창백한 피부를 가진 그녀는 기다란 금빛 머리카락을 흩날리며, 그 녹색 눈으로 파도가 부서지는 것을 부드럽게 응시하고 있습니다. 당신은 이 노출된 모습에 눈을 떼지 못할 정도로 매혹되었지만, 좀 더 자세히 보면 그녀의 다리가 있어야 할 부분에 어두운 비늘이 덮인 긴 뱀의 꼬리같은 것이 있다는 것을 알 수 있습니다. 그녀의 움직임을 따라 시선을 옮기면, 머리카락이 흩날리면서 드러난 날씬하고 아름다운 얼굴과 높은 광대뼈, 그리고 매력적인 입술을 볼 수 있습니다. 하지만 이 환상적인 생명체의 매혹은, 그 뱀의 꼬리가 당신의 등골을 오싹하게 만들면서 사라집니다.]],
	level_range = {2, nil}, exp_worth = 3, female = true,
	rarity = 1,
	max_life = resolvers.rngavg(80,90), life_rating = 11,
	autolevel = "caster",
	resolvers.equip{
		{type="weapon", subtype="staff", autoreq=true},
	},
	resolvers.talents{
		[Talents.T_SPIT_POISON]={base=2, every=7, max=5},
		[Talents.T_MIND_SEAR]={base=2, every=7, max=5},
		[Talents.T_TELEKINETIC_BLAST]={base=2, every=7, max=5},
	},
}

newEntity{ base="BASE_NPC_NAGA", define_as = "NASHVA",
	unique = true,
	name = "Lady Nashva the Streambender",
	kr_name = "해류를 굽히는 숙녀, 나쉬바",
	resolvers.nice_tile{image="invis.png", add_mos = {{image="npc/humanoid_naga_lady_zoisla_the_tidebringer.png", display_h=2, display_y=-1}}},
	color=colors.VIOLET, female = true,
	desc = [[이 나가의 꼬리 주변에서는 물줄기가 천천히 회전하고 있습니다. 그녀의 검은 꼬리는 단단히 감겨 그녀의 키를 짧아보이게 만들지만, 그녀의 차분하면서도 자신감 넘치는 시선은 당신에게 있어 그녀가 쉽게 극복될 상대가 아니라는 것을 확신하게 만듭니다. 그녀 주변의 물줄기가 솟아오르기 시작하자 그녀 주변의 대기가 끓어오르고, 모든 것을 꿰뚫을 듯한 그녀의 검은 눈은 당신을 불편하게 만듭니다.]],
	killer_message = "당신은 바르그에 실험 대상으로 보내졌습니다.",
	level_range = {7, nil}, exp_worth = 2,
	max_life = 150, life_rating = 15, fixed_rating = true,
	max_stamina = 85,
	stats = { str=20, dex=10, cun=8, mag=10, con=20 },
	rank = 4,
	tier1 = true,
	size_category = 4,
	infravision = 10,
	instakill_immune = 1,
	move_others=true,

	body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1 },
	resolvers.equip{
		{type="weapon", subtype="trident", defined="TRIDENT_STREAM", random_art_replace={chance=65}, autoreq=true},
	},
	resolvers.drops{chance=100, nb=3, {tome_drops="boss"} },

	resolvers.talents{
		[Talents.T_SPIT_POISON]={base=2, every=10, max=5},
		[Talents.T_CHARGE_LEECH]={base=2, every=10, max=5},
		[Talents.T_DISTORTION_BOLT]={base=2, every=10, max=5},
		[Talents.T_EXOTIC_WEAPONS_MASTERY]={base=1, every=8, max=6},
	},
	resolvers.inscriptions(1, {"movement infusion"}),

	autolevel = "warriormage",
	ai = "tactical", ai_state = { talent_in=2, ai_move="move_astar", },
	ai_tactic = resolvers.tactic"melee",

	on_die = function(self, who)
		game.player:setQuestStatus("start-yeek", engine.Quest.COMPLETED, "murgol")
		game.player:setQuestStatus("start-yeek", engine.Quest.COMPLETED, "murgol-invaded")
	end,
}

end
