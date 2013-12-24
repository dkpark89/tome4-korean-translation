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
	text = [[@playername@, 감사합니다. 인정하기는 싫지만, 당신이 제 목숨을 구했습니다.]],
	answers = {
		{"당신을 위해서라면. 하지만 이 어두운 곳에서 무엇을 하고 있었는지 물어봐도 될까요?", jump="what", cond=function(npc, player) return not player:hasQuest("start-sunwall") end},
		{"당신을 위해서라면. 비록 저는 몇 달 동안 이곳을 떠나 있었지만, 저는 느낄 수 있습니다. 이곳은 제 고향 땅입니다!", jump="back", cond=function(npc, player) return player:hasQuest("start-sunwall") end},
	}
}

newChat{ id="what",
	text = [[저는 아노리실입니다. 태양과 달의 힘을 다루는 마법사로, 모든 사악한 것들과 맞서 싸우는 자들입니다. 그리고 저는 태양의 기사단과 함께 동쪽에 있는 아침의 문에서 왔습니다.
제 동료들은... 오크들에게 학살당했습니다. 그리고 저 역시 죽을 뻔 했지요. 도와주셔서 다시 한번 감사드립니다.]],
	answers = {
		{"오히려 제가 더 기쁜 일입니다. 하지만 제 부탁을 하나 들어주시겠습니까? 저는 이 땅의 사람이 아닙니다. 저는 철의 왕좌 깊숙한 곳에서 오크들이 지키는 장거리 관문을 사용해서 이곳에 왔습니다.", action=function(npc, player) game:setAllowedBuild("divine") game:setAllowedBuild("divine_anorithil", true) end, jump="sunwall"},
	}
}

newChat{ id="sunwall",
	text = [[네. 저 역시 당신이 이곳 사람이 아니라는 것을 느꼈습니다. 당신의 유일한 희망은 오크들의 공습으로부터의 마지막 피난처인 자유민들의 도시, '아침의 문' 이 되겠군요. 이 동굴을 빠져나와서, 남동쪽으로 가시면 됩니다. 아마 마을을 지나칠 일은 없을겁니다.
고위 태양의 기사 아에린에게 저를 만났다는 말을 하십시오. 당신을 통과시키라는 말을 해두겠습니다.]],
	answers = {
		{"감사합니다. 아에린과 대화를 해보겠습니다.", action=function(npc, player) game.player:setQuestStatus("strange-new-world", engine.Quest.COMPLETED, "helped-fillarel") end},
	}
}

newChat{ id="back",
	text = [[흠? 잠깐, 이 얼굴... @playername@님이 아닙니까! 우리는 당신이 나가들의 관문이 폭발하면서 죽은 줄 알았습니다!
당신의 용기 덕분에, 아침의 문은 아직 굳건히 이 땅에 서있습니다.
지금 즉시 그곳으로 가보십시오.]],
	answers = {
		{"슬프게도, 저는 나쁜 소식을 전해주는 전령이 되겠군요. 오크들이 어떤 계획을 꾸미고 있습니다. 그럼 행운이 있으시길."},
	}
}

return "welcome"
