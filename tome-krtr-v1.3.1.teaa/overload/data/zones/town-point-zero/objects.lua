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

load("/data/general/objects/objects-maj-eyal.lua")

local Stats = require "engine.interface.ActorStats"
local Talents = require "engine.interface.ActorTalents"

newEntity{ base = "BASE_TOOL_MISC",
	power_source = {arcane=true},
	define_as = "TIME_SHARD",
	kr_name = "결정화된 시간의 파편", kr_unided_name = "빛나는 파편",
	desc = [[무지개 빛이 흘러나오는, 보라색 수정 파편입니다. 그 빛은 희미해졌다 강해지고, 어떨 때는 빠르다가 어떨 때는 느려지며, 시간 그 자체의 혼돈스러운 흐름에 따르고 있습니다. 이것을 통해 당신은 늙으면서 동시에 젊어지는 느낌을 느끼고, 신생아의 느낌과 태고적 존재의 느낌을 동시에 받으며, 당신의 육체는 시간에서 벗어나 영원히 존재하는 영혼의 수천 가지 일면 가운데 하나일 뿐이라는 것을 느낍니다.]],
	unique = true,
	name = "Shard of Crystalized Time", color = colors.YELLOW,
	unided_name = "glowing shard", image = "object/artifact/time_shard.png",
	level_range = {5, 12},
	rarity = false,
	cost = 10,
	material_level = 1,
	metallic = false,
	wielder = {
		inc_stats = { [Stats.STAT_WIL] = 4, [Stats.STAT_CON] = 2, },
		combat_def = 5,
		inc_damage = { [DamageType.TEMPORAL] = 7 },
		paradox_reduce_fails = 25,
	},
}
