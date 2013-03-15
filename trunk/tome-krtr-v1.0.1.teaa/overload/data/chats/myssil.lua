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

local p = game.party:findMember{main=true}
if not p:attr("forbid_arcane") or p:attr("forbid_arcane") < 2 then
newChat{ id="welcome",
	text = [[#LIGHT_GREEN#*검은 빛의 강철 판갑으로 무장한 하플링 여성이 당신 앞에 서있습니다.*#WHITE#
시련을 통과해라. 이야기는 그 다음에 하지.]],
	answers = {
		{"잠깐..."},
	}
}
return "welcome"
end



newChat{ id="welcome",
	text = [[#LIGHT_GREEN#*검은 빛의 강철 판갑으로 무장한 하플링 여성이 당신 앞에 서있습니다.*#WHITE#
나는 수호자 미씰이다. 지구르에 온 것을 환영한다.]],
	answers = {
		{"제가 받을 수 있는 최대한의 도움이 필요합니다. 하지만 이는 저를 위한 것이 아니며, 북서쪽에 있는 데르스 마을을 위한 것입니다.", jump="save-derth", cond=function(npc, player) local q = player:hasQuest("lightning-overload") return q and q:isCompleted("saved-derth") and not q:isCompleted("tempest-entrance") and not q:isStatus(q.DONE) end},
		{"수호자여, 당신의 명령대로 폭풍우 봉우리에 다녀왔습니다.", jump="tempest-dead", cond=function(npc, player) local q = player:hasQuest("lightning-overload") return q and q:isCompleted("tempest-entrance") and not q:isCompleted("antimagic-reward") and q:isStatus(q.DONE) end},
		{"아무 것도 아닙니다. 당신의 시간을 뺏어서 미안합니다. 그럼 이만, 수호자여."},
	}
}

newChat{ id="save-derth",
	text = [[그래. 우리도 그곳에 퍼진 황폐한 마법의 기운을 느꼈다. 사람들을 보내 구름을 흩어내고는 있지만, 사실 진정한 위협은 그곳에 있지 않다.
폭푸우 봉우리에 있는, 천둥을 다스리는 강력한 마법사가 구름을 보냈다는 사실을 알아냈지. 허 끔찍한 앙골웬 놈들은 아무 행동도 취하지 않고 있고 말이야. 타락한 놈들!
네 행동이 필요한 시점이다, @playername@. 이 마법사가 있는 곳의 위치를 표시해주지. 다이카라 산맥의 정상 부근이다.
그를 제거하라.]],
	answers = {
		{"맡겨만 주십시오, 수호자여.", action=function(npc, player)
			player:hasQuest("lightning-overload"):create_entrance()
		end},
	}
}

newChat{ id="tempest-dead",
	text = [[나도 들었네, @playername@. 수련의 성과를 보여주었군 그래. 자연의 축복과 함께 하길, 지구르의 추종자, @playername@.
#LIGHT_GREEN#*그녀가 당신에게 손을 댑니다. 자신에게 자연의 힘이 주입되는 것을 느낄 수 있습니다.
자네의 여행길에 도움이 될 것이다. 그럼 잘 가라!]],
	answers = {
		{"감사합니다, 수호자여.", action=function(npc, player)
			player:hasQuest("lightning-overload"):create_entrance()
			if player:knowTalentType("wild-gift/fungus") then
				player:setTalentTypeMastery("wild-gift/fungus", player:getTalentTypeMastery("wild-gift/fungus") + 0.1)
			elseif player:knowTalentType("wild-gift/fungus") == false then
				player:learnTalentType("wild-gift/fungus", true)
			else
				player:learnTalentType("wild-gift/fungus", false)
			end
			-- Make sure a previous amulet didnt bug it out
			if player:getTalentTypeMastery("wild-gift/fungus") == 0 then player:setTalentTypeMastery("wild-gift/fungus", 1) end
			game.logPlayer(player, "#00FF00#미생물 기술 계열을 얻었습니다.")
			player:hasQuest("lightning-overload"):setStatus(engine.Quest.COMPLETED, "antimagic-reward")
		end},
	}
}

return "welcome"
