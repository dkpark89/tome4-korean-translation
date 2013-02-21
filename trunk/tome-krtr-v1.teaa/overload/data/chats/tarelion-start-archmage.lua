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
	text = [[잠시 기다리게!]],
	answers = {
		{"이거 마도사 타렐리온이 아니십니까?", jump="next1"},
	}
}

newChat{ id="next1",
	text = [[그렇네 @playername@, 자네가 야생의 세계에 나가려고 하고 있다는 걸 들었네, 자네만의 모험을 찾아서 말이야.
그건 좋은 일일세, 나는 우리들 중 더 많은 사람들이 마을의 밖에 나가 바깥의 사람들을 도와야 한다고 생각하네.
말해보게, 아마도 자네는 약간의 모험을 함과 동시에 앙골웬을 도우는 방법을 알고 싶나?]],
	answers = {
		{"아마도요, 무엇이 필요하십니까??", jump="next2"},
	}
}

newChat{ id="next2",
	text = [[마법폭발의 기간동안 세계는 산산조각이 났었네, 말 그대로 말야. 그 중 일부가, 현재 우리가 '너무나 광활한 공간'이라 부르는 곳이, 세계에서 떨어져 나가 별들 사이의 공허 속으로 날려가버렸다네.
우리는 그 곳을 안정적으로 만들어 에이알이 있는 궤도를 선회하게 만들었지만, 최근 거기서 장애가 일어나는 것을 눈치챘다네. 우리가 아무 짓도 하지 않는다면 그 곳은 곧 에이알에 떨어지게 되고, 그로인해 아주 큰 파괴가 덮쳐올 것이야.
그곳은 이 땅의 일부분이었기에 우리는 자네를 그곳으로 순간이동 시킬 수 있을만큼의 지식을 가지고 있네. 자네는 그 곳에서 어떤 공격 마법이라도 사용하여 세 개의 웜홀을 안정화시켜야만 하네.
그리고 그 곳의 불안정한 상태가 자네에게는 이점이 되기도 할 걸세, 자네는 그 곳에서 간단한 근거리 순간이동을 자유롭게 조종이 가능할 걸세.

그래서, 자네가 우리를 도울 수 있다고 생각되나?]],
	answers = {
		{"물론입니다 마도사 타렐리온, 저를 그 곳으로 보내주십시오!", jump="teleport"},
		{"아뇨, 죄송하지만 전 이만 가봐야 겠습니다.", jump="refuse"},
	}
}

newChat{ id="teleport",
	text = [[자네에게 행운이 있기를!]],
	answers = {
		{"[순간이동]", action=function(npc, player) game:changeLevel(1, "abashed-expanse", {direct_switch=true}) end},
	}
}

newChat{ id="refuse",
	text = [[알겠네, 즐거운 모험이 되기를 바라네. 이제 난 그 곳에 가서 일을 처리할 다른 사람을 찾아봐야 겠군.]],
	answers = {
		{"그럼 안녕히.", action=function(npc, player) player:setQuestStatus("start-archmage", engine.Quest.FAILED) end},
	}
}

return "welcome"
