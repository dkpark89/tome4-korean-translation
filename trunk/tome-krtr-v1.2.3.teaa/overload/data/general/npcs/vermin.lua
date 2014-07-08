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

require "engine.krtrUtils"

local Talents = require("engine.interface.ActorTalents")

newEntity{
	define_as = "BASE_NPC_WORM",
	type = "vermin", subtype = "worms",
	display = "w", color=colors.WHITE,
	can_multiply = 4,
	body = { INVEN = 10 },

	sound_die = {"creatures/worms/worm_die_%d", 1, 2},
	combat = {sound={"creatures/worms/worm_%d", 1, 4}},

	autolevel = "warrior",
	ai = "dumb_talented_simple", ai_state = { ai_move="move_complex", talent_in=3, },
	global_speed_base = 0.9,
	stats = { str=10, dex=15, mag=3, con=3 },
	combat_armor = 1, combat_def = 1,
	infravision = 10,
	rank = 1,
	size_category = 1,
	cut_immune = 1,
	blind_immune = 1,
	life_rating = 6,
	not_power_source = {arcane=true, technique_ranged=true},
}

newEntity{ base = "BASE_NPC_WORM",
	name = "white worm mass", color=colors.WHITE,
	kr_name = "흰 벌레 덩어리",
	level_range = {1, 15}, exp_worth = 1,
	rarity = 1,
	max_life = resolvers.rngavg(5,9),
	combat = { dam=1, atk=0, apr=100 },

	resolvers.talents{ [Talents.T_CRAWL_POISON]=1, [Talents.T_MULTIPLY]=1 },
}

newEntity{ base = "BASE_NPC_WORM",
	name = "green worm mass", color=colors.GREEN,
	kr_name = "녹색 벌레 덩어리",
	level_range = {2, 15}, exp_worth = 1,
	rarity = 2,
	max_life = resolvers.rngavg(5,9),
	combat = { dam=1, atk=3, apr=100 },

	resolvers.talents{ [Talents.T_CRAWL_ACID]=2, [Talents.T_MULTIPLY]=1 },
	ingredient_on_death = "GREEN_WORM",
}

newEntity{ base = "BASE_NPC_WORM", define_as = "CARRION_WORM_MASS",
	name = "carrion worm mass", color=colors.SANDY_BROWN,
	kr_name = "썩은 고기를 먹는 벌레 덩어리",
	can_multiply = 2,
	level_range = {20, nil}, exp_worth = 1,
	rarity = 4,
	max_life = resolvers.rngavg(5,9),
	combat = { dam=1, atk=15, apr=100 },

	disease_immune = 1,
	resists = { [DamageType.PHYSICAL] = 50, [DamageType.ACID] = 100, [DamageType.BLIGHT] = 100, [DamageType.FIRE] = -50},
	no_auto_resists = true,

	autolevel = "warriormage",
	resolvers.talents{ [Talents.T_CRAWL_ACID]=2, [Talents.T_ROTTING_DISEASE]=4, [Talents.T_MULTIPLY]=1 },

	on_die = function(self, src)
		game.level.map:addEffect(self,
			self.x, self.y, 5,
			engine.DamageType.BLIGHT, self:getStr(90, true),
			2,
			5, nil,
			engine.MapEffect.new{color_br=150, color_bg=255, color_bb=150, effect_shader="shader_images/poison_effect.png"}
		)
		game.logSeen(self, "%s 죽자, 오염된 기체가 흘러나옵니다.", (self.kr_name or self.name):capitalize():addJosa("가"))
	end,
}
