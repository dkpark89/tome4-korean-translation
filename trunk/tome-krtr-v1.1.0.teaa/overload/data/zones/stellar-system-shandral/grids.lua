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

load("/data/general/grids/void.lua")

newEntity{ base = "VOID",
	define_as = "BLOCK",
	block_move = true,
	block_fortress = true,
}

class = require "mod.class.StellarBody"
newEntity{ base = "VOID",
	define_as = "CELESTIAL_BODY",
	image="invis.png",
	notice = true,
	block_move = true,
	always_remember = true,
	show_tooltip = true,
}

--------------------------------------------------------------------
-- STARS
--------------------------------------------------------------------
newEntity{ base = "CELESTIAL_BODY",
	define_as = "SHANDRAL",
	name = "Shandral (Sun)",
	kr_name = "샨드랄 (태양)",
	display = '*', color=colors.GOLD,
	desc = [[샨드랄 항성계의 태양입니다.]],
	sphere_map = "stars/sun_surface.png",
	sphere_size = 8,
	x_rot = 20, y_rot = -20, rot_speed = 17000,
}

--------------------------------------------------------------------
-- Planet
--------------------------------------------------------------------
newEntity{ base = "CELESTIAL_BODY",
	define_as = "EYAL",
	name = "Eyal (Planet)",
	kr_name = "에이알 (행성)",
	display = 'O', color=colors.BLUE,
	desc = [[샨드랄 항성계의 주요 행성 중 하나입니다.]],
	sphere_map = "stars/eyal.png",
	sphere_size = 1,
	x_rot = 30, y_rot = -30, rot_speed = 9000,
}

newEntity{ base = "CELESTIAL_BODY",
	define_as = "SUMMERTIDE",
	name = "Summertide (Moon of Eyal)",
	kr_name = "밀려오는 여름 (에이알의 달)",
	display = 'o', color=colors.GREY,
	desc = [[에이알의 달입니다. '알티아' 라고도 불립니다.]],
	sphere_map = "stars/moon1.png",
	sphere_size = 0.32,
	x_rot = 50, y_rot = -80, rot_speed = 5600,
}

newEntity{ base = "CELESTIAL_BODY",
	define_as = "WINTERTIDE",
	name = "Wintertide (Moon of Eyal)",
	kr_name = "밀려오는 겨울 (에이알의 달)",
	display = 'o', color=colors.GREY,
	desc = [[에이알의 달입니다. '펠리아' 라고도 불립니다.]],
	sphere_map = "stars/moon1.png",
	sphere_size = 0.32,
	x_rot = -50, y_rot = 20, rot_speed = 5600,
}

--------------------------------------------------------------------
-- Planet
--------------------------------------------------------------------
newEntity{ base = "CELESTIAL_BODY",
	define_as = "KOLAL",
	name = "Kolal (Planet)",
	kr_name = "코랄 (행성)",
	display = 'O', color=colors.BROWN,
	desc = [[샨드랄 항성계의 주요 행성 중 하나입니다.]],
	sphere_map = "stars/kolal.png",
	sphere_size = 0.8,
	x_rot = 10, y_rot = -50, rot_speed = 4000,
}

--------------------------------------------------------------------
-- Planet
--------------------------------------------------------------------
newEntity{ base = "CELESTIAL_BODY",
	define_as = "LUXAM",
	name = "Luxam (Planet)",
	kr_name = "룩삼 (행성)",
	display = 'O', color=colors.BROWN,
	desc = [[샨드랄 항성계의 주요 행성 중 하나입니다.]],
	sphere_map = "stars/luxam.png",
	sphere_size = 1.3,
	x_rot = 0, y_rot = -20, rot_speed = 1000,
}

--------------------------------------------------------------------
-- Planet
--------------------------------------------------------------------
newEntity{ base = "CELESTIAL_BODY",
	define_as = "PONX",
	name = "Ponx (Gaz Planet)",
	kr_name = "폰스 (행성)",
	display = 'O', color=colors.LIGHT_BLUE,
	desc = [[샨드랄 항성계의 주요 행성 중 하나입니다.]],
	sphere_map = "stars/ponx.png",
	sphere_size = 2,
	x_rot = 20, y_rot = -40, rot_speed = 3000,
}
