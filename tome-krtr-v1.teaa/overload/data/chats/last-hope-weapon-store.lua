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

newChat{ id="welcome",
	text = [[상점에 오신 것을 환영하오, @playername@ 씨.]],
	answers = {
		{"파는 물건들을 보고 싶습니다.", action=function(npc, player)
			npc.store:loadup(game.level, game.zone)
			npc.store:interact(player)
		end},
		{"육체적 훈련을 받기 위해 왔습니다.", jump="training"},
		{"미안합니다, 이만 가볼게요!"},
	}
}

newChat{ id="training",
	text = [[물론 가능하지. 육체적 훈련 (물리 / 전투장비 수련) 에는 금화 50 개, 기초적인 활과 투석구 사용법 (사격 기술) 은 금화 8 개를 요금으로 받고 있다네.]],
	answers = {
		{"기본적인 무기와 방어구 사용법 훈련을 받고 싶습니다.", action=function(npc, player)
			game.logPlayer(player, "대장장이는 당신과 시간을 보내면서, 기본적인 무기와 방어구 사용법을 알려주었습니다.")
			player:incMoney(-50)
			player:learnTalentType("technique/combat-training", true)
			player.changed = true
		end, cond=function(npc, player)
			if player.money < 50 then return end
			if player:knowTalentType("technique/combat-training") then return end
			return true
		end},
		{"기초적인 활과 투석구 사용법을 배우고 싶습니다.", action=function(npc, player)
			game.logPlayer(player, "대장장이는 당신과 시간을 보내면서, 기초적인 활과 투석구 사용법을 알려주었습니다.")
			player:incMoney(-8)
			player:learnTalent(player.T_SHOOT, true, nil, {no_unlearn=true})
			player.changed = true
		end, cond=function(npc, player)
			if player.money < 8 then return end
			if player:knowTalent(player.T_SHOOT) then return end
			return true
		end},
		{"사양하겠습니다."},
	}
}

return "welcome"
