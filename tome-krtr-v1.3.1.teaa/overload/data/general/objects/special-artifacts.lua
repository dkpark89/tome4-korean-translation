-- ToME - Tales of Maj'Eyal
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

require "engine.krtrUtils"

local Stats = require "engine.interface.ActorStats"
local Talents = require "engine.interface.ActorTalents"

load("/data/general/objects/staves.lua")

-- This file describes artifacts not bound to a special location or quest, but still special(they do not get randomly generated)

newEntity{ base = "BASE_STAFF", define_as = "TELOS_SPIRE",
	power_source = {arcane=true},
	unique = true,
	name = "Telos Spire of Power", image = "object/artifact/telos_spire_of_power.png",
	unided_name = "pulsing staff",
	flavor_name = "magestaff",
	level_range = {37, 50},
	color=colors.VIOLET,
	rarity = false,
	kr_name = "텔로스의 힘의 정수", kr_unided_name = "맥동하는 마법지팡이",
	desc = [[텔로스는 황혼의 시대에 살았던, 아주 강력한 마법사였습니다. 그를 동료들은 미워했고 일반 사람들은 무서워하여, 그는 아주 긴 시간 동안 은둔 생활을 할 수 밖에 없었습니다. 결국 자신의 힘이 모인 장소였던 텔무르에서 그는 사망하였지만, 그의 영혼만은 아직 그 장소에 머무르고 있습니다.]],
	cost = 400,
	material_level = 5,
	plot = true,

	require = { stat = { mag=48 }, },
	modes = {"fire", "cold", "lightning", "arcane"},
	combat = {
		sentient = "telos_full",
		is_greater = true,
		dam = 37,
		apr = 4,
		dammod = {mag=1.5},
		damtype = DamageType.BLIGHT,
	},
	wielder = {
		inc_stats = { [Stats.STAT_CUN] = 8, [Stats.STAT_MAG] = 7 },
		max_mana = 100,
		max_vim = 50,
		combat_spellpower = 30,
		combat_spellcrit = 30,
		combat_mentalresist = 16,
		combat_spellresist = 16,
		combat_critical_power = 30,
		spellsurge_on_crit = 7,
		damage_resonance = 15,
		inc_damage = { [DamageType.ARCANE] = 37, [DamageType.BLIGHT] = 37, [DamageType.COLD] = 37, [DamageType.DARKNESS] = 37, [DamageType.ACID] = 37, [DamageType.LIGHT] = 37, },
		damage_affinity = { [DamageType.ARCANE] = 15, [DamageType.BLIGHT] = 15, [DamageType.COLD] = 15, [DamageType.DARKNESS] = 15, [DamageType.ACID] = 15, [DamageType.LIGHT] = 15, },
		confusion_immune = 0.4,
		vim_on_crit = 6,
	},
	max_power = 15, power_regen = 1,
	use_power = { name = "turn into a corrupted losgoroth (poison, disease, cut and confusion immune; converts half damage into life drain; does not require breath", kr_name = "타락한 로스고로스로 변신 (중독과 질병, 출혈, 혼란에 완전 면역 & 공격시 피해량의 절반만큼 생명력 흡수 & 숨 쉴 필요 없어짐)", power = 15,
		use = function(self, who)
			game.logSeen(who, "%s %s 휘둘러, 타락한 로스고로스로 변신합니다!", (who.kr_name or who.name):capitalize():addJosa("가"), self:getName():addJosa("를"))
			who:setEffect(who.EFF_CORRUPT_LOSGOROTH_FORM, 10, {})
			return {id=true, used=true}
		end
	},
}
