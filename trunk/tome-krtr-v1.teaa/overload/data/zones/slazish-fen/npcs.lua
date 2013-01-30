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

--load("/data/general/npcs/rodent.lua", rarity(5))
--load("/data/general/npcs/vermin.lua", rarity(2))
--load("/data/general/npcs/canine.lua", rarity(0))
--load("/data/general/npcs/troll.lua", rarity(0))
--load("/data/general/npcs/snake.lua", rarity(3))
--load("/data/general/npcs/plant.lua", rarity(0))
--load("/data/general/npcs/swarm.lua", rarity(3))
--load("/data/general/npcs/bear.lua", rarity(2))
--
--load("/data/general/npcs/all.lua", rarity(4, 35))

local Talents = require("engine.interface.ActorTalents")

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

	life_rating = 11,
	rank = 2,
	size_category = 3,

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
	kr_display_name = "나가 조수감시원",
	desc = [[당신이 기다란 상의 앞에 서자, 그의 다리가 있어야 할 자리에 뱀의 꼬리가 붙어 지탱하고 있음이 보입니다. 그의 상체는 날씬하고 근육질이며, 얼굴은 엘프와 같이 아름답고, 금발의 늘어진 머리를 가졌습니다. 하지만 이 생명체도 사나움을 가지고 있고, 그 밝은 눈동자는 화가 끓어오르고 있습니다.]],
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
	kr_display_name = "나가 조수담당자",
	resolvers.nice_tile{image="invis.png", add_mos = {{image="npc/humanoid_naga_naga_tidecaller.png", display_h=2, display_y=-1}}},
	desc = [[이 이상한 생명체가 움직이면 미끄러지는 소음이 동반되고, 그 뱀같은 꼬리는 아름다운 엘프같은 여성의 상체를 들어올리고 있습니다. 그녀가 섬세한 손동작을 취하면 땅에서 물줄기가 솟아나고, 당신은 이것이 단순한 괴물이 아니라 두려움과 힘을 가진 생명체임을 느낍니다.]],
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
	kr_display_name = "나가 바다의 요정",
	desc = [[기다란 금빛 머리카락 뒤로 녹색 눈이 부드럽게 파도가 부서지는 것을 응시하고 있고, 창백한 피부를 가지고 있습니다. 당신은 그 노출한 모습에서 눈을 뗄 수 없지만, 더 멀리 본다면 어두운 비늘이 긴 뱀의 꼬리까지 붙어있음을 알 수 있습니다. 그녀의 움직임을 따라 시선이 옮기면, 머리카락이 흔들려 높은 광대뼈와 통통한 입술의 날씬하고 아름다운 얼굴을 볼 수 있습니다. 이 환상적인 생물체의 모든 매혹은 공포스런 뱀꼬리가 당신의 척추를 박살낼 때까지 계속됩니다.]],
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

newEntity{ base="BASE_NPC_NAGA", define_as = "ZOISLA",
	unique = true,
	name = "Lady Zoisla the Tidebringer",
	kr_display_name = "해일을 부르는 숙녀, 조이슬라",
	resolvers.nice_tile{image="invis.png", add_mos = {{image="npc/humanoid_naga_lady_zoisla_the_tidebringer.png", display_h=2, display_y=-1}}},
	color=colors.VIOLET, female = true,
	desc = [[이 나가의 꼬리 주변의 땅에서는 물이 천천히 돌고 있고, 작은 물방울이 위로 도약하여 그들의 여왕의 명령을 기다리고 있습니다. 그녀의 어두운 꼬리는 단단히 감겨있어 짧은 것 처럼 보이지만, 그녀의 편안하고 확신에 찬 눈빛을 보면 그녀를 쉽게 압도할 수 없음을 알 수 있습니다. 그녀 주변의 물이 솟아 오르면 대기는 끓어오르고, 그녀의 어두운 눈동자가 당신의 깊은 곳까지 꿰뚫어 보는 것을 느끼는 순간 당신은 편안해 집니다.]],
	killer_message = "and brougth back to Vargh for experimentations",
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
		{type="weapon", subtype="staff", autoreq=true},
		{defined="ROBES_DEFLECTION", autoreq=true},
	},
	resolvers.drops{chance=100, nb=1, {unique=true, not_properties={"lore"}} },
	resolvers.drops{chance=100, nb=3, {tome_drops="boss"} },
	resolvers.drops{chance=100, nb=1, {defined="SLAZISH_NOTE3"} },

	resolvers.talents{
		[Talents.T_SPIT_POISON]={base=2, every=10, max=5},
		[Talents.T_WATER_BOLT]={base=2, every=10, max=5},
		[Talents.T_MIND_SEAR]={base=2, every=10, max=5},
		[Talents.T_EXOTIC_WEAPONS_MASTERY]={base=1, every=8, max=6},
	},
	resolvers.inscriptions(1, {"movement infusion"}),

	autolevel = "warriormage",
	ai = "tactical", ai_state = { talent_in=2, ai_move="move_astar", },
	ai_tactic = resolvers.tactic"melee",

	on_die = function(self, who)
		game.player:resolveSource():setQuestStatus("start-sunwall", engine.Quest.COMPLETED, "slazish")
	end,
}
