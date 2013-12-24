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

-----------------------------------------------------------
-- Non-yeek version
-----------------------------------------------------------

newChat{ id="welcome",
	text = [[#LIGHT_GREEN#*당신 앞에 하플링만한 키에, 짧은 흰색 털가죽과 굉장히 큰 머리를 가진 생명체가 서있습니다.
당신은 그의 손이 대검을 잡고 있지 않다는 것을 발견했습니다. 그의 검은 공중을 떠다니며, 그의 의지를 따르는 것 같습니다.*#WHITE#
왜 저를 구해주셨습니까, 낯선 이여. 당신은 '한길' 의 사람이 아닙니다만.]],
	answers = {
		{"음, 당신이 도움이 필요해보여서 그랬지요.", jump="kindness"},
		{"내가 직접 네 목을 따고 싶었기 때문이지!", action=function(npc, player) npc:checkAngered(player, false, -200) end},
	}
}

newChat{ id="kindness",
	text = [[#LIGHT_GREEN#*공중을 떠다니는 대검이 조금 덜 호전적인 움직임을 보입니다. 그는 놀란 것 같습니다.*#WHITE#
그렇다면 '한길' 을 대신해서, 감사드립니다.]],
	answers = {
		{"'한길' 은 대체 무엇이고, 당신은 무슨 종족인가요?", jump="what"},
	}
}

newChat{ id="what",
	text = [['한길' 은 깨달음이자, 평화이며, 보호입니다. 그리고 저는 이크 종족입니다. 저는 수 세기 동안 닫혀있던 이 터널을 통해 세계를 탐험하려고 왔습니다.]],
	answers = {
		{"'한길' 에 대해 더 설명해줄 수 있나요?", jump="way", action=function(npc, player)
			game.party:reward("정신적 보호를 받을 인원을 고르세요 :", function(player)
				player.combat_mentalresist = player.combat_mentalresist + 15
				player:attr("confusion_immune", 0.10)
			end)
			game.logPlayer(player, "'한길' 의 추종자가 당신의 정신을 보호해주는 힘을 불어넣었습니다. (정신 내성 +15, 혼란 면역 +10%%)")
		end},
--		{"So you will wander the land alone?", jump="done"},
	}
}

newChat{ id="done",
	text = [[저는 결코 혼자가 아닙니다. 저에게는 '한길' 이 있습니다.]],
	answers = {
		{"음... 그럼 이만.", action=function(npc, player) npc:disappear() end},
	}
}

newChat{ id="way",
	text = [[그럴 수는 없습니다. 하지만 당신에게 살짝 보여주도록 하죠.
#LIGHT_GREEN#*그가 당신에게 몸을 기댔습니다. 당신의 정신은 갑자기 평화와 행복함으로 가득 찼습니다.*#WHITE#
이것이 '한길' 입니다.]],
	answers = {
		{"좋은 것을 보여주어 고맙습니다. 그럼 잘 지내시길, 나의 친구여.", action=function(npc, player)
			npc:disappear()
			game:setAllowedBuild("yeek", true)
		end},
	}
}

-----------------------------------------------------------
-- Yeek version
-----------------------------------------------------------

newChat{ id="yeek-welcome",
	text = [['한길' 이여, 감사합니다. 이... 것... 이 저를 죽이려 했습니다.]],
	answers = {
		{"'한길' 이 이 터널의 반대편을 조사해보라고 했습니다.", jump="explore"},
	}
}

newChat{ id="explore",
	text = [[네, 저 역시 그렇습니다. 우리는 갈라져서 이 땅을 찾아보는 것이 좋을 것 같군요.]],
	answers = {
		{"안녕히 가십시오. 우리는 언제나 '한길' 을 걷고 있을 것입니다.", action=function()
			game:setAllowedBuild("psionic")
			game:setAllowedBuild("psionic_mindslayer", true)
		end},
	}
}

return (game.party:findMember{main=true}.descriptor.race == "Yeek") and "yeek-welcome" or "welcome"
