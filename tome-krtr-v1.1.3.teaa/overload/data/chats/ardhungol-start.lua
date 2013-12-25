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

if not game.state:isAdvanced() and game.player.level < 20 then
newChat{ id="welcome",
	text = [[안녕하세요.]],
	answers = {
		{"안녕하십니까."},
	}
}
return "welcome"
end

if not game.player:hasQuest("spydric-infestation") then
newChat{ id="welcome",
	text = [[당신이 서쪽에서 온 위대한 영웅이라는 소문을 들었습니다. 저를 도와주세요, 제발.]],
	answers = {
		{"가능하다면요. 무슨 일이길래?", jump="quest", cond=function(npc, player) return not player:hasQuest("spydric-infestation") end},
		{"지금도 해결해야 할 문제가 너무 많습니다. 죄송하게 됐군요."},
	}
}
else
newChat{ id="welcome",
	text = [[@playername@씨, 돌아오셔서 반갑습니다.]],
	answers = {
		{"당신의 남편을 찾았습니다. 그가 무사히 집에 돌아갔는지요?", jump="done", cond=function(npc, player) return player:isQuestStatus("spydric-infestation", engine.Quest.COMPLETED) end},
		{"저는 이제 가봐야 합니다. 안녕히."},
	}
}
end

newChat{ id="quest",
	text = [[제 남편, 태양의 기사 라심은 이 마을 북쪽에 있는 알드훈골의 굴에서 거미들을 처리하는 임무를 받았습니다.
이제 그가 떠난지 벌써 3 일이 지나, 이제는 그가 돌아와야 할 때입니다. 하지만 저는 그에게 뭔가 끔찍한 일이 생겼다는 느낌이 듭니다. 부디 그를 찾아주세요!
분명 그는 아노리실에게 이곳으로 즉시 돌아올 수 있는 마법석을 받았는데도, 아직 그것을 사용하지 않았거든요!]],
	answers = {
		{"한번 그를 찾아보겠습니다.", action=function(npc, player) player:grantQuest("spydric-infestation") end},
		{"거미? 아으으, 죄송합니다. 하지만 그는 이미 죽었을 거에요."},
	}
}

newChat{ id="done",
	text = [[아, 덕분에요! 그가 말하길, 당신이 아니였다면 그곳에서 꼼짝없이 죽었을 거라고 하더군요.]],
	answers = {
		{"별 것 아니였습니다.", action=function(npc, player)
			player:setQuestStatus("spydric-infestation", engine.Quest.DONE)
			world:gainAchievement("SPYDRIC_INFESTATION", game.player)
			game:setAllowedBuild("divine")
			game:setAllowedBuild("divine_sun_paladin", true)
		end},
	}
}

return "welcome"
