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

-- Check for unidentified stuff
local function can_auto_id(npc, player)
	for inven_id, inven in pairs(player.inven) do
		for item, o in ipairs(inven) do
			if not o:isIdentified() then return true end
		end
	end
end
local function can_not_auto_id(npc, player)
	return not can_auto_id(npc, player)
end

local function auto_id(header, footer, done)
	return function(npc, player)
		local list = {}
		for inven_id, inven in pairs(player.inven) do
			for item, o in ipairs(inven) do
				if not o:isIdentified() then
					o:identify(true)
					list[#list+1] = o:getName{do_color=true}
				end
			end
		end

		-- Create the chat
		newChat{ id="id_list",
			text = header..table.concat(list, "\n")..footer,
			answers = { {done} }
		}

		-- Switch to that chat
		return "id_list"
	end
end

----------------------------------------------------------------------
-- Yeek version
----------------------------------------------------------------------
if version == "yeek" then

newChat{ id="welcome",
	text = [['한길' 에 정신을 집중하여, 그 지식의 흐름에 몸을 맡겼습니다.]],
	answers = {
		{"[형상과 지식들을 흐름 속에서 찾아봅니다]", cond=can_auto_id,
			action=auto_id("", "", "[당신은 마음으로 '한길' 에 감사를 표시했습니다]")
		},
		{"[아무 지식도 얻지 못했습니다]", cond=can_not_auto_id},
	}
}
return "welcome"

----------------------------------------------------------------------
-- Undead version
----------------------------------------------------------------------
elseif version == "undead" then

newChat{ id="welcome",
	text = [[당신은 가던 길을 멈추고, 과거의 기억을 떠올리기 시작합니다.]],
	answers = {
		{"[형상과 지식들을 머리 속으로 떠올립니다]", cond=can_auto_id,
			action=auto_id("", "", "[생각을 끝낸다]")
		},
		{"[딱히 새로운 기억을 떠올리지 못했습니다]", cond=can_not_auto_id},
	}
}
return "welcome"

----------------------------------------------------------------------
-- Elisa version
----------------------------------------------------------------------
else

newChat{ id="welcome",
	text = [[오, 안녕, @playername@, 새로 보여줄 거라도 있어?]],
	answers = {
		{"그래, 엘리사. 이 물건을 감정해줄 수 있겠어? [그녀에게 오브가 감정해내지 못한 물건을 보여준다]", cond=can_auto_id,
			action=auto_id("어디 보자... \n", "\n\n이네. 아주 멋진 물건을 얻었는걸, @playername@!", "고마워, 엘리사!")
		},
		{"어어, 아니... 미안. 그냥 친구 목소리를 조금 듣고 싶었어.", jump="friend"},
		{"Not yet sorry!"},
	}
}

newChat{ id="friend",
	text = [[#LIGHT_GREEN#*당신은 소리를 죽인 채로 킥킥거리는 웃음소리를 들었습니다.*#WHITE#
오, 너는 정말 #{bold}#너무너무너무너무#{normal}# 귀여워!]],
	answers = {
		{"잘 있어, 엘리사!"},
	}
}
return "welcome"

end
