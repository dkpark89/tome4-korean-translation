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

local Stats = require "engine.interface.ActorStats"

newEntity{ base = "BASE_STAFF",
	power_source = {arcane=true},
	slot = "OFFHAND", slot_forbid = false,
	twohanded = false, add_name=false,
	define_as = "TELOS_BOTTOM_HALF", rarity=false, image = "object/artifact/staff_broken_bottom_telos.png",
	unided_name = "broken staff",
	name = "Telos's Staff (Bottom Half)", unique=true,
	kr_name = "텔로스 지팡이 (하단)", kr_unided_name = "부서진 지팡이",
	desc = [[부서진 텔로스 지팡이의 하단부입니다.]],
	require = { stat = { mag=35 }, },
	encumberance = 2.5,
	cost = 500,
	wielder = {
		inc_stats = { [Stats.STAT_MAG] = 4, },
		max_mana = 50,
		combat_mentalresist = 8,
		inc_damage={
			[DamageType.COLD] = 20,
			[DamageType.ACID] = 20,
		},
		combat_spellcrit = 8,
		combat_critical_power = 20,
		confusion_immune = 0.2,
	},
}
