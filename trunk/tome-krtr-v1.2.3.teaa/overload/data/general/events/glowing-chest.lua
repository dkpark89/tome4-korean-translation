﻿-- ToME - Tales of Maj'Eyal
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
local x, y = game.state:findEventGrid(level)
if not x then return false end

local o
local r = rng.range(0, 99)
if r < 10 then
	o = game.state:generateRandart{lev=resolvers.current_level+10}
elseif r < 40 then
	o = game.zone:makeEntity(game.level, "object", {tome={double_greater=1}}, nil, true)
else
	o = game.zone:makeEntity(game.level, "object", {tome={greater_normal=1}}, nil, true)
end
r = 99 - r 
local ms
if rng.percent(r * 2) then
	ms = {}
	r = rng.range(0, 99)
	if r < 8 then
		ms[#ms+1] = game.zone:makeEntity(game.level, "actor", {random_boss=true}, nil, true)
	elseif r < 25 then
		ms[#ms+1] = game.zone:makeEntity(game.level, "actor", {random_elite=true}, nil, true)
		ms[#ms+1] = game.zone:makeEntity(game.level, "actor", {random_elite=true}, nil, true)
	elseif r < 60 then
		ms[#ms+1] = game.zone:makeEntity(game.level, "actor", {random_elite=true}, nil, true)
	else
		ms[#ms+1] = game.zone:makeEntity(game.level, "actor", {}, nil, true)
		ms[#ms+1] = game.zone:makeEntity(game.level, "actor", {}, nil, true)
		ms[#ms+1] = game.zone:makeEntity(game.level, "actor", {}, nil, true)
		ms[#ms+1] = game.zone:makeEntity(game.level, "actor", {}, nil, true)
	end
end 

local g = game.level.map(x, y, engine.Map.TERRAIN):cloneFull()
g.name = "glowing chest"
g.kr_name = "빛나는 상자"
g.display='~' g.color_r=255 g.color_g=215 g.color_b=0 g.notice = true
g:removeAllMOs()
if engine.Map.tiles.nicer_tiles then
	g.add_displays = g.add_displays or {}
	g.add_displays[#g.add_displays+1] = mod.class.Grid.new{image="object/chest3.png", z=5}
end
g:altered()
g.special = true
g.chest_item = o
g.chest_guards = ms
g.block_move = function(self, x, y, who, act, couldpass)
	if not who or not who.player or not act then return false end
	if self.chest_opened then return false end

	require("engine.ui.Dialog"):yesnoPopup("빛나는 상자", "상자를 열겠습니까?", function(ret) if ret then
		self.chest_opened = true
		if self.chest_item then
			game.zone:addEntity(game.level, self.chest_item, "object", x, y)
			game.logSeen(who, "#GOLD#상자 속에서 물건이 나왔습니다!")
			if self.chest_guards then
				for _, m in ipairs(self.chest_guards) do
					if game.level.data and game.level.data.special_level_faction then
						m.faction = game.level.data.special_level_faction
					end
					local mx, my = util.findFreeGrid(x, y, 5, true, {[engine.Map.ACTOR]=true})
					if mx then game.zone:addEntity(game.level, m, "actor", mx, my) end
				end
				game.logSeen(who, "#GOLD#하지만 상자는 보호받고 있습니다!")
			end
		end
		self.chest_item = nil
		self.chest_guards = nil
		self.block_move = nil
		self.special = nil
		self.autoexplore_ignore = true
		
		if self.add_displays and self.add_displays[1] then 
			self.add_displays[1].image = "object/chestopen3.png"
			self:removeAllMOs()
			game.level.map:updateMap(x, y)
		end
	end end, "열기", "놔두기")

	return false
end
game.zone:addEntity(game.level, g, "terrain", x, y)

return true
