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

-----------------------------------------------------------------------
-- Default
-----------------------------------------------------------------------
if not game.player:isQuestStatus("temple-of-creation", engine.Quest.COMPLETED, "slasul-story") then

newChat{ id="welcome",
	text = [[이게 무슨 짓인가? 나의 신전에 들어와서 내 동료들을 살해한 이유는 무엇인가?
말하라, 그렇지 않으면 죽을 것이다. 나 슬라슐의 이름으로, 너는 내 계획을 방해하지 못할 것이다.]],
	answers = {
		{"[공격한다]", action=attack("그게 네 대답인가... 그렇다면 죽어라!")},
		{"나는 우클름스윅이 보내, 너의 모든 수중 생물들을 지배하려는 정신나간 계획을 멈추러 왔다!", jump="quest"},
	}
}

newChat{ id="quest",
	text = [[그렇군. 그 용이 너를 보냈군. 내가 미쳤다고 생각하는건 그 용이 말해준거라고 생각하는데, 맞나?
하지만, 우리들 중 그 누가 진정한 악이란 말인가? 나는 내 사람들을 발전시키기 위해 일하고 있고, 너를 포함한 어느 누구에게도 해를 끼치지 않았다. 하지만 너는 내 친구들을 모두 죽여버리면서, 나를 죽이기 위해 이곳에 왔다!
누가 진짜 미쳤다는 것인가?]],
	answers = {
		{"나를 타락시키려는 네 서투른 시도는 통하지 않는다. 네 죗값을 치뤄라!", action=attack("그 이유를 생각조차 하지 않는다면, 어쩔 수 없군!")},
		{"그 말은... 거슬리는군. 내가 왜 너에게 자비를 베풀어야 하지?", jump="givequest"},
	}
}

newChat{ id="givequest",
	text = [[나에게 자비를 베푼다?#LIGHT_GREEN#*그가 웃습니다.*#WHITE#
섣불리 말하지 말라. 자비를 구해야 할 자는 내가 아니라, 바로 네놈이다!
그래, 내 이야기를 해주도록 하지. 너희 지표면에 사는 자들은 나가들에 대해 그다지 많은 것을 알지 못한다. 하지만 이걸 말하고 싶군. 현재 우리의 상태는 우리가 선택한 것이 아니다.
날로레들의 영토가 바다에 가라앉았을 때, 많은 자들이 죽음을 맞이했다. 그래서 우리는 이 신전의 마법에 기댈 수밖에 없었지. 다행히도 마법은 제대로 작동해서, 우리를 살렸다. 하지만 우리는 저주받게 되었지. 그 끔찍한 마법은 우리를 이런 모양으로 만들었다.
내가 한 말을 믿지 못해도 좋다. 하지만 이것만은 믿어주었으면 한다. 쉐르'툴 종족은 사라지지 않았다. 단지 숨어있을 뿐이지. 또한 그 실체 역시, 자비와는 거리가 먼 종족들이다.
최근, 자네를 여기로 보낸 물의 용이 "요원" 들을 보내 이 신전을 확보하려 하고 있다. 그의 목표는 확신할 수 없지만, 최소한 평화적인 목적이 아니라는 것만은 확실하지.]],
	answers = {
		{"정신 나간 사람이 할 말은 아닌 것 같군요... 우클름스윅이 거짓말을 했을까요?", jump="portal_back", action=function(npc, player) player:setQuestStatus("temple-of-creation", engine.Quest.COMPLETED, "slasul-story") end},
		{"네 거짓말에 속지 않으리라! 너에게 희생된 것들에 대한 대가를 치뤄라!", action=attack("이런 상황을 원한 것은 아니다만... 자네가 원한다면.")},
	}
}

newChat{ id="portal_back",
	text = [[이 관문을 사용하게. 그 수중 동굴로 자네를 데려다 줄걸세. 그에게 진실을 묻게.]],
	answers = {
		{"그에게 나를 속인 것에 대한 대가를 치루게 하겠습니다.", action=function(npc, player) 
			player:hasQuest("temple-of-creation"):portal_back() 
			for uid, e in pairs(game.level.entities) do
				if e.faction == "enemies" then e.faction = "temple-of-creation" end
			end
		end},
	}
}

-----------------------------------------------------------------------
-- Coming back later
-----------------------------------------------------------------------
else
newChat{ id="welcome",
	text = [[내 말을 들어주어 고맙네.]],
	answers = {
		{"그 용의 말은 거짓이었습니다. 저는 느낄 수 있습니다. 당신과 뜻을 함께 하기로 결심했습니다.", jump="cause", cond=function(npc, player) return player:knowTalent(player.T_LEGACY_OF_THE_NALOREN) and not player:isQuestStatus("temple-of-creation", engine.Quest.COMPLETED, "legacy-naloren") end},
		{"그럼 이만, 슬라슐."},
		{"[공격한다]", action=attack("그렇다면... 죽어라!")},
	}
}

newChat{ id="cause",
	text = [[자네가 그래주길 내심 바랬다네.
이 동맹을 더욱 공고히 하세. 자네의 생명력을 나와 나누게나! 이를 통해 자네가 살아있는 동안, 나는 죽지 않을 수 있게 된다네!
그 답례로, 자네에게 이 강력한 삼지창을 주도록 하지.]], 
	answers = {
		{"그 제안을 받아들이겠습니다, 나의 왕이시여.", action=function(npc, player)
			local o = game.zone:makeEntityByName(game.level, "object", "LEGACY_NALOREN", true)
			if o then
				o:identify(true)
				player:addObject(player.INVEN_INVEN, o)
				npc:doEmote("이제 우리는 한몸이나 마찬가지일세!", 150)
				game.level.map:particleEmitter(npc.x, npc.y, 1, "demon_teleport")
				game.level.map:particleEmitter(player.x, player.y, 1, "demon_teleport")
				npc.invulnerable = 1
				npc.never_anger = 1
				player:setQuestStatus("temple-of-creation", engine.Quest.COMPLETED, "legacy-naloren")
			end
		end},
		{"그 말은 이상하게 들리는군요. 다시 생각을 해보겠습니다."},
	}
}

end

return "welcome"
