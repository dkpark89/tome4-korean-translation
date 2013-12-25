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

name = "There and back again"
kr_name = "그곳에 또 다시"
desc = function(self, who)
	local desc = {}
	desc[#desc+1] = "아침의 문에 있는 제메키스는 당신을 위해 마즈'에이알로 돌아가는 관문을 만들 수 있습니다."

	if self:isCompleted("athame") then
		desc[#desc+1] = "#LIGHT_GREEN#* 당신은 피의 룬 제례단검을 찾았습니다.#WHITE#"
	else
		desc[#desc+1] = "#SLATE#* 피의 룬 제례단검을 찾아야 합니다.#WHITE#"
	end
	if self:isCompleted("gem") then
		desc[#desc+1] = "#LIGHT_GREEN#* 당신은 공명하는 다이아몬드를 찾았습니다.#WHITE#"
	else
		desc[#desc+1] = "#SLATE#* 당신은 공명하는 다이아몬드를 찾아야 합니다.#WHITE#"
	end

	if self:isCompleted() then
		desc[#desc+1] = ""
		desc[#desc+1] = "#LIGHT_GREEN#* 마즈'에이알로 돌아가는 관문이 작동하기 시작했습니다. 이제 마즈'에이알로 돌아갈 수는 있지만, 다른 장거리 관문들처럼, 이 관문 역시 단방향 관문입니다.#WHITE#"
	end

	return table.concat(desc, "\n")
end

on_grant = function(self, who)
	-- Reveal entrances
	game:onLevelLoad("wilderness-1", function(zone, level)
		local g = game.zone:makeEntityByName(level, "terrain", "VOR_ARMOURY")
		local spot = level:pickSpot{type="zone-pop", subtype="vor-armoury"}
		game.zone:addEntity(level, g, "terrain", spot.x, spot.y)
		game.nicer_tiles:updateAround(game.level, spot.x, spot.y)
		game.state:locationRevealAround(spot.x, spot.y)
	end)

	game.logPlayer(game.player, "제메키스가 당신의 지도에 보르 무기고의 위치를 표시해줬습니다.")
end

wyrm_lair = function(self, who)
	-- Reveal entrances
	game:onLevelLoad("wilderness-1", function(zone, level)
		local g = game.zone:makeEntityByName(level, "terrain", "BRIAGH_LAIR")
		local spot = level:pickSpot{type="zone-pop", subtype="briagh"}
		game.zone:addEntity(level, g, "terrain", spot.x, spot.y)
		game.nicer_tiles:updateAround(game.level, spot.x, spot.y)
	end)

	game.logPlayer(game.player, "제메키스가 당신의 지도에 브리아그흐의 동굴이 있는 곳을 표시해줬습니다.")
end

create_portal = function(self, npc, player)
	-- Farportal
	local g1 = game.zone:makeEntityByName(game.level, "terrain", "WEST_PORTAL")
	local g2 = game.zone:makeEntityByName(game.level, "terrain", "CWEST_PORTAL")

	game.logPlayer(game.player, "#VIOLET#제메키스가 보석과 제례단검을 이용해 바닥에 룬 문자를 그리기 시작했습니다.")
	game.logPlayer(game.player, "#VIOLET#땅이 흔들리기 시작합니다!")
	game.logPlayer(game.player, "#VIOLET#제메키스가 말했습니다. '관문이 완성되었네!'")

	-- Zemekkys is not in his home anymore
	npc.block_move = true

	-- Add Zemekkys near the portal
	local zemekkys = mod.class.NPC.new{
		type = "humanoid", subtype = "elf",
		display = "p", color=colors.AQUAMARINE,
		name = "High Chronomancer Zemekkys",
		kr_name = "고위 시공 제어사 제메키스",
		size_category = 3, rank = 3,
		ai = "none",
		faction = "sunwall",
		can_talk = "zemekkys-done",
	}
	zemekkys:resolve() zemekkys:resolve(nil, true)

	local spot = game.level:pickSpot{type="pop-quest", subtype="farportal-npc"}
	game.zone:addEntity(game.level, zemekkys, "actor", spot.x, spot.y)

	local spot = game.level:pickSpot{type="pop-quest", subtype="farportal"}
	game.zone:addEntity(game.level, g1, "terrain", spot.x, spot.y)
	game.zone:addEntity(game.level, g1, "terrain", spot.x+1, spot.y)
	game.zone:addEntity(game.level, g1, "terrain", spot.x+2, spot.y)
	game.zone:addEntity(game.level, g1, "terrain", spot.x, spot.y+1)
	game.zone:addEntity(game.level, g2, "terrain", spot.x+1, spot.y+1)
	game.zone:addEntity(game.level, g1, "terrain", spot.x+2, spot.y+1)
	game.zone:addEntity(game.level, g1, "terrain", spot.x, spot.y+2)
	game.zone:addEntity(game.level, g1, "terrain", spot.x+1, spot.y+2)
	game.zone:addEntity(game.level, g1, "terrain", spot.x+2, spot.y+2)

	local spot = game.level:pickSpot{type="pop-quest", subtype="farportal-player"}
	player:move(spot.x, spot.y, true)

	player:setQuestStatus(self.id, engine.Quest.DONE)
	world:gainAchievement("WEST_PORTAL", game.player)
	player:grantQuest("east-portal")
end
