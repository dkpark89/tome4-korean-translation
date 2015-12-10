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

require "engine.krtrUtils"

local Talents = require("engine.interface.ActorTalents")

newEntity{
	define_as = "BASE_NPC_SANDWORM",
	type = "vermin", subtype = "sandworm",
	display = "w", color=colors.YELLOW,
	level_range = {7, nil},
	body = { INVEN = 10 },

	combat = { dam=resolvers.levelup(resolvers.mbonus(25, 15), 1, 1), atk=15, apr=0, dammod={str=0.7} },

	infravision = 10,
	max_life = 40, life_rating = 5,
	max_stamina = 85,
	max_mana = 85,
	resists = { [DamageType.FIRE] = 30, [DamageType.COLD] = -30 },
	rank = 2,
	size_category = 2,
	blind_immune = 1,
	sand_dweller = 1,

	drops = resolvers.drops{chance=5, nb=1, {type="scroll"} },

	autolevel = "warrior",
	ai = "dumb_talented_simple", ai_state = { ai_move="move_complex", talent_in=3, },
	stats = { str=15, dex=7, mag=3, con=3 },
	combat_armor = 1, combat_def = 1,
	ingredient_on_death = "SANDWORM_TOOTH",
	not_power_source = {arcane=true, technique_ranged=true},
}

newEntity{ base = "BASE_NPC_SANDWORM",
	name = "sandworm",
	kr_name = "지렁이",
	desc = [[모래 속에서 살고 있으며, 그 색깔을 닮은 거대한 벌레입니다. 당신이 이 굴 안에 있는 것을 별로 좋아하지 않는 것 같습니다.]],
	rarity = 1,
}

newEntity{ base = "BASE_NPC_SANDWORM",
	name = "sandworm destroyer",
	kr_name = "파괴자 지렁이",
	color={r=169,g=168,b=52},
	desc = [[모래 속에서 살고 있으며, 그 색깔을 닮은 거대한 벌레입니다. 이 특별한 지렁이는 한 가지 목적만을 위해 길러졌습니다. 그 목적은 지렁이가 아닌 모든 존재를 없애는 것입니다. 물론, 여기에는 당신도 포함됩니다.]],
	rarity = 3,

	resolvers.talents{
		[Talents.T_STUN]={base=2, every=10, max=5},
		[Talents.T_KNOCKBACK]={base=2, every=10, max=5},
	},
}

newEntity{ base = "BASE_NPC_SANDWORM",
	name = "sand-drake", display = 'D',
	kr_name = "모래 드레이크",
	type = "dragon", subtype = "sand",
	color={r=204,g=255,b=95},
	desc = [[날개없는 용처럼 생긴 부정한 생물입니다. 하지만 이 것은 모랫빛을 띄고 있어, 사냥감에게 더욱 위험합니다.]],
	rarity = 5,
	rank = 3,
	size_category = 5,

	ai = "tactical",
	ai_tactic = resolvers.tactic"melee",

	resolvers.talents{
		[Talents.T_SAND_BREATH]={base=3, every=5, max=7},
		[Talents.T_KNOCKBACK]={base=2, every=10, max=5},
	},
}

newEntity{ base = "BASE_NPC_SANDWORM",
	name = "gigantic sandworm tunneler", color=colors.LIGHT_UMBER,
	kr_name = "거대 굴착 지렁이",
	resolvers.nice_tile{image="invis.png", add_mos = {{image="npc/vermin_sandworm_gigantic_sandworm_tunneler.png", display_h=2, display_y=-1}}},
	desc = "땅이 흔들리면서, 이 거대한 벌레가 당신 쪽으로 굴을 파고 있습니다. 그 거대한 입은 돌과 살점을 가리지 않고 먹어치울 수 있습니다.",
	level_range = {20, nil}, exp_worth = 1,
	rarity = 2,
	size_category = 4,
	max_life = 120, life_rating = 13,
	combat_armor = 1, combat_def = 0,
	combat = { dam=resolvers.levelup(resolvers.mbonus(55, 15), 1, 1), atk=15, apr=0, dammod={str=1} },

	ai = "dumb_talented_simple", ai_state = { ai_target="target_player_radius", sense_radius=40, talent_in=2, },
	dont_pass_target = true,
	stats = { str=30, dex=7, mag=3, con=3 },

	no_breath = 1,

	can_pass = {pass_wall=20},
	move_project = {[DamageType.DIG]=1},

	resolvers.talents{
		[Talents.T_RUSH]={base=5, every=10, max=8},
		[Talents.T_GRAB]={base=5, every=10, max=8},
	},
}

newEntity{ base = "BASE_NPC_SANDWORM",
	name = "gigantic gravity worm", color=colors.UMBER,
	kr_name = "거대 중력 벌레",
	resolvers.nice_tile{image="invis.png", add_mos = {{image="npc/vermin_sandworm_gigantic_gravity_worm.png", display_h=2, display_y=-1}}},
	desc = "거대한 벌레로, 벌레 주변의 시공간이 왜곡되고 있습니다.",
	level_range = {20, nil}, exp_worth = 1,
	rarity = 5,
	size_category = 4,
	max_life = 100, life_rating = 14,
	combat_armor = 1, combat_def = 0,
	combat = { dam=resolvers.levelup(resolvers.mbonus(45, 15), 1, 0.9), atk=15, apr=0, dammod={str=1} },

	stats = { str=20, dex=7, mag=30, con=3 },
	autolevel = "warriormage",

	resolvers.talents{
		[Talents.T_GRAVITY_WELL]={base=3, every=10, max=8},
		[Talents.T_GRAVITY_SPIKE]={base=3, every=10, max=8},
		[Talents.T_GRAVITY_LOCUS]={base=3, every=10, max=8},
	},
}

newEntity{ base = "BASE_NPC_SANDWORM",
	name = "gigantic corrosive tunneler", color=colors.GREEN,
	kr_name = "부식성 거대 굴착 벌레",
	resolvers.nice_tile{image="invis.png", add_mos = {{image="npc/vermin_sandworm_gigantic_corrosive_tunneler.png", display_h=2, display_y=-1}}},
	desc = "이 거대한 벌레는 강력한 부식성 타액을 사용하여 땅 속에서 굴을 파고 있습니다.",
	level_range = {20, nil}, exp_worth = 1,
	rarity = 3,
	size_category = 4,
	max_life = 80, life_rating = 10,
	combat_armor = 1, combat_def = 0,
	combat = { dam=resolvers.levelup(resolvers.mbonus(55, 15), 1, 1), atk=15, apr=50, damtype=DamageType.ACID, dammod={str=1} },
	resists={[DamageType.ACID] = 100},

	stats = { str=30, dex=7, mag=3, con=3 },

	no_breath = 1,

	ai = "dumb_talented_simple", ai_state = { ai_target="target_player_radius", sense_radius=40, talent_in=2, },
	dont_pass_target = true,
	move_project = {[DamageType.DIG]=1},

	resolvers.talents{
		[Talents.T_ACID_BLOOD]={base=3, every=10, max=6},
	},

	on_die = function(self, src)
		game.level.map:addEffect(self,
			self.x, self.y, 5,
			engine.DamageType.ACID, self:getStr(90, true),
			3,
			5, nil,
			engine.MapEffect.new{color_br=150, color_bg=150, color_bb=150, effect_shader="shader_images/poison_effect.png"}
		)
		game.logSeen(self, "%s 산성 구름에 갇혀, 폭발합니다.", (self.kr_name or self.name):capitalize():addJosa("가"))
	end,
}
