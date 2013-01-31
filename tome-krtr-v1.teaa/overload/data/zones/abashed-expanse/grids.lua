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

load("/data/general/grids/basic.lua")
load("/data/general/grids/forest.lua")
load("/data/general/grids/burntland.lua", function(e) if e.image == "terrain/grass_burnt1.png" then e.image = "terrain/floating_rocks05_01.png" end end)
load("/data/general/grids/void.lua")

newEntity{ base="FLOATING_ROCKS", define_as = "WORMHOLE", nice_tiler = false,
	name = "unstable wormhole",
	kr_display_name = "불안정한 웜홀",
	display = '*', color = colors.GREY,
	force_clone = true,
	damage_project = function(self, src, x, y, type, dam)
		if type ~= engine.DamageType.PHYSICAL and game.party:hasMember(src) and not self.change_level then
			self.change_level = 1
			self.name = "stable wormhole"
			self.kr_display_name = "안정된 웜홀"
			game.logSeen(src, "#VIOLET#웜홀이 에너지를 흡수하여 안정화되었습니다. 이제 이것을 사용하여 여행을 떠날수 있습니다.")
			local q = game.player:hasQuest("start-archmage")
			if q then q:stabilized() end
		end
	end,
	resolvers.generic(function(e) e:addParticles(engine.Particles.new("wormhole", 1, {})) end),
}
