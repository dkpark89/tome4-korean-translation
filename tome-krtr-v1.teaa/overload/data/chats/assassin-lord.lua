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

local function evil(npc, player)
	engine.Faction:setFactionReaction(player.faction, npc.faction, 100, true)
	player:setQuestStatus("lost-merchant", engine.Quest.COMPLETED, "evil")
	player:setQuestStatus("lost-merchant", engine.Quest.COMPLETED)
	world:gainAchievement("LOST_MERCHANT_EVIL", player)
	game:setAllowedBuild("rogue_poisons", true)
	local p = game.party:findMember{main=true}
	if p.descriptor.subclass == "Rogue"  then
		if p:knowTalentType("cunning/poisons") == nil then
			p:learnTalentType("cunning/poisons", false)
			p:setTalentTypeMastery("cunning/poisons", 1.3)
		end
	end
	game:changeLevel(1, "wilderness")
	game.log([[당신이 떠날 때, '암살단 단장' 이 말했습니다. "그리고 잊지마라, 넌 이제 내 거니까."]]) --@@ ''와 ""를 모두 사용하기 위해, [[]]로 바꿈
end

newChat{ id="welcome",
	text = [[#LIGHT_GREEN#*검은 옷을 입은 위협적인 남자가 당신 앞에 서있습니다.*#WHITE#
아아, 그래 침입자여... 우리가 네 녀석을 어떻게 처리해야 할까? 왜 나의 부하들을 죽였지?]],
	answers = {
		{"나는 여기서 들리는 비명소리를 따라왔고, 그리고 당신의 부하들이... 그들이 내가 가는 길을 막아섰지. 도대체 무슨 일이 있었던 거지?", jump="what"},
		{"여기 어딘가에 보물이 있을 것 같아서 왔지.", jump="greed"},
		{"죄송합니다, 지금 나갈게요!", jump="hostile"},
	}
}

newChat{ id="hostile",
	text = [[오, 어딜 도망가시려고? 이곳을 발견해놓고? #{bold}#죽여라!#{normal}#]],
	answers = {
		{"[공격한다]", action=function(npc, player) engine.Faction:setFactionReaction(player.faction, npc.faction, -100, true) end},
		{"잠깐! 당신은 꽤 실용주의자로 보이는데. 어쩌면 우리들끼리 어떻게 합의를 볼 수 있을지도 몰라.", jump="offer"},
	}
}

newChat{ id="what",
	text = [[오, 그런다고 내가 너를 공격하기 전에 내 계획을 말해줄 것 같았나? #{bold}#침입자를 잡아라!#{normal}#]],
	answers = {
		{"[공격한다]", action=function(npc, player) engine.Faction:setFactionReaction(player.faction, npc.faction, -100, true) end},
		{"잠깐! 당신은 꽤 실용주의자로 보이는데. 어쩌면 우리들끼리 어떻게 합의를 볼 수 있을지도 몰라.", jump="offer"},
	}
}
newChat{ id="greed",
	text = [[그렇다면 오늘은 네 행운의 날이 아니라는 말을 해줘야겠군. 이 상인은 우리 것이고... 이제 너도 그렇게 되겠지! #{bold}#침입자를 잡아라!!#{normal}#]],
	answers = {
		{"[공격한다]", action=function(npc, player) engine.Faction:setFactionReaction(player.faction, npc.faction, -100, true) end},
		{"잠깐! 당신은 꽤 실용주의자로 보이는데. 어쩌면 우리들끼리 어떻게 합의를 볼 수 있을지도 몰라.", jump="offer"},
	}
}

newChat{ id="offer",
	text = [[흠, 사실 네가 죽여버린 부하들을 대신할 사람을 찾고 있는건 맞아. 너도 꽤 강해보이는게, 나를 위해 일할 정도는 되는 것 같군.
너는 나를 위해 몇몇 더러운 일들을 해줄 필요가 있어. 물론, 너는 내 부하가 되는거지. 그렇지만 꽤 많은 수입이 있을 거라는 것 정도는 보장하지. 네가 보기만큼 일을 잘 해줬을 경우의 말이지만.
그리고 나를 배신할 생각은 하지 않는게 좋아. 그건 굉장히... 현명하지 못한 선택이 될테니까.]],
	answers = {
		{"뭐, 확실히 여기서 죽는 것보다는 낫겠지.", action=evil},
		{"돈? 나도 끼워줘!", action=evil},
		{"나와 상인을 여기서 나가게 해주면 네 목숨만은 살려주지!", action=function(npc, player) engine.Faction:setFactionReaction(player.faction, npc.faction, -100, true) end},
	}
}

return "welcome"
