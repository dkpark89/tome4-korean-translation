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
	game.log([[당신이 떠날 때 '암살단 단장'이 말하길: "그리고 잊지마라, 넌 이제 내 꺼다."]]) --@@ ''와 ""를 모두 사용하기 위해, [[]]로 바꿈
end

newChat{ id="welcome",
	text = [[#LIGHT_GREEN#*당신이 멈추기 전에 검은 옷을 입은 위협적인 남자가 말하길.*#WHITE#
아, 침입자가 여기 있군... 우리가 네 녀석을 어떻게 처리 해야할까? 왜 나의 부하들을 죽였지?]],
	answers = {
		{"나는 여기서 들리는 울부짖음을 따라왔고, 그리고 당신의 부하들이... 그들이 오는 길 도중에 있었지. 도대체 무슨 일이 있었던 거지?", jump="what"},
		{"여기 어딘가에 보물이 있을 것 같아서 왔지.", jump="greed"},
		{"미안, 난 가봐야 할 것 같아!", jump="hostile"},
	}
}

newChat{ id="hostile",
	text = [[Oh, you are not going anywhere, I'm afraid! KILL!]],
	answers = {
		{"[공격한다]", action=function(npc, player) engine.Faction:setFactionReaction(player.faction, npc.faction, -100, true) end},
		{"잠깐! 당신은 실질주의자처럼 보이는데; 어쩌면 우리들끼리 어떻게 합의를 볼 수 있을지도 몰라.", jump="offer"},
	}
}

newChat{ id="what",
	text = [[Oh, so this is the part where I tell you my plan before you attack me? GET THIS INTRUDER!]],
	answers = {
		{"[공격한다]", action=function(npc, player) engine.Faction:setFactionReaction(player.faction, npc.faction, -100, true) end},
		{"잠깐! 당신은 실질주의자처럼 보이는데; 어쩌면 우리들끼리 어떻게 합의를 볼 수 있을지도 몰라.", jump="offer"},
	}
}
newChat{ id="greed",
	text = [[I am afraid this is not your lucky day then. The merchant is ours... and so are you! GET THIS INTRUDER!!]],
	answers = {
		{"[공격한다]", action=function(npc, player) engine.Faction:setFactionReaction(player.faction, npc.faction, -100, true) end},
		{"잠깐! 당신은 실질주의자처럼 보이는데; 어쩌면 우리들끼리 어떻게 합의를 볼 수 있을지도 몰라.", jump="offer"},
	}
}

newChat{ id="offer",
	text = [[Well, I need somebody to replace the men you killed. You look sturdy; maybe you could work for me.
You will have to do some dirty work for me, though, and you will be bound to me.  Nevertheless, you may make quite a profit from this venture, if you are as good as you seem to be.
And do not think of crossing me.  That would be... unwise.]],
	answers = {
		{"뭐, 확실히 죽는 것 보다는 낫겠지.", action=evil},
		{"돈? 나도 끼워줘!", action=evil},
		{"나와 상인을 여기서 나가게 해주면 네 목숨만은 살려주지!", action=function(npc, player) engine.Faction:setFactionReaction(player.faction, npc.faction, -100, true) end},
	}
}

return "welcome"
