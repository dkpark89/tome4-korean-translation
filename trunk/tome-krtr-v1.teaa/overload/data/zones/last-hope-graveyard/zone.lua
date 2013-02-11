-- ToME - Tales of Maj'Eyal
-- Copyright (C) 2009, 2010, 2011, 2012 Nicolas Casalini
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
	name = "Last Hope Graveyard",
	kr_display_name = "마지막 희망 공동묘지",
	display_name = function(x, y)
		if game.level.level == 1 then return "Last Hope Graveyard"
		elseif game.level.level == 2 then return "Mausoleum"
		end
		return "Last Hope Graveyard"
	end,
	kr_display_name_f = function(x, y)
		if game.level.level == 1 then return "마지막 희망 공동묘지"
		elseif game.level.level == 2 then return "능묘"
		end
		return "마지막 희망 공동묘지"
	end,
	level_range = {15, 35},
	level_scheme = "player",
	max_level = 2,
	decay = {300, 800},
	actor_adjust_level = function(zone, level, e) return zone.base_level + e:getRankLevelAdjust() + level.level-1 + rng.range(-1,2) end,
	width = 50, height = 50,
	all_remembered = true,
--	all_lited = true,
	persistent = "zone",
	color_shown = {0.7, 0.7, 0.7, 1},
	color_obscure = {0.7*0.6, 0.7*0.6, 0.7*0.6, 0.6},
	ambient_music = "Inside a dream.ogg",
	min_material_level = 2,
	max_material_level = 3,
	generator =  {
		map = {
			class = "engine.generator.map.Roomer",
			nb_rooms = 10,
			rooms = {"random_room"},
			lite_room_chance = 0,
			['.'] = "FLOOR",
			['#'] = "WALL",
			up = "UP",
			down = "DOWN",
			door = "DOOR",
		},
		actor = {
			nb_npc = {0, 0},
		},
		object = {
			nb_object = {0, 0},
		},
		trap = {
			nb_trap = {0, 0},
		},
	},
	levels =
	{
		[1] = {
			generator = {
				map = {
					class = "engine.generator.map.Static",
					map = "zones/last-hope-graveyard",
				},
			},
		},
		[2] = {
			generator = {
				map = {
					class = "engine.generator.map.Static",
					map = "zones/last-hope-mausoleum",
				},
			},
		},
	},

	make_coffin = function(x, y, g)
		local r = rng.range(1, 100)
		local fct
