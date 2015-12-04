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

newEntity{
	define_as = "BASE_MONEY",
	type = "money", subtype="money",
	display = "$", color=colors.YELLOW,
	encumber = 0,
	rarity = 5,
	identified = true,
	desc = [[번쩍인다고 해서 반드시 다 금은 아니며, 금이라고 해서 반드시 번쩍이는 것도 아니다.]],
	on_prepickup = function(self, who, id)
		who:incMoney(self.money_value / 10)
		game.logPlayer(who, "당신은 금화 %0.2f 개를 주웠습니다.", self.money_value / 10)
		-- Remove from the map
		game.level.map:removeObject(who.x, who.y, id)
		return true
	end,
	auto_pickup = true,
}

newEntity{ base = "BASE_MONEY", define_as = "MONEY_SMALL",
	name = "gold pieces", image = "object/money_small.png",
	kr_name = "금화",
	add_name = " (#MONEY#)",
	level_range = {1, 50},
	resolvers.generic(function(e)
		e.money_value = rng.avg(4, 10) * (game.player.money_value_multiplier or 1)
	end)
}

newEntity{ base = "BASE_MONEY", define_as = "MONEY_BIG",
	name = "huge pile of gold pieces", image = "object/money_large.png",
	kr_name = "금화 뭉치",
	add_name = " (#MONEY#)",
	level_range = {30, 50},
	color=colors.GOLD,
	rarity = 15,
	resolvers.generic(function(e)
		e.money_value = rng.avg(15, 35) * (game.player.money_value_multiplier or 1)
	end)
}
