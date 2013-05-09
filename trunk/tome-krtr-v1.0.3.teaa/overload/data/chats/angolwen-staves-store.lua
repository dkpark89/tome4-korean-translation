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
	text = [[어서 오십시오. @playername@씨, 찾아주셔서 고맙습니다.]],
	answers = {
		{"파는 물건들을 보고 싶은데요.", action=function(npc, player)
			npc.store:loadup(game.level, game.zone)
			npc.store:interact(player)
		end},
		{"지팡이 전투기술을 배워볼까 해서 찾아왔습니다.", jump="training"},
		{"미안합니다, 이만 가볼게요!"},
	}
}

newChat{ id="training",
	text = [[금화 100 개를 지불하시면 지팡이 전투기술 계열에 대한 기초를 간략히 설명해 줄 수 있습니다. (비활성화 상태로 해당 기술 계열 습득) 
금화 750 개를 지불하시면 더욱 깊이 있는 학습을 받으실 수도 있지요. (활성화 상태로 해당 기술 계열 습득)]],
	answers = {
		{"그냥 기초만 배울게요.", action=function(npc, player)
			game.logPlayer(player, "지팡이 조각가에게 기초적인 지팡이 전투기술을 배웠습니다.")
			player:incMoney(-100)
			player:learnTalentType("spell/staff-combat", false)
			player.changed = true
		end, cond=function(npc, player)
			if player.money < 100 then return end
			--if player:knowTalentType("spell/staff-combat") then return end
			if player:knowTalentType("spell/staff-combat") or player:knowTalentType("spell/staff-combat") == false then return end
			return true
		end},
		{"알아야 할 모든 것을 가르쳐 주셨으면 좋겠네요.", action=function(npc, player)
			game.logPlayer(player, "지팡이 조각가에게 지팡이 전투기술에 관하여 심도있는 교육을 받았습니다.")
			player:incMoney(-750)
			player:learnTalentType("spell/staff-combat", true)
			player.changed = true
		end, cond=function(npc, player)
			if player.money < 750 then return end
			if player:knowTalentType("spell/staff-combat") then return end
			return true
		end},
		{"죄송합니다, 지금은 필요 없을 것 같네요."},
	}
}

return "welcome"
