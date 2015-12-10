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
local ogretext = ""
if player.descriptor and player.descriptor.subrace == "Ogre" then
	ogretext = "\n\n#{italic}##LIGHT_GREEN#*포션을 마시자, 당신의 룬들은 타올라 흐려지고, 끔찍한 고통이 당신의 피부에서부터 뼈, 근육, 심장까지 잠식합니다. 고통에 당신은 잠시 기절하고맙니다. 조금 뒤, 룬들은 전부 사라지고, 당신은 매우 기분이 나빴지만 그럼에도 불구하고... 정화된 기분입니다.*#{normal}##WHITE#"
end

newChat{ id="welcome",
	text = ([[훌륭했네! 자네는 마법사가 만들어낸 화염과 폭풍 따위는 검과 화살의 상대가 되지 않는다는 것을 입증했네! 오게, 우리의 방식을 배우게. 자네는 준비가 됐네.
#LIGHT_GREEN#*그가 당신에게 물약을 건넵니다.*#WHITE#
이걸 마시게. 우리는 매우 희귀한 종류의 드레이크에게서 이것을 추출해냈다네. 이 물약은 자네에게 마법에 맞서 싸울 수 있고 마법적인 능력을 없애버리는 힘을 줄걸세. 하지만 자네는 영원히 마법을 사용할 수 없게 된다는 것을 잊지 말게나.%s]]):format(ogretext),
	answers = {
		{"감사합니다. 저는 이제부터 마법이 승리하게 놔두지 않을 것입니다! #LIGHT_GREEN#[물약을 마신다]", action=function(npc, player) player:setQuestStatus("antimagic", engine.Quest.COMPLETED) end},
	}
}

return "welcome"
