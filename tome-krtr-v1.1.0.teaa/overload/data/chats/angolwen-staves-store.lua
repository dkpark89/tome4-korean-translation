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
	text = [[그렇다면 제가 지팡이 사용법 (주문 / 지팡이 전투 기술 계열) 을 가르쳐드릴 수 있습니다. 기초적인 기술을 배우려면 금화 100 개, 보다 집중적인 훈련을 통해 실제로 기술을 습득하려면 금화 500 개, 그리고 기술을 습득한 상태라면 금화 750 개를 받고 더 세부적인 기술을 가르쳐드릴 수 있습니다.]], 
	answers = {
		{"그냥 기초적인 것만 알려주세요. (잠겨진 상태로 기술 계열 습득) - 금화 100 개", action=function(npc, player) 
			game.logPlayer(player, "지팡이 조각가에게 기초적인 지팡이 전투기술을 배웠습니다.")
			player:incMoney(-100)
			player:learnTalentType("spell/staff-combat", false)
			if player:getTalentTypeMastery("spell/staff-combat") < 1 then
				player:setTalentTypeMastery("spell/staff-combat", math.min(1.1, player:getTalentTypeMastery("spell/staff-combat") + 0.3))
				game.logPlayer(player, "그는 당신이 그의 교육을 빠르게 소화해내는 것에 놀라움을 느꼈습니다.") 
			end
			player.changed = true
		end, cond=function(npc, player)
			if player.money < 100 then return end
			if player:knowTalentType("spell/staff-combat") or player:knowTalentType("spell/staff-combat") == false then return end
			return true
		end},
		{("제가 알아야 할 것들을 가르쳐주세요. (기술 계열 잠금 해제) - 금화 %d 개"):format(500), 
		action=function(npc, player) --Normal intensive training
			game.logPlayer(player, "지팡이 조각가가 당신과 많은 시간을 보내면서, 지팡이 전투 기술을 세세하게 가르쳐주었습니다.") 
			player:incMoney(-500)
			player:learnTalentType("spell/staff-combat", true)
			if player:getTalentTypeMastery("spell/staff-combat") < 1 then -- Special case for previously locked category (escort)
				player:setTalentTypeMastery("spell/staff-combat", math.max(1.0, player:getTalentTypeMastery("spell/staff-combat") + 0.3))
			end
			if player:getTalentTypeMastery("spell/staff-combat") > 1 then
				game.logPlayer(player, "그는 당신의 숙련도와 배운 것을 기초로 하는 몇몇 응용 기술들에 깊은 인상을 받았습니다.") 
			end
			player.changed = true
		end,
		cond=function(npc, player)
			if player.money < 500 then return end
			if player:knowTalentType("spell/staff-combat") then return end
			return true
		end},
		{"저는 이미 지팡이 전투 기술을 알고 있습니다. 더 전문적인 기술을 알려주세요. (기술 계열 숙련도 0.2 향상) - 금화 750 개", action=function(npc, player) --Enhanced intensive training 
			player:incMoney(-750)
			player:learnTalentType("spell/staff-combat", true)
			player:setTalentTypeMastery("spell/staff-combat", player:getTalentTypeMastery("spell/staff-combat") + 0.2)
			game.logPlayer(player, ("지팡이 조각가가 당신과 많은 시간을 보내면서, 지팡이 전투 기술을 세세하게 가르쳐주었습니다. %s"):format(player:getTalentTypeMastery("spell/staff-combat")>1 and " 또한 몇몇 고급 기술들을 알려주었습니다." or "")) 
			player.changed = true
		end, cond=function(npc, player)
			if player.money < 750 then return end
			if player:knowTalentType("spell/staff-combat") and player:getTalentTypeMastery("spell/staff-combat") < 1.2 then return true end
		end},
		{"죄송합니다, 지금은 필요 없을 것 같네요."},
	}
}

return "welcome"
