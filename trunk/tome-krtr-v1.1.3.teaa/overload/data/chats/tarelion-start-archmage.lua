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
	text = [[잠시 기다리게!]],
	answers = {
		{"마도사 타렐리온님?", jump="next1"},
	}
}

newChat{ id="next1",
	text = [[그래, @playername@, 자네가 바깥 세계에 나가려고 하고 있다는 소식을 들었네, 자네만의 모험을 찾아서 말이야.
그건 좋은 일일세, 나는 우리들 중 더 많은 사람들이 마을을 나와 바깥의 사람들을 도와야 한다고 생각하네.
말해보게, 혹시 자네는 모험을 하면서 앙골웬도 도울 수 있는 방법을 알고 싶나?]],
	answers = {
		{"아마도요, 무슨 일이죠?", jump="next2"},
	}
}

newChat{ id="next2",
	text = [[마법폭발과 함께, 세계는 산산조각이 났네, 말 그대로 말이야. 그 중에는 현재 우리가 '너무나 광활한 공간'이라고 부르는, 이 세계에서 떨어져나가 별들 사이의 공허 속으로 던져지고 만 곳도 있지.
우리는 그곳을 안정화시켜 이곳 에이알 세계를 선회하도록 만들었지만, 최근 그곳에서 문제가 일어나는 것을 알아냈다네. 우리가 아무 행동도 취하지 않는다면, 그 지역은 에이알 세계와 충동하여 엄청난 파괴를 일으키게 될걸세.
그곳은 이 땅의 일부분이였기 때문에, 우리는 자네를 그곳으로 순간이동 시킬 수 있는 방법을 알고 있다네. 자네는 그곳에서 어떤 공격 마법을 사용해서라도, 그곳에 있는 세 개의 웜홀을 안정화시켜야만 하네.
그곳의 불안정한 상태가 자네에게 유리하게 작용하는 점도 있을걸세. 그곳에서는 간단한 근거리 순간이동 마법으로도 도착지점을 완벽하게 조종할 수 있으니 말일세.

그래서, 우리를 도와줄 수 있겠나?]],
	answers = {
		{"물론입니다, 마도사 타렐리온. 저를 그곳으로 보내주십시오!", jump="teleport"},
		{"아뇨, 죄송하지만 전 이만 가봐야겠습니다.", jump="refuse"},
	}
}

newChat{ id="teleport",
	text = [[자네에게 행운이 있기를!]],
	answers = {
		{"[공간이동]", action=function(npc, player) game:changeLevel(1, "abashed-expanse", {direct_switch=true}) end},
	}
}

newChat{ id="refuse",
	text = [[알겠네, 즐거운 모험이 되기를 바라네. 이제 나는 그곳에 가서 일을 처리할 다른 사람을 찾아봐야겠군.]],
	answers = {
		{"그럼 안녕히.", action=function(npc, player) player:setQuestStatus("start-archmage", engine.Quest.FAILED) end},
	}
}

return "welcome"
