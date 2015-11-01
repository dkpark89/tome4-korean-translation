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

-- Find a random spot
local x, y = game.state:findEventGrid(level)
if not x then return false end

level.map:particleEmitter(x, y, 3, "generic_vortex", {rm=200, rM=250, gm=200, gM=250, bm=80, bM=120, am=80, aM=150, radius=3, density=50})

local on_stand = function(self, x, y, who) who:setEffect(who.EFF_WHISTLING_VORTEX, 1, {}) end

local grids = core.fov.circle_grids(x, y, 3, function(_, lx, ly) return not game.state:canEventGrid(level, lx, ly) end)
for x, yy in pairs(grids) do for y, _ in pairs(yy) do
	local g = game.level.map(x, y, engine.Map.TERRAIN):cloneFull()
	g.on_stand = g.on_stand or on_stand
	if g.on_stand == on_stand and g.type == "floor" then
		g.name = g.name ..  " (whistling vortex)"
		if not g.special_minimap then g.special_minimap = colors.DARK_SLATE_GRAY end
	end
	g.always_remember = true
	game.zone:addEntity(game.level, g, "terrain", x, y)
end end
print("[EVENT] whistling-vortex centered at ", x, y)
return true