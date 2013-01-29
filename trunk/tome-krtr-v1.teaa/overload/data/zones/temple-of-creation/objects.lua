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

load("/data/general/objects/2htridents.lua", function(e) e.rarity = e.trident_rarity end)
load("/data/general/objects/objects-far-east.lua")

local Talents = require "engine.interface.ActorTalents"
local Stats = require "engine.interface.ActorStats"
local DamageType = require "engine.DamageType"

newEntity{ base = "BASE_LITE",
	power_source = {arcane=true},
	define_as = "ELDRITCH_PEARL",
	unided_name = "bright pearl",
	name = "Eldritch Pearl", unique=true, image = "object/artifact/eldritch_pearl.png",
	kr_display_name = "섬뜩한 진주", kr_unided_name = "밝은 진주",
	display ='*', color = colors.AQUAMARINE,
	desc = [[창조의 사원에서 수천년을 보냄으로써, 이 진주에는 돌진하는 물줄기의 격정이 주입되었습니다. 빛이 굽이치며 발산됩니다.]],

	-- No cost, it's invaluable
	wielder = {
		lite = 6,
		can_breath = {water=1},
		combat_dam = 12,
		combat_spellpower = 12,
		inc_stats = {
			[Stats.STAT_STR] = 4,
			[Stats.STAT_DEX] = 4,
			[Stats.STAT_MAG] = 4,
			[Stats.STAT_WIL] = 4,
			[Stats.STAT_CUN] = 4,
			[Stats.STAT_CON] = 4,
			[Stats.STAT_LCK] = -5,
		},
	},

	max_power = 150, power_regen = 1,
	use_talent = { id = Talents.T_TIDAL_WAVE, level=4, power = 80 },
}

for i = 1, 3 do
newEntity{ base = "BASE_LORE",
	define_as = "NOTE"..i,
	name = "tract", lore="temple-creation-note-"..i,
	kr_display_name = "논문",
	desc = [[나가의 역사를 밝히는 논문입니다.]],
	rarity = false,
	encumberance = 0,
}
end

newEntity{ base = "BASE_LORE",
	define_as = "SLASUL_NOTE",
	name = "note", lore="temple-creation-note-4",
	kr_display_name = "쪽지",
	desc = [[쪽지입니다.]],
	rarity = false,
	encumberance = 0,
}

newEntity{ base = "BASE_TRIDENT",
	power_source = {nature=true, psionic=true},
	define_as = "LEGACY_NALOREN",
	unided_name = "ornate orichalcum trident",
	name = "Legacy of the Naloren", unique=true, image = "object/artifact/trident_of_the_tides.png",
	kr_display_name = "날로레의 유산", kr_unided_name = "화려하게 장식된 오리하르콘 삼지창",
	desc = [[이 놀랍도록 아름답고 강력한 삼지창은 희귀한 금속인 오리하르콘으로 만들어졌습니다. 굉장한 진주가 이 삼지창의 끝에 박혀 있고, 세줄기의 뾰족한 날이 뻗어나와 있습니다.
여기에는 대부분의 가장 강력한 나가 전사들의 위대한 힘이 주입되어 있습니다.
슬라술은 이것을 믿음의 증표로 당신에게 주었습니다. 이것은 모든 날로레 종족의 희망의 상징으로, 그들의 부족이 아닌이게게 이것을 주는 것은 매우 큰 신뢰를 나타냅니다.]],
	require = { stat = { str=35 }, },
	level_range = {40, 50},
	rarity = false,
	cost = 350,
	material_level = 5,
	plot = true,
	combat = {
		dam = 84,
		apr = 20,
		physcrit = 20,
		dammod = {str=1.4},
		damrange = 1.4,
		talent_on_hit = { T_STUNNING_BLOW = {level=1, chance=10}, T_SILENCE = {level=3, chance=10}, T_SPIT_POISON = {level=5, chance=10} }
	},

	wielder = {
		lite = 2,
		combat_dam = 12,
		combat_mindpower = 12,
		combat_mindcrit = 12,
		inc_stats = {
			[Stats.STAT_STR] = 4,
			[Stats.STAT_DEX] = 4,
			[Stats.STAT_MAG] = 4,
			[Stats.STAT_WIL] = 4,
			[Stats.STAT_CUN] = 4,
			[Stats.STAT_CON] = 4,
			[Stats.STAT_LCK] = 10,
		},
		resists = {
			[DamageType.COLD] = 15,
			[DamageType.NATURE] = 20,
			[DamageType.ACID] = 10,
		},
		inc_damage = {
			[DamageType.COLD] = 15,
			[DamageType.NATURE] = 25,
			[DamageType.MIND] = 10,
		},
		talent_cd_reduction={
			[Talents.T_RUSH]=3,
			[Talents.T_SPIT_POISON]=2,
		},
		talents_types_mastery = {
			["technique/combat-training"] = 0.3,
			["technique/combat-techniques-active"] = 0.3,
			["psionic/psychic-assault"] = 0.3,
		},
	},

	max_power = 60, power_regen = 1,
	use_talent = { id = Talents.T_IMPLODE, level=2, power = 40 },
}
