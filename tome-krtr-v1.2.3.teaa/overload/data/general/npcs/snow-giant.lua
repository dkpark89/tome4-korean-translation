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

local Talents = require("engine.interface.ActorTalents")

newEntity{
	define_as = "BASE_NPC_SNOW_GIANT",
	type = "giant", subtype = "ice",
	display = "P", color=colors.WHITE,

	combat = { dam=resolvers.levelup(resolvers.mbonus(50, 10), 1, 1), atk=15, apr=15, dammod={str=0.8} },

	body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1 },
	resolvers.drops{chance=100, nb=1, {type="money"} },

	infravision = 10,
	life_rating = 12,
	max_stamina = 90,
	rank = 2,
	size_category = 4,

	autolevel = "warrior",
	ai = "dumb_talented_simple", ai_state = { ai_move="move_complex", talent_in=2, },
	stats = { str=20, dex=8, mag=6, con=16 },

	resolvers.inscriptions(1, "infusion"),

	resists = { [DamageType.PHYSICAL] = 20, [DamageType.COLD] = 50, },

	no_breath = 1,
	confusion_immune = 1,
	poison_immune = 1,
	ingredient_on_death = "SNOW_GIANT_KIDNEY",
}

newEntity{ base = "BASE_NPC_SNOW_GIANT",
	name = "snow giant", color=colors.WHITE,
	kr_name = "설원 거인",
	resolvers.nice_tile{image="invis.png", add_mos = {{image="npc/giant_ice_snow_giant.png", display_h=2, display_y=-1}}},
	desc = [[거대한 탑과 같은 위압감을 자랑하는 거인입니다. 거대한 망치를 쥐고, 다정하지 않은 눈빛으로 당신을 쳐다보고 있습니다.]],
	level_range = {10, nil}, exp_worth = 1,
	rarity = 1,
	max_life = resolvers.rngavg(100,120),
	combat_armor = 0, combat_def = 0,
	on_melee_hit = {[DamageType.COLD]=resolvers.mbonus(15, 5)},
	melee_project = {[DamageType.COLD]=resolvers.mbonus(15, 5)},
	resolvers.talents{ [Talents.T_MIND_DISRUPTION]={base=2, every=10, max=5}, },
}

newEntity{ base = "BASE_NPC_SNOW_GIANT",
	name = "snow giant thunderer", color=colors.LIGHT_BLUE,
	kr_name = "천둥의 설원 거인",
	resolvers.nice_tile{image="invis.png", add_mos = {{image="npc/giant_ice_snow_giant_thunderer.png", display_h=2, display_y=-1}}},
	desc = [[거대한 탑과 같은 위압감을 자랑하는 거인입니다. 거대한 망치를 쥐고, 다정하지 않은 눈빛으로 당신을 쳐다보고 있습니다. 몸에서 뇌전이 파직거리며 흐르고 있습니다.]],
	level_range = {14, nil}, exp_worth = 1,
	rarity = 3,
	max_life = resolvers.rngavg(100,120),
	combat_armor = 0, combat_def = 0,
	on_melee_hit = {[DamageType.COLD]=resolvers.mbonus(15, 5)},
	melee_project = {[DamageType.COLD]=resolvers.mbonus(15, 5)},
	autolevel = "warriormage",
	resolvers.talents{ [Talents.T_LIGHTNING]={base=3, every=6, max=6}, [Talents.T_CHAIN_LIGHTNING]={base=3, every=6, max=6}, },
}

