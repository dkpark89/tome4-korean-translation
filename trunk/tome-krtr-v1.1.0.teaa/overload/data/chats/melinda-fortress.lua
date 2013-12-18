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

local ql = game.player:hasQuest("love-melinda")
local set = function(what) return function(npc, player) ql:setStatus(ql.COMPLETED, "chat-"..what) end end
local isNotSet = function(what) return function(npc, player) return not ql:isCompleted("chat-"..what) end end
local melinda = game.level:findEntity{define_as="MELINDA_NPC"}
local butler = game.level:findEntity{define_as="BUTLER"}
print("===", butler)

--@@ 한글화 필요 #32~78 : 내용이 추가되었음
newChat{ id="welcome",
	text = [[안녕, 내 사랑!]],
	answers = {
		{"#LIGHT_GREEN#[그녀에게 키스합니다]#WHITE#"},
		{"이곳에서의 생활은 어때?", cond=isNotSet"settle", action=set"settle", jump="settle"},
	}
}

ql.wants_to = ql.wants_to or "derth"
local dest = {
	derth = [[데르스에 작은 상점을 여는 것]],
	magic = [[앙골웬에서 마법을 배우는 것]],
	antimagic = [[지구르에서 훈련을 하는 것]],
}

newChat{ id="settle",
	text = [[뭐... 저 탱크는 #{bold}#끔찍#{normal}#하지만, 그 기묘한 집사가 말하기를 이게 유일한 방법이라고 하더라고요.
	확실히 요즘은 기분도 괜찮아지는 것 같고요.
	하지만 여기서의 생활이 조금 심심하다는 것은 꼭 말하고 싶네요.
	제가 저번에 ]]..dest[ql.wants_to]..[[에 대해 말했다는 것 기억하시나요? 낮에는 저를 그곳에 데려다주고, 밤에는 이곳에 돌아와서 치료를 받을 수 있지 않을까요?]],
	answers = {
		{"오, 그래. 그럴 수도 있겠네. 그림자, 그녀를 위해 차원의 문을 만들어줄 수 있어?", jump="portal", switch_npc=butler},
	}
}

newChat{ id="portal",
	text = [[네, 주인님. 지금 바로 가능합니다.
	그녀는 누구에게도 들키지 않고 이곳에 출입할 수 있을 것입니다.]],
	answers = {
		{"완벽하군.", jump="portal2", switch_npc=melinda, action=function(npc, player)
			local spot = game.level:pickSpot{type="portal-melinda", subtype="back"}
			if spot then
				local g = game.zone:makeEntityByName(game.level, "terrain", "TELEPORT_OUT_MELINDA")
				game.zone:addEntity(game.level, g, "terrain", spot.x, spot.y)
			end
		end},
	}
}

newChat{ id="portal2",
	text = [[오, 정말 좋네요. 고마워요! 이제 제게 저만의 비밀 거주지와, 저만의 삶이 생겼네요.]],
	answers = {
		{"내가 바라는 것은 네 행복 뿐이야. 기뻐하는 것을 보니 나도 기쁘군 그래.", jump="reward"},
	}
}

newChat{ id="reward",
	text = [[#LIGHT_GREEN#*매력적인 자태를 보이며, 그녀가 가까이 다가옵니다*#WHITE#
우리 자기, 우리가 마지막으로 했던 곳이 어디였더라?]],
	answers = {
		{"기억이 나지 않는군 그래. 다시 떠올릴 수 있게 도와주겠어? #LIGHT_GREEN#[그녀에게 장난스러운 미소를 보입니다]", action=function(npc, player)
			player:setQuestStatus("love-melinda", engine.Quest.COMPLETED, "portal-done")
			world:gainAchievement("MELINDA_LUCKY", player)
		end},
	}
}

return "welcome"
