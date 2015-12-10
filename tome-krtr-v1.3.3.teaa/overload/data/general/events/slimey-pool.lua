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

local list = mod.class.Grid:loadList("/data/general/grids/slime.lua")

local on_stand = function(self, x, y, who) who:setEffect(who.EFF_SLIMEY_POOL, 1, {}) end
local g = list.SLIME_FLOOR:clone()

level.map(x, y, engine.Map.TERRAIN, g)
game.nicer_tiles:updateAround(level, x, y)
g = level.map(x, y, engine.Map.TERRAIN)
g.name = "slimey pool"
g.kr_name = "슬라임 웅덩이"
g.on_stand = on_stand
g.always_remember = true g.special_minimap = colors.OLIVE_DRAB
g:altered()

if core.shader.active(4) then
	level.map:particleEmitter(x, y, 2, "shader_ring_rotating", {rotation=0, system_rotationv=0.1, radius=2}, {type="flames", aam=0.5, zoom=3, npow=4, time_factor=10000, color1={0.2,0.7,0,1}, color2={0,1,0.3,1}, hide_center=0})
else
	level.map:particleEmitter(x, y, 2, "ultrashield", {rm=0, rM=0, gm=180, gM=220, bm=10, bM=80, am=220, aM=250, radius=2, density=1, life=14, instop=17})
end

local grids = core.fov.circle_grids(x, y, 1, function(_, lx, ly) return not game.state:canEventGrid(level, lx, ly) end)
for x, yy in pairs(grids) do for y, _ in pairs(yy) do
	local g = game.level.map(x, y, engine.Map.TERRAIN):cloneFull()
	g.on_stand = g.on_stand or on_stand
	if g.on_stand == on_stand and g.type == "floor" then
		g.name = g.name .. " (slimey)"
		if not g.special_minimap then g.special_minimap = colors.DARK_SEA_GREEN end
	end
	g.always_remember = true
	game.zone:addEntity(game.level, g, "terrain", x, y)
end end
print("[EVENT] slimey-pool centered at ", x, y)
return true
