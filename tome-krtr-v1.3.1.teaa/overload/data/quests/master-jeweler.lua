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

name = "Lost Knowledge"
kr_name = "잊혀진 지식"
desc = function(self, who)
	local desc = {}
	desc[#desc+1] = "당신은 보석에 대해 적힌 고대의 서적을 발견하였습니다."
	desc[#desc+1] = "아침의 문에 있는 보석 세공사에게 가져다주어야 할 것 같습니다."
	if self:isCompleted("search-valley") then
		desc[#desc+1] = "리미르는 남쪽 산맥에 있는 달의 골짜기를 조사해보라고 했습니다."
	end
	return table.concat(desc, "\n")
end

on_grant = function(self, who)
	game.logPlayer(who, "#VIOLET#이 책은 보석의 힘에 대해 적혀있는 것 같습니다. 아침의 문에 있는 보석 세공사에게 가져다주어야 할 것 같습니다.")
end

has_tome = function(self, who)
	for inven_id, inven in pairs(who.inven) do
		for item, o in ipairs(inven) do
			if o.type == "scroll" and o.subtype == "tome" and o.define_as == "JEWELER_TOME" then return o, inven_id, item end
		end
	end
end

has_scroll = function(self, who)
	for inven_id, inven in pairs(who.inven) do
		for item, o in ipairs(inven) do
			if o.type == "scroll" and o.subtype == "tome" and o.define_as == "JEWELER_SUMMON" then return o, inven_id, item end
		end
	end
end

remove_tome = function(self, who)
	local o, inven, item = self:has_tome(who)
	who:removeObject(inven, item)
end

start_search = function(self, who)
	-- Reveal entrances
	game:onLevelLoad("wilderness-1", function(zone, level)
		local g = game.zone:makeEntityByName(level, "terrain", "CAVERN_MOON")
		local spot = level:pickSpot{type="zone-pop", subtype="valley-moon-caverns"}
		game.zone:addEntity(level, g, "terrain", spot.x, spot.y)
		game.nicer_tiles:updateAround(game.level, spot.x, spot.y)
		game.state:locationRevealAround(spot.x, spot.y)
	end)

	who:setQuestStatus(self.id, engine.Quest.COMPLETED, "search-valley")
	game.logPlayer(game.player, "리미르가 당신의 지도에 동굴의 입구를 표시해줬습니다. 아마 이곳을 통해 달의 골짜기로 들어갈 수 있는 것 같습니다.")

	local o = game.zone:makeEntityByName(game.level, "object", "JEWELER_SUMMON")
	if o then who:addObject(who:getInven("INVEN"), o) end
end

summon_limmir = function(self, who)
	if not game.level.map.attrs(who.x, who.y, "summon_limmir") then
		game.logPlayer(who, "리미르를 부르기 위해서는 먼저 월장석 근처에 가야합니다.")
		return
	end

	local o, inven, item = self:has_scroll(who)
	if not o then game.logPlayer(who, "소환의 두루마리가 없습니다!") return end
	who:removeObject(inven, item)

	local limmir = game.zone:makeEntityByName(game.level, "actor", "LIMMIR")
	limmir.limmir_target = {x=42, y=11}
	limmir.limmir_target2 = {x=24, y=25}
	limmir.no_inventory_access = true
	limmir.remove_from_party_on_death = true
	limmir.no_party_ai = true
	game.zone:addEntity(game.level, limmir, "actor", 45, 1)

	game.party:addMember(limmir, {type="quest", title="Limmir (Quest)", temporary_level = true})
end

ritual_end = function(self)
	local limmir = nil
	for i, e in pairs(game.level.entities) do
		if e.define_as and e.define_as == "LIMMIR" then limmir = e break end
	end

	if not limmir then
		game.player:setQuestStatus(self.id, engine.Quest.COMPLETED, "limmir-dead")
		game.player:setQuestStatus(self.id, engine.Quest.FAILED)
		return
	end

	game.player:setQuestStatus(self.id, engine.Quest.COMPLETED, "limmir-survived")
	game.player:setQuestStatus(self.id, engine.Quest.DONE)
	world:gainAchievement("MASTER_JEWELER", game.player)

	for i = #game.level.e_array, 1, -1 do
		local e = game.level.e_array[i]
		if not e.unique and e.type == "demon" then e:die() end
	end
	limmir.name = "Limmir the Master Jeweler"
	limmir.kr_name = "보석 세공의 명인 리미르"
	limmir.can_talk = "jewelry-store"

	game.party:removeMember(limmir)

	-- Update water
	local water = game.zone:makeEntityByName(game.level, "terrain", "DEEP_WATER")
	for x = 0, game.level.map.w - 1 do for y = 0, game.level.map.h - 1 do
		local g = game.level.map(x, y, engine.Map.TERRAIN)
		if g and g.define_as == "POISON_DEEP_WATER" then
			game.level.map(x, y, engine.Map.TERRAIN, water)
		end
	end end
end
