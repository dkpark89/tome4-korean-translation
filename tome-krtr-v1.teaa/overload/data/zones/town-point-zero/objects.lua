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

load("/data/general/objects/objects-maj-eyal.lua")

local Stats = require "engine.interface.ActorStats"
local Talents = require "engine.interface.ActorTalents"

newEntity{ base = "BASE_TOOL_MISC",
	power_source = {arcane=true},
	define_as = "TIME_SHARD",
	desc = [[보라색 수정의 무지개 빛 파편이다. 그 빛은 희미해졌다 강해지고, 어떤때는 빠르다가 어떤때는 느리며, 시간 그 자체의 혼돈적 흐름에 따르고 있다. 이것으로 당신은 늙으면서 동시에 젊어지는 듯 느끼고, 신생아적인 느낌과 태고적부터 존재하는듯한 느낌을 동시에 받으며, 당신의 육체는 시간에서 벗어난 영원한 영혼의 수천번의 굴절 가운데 단지 하나뿐임을 느낀다.]],
	unique = true,
	name = "Shard of Crystalized Time", color = colors.YELLOW,
	kr_display_name = "결정화된 시간의 파편",
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
