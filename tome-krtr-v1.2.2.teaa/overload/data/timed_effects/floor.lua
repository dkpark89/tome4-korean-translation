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

local Stats = require "engine.interface.ActorStats"
local Particles = require "engine.Particles"
local Entity = require "engine.Entity"
local Chat = require "engine.Chat"
local Map = require "engine.Map"
local Level = require "engine.Level"

local function floorEffect(t)
	t.name = t.name or t.desc
	t.name = t.name:upper():gsub("[ ']", "_")
	t.kr_name = t.kr_name or t.name or t.desc
	t.kr_name = t.kr_name:upper():gsub("[ ']", "_")
	local d = t.long_desc
	if type(t.long_desc) == "string" then t.long_desc = function() return d end end
	t.type = "other"
	t.subtype = { floor=true }
	t.status = "neutral"
	t.parameters = {}
	t.on_gain = function(self, err) return nil, "+"..(t.kr_name or t.desc) end
	t.on_lose = function(self, err) return nil, "-"..(t.kr_name or t.desc) end

	newEffect(t)
end

floorEffect{
	desc = "Icy Floor", image = "talents/ice_storm.png",
	kr_name = "얼어붙은 바닥",
	long_desc = "얼어붙은 바닥 효과 : 이동 속도 +20% / 냉기 저항 관통 +20% / 기절 면역력 -30%",
	activate = function(self, eff)
		self:effectTemporaryValue(eff, "resists_pen", {[DamageType.COLD] = 20})
		self:effectTemporaryValue(eff, "movement_speed", 0.2)
		self:effectTemporaryValue(eff, "stun_immune", -0.3)
	end,
}

floorEffect{
	desc = "Font of Life", image = "talents/grand_arrival.png",
	kr_name = "생명의 샘",
	long_desc = function(self, eff) return ("생명의 샘 효과 : 생명력 재생 +%0.2f / 평정 회복 -%0.2f / 체력 재생 +%0.2f / 염력 재생 +%0.2f \n(단, 언데드는 아무런 영향도 받지 않음)"):format(eff.power, eff.power, eff.power, eff.power) end,
	activate = function(self, eff)
		if self:attr("undead") then eff.power = 0 return end
		eff.power = 3 + game.zone:level_adjust_level(game.level, game.zone, "object") / 2
		self:effectTemporaryValue(eff, "life_regen", eff.power)
		self:effectTemporaryValue(eff, "stamina_regen", eff.power)
		self:effectTemporaryValue(eff, "psi_regen", eff.power)
		self:effectTemporaryValue(eff, "equilibrium_regen", -eff.power)
	end,
}

floorEffect{
	desc = "Spellblaze Scar", image = "talents/blood_boil.png",
	kr_name = "마법폭발의 상처",
	long_desc = "마법폭발의 상처 효과 : 주문 치명타율 +25% / 화염 공격 피해량 +10% / 황폐 공격 피해량 +10% / 주문 치명타시 해당 원천력이 추가로 소모됨",
	activate = function(self, eff)
		self:effectTemporaryValue(eff, "combat_spellcrit", 25)
		self:effectTemporaryValue(eff, "inc_damage", {[DamageType.FIRE]=10,[DamageType.BLIGHT]=10})
		self:effectTemporaryValue(eff, "mana_on_crit", -15)
		self:effectTemporaryValue(eff, "vim_on_crit", -10)
		self:effectTemporaryValue(eff, "paradox_on_crit", 20)
		self:effectTemporaryValue(eff, "positive_on_crit", -10)
		self:effectTemporaryValue(eff, "negative_on_crit", -10)
	end,
}

floorEffect{
	desc = "Blighted Soil", image = "talents/blightzone.png",
	kr_name = "황폐한 토양",
	long_desc = "황폐한 토양 효과 : 질병 면역력 -60% / 공격 성공시 40%의 확률로 (턴당 한번씩) 목표가 임의의 질병에 걸림",
	activate = function(self, eff)
		self:effectTemporaryValue(eff, "disease_immune", -0.6)
		self:effectTemporaryValue(eff, "blighted_soil", 40)
	end,
}

