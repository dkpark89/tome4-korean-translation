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

newEntity{ define_as = "EIDOLON",
	type = "unknown", subtype = "unknown",
	name = "The Eidolon",
	kr_name = "에이돌론",
	display = "@", color=colors.GREY,
	resolvers.nice_tile{image="invis.png", add_mos = {{image="npc/unknown_unknown_the_eidolon.png", display_h=2, display_y=-1}}},
	desc = [[공허 속의 파문과 같은 존재로 보이지만... 살아있습니다. 이 생명체는 흥미로운 눈으로 당신을 쳐다보고 있습니다.]], 
	faction = "neutral",
	blood_color = colors.DARK,
	level_range = {200, nil}, exp_worth = 0,
	rank = 5,
	never_move = 1,
	invulnerable = 1,
	never_anger = 1,

	can_talk = "eidolon-plane",
}
