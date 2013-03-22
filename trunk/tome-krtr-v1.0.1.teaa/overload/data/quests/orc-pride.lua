-- ToME - Tales of Maj'Eyal
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

name = "The many Prides of the Orcs"
kr_name = "수많은 오크의 긍지들"
desc = function(self, who)
	local desc = {}
	desc[#desc+1] = "오크 긍지들이 있는 곳을 조사해야 합니다."

	if self:isCompleted("rak-shor") then
		desc[#desc+1] = "#LIGHT_GREEN#* 당신은 락'쇼르를 처치했습니다.#WHITE#"
	else
		desc[#desc+1] = "#SLATE#* 락'쇼르 긍지, 남쪽에 있는 사막의 서쪽 지역#WHITE#"
	end
--[[
	if self:isCompleted("eastport") then
		desc[#desc+1] = "#LIGHT_GREEN#* You have killed the master of Eastport.#WHITE#"
	else
		desc[#desc+1] = "#SLATE#* A group of corrupted Humans live in Eastport on the southern coastline. They have contact with the Pride.#WHITE#"
	end
]]
	if self:isCompleted("vor") then
		desc[#desc+1] = "#LIGHT_GREEN#* 당신은 보르를 처치했습니다.#WHITE#"
	else
		desc[#desc+1] = "#SLATE#* 보르 긍지, 북동쪽.#WHITE#"
	end
	if self:isCompleted("grushnak") then
		desc[#desc+1] = "#LIGHT_GREEN#* 당신은 그루쉬낙을 처치했습니다.#WHITE#"
	else
		desc[#desc+1] = "#SLATE#* 그루쉬낙 긍지, 북서쪽에 있는 작은 산 너머#WHITE#"
	end
	if self:isCompleted("gorbat") then
		desc[#desc+1] = "#LIGHT_GREEN#* 당신은 고르뱃을 처치했습니다.#WHITE#"
	else
		desc[#desc+1] = "#SLATE#* 고르뱃 긍지, 남쪽에 있는 사막의 산 너머#WHITE#"
	end

	if self:isCompleted() then
		desc[#desc+1] = ""
		desc[#desc+1] = "#LIGHT_GREEN#* 모든 오크 긍지들은 파괴되고, 그들의 지도자는 죽음을 맞이했습니다. 고위 태양의 기사 아에린이 이 소식을 들으면 굉장히 기뻐할 것입니다!#WHITE#"
	end

	return table.concat(desc, "\n")
end

on_grant = function(self, who)
	-- Reveal entrances
	game:onLevelLoad("wilderness-1", function(zone, level)
		local g = game.zone:makeEntityByName(level, "terrain", "RAK_SHOR_PRIDE")
		local spot = level:pickSpot{type="zone-pop", subtype="rak-shor-pride"}
		game.zone:addEntity(level, g, "terrain", spot.x, spot.y)
		game.nicer_tiles:updateAround(game.level, spot.x, spot.y)
		game.state:locationRevealAround(spot.x, spot.y)

		g = game.zone:makeEntityByName(level, "terrain", "VOR_PRIDE")
		local spot = level:pickSpot{type="zone-pop", subtype="vor-pride"}
		game.zone:addEntity(level, g, "terrain", spot.x, spot.y)
		game.nicer_tiles:updateAround(game.level, spot.x, spot.y)
		game.state:locationRevealAround(spot.x, spot.y)

		g = game.zone:makeEntityByName(level, "terrain", "GORBAT_PRIDE")
		local spot = level:pickSpot{type="zone-pop", subtype="gorbat-pride"}
		game.zone:addEntity(level, g, "terrain", spot.x, spot.y)
		game.nicer_tiles:updateAround(game.level, spot.x, spot.y)
		game.state:locationRevealAround(spot.x, spot.y)

		g = game.zone:makeEntityByName(level, "terrain", "GRUSHNAK_PRIDE")
		local spot = level:pickSpot{type="zone-pop", subtype="grushnak-pride"}
		game.zone:addEntity(level, g, "terrain", spot.x, spot.y)
		game.nicer_tiles:updateAround(game.level, spot.x, spot.y)
		game.state:locationRevealAround(spot.x, spot.y)
	end)
end

on_status_change = function(self, who, status, sub)
	if sub then
		if self:isCompleted("rak-shor") and self:isCompleted("vor") and self:isCompleted("grushnak") and self:isCompleted("gorbat") then
			who:setQuestStatus(self.id, engine.Quest.COMPLETED)
			world:gainAchievement("ORC_PRIDE", game.player)
		end
	end
end
