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
	text = [[대체 무슨 일이 일어난거죠?!]],
	answers = {
		{"미안, 너를 보호해주지 못해서 네 목숨을 잃어버릴뻔 했어. 너는... 강력한 황폐의 파동을 발사했어.", jump="next1"},
	}
}

newChat{ id="next1",
	text = [[하지만, 저는 태어나서 한번도 마법을 써본 적이 없는걸요!]],
	answers = {
		{"너는 아직도 그... 끔찍한 악마에게 오염되어 있어! 아직 오염이 사라지지 않은거야!", jump="next_am", cond=function(npc, player) return player:attr("forbid_arcane") end},
		{"아직 그 악마로 인한 오염이 네 안에 조금 남아있는 것 같아.", jump="next_notam", cond=function(npc, player) return not player:attr("forbid_arcane") end},
	}
}

newChat{ id="next_am",
	text = [[오, 세상에! 저는 정말 이런 일이 일어날 것이라고는 생각도 하지 못했어요. 제발 저를 믿어주세요!]],
	answers = {
		{"그럴거야. 너도 알겠지만, 지구르 추종자들은 정신나간 광신도들이 아니니까. 네가 황폐의 힘에 저항하는 한, 우리도 너를 치료할 방법을 찾아볼거야.", jump="next2"},
	}
}

newChat{ id="next_notam",
	text = [[오, 세상에! 저에게 대체 무슨 일이 일어나고 있는거죠?!? 제발 저를 도와주세요!]],
	answers = {
		{"그럴거야. 우리 같이 치료법을 찾아보자.", jump="next2"},
	}
}

newChat{ id="next2",
	text = [[저는 정말 운 좋은 여자에요, 그렇지 않나요... 제 목숨을 구해주신 것도 이걸로 벌써 두 번째네요.]],
	answers = {
		{"지난 몇 주 동안, 너는 내게 아주 소중한 존재가 됐어. 너를 알게 된 것은 정말 기쁜 일이야. 하지만 일단, 여기는 대화를 나누기 적절한 장소가 아닌 것 같아. 여기서 나가자.", jump="next3"},
	}
}

newChat{ id="next3",
	text = [[당신 말이 맞아요. 여기서 벗어나요.]],
	answers = {
		{"#LIGHT_GREEN#[마지막 희망으로 돌아간다]", action=function(npc, player)
			game:changeLevel(1, "town-last-hope", {direct_switch=true})
			player:move(25, 44, true)
		end},
	}
}

return "welcome"
