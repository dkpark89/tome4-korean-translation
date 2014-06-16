-- ToME - Tales of Middle-Earth
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

-- This file describes artifacts associated with unique enemies that can appear anywhere their base enemy can.

newEntity{ define_as = "RUNGOF_FANG",
	power_source = {nature=true},
	unique = true,
	type = "misc", subtype="fang",
	unided_name = "bloodied fang",
	name = "Rungof's Fang", image = "object/artifact/rungof_fang.png",
	kr_name = "룬고프의 송곳니",
	unided_name = "피투성이 송곳니",
	level_range = {20, 35},
	rarity = false,
	display = "*", color=colors.DARK_RED,
	encumber = 1,
	not_in_stores = true,
	desc = [[위대한 와르그, 룬고프의 송곳니입니다. 핏빛 송곳니로 보일 만큼 많은 피가 묻어있습니다.]],

	carrier = {
		combat_apr = 7,
		esp = {['animal/canine']=1},
	},
}

newEntity{ base = "BASE_BATTLEAXE",
	power_source = {arcane=true},
	define_as = "KHULMANAR_WRATH",
	name = "Khulmanar's Wrath", color = colors.DARK_RED, image = "object/artifact/hellfire.png",
	unided_name = "firey blackened battleaxe", unique = true,
	kr_name = "크훌마나르의 분노", kr_unided_name = "불타는 검은 대형도끼",
	desc = [[그을음으로 검은 빛을 띄고 있는 가시 덮힌 대형도끼로, 공포의 영역에서 타오르는 불꽃이 맹렬하게 타오르고 있습니다. 울흐'록이 그의 장군에게 수여한 이 강력한 무기는, 가장 끈질긴 적이라 할지라도 불태워버릴 수 있습니다.]],
	level_range = {37, 50},
	rarity = 300,
	require = { stat = { str=52 }, },
	cost = 600,
	material_level = 5,
	combat = {
		dam = 70,
		apr = 8,
		physcrit = 8,
		dammod = {str=1.2},
		convert_damage = {[DamageType.FIRE] = 20},
		melee_project={[DamageType.FIRE] = 50,}
	},
	wielder = {
		demon=1,
		inc_damage={
			[DamageType.FIRE] = 20,
		},
		resists={
			[DamageType.FIRE] = 20,
		},
		resists_pen={
			[DamageType.FIRE] = 25,
		},
	},
	max_power = 35, power_regen = 1,
	use_talent = { id = Talents.T_INFERNAL_BREATH, level = 3, power = 35 },
}

newEntity{ base = "BASE_TOOL_MISC", image="object/temporal_instability.png",
	power_source = {arcane=true, psionic=true},
	define_as = "BLADE_RIFT",
	unique = true,
	name = "The Bladed Rift", color = colors.BLUE, image = "object/artifact/bladed_rift.png",
	unided_name = "hole in space",
	kr_name = "칼날 균열", kr_unided_name = "공간에 뚫린 구멍",
	desc = [[패배한 악'기실은 작은 균열이 되어 붕괴하였습니다. 어떻게 이것이 안정화되었는지는 모르겠지만, 이 균열에 정신을 집중하면 그 안에 있는 칼날들을 밖으로 불러낼 수 있을 것 같습니다.]],
	level_range = {30, 50},
	rarity = 500,
	cost = 500,
	material_level = 5,
	metallic = false,
	use_no_energy = true,
	special_desc = function(self) return "이 아이템을 사용하는 데에는 턴이 소모되지 않습니다." end,
	wielder = {
		combat_spellpower=10,
		combat_mindpower=10,
		on_melee_hit = {[DamageType.PHYSICALBLEED]=25},
		melee_project = {[DamageType.PHYSICALBLEED]=25},
		resists={
			[DamageType.TEMPORAL] 	= 15,
		},
		inc_damage={
			[DamageType.TEMPORAL] 	= 10,
			[DamageType.PHYSICAL] 	= 5,
		},
	},
	-- Trinket slots are allowed to have extremely good actives because of their opportunity cost
	max_power = 25, power_regen = 1,
	use_talent = { id = Talents.T_ANIMATE_BLADE, level = 1, power = 15 },
}

newEntity{ base = "BASE_LONGSWORD", define_as = "RIFT_SWORD",
	power_source = {arcane=true},
	unique = true,
	name = "Blade of Distorted Time", image = "object/artifact/blade_of_distorted_time.png",
	unided_name = "time-warped sword",
	kr_name = "왜곡된 시간의 칼날", kr_unided_name = "시간 왜곡의 장검",
	desc = [[상처입은 시간 흐름의 남은 부분입니다. 가끔 모양이 변하거나, 그 형태가 옅어지기도 합니다.]],
	level_range = {30, 50},
	rarity = 220,
	require = { stat = { str=44 }, },
	cost = 300,
	material_level = 4,
	combat = {
		dam = 40,
		apr = 10,
		physcrit = 8,
		dammod = {str=0.9,mag=0.2},
		convert_damage={[DamageType.TEMPORAL] = 20},
		special_on_hit = {desc="대상에게 추가적인 시간 속성 피해를 주고 속도 저하", fct=function(combat, who, target)
			local dam = (20 + who:getMag()/2)
			local slow = (10 + who:getMag()/5)/100
			who:project({type="hit", range=1}, target.x, target.y, engine.DamageType.CHRONOSLOW, {dam=dam, slow=slow})
		end},
	},
	wielder = {
		inc_damage={
			[DamageType.TEMPORAL] = 12,
			[DamageType.PHYSICAL] = 10,
		},
	},
	max_power = 8, power_regen = 1,
	use_talent = { id = Talents.T_RETHREAD, level = 2, power = 8 },
}

newEntity{ base = "BASE_RUNE", define_as = "RUNE_REFLECT",
	name = "Rune of Reflection", unique=true, image = "object/artifact/rune_of_reflection.png",
	desc = [[은빛 룬의 표면으로, 자신의 반사된 모습이 비쳐보입니다.]],
	kr_name = "반사의 룬", kr_unided_name = "빛나는 룬",
	unided_name = "shiny rune",
	level_range = {5, 15},
	rarity = 240,
	cost = 100,
	material_level = 3,

	inscription_kind = "protect",
	inscription_data = {
		cooldown = 15,
	},
	inscription_talent = "RUNE:_REFLECTION_SHIELD",
}

newEntity{ base = "BASE_BATTLEAXE",
	power_source = {nature=true, antimagic=true},
	define_as = "GAPING_MAW",
	name = "The Gaping Maw", color = colors.SLATE, image = "object/artifact/battleaxe_the_gaping_maw.png",
	unided_name = "huge granite battleaxe", unique = true,
	kr_name = "벌어진 입", kr_unided_name = "커다란 화강암 대형도끼",
	desc = [[이 커다란 화강암 대형도끼는 도끼의 생김새를 하고 있지만, 그냥 둔기라고 보는게 더 좋을 것 같습니다. 검게 변색된 나무 손잡이에 용가죽을 꽁꽁 동여매 만든 자루, 그리고 찐득한 녹색 액체가 발린 날카로운 화강암 도끼날이 번쩍입니다.]],
	level_range = {38, 50},
	rarity = 300,
	require = { stat = { str=60 }, },
	metallic = false,
	cost = 650,
	material_level = 5,
	combat = {
		dam = 72,
		apr = 4,
		physcrit = 8,
		dammod = {str=1.2},
		melee_project={[DamageType.SLIME] = 50, [DamageType.ACID] = 50},
		special_on_crit = {desc="deal manaburn damage equal to your mindpower in a radius 3 cone", on_kill=1, fct=function(combat, who, target) --@@ 한글화 필요
			who.turn_procs.gaping_maw = (who.turn_procs.gaping_maw or 0) + 1
			local tg = {type="cone", range=10, radius=3, force_target=target, selffire=false}
			local grids = who:project(tg, target.x, target.y, engine.DamageType.MANABURN, who:combatMindpower() / (who.turn_procs.gaping_maw))
			game.level.map:particleEmitter(target.x, target.y, tg.radius, "directional_shout", {life=8, size=3, tx=target.x-who.x, ty=target.y-who.y, distorion_factor=0.1, radius=3, nb_circles=8, rm=0.8, rM=1, gm=0.4, gM=0.6, bm=0.1, bM=0.2, am=1, aM=1})
			who.turn_procs.gaping_maw = (who.turn_procs.gaping_maw or 0) + 1
		end},
	},
	wielder = {
		talent_cd_reduction= {
			[Talents.T_SWALLOW] = 2,
			[Talents.T_MANA_CLASH] = 2,
			[Talents.T_ICE_CLAW] = 1,
		},
	},
	on_wear = function(self, who)
		if who:attr("forbid_arcane") then
			local Stats = require "engine.interface.ActorStats"
			local DamageType = require "engine.DamageType"

			self:specialWearAdd({"wielder","inc_damage"}, {[DamageType.NATURE]=15})
			self:specialWearAdd({"wielder","inc_stats"}, { [Stats.STAT_STR] = 6, [Stats.STAT_WIL] = 6, })
			game.logPlayer(who, "#DARK_GREEN#당신은 구체화된 자연의 분노를 느낍니다!")
		end
	end,
}