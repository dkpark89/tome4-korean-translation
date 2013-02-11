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

newEntity{ base = "BASE_STORE", define_as = "HEAVY_ARMOR_STORE",
	name="Hormond & Son Plates",
	kr_display_name = "호르몬드와 손의 철갑",
	display='2', color=colors.UMBER,
	resolvers.store("HEAVY_ARMOR", "allied-kingdoms", "store/shop_door.png", "store/shop_sign_hormond_sons.png"),
}

newEntity{ base = "BASE_STORE", define_as = "LIGHT_ARMOR_STORE",
	name="Rila's Leather",
	kr_display_name = "릴라의 가죽갑옷",
	display='2', color=colors.UMBER,
	resolvers.store("LIGHT_ARMOR", "allied-kingdoms", "store/shop_door.png", "store/shop_sign_rilas_leather.png"),
}

newEntity{ base = "BASE_STORE", define_as = "CLOTH_ARMOR_STORE",
	name="Toxar Alchemical Tailor",
	kr_display_name = "연금술 재단사 톡사르",
	display='2', color=colors.UMBER,
	resolvers.store("CLOTH_ARMOR", "allied-kingdoms", "store/shop_door.png", "store/shop_sign_toxar_alchemical_tailor.png"),
}

newEntity{ base = "BASE_STORE", define_as = "SWORD_WEAPON_STORE",
	name="Herk's Cutting Edge",
	kr_display_name = "헤르크의 절단의 칼날",
	display='3', color=colors.UMBER,
	resolvers.store("SWORD_WEAPON", "allied-kingdoms", "store/shop_door.png", "store/shop_sign_herks_cutting_edge.png"),
	resolvers.chatfeature("last-hope-weapon-store", "allied-kingdoms"),
}

newEntity{ base = "BASE_STORE", define_as = "KNIFE_WEAPON_STORE",
	name="Yulek's Tools of the Night",
	kr_display_name = "이울렉의 밤을 위한 도구",
	display='3', color=colors.UMBER,
	resolvers.store("KNIFE_WEAPON", "allied-kingdoms", "store/shop_door.png", "store/shop_sign_yuleks_tools_of_night.png"),
	resolvers.chatfeature("last-hope-weapon-store", "allied-kingdoms"),
}

newEntity{ base = "BASE_STORE", define_as = "AXE_WEAPON_STORE",
	name="Vortal's Trees Choppers",
	kr_display_name = "보르탈의 나무 절단기",
	display='3', color=colors.UMBER,
	resolvers.store("AXE_WEAPON", "allied-kingdoms", "store/shop_door.png", "store/shop_sign_vortals_trees.png"),
	resolvers.chatfeature("last-hope-weapon-store", "allied-kingdoms"),
}

newEntity{ base = "BASE_STORE", define_as = "MAUL_WEAPON_STORE",
	name="Raber's Blunt Paradise",
	kr_display_name = "라버의 둔기의 낙원",
	display='3', color=colors.UMBER,
	resolvers.store("MAUL_WEAPON", "allied-kingdoms", "store/shop_door.png", "store/shop_sign_rabers_blunt_paradise.png"),
	resolvers.chatfeature("last-hope-weapon-store", "allied-kingdoms"),
}

newEntity{ base = "BASE_STORE", define_as = "ARCHER_WEAPON_STORE",
	name="Dala's Far Reaching Implements",
	kr_display_name = "달라의 장거리 무구",
	display='3', color=colors.UMBER,
	resolvers.store("ARCHER_WEAPON", "allied-kingdoms", "store/shop_door.png", "store/shop_sign_dalas_far_reaching.png"),
	resolvers.chatfeature("last-hope-weapon-store", "allied-kingdoms"),
}

newEntity{ base = "BASE_STORE", define_as = "HERBALIST",
	name="Sarah's Herbal Infusions",
	kr_display_name = "사라의 약초 주입물",
	display='4', color=colors.LIGHT_GREEN,
	resolvers.store("POTION", "allied-kingdoms", "store/shop_door.png", "store/shop_sign_saras_herbal_infusions.png"),
}

newEntity{ base = "BASE_STORE", define_as = "RUNES",
	name="Sook's Runes and other Harmless Contraptions",
	kr_display_name = "숙의 룬과 기타 무해한 장치",
	display='5', color=colors.LIGHT_RED,
	resolvers.store("SCROLL", "allied-kingdoms", "store/shop_door.png", "store/shop_sign_runemaster.png"),
}

newEntity{ base = "BASE_STORE", define_as = "LIBRARY",
	name="Library",
	kr_display_name = "도서관",
	display='5', color=colors.LIGHT_RED,
	resolvers.store("LAST_HOPE_LIBRARY", "allied-kingdoms", "store/shop_door.png", "store/shop_sign_library.png"),
}

newEntity{ base = "BASE_STORE", define_as = "ELDER",
	name="The Elder",
	kr_display_name = "장로",
	display='*', color=colors.UMBER, image = "store/shop_door2.png",
	resolvers.chatfeature("last-hope-elder", "allied-kingdoms"),
}

newEntity{ base = "BASE_STORE", define_as = "TANNEN",
	name="Tannen's Door",
	kr_display_name = "탄넨의 문",
	display='*', color=colors.UMBER, image = "store/shop_door_barred.png",
	resolvers.chatfeature("tannen", "allied-kingdoms"),
}

newEntity{ base = "BASE_STORE", define_as = "ALCHEMIST",
	name="Home of Ungrol the Alchemist",
	kr_display_name = "연금술사 운그롤의 집",
	display='*', color=colors.UMBER, image = "store/shop_door_barred.png",
	resolvers.chatfeature("alchemist-last-hope", "allied-kingdoms"),
}

newEntity{ base = "BASE_STORE", define_as = "MELINDA_FATHER",
	name="Rich merchant",
	kr_display_name = "부자 상인",
	display='*', color=colors.UMBER, image = "store/shop_door_barred.png",
	resolvers.chatfeature("last-hope-melinda-father", "allied-kingdoms"),
}

newEntity{ base = "BASE_STORE", define_as = "RARE_GOODS",
	name="Urthol's Wondrous Emporium",
	kr_display_name = "우르솔의 놀라운 잡화점",
	display='7', color=colors.BLUE,
	resolvers.store("LOST_MERCHANT", "allied-kingdoms", "store/shop_door.png", "store/shop_sign_urthols_emporium.png"),
	resolvers.chatfeature("last-hope-lost-merchant", "allied-kingdoms"),
}
