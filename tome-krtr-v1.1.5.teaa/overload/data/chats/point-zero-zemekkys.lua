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
	action = function(npc, player) npc.talked_times = (npc.talked_times or 0) + 1 end,
	text = [[@playername@, 다시 봐서 반갑군 그래! 아니, 우리 처음 만나는 건가?]],
	answers = {
		{"그럼 이만, 위대한 감시원이여."},
		{"그렇습니다. 우리는 서로 처음 보는 사이입니다.", jump="first", cond=function(npc, player) return not npc.talked_times end},
	}
}

newChat{ id="first",
	text = [[아, 자네에게는 처음일지도 모르지만, 나는 아니라네.
들어보게. 언젠가 자네는 나를 다시 만나게 될거라네. 하지만 그 '나' 는 지금 자네와 이야기하는 내가 아니라네. 아마 지금의 나보다 더 젊은 '나' 이겠지.
이건 굉장히 중요한 일이라네. 그때의 '나' 에게 지금의 나에 대한 얘기를 하면 절대 안되네. 알겠는가?]],
	answers = {
		{"네, 뭐..."},
		{"알겠습니다, 위대한 감시원이여."},
	}
}

return "welcome"
