﻿-- ToME - Tales of Maj'Eyal
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

name = "Tutorial"
kr_name = "연습 게임"
desc = function(self, who)
	local desc = {}
	desc[#desc+1] = "당신은 숲의 중심부까지 탐험을 하여, 마구잡이로 주민들을 공격하는 '외로운 한 마리 늑대' 를 처치해야 합니다."
	return table.concat(desc, "\n")
end

on_status_change = function(self, who, status, sub)
	if self:isCompleted() then
		who:setQuestStatus(self.id, engine.Quest.DONE)
		world:gainAchievement({id="TUTORIAL_DONE",no_difficulties=true}, game.player)
	end
end

on_grant = function(self)
	local d = require("engine.dialogs.ShowText").new("게임 배우기 : 이동", "tutorial/move")
	game:registerDialog(d)
end
