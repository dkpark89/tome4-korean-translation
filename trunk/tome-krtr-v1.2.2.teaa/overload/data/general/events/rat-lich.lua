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

-- Unique
if game.state:doneEvent(event_id) then return end

-- Find a random spot
local x, y = rng.range(1, level.map.w - 2), rng.range(1, level.map.h - 2)
local tries = 0
while not game.state:canEventGrid(level, x, y) and tries < 100 do
	x, y = rng.range(1, level.map.w - 2), rng.range(1, level.map.h - 2)
	tries = tries + 1
end
if tries >= 100 then return false end

local id = "rat-lich-"..game.turn

local changer = function(id)
	local npcs = mod.class.NPC:loadList{"/data/general/npcs/undead-rat.lua"}
	local objects = mod.class.Object:loadList("/data/general/objects/objects.lua")
	local terrains = mod.class.Grid:loadList("/data/general/grids/basic.lua")
	terrains.UP_WILDERNESS.change_level_shift_back = true
	terrains.UP_WILDERNESS.change_zone_auto_stairs = true

	objects.RATLICH_SKULL = mod.class.Object.new{
		define_as = "RATLICH_SKULL",
		power_source = {arcane=true},
		unique = true,
		slot = "TOOL",
		type = "tool", subtype="skull", image = "object/artifact/skull_of_the_rat_lich.png",
		unided_name = "dusty rat skull",
		name = "Skull of the Rat Lich",
		display = "*", color=colors.BLACK,
		level_range = {10, 25},
		cost = 150,
		encumber = 1,
		material_level = 3,
		kr_name = "리치 쥐의 두개골", kr_unided_name = "먼지 낀 쥐의 두개골",
		desc = [[이 고대의 해골은 리치 쥐가 남긴 전부입니다. 두개골의 일부에는 아직 그 힘이 남아있으며, 눈에서는 아직도 희미하게 붉은 빛이 납니다.]],

		wielder = {
			combat_spellpower = 10,
			combat_spellcrit = 4,
			on_melee_hit = {[engine.DamageType.DARKNESS]=12},
		},
		max_power = 70, power_regen = 1,
		use_power = { name = "raise undead rats", kr_name = "언데드 생쥐 일으키기", power = 70, use = function(self, who)
			if not who:canBe("summon") then game.logPlayer(who, "소환할 수 없습니다. 억제되었습니다!") return end

			local NPC = require "mod.class.NPC"
			local list = NPC:loadList("/data/general/npcs/undead-rat.lua")

			for i = 1, 2 do
				-- Find space
				local x, y = util.findFreeGrid(who.x, who.y, 5, true, {[engine.Map.ACTOR]=true})
				if not x then break end

				local e
				repeat e = rng.tableRemove(list)
				until not e.unique and e.rarity

				local rat = game.zone:finishEntity(game.level, "actor", e)
				rat.make_escort = nil
				rat.silent_levelup = true
				rat.faction = who.faction
				rat.ai = "summoned"
				rat.ai_real = "dumb_talented_simple"
				rat.summoner = who
				rat.summon_time = 10

				local necroSetupSummon = getfenv(who:getTalentFromId(who.T_CREATE_MINIONS).action).necroSetupSummon
				necroSetupSummon(who, rat, x, y, nil, true, true)

				game:playSoundNear(who, "talents/spell_generic2")
			end
			return {id=true, used=true}
		end },
	}

	local zone = mod.class.Zone.new(id, {
		name = "Forsaken Crypt",
		kr_name = "버려진 지하실",
		level_range = {game.zone:level_adjust_level(game.level, game.zone, "actor"), game.zone:level_adjust_level(game.level, game.zone, "actor")},
		level_scheme = "player",
		max_level = 1,
		actor_adjust_level = function(zone, level, e) return zone.base_level + e:getRankLevelAdjust() + level.level-1 + rng.range(-1,2) end,
		width = 50, height = 50,
		ambient_music = "Dark Secrets.ogg",
		reload_lists = false,
		persistent = "zone",
		min_material_level = game.zone.min_material_level,
		max_material_level = game.zone.max_material_level,
		generator =  {
			map = {
				class = "engine.generator.map.Roomer",
				nb_rooms = 10,
				rooms = {"random_room", {"money_vault",5}},
				lite_room_chance = 50,
				['.'] = "FLOOR",
				['#'] = "WALL",
				up = "UP_WILDERNESS",
				down = "DOWN",
				door = "DOOR",
			},
			actor = {
				class = "mod.class.generator.actor.Random",
				nb_npc = {35, 45},
				guardian = "RATLICH",
			},
			object = {
				class = "engine.generator.object.Random",
				nb_object = {6, 9},
			},
			trap = {
				class = "engine.generator.trap.Random",
				nb_trap = {6, 9},
			},
		},
		npc_list = npcs,
		grid_list = terrains,
		object_list = objects,
		trap_list = mod.class.Trap:loadList("/data/general/traps/natural_forest.lua"),
	})
	return zone
end

local g = game.level.map(x, y, engine.Map.TERRAIN):cloneFull()
g.name = "forsaken crypt"
g.kr_name = "버려진 지하실"
g.display='>' g.color_r=0 g.color_g=0 g.color_b=255 g.notice = true
g.change_level=1 g.change_zone=id g.glow=true
g:removeAllMOs()
if engine.Map.tiles.nicer_tiles then
	g.add_displays = g.add_displays or {}
	g.add_displays[#g.add_displays+1] = mod.class.Grid.new{image="terrain/crystal_ladder_down.png", z=5}
end
g:altered()
g:initGlow()
g.real_change = changer
g.change_level_check = function(self)
	game:changeLevel(1, self.real_change(self.change_zone), {temporary_zone_shift=true, direct_switch=true})
	require("engine.ui.Dialog"):simplePopup("버려진 지하실", "삐걱거리는 소리와 함께 뼈가 부딪히는 소리가 주변에 메아리쳐 들립니다... 순수한 죽음이 기다립니다. 도망치십시오!")
	self.change_level_check = nil
	self.real_change = nil
	return true
end
game.zone:addEntity(game.level, g, "terrain", x, y)

-- Pop undead rats at the stairs
local npcs = mod.class.NPC:loadList{"/data/general/npcs/undead-rat.lua"}
for z = 1, 3 do
	local m = game.zone:makeEntity(game.level, "actor", {base_list=npcs, name="skeletal rat"}, nil, true)
	local i, j = util.findFreeGrid(x, y, 10, true, {[engine.Map.ACTOR]=true})
	if i and j and m then
		game.zone:addEntity(game.level, m, "actor", i, j)
	end
end

return true
