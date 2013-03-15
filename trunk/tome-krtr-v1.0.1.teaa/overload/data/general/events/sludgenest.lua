﻿-- ToME - Tales of Maj'Eyal
-- Copyright (C) 2009, 2010, 2011, 2012, 2013 Nicolas Casalini
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

level.data.on_enter_list.sludgenest = function()
	if game.level.data.sludgenest_added then return end
	if game:getPlayer(true).level < 30 then return end

	local spot = game.level:pickSpot{type="world-encounter", subtype="sludgenest"}
	if not spot then return end

	game.level.data.sludgenest_added = true
	local g = game.level.map(spot.x, spot.y, engine.Map.TERRAIN):cloneFull()
	g.__nice_tile_base = nil
	g.name = "Way into a strange lush forest"
	g.kr_name = "이상한 우거진 숲으로 이어진 길"
	g.display='>' g.color_r=100 g.color_g=255 g.color_b=0 g.notice = true
	g.change_level=1 g.change_zone="sludgenest" g.glow=true
	g.add_displays = g.add_displays or {}
	g.add_displays[#g.add_displays+1] = mod.class.Grid.new{image="terrain/jungle/jungle_tree_11.png", display_y=-1, display_h=2, z=16}
	g.nice_tiler = nil
	g:initGlow()
	game.zone:addEntity(game.level, g, "terrain", spot.x, spot.y)
	print("[WORLDMAP] sludgenest at", spot.x, spot.y)
	require("engine.ui.Dialog"):simpleLongPopup("우거진 숲", "갑자기 이 것이 나타났습니다. 예전에 누군가가 말한 북쪽땅의 차가운 얼음 무더기 사이에 있는 이상한 우거진 숲이 떠올랐습니다.", 400)
end

return true
