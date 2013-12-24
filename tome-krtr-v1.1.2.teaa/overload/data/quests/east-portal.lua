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

name = "Back and there again"
kr_name = "다시 또 그 곳에"
desc = function(self, who)
	local desc = {}
	desc[#desc+1] = "당신은 마즈'에이알로 돌아갈 수 있는 관문을 만들었습니다. 마지막 희망에 있는 누군가와 대화를 해서, 동대륙에 다시 갈 수 있는 관문을 만들어야 할 것 같습니다."

	if self:isCompleted("talked-elder") then
		desc[#desc+1] = "당신은 마지막 희망의 장로에게서 탄넨과 이야기 해보라는 말을 들었습니다. 그는 도시 북쪽에 살고 있습니다."
	end

	if self:isCompleted("gave-orb") then
		desc[#desc+1] = "당신은 레크놀에서 제례단검과 다이아몬드를 찾는 동안 그가 연구할 수 있도록, 탄넨에게 여러 장소로의 오브를 주었습니다."
	end
	if self:isCompleted("withheld-orb") then
		desc[#desc+1] = "탄넨이 여러 장소로의 오브를 연구하기 위해 잠시 빌려줄 것을 요구했지만, 당신은 이를 거절했습니다. 이제 레크놀에 가서 제례단검과 다이아몬드를 찾아봐야 합니다."
	end
	if self:isCompleted("open-telmur") then
		desc[#desc+1] = "탄넨에게 제례단검과 다이아몬드를 전해주자, 그는 텔무르의 탑에 가서 관문과 관련된 글이 있을지도 모르니, 그곳에 가서 글을 찾아보라고 했습니다. 또한, 그는 당신에게 며칠이 지난 후에 돌아올 것을 요구했습니다."
	end
	if self:isCompleted("ask-east") then
		desc[#desc+1] = "탄넨에게 제례단검과 다이아몬드를 전해주자, 그는 제메키스에게 돌아가 몇 가지 질문을 해줄 것을 요구했습니다."
	end
	if self:isCompleted("just-wait") then
		desc[#desc+1] = "탄넨에게 제례단검과 다이아몬드를 전해주자, 그는 당신에게 며칠이 지난 후에 돌아올 것을 요구했습니다."
	end
	if self:isCompleted("tricked-demon") then
		desc[#desc+1] = "탄넨은 당신을 속였습니다! 그는 오브를 악마들의 공간으로 이동시키는 가짜와 바꿔치기 했습니다. 출구를 찾고, 그에게 복수를 해야합니다!"
	end
	if self:isCompleted("trapped") then
		desc[#desc+1] = "탄넨은 자신의 추악한 본모습을 드러내었으며, 당신을 그의 탑에 가두었습니다."
	end

	if self:isCompleted() then
		desc[#desc+1] = ""
		desc[#desc+1] = "#LIGHT_GREEN#* 동대륙으로 돌아가는 관문이 활성화 되었습니다. 이것을 사용해 동대륙으로 갈 수 있을 것 같습니다.#WHITE#"
	end

	return table.concat(desc, "\n")
end

on_status_change = function(self, who, status, sub)
	if sub then
		if self:isCompleted("orb-back") and self:isCompleted("diamon-back") and self:isCompleted("athame-back") then
			self:tannen_exit(who)
			
			if game:getPlayer(true).alchemy_golem then
				game:setAllowedBuild("cosmetic_class_alchemist_drolem", true)
			end
		end
	end
end

create_portal = function(self, npc, player)
	self:remove_materials(player)

	-- Farportal
	local g1 = game.zone:makeEntityByName(game.level, "terrain", "FAR_EAST_PORTAL")
	local g2 = game.zone:makeEntityByName(game.level, "terrain", "CFAR_EAST_PORTAL")
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

	player:setQuestStatus(self.id, engine.Quest.DONE)
	world:gainAchievement("EAST_PORTAL", game.player)
end

give_orb = function(self, player)
	player:setQuestStatus(self.id, engine.Quest.COMPLETED, "gave-orb")

	local orb_o, orb_item, orb_inven_id = player:findInAllInventories("Orb of Many Ways")
	player:removeObject(orb_inven_id, orb_item, true)
	orb_o:removed()
end

withheld_orb = function(self, player)
	player:setQuestStatus(self.id, engine.Quest.COMPLETED, "withheld-orb")
end

remove_materials = function(self, player)
	local gem_o, gem_item, gem_inven_id = player:findInAllInventories("Resonating Diamond")
	player:removeObject(gem_inven_id, gem_item, false)
	gem_o:removed()

	local athame_o, athame_item, athame_inven_id = player:findInAllInventories("Blood-Runed Athame")
	player:removeObject(athame_inven_id, athame_item, false)
	athame_o:removed()
end

open_telmur = function(self, player)
	self:remove_materials(player)

	-- Reveal entrances
	game:onLevelLoad("wilderness-1", function(zone, level)
		local g = game.zone:makeEntityByName(level, "terrain", "TELMUR")
		local spot = level:pickSpot{type="zone-pop", subtype="telmur"}
		game.zone:addEntity(level, g, "terrain", spot.x, spot.y)
		game.nicer_tiles:updateAround(game.level, spot.x, spot.y)
		game.state:locationRevealAround(spot.x, spot.y)
	end)

	game.logPlayer(game.player, "탄넨이 텔무르로 가는 길을 당신의 지도에 표시해줬습니다.")
	player:setQuestStatus(self.id, engine.Quest.COMPLETED, "open-telmur")
	self.wait_turn = game.turn + game.calendar.DAY * 3
end

ask_east = function(self, player)
	self:remove_materials(player)

	-- Swap the orbs! Tricky bastard!
	local orb_o, orb_item, orb_inven_id = player:findInAllInventories("Orb of Many Ways")
	player:removeObject(orb_inven_id, orb_item, true)
	orb_o:removed()

	local demon_orb = game.zone:makeEntityByName(game.level, "object", "ORB_MANY_WAYS_DEMON")
	player:addObject(orb_inven_id, demon_orb)
	demon_orb:added()

	player:setQuestStatus(self.id, engine.Quest.COMPLETED, "ask-east")
end

tannen_tower = function(self, player)
	game:changeLevel(1, "tannen-tower", {direct_switch=true})
	player:setQuestStatus(self.id, engine.Quest.COMPLETED, "trapped")
end

tannen_exit = function(self, player)
	require("engine.ui.Dialog"):simplePopup("다시 또 그 곳에", "탑 중앙에 관문이 생겨났습니다!")
	local g = game.zone:makeEntityByName(game.level, "terrain", "PORTAL_BACK")
	game.zone:addEntity(game.level, g, "terrain", 12, 12)
end

back_to_last_hope = function(self)
	-- TP last hope
	game:changeLevel(1, "town-last-hope", {direct_switch=true})
	-- Move to the portal spot
	local spot = game.level:pickSpot{type="pop-quest", subtype="farportal-player"}
	game.player:move(spot.x, spot.y, true)
	-- Remove tannen
	local spot = game.level:pickSpot{type="pop-quest", subtype="tannen-remove"}
	game.level.map(spot.x, spot.y, engine.Map.TERRAIN, game.level.map(spot.x, spot.y-1, engine.Map.TERRAIN))

	-- Add the mage
	local g = mod.class.NPC.new{
		name="Meranas, Herald of Angolwen",
		kr_name="앙골웬의 전령, 메라나스",
		type="humanoid", subtype="human", faction="angolwen",
		display='p', color=colors.RED,
	}
	g:resolve() g:resolve(nil, true)
	local spot = game.level:pickSpot{type="pop-quest", subtype="farportal-npc"}
	game.zone:addEntity(game.level, g, "actor", spot.x, spot.y)
	game.level.map:particleEmitter(spot.x, spot.y, 1, "teleport")
	game.nicer_tiles:postProcessLevelTiles(game.level)

	local Chat = require("engine.Chat")
	local chat = Chat.new("east-portal-end", g, game.player)
	chat:invoke()
	game.logPlayer(who, "#VIOLET#회오리치는 관문에 들어가자, 당신은 눈 깜짝할 사이에 마지막 희망으로 돌아왔습니다.")
end
