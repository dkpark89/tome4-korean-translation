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

local function attack(str)
	return function(npc, player) engine.Faction:setFactionReaction(player.faction, npc.faction, -100, true) npc:doEmote(str, 150) end
end

newChat{ id="welcome",
	text = [[#LIGHT_GREEN#*당신 앞에 엄청나게 큰 머리를 가진, 작은 인간형 생물이 서있습니다.*#WHITE#
아, @playerdescriptor.race@분께서 여긴 왠일이시죠? 길을 잘못 들어 여기로 온 것이라고 믿겠습니다.]],
	answers = {
		{"뭐 그렇다고 해두지. 여기는 무엇을 하는 곳인가?", jump="what"},
	}
}

newChat{ id="what",
	text = [[이곳은 피의 투기장입니다! 들어보십시오, 당신에게는 두 가지 선택지가 있습니다.
당신이 노예처럼 보이지는 않으니, 당신이 '게임' 을 즐길 수 있게 해드리지요.
만약 당신이 노예 게임같은 것을 해서는 안된다고 생각한다면, 당신은... 여기서 사라지실 필요가 있습니다.]],
	answers = {
		{"노예? 노예 제도 같은 것은 있어서는 안돼! [공격한다]", action=attack("그렇게 생각합니까? 그러핟면 죽으십시오.")},
		{"게임? 그거 좋지. 정확히 무슨 게임이지?", jump="game"},
	}
}

newChat{ id="game",
	text = [[뭐, 아주 간단합니다. 저는 정신적으로 다양한 야생동물과 노예들을 조종하게 됩니다. 그리고 당신은 반대편에 있는 명령의 오브를 사용해서 노예 하나를 조종하게 됩니다.
우리 둘이 서로의 장기말을 사용해서 10 번의 쇄도를 펼칩니다. 만약 당신의 노예가 이긴다면, 특별한 반지인 '피를 부르는 자' 를 얻을 수 있습니다.]],
	answers = {
		{"만약 내가 패배한다면?", jump="lose"},
		{"나 자신은 멀쩡한 상태로 피와 죽음을 즐길 수 있다? 정말 재미있겠군!", jump="price"},
	}
}

newChat{ id="lose",
	text = [[원래대로라면 당신은 노예가 됩니다만, 당신은 노예가 되는 것 보다는 계속 게임을 즐길 수 있게 해주는 편이 더 이득일 것 같군요. 그냥 다시 게임을 하시면 됩니다.]],
	answers = {
		{"나 자신은 멀쩡한 상태로 피와 죽음을 즐길 수 있다? 정말 재미있겠군!", jump="price"},
	}
}

newChat{ id="price",
	text = [[좋습니다. 오, 하나 깜빡한 것이 있군요. 게임을 하시려면 표준 요금인 금화 150 개를 지불하셔야 합니다.
당신 같은 모험가들에게는 얼마 안되는 금액이라 생각합니다만.]],
	answers = {
		{"금화 150 개? 어... 그럼, 물론이지.", action=function(npc) npc.can_talk = nil end},
	}
}

return "welcome"
