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

require "engine.krtrUtils"

load("/data/general/objects/objects.lua")

local Stats = require "engine.interface.ActorStats"

newEntity{ base = "BASE_LEATHER_BOOT",
	power_source = {arcane=true},
	define_as = "BOOTS_OF_PHASING",
	unique = true,
	name = "Shifting Boots", image = "object/artifact/shifting_boots.png",
	unided_name = "pair of shifting boots",
	kr_display_name = "이동의 신발", kr_unided_name = "형태가 계속 변하는 신발",
	desc = [[이 가죽 신발을 신은 자는, 누구든지 그 옛 소유자였던 드래보르만큼 사람을 성가시게 만들 수 있습니다.]],
	color = colors.BLUE,
	rarity = false,
	cost = 200,
	material_level = 5,
	wielder = {
		combat_armor = 1,
		combat_def = 7,
		fatigue = 2,
		talents_types_mastery = { ["spell/temporal"] = 0.1 },
		inc_stats = { [Stats.STAT_CUN] = 8, [Stats.STAT_DEX] = 4, },
	},

	max_power = 40, power_regen = 1,
	use_power = { name = "임의의 장소로 단거리 순간이동", power = 22, use = function(self, who)
		game.level.map:particleEmitter(who.x, who.y, 1, "teleport")
		who:teleportRandom(who.x, who.y, 10 + who:getMag(5))
		game.level.map:particleEmitter(who.x, who.y, 1, "teleport")
		game.logSeen(who, "%s %s 사용했습니다!", (who.kr_display_name or who.name):capitalize():addJosa("가"), self:getName{no_count=true}:addJosa("를"))
		return {id=true, used=true}
	end}
}
