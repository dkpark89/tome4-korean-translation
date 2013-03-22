-- ToME - Tales of Maj'Eyal
-- Copyright (C) 2009, 2010, 2011, 2012, 2013 Nicolas Casalini
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
	kr_name = "파도를 감시하는 나가",
	desc = [[이 기다란 존재의 앞에 서자, 당신은 그의 다리가 있어야 할 자리에 뱀의 꼬리가 붙어있다는 것을 발견했습니다. 그의 상체는 날씬하면서도 근육질이며, 얼굴은 엘프와도 같이 아름답고, 금발의 머리를 흩날리고 있습니다. 하지만 이 생명체도 사나움이라는 감정을 충분히 가지고 있으며, 그 밝은 눈동자에서는 화가 끓어오르고 있습니다.]],
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

newEntity{ base="BASE_NPC_NAGA", define_as = "ZOISLA",
	unique = true,
	name = "Lady Zoisla the Tidebringer",
	kr_name = "파도를 부르는 나가 숙녀, 조이슬라",
	resolvers.nice_tile{image="invis.png", add_mos = {{image="npc/humanoid_naga_lady_zoisla_the_tidebringer.png", display_h=2, display_y=-1}}},
	color=colors.VIOLET, female = true,
	desc = [[이 나가의 꼬리 주변에서는 물이 천천히 회전하고 있으며, 작은 물방울들이 위로 튀어올라 그들의 여왕이 내릴 명령을 기다리고 있습니다. 그녀의 어두운 꼬리는 단단히 감겨있어 짧아 보이지만, 그녀의 차분하면서도 자신감에 찬 눈빛을 보면 그녀가 만만한 상대가 아니라는 것을 알 수 있습니다. 그녀 주변의 물이 솟아오름과 동시에 대기는 끓어오르며, 그녀의 어두운 눈동자가 당신의 깊은 곳까지 꿰뚫어보는 느낌이 들어 불편함을 느낍니다.]],
	killer_message = "당신은 바르그의 실험 대상으로 보내졌습니다.",
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
