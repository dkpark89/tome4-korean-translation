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
[[###########]],
[[#42..#..23#]],
[[#####.#####]],
[[#...212...#]],
[[#.#.....#.#]],
[[#.........#]],
[[#####+#####]],
[[#####!#####]],
}

return function(gen, id)
	local room = gen:roomParse(def)
	return { name="conclave-ogre-final"..room.w.."x"..room.h, w=room.w, h=room.h, generator = function(self, x, y, is_lit)
		gen:roomFrom(id, x, y, is_lit, room)

		-- Everything but the entrance is special: cant have the player spawn here
		util.squareApply(x, y, room.w, room.h-2, function(i, j) gen.map.room_map[i][j].special = true end)

		local spot = room.spots[1][1]
		local e = gen.zone:makeEntityByName(gen.level, "actor", "HEALER_ASTELRID")
		if e then
			gen:roomMapAddEntity(x + spot.x, y + spot.y, "actor", e)
			gen.spots[#gen.spots+1] = {x=x+spot.x, y=y+spot.y, guardian=true, check_connectivity="entrance"}
			e.on_added_to_level = nil
		end

		for _, spot in ipairs(room.spots[2]) do
			local e = gen.zone:makeEntity(gen.level, "actor", {type="giant", subtype="ogre", special_rarity="special_rarity"}, nil, true)
			if e then
				gen:roomMapAddEntity(x + spot.x, y + spot.y, "actor", e)
				e.on_added_to_level = nil
			end
		end

		if rng.percent(7) then
			for _, spot in ipairs(room.spots[4]) do
				local e = gen.zone:makeEntityByName(gen.level, "object", "LORE_SONG")
				if e then
					gen:roomMapAddEntity(x + spot.x, y + spot.y, "object", e)
				end
			end
		end
	end}
end
