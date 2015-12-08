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

newEntity{ base = "BASE_LORE_RANDOM",
	name = "The story of my salvation", lore="zigur-potion", unique=true,
	kr_name = "나의 구원받은 이야기",
	desc = [[마법의 공포에 대한 오래된 이야기.]],
	level_range = {1, 20},
	rarity = 40,
}

newEntity{ base = "BASE_LORE_RANDOM",
	name = "On Adventuring", lore="kestin-highfin-adventuring-notes", unique=true,
	kr_name = "모험가의 길",
	desc = [[전설적인 여행자의 단편.]],
	level_range = {10, 25},
	rarity = 35,
}

newEntity{ base = "BASE_LORE_RANDOM",
	name = "memories of Artelia Firstborn", lore="creation-elf", unique=true,
	kr_name = "아르텔리아 퍼스트본의 기억",
	desc = [[처음 깨달음을 얻은 엘프의 기억.]],
	level_range = {1, 25},
	rarity = 40,
	-- Only elves can find it
	checkFilter = function(e) local p = game.party:findMember{main=true} if p.descriptor.race == "Elf" then return true end return false end,
}

newEntity{ base = "BASE_LORE_RANDOM",
	name = "human myth of creation", lore="creation-human", unique=true,
	kr_name = "인간의 창조 신화",
	desc = [[인간의 창조 신화.]],
	level_range = {1, 25},
	rarity = 40,
	-- Only humans can find it
	checkFilter = function(e) local p = game.party:findMember{main=true} if p.descriptor.race == "Human" then return true end return false end,
}

newEntity{ base = "BASE_LORE_RANDOM",
	name = "a logical analysis of creation, by philosopher Smythen", lore="creation-halfling", unique=true,
	kr_name = "철학자 스미든의 창조에 대한 논리적 분석",
	desc = [[하플링의 창조 신화.]],
	level_range = {1, 25},
	rarity = 40,
	-- Only hhalflings can find it
	checkFilter = function(e) local p = game.party:findMember{main=true} if p.descriptor.race == "Halfling" then return true end return false end,
}

newEntity{ base = "BASE_LORE_RANDOM",
	name = "Tale of the Moonsisters", lore="moons-human", unique=true,
	kr_name = "달의 자매 이야기",
	desc = [[에이알의 달이 생긴 이야기]],
	level_range = {1, 35},
	rarity = 40,
	-- Only humans can find it
	checkFilter = function(e) local p = game.party:findMember{main=true} if p.descriptor.race == "Human" then return true end return false end,
}
