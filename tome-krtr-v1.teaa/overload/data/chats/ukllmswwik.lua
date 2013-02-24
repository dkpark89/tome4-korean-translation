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

local function attack(str)
	return function(npc, player) engine.Faction:setFactionReaction(player.faction, npc.faction, -100, true) npc:doEmote(str, 150) end
end

-----------------------------------------------------------------------
-- Default
-----------------------------------------------------------------------
if not game.player:isQuestStatus("temple-of-creation", engine.Quest.COMPLETED, "drake-story") then

newChat{ id="welcome",
	text = [[#LIGHT_GREEN#*@npcname@의 깊은 목소리가 동굴 전체에 울려퍼집니다.*#WHITE#
이곳은 나의 영토이다. 이곳은 침입자를 친절하게 받아들이는 장소가 아니다. 네가 이곳에 온 목적은?]],
	answers = {
		{"너를 죽이고 네 보물을 가지기 위해서 왔다! 죽어라, 이 빌어먹을 물고기!", action=attack("죽어라!")},
		{"이곳에 침입하려고 온 것은 아닙니다. 지금 나가도록 하겠습니다.", jump="quest"},
	}
}

newChat{ id="quest",
	text = [[잠깐! 너라면 가치가 있겠군. 내 이야기를 하나 해주지.
장작더미의 시대 동안, 이 세계는 마법폭발의 후폭풍에 고통받고 있었다. 그리고 마즈'에이알의 대륙붕 일부는 찢겨져 바다 속으로 가라앉게 되었지.
그로 인해 날로레 엘프 종족은 멸망했다... 고 세상 사람들은 이야기하지. 하지만 그들 중 몇몇은 살아남았다. 그들은 쉐르'툴 종족이 남긴 고대의 마법을 그들 스스로에게 사용해서, 물 속에서 살아갈 수 있는 몸이 되었지.
그들의 이름은 이제 '나가' 라고 불린다. 그들은 바다 깊은 곳, 마즈'에이알 대륙과 동대륙 사이에서 살고 있지.
그들 중 하나인 슬라슐은, 그의 의지에 따라 세계를 지배하기로 결심했다. 바다 속과 지상 모두를 말이지. 그는 쉐르'툴 종족의 유적으로 생각되는 고대의 유적,'창조의 사원' 을 찾아 그곳에 머물고 있다.
그는 그곳에 잠든 힘을 통해 나가들을 한 차원 더 #{italic}#발전#{normal}#시킬 수 있다고 생각했다.
하지만 그는 미쳐버렸고, 이제 바다 속에 있는 모든 지성체들을 적으로 여긴다. 나를 포함해서 말이지.
나는 이 성역을 벗어날 수 없다. 나를 도와줄 수 있겠나?
어찌 됐건, 그의 광기를 끝내주는 것은 그에게 자비를 베풀어주는 것이 될 것이다.]],
	answers = {
		{"아니, 나는 여전히 너를 죽이고 네 보물을 가지는 것이 더 좋을 것 같군!", action=attack("죽어라!")},
		{"그 말대로 하겠습니다. 어디서 그를 찾을 수 있습니까?", jump="givequest"},
		{"그 말은... '현명하지 못한 것' 같군요. 미안합니다, 하지만 그 제안은 거절하겠습니다.", action=function(npc, player) player:grantQuest("temple-of-creation") player:setQuestStatus("temple-of-creation", engine.Quest.COMPLETED, "drake-story") player:setQuestStatus("temple-of-creation", engine.Quest.FAILED) end},
	}
}

newChat{ id="givequest",
	text = [[그가 있는 곳으로 관문을 열어줄 수 있다. 멀리 떨어진 서쪽 바다지. 하지만 조심해라. 이 관문은 단방향 관문이다. 네 복귀는 내가 장담할 수 없다. 너 스스로 길을 찾아야 할 것이다.]],
	answers = {
		{"그러죠.", action=function(npc, player) player:grantQuest("temple-of-creation") player:setQuestStatus("temple-of-creation", engine.Quest.COMPLETED, "drake-story") end},
		{"나를 죽이려는 함정이 분명하군! 잘 있으시오.", action=function(npc, player) player:grantQuest("temple-of-creation") player:setQuestStatus("temple-of-creation", engine.Quest.COMPLETED, "drake-story") player:setQuestStatus("temple-of-creation", engine.Quest.FAILED) end},
	}
}


-----------------------------------------------------------------------
-- Coming back later
-----------------------------------------------------------------------
else
newChat{ id="welcome",
	text = [[흠?]],
	answers = {
		{"[공격한다]", action=attack("이 배반자!")},
		{"네 보물을 내놔라, 물 속 짐승이여!", action=attack("오, 네 대답은 그것인가? 좋다, 가져가 보아라!")},
		{"슬라슐의 말을 들었습니다. 그는 딱히 적대적이거나 미쳐보이지 않았습니다.", jump="slasul_friend", cond=function(npc, player) return player:isQuestStatus("temple-of-creation", engine.Quest.COMPLETED, "slasul-story") and not player:isQuestStatus("temple-of-creation", engine.Quest.COMPLETED, "kill-slasul") end},
		{"잘 있으시오, 용이여."},
	}
}

newChat{ id="slasul_friend",
	text = [[#LIGHT_GREEN#*@npcname1@ 소리지릅니다!*#WHITE# 그 정신 나간 나가의 거짓말을 믿는 것인가!
너는 타락하였다! 병들었다!]],
	answers = {
		{"[공격한다]", action=attack("용들의 일에 간섭하지 말지어다!")},
		{"#LIGHT_GREEN#*자신의 머리를 흔듭니다.*#LAST#그가 내 마음을 어지럽혔습니다! 용이시여, 저는 당신의 적이 아닙니다.", jump="last_chance", cond=function(npc, player) return rng.percent(30 + player:getLck()) end},
	}
}

newChat{ id="last_chance",
	text = [[#LIGHT_GREEN#*@npcname1@ 분노를 가라앉혔습니다!*#WHITE# 좋아. 그는 정말 사기꾼이나 다름없군. 이제 가서 네 일을 끝내라. 그 전까지는 돌아올 생각도 하지 않는게 좋을 것이다!]],
	answers = {
		{"감사합니다, 위대한 자여."},
	}
}

end

return "welcome"

