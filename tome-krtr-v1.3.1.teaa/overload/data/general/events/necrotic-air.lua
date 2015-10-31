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

if core.shader.active(4) then
	level.map:particleEmitter(x, y, 2, "shader_ring_rotating", {rotation=0, radius=4}, {type="flames", aam=0.2, zoom=1, npow=8, time_factor=6000, color1={0.1,0.1,0.1,6}, color2={0.3,0.3,0.3,1}, hide_center=0})
else
	level.map:particleEmitter(x, y, 2, "ultrashield", {rm=200, rM=250, gm=200, gM=250, bm=80, bM=120, am=220, aM=250, radius=2, density=1, life=14, instop=17})
end

local on_stand = function(self, x, y, who) who:setEffect(who.EFF_NECROTIC_AIR, 1, {}) end

local grids = core.fov.circle_grids(x, y, 2, function(_, lx, ly) return not game.state:canEventGrid(level, lx, ly) end)
for x, yy in pairs(grids) do for y, _ in pairs(yy) do
	local g = game.level.map(x, y, engine.Map.TERRAIN):cloneFull()
	g.on_stand = g.on_stand or on_stand
	if g.on_stand == on_stand and g.type == "floor" then
		g.name = g.name .. " (necrotic air)"
		if not g.special_minimap then g.special_minimap = colors.DARK_SLATE_GRAY end
	end
	g.always_remember = true
	game.zone:addEntity(game.level, g, "terrain", x, y)
end end
print("[EVENT] necrotic-air centered at ", x, y)
return true