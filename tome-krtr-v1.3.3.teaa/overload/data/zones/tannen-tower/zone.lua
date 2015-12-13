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
	name = "Tannen's Tower",
	kr_name = "탄넨의 탑",
	level_range = {35, 45},
	level_scheme = "player",
	max_level = 4, reverse_level_display=true,
	decay = {300, 800},
	actor_adjust_level = function(zone, level, e) return zone.base_level + e:getRankLevelAdjust() + level.level-1 + rng.range(-1,2) end,
	width = 25, height = 25,
--	all_remembered = true,
--	all_lited = true,
	no_worldport = true,
	persistent = "zone",
	no_level_connectivity = true,
	ambient_music = {"Remembrance.ogg","weather/dungeon_base.ogg"},
	min_material_level = 3,
	max_material_level = 4,
	generator =  {
		map = {
			class = "engine.generator.map.Static",
		},
		actor = {
			class = "mod.class.generator.actor.Random",
			nb_npc = {0, 0},
		},
		object = {
			class = "engine.generator.object.Random",
			nb_object = {2, 3},
		},
		trap = {
			class = "engine.generator.trap.Random",
			nb_trap = {0, 0},
		},
	},
	on_enter = function(lev, old_lev, newzone)
		if newzone and not game.level.shown_warning then
			require("engine.ui.Dialog"):simplePopup("탄넨의 탑", "그 관문은 당신을 탑의 지하실에 있는 방과 같은 곳으로 데리고 왔습니다. 이곳에서 탈출해야 합니다!")
			game.level.shown_warning = true
		end
		if lev == 4 then
			core.fov.set_actor_vision_size(0)
			if not game.level.data.seen_tannen then
				game.level.data.seen_tannen = true
				require("engine.ui.Dialog"):simpleLongPopup("Tannen's Tower", [[당신이 걸어 올라가자, 탄넨이 양피지 뭉치를 읽으며 그의 드롤렘과 같이 서있는 것이 보입니다. 양피지를 읽으면서, 그의 눈동자는 확장되고, 앞뒤로 걸으면서 땀을 흘리기 시작합니다. 그가 마침내 양피지를 주머니에 집어넣는 순간, 당신을 발견하고 깜짝 놀란 고양이 처럼 뒤로 펄쩍 뛰었습니다. "안돼! 지금은 안돼! 넌 지금 뭐가 중요한지 몰라!" 그는 로브에서 한가득 형형색색의 플라스크를 꺼내고, 그의 드롤렘은 삶을 얻은 듯이 눈동자를 빛냅니다.]], 500)
			end
		end
	end,
	on_leave = function()
		if game.level.level == 4 then
			core.fov.set_actor_vision_size(1)
		end
	end,
	on_loaded = function() -- When the game is loaded from a savefile
		game:onTickEnd(function() if game.level.level == 4 then
			core.fov.set_actor_vision_size(0)
		end end)
	end,
	levels =
	{
		[4] = { generator = { map = { map = "zones/tannen-tower-1" }, }, all_remembered = true, all_lited = true, },
		[3] = { generator = { map = { map = "zones/tannen-tower-2" }, actor = { nb_npc = {22, 22}, }, trap = { nb_trap = {6, 6} }, }, },
		[2] = { generator = { map = { map = "zones/tannen-tower-3" }, actor = { nb_npc = {22, 22}, filters={{special_rarity="aquatic_rarity"}} }, trap = { nb_trap = {6, 6} }, }, },
		[1] = { generator = { map = { map = "zones/tannen-tower-4" }, }, },
	},
	post_process = function(level)
		game.state:makeAmbientSounds(level, {
			dungeon2={ chance=250, volume_mod=1, pitch=1, random_pos={rad=10}, files={"ambient/dungeon/dungeon1","ambient/dungeon/dungeon2","ambient/dungeon/dungeon3","ambient/dungeon/dungeon4","ambient/dungeon/dungeon5"}},
		})
	end,
}
