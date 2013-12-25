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

load("/data/general/objects/objects.lua")

newEntity{ base = "BASE_HEAVY_BOOTS", define_as = "PHYSSAVE_BOOTS",
	power_source = {technique=true},
	unique = true,
	name = "Boots of Physical Save (+10)", image = "object/artifact/scorched_boots.png",
	kr_name = "물리 내성의 신발 (+10)", kr_unided_name = "말라붙은 오래된 신발",
	unided_name = "Dried-up old boots.",
	identified = true,
	no_unique_lore = true,
	level_range = {1, nil},
	color = colors.YELLOW,
	encumber = 1,
	rarity = 300,
	desc = [[물리 내성을 10 만큼 올려주는 훌륭한 신발입니다.]],
	cost = 100,
	wielder = {
		combat_physresist = 10,
	},
}

newEntity{ base = "BASE_AMULET", define_as = "MINDPOWER_AMULET",
	power_source = {technique=true},
	unique = true,
	name = "Amulet of Mindpower (+3)", image = "object/artifact/amulet_spellblaze_echoes.png",
	unided_name = "Glittering amulet.",
	kr_name = "정신력의 목걸이 (+3)", kr_unided_name = "화려한 목걸이",
	identified = true,
	no_unique_lore = true,
	level_range = {1, nil},
	color = colors.YELLOW,
	encumber = 1,
	rarity = 300,
	desc = [[정신력을 3 만큼 올려주는 아름다운 목걸이입니다.]],
	cost = 100,
	wielder = {
		combat_mindpower = 3,
	},
}

newEntity{ base = "BASE_HELM", define_as = "ACCURACY_HELM",
	power_source = {technique=true},
	unique = true,
	name = "Helmet of Accuracy (+6)", image = "object/artifact/helm_of_the_dwarven_emperors.png",
	kr_name = "정확도의 투구 (+6)",  kr_unided_name = "단단해 보이는 투구",
	unided_name = "Hard-looking helmet.",
	identified = true,
	no_unique_lore = true,
	level_range = {1, nil},
	color = colors.YELLOW,
	encumber = 1,
	rarity = 300,
	desc = [[정확도를 6 만큼 올려주는, 잘 만들어진 투구입니다.]],
	cost = 100,
	wielder = {
		combat_atk = 6,
	},
}

newEntity{ base = "BASE_RING", define_as = "MENTALSAVE_RING",
	power_source = {technique=true},
	unique = true,
	name = "Ring of Mental Save (+6)", image = "object/artifact/ring_of_war_master.png",
	unided_name = "Smooth ring.",
	kr_name = "정신 내성의 반지 (+6)", kr_unided_name = "매끈한 반지",
	identified = true,
	no_unique_lore = true,
	level_range = {1, nil},
	color = colors.YELLOW,
	encumber = 1,
	rarity = 300,
	desc = [[루비가 박힌 반지입니다.]],
	cost = 100,
	wielder = {
		combat_mentalresist = 6,
	},
}
