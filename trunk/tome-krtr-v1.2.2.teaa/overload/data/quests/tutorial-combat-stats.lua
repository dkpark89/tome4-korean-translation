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

name = "Tutorial: combat stats"
kr_name = "연습 게임 : 전투 능력치"
desc = function(self, who)

	local desc = {}
--[=[
	if self:isCompleted("started-basic-gameplay") and not self:isCompleted("finished-basic-gameplay") then
		desc[#desc+1] = "당신은 숲은 가운데까지 탐험을 하여, 임의로 주민을 공격하는 '외로운 한 마리 늑대'를 죽여야 합니다."
	end
	if self:isCompleted("finished-basic-gameplay") then
		desc[#desc+1] = "#LIGHT_GREEN#당신은 '외로운 한 마리 늑대'를 물리쳤습니다!#WHITE#"
	end
]=]
	if not self:isCompleted("finished-combat-stats") then
		desc[#desc+1] = "ToME4 의 전투 규칙을 배우기 위해, 초보 모험가를 위한 계몽의 지하미궁을 탐험하십시오."
	end
	if self:isCompleted("finished-combat-stats") then
		desc[#desc+1] = "#LIGHT_GREEN#당신은 초보 모험가를 위한 계몽의 지하미궁을 통과했습니다!#WHITE#"
	end
	return table.concat(desc, "\n")
end

on_status_change = function(self, who, status, sub)
	if self:isCompleted() then
		who:setQuestStatus(self.id, engine.Quest.DONE)
		--world:gainAchievement({id="TUTORIAL_DONE",no_difficulties=true}, game.player)
	end
end

final_message = function(self)
	if self:isCompleted("finished-basic-gameplay") and self:isCompleted("finished-combat-stats") then
		game.player:resolveSource():setQuestStatus("tutorial", engine.Quest.COMPLETED)
		local d = require("engine.dialogs.ShowText").new("연습게임 완료", "tutorial/done")
		game:registerDialog(d)
	end
end
--[=[
choose_basic_gameplay = function()
	game.player.combat_atk = 0
	game.player.combat_dam = 0
	game.player.combat_spellpower = 0
	game.player.combat_def = 0
	game.player.combat_physresist = 0
	game.player.combat_spellresist = 0
	game.player.combat_mentalresist = 0
	local d = require("engine.dialogs.ShowText").new("기본적인 게임진행", "tutorial/basic-intro")
	game:registerDialog(d)
end

choose_combat_stats = function(self, who, status, sub)
	game.player.combat_atk = 24
	game.player.combat_dam = 7
	game.player.combat_spellpower = 88
	game.player.combat_def = 18
	game.player.combat_physresist = 10
	game.player.combat_spellresist = 116
	game.player.combat_mentalresist = 62
	local d = require("engine.dialogs.ShowText").new("전투 능력치 규칙", "tutorial/combat-stats-intro")
	game:registerDialog(d)
end
]=]
on_grant = function(self)
	game.player.combat_atk = 25
	game.player.combat_dam = 7
	game.player.combat_spellpower = 88
	game.player.combat_def = 18
	game.player.combat_physresist = 10
	game.player.combat_spellresist = 116
	game.player.combat_mentalresist = 62
--	local d = require("engine.dialogs.ShowText").new("Combat stat mechanics", "tutorial/combat-stats-intro")
--	game:registerDialog(d)
end