--[[
		if r <= 10 then
			fct = function(self, x, y, who)
				local Dialog = require("engine.ui.Dialog")
				if not who:knowTalentType("cursed/cursed-aura") then
					Dialog:simplePopup("Curse!", "The coffin was a decoy, a powerful curse was set upon you (check your talents).")
					who:learnTalentType("cursed/cursed-aura", true)
					who:learnTalent(who.T_DEFILING_TOUCH, true, nil, {no_unlearn=true})
				else
					game.log("There is nothing there.")
				end
			end
		else]] if r <= 60 then
			g.sumomn_npc = game.zone:makeEntity(game.level, "actor", {properties={"undead"}, add_levels=10, random_boss={nb_classes=1, rank=3, ai = "tactical", loot_quantity = 0, no_loot_randart = true}}, nil, true)
			fct = function(self, x, y, who)
				local x, y = util.findFreeGrid(who.x, who.y, 5, true, {[engine.Map.ACTOR]=true})
				if self.sumomn_npc and x and y then
					game.zone:addEntity(game.level, self.sumomn_npc, "actor", x, y)
					self.sumomn_npc = nil
					game.log("당신보다 먼저 여기 온 존재가 있습니다. 시체가 언데드로 변해 있습니다.")
				else
					game.log("여기에는 아무 것도 없습니다.")
				end
			end
		elseif r <= 95 then
			fct = function(self, x, y, who)
				game.log("여기에는 아무 것도 없습니다.")
			end
		else
			g.coffin_obj = game.zone:makeEntity(game.level, "object", {unique=true, not_properties={"lore"}}, nil, true)
			fct = function(self, x, y, who)
				local x, y = util.findFreeGrid(who.x, who.y, 5, true, {[engine.Map.OBJECT]=true})
				if self.coffin_obj and x and y then
					game.zone:addEntity(game.level, self.coffin_obj, "object", x, y)
					self.coffin_obj = nil
					game.log("시체가 가지고 있던 보물을 찾았습니다!")
				else
					game.log("여기에는 아무 것도 없습니다.")
				end
			end
		end
		g.coffin_open = fct
	end,
	
	open_coffin = function(self, x, y, who)
		local Dialog = require("engine.ui.Dialog")
		Dialog:yesnoLongPopup("관을 열기", "죽은 자의 가족이 부자일 경우, 가끔씩 관 속에 보물을 같이 넣어두기도 합니다. 그러나, 강력한 저주가 관을 보호하고 있을 수도 있습니다. 엽니까?", 500, function(ret)
			if not ret then return end

			if self.coffin_open then
				self.coffin_open(self, x, y, who)
			end

			local g = game.zone:makeEntityByName(game.level, "terrain", "COFFIN_OPEN")
			game.zone:addEntity(game.level, g, "terrain", x, y)
		end, "예", "아니오")
	end,

	open_all_coffins = function(who, celia)
		for i = 0, game.level.map.w - 1 do for j = 0, game.level.map.h - 1 do
			game.level.map.attrs(i, j, "no_teleport", false)
		end end

		local floor = game.zone:makeEntityByName(game.level, "terrain", "FLOOR")
		local coffin_open = game.zone:makeEntityByName(game.level, "terrain", "COFFIN_OPEN")
		local spot = game.level:pickSpotRemove{type="door", subtype="chamber"}
		while spot do
			local g = game.level.map(spot.x, spot.y, engine.Map.TERRAIN)
			if g.is_door then game.zone:addEntity(game.level, floor, "terrain", spot.x, spot.y) end
			spot = game.level:pickSpotRemove{type="door", subtype="chamber"}
		end

		local spot = game.level:pickSpotRemove{type="coffin", subtype="chamber"}
		while spot do
			local g = game.level.map(spot.x, spot.y, engine.Map.TERRAIN)
			if g.define_as == "COFFIN" then
				game.zone:addEntity(game.level, coffin_open, "terrain", spot.x, spot.y)

				local m = game.zone:makeEntity(game.level, "actor", {properties={"undead"}, add_levels=10, random_boss={nb_classes=1, rank=3, ai = "tactical", loot_quantity = 0, no_loot_randart = true}}, nil, true)
				local x, y = util.findFreeGrid(spot.x, spot.y, 5, true, {[engine.Map.ACTOR]=true})
				if m and x and y then
					game.zone:addEntity(game.level, m, "actor", x, y)
					m:setTarget(who)
					m.necrotic_minion = true
					m.summoner = celia
				end
			end
			spot = game.level:pickSpotRemove{type="coffin", subtype="chamber"}
		end

		local spot = game.level:pickSpotRemove{type="stairs", subtype="stairs"}
		if spot then
			local g = game.level.map(spot.x, spot.y, engine.Map.TERRAIN)
			game.zone:addEntity(game.level, floor, "terrain", spot.x, spot.y)
		end

		game.log("#YELLOW#모든 문이 박살나는 소리가 들렸습니다.")
	end,

	on_enter = function(lev, old_lev, newzone)
		local Dialog = require("engine.ui.Dialog")
		if lev == 2 and not game.level.shown_warning then
			Dialog:simpleLongPopup("능묘", [[계단을 조심스레 밟으며 내려가자, 뒤쪽에서 큰 암석판이 미끄러져 돌아갈 모든 길을 막아 버렸습니다. 공기는 답답하게 가라앉아 있으며, 이 좁은 공간에 있는 것만으로도 마치 관에 갇혀 생매장 당한 것 같은 기분이 듭니다.

곧 이 불편하고 불안한 느낌과 공포가 사실로 드러납니다. 저 멀리에 보이는 전당의 문, 그 뒤로 거대한 악의와 부정한 공포의 힘이 느껴집니다. 복도의 끝에 있는 큰 검정색 문 아래로 희미한 빛이 보이고, 다른 모든 문들은 여기에 순종하며 굴종하고 때를 기다리며 예속되어 있을 뿐이라는 느낌이 막연히 느껴집니다...

여인이 흐느끼는 소리가 들리고, 이따금씩 고통의 신음과 비명으로 변하기도 합니다. 이 소리가 어둠의 회랑에서 메아리치고, 당신의 정신 속 가장 어두운 부분을 뚫고 들어와 당신이 저지른 모든 나쁜 행위와 비열한 죄를 상기시킵니다. 유죄라는 공포과 전율이 머리 속을 가득 채우고, 당신의 정신을 억압하고 빼앗아버릴 것 같습니다. 지금 떠오르는 유일한 생각은, 빨리 탈출하고 싶다는 것 뿐입니다.]], 600)
			game.level.shown_warning = true
		end
	end,
}
