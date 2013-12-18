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
	text = [[그렇다면 제가 마석 사용법 (자연의 권능 / 마석 수련) 을 가르쳐드릴 수 있습니다. 기초적인 기술을 배우려면 금화 100 개, 보다 집중적인 훈련을 통해 실제로 기술을 습득하려면 금화 500 개, 그리고 기술을 습득한 상태라면 금화 750 개를 받고 추가적인 기술을 가르쳐드릴 수 있습니다.]],
	answers = {
		{"그냥 기초적인 것만 알려주세요. (잠겨진 상태로 기술 계열 습득) - 금화 100 개", action=function(npc, player) -- Normal basic training
			game.logPlayer(player, "상점 주인이 당신과 약간의 시간을 보내면서, 마석을 통해 힘을 이끌어내는 방법을 가르쳐주었습니다.")
			player:incMoney(-100)
			player:learnTalentType("wild-gift/mindstar-mastery", false)
			if player:getTalentTypeMastery("wild-gift/mindstar-mastery") < 1 then
				player:setTalentTypeMastery("wild-gift/mindstar-mastery", math.min(1.1, player:getTalentTypeMastery("wild-gift/mindstar-mastery") + 0.3))
				game.logPlayer(player, "그는 당신과 자연의 힘 사이의 친화력에 깊은 인상을 받았습니다.")
			end
			player.changed = true
		end, cond=function(npc, player)
			if player.money < 100 then return end
			if player:knowTalentType("wild-gift/mindstar-mastery") or player:knowTalentType("wild-gift/mindstar-mastery") == false then return end
			return true
		end},
		{"제가 알아야 할 것들을 가르쳐주세요. (기술 계열 잠금 해제) - 금화 500 개", action=function(npc, player)
			game.logPlayer(player, "상점 주인이 당신과 많은 시간을 보내면서, 마석을 통해 힘을 이끌어내는 방법을 세세하게 가르쳐주었습니다.")
			player:incMoney(-500)
			player:learnTalentType("wild-gift/mindstar-mastery", true)
			if player:getTalentTypeMastery("wild-gift/mindstar-mastery") < 1 then -- Special case for previously locked category (escort)
				player:setTalentTypeMastery("wild-gift/mindstar-mastery", math.max(1.0, player:getTalentTypeMastery("wild-gift/mindstar-mastery") + 0.3))
			end
			if player:getTalentTypeMastery("wild-gift/mindstar-mastery") > 1 then
				game.logPlayer(player, "그는 당신의 숙련도와 강력한 힘을 다루는 몇몇 기술들에 깊은 인상을 받았습니다.")
			end
			player.changed = true
		end, cond=function(npc, player)
			if player.money < 500 then return end
			if player:knowTalentType("wild-gift/mindstar-mastery") then return end
			return true
		end},
		{"저는 이미 마석 사용 기술을 알고 있습니다. 더 전문적인 기술을 알려주세요. (기술 계열 숙련도 0.2 향상) - 금화 750 개", action=function(npc, player) --Enhanced intensive training
			player:incMoney(-750)
			player:learnTalentType("wild-gift/mindstar-mastery", true)
			player:setTalentTypeMastery("wild-gift/mindstar-mastery", player:getTalentTypeMastery("wild-gift/mindstar-mastery") + 0.2)
			game.logPlayer(player, ("상점 주인이 당신과 많은 시간을 보내면서, 마석을 통해 힘을 이끌어내는 방법을 세세하게 가르쳐주었습니다.%s."):format(player:getTalentTypeMastery("wild-gift/mindstar-mastery")>1 and " 또한 강력한 힘의 역장을 유지시키기 위해 필요한 정신 수련법을 알려주었습니다." or ""))
			player.changed = true
		end, cond=function(npc, player)
			if player.money < 750 then return end
			if player:knowTalentType("wild-gift/mindstar-mastery") and player:getTalentTypeMastery("wild-gift/mindstar-mastery") < 1.2 then return true end
		end},
		{"아니오, 지금은 필요 없을 것 같네요."},
	}
}

return "welcome"
