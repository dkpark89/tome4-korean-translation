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

load("/data/general/grids/basic.lua")
load("/data/general/grids/forest.lua")
load("/data/general/grids/water.lua")

local grass_editer = { method="borders_def", def="grass"}

newEntity{
	define_as = "BOGTREE",
	type = "wall", subtype = "water",
	name = "tree",
	kr_name = "나무",
	image = "terrain/poisoned_water_01.png",
	display = '#', color=colors.LIGHT_GREEN, back_color=colors.DARK_BLUE,
	always_remember = true,
	can_pass = {pass_tree=1},
	does_block_move = true,
	block_sight = true,
	dig = "SHALLOW_WATER",
	nice_tiler = { method="replace", base={"BOGTREE", 100, 1, 40}},
	shader = "water",
}
for i = 1, 40 do
	newEntity(class:makeNewTrees({base="BOGTREE", define_as = "BOGTREE"..i}, {
		{"small_willow", {"shadow", "trunk", "waterripples", "foliage_bare"}},
		{"small_willow_moss", {"shadow", "trunk", "waterripples", "foliage_bare"}},
		{"willow", {tall=-1, "shadow", "trunk", "waterripples", "foliage_bare"}},
		{"willow_moss", {tall=-1, "shadow", "trunk", "waterripples", "foliage_bare"}},
		{"small_willow", {"shadow", "trunk", "waterripples", "foliage_spring"}},
		{"small_willow_moss", {"shadow", "trunk", "waterripples", "foliage_spring"}},
		{"willow", {tall=-1, "shadow", "trunk", "waterripples", "foliage_spring"}},
		{"willow_moss", {tall=-1, "shadow", "trunk", "waterripples", "foliage_spring"}},
		{"small_willow", {"shadow", "trunk", "waterripples", "foliage_spring"}},
		{"small_willow_moss", {"shadow", "trunk", "waterripples", "foliage_spring"}},
		{"willow", {tall=-1, "shadow", "trunk", "waterripples", "foliage_spring"}},
		{"willow_moss", {tall=-1, "shadow", "trunk", "waterripples", "foliage_spring"}},
		{"small_willow", {"shadow", "trunk", "waterripples", "foliage_spring"}},
		{"small_willow_moss", {"shadow", "trunk", "waterripples", "foliage_spring"}},
		{"willow", {tall=-1, "shadow", "trunk", "waterripples", "foliage_spring"}},
		{"willow_moss", {tall=-1, "shadow", "trunk", "waterripples", "foliage_spring"}},
	}))
end

newEntity{ base="WATER_BASE",
	define_as = "BOGWATER",
	name = "bog water",
	kr_name = "습지",
	image="terrain/poisoned_water_01.png",
}

newEntity{ base="BOGWATER",
	define_as = "BOGWATER_MISC",
	nice_tiler = { method="replace", base={"BOGWATER_MISC", 100, 1, 7}},
}
for i = 1, 7 do newEntity{ base="BOGWATER_MISC", define_as = "BOGWATER_MISC"..i, add_mos={{image="terrain/misc_bog"..i..".png"}}} end

newEntity{ base="BOGWATER",
	define_as = "PORTAL",
	display = "&", color = colors.VIOLET,
	name = "coral portal",
	kr_name = "산호 관문",
	add_displays = {class.new{z=18, image="terrain/naga_portal.png", display_h=2, display_y=-1, embed_particles = {
		{name="naga_portal_smoke", rad=2, args={smoke="particles_images/smoke_whispery_bright"}},
		{name="naga_portal_smoke", rad=2, args={smoke="particles_images/smoke_heavy_bright"}},
		{name="naga_portal_smoke", rad=2, args={smoke="particles_images/smoke_dark"}},
	}}},
	does_block_move = true,
	pass_projectile = true,
	block_move = function(self, x, y, who, act, couldpass)
		if not who or not who.player or not act then return true end
		if self.broken then
			game.log("#VIOLET#이 관문은 이미 부서져 있습니다!")
			return true
		end

		who:restInit(20, "관문 파괴", "관문 파괴", function(cnt, max)
			if cnt > max then
				game.log("#VIOLET#이 관문이 무너지기 시작했습니다, 물러나십시오!")
				self.broken = true
				who:setQuestStatus("start-sunwall", engine.Quest.COMPLETED, "slazish")
				game:onTickEnd(function()
					local sx, sy = util.findFreeGrid(x, y, 10, true, {[engine.Map.ACTOR]=true})
					local npc = game.zone:makeEntityByName(game.level, "actor", "ZOISLA")
					if sx then
						game.zone:addEntity(game.level, npc, "actor", sx, sy)
						game.level.map:particleEmitter(sx, sy, 1, "teleport_water")
						local chat = require("engine.Chat").new("zoisla", npc, who)
						chat:invoke("welcome")
					end
				end)
			end
		end)

		return true
	end,
}

newEntity{ base = "GRASS_UP_WILDERNESS", define_as = "GATES_OF_MORNING",
	change_zone = "town-gates-of-morning", change_zone_auto_stairs = true,
}
