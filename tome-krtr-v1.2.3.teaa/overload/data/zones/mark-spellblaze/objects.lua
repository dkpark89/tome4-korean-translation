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

load("/data/general/objects/objects-maj-eyal.lua")

newEntity{ base = "BASE_LORE",
	define_as = "DRAFT_LETTER",
	name = "draft letter", lore="grand-corruptor-draft",
	kr_name = "휘갈겨 쓴 편지",
	desc = [[편지입니다.]],
	rarity = false,
	encumberance = 0,
}

newEntity{
	power_source = {nature=true},
	define_as = "CORRUPTED_SANDQUEEN_HEART",
	type = "corpse", subtype = "heart", image = "object/artifact/corrupted_queen_heart.png",
	name = "Corrupted heart of the Sandworm Queen", unique=true, unided_name="pulsing organ",
	display = "*", color=colors.VIOLET,
	kr_name = "타락한 지렁이 여왕의 심장", kr_unided_name = "맥동하는 장기",
	desc = [[지렁이 여왕의 죽은 몸에서 떼어낸 심장으로, '마법폭발의 흔적'의 제단에서 타락시킨 상태입니다. 당신이 충분히 정신 나간 사람이라면, 한번 먹어볼 수도 있습니다...]],
	cost = 3000,
	quest = 1,

	use_simple = { name="consume the heart", kr_name="심장 먹기", use = function(self, who)
		game.logPlayer(who, "#00FFFF#당신이 심장을 먹자, 타락의 힘이 당신을 채우는 것이 느껴집니다!")
		who.unused_stats = who.unused_stats + 3
		who.unused_talents = who.unused_talents + 1
		who.unused_generics = who.unused_generics + 1
		game.logPlayer(who, "사용할 수 있는 능력치 점수 %d점이 있습니다. 'p' 키를 눌러 사용할 수 있습니다.", who.unused_stats)
		game.logPlayer(who, "사용할 수 있는 직업기술 점수 %d점이 있습니다. 'p' 키를 눌러 사용할 수 있습니다.", who.unused_talents)
		game.logPlayer(who, "사용할 수 있는 일반기술 점수 %d점이 있습니다. 'p' 키를 눌러 사용할 수 있습니다.", who.unused_generics)

		if not who:attr("forbid_arcane") then
			if who:knowTalentType("corruption/vile-life") then
				who:setTalentTypeMastery("corruption/vile-life", who:getTalentTypeMastery("corruption/vile-life") + 0.2)
			elseif who:knowTalentType("corruption/vile-life") == false then
				who:learnTalentType("corruption/vile-life", true)
			else
				who:learnTalentType("corruption/vile-life", false)
			end
			-- Make sure a previous amulet didnt bug it out
			if who:getTalentTypeMastery("corruption/vile-life") == 0 then who:setTalentTypeMastery("corruption/vile-life", 1) end
			game.logPlayer(who, "타락한 여왕의 심장이 당신을 변화시켰습니다!")
			game.logPlayer(who, "#00FF00#당신은 황폐와의 친화력을 얻어,이제 새로운 기술계열 '불결한 생명력' 을 배울 수 있습니다. ('p' 키를 눌러 확인할 수 있습니다)") 

			who:attr("drake_touched", 1)
		end

--		game:setAllowedBuild("wilder_wyrmic", true)

		return {used=true, id=true, destroy=true}
	end}
}
