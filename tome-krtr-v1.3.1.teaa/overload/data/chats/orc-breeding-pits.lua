-- ToME - Tales of Maj'Eyal
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

newChat{ id="welcome",
	text = [[#LIGHT_GREEN#*잔디밭에서 희미하게 한 줄기 빛이 잠시 어른거렸습니다. 다가가서 살펴보니, 습격을 당한 듯한 태양의 기사가 외롭게 땅에 쓰러져 있습니다. 그녀의 상처는 그리 커보이진 않았지만, 마지막으로 당한 공격에서 중독을 당한듯 얼굴색이 창백합니다. 그녀가 당신에게 겨우 속삭입니다.*#WHITE#
제발, 도와주세요.
]],
	answers = {
		{"무엇을 도와드릴까요?", jump="next1"},
	}
}

newChat{ id="next1",
	text = [[아에린의 명으로 수색하던 그 혐오체를... 제가 찾아냈어요. 오크들의 번식용 동굴이었죠... 거긴 상상할 수 있는 것보다 훨씬 더 지독했어요... 오크들의 야영지로 부터 멀리 떨어진 곳에 숨겨져 있었어요, 모두의 시선이 닿지 않는 곳으로요. 그들의 약점인 어미들과 어린 새끼들이 전부 거기 있었어요!
#LIGHT_GREEN#*그녀는 그 장소가 묘사된 지도를 꺼내어, 힘들게 당신의 손으로 그것을 건네 주었습니다.*#WHITE#

이건 이 전쟁을 영원히 끝낼... 마지막 방법일 수도 있어요. 증원이 되기 전에, 우리는 빨리 이 곳을 습격해야 해요...

#LIGHT_GREEN#*그녀는 당신을 힘겹게 쳐다보며, 마지막으로 애원하는 눈빛을 보이는 것에 모든 힘을 쏟고 있습니다.*#WHITE#]],
	answers = {
		{"이건 저 혼자서 할 수 있는 일이 아닌것 같네요... 제가 아에린에게 이에 대한 보고를 하겠습니다. 그녀는 잘 처리할 수 있을 거예요.", action=function(npc, player)
			player:grantQuest("orc-breeding-pits")
			player:setQuestStatus("orc-breeding-pits", engine.Quest.COMPLETED, "wuss-out")
		end},
		{"이 문제는 제가 처리할 수 있을 것 같네요. 걱정말고 맡겨두세요.", action=function(npc, player)
			player:grantQuest("orc-breeding-pits")
			local q = player:hasQuest("orc-breeding-pits")
			q:reveal()
		end},
		{"저보고 어미들과 그 어린 새끼들을 죽이라는 말인가요? 그건 너무 야만적이네요. 전 거기에 관여하지 않겠습니다!"},
	}
}

return "welcome"
