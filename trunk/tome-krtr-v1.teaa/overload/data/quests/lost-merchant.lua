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

name = "Trapped!"
kr_display_name = "함정이다!"
desc = function(self, who)
	local desc = {}
	desc[#desc+1] = "당신은 도움을 원하는 간청을 듣고, 조사를 해보기로 결심했습니다..."
	desc[#desc+1] = "함정에 갇힌 이상, 이 알지 못할 곳을 헤쳐나가는 것만이 유일한 길이 될 것 같습니다."
	return table.concat(desc, "\n")
end

on_status_change = function(self, who, status, sub)
	if sub and sub == "evil" then
		game.level.map(who.x, who.y, game.level.map.TERRAIN, game.zone.grid_list.UP_WILDERNESS)
		game.logPlayer(who, "발 밑에 위로 올라가는 계단이 솟아났습니다. 암살단 단장이 말했습니다. '기억해라, 너는 네 것이라는 사실을. 나중에 부르도록 하지.'")
	end

	if self:isCompleted() then
		who:setQuestStatus(self.id, engine.Quest.DONE)
	end
end

leave_zone = function(self, who)
	if self:isStatus(self.COMPLETED, "evil") then return end
	local merchant_alive = false
	for uid, e in pairs(game.level.entities) do
		if e.is_merchant and not e.dead then
			merchant_alive = true
			break
		end
	end
	if merchant_alive then
		game.logPlayer(who, "#LIGHT_BLUE#상인이 자신의 목숨을 구해준 것에 대해 감사를 표했습니다. 그는 당신에게 금화 8 개를 주었으며, 마지막 희망에서 다시 볼 것을 청했습니다.")
		who:incMoney(8)
		who.changed = true
		who:setQuestStatus(self.id, engine.Quest.COMPLETED, "saved")
		world:gainAchievement("LOST_MERCHANT_RESCUE", game.player)
	end
	who:setQuestStatus(self.id, engine.Quest.COMPLETED)
end

is_assassin_alive = function(self)
	local assassin_alive = false
	for uid, e in pairs(game.level.entities) do
		if e.is_assassin_lord and not e.dead then
			assassin_alive = true
			break
		end
	end
	return assassin_alive
end
