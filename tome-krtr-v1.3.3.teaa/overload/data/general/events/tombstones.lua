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

-- Find a random spot
local nb = rng.range(3, 5)
for i = 1, nb do

local x, y = rng.range(1, level.map.w - 2), rng.range(1, level.map.h - 2)
local tries = 0
while not game.state:canEventGrid(level, x, y) and tries < 100 do
	x, y = rng.range(1, level.map.w - 2), rng.range(1, level.map.h - 2)
	tries = tries + 1
end
if tries < 100 then
	local g = game.level.map(x, y, engine.Map.TERRAIN):cloneFull()
	g.name = "grave"
	g.kr_name = "무덤"
	g.display='&' g.color_r=255 g.color_g=255 g.color_b=255 g.notice = true
	g.always_remember = true g.special_minimap = colors.OLIVE_DRAB
	g:removeAllMOs()
	if engine.Map.tiles.nicer_tiles then
		g.add_displays = g.add_displays or {}
		g.add_displays[#g.add_displays+1] = mod.class.Grid.new{image="terrain/grave_unopened_0"..rng.range(1,3).."_64.png", display_y=-1, display_h=2}
	end
	g.special = true
	g:altered()
	g.grow = nil g.dig = nil
	g.block_move = function(self, x, y, who, act, couldpass)
		if not who or not who.player or not act then return false end
		who:runStop("무덤")
		require("engine.ui.Dialog"):yesnoPopup("무덤", "무덤을 파헤칩니까?", function(ret) if ret then
			local g = game.level.map(x, y, engine.Map.TERRAIN)
			g:removeAllMOs()
			if g.add_displays then
				local ov = g.add_displays[#g.add_displays]
				ov.image = "terrain/grave_opened_0"..rng.range(1, 3).."_64.png"
			end
			g.name = "grave (opened)"
			game.level.map:updateMap(x, y)

			self.block_move = nil
			self.autoexplore_ignore = true
			if rng.percent(20) then game.log("여기에는 아무 것도 없습니다..") return end

			local m = game.zone:makeEntity(game.level, "actor", {properties={"undead"}, add_levels=10, random_boss={nb_classes=1, rank=3, ai = "tactical", loot_quantity = 0, no_loot_randart = true}}, nil, true)
			local x, y = util.findFreeGrid(who.x, who.y, 5, true, {[engine.Map.ACTOR]=true})
			if m and x and y then
				game.zone:addEntity(game.level, m, "actor", x, y)
				game.log("당신은 여기 처음 온 사람이 아닙니다. 시체는 언데드로 변해 있습니다.")
			else
				game.log("여기에는 아무 것도 없습니다.")
			end
		end end)
		return false
	end,
	game.zone:addEntity(game.level, g, "terrain", x, y)
	print("[EVENT] 묘비는 여기에 있습니다 : ", x, y)
end

end -- for

return true
