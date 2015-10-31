-- ToME - Tales of Maj'Eyal
-- Copyright (C) 2009 - 2015 Nicolas Casalini
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

newEntity{ define_as = "TRAP_TEMPORAL",
	type = "temporal", subtype="water", id_by_type=true, unided_name = "trap",
	display = '^',
	triggered = function(self, x, y, who)
		return true, self.auto_disarm
	end,
}

newEntity{ base = "TRAP_TEMPORAL",
	name = "disturbed pocket of time", auto_id = true, image = "trap/.png",
	detect_power = resolvers.clscale(8,50,8),
	disarm_power = resolvers.clscale(2,50,8),
	rarity = 3, level_range = {1, 50},
	color=colors.VIOLET,
	message = "@Target@ is caught in a distorted pocket of time!",
	triggered = function(self, x, y, who)
		who:paradoxDoAnomaly(100, 0, {anomaly_type="no-major"})
		return true
	end,
}

newEntity{ base = "TRAP_TEMPORAL",
	name = "extremely disturbed pocket of time", auto_id = true, image = "trap/.png",
	detect_power = resolvers.clscale(8,50,8),
	disarm_power = resolvers.clscale(2,50,8),
	rarity = 6, level_range = {1, 50},
	color=colors.PURPLE,
	message = "@Target@ is caught in an extremely distorted pocket of time!",
	triggered = function(self, x, y, who)
		who:paradoxDoAnomaly(100, 0, {anomaly_type="major"})
		return true
	end,
}
