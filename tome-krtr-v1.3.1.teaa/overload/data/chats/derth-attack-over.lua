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
	text = [[#LIGHT_GREEN#*하플링이 그가 만든 은신처에서 기어나옵니다.*#WHITE#
당신이 그것들을 모두 죽였나요? 이제 우리는 안전한가요? 오, 제발 방금 전 일이 나쁜 꿈이었다고 말해주세요!]],
	answers = {
		{"진정하세요. 그 괴물같은 놈들은 모두 제거했습니다. 이것들이 어디서 왔는지, 아니면 그것들이 원하는 것은 무엇이였는지 아시나요?", jump="quest"},
	}
}

newChat{ id="quest",
	text = [[이곳저곳에서 다요! 하늘에서요!
사실 저도 잘 모르겠어요. 마을에서 비명이 들릴 때까지, 저는 마을 밖에서 작물을 관리하고 있었어요. 제가 비명소리를 듣고 마을에 들어갔을 때는, 검은 구름이 마을을 덮고 있었죠. 그리고 그... 그것들은 번개가 떨어지면서 나타났어요! ]],
	answers = {
		{"일단 지금은 번개가 그친 것 같군요. 이 먹구름들을 없앨 방법을 알만한 사람을 찾아보죠.", jump="quest2"},
	}
}

newChat{ id="quest2",
	text = [[감사합니다! 오늘 당신은 많은 사람을 구한겁니다!
그러고보니, 현명하고 강력한 자가 산 속의 비밀스러운 마을에 산다는 소문을 들었습니다. 그들이 도움을 줄 수 있을까요? 아니, 그들이 존재하기는 할까요...
그리고 지구르인가 뭔가 하는 사람들은 마법과 싸우고 있다고 합니다. 왜 그들은 여기에 오지 않는걸까요?]],
	answers = {
		{"정확히는 지구르 추종자라고 합니다. 제가 지구르 추종자이기도 하고요.", cond=function(npc, player) return player:isQuestStatus("antimagic", engine.Quest.DONE) end, jump="zigur"},
		{"여러분을 이대로 놔두지는 않겠습니다.", action=function(npc, player) player:hasQuest("lightning-overload"):done_derth() end},
	}
}

newChat{ id="zigur",
	text = [[그럼 이 악마 같은 마법을 어떻게 좀 해주세요!]],
	answers = {
		{"그러죠!", action=function(npc, player) player:hasQuest("lightning-overload"):done_derth() end},
	}
}

return "welcome"
