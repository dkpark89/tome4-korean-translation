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

load("/data/general/objects/objects-far-east.lua")
load("/data/general/objects/lore/sunwall.lua")
load("/data/general/objects/lore/orc-prides.lua")

local Stats = require"engine.interface.ActorStats"

-- Artifact, randomly dropped in Vor Pride, and only there
newEntity{ base = "BASE_SCROLL", subtype="tome",
	power_source = {arcane=true},
	name = "Tome of Wildfire", unided_name = "burning book", unique=true, no_unique_lore=true, image = "object/artifact/tome_of_wildfire.png",
	kr_name = "열화의 서적", kr_unided_name = "타오르는 책",
	desc = "타오르는 화염이 이 커다란 책을 감싸고 있습니다. 하지만 만져봐도 별 문제는 없는 것 같습니다.",
	color = colors.VIOLET,
	level_range = {35, 45},
	rarity = 200,
	cost = 100,

	use_simple = { name="learn the ancient secrets", kr_name="고대의 비밀 학습", use = function(self, who)
		if not who:knowTalent(who.T_FLAME) then
			who:learnTalent(who.T_FLAME, true, 3, {no_unlearn=true})
			game.logPlayer(who, "#00FFFF#당신은 이 서적을 읽고, 잊혀진 고대의 화염 마법을 배웠습니다!")
		else
			who.talents_types_mastery["spell/fire"] = (who.talents_types_mastery["spell/fire"] or 1) + 0.1
			who.talents_types_mastery["spell/wildfire"] = (who.talents_types_mastery["spell/wildfire"] or 1) + 0.1
			game.logPlayer(who, "#00FFFF#당신은 이 서적을 읽고, 화염 마법들의 기술 숙련도를 올렸습니다!")
		end

		return {used=true, id=true, destroy=true}
	end}
}

-- Artifact, randomly dropped in Vor Pride, and only there
newEntity{ base = "BASE_SCROLL", subtype="tome",
	power_source = {arcane=true},
	name = "Tome of Uttercold", unided_name = "frozen book", unique=true, no_unique_lore=true, image = "object/artifact/tome_of_uttercold.png",
	kr_name = "절대영도의 서적", kr_unided_name = "얼어붙은 책",
	desc = "서서히 변화하는 얼음이 이 커다란 책을 감싸고 있습니다. 하지만 만져봐도 별 문제는 없는 것 같습니다.",
	color = colors.VIOLET,
	level_range = {35, 45},
	rarity = 200,
	cost = 100,

	use_simple = { name="learn the ancient secrets", kr_name="고대의 비밀 학습", use = function(self, who)
		if not who:knowTalent(who.T_ICE_STORM) then
			who:learnTalent(who.T_ICE_STORM, true, 3, {no_unlearn=true})
			game.logPlayer(who, "#00FFFF#당신은 이 서적을 읽고, 잊혀진 고대의 얼음 마법을 배웠습니다!")
		else
			who.talents_types_mastery["spell/water"] = (who.talents_types_mastery["spell/water"] or 1) + 0.1
			who.talents_types_mastery["spell/ice"] = (who.talents_types_mastery["spell/ice"] or 1) + 0.1
			game.logPlayer(who, "#00FFFF#당신은 이 서적을 읽고, 냉기 마법들의 기술 숙련도를 올렸습니다!")
		end

		return {used=true, id=true, destroy=true}
	end}
}

newEntity{ base = "BASE_LORE",
	define_as = "NOTE_LORE",
	name = "draft note", lore="vor-pride-note",
	kr_name = "휘갈겨 쓴 쪽지",
	desc = [[쪽지입니다.]],
	rarity = false,
}

for i = 1, 5 do
newEntity{ base = "BASE_LORE",
	define_as = "ORC_HISTORY"..i,
	name = "Records of Lorekeeper Hadak", lore="orc-history-"..i, unique="Records of Lorekeeper Hadak "..i,
	kr_name = "지식 관리인 하닥의 기록",
	desc = [[오크류의 오랜 역사의 일부분입니다.]],
	rarity = false,
}
end
