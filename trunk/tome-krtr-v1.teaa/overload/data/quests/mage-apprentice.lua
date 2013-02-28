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

name = "An apprentice task"
kr_display_name = "견습 마법사의 임무"
desc = function(self, who)
	local desc = {}
	desc[#desc+1] = "당신은 마법의 힘이 깃든 고대 유물을 찾으라는 임무를 받은, 초보 마법사를 만났습니다."
	desc[#desc+1] = "그는 당신에게 도움을 요청했습니다. 여행 중에 조건을 만족하면서 필요는 없는 물건을 구하게 되면, 그에게 가져다주기로 했습니다."
	if self:isCompleted() then
	else
		desc[#desc+1] = "#SLATE#* 마법의 힘이 깃든 고대 유물 하나 모으기#WHITE#"
	end
	return table.concat(desc, "\n")
end

on_grant = function(self, who)
	self.nb_collect = 0
end

on_status_change = function(self, who, status, sub)
	if sub then
		if self:isCompleted() then
			who:setQuestStatus(self.id, engine.Quest.DONE)
		end
	end
end

collect_staff_unique = function(self, npc, who, dialog)
	who:showInventory("무슨 물건을 줍니까?", who:getInven("INVEN"),
		function(o) return o.power_source and o.power_source.arcane and o.unique
		end,
		function(o, item)
			-- Special handling for the staff of absorption
			if o.define_as and o.define_as == "STAFF_ABSORPTION" then
				game.logPlayer(who, "#LIGHT_RED#견습 마법사가 지팡이를 만지자, 그가 비명을 지르기 시작했습니다. 그의 입에서 불꽃이 마구 뿜어져 나오며, 그의 생명력이 지팡이에 흡수되는 것이 느껴졌습니다. 그리고 순식간에, 그는 생명이 없는 빈 껍데기가 되어 쓰러졌습니다.")
				who:setQuestStatus(self, self.FAILED)
				game:unregisterDialog(dialog.next_dialog)
				game.level.map:particleEmitter(npc.x, npc.y, 3, "fireflash", {radius=3, tx=npc.x, ty=npc.y})
				world:gainAchievement("APPRENTICE_STAFF", player)
				npc:die()
				return true
			end

			self.nb_collect = self.nb_collect + 1
			if self.nb_collect >= 1 then who:setQuestStatus(self, self.COMPLETED) end
			who:removeObject(who:getInven("INVEN"), item)
			game.log("당신은 견습 마법사에게 물건을 주었습니다 : %s", o:getName{no_count=true, do_color=true})
			who:sortInven(who:getInven(inven))
			dialog:regen()
			return true
		end
	)
end

can_offer_unique = function(self, who)
	if self.nb_collect >= 1 then return end
	if not who:getInven("INVEN") then return end

	for item, o in ipairs(who:getInven("INVEN")) do
		if o.power_source and o.power_source.arcane and o.unique then return true end
	end
end

access_angolwen = function(self, player)
	if player:hasQuest("antimagic") and not player:hasQuest("antimagic"):isEnded() then player:setQuestStatus("antimagic", engine.Quest.FAILED) end -- Fail antimagic quest

	local level = game.level
	local g = game.zone:makeEntityByName(game.level, "terrain", "TOWN_ANGOLWEN")
	local p = game.zone:makeEntityByName(game.level, "terrain", "TOWN_ANGOLWEN_PORTAL")
	local spot = level:pickSpot{type="zone-pop", subtype="angolwen"}
	game.zone:addEntity(level, g, "terrain", spot.x, spot.y)
	game.nicer_tiles:updateAround(game.level, spot.x, spot.y)
	game.state:locationRevealAround(spot.x, spot.y)
	spot = level:pickSpot{type="zone-pop", subtype="angolwen-portal"}
	game.zone:addEntity(level, p, "terrain", spot.x, spot.y)
	game.nicer_tiles:updateAround(game.level, spot.x, spot.y)
	game.state:locationRevealAround(spot.x, spot.y)

	game:setAllowedBuild("mage", true)
	world:gainAchievement("THE_SECRET_CITY", player)
	player:setQuestStatus(self, self.DONE)
	player:attr("angolwen_access", 1)
end

ring_gift = function(self, player)
	if player:hasQuest("antimagic") and not player:hasQuest("antimagic"):isEnded() then player:setQuestStatus("antimagic", engine.Quest.FAILED) end -- Fail antimagic quest

	local o = game.zone:makeEntity(game.level, "object", {type="jewelry", subtype="ring", tome_drops="boss"}, player.level + 5, true)
	if o then
		o:identify(true)
		player:addObject(player.INVEN_INVEN, o)
		game.zone:addEntity(game.level, o, "object")
		game.logPlayer(player, "당신은 선물을 받았습니다 : %s", o:getName{do_color=true})
	end
	player:setQuestStatus(self, self.DONE)
end
