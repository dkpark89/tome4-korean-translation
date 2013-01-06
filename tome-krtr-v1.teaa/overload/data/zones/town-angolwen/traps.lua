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

load("/data/general/traps/store.lua")

newEntity{ base = "BASE_STORE", define_as = "JEWELRY",
	name="Shining Jewel",
	kr_display_name = "빛나는 장신구",
	display='2', color=colors.BLUE,
	resolvers.store("ANGOLWEN_JEWELRY", "angolwen", "store/shop_door.png", "store/shop_sign_rings.png"),
	resolvers.chatfeature("jewelry-store", "angolwen"),
}

newEntity{ base = "BASE_STORE", define_as = "ALCHEMIST",
	name="Alchemist",
	kr_display_name = "연금술사",
	display='4', color=colors.GREEN,
	resolvers.store("POTION", "angolwen", "store/shop_door.png", "store/shop_sign_alchemist.png"),
}

newEntity{ base = "BASE_STORE", define_as = "LIBRARY",
	name="Library",
	kr_display_name = "도서관",
	display='5', color=colors.RED,
	resolvers.store("ANGOLWEN_SCROLL", "angolwen", "store/shop_door.png", "store/shop_sign_library.png"),
}

newEntity{ base = "BASE_STORE", define_as = "STAVES",
	name="Tools of the Art",
	kr_display_name = "작품을 위한 도구점",
	display='6', color=colors.UMBER,
	resolvers.store("ANGOLWEN_STAFF_WAND", "angolwen", "store/shop_door.png", "store/shop_sign_staves_wands.png"),
}
