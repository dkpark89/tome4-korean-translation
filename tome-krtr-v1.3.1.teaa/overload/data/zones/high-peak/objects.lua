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

load("/data/general/objects/objects-far-east.lua")
load("/data/general/objects/lore/sunwall.lua")

local Stats = require "engine.interface.ActorStats"
local Talents = require "engine.interface.ActorTalents"

-- The staff of absorption, the reason the game exists!
newEntity{ define_as = "STAFF_ABSORPTION_AWAKENED", base="BASE_STAFF",
	power_source = {unknown=true},
	unique = true, godslayer=true, flavor_name = "magestaff",
	name = "Awakened Staff of Absorption", identified=true, force_lore_artifact=true,
	kr_name = "각성한 흡수의 지팡이",
	display = "\\", color=colors.VIOLET, image = "object/artifact/staff_absorption.png",
	encumber = 7,
	plot=true,
	desc = [[힘을 내장한 룬이 새겨진 이 지팡이는, 아주 오래전에 만들어진 것으로 보입니다. 하지만 아직도 변색된 흔적은 보이지 않습니다.
주변에 희미하게 빛이 나고 있으며, 살짝만 건드려도 그 안에 엄청난 힘이 들어있음을 느낄 수 있습니다.
'주술사' 들이 그 힘을 각성시킨 것으로 보입니다.
#{italic}#"보라 그들이 아마크텔을 불러오자, 그의 왕좌에서 수천의 생명이 죽어갔으며, 신 살해자 셋이 그의 발밑에서 부서졌다. 하지만 팔리온은 죽어가면서 차가운 검 아르킬로 고위신의 무릎을 꿰뚫었고, 신 살해자의 지도자 칼디자르는 그 기회를 잡아 흡수의 지팡이를 내밀어 아마크텔에게 최후의 일격을 가했다. 그렇게 가장 위대한 신이 그 자식들에 의해 쓰러지고, 먼지가 되어 사라졌다."#{normal}#]],

	modes = {"fire", "cold", "lightning", "arcane"},
	require = { stat = { mag=40 }, },
	combat = {
		dam = 60,
		apr = 60,
		atk = 30,
		dammod = {mag=1.3},
		damtype = DamageType.ARCANE,
		is_greater = true,
		of_breaching = true,
	--	of_retribution = true,
	},
	wielder = {
		combat_spellpower = 48,
		combat_spellcrit = 15,
		max_mana = 100,
		max_positive = 50,
		max_negative = 50,
		inc_stats = { [Stats.STAT_MAG] = 10, [Stats.STAT_WIL] = 10 },
		inc_damage={
			[DamageType.FIRE] = 60,
			[DamageType.LIGHTNING] = 60,
			[DamageType.COLD] = 60,
			[DamageType.ARCANE] = 60,
		},
		resists_pen={
			[DamageType.FIRE] = 30,
			[DamageType.LIGHTNING] = 30,
			[DamageType.COLD] = 30,
			[DamageType.ARCANE] = 30,
		},
		--[[elemental_retribution = {
			[DamageType.FIRE] = 1,
			[DamageType.LIGHTNING] = 1,
			[DamageType.COLD] = 1,
			[DamageType.ARCANE] = 1,
		},]]
		learn_talent = { [Talents.T_COMMAND_STAFF] = 1, }, --[Talents.T_ELEMENTAL_RETRIBUTION] = 5,},
		speaks_shertul = 1,
	},

	-- This is not a simple artifact, it is a godslayer, show off!
	resolvers.generic(function(e) e:addParticles(engine.Particles.new("godslayer_swirl", 1, {})) end),
	moddable_tile_particle = {"godslayer_swirl", {size=64, x=-16}},

	max_power = 200, power_regen = 1,
	use_power = {
	name = function(self, who) return ("%d 범위 내에 있는 목표의 정수를 흡수하여, 생명력의 30%%를 흡수하고, 당신의 총 피해량을 30%% 만큼 %d 턴 동안 상승 시킵니다."):format(self.use_power.range, self.use_power.duration) end,
	power = 200,
	range = 8,
	duration =7,
		use = function(self, who)
			local tg = {type="hit", range=self.use_power.range}
			local x, y = who:getTarget(tg)
			if not x or not y then return nil end
			local _ _, x, y = who:canProject(tg, x, y)
			local target = game.level.map(x, y, engine.Map.ACTOR)
			if not target then return nil end
			if target.staff_drained then
				game.logPlayer(who, "이 상대는 이미 흡수 당했습니다.")
			end

			_, x = target:takeHit(target.max_life * 0.3, who, {special_death_msg = "는 ".. self.name.."에 흡수 되어 죽었습니다."})
			game.logPlayer(who, "당신은 지팡이를 휘둘러, 상대의 에너지를 흡수합니다.")
			game:delayedLogDamage(who, target, x, ("#ORCHID# %d 정수 흡수 #LAST#"):format(x), false)
			who:setEffect(who.EFF_POWER_OVERLOAD, self.use_power.duration, {power=30})
			return {id=true, used=true}		end
	},
}

newEntity{ define_as = "PEARL_LIFE_DEATH",
	power_source = {nature=true},
	unique = true,
	type = "gem", subtype="white",
	unided_name = "shining pearl",
	name = "Pearl of Life and Death",
	display = "*", color=colors.WHITE, image = "object/artifact/pearl_of_life.png",
	encumber = 2,
	plot=true,
	kr_name = "삶과 죽음의 진주", kr_unided_name = "빛나는 진주",
	desc = [[보통의 것보다 세 배는 큰 진주입니다. 무한한 색깔로 변하면서 반짝이고 있지만, 결코 변하지 않는 약간의 무늬가 보입니다.]],

	carrier = {
		lite = 1,
		inc_stats = { [Stats.STAT_STR] = 5, [Stats.STAT_DEX] = 5, [Stats.STAT_MAG] = 5, [Stats.STAT_WIL] = 5, [Stats.STAT_CUN] = 5, [Stats.STAT_CON] = 5, [Stats.STAT_LCK] = 10 },
		inc_damage = {all = 7},
		resists = {all = 7},
		stun_immune = 1,
	},
}
