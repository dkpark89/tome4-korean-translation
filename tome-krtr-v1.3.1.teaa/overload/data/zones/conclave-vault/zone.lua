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

return {
	name = "Old Conclave Vault",
	level_range = {20, 30},
	level_scheme = "player",
	max_level = 4,
	decay = {300, 800, only={object=true}},
	actor_adjust_level = function(zone, level, e) return zone.base_level + e:getRankLevelAdjust() + level.level-1 + rng.range(-1,2) end,
	width = 50, height = 50,
	persistent = "zone",
--	all_remembered = true,
	all_lited = true,
	ambient_music = "Sinestra.ogg",
	min_material_level = 2,
	max_material_level = 3,
	generator =  {
		map = {
			class = "engine.generator.map.Roomer",
			nb_rooms = 10,
			rooms = {"!room1", "!room2", {"!room3", 3}, "small_x", "!room4", "!room5", "!room6"},
			lite_room_chance = 100,
			['.'] = function() if rng.percent(95) then return "FLOOR" else return rng.table{"RUNE_FLOOR", "BLOOD_FLOOR", "DECO_FLOOR"} end end,
			['#'] = "WALL",
			['+'] = "DOOR",
			up = "UP",
			down = "DOWN",
			door = "DOOR",
			force_last_stair = true,
		},
		actor = {
			class = "mod.class.generator.actor.Random",
			nb_npc = {12, 15},
		},
		object = {
			class = "engine.generator.object.Random",
			nb_object = {3, 6},
		},
		trap = {
			class = "engine.generator.trap.Random",
			nb_trap = {4, 4},
		},
	},
	levels =
	{
		[1] = {
			generator = { map = {
				class = "engine.generator.map.Static",
				map = "!conclave-vault-entrance",
			}, actor = {
				nb_npc = {0, 0},
			}, object = {
				nb_object = {0, 0},
			}, trap = {
				nb_trap = {2, 2},
			}},
		},
		[4] = {
			generator = { map = {
				down = "FLOOR",
				required_rooms = {"!boss"},
			} },
		},
	},
	post_process = function(level)
		-- Place a lore note on each level
		if level.level > 1 then game:placeRandomLoreObject("NOTE"..(level.level-1)) end
	end,

	awaken_ogres = function(who, x, y, radius, dur)
		if not who or who.special_rarity then return end
		core.fov.calc_circle(x, y, game.level.map.w, game.level.map.h, radius or 4, function(_, i, j)
			if game.level.map:checkAllEntities(i, j, "block_sight") then return true end
		end, function(_, i, j)
			local a = game.level.map(i, j, engine.Map.ACTOR)
			if not a then return end
			local eff = a:hasEffect(a.EFF_AEONS_STASIS)
			if not eff or eff.timeout then return end
			dur = dur or {3,6}
			eff.timeout = rng.range(dur[1], dur[2])
			a:setTarget(who)
		end, nil)
	end,
}
