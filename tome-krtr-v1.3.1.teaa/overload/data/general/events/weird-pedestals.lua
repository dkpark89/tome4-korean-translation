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

local function check(x, y)
	local list = {}
	for i = -1, 1 do for j = -1, 1 do
		if game.state:canEventGrid(level, x+i, y+j) then list[#list+1] = {x=x+i, y=y+j} end
	end end

	if #list < 3 then return false
	else return list end
end

local x, y = rng.range(3, level.map.w - 4), rng.range(3, level.map.h - 4)
local tries = 0
while not check(x, y) and tries < 500 do
	x, y = rng.range(3, level.map.w - 4), rng.range(3, level.map.h - 4)
	tries = tries + 1
end
if tries >= 500 then return false end

local grids = check(x, y)

for i = 1, 3 do
	local gr = rng.tableRemove(grids)
	local i, j = gr.x, gr.y

	local g = game.level.map(i, j, engine.Map.TERRAIN):cloneFull()
	g.name = "weird pedestal"
	g.kr_name = "이상한 받침대"
	g.display='&' g.color_r=255 g.color_g=255 g.color_b=255 g.notice = true
	g.always_remember = true g.special_minimap = colors.OLIVE_DRAB
	g:removeAllMOs()
	if engine.Map.tiles.nicer_tiles then
		g.add_displays = g.add_displays or {}
		g.add_displays[#g.add_displays+1] = mod.class.Grid.new{image="terrain/pedestal_01.png", display_y=-1, display_h=2}
	end
	g:altered()
	g.grow = nil g.dig = nil
	g.x = i
	g.y = j
	g.special = true
	g.block_move = function(self, x, y, who, act, couldpass)
		if not who or not who.player or not act then return false end
		who:runStop("이상한 받침대")
		if self.pedestal_activated then return false end
		require("engine.ui.Dialog"):yesnoPopup("이상한 받침대", "받침대를 조사해 보시겠습니까?", function(ret) if ret then
			who:restInit(20, "조사 중", "조사 완료", function(cnt, max)
				if cnt > max then
					self.pedestal_activated = true
					self.block_move = nil
					self.autoexplore_ignore = true
					require("engine.ui.Dialog"):simplePopup("이상한 받침대", "받침대를 조사하자 주변의 그림자가 형체를 가지게 되더니, 사람의 형태가 되었습니다!")

					local m = game.zone:makeEntity(game.level, "actor", {
						base_list=mod.class.NPC:loadList("/data/general/npcs/humanoid_random_boss.lua"),
						special_rarity="humanoid_random_boss",
						random_boss={
							nb_classes=1,
							rank=3, ai = "tactical",
							life_rating=function(v) return v * 1.3 + 2 end,
							loot_quality = "store",
							loot_quantity = 1,
							no_loot_randart = true,
							name_scheme = "#rng# the Invoker",
					}}, nil, true)
					local i, j = util.findFreeGrid(x, y, 5, true, {[engine.Map.ACTOR]=true})
					if i then
						game.level.map:particleEmitter(i, j, 1, "teleport")
						game.zone:addEntity(game.level, m, "actor", i, j)
						m.emote_random = {chance=30, "그가 올 것이다!", "너는 파멸할 것이다!!", "그가 모든 것을 먹어치울 것이다!", "내 생명은 그의 것일지니!", "침입자는 죽어라!"}
						m.pedestal_x = self.x
						m.pedestal_y = self.y
						m.on_die = function(self)
							local g = game.level.map(self.pedestal_x, self.pedestal_y, engine.Map.TERRAIN)
							g:removeAllMOs()
							if g.add_displays then
								local ov = g.add_displays[#g.add_displays]
								ov.image = "terrain/pedestal_orb_0"..rng.range(1, 5)..".png"
							end
							g.name = "weird pedestal (glowing)"
							game.level.map:updateMap(self.pedestal_x, self.pedestal_y)
							game.level.pedestal_events = (game.level.pedestal_events or 0) + 1
							game.logSeen(self, "%s의 영혼이 받침대에 흡수됩니다. 빛나는 오브가 나타났습니다.", (self.kr_name or self.name):capitalize())

							if game.level.pedestal_events >= 3 then
								game.level.pedestal_events = 0

								local m = game.zone:makeEntity(game.level, "actor", {
									base_list=mod.class.NPC:loadList{"/data/general/npcs/major-demon.lua", "/data/general/npcs/minor-demon.lua"},
									random_boss={
										nb_classes=2,
										rank=3.5, ai = "tactical",
										life_rating=function(v) return v * 2 + 5 end,
										loot_quantity = 0,
										no_loot_randart = true,
										name_scheme = "#rng# the Bringer of Doom",
										on_die = function(self) world:gainAchievement("EVENT_PEDESTALS", game:getPlayer(true)) end,
								}}, nil, true)

								local i, j = util.findFreeGrid(x, y, 5, true, {[engine.Map.ACTOR]=true})
								if i then
									game.level.map:particleEmitter(i, j, 1, "teleport")
									game.zone:addEntity(game.level, m, "actor", i, j)
									local o = game.zone:makeEntity(game.level, "object", {unique=true, not_properties={"lore"}}, nil, true)
									if not o then -- create artifact or randart
										o = game.state:generateRandart{lev=resolvers.current_level+10}
									end
									if o then
										game.zone:addEntity(game.level, o, "object")
										m:addObject(m.INVEN_INVEN, o)
									end
									require("engine.ui.Dialog"):simplePopup("이상한 받침대", "끔직한 목소리가 들립니다. '그들의 생명은 나의 것이다! 내가 간다!'")
								end
							end
						end
					end
				end
			end)
		end end)
		return false
	end
	game.zone:addEntity(game.level, g, "terrain", i, j)
	print("[EVENT] 이상한 받침대는 여기에 있습니다 : ", i, j)
end

return true