floorEffect{
	desc = "Glimmerstone", image = "effects/dazed.png", name = "DAZING_DAMAGE",
	kr_name = "깜박이는 암석",
	long_desc = "깜박이는 암석 효과 : 다음 공격시 상대를 혼절시키려고 시도",
	activate = function(self, eff)
	end,
}

floorEffect{
	desc = "Protective Aura", image = "talents/barrier.png",
	kr_name = "보호의 기운",
	long_desc = function(self, eff) return ("보호의 기운 효과 : 방어도 +%d / 물리내성 +%d"):format(eff.power, eff.power * 3) end,
	activate = function(self, eff)
		eff.power = 3 + game.zone:level_adjust_level(game.level, game.zone, "object") / 5
		self:effectTemporaryValue(eff, "combat_armor", eff.power)
		self:effectTemporaryValue(eff, "combat_physresist", eff.power * 3)
	end,
}

floorEffect{
	desc = "Antimagic Bush", image = "talents/fungal_growth.png",
	kr_name = "반마법 덤불",
	long_desc = function(self, eff) return ("반마법 덤불 효과 : 자연 속성 공격 피해량 +20%% / 자연 속성 저항 관통 +20%% / 주문력 -%d"):format(eff.power) end,
	activate = function(self, eff)
		eff.power = 10 + game.zone:level_adjust_level(game.level, game.zone, "object") / 1.5
		self:effectTemporaryValue(eff, "combat_spellpower", -eff.power)
		self:effectTemporaryValue(eff, "inc_damage", {[DamageType.NATURE]=20})
		self:effectTemporaryValue(eff, "resists_pen", {[DamageType.NATURE]=20})
	end,
}

floorEffect{
	desc = "Necrotic Air", image = "talents/repression.png",
	kr_name = "원혼의 대기",
	long_desc = "원혼의 대기 효과 : 치유 효율 -40% / 언데드인 경우 전체 저항 +15%",
	activate = function(self, eff)
		self:effectTemporaryValue(eff, "healing_factor", -0.4)
		if self:attr("undead") then self:effectTemporaryValue(eff, "resists", {all=15}) end
	end,
}

floorEffect{
	desc = "Whistling Vortex", image = "talents/shadow_blast.png",
	kr_name = "휘몰아치는 소용돌이",
	long_desc = function(self, eff) return ("휘몰아치는 소용돌이 효과 : 장거리 회피 +%d / 장거리 정확도 -%d / 날아오는 발사체 속도 -30%%"):format(eff.power, eff.power) end,
	activate = function(self, eff)
		eff.power = 10 + game.zone:level_adjust_level(game.level, game.zone, "object") / 2
		self:effectTemporaryValue(eff, "combat_def_ranged", eff.power)
		self:effectTemporaryValue(eff, "combat_atk_ranged", -eff.power)
		self:effectTemporaryValue(eff, "slow_projectiles", 30)
	end,
}

floorEffect{
	desc = "Fell Aura", image = "talents/shadow_mages.png",
	kr_name = "격렬한 기운",
	long_desc = "격렬한 기운 효과 : 치명타 피해량 +40% 추가 / 전체 저항 -20%",
	activate = function(self, eff)
		self:effectTemporaryValue(eff, "combat_critical_power", 40)
		self:effectTemporaryValue(eff, "resists", {all=-20})
	end,
}

floorEffect{
	desc = "Slimey Pool", image = "talents/acidic_skin.png",
	kr_name = "슬라임 웅덩이",
	long_desc = "슬라임 웅덩이 효과 : 이동 속도 -20% / 근접 공격시 슬라임 속성 피해량 +20 추가",
	activate = function(self, eff)
		self:effectTemporaryValue(eff, "on_melee_hit", {[DamageType.SLIME] = 20})
		self:effectTemporaryValue(eff, "movement_speed", -0.2)
	end,
}
