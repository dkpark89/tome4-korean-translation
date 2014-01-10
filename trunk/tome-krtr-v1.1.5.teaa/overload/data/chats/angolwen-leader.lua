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
	text = [[#LIGHT_GREEN#*키 큰 여성이 당신 앞에 서있습니다. 그녀의 흰색 피부와 흰색 로브에서 엄청난 힘이 흘러나오고 있습니다.*#WHITE#
저는 칼'크룰의 리나니일이라고 합니다. 저희 도시에 오신 것을 환영합니다, @playerdescriptor.subclass@여. 제가 도와드릴 일이라도?]],
	answers = {
		{"제가 받을 수 있는 최대한의 도움이 필요합니다. 하지만 이는 저를 위한 것이 아니며, 북동쪽에 있는 데르스 마을을 위한 것입니다.", jump="save-derth", cond=function(npc, player) local q = player:hasQuest("lightning-overload") return q and q:isCompleted("saved-derth") and not q:isCompleted("tempest-located") and not q:isStatus(q.DONE) end},
		{"준비는 끝났습니다! 저를 우르키스에게 보내주십시오!", jump="teleport-urkis", cond=function(npc, player) local q = player:hasQuest("lightning-overload") return q and not q:isEnded("tempest-located") and q:isCompleted("tempest-located") end},
		{"아닙니다. 당신 같은 숙녀분의 시간을 뺏어서 미안합니다. 안녕히 계시길."},
	}
}

newChat{ id="save-derth",
	text = [[네, 저희도 그곳에서 일어난 파괴 행위를 알고 있습니다. 친구들을 보내 구름을 흩어내려 했지만, 사실 진정한 위협은 그곳에 있지 않습니다.
이 재앙을 만들어낸 자는 '우르키스' 라는 대기술사입니다. 폭풍을 다스릴 수 있는 강력한 마도사지요.
수 년 전 그는 이곳 앙골웬을 떠나, 그만의 길을 걷기 시작했습니다. 처음에는 그도 조용히 살아왔기 때문에 저희도 별다른 행동을 취하지 않았지만, 이제는 다른 선택지가 없을 것 같군요.
하늘을 정화하는 것은 너무나 오랜 시간이 걸립니다. 그 대신, 만약 그대가 그럴 의지가 있다면, 우리는 그대를 우르키스가 있는 곳으로 보내드리겠습니다.
그대에게 거짓말은 하지 않겠습니다. 우리는 그대를 그곳에 보내줄 수는 있지만, 당신의 안전을 보장할 수는 없습니다. 또한 우리는 그대를 그가 있는 곳에서 탈출시켜줄 수 없습니다. 그는 다이카라 산맥의 가장 높은 곳에 있기 때문입니다.]],
	answers = {
		{"준비가 필요할 것 같군요. 준비를 끝내고 다시 오겠습니다.", action=function(npc, player) player:setQuestStatus("lightning-overload", engine.Quest.COMPLETED, "tempest-located") end},
		{"준비는 끝났습니다. 저를 보내주십시오. 데르스의 선량한 시민들이 고통받게 내버려두지 않겠습니다.", action=function(npc, player) player:setQuestStatus("lightning-overload", engine.Quest.COMPLETED, "tempest-located") player:hasQuest("lightning-overload"):teleport_urkis() end},
	}
}

newChat{ id="teleport-urkis",
	text = [[그대에게는 행운이, 그대가 가는 길에는 앙골웬의 축복이 함께 하기를.]],
	answers = {
		{"감사합니다.", action=function(npc, player) player:hasQuest("lightning-overload"):teleport_urkis() end},
	}
}

return "welcome"
