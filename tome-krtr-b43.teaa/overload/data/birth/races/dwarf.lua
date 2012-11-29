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

---------------------------------------------------------
--                       Dwarves                       --
---------------------------------------------------------
newBirthDescriptor{
	type = "race",
	name = "Dwarf",
	display_name = "드워프",
	desc = {
		"드워프는 철의 왕좌라는 지하왕국에서 살고 있는 무뚝뚝한 종족입니다.",
		"강인한 육체와 그들이 만든 걸작품으로 명성 높지만, 과거에 있었던 전란에서 다른 종족들과 연합하지 않고 홀로 싸운 일 때문에, 그리 환영받지는 못합니다.",
		"모든 드워프는 그들의 제국과 금전에 대한 사랑으로 똘똘 뭉쳐있습니다.",
	},
	descriptor_choices =
	{
		subrace =
		{
			__ALL__ = "disallow",
			Dwarf = "allow",
		},
	},
	copy = {
		faction = "iron-throne",
		type = "humanoid", subtype="dwarf",
		calendar = "dwarf",
		default_wilderness = {"playerpop", "dwarf"},
		starting_zone = "reknor-escape",
		starting_quest = "start-dwarf",
		starting_intro = "dwarf",
		resolvers.inscription("INFUSION:_REGENERATION", {cooldown=10, dur=5, heal=60}),
		resolvers.inscription("INFUSION:_WILD", {cooldown=12, what={physical=true}, dur=4, power=14}),
		resolvers.inventory{ id=true, {defined="ORB_SCRYING"} },
		resolvers.generic(function(e) e.hotkey[10] = {"inventory", "Orb of Scrying"} end),
	},
	random_escort_possibilities = { {"trollmire", 2, 3}, {"ruins-kor-pul", 1, 2}, {"daikara", 1, 2}, {"old-forest", 1, 4}, {"dreadfell", 1, 8}, {"reknor", 1, 2}, },
}

---------------------------------------------------------
--                       Dwarves                       --
---------------------------------------------------------
newBirthDescriptor
{
	type = "subrace",
	name = "Dwarf",
	display_name = "드워프",
	desc = {
		"드워프는 철의 왕좌라는 지하왕국에서 살고 있는 무뚝뚝한 종족입니다.",
		"강인한 육체와 그들이 만든 걸작품으로 명성 높지만, 과거에 있었던 전란에서 다른 종족들과 연합하지 않고 홀로 싸운 일 때문에, 그리 환영받지는 못합니다.",
		"몇 턴 동안 방어도와 물리,주문 내성을 향상시켜주는 #GOLD#드워프의 활력#WHITE# 을 사용할 수 있습니다.",
		"#GOLD#능력치 변경:",
		"#LIGHT_BLUE# * 힘+4, 민첩-2, 체격+3",
		"#LIGHT_BLUE# * 마법-2, 의지+3, 교활함+0",
		"#GOLD#레벨 당 생명력:#LIGHT_BLUE# 12",
		"#GOLD#경험치 불이익:#LIGHT_BLUE# 25%",
	},
	inc_stats = { str=4, con=3, wil=3, mag=-2, dex=-2 },
	talents_types = { ["race/dwarf"]={true, 0} },
	talents = {
		[ActorTalents.T_DWARF_RESILIENCE]=1,
	},
	copy = {
		moddable_tile = "dwarf_#sex#",
		moddable_tile_ornament = {male="beard_02", female="braid_01"},
		random_name_def = "dwarf_#sex#",
		life_rating=12,
	},
	experience = 1.25,
}
