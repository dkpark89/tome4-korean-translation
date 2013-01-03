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
name = "Reknor is lost!"
kr_display_name = "Reknor은 함락되었다!"
desc = function(self, who)
	local desc = {}
	desc[#desc+1] = "당신은 the kingdom of Reknor의 상황을 조사하기 위해 파견된 드워프의 일원이었습니다."
	desc[#desc+1] = "당신이 그곳에 도착하여 찾아낸 것은 잘 조직되고 매우 강력한 오크들 뿐이었습니다."
	desc[#desc+1] = "대부분의 동료는 거기서 죽어버렸으니 이제 유일한 생존자인 당신과 Norgan은 최대한 빨리 the Iron Council에 돌아가 이 사실을 알려야합니다."
	desc[#desc+1] = "그 무엇도 막지 못하도록 하십시오."
	if self:isCompleted("norgan-survived") then
		desc[#desc+1] = "Norgan과 당신은 고향에 돌아왔습니다."
	end
	return table.concat(desc, "\n")
end

on_status_change = function(self, who, status, sub)
	if self:isCompleted() then
		who:setQuestStatus(self.id, engine.Quest.DONE)
		who:grantQuest("deep-bellow")
		who:grantQuest("starter-zones")
	end
end

on_grant = function(self, who)
	local x, y = util.findFreeGrid(game.player.x, game.player.y, 20, true, {[engine.Map.ACTOR]=true})
	local norgan = game.zone:makeEntityByName(game.level, "actor", "NORGAN")
	game.zone:addEntity(game.level, norgan, "actor", x, y)

	game.party:addMember(norgan, {
		control="order", type="squadmate", title="Norgan",
		orders = {leash=true, anchor=true}, -- behavior=true},
	})
end
