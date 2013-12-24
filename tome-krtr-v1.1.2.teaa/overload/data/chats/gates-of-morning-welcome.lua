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
	text = [[#LIGHT_GREEN#*당신의 앞에, 빛나는 금색 갑옷을 걸친 아름다운 여성이 서있습니다.*#WHITE#
멈춰라! 수상한 자! 이곳에 온 목적이 뭐냐? 아침의 문은 이 땅에서 유일하게 남은, 최후의 피난처다! 정체를 밝혀라! 스파이냐?]],
	answers = {
		{"숙녀분이시여, 물론 저는 이 땅에서 처음 보는 사람일 수밖에 없습니다. 저는 서쪽, 마즈'에이알 대륙에서 왔습니다.", jump="from",
		  cond=function(npc, player) return player:hasQuest("strange-new-world") and player:hasQuest("strange-new-world"):isCompleted("helped-fillarel") end},
		{"죄송합니다, 이만 가볼게요!"},
	}
}

newChat{ id="from",
	text = [[마즈'에이알! 오랜 세월동안 우리는 그곳의 사람들과 연락하려는 시도를 해왔지. 물론 언제나 실패했지만.
어찌됐건, 여기에 온 목적이 뭐냐?]],
	answers = {
		{"이 낯선 땅에서 오도가도 못하는 신세가 된 것 같아서 그렇습니다. #LIGHT_GREEN#*지금까지 오크를 사냥했던 이야기와 필라렐과의 만남을 이야기합니다.*#WHITE#", jump="orcs"},
		{"태양의 기사들? 그들은 누구입니까? 제가 왔던 곳에서는 존재하지 않던 자들입니다.", jump="sun-paladins", cond=function() return profile.mod.allow_build.divine_sun_paladin end},
	}
}

newChat{ id="sun-paladins",
	text = [[우리는 이곳 태양의 장벽의 강력한 전사들이다. 태양의 힘을 사용하며, 육체적 수련을 병행하는 전사들이지.
수백 년 동안, 우리는 오크 무리들로부터 자유민들을 지켜왔다. 우리의 숫자는 줄어들고 있지만, 우리는 마지막 숨이 붙어있는 그 순간까지 이곳을 굳건히 지킬 것이다.]],
	answers = {
		{"숙녀분이시여, 고귀한 정신을 가지고 계시군요.", jump="from"},
	}
}

newChat{ id="orcs",
	text = [[오크! 아! 그렇다면 너에게 있어 오늘은 운이 좋은 날이겠군. 이 대륙은 오크들이 모조리 점령한 상태다. 그들은 무리를 형성해서 돌아다니고 있고, 소문에 의하면 그들의 지배자는 강력하다는 말이 있다.
그들은 이 땅을 자유롭게 돌아다니며, 심지어는 우리를 공격하기도 하지.
@playername7@여, 자네는 우리 일원 중 하나를 도와주었다. 태양의 장벽의 이름으로, 자네를 동료로 받아들이고 아침의 문에 출입할 권한을 주도록 하지.]],
	answers = {
		{"감사합니다, 숙녀분이시여.", action=function(npc, player)
			world:gainAchievement("STRANGE_NEW_WORLD", game.player)
			player:setQuestStatus("strange-new-world", engine.Quest.DONE)
			local spot = game.level:pickSpot{type="npc", subtype="aeryn-main"}
			npc:move(spot.x, spot.y, true)
			npc.can_talk = "gates-of-morning-main"
		end},
	}
}

return "welcome"
