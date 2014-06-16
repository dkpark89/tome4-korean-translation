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

-- Check for unidentified stuff
local function can_auto_id(npc, player)
	for inven_id, inven in pairs(player.inven) do
		for item, o in ipairs(inven) do
			if not o:isIdentified() then return true end
		end
	end
end

local function auto_id(npc, player)
	local list = {}
	local do_quest = false
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
		text = [[뭘 가져왔나 한 번 살펴 볼까...
]]..table.concat(list, "\n")..[[

@playername@씨, 이건 정말 멋진데!]],
		answers = {
			{"고마워, 엘리사!", jump=do_quest and "quest" or nil},
		}
	}

	-- Switch to that chat
	return "id_list"
end

newChat{ id="welcome",
	text = [[안녕 친구, 내가 도와줄 일이 있어?]],
	answers = {
		{"이 물건들 좀 살펴봐주지 않을래? [감정되지 않은 아이템을 그녀에게 보여준다]", cond=can_auto_id, action=auto_id},
		{"아무것도 아냐, 안녕."},
	}
}

newChat{ id="quest",
	text = [[잠깐만, @playername@, 너 보아하니 모험가 같은데, 아마도 우리가 서로 도울 수 있을거야.
너도 봐서 알겠지만, 나는 새로운 지식들이랑 고대의 위력적인 아티팩트들에 대해서 배우는걸 #{bold}#너어어어무 좋아하거든.#{normal}# 그렇지만 내가 모험가가 아닌 이상 밖에 나가면 확실하게 죽을거란 말야.
그러니까 이 오브를 받아 (#LIGHT_GREEN#*그녀가 점술사의 오브를 건네줍니다*#WHITE#) 이제 너는 세계 어디에서라도 나랑 얘기할 수 있어! 이렇게하면 새롭게 발견한 물건들을 나한테 보여줄 수 있을거야!
나는 흥미로운 물건들을 많이 보고 싶고 너는 가지고 있는 물건이 어떤 물건인지 알아야하잖아? 상부상조지! 안그래 자기?
아 맞다, 오브를 가지고 다니기만 하면 일반적인 물건들은 그냥 감정할 수 있어.]],
	answers = {
		{"우와, 고마워 엘리사. 진짜 끝내주는걸!", action=function(npc, player)
			player:setQuestStatus("first-artifact", engine.Quest.COMPLETED)

			local orb = game.zone:makeEntityByName(game.level, "object", "ORB_SCRYING")
			if orb then player:addObject(player:getInven("INVEN"), orb) orb:added() orb:identify(true) end
		end},
	}
}

return "welcome"
