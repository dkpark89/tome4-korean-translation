﻿-- ToME - Tales of Maj'Eyal
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

load("/data/general/grids/basic.lua")
load("/data/general/grids/sand.lua")

newEntity{ define_as = "LAVA_WALL",
	name='lava pit',
	kr_name = "용암 구덩이",
	display='~', color=colors.LIGHT_RED, back_color=colors.RED,
	always_remember = true, does_block_move = true,
	image="terrain/lava_floor.png",
}

newEntity{ define_as = "LAVA_WALL_OPAQUE",
	name='lava pit',
	kr_name = "용암 구덩이",
	display='~', color=colors.LIGHT_RED, back_color=colors.RED,
	always_remember = true, does_block_move = true,
	block_sight = true,
	block_sense = true,
	block_esp = true,
	image="terrain/lava_floor.png",
}

newEntity{
	define_as = "CONTROL_ORB",
	name = "Slave Control Orb", image = "terrain/marble_floor.png", add_displays = {class.new{image="terrain/control_orb_red.png"}},
	kr_name = "노예 제어용 오브",
	display = '*', color=colors.PURPLE,
	notice = true,
	always_remember = true,
	faction = "slavers",
	block_move = function(self, x, y, e, act, couldpass)
		if e and e.player and act and e:reactionToward(self) >= 0 then
			local chat = require("engine.Chat").new("ring-of-blood-orb", self, e)
			chat:invoke()
		end
		return true
	end,
}
