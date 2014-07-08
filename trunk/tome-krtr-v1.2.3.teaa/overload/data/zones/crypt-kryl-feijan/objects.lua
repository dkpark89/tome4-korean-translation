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
local Talents = require "engine.interface.ActorTalents"

newEntity{ base = "BASE_MINDSTAR",
	power_source = {psionic = true },
	unique = true,
	name = "Writhing Essence of Nightmares",
	kr_name = "고통스러운 악몽의 정수", kr_unided_name = "몸부림치는 마석",
	desc = [[이 검은 촉수 덩어리에서는 속삭이는 소리가 끊임없이 나오고 있습니다. 이 속삭임을 듣게 된 불행한 자에게는, 말로 설명하지 못할 공포가 귀를 통해 엄습하게 됩니다.]],
	unided_name = "writhing mindstar",
	level_range = {20, 32},
	colors = colors.PURPLE , image = "object/artifact/writhing_essence_of_nightmares.png",
	rarity = 30,
	cost = 120,
	require= {stat = { wil=30 }, },
	material_level = 3,
	combat = {
		dam = 15,
		apr = 20,
		physcrit = 2,
		dammod = { wil=0.5, cun=0.3 },
		damtype=DamageType.DARKNESS,
	},
	wielder = {
		combat_mindpower = 15,
		combat_mindcrit =  3,
		inc_damage= {
			[DamageType.MIND] = 10,
			[DamageType.DARKNESS] = 10,
		},
		talents_types_mastery = {
			["cursed/fears"] = 0.2,
			["psionic/nightmare"] = 0.2,
		},
		inc_stats = { [Stats.STAT_WIL] = 4, [Stats.STAT_CUN] = 2, },
	},
	max_power = 40, power_regen=1,
	use_talent = { id = Talents.T_WAKING_NIGHTMARE , level = 2, power = 40},
}
