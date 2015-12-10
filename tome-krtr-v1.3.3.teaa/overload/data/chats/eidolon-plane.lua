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
if game.zone.from_farportal then

newChat{ id="welcome",
	text = [[#LIGHT_GREEN#*사람 형체를 하고 있지만 '아무 것도 아닌 것' 으로 이루어진 존재가, 당신을 쳐다보고 있습니다.*#WHITE#
나는 에이돌론이고 당신은 여기에 와서는 안되네!
이 차원에 어떻게 왔는지는 모르지만, #{bold}#다시는 오지말게!
당장 꺼져!
#{normal}#
.]],
	answers = {
		{"...", action=function() game.level.data.eidolon_exit(false) end},
	}
}


else

newChat{ id="welcome",
	text = [[#LIGHT_GREEN#*사람 형체를 하고 있지만 '아무 것도 아닌 것' 으로 이루어진 존재가, 당신을 쳐다보고 있습니다.*#WHITE#
네가 죽기 직전, 내가 너를 구해주었네. 나는 에이돌론이라고 하네.
너는 내 '관심' 을 끌만한 가치가 있어. 네 앞날도 관심을 가지고 지켜보도록 하지.
여기서 쉬어도 좋네. 그리고 준비가 다 되면, 다시 너를 물질계로 돌려보내주지.
하지만 내 호의를 당연한 것으로 생각하지는 않는게 좋을거야. 나는 네 시종이 아니고, 때가 되면 너를 죽게 놔둘테니까.
하고 싶은 질문이 많겠지만, 대답해 줄 생각은 없네. 나는 너를 도와주려고 왔지, 그 이유를 설명해주려고 온 건 아니니까.]],
	answers = {
		{"감사합니다. 저는 잠시 휴식을 취하도록 하겠습니다."},
		{"감사합니다. 저는 이제 돌아갈 준비가 되었습니다!", 
			cond=function() return game.level.source_level and not game.level.source_level.no_return_from_eidolon end,
			action=function() game.level.data.eidolon_exit(false) end
		},
		{"감사합니다. 그러나 전 돌아가도 살아남을 것 같지 않으니, 대신 다른 곳으로 보내주실 수 있습니까?",
			cond=function() return game.level.source_level and not game.level.source_level.no_return_from_eidolon and (not game.level.source_level.data or not game.level.source_level.data.no_worldport) end,
			action=function() game.level.data.eidolon_exit(true) end
		},
		{"감사합니다. 그러나 전 돌아가도 살아남을 것 같지 않으니, 대신 이 지역의 다른 곳으로 보내주실 수 있습니까?", 
			cond=function() return game.level.source_zone and game.level.source_zone.infinite_dungeon end,
			action=function() game.level.data.eidolon_exit("teleport") end
		},
		{"감사합니다. 저는 이제 돌아갈 준비가 되었습니다!",
			cond=function() return not game.level.source_level or game.level.source_level.no_return_from_eidolon end,
			jump="jump_error",
		},
		{"감사합니다. 하지만 저는 이제 이런 삶에 지쳤습니다. 더 이상 바라는 것은 없습니다. 저를 죽게 놔둬주십시오.", jump="die"},
	}
}

newChat{ id="jump_error",
	text = [[시공간의 흐름에 오류가 생긴 것 같군...
안전한 곳에 보내주도록 하지.]],
	answers = {
		{"감사합니다.", action=function(npc, player) game:changeLevel(1, "wilderness") end},
	}
}

newChat{ id="die",
	text = [[#LIGHT_GREEN#*에이돌론이 당신을 이상하다는 눈빛으로 쳐다봅니다.*#WHITE#
나는... 너를 살려줄 계획이었지만, 네 자유의지를 방해할 수는 없겠지. 다만, 아직도 많은 운명이 물질계에서 너를 기다리고 있다는 것만 알아둬라.
다시 묻지. 방금 전 말은 진심인가?]],
	answers = {
		{"그렇습니다. 저를 죽여주십시오.", action=function(npc, player) game:getPlayer(true):die(game.player, {special_death_msg=("%s는 편안하게 죽음을 맞이했습니다"):format(game.player.female and "그녀" or "그")}) end},
		{"역시, 살아가는 것이 가치가 있는 일이겠죠!"},
	}
}

end

return "welcome"
