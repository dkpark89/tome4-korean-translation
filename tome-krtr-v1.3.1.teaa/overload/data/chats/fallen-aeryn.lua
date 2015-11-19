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

require "engine.krtrUtils"

local function kill(npc, player)
	player:setQuestStatus("high-peak", engine.Quest.COMPLETED, "killed-aeryn")
	npc.die = nil
	mod.class.NPC.die(npc, player)
end

local function spare(npc, player)
	player:setQuestStatus("high-peak", engine.Quest.COMPLETED, "spared-aeryn")
	npc.die = nil
	game.level:removeEntity(npc)
	game.logPlayer(player, "%s 그녀의 목걸이를 쥐더니, 마법 에너지로 화해 사라집니다.", (npc.kr_name or npc.name):capitalize():addJosa("이"))
end

newChat{ id="welcome",
	text = [[#LIGHT_GREEN#*그녀는 거의 죽은 채로 당신의 발 밑에 누워있습니다.*#WHITE#
그래... 이제 나를 죽이고 이 파괴의 고리를 끝내주겠어?]],
	answers = {
		{"무슨 말입니까? 대체 왜 나를 공격한거죠?", jump="what"},
		{"우선 얘기를 들어야겠습니다. 대체 왜 나를 공격한거죠?", jump="what"},
		{"[그녀를 죽인다]", action=kill},
	}
}

newChat{ id="what",
	text = [[설마... 몰랐던거야?
네가 이곳에 들어간지 몇 시간 되지 않아, 오크 무리가 쳐들어왔지. 아니, 오크 뿐만이 아니었어. 악마들도 그 무리에 섞여있었지. 우리는 완전히 제압되었어! 완전히 파괴되었다고!
더 이상 내가 있을 곳은 없어! 이건 다 네가 검게 탄 상처에서 그들을 멈추지 못했기 때문이야! 너 때문에 우리는 실패했어! 너를 보호하기 위해 사람들이 죽었지만, 너는 실패했다고!
#LIGHT_GREEN#*그녀가 눈물을 흘리기 시작합니다...*#WHITE#]],
	answers = {
		{"제가 실수를 했다는 것은 알고 있습니다. 그렇기 때문에, 그것들을 고치려고 노력하고 있습니다. 저에게 기회를 주십시오. 저는 그들을 살리지 못했지만, 적어도 그들의 죽음을 의미 있는 것으로 만들어 보이겠습니다!", action=spare},
		{"[그녀를 죽인다]", action=kill},
	}
}

return "welcome"
