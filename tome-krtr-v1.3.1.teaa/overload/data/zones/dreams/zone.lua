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

return {
	name = "Dreams",
	kr_name = "꿈",
	display_name = function(x, y)
		if game.level.level == 1 then return "Dream of vulnerability" end
		if game.level.level == 2 then return "Dream of loss" end
		return "Dream ???"
	end,
	kr_display_name = function(x, y)
		if game.level.level == 1 then return "약화의 꿈" end
		if game.level.level == 2 then return "상실의 꿈" end
		return "꿈 ???"
	end, 
	variable_zone_name = true,
	level_range = {1, 1},
	level_scheme = "player",
	max_level = 1,
	decay = {300, 800},
	actor_adjust_level = function(zone, level, e) return zone.base_level + e:getRankLevelAdjust() + level.level-1 + rng.range(-1,2) end,
	ambient_music = "Woods of Eremae.ogg",
	min_material_level = 3,
	max_material_level = 3,
	generator =  {
	},
	levels =
	{
		[1] = {
			motionblur = 2,
			width = 48, height = 48,
			color_shown = {0.9, 0.7, 0.4, 1},
			color_obscure = {0.9*0.6, 0.7*0.6, 0.4*0.6, 0.6},
			generator = {
				map = {
					class = "engine.generator.map.Maze",
					up = "FLOOR",
					down = "DREAM_END",
					wall = "JUNGLE_TREE",
					floor = "JUNGLE_GRASS",
					widen_w = 3, widen_h = 3,
					force_last_stair = true,
				},
				actor = {
					class = "mod.class.generator.actor.Random",
					nb_npc = {20, 20},
					filters = {{subtype="feline"}},
					randelite = 0,
				},
				object = {
					class = "engine.generator.object.Random",
					nb_object = {0, 0},
				},
				trap = {
					class = "engine.generator.trap.Random",
					nb_trap = {0, 0},
				},
			},
			post_process = function(level)
				-- Add mouse tunnels
				local Map = require "engine.Map"
				local dirs = {}
				for i = 1, level.map.w - 2 do for j = 1, level.map.h - 2 do
					while true do -- Breakable
						if level.map:checkEntity(i, j, Map.TERRAIN, "block_move") then break end

						local g4 = level.map:checkEntity(i - 1, j, Map.TERRAIN, "block_move")
						local g6 = level.map:checkEntity(i + 1, j, Map.TERRAIN, "block_move")
						local g8 = level.map:checkEntity(i, j - 1, Map.TERRAIN, "block_move")
						local g2 = level.map:checkEntity(i, j + 1, Map.TERRAIN, "block_move")

						if g4 then for z = i - 1, 1, -1 do
							if not level.map:checkEntity(z, j, Map.TERRAIN, "block_move") then
								dirs[#dirs+1] = {dir=4, x1=i-1, y1=j, x2=z+1, y2=j}
								break
							end
						end end
						if g6 then for z = i + 1, level.map.w - 2 do
							if not level.map:checkEntity(z, j, Map.TERRAIN, "block_move") then
								dirs[#dirs+1] = {dir=6, x1=i+1, y1=j, x2=z-1, y2=j}
								break
							end
						end end
						if g8 then for z = j - 1, 1, -1 do
							if not level.map:checkEntity(i, z, Map.TERRAIN, "block_move") then
								dirs[#dirs+1] = {dir=8, x1=i, y1=j-1, x2=i, y2=z+1}
								break
							end
						end end
						if g2 then for z = j + 1, level.map.h - 2 do
							if not level.map:checkEntity(i, z, Map.TERRAIN, "block_move") then
								dirs[#dirs+1] = {dir=2, x1=i, y1=j+1, x2=i, y2=z-1}
								break
							end
						end end

						break -- break the while
					end
				end end

				local nb = 0
				while nb < 15 and #dirs > 0 do
					local spot = rng.tableRemove(dirs)

					if not level.map:checkEntity(spot.x1, spot.y1, Map.TERRAIN, "mouse_hole") and not level.map:checkEntity(spot.x2, spot.y2, Map.TERRAIN, "mouse_hole") then
						local t1, t2
						if spot.dir == 4 then t1, t2 = {z=5, display_x=-1.5, display_w=2, image="terrain/road_going_left_01.png"}, {z=5, display_x=-0.5, display_w=2, image="terrain/road_going_right_01.png"}
						elseif spot.dir == 6 then t1, t2 = {z=5, display_x=-0.5, display_w=2, image="terrain/road_going_right_01.png"}, {z=5, display_x=-1.5, display_w=2, image="terrain/road_going_left_01.png"}
						elseif spot.dir == 8 then t1, t2 = {z=5, display_y=-1.5, display_h=2, image="terrain/road_upwards_01.png"}, {z=5, display_y=-0.5, display_h=2, image="terrain/road_downwards_01.png"}
						elseif spot.dir == 2 then t1, t2 = {z=5, display_y=-0.5, display_h=2, image="terrain/road_downwards_01.png"}, {z=5, display_y=-1.5, display_h=2, image="terrain/road_upwards_01.png"}
						end

						local g = game.zone.grid_list.DREAM_MOUSE_HOLE:clone()
						g.add_displays[#g.add_displays+1] = mod.class.Grid.new(t1)
						g.mouse_hole = {x=spot.x2, y=spot.y2}
						game.zone:addEntity(level, g, "terrain", spot.x1, spot.y1)

						local g = game.zone.grid_list.DREAM_MOUSE_HOLE:clone()
						g.add_displays[#g.add_displays+1] = mod.class.Grid.new(t2)
						g.mouse_hole = {x=spot.x1, y=spot.y1}
						game.zone:addEntity(level, g, "terrain", spot.x2, spot.y2)

						nb = nb + 1
					end
				end
			end,
		},
		[2] = {
			motionblur = 3,
			width = 30, height = 30,
			color_shown = {0.9, 0.7, 0.4, 1},
			color_obscure = {0.9*0.6, 0.7*0.6, 0.4*0.6, 0.6},
			generator = {
				map = {
					class = "engine.generator.map.Building",
					max_block_w = 15, max_block_h = 15,
					max_building_w = 5, max_building_h = 5,
					floor = function() if rng.chance(22) then return "DREAM_STONE" else return "BAMBOO_HUT_FLOOR" end end,
					external_floor = "BAMBOO_HUT_FLOOR",
					wall = "BAMBOO_HUT_WALL",
					up = "BAMBOO_HUT_FLOOR",
					down = "BAMBOO_HUT_FLOOR",
					door = "BAMBOO_HUT_DOOR",
					force_last_stair = true,
					lite_room_chance = 100,
				},
				actor = {
					class = "mod.class.generator.actor.Random",
					nb_npc = {10, 10},
					filters = {{name="yeek illusion"}},
					randelite = 0,
				},
				object = {
					class = "engine.generator.object.Random",
					nb_object = {0, 0},
				},
				trap = {
					class = "engine.generator.trap.Random",
					nb_trap = {0, 0},
				},
			},
			post_process = function(level)
				local list = {}
				for uid, e in pairs(level.entities) do
					if e.subtype == "yeek" then list[#list+1] = e end
				end
				local wife = rng.table(list)
				wife.is_wife = true

				level.back_shader = require("engine.Shader").new("funky_bubbles", {})
			end,
			background = function(level, x, y, nb_keyframes)
				if not level.back_shader or not level.back_shader.shad then return end
				local sx, sy = level.map._map:getScroll()
				local mapcoords = {(-sx + level.map.mx * level.map.tile_w) / level.map.viewport.width , (-sy + level.map.my * level.map.tile_h) / level.map.viewport.height}
				level.back_shader:setUniform("xy", mapcoords)
				level.back_shader.shad:use(true)
				core.display.drawQuad(x, y, level.map.viewport.width, level.map.viewport.height, 255, 255, 255, 255)
				level.back_shader.shad:use(false)
			end,
		},
	},

	on_enter = function(lev, old_lev)
		-- Dream of vulnerability
		if lev == 1 then
			game.level.data.enter_dreams{
				name = "frail mouse", image = "npc/vermin_rodent_giant_white_mouse.png",
				kr_name = "연약한 생쥐",
				type = "vermin", subtype = "rodent",
				display = "r", color=colors.WHITE,
				infravision = 10,
				sound_moam = {"creatures/rats/rat_hurt_%d", 1, 2},
				sound_die = {"creatures/rats/rat_die_%d", 1, 2},
				sound_random = {"creatures/rats/rat_%d", 1, 3},
				stats = { str=8, dex=15, mag=3, con=5, cun=15, },
				combat = {sound="creatures/rats/rat_attack", dam=5, atk=0, apr=10 },
				combat_armor = 1, combat_def = 1,
				rank = 1,
				movement_speed = 1.4,
				perfect_evasion = 1,
				size_category = 1,
				level_range = {1, 1}, exp_worth = 1,
				max_life = 10,
				mouse_turn = game.turn,
				talent_cd_reduction={
					T_EVASION=17,
					T_NIMBLE_MOVEMENTS=15,
					T_HIDE_IN_PLAIN_SIGHT=30,
					T_STEALTH=5,
				},
				resolvers.talents{
					T_STEALTH = 12,
					T_SHADOWSTRIKE = 5,
					T_HIDE_IN_PLAIN_SIGHT = 15,
					T_EVASION = 30,
					T_NIMBLE_MOVEMENTS = 3,
					T_PIERCING_SIGHT = 30,
				},
				
			
			msg = [[유독성 연기가 신체에 침범하여, 갑자기 깊은 수면에 빠졌습니다...
... 당신은 약해지고 ...
... 하찮은 존재이며 ...
... 먹잇감 ... 인 것 같습니다 ...
여기서 빨리 도망가야 합니다!]], 
			success_msg = [[정신으로 이루어진 생쥐가 꿈의 관문으로 들어서자, 당신은 갑작스레 잠에서 깨어났습니다.
상쾌한 기분이 듭니다!]],
				dream = "mice",
				}
		end

		-- Dream of loss
		if lev == 2 then
			game.level.data.enter_dreams{
				name = "lost man", image = "npc/humanoid_human_townsfolk_meanlooking_mercenary01_64.png",
				type = "humanoid", subtype = "human",
				display = "h", color=colors.VIOLET,
				infravision = 10,
				stats = { str=12, dex=12, mag=3, con=10, cun=10, },
				combat = {sound = {"actions/melee", pitch=0.6, vol=1.2}, sound_miss = {"actions/melee", pitch=0.6, vol=1.2}, dam=90, atk=15, apr=3 },
				combat_armor = 5, combat_def = 5,
				max_life = 100, life_regen = 0,
				resolvers.talents{
				},
				msg = [[유독성 연기가 신체에 침범하여, 갑자기 깊은 수면에 빠졌습니다...
... 뭔가를 잊어버린 것 같습니다 ...
... 상실감이 느껴집니다  ...
... 슬픔이 느껴집니다 ...
당신은 아내를 잊어버렸습니다! 그녀를 찾아야 합니다!]],
				success_msg = [[꿈의 관문으로 들어서자, 당신은 갑자기 깨어났습니다.
상쾌한 기분이 듭니다.]],
				dream = "lost",
			}
		end
	end,
	enter_dreams = function(t)
		local Player = require "mod.class.Player"
		table.update(t, {
			__no_save_json = true,
			body = {INVEN=10},
			no_inventory_access = true,
			level_range = {1, 1}, exp_worth = 1,
			on_die = function(self)
				local msg = self.success_msg
				local dream = self.dream
				game.level.data.leave_dreams(self, msg, dream)
			end,
		})
		local f = Player.new(t)
		f:resolve() f:resolve(nil, true)
		f.unused_talents = 0 f.unused_generics = 0
		if f.unused_stats > 0 then
			game.log("%s %d 만큼의 능력치 점수를 가지고 있습니다. p를 눌러 사용하십시요.", f.name:capitalize(), f.unused_stats)
		end
		f.summoner = game:getPlayer(true)
		f.x = game.player.x
		f.y = game.player.y
		for pmem, def in pairs(game.party.members) do
			game.level.map:remove(pmem.x, pmem.y, engine.Map.ACTOR)
			if game.level:hasEntity(pmem) then game.level:removeEntity(pmem) end
		end
		game.party:addMember(f, {temporary_level=1, control="full"})
		game.party:setPlayer(f, true)
		game.level:addEntity(f)
		f:move(f.x, f.y, true)
		f.energy.value = 1000
		game.paused = true
		game.player:updateMainShader()
		require("engine.ui.Dialog"):simpleLongPopup("깊은 수면...", t.msg, 600)
	end,
	leave_dreams = function(self, msg, dream)
		local danger = game.level.data.danger
		game.level:addEntity(self.summoner)
		game:onTickEnd(function()
			game:changeLevel(game.level.data.caldera_lev, "noxious-caldera", {direct_switch=true})
			for pmem, def in pairs(game.party.members) do
				if pmem.caldera_x and pmem.caldera_y then
					pmem:move(pmem.caldera_x, pmem.caldera_y, true)
					if not game.level:hasEntity(pmem) then game.level:addEntity(pmem) end
				end
			end
			game.party:setPlayer(game:getPlayer(true))
			if self.success and danger then
				require("engine.ui.Dialog"):simpleLongPopup("Deep slumber...", msg, 600)
				game.logPlayer(game.player, msg:gsub("\n", " "))
				game.player:setEffect(game.player.EFF_VICTORY_RUSH_ZIGUR, 4, {})
				world:gainAchievement("ALL_DREAMS", self.summoner, dream)
			elseif danger then
				local msg = [[꿈에서 당신이 죽음과 동시에 잠에서 갑자기 깨어났습니다.
				독가스가 당신의 몸을 침범합니다!]]
				game.logPlayer(game.player)
				require("engine.ui.Dialog"):simpleLongPopup("깊은 수면...", msg, 600)
				local hit = math.max(0, game.player.life * 2 / 3)
				game:onTickEnd(game.player:setEffect(game.player.EFF_DEATH_DREAM, 4, {power=hit/4}))
			end
		end)
	end,
}
