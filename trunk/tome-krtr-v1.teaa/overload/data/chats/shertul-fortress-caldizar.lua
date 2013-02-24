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

local has_staff = false
local o, item, inven_id = player:findInAllInventoriesBy("define_as", "STAFF_ABSORPTION")
if o then has_staff = true end
local o, item, inven_id = player:findInAllInventoriesBy("define_as", "STAFF_ABSORPTION_AWAKENED")
if o then has_staff = true end

local speak
if has_staff then
	speak = [["너는 이곳에 있어서는 안된다. 어떻게 이곳-"#{normal}# 그것은 갑자기 멈췄습니다. 당신의 손에 들려 있는 지팡이에 관심을 보이는 것 같습니다. #{italic}#"어떻게 이것을 손에 넣었지?! 무지한 것, 네가 다루려는 힘이 무엇인지조차 모르는구나! 이제 이곳에서 나가라. 썩 꺼져!"]]
else
	speak = [["너는 이곳에 있어서는 안된다. 어떻게 이곳에 온거지?! 썩 꺼져!"]]
end

newChat{ id="welcome",
	text = [[#{italic}#문을 열자, 당신은 그 앞에 있는 것에 놀라움을 감추지 못했습니다. 하나의 생명체가 당신 앞에 서있습니다. 촉수를 닮은 긴 팔다리와 땅딸막한 머리, 강력한 힘의 기운이 퍼져나오는 이 생명체는 당신이 생전 처음 느껴보는 것입니다. 이 생명체는 쉐르'툴이 분명합니다. 그것도 살아있는 쉐르'툴!
	
하지만 당신의 존재를 알아차린 쉐르'툴에 의해, 당신의 감탄은 끊겼습니다. 그리고 당신은 강렬한 압도되는 듯한 멈출 수 없는 힘을 느꼈습니다. 머리 속에서 목소리가 울립니다. #{normal}#]]..speak..[[#{italic}#

정신적이고 마법적인 힘의 파동이 당신에게 유성처럼 몰아쳤습니다. 당신은 대기 중에 띄워졌으며, 강력한 압력이 당신의 피부 전체를 압도했습니다. 당신은 이렇게 짓눌려 아무 것도 아닌 존재가 될까봐 공포에 떨었습니다. 당신은 저항해보려 했지만, --#{normal}#]],
	answers = {
		{"[계속]", jump="next", action=function(npc, player)
			game:changeLevel(1, "shertul-fortress", {direct_switch=true})
			local spot = game.level:pickSpot{type="spawn", subtype="farportal"} or {x=39, y=29}
			game.player:move(spot.x, spot.y, true)
			world:gainAchievement("CALDIZAR", game.player)
			game.party:learnLore("shertul-fortress-caldizar")
		end},
	}
}

newChat{ id="next",
	text = [[#{italic}#엄청난 두통과 함께, 당신은 당신의 장거리 관문 옆에서 일어났습니다. 얼굴은 땀으로 젖었으며, 그것을 만지자 당신은 손가락이 붉게 물들었다는 것을 깨달았습니다. 당신은 피눈물을 흘렸던 것 같습니다. 어둡고 끔찍한 기억들이 당신의 정신 깊숙히 파고들었습니다. 하지만 기억해내려 할수록 더 기억하기 힘들어지다가, 천천히 지워져 완전히 사라졌습니다. 마치 꿈인 듯 말이죠.#{normal}#]],
	answers = {
		{"[끝낸다]"},
	}
}

return "welcome"
