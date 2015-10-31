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

local def = { numbers = '.',
[[#!!!!!!!!!!#]],
[[!..........!]],
[[###......#2!]],
[[!1#......#2!]],
[[!1#......#2!]],
[[!1#......#1!]],
[[!1#......#1!]],
[[!2#......#1!]],
[[!2#......#1!]],
[[!2#......###]],
[[!2.........!]],
[[#!!!!!!!!!!#]],
}

return function(gen, id)
	local room = gen:roomParse(def)
	return { name="conclave-ogre-2"..room.w.."x"..room.h, w=room.w, h=room.h, generator = function(self, x, y, is_lit)

		gen:roomFrom(id, x, y, is_lit, room)

		for _, spot in ipairs(room.spots[1]) do
			local e = gen.zone:makeEntity(gen.level, "actor", {special_rarity="vat_rarity"}, nil, true)
			if e then gen:roomMapAddEntity(x + spot.x, y + spot.y, "actor", e) gen.map.room_map[x + spot.x][y + spot.y].special = true end
		end
		for _, spot in ipairs(room.spots[2]) do
			game.level.map(x + spot.x, y + spot.y, gen.map.TRIGGER, engine.Entity.new{ on_move = function(self, x, y, who) if who and game.zone.awaken_ogres then
				game.zone.awaken_ogres(who, x, y, 8, {8, 12})
			end end})
		end
	end}
end
