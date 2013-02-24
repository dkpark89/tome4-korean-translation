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

local function attack_krogar(npc, player)
	local fillarel, krogar
	for uid, e in pairs(game.level.entities) do
		if e.define_as == "FILLAREL" and not e.dead then fillarel = e
		elseif e.define_as == "CORRUPTOR" and not e.dead then krogar = e end
	end
	krogar.faction = "enemies"
	fillarel.inc_damage.all = -80
	fillarel:setTarget(krogar)
	krogar:setTarget(filarel)
	game.player:setQuestStatus("strange-new-world", engine.Quest.COMPLETED, "sided-fillarel")
end

local function attack_fillarel(npc, player)
	local fillarel, krogar
	for uid, e in pairs(game.level.entities) do
		if e.define_as == "FILLAREL" and not e.dead then fillarel = e
		elseif e.define_as == "CORRUPTOR" and not e.dead then krogar = e end
	end
	fillarel.faction = "enemies"
	krogar.inc_damage.all = -80
	fillarel:setTarget(krogar)
	krogar:setTarget(filarel)
	game.player:setQuestStatus("strange-new-world", engine.Quest.COMPLETED, "sided-krogar")
end

game.player:grantQuest("strange-new-world")

newChat{ id="welcome",
	text = [[#LIGHT_GREEN#*금빛 로브를 입은, 아름다운 엘프 여성이 당신 앞에 서있습니다. 그녀는 갑옷을 걸친 오크와 마주하고 있습니다.*#WHITE#
필라렐 : "항복하라, 오크! 너는 이길 수 없다. 나는 태양의 힘과 달의 그림자를 다루는 자다!"
크로가르 : "하! 이제 한 시간밖에 지나지 않았건만, 벌써 지쳐보이는군 그래, '아가씨'."
#LIGHT_GREEN#*당신이 이곳에 도착하자, 그들이 당신을 쳐다봅니다.*#WHITE#
필라렐 : "자네! @playerdescriptor.race@! 나를 도와 이 괴물을 물리치거나, 아니면 저리 물러나게!"
크로가르 : "아, 도움을 구하시겠다? 하. @playerdescriptor.race@, 이 년을 죽이면 내가 답례를 해주겠다!"]],
	answers = {
		{"[크로가르를 공격한다]", action=attack_krogar},
--		{"[attack Fillarel]", action=attack_fillarel, cond=function(npc, player) return not player:hasQuest("start-sunwall") and config.settings.cheat end},
	}
}
return "welcome"
