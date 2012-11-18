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

newBirthDescriptor{
	type = "class",
	name = "Defiler",
	display_name = "모독자 (Defiler)",
	locked = function() return profile.mod.allow_build.corrupter end,
	locked_desc = "사악한 마음, 검은 피, 타락한 행위... 동포의 피로 땅을 적시는 자가 힘을 얻으리라.",
	desc = {
		"모독자는 악의 낙인을 받았습니다. 그들은 세상의 역병이며, 악의 씨앗을 흩뿌려 주인을 섬기거나 스스로 그런 자들의 주인이 되기도 합니다.",
	},
	descriptor_choices =
	{
		subclass =
		{
			__ALL__ = "disallow",
			Reaver = "allow",
			Corruptor = "allow",
		},
	},
	copy = {
		max_life = 120,
	},
}

newBirthDescriptor{
	type = "subclass",
	name = "Reaver",
	display_name = "파괴자 (Reaver)",
	locked = function() return profile.mod.allow_build.corrupter_reaver end,
	locked_desc = "그대에게 대적하는 자들의 영혼을 거두라, 그리하면 그대의 육신에 어둠의 권능이 깃들지니.",
	desc = {
		"파괴자는 각각의 손에 무기를 들고 적에게 달려드는 무시무시한 자들입니다.",
		"사악한 타락의 기운을 휘둘러, 지독한 전투기술로 적의 두개골을 깨부수는 동시에 끔찍한 전염병에 감염시키기도 합니다.",
		"가장 중요한 능력치는 힘과 마법입니다.",
		"#GOLD#능력치 변경:",
		"#LIGHT_BLUE# * 힘+4, 민첩+1, 체력+0",
		"#LIGHT_BLUE# * 마법+4, 의지+0, 교활함+0",
		"#GOLD#레벨 당 생명력:#LIGHT_BLUE# +2",
	},
	power_source = {arcane=true, technique=true},
	stats = { str=4, mag=4, dex=1, },
	talents_types = {
		["technique/combat-training"]={true, 0.3},
		["cunning/survival"]={false, 0.1},
		["corruption/sanguisuge"]={true, 0.3},
		["corruption/reaving-combat"]={true, 0.3},
		["corruption/scourge"]={true, 0.3},
		["corruption/plague"]={true, 0.3},
		["corruption/hexes"]={false, 0.3},
		["corruption/curses"]={false, 0.3},
		["corruption/bone"]={true, 0.3},
		["corruption/torment"]={true, 0.3},
		["corruption/vim"]={true, 0.3},
	},
	talents = {
		[ActorTalents.T_CORRUPTED_STRENGTH] = 1,
		[ActorTalents.T_WEAPON_COMBAT] = 1,
		[ActorTalents.T_DRAIN] = 1,
		[ActorTalents.T_REND] = 1,
	},
	copy = {
		resolvers.equip{ id=true,
			{type="weapon", subtype="waraxe", name="iron waraxe", autoreq=true, ego_chance=-1000},
			{type="weapon", subtype="waraxe", name="iron waraxe", autoreq=true, ego_chance=-1000},
			{type="armor", subtype="light", name="rough leather armour", autoreq=true, ego_chance=-1000}
		},
	},
	copy_add = {
		life_rating = 2,
	},
}

newBirthDescriptor{
	type = "subclass",
	name = "Corruptor",
	display_name = "타락자 (Corruptor)",
	locked = function() return profile.mod.allow_build.corrupter_corruptor end,
	locked_desc = "타락과 사악한 행위에는 강력한 힘이 있나니, 유혹을 받아들여 타락하라.",
	desc = {
		"타락자는 적의 영혼을 쥐어짜내는 어둠의 마법을 쓰는 무시무시한 자들입니다.",
		"사악한 타락의 기운을 휘둘러,영혼을 파괴하고 생명력을 빼앗아 흡수합니다.",
		"강력한 타락자는 악마로 변할 수도 있습니다.",
		"가장 중요한 능력치는 마법과 의지입니다.",
		"#GOLD#능력치 변경:",
		"#LIGHT_BLUE# * 힘+0, 민첩+0, 체격+2",
		"#LIGHT_BLUE# * 마법+4, 의지+3, 교활함+0",
		"#GOLD#레벨 당 생명력:#LIGHT_BLUE# +0",
	},
	power_source = {arcane=true},
	stats = { mag=4, wil=3, con=2, },
	talents_types = {
		["cunning/survival"]={false, 0},
		["corruption/sanguisuge"]={true, 0.3},
		["corruption/hexes"]={true, 0.3},
		["corruption/curses"]={true, 0.3},
		["corruption/bone"]={false, 0.3},
		["corruption/plague"]={true, 0.3},
		["corruption/shadowflame"]={false, 0.3},
		["corruption/blood"]={true, 0.3},
		["corruption/vim"]={true, 0.3},
		["corruption/blight"]={true, 0.3},
		["corruption/torment"]={false, 0.3},
	},
	talents = {
		[ActorTalents.T_DRAIN] = 1,
		[ActorTalents.T_BLOOD_SPRAY] = 1,
		[ActorTalents.T_SOUL_ROT] = 1,
		[ActorTalents.T_PACIFICATION_HEX] = 1,
	},
	copy = {
		resolvers.equip{ id=true,
			{type="weapon", subtype="staff", name="elm staff", autoreq=true, ego_chance=-1000},
			{type="armor", subtype="cloth", name="linen robe", autoreq=true, ego_chance=-1000}
		},
	},
}
