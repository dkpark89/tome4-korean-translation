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

local function void_portal_open(npc, player)
	-- Charred scar was successful
	if player:hasQuest("charred-scar") and player:hasQuest("charred-scar"):isCompleted("stopped") then return false end
	return true
end
local function aeryn_alive(npc, player)
	if game.state:isUniqueDead("High Sun Paladin Aeryn") then return false end

	-- Charred scar was successful
	if player:hasQuest("charred-scar") and player:hasQuest("charred-scar"):isCompleted("stopped") then return true end

	-- Spared aeryn
	return player:isQuestStatus("high-peak", engine.Quest.COMPLETED, "spared-aeryn")
end
local function aeryn_dead(npc, player) return not aeryn_alive(npc, player) end

local function aeryn_comes(npc, player)
	local x, y = util.findFreeGrid(player.x, player.y, 1, true, {[engine.Map.ACTOR]=true})
	local aeryn = game.zone:makeEntityByName(game.level, "actor", "HIGH_SUN_PALADIN_AERYN")
	if aeryn then
		game.zone:addEntity(game.level, aeryn, "actor", x, y)
		game.player:setQuestStatus("high-peak", engine.Quest.COMPLETED, "aeryn-helps")
		game.logPlayer(player, "고위 태양의 기사 아에린이 당신 옆에 나타났습니다!")

		-- The sorcerer focus her first
		for uid, e in pairs(game.level.entities) do
			if e.define_as and (e.define_as == "ELANDAR" or e.define_as == "ARGONIEL") then
				e:setTarget(aeryn)
			end
		end
	end
end

newChat{ id="welcome",
	text = [[#LIGHT_GREEN#*두 주술사들이 당신 앞에 서있습니다. 그들은 마치 태양과 같이 빛나고 있습니다.*#WHITE#
아! 우리 손님 분이 드디어 오셨군 그래. 최고봉을 오르는 길은 즐거우셨는지요?]],
	answers = {
		{"잠깐 이야기를 하지. 나는 너희들을 멈추러 왔다!", jump="explain"},
		{"이런 일을 하는 이유는 대체 뭐지? 너희들은 사람들을 돕기로 한 것 아니였나!", jump="explain"},
	}
}

newChat{ id="explain",
	text = [[오, 우리가 원하는 것은 사람들을 도우는 것입니다. 우리는 '지금의 사람들은 그들만의 정부를 꾸려가는데 적합하지 않다' 는, 자명한 결론을 내었습니다. 언제나 말다툼하고, 논쟁하고...
오크들의 마지막 침공 이래, 그들을 연합시키는 위협은 없었지요!]],
	answers = {
		{"그래서 너희들 스스로가 '위협' 이 되기로 한건가?", jump="explain2"},
	}
}

newChat{ id="explain2",
	text = [[우리들 말인가요? 아뇨, 우리는 진정한 '주인님' 을 위한 하찮은 도구일 뿐이지요. 우리는 그의 귀환을 계획하고 있습니다.]],
	answers = {
		{"'그' 라니...?", jump="explain3"},
	}
}

if void_portal_open(nil, game.player) then
newChat{ id="explain3",
	text = [[창조자. 이 세계를 만든 신. 종족들 간에 서로 싸우고 대지를 불태우는 것을 조용히 지켜본 자.
이 세계에 큰 실망과 슬픔을 느낀 자. 이 세계의 보호막을 박살내고 더 좋은 방향으로 세계를 재창조할 자!
이 지팡이를 통해, 우리는 이 세계에서 충분한 힘을 모았습니다. 이 공허와 통하는 관문을 열어, 그를 소환할 수 있을 정도로 말이지요!
그리고, 당신은 이미 늦었습니다. 그는 이제 우리의 소환에 응답해 이곳에 나타날 것입니다. 이제 시간문제인 일이지요!]],
	answers = {
		{"나는 *반드시* 너희를 멈출 것이다! 오늘 세계는 멸망하지 않을 것이다!", jump="aeryn", switch_npc={name="High Sun Paladin Aeryn"}, action=aeryn_comes, cond=aeryn_alive},
		{"나는 *반드시* 너희를 멈출 것이다! 오늘 세계는 멸망하지 않을 것이다!", cond=aeryn_dead},
	}
}
else
newChat{ id="explain3",
	text = [[창조자. 이 세계를 만든 신. 종족들 간에 서로 싸우고 대지를 불태우는 것을 조용히 지켜본 자.
이 세계에 큰 실망과 슬픔을 느낀 자. 이 세계의 보호막을 박살내고 더 좋은 방향으로 세계를 재창조할 자!
이 지팡이를 통해, 우리는 이 세계에서 충분한 힘을 모았습니다. 이 공허와 통하는 관문을 열어, 그를 소환할 수 있을 정도로 말이지요!
당신은 우리를 막지 못할 것입니다!]],
	answers = {
		{"나는 *반드시* 너희를 멈출 것이다! 오늘 세계는 멸망하지 않을 것이다!", jump="aeryn", switch_npc={name="High Sun Paladin Aeryn"}, action=aeryn_comes, cond=aeryn_alive},
		{"나는 *반드시* 너희를 멈출 것이다! 오늘 세계는 멸망하지 않을 것이다!", cond=aeryn_dead},
	}
}
end

newChat{ id="aeryn",
	text = [[#LIGHT_GREEN#*당신 주변의 대기가 휘몰아치더니, 갑자기 고위 태양의 기사 아에린이 나타납니다!*#WHITE#
그렇다면 그대는 혼자가 아닐지언저! 우리는 함께 저들을 막거나, 이곳에서 함께 죽음을 맞이하리라!]],
	answers = {
		{"당신이 제 편에 서준다니 기쁘군요. 저 마법사들을 사냥할 시간입니다!"},
	}
}

return "welcome"
