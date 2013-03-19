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

newChat{ id="welcome",
	text = [[@playername@씨, 저희 가게에 오신 것을 환영합니다.]],
	answers = {
		{"무엇을 파는지 알고 싶은데요.", action=function(npc, player)
			npc.store:loadup(game.level, game.zone)
			npc.store:interact(player)
		end},
		{"마석 수련을 받기 위해 왔어요.", jump="training"},
		{"미안합니다, 이만 가볼게요!"},
	}
}

newChat{ id="training",
	text = [[금화 100개면 자연의 권능 중 마석 수련 계열의 기초를 간략히 설명해 줄 수 있지요 (비활성화 상태로 해당 기술 계열 습득). 아니면, 금화 750개로 더욱 깊이있는 도움을 받을 수도 있구요.]],
	answers = {
		{"그냥 기초만 배울께요.", action=function(npc, player)
			game.logPlayer(player, "가게 주인이 마석을 통해 힘을 뿜어내는 방법을 알려 줬습니다.")
			player:incMoney(-100)
			player:learnTalentType("wild-gift/mindstar-mastery", false)
			player.changed = true
		end, cond=function(npc, player)
			if player.money < 100 then return end
			--if player:knowTalentType("wild-gift/mindstar-mastery") then return end
			if player:knowTalentType("wild-gift/mindstar-mastery") or player:knowTalentType("wild-gift/mindstar-mastery") == false then return end
			return true
		end},
		{"알아야 할 모든 것을 가르쳐 주셨으면 좋겠네요.", action=function(npc, player)
			game.logPlayer(player, "가게 주인이 공들여 마석을 통해 힘을 뿜어내는 방법과 그 자세한 원리를 설명해 줬습니다.")
			player:incMoney(-750)
			player:learnTalentType("wild-gift/mindstar-mastery", true)
			player.changed = true
		end, cond=function(npc, player)
			if player.money < 750 then return end
			if player:knowTalentType("wild-gift/mindstar-mastery") then return end
			return true
		end},
		{"아니오, 지금은 필요없을 것 같네요."},
	}
}

return "welcome"
