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
name = "Reknor is lost!"
kr_name = "레크놀은 함락되었다!"
desc = function(self, who)
	local desc = {}
	desc[#desc+1] = "당신은 레크놀 왕국의 상황을 조사하기 위해 파견된 드워프의 일원이었습니다."
	desc[#desc+1] = "당신이 그곳에 도착하여 찾아낸 것이라고는, 잘 조직되고 매우 강력한 오크들 뿐이었습니다."
	desc[#desc+1] = "대부분의 동료들은 오크의 공격에 의해 사망하였고, 이제 당신과 동료인 노르간 둘만이 살아남았습니다. 최대한 빨리 철의 평의회로 돌아가 이 사실을 알려야 합니다."
	desc[#desc+1] = "그 무엇도 당신을 막지 못하게 하십시오."
	if self:isCompleted("norgan-survived") then
		desc[#desc+1] = "노르간과 당신 둘 다 성공적으로 마을에 도착했습니다."
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
