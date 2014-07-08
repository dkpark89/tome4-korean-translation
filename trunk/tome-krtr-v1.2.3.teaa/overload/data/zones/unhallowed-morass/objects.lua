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

load("/data/general/objects/objects-maj-eyal.lua")

local Talents = require "engine.interface.ActorTalents"

newEntity{ base = "BASE_LITE", define_as = "VOID_STAR",
	power_source = {arcane=true},
	unique = true,
	name = "Void Star", image="object/artifact/void_star.png",
	unided_name = "tiny black star",
	level_range = {1, 10},
	color = colors.GREY,
	encumber = 1,
	rarity = false,
	kr_name = "공허의 별", kr_unided_name = "작고 검은 별",
	desc = [[아주 작고 칠흑같이 검은, 별처럼 생긴 물건입니다. 그 원리는 모르겠지만, 아직도 빛나고 있습니다.]],
	cost = 120,
	material_level = 2,

	wielder = {
		combat_spellcrit = 5,
		inc_damage = {
			[DamageType.ARCANE]    = 6,
			[DamageType.FIRE]      = 6,
			[DamageType.COLD]      = 6,
			[DamageType.ACID]      = 6,
			[DamageType.LIGHTNING] = 6,
		},
		lite = 2,
	},

	max_power = 70, power_regen = 1,
	use_talent = { id = Talents.T_ECHOES_FROM_THE_VOID, level = 2, power = 70 },
}
