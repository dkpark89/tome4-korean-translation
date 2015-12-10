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

load("/data/general/traps/store.lua")

newEntity{ base = "BASE_STORE", define_as = "HEAVY_ARMOR_STORE",
	name="Armoury",
	kr_name = "방어구점",
	display='2', color=colors.UMBER,
	resolvers.store("HEAVY_ARMOR", "allied-kingdoms", "store/shop_door.png", "store/shop_sign_armory.png"),
}

newEntity{ base = "BASE_STORE", define_as = "LIGHT_ARMOR_STORE",
	name="Tanner",
	kr_name = "무두장이",
	display='2', color=colors.UMBER,
	resolvers.store("LIGHT_ARMOR", "allied-kingdoms", "store/shop_door.png", "store/shop_sign_tanner.png"),
}

newEntity{ base = "BASE_STORE", define_as = "SWORD_WEAPON_STORE",
	name="Swordsmith",
	kr_name = "검의 대장간",
	display='3', color=colors.UMBER,
	resolvers.store("SWORD_WEAPON", "allied-kingdoms", "store/shop_door.png", "store/shop_sign_swordsmith.png"),
}

newEntity{ base = "BASE_STORE", define_as = "KNIFE_WEAPON_STORE",
	name="Knives and daggers",
	kr_name = "비수와 단검",
	display='3', color=colors.UMBER,
	resolvers.store("KNIFE_WEAPON", "allied-kingdoms", "store/shop_door.png", "store/shop_sign_knives.png"),
}

newEntity{ base = "BASE_STORE", define_as = "ARCHER_WEAPON_STORE",
	name="Death from Afar",
	kr_name = "먼 곳으로부터의 죽음",
	display='3', color=colors.UMBER,
	resolvers.store("ARCHER_WEAPON", "allied-kingdoms", "store/shop_door.png", "store/shop_sign_bows.png"),
}

newEntity{ base = "BASE_STORE", define_as = "HERBALIST",
	name="Herbalist",
	kr_name = "약초상",
	display='4', color=colors.LIGHT_BLUE,
	resolvers.store("POTION", "allied-kingdoms", "store/shop_door.png", "store/shop_sign_herbalist.png"),
}

newEntity{ base = "BASE_STORE", define_as = "JEWELRY",
	name="Jewelry",
	kr_name = "장신구점",
	display='9', color=colors.LIGHT_RED,
	resolvers.store("GEMSTORE", "allied-kingdoms", "store/shop_door.png", "store/shop_sign_jewelry.png"),
}

newEntity{ base = "BASE_STORE", define_as = "TOOLSHOP",
	name="Survival Supplies",
	kr_name = "서바이벌 보급품",
	display='8', color=colors.UMBER,
	resolvers.store("LITEDIGSTORE", "allied-kingdoms", "store/shop_door.png", "store/shop_sign_utility_store.png"),
}

newEntity{ base = "BASE_STORE", define_as = "ALCHEMIST",
	name="Home of Stire the Alchemist",
	kr_name = "연금술사 스티르의 집",
	display='*', color=colors.UMBER, image = "store/shop_door_barred.png",
	resolvers.chatfeature("alchemist-derth", "allied-kingdoms"),
}