newEntity{ base = "BASE_NPC_SNOW_GIANT",
	name = "snow giant boulder thrower", color=colors.UMBER,
	kr_name = "바위던지기 설원 거인",
	resolvers.nice_tile{image="invis.png", add_mos = {{image="npc/giant_ice_snow_giant_boulder_thrower.png", display_h=2, display_y=-1}}},
	desc = [[거대한 탑과 같은 위압감을 자랑하는 거인입니다. 거대한 망치를 쥐고, 다정하지 않은 눈빛으로 당신을 쳐다보고 있습니다.]],
	level_range = {15, nil}, exp_worth = 1,
	rarity = 3,
	max_life = resolvers.rngavg(100,120),
	combat_armor = 0, combat_def = 0,
	on_melee_hit = {[DamageType.COLD]=resolvers.mbonus(15, 5)},
	melee_project = {[DamageType.COLD]=resolvers.mbonus(15, 5)},
	resolvers.talents{ [Talents.T_THROW_BOULDER]={base=3, every=6, max=6}, },
}

newEntity{ base = "BASE_NPC_SNOW_GIANT",
	name = "snow giant chieftain", color=colors.AQUAMARINE,
	kr_name = "설원 거인 족장",
	resolvers.nice_tile{image="invis.png", add_mos = {{image="npc/giant_ice_snow_giant_chieftain.png", display_h=2, display_y=-1}}},
	desc = [[거대한 탑과 같은 위압감을 자랑하는 거인입니다. 거대한 망치를 쥐고, 다정하지 않은 눈빛으로 당신을 쳐다보고 있습니다.]],
	level_range = {15, nil}, exp_worth = 1,
	rarity = 7,
	rank = 3,
	max_life = resolvers.rngavg(150,170),
	combat_armor = 12, combat_def = 12,
	on_melee_hit = {[DamageType.COLD]=resolvers.mbonus(15, 10)},
	melee_project = {[DamageType.COLD]=resolvers.mbonus(15, 10)},
	resolvers.talents{ [Talents.T_KNOCKBACK]={base=3, every=6, max=6}, [Talents.T_STUN]={base=3, every=6, max=6}, },
	make_escort = {
		{type="giant", subtype="ice", number=3},
	},
	lite = 1,

	ai = "tactical",

	resolvers.drops{chance=100, nb=1, {ego_chance=10} },
}

newEntity{ base = "BASE_NPC_SNOW_GIANT",
	define_as = "BURB_SNOW_GIANT",
	name = "Burb the snow giant champion", color=colors.VIOLET, unique=true,
	kr_name = "최강의 설원 거인, 불브",
	resolvers.nice_tile{image="invis.png", add_mos = {{image="npc/giant_ice_snow_giant_chieftain.png", display_h=2, display_y=-1}}},
	desc = [[동료들보다 더욱 크고 위압적이며, 미친 듯이 격분한 설원 거인입니다. 그가 아직 입에 거품을 물 정도로 난폭하지 않았던 시절, 그는 찾을 수 있는 모든 평평한 바위에 아이처럼 앉아서 다양한 이야기와 신비한 무늬를 새겼다고 합니다. 이제는 전설로만 남은 이야기지만요.]],
	level_range = {25, nil}, exp_worth = 10,
	autolevel = "warriormage",
	rarity = 10,
	rank = 3.5,
	life_rating = 25,
	max_life = resolvers.rngavg(150,170),
	combat_armor = 32, combat_def = 30,
	on_melee_hit = {[DamageType.COLD]=resolvers.mbonus(25, 20)},
	melee_project = {[DamageType.COLD]=resolvers.mbonus(25, 20)},
	resolvers.talents{
		[Talents.T_KNOCKBACK]={base=4, every=6, max=10},
		[Talents.T_STUN]={base=5, every=6, max=10},
		[Talents.T_THROW_BOULDER]={base=4, every=6, max=10},
		[Talents.T_ICE_SHARDS]={base=4, every=6, max=8},
		[Talents.T_UTTERCOLD]={base=4, every=6, max=8},
		[Talents.T_FREEZE]={base=4, every=6, max=8},
		[Talents.T_ICE_STORM]={base=4, every=6, max=8},
		[Talents.T_GIANT_LEAP]=1,
		},
	make_escort = {
		{type="giant", subtype="ice", number=3},
	},
	lite = 1,
	ai = "tactical",

	resolvers.drops{chance=100, nb=3, {tome_drops="boss"} },
}
