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

require "engine.krtrUtils"

local Stats = require "engine.interface.ActorStats"
local Particles = require "engine.Particles"
local Entity = require "engine.Entity"
local Chat = require "engine.Chat"
local Map = require "engine.Map"
local Level = require "engine.Level"

newEffect{
	name = "CUT", image = "effects/cut.png",
	desc = "Bleeding",
	kr_name = "출혈",
	long_desc = function(self, eff) return ("출혈상 : 매 턴마다 물리 피해 %0.2f"):format(eff.power) end,
	type = "physical",
	subtype = { wound=true, cut=true },
	status = "detrimental",
	parameters = { power=1 },
	on_gain = function(self, err) return "#Target1# 피를 흘리기 시작합니다.", "+출혈" end,
	on_lose = function(self, err) return "#Target#의 출혈이 멈췄습니다.", "-출혈" end,
	on_merge = function(self, old_eff, new_eff)
		-- Merge the flames!
		local olddam = old_eff.power * old_eff.dur
		local newdam = new_eff.power * new_eff.dur
		local dur = math.ceil((old_eff.dur + new_eff.dur) / 2)
		old_eff.dur = dur
		old_eff.power = (olddam + newdam) / dur
		return old_eff
	end,
	on_timeout = function(self, eff)
		DamageType:get(DamageType.PHYSICAL).projector(eff.src or self, self.x, self.y, DamageType.PHYSICAL, eff.power)
	end,
}

newEffect{
	name = "DEEP_WOUND", image = "talents/bleeding_edge.png",
	desc = "Deep Wound",
	kr_name = "깊은 상처",
	long_desc = function(self, eff) return ("깊은 상처 : 매 턴마다 물리 피해 %0.2f / 치유 효율 -%d%%"):format(eff.power, eff.heal_factor) end,
	type = "physical",
	subtype = { wound=true, cut=true },
	status = "detrimental",
	parameters = {power=10, heal_factor=30},
	on_gain = function(self, err) return "#Target1# 피를 흘리기 시작합니다.", "+깊은 상처" end,
	on_lose = function(self, err) return "#Target#의 출혈이 멈췄습니다.", "-깊은 상처" end,
	activate = function(self, eff)
		eff.healid = self:addTemporaryValue("healing_factor", -eff.heal_factor / 100)
	end,
	on_timeout = function(self, eff)
		DamageType:get(DamageType.PHYSICAL).projector(eff.src or self, self.x, self.y, DamageType.PHYSICAL, eff.power)
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("healing_factor", eff.healid)
	end,
}

newEffect{
	name = "REGENERATION", image = "talents/infusion__regeneration.png",
	desc = "Regeneration",
	kr_name = "재생",
	long_desc = function(self, eff) return ("주변에 생명력이 흐름 : 매 턴마다 생명력 재생 %0.2f"):format(eff.power) end,
	type = "physical",
	subtype = { nature=true, healing=true },
	status = "beneficial",
	parameters = { power=10 },
	on_gain = function(self, err) return "#Target#의 생명력이 빠르게 재생됩니다.", "+재생" end,
	on_lose = function(self, err) return "#Target#의 생명력 재생이 조금 느려집니다.", "-재생" end,
	activate = function(self, eff)
		if not eff.no_wild_growth then
			if self:attr("liferegen_factor") then eff.power = eff.power * (100 + self:attr("liferegen_factor")) / 100 end
			if self:attr("liferegen_dur") then eff.dur = eff.dur + self:attr("liferegen_dur") end
		end
		eff.tmpid = self:addTemporaryValue("life_regen", eff.power)

		if self:knowTalent(self.T_ANCESTRAL_LIFE) then
			local t = self:getTalentFromId(self.T_ANCESTRAL_LIFE)
			self.energy.value = self.energy.value + (t.getTurn(self, t) * game.energy_to_act / 100)
		end
	end,
	on_timeout = function(self, eff)
		if self:knowTalent(self.T_ANCESTRAL_LIFE) then
			local t = self:getTalentFromId(self.T_ANCESTRAL_LIFE)
			self:incEquilibrium(-t.getEq(self, t))
		end
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("life_regen", eff.tmpid)
	end,
}

newEffect{
	name = "POISONED", image = "effects/poisoned.png",
	desc = "Poisoned",
	kr_name = "중독",
	long_desc = function(self, eff) return ("중독 : 매 턴마다 자연 피해 %0.2f"):format(eff.power) end,
	type = "physical",
	subtype = { poison=true, nature=true }, no_ct_effect = true,
	status = "detrimental",
	parameters = { power=10 },
	on_gain = function(self, err) return "#Target1# 중독되었습니다!", "+중독" end,
	on_lose = function(self, err) return "#Target#의 중독이 회복되었습니다.", "-중독" end,
	on_merge = function(self, old_eff, new_eff)
		-- Merge the poison
		local olddam = old_eff.power * old_eff.dur
		local newdam = new_eff.power * new_eff.dur
		local dur = math.ceil((old_eff.dur + new_eff.dur) / 2)
		old_eff.dur = dur
		old_eff.power = (olddam + newdam) / dur
		if new_eff.max_power then old_eff.power = math.min(old_eff.power, new_eff.max_power) end
		return old_eff
	end,
	on_timeout = function(self, eff)
		if self:attr("purify_poison") then self:heal(eff.power)
		else DamageType:get(DamageType.NATURE).projector(eff.src, self.x, self.y, DamageType.NATURE, eff.power)
		end
	end,
}

newEffect{
	name = "SPYDRIC_POISON", image = "effects/spydric_poison.png",
	desc = "Spydric Poison",
	kr_name = "거미독",
	long_desc = function(self, eff) return ("거미독 : 매 턴마다 자연 피해 %0.2f / 이동 불가능 (다른 행동은 가능)"):format(eff.power) end,
	type = "physical",
	subtype = { poison=true, pin=true, nature=true }, no_ct_effect = true,
	status = "detrimental",
	parameters = {power=10},
	on_gain = function(self, err) return "#Target1# 중독되어, 이동할 수 없습니다!", "+거미독" end,
	on_lose = function(self, err) return "#Target#의 중독이 회복되었습니다.", "-거미독" end,
	activate = function(self, eff)
		eff.tmpid = self:addTemporaryValue("never_move", 1)
	end,
	on_timeout = function(self, eff)
		if self:attr("purify_poison") then self:heal(eff.power)
		else DamageType:get(DamageType.NATURE).projector(eff.src, self.x, self.y, DamageType.NATURE, eff.power)
		end
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("never_move", eff.tmpid)
	end,
}

newEffect{
	name = "INSIDIOUS_POISON", image = "effects/insidious_poison.png",
	desc = "Insidious Poison",
	kr_name = "잠식형 독",
	long_desc = function(self, eff) return ("잠식형 독 : 매 턴마다 자연 피해 %0.2f / 치유 효율 -%d%%"):format(eff.power, eff.heal_factor) end,
	type = "physical",
	subtype = { poison=true, nature=true }, no_ct_effect = true,
	status = "detrimental",
	parameters = {power=10, heal_factor=30},
	on_gain = function(self, err) return "#Target1# 중독되었습니다!", "+잠식형 독" end,
	on_lose = function(self, err) return "#Target#의 중독이 회복되었습니다.", "-잠식형 독" end,
	activate = function(self, eff)
		eff.healid = self:addTemporaryValue("healing_factor", -eff.heal_factor / 100)
	end,
	on_timeout = function(self, eff)
		if self:attr("purify_poison") then self:heal(eff.power)
		else DamageType:get(DamageType.NATURE).projector(eff.src, self.x, self.y, DamageType.NATURE, eff.power)
		end
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("healing_factor", eff.healid)
	end,
}

newEffect{
	name = "CRIPPLING_POISON", image = "talents/crippling_poison.png",
	desc = "Crippling Poison",
	kr_name = "무력형 독",
	long_desc = function(self, eff) return ("중독 : 매 턴마다 자연 피해 %0.2f / 기술 사용시 %d%% 확률로 사용 실패"):format(eff.power, eff.fail) end,
	type = "physical",
	subtype = { poison=true, nature=true }, no_ct_effect = true,
	status = "detrimental",
	parameters = {power=10, fail=5},
	on_gain = function(self, err) return "#Target1# 중독되었습니다!", "+무력형 독" end,
	on_lose = function(self, err) return "#Target#의 중독이 회복되었습니다.", "-무력형 독" end,
	-- Damage each turn
	on_timeout = function(self, eff)
		if self:attr("purify_poison") then self:heal(eff.power)
		else DamageType:get(DamageType.NATURE).projector(eff.src, self.x, self.y, DamageType.NATURE, eff.power)
		end
	end,
	activate = function(self, eff)
		eff.tmpid = self:addTemporaryValue("talent_fail_chance", eff.fail)
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("talent_fail_chance", eff.tmpid)
	end,
}

newEffect{
	name = "NUMBING_POISON", image = "effects/numbing_poison.png",
	desc = "Numbing Poison",
	kr_name = "마비형 독",
	long_desc = function(self, eff) return ("중독 : 매 턴마다 자연 피해 %0.2f / 공격시 피해량 -%d%%"):format(eff.power, eff.reduce) end,
	type = "physical",
	subtype = { poison=true, nature=true }, no_ct_effect = true,
	status = "detrimental",
	parameters = {power=10, reduce=5},
	on_gain = function(self, err) return "#Target1# 중독되었습니다!", "+마비형 독" end,
	on_lose = function(self, err) return "#Target#의 중독이 회복되었습니다.", "-마비형 독" end,
	-- Damage each turn
	on_timeout = function(self, eff)
		if self:attr("purify_poison") then self:heal(eff.power)
		else DamageType:get(DamageType.NATURE).projector(eff.src, self.x, self.y, DamageType.NATURE, eff.power)
		end
	end,
	activate = function(self, eff)
		eff.tmpid = self:addTemporaryValue("numbed", eff.reduce)
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("numbed", eff.tmpid)
	end,
}

newEffect{
	name = "STONE_POISON", image = "talents/stoning_poison.png",
	desc = "Stoning Poison",
	kr_name = "석화형 독",
	long_desc = function(self, eff) return ("중독 : 매 턴마다 자연 피해 %0.2f / 해독시 %d 턴 동안 석화"):format(eff.power, eff.stone) end,
	type = "physical",
	subtype = { poison=true, earth=true }, no_ct_effect = true,
	status = "detrimental",
	parameters = {power=10, reduce=5},
	on_gain = function(self, err) return "#Target1# 중독되었습니다!", "+석화형 독" end,
	on_lose = function(self, err) return "#Target#의 중독이 회복되었습니다.", "-석화형 독" end,
	-- Damage each turn
	on_timeout = function(self, eff)
		if self:attr("purify_poison") then self:heal(eff.power)
		else DamageType:get(DamageType.NATURE).projector(eff.src, self.x, self.y, DamageType.NATURE, eff.power)
		end
	end,
	activate = function(self, eff)
	end,
	deactivate = function(self, eff)
		if eff.dur <= 0 and self:canBe("stun") and self:canBe("stone") and self:canBe("instakill") then
			self:setEffect(self.EFF_STONED, eff.stone, {})
		end
	end,
}

newEffect{
	name = "BURNING", image = "talents/flame.png",
	desc = "Burning",
	kr_name = "불 붙음",
	long_desc = function(self, eff) return ("불 붙음 : 매 턴마다 화염 피해 %0.2f"):format(eff.power) end,
	type = "physical",
	subtype = { fire=true },
	status = "detrimental",
	parameters = { power=10 },
	on_gain = function(self, err) return "#Target#의 몸에 불이 붙었습니다!", "+불 붙음" end,
	on_lose = function(self, err) return "#Target#의 불이 멈췄습니다.", "-불 붙음" end,
	on_merge = function(self, old_eff, new_eff)
		-- Merge the flames!
		local olddam = old_eff.power * old_eff.dur
		local newdam = new_eff.power * new_eff.dur
		local dur = math.ceil((old_eff.dur + new_eff.dur) / 2)
		old_eff.dur = dur
		old_eff.power = (olddam + newdam) / dur
		return old_eff
	end,
	on_timeout = function(self, eff)
		DamageType:get(DamageType.FIRE).projector(eff.src, self.x, self.y, DamageType.FIRE, eff.power)
	end,
}

newEffect{
	name = "BURNING_SHOCK", image = "talents/flameshock.png",
	desc = "Burning Shock",
	kr_name = "화염 충격",
	long_desc = function(self, eff) return ("화염 충격 : 매 턴마다 화염 피해 %0.2f / 공격시 피해량 -70%% / 50%% 확률로 임의의 기술이 대기상태로 변경 / 이동 속도 -50%% / 재사용 대기시간이 줄어들지 않음"):format(eff.power) end,
	type = "physical",
	subtype = { fire=true, stun=true },
	status = "detrimental",
	parameters = {},
	on_gain = function(self, err) return "#Target1# 화염 충격으로 기절했습니다!", "+화염 충격" end,
	on_lose = function(self, err) return "#Target1# 기절에서 깨어났습니다.", "-화염 충격" end,
	activate = function(self, eff)
		eff.tmpid = self:addTemporaryValue("stunned", 1)
		eff.tcdid = self:addTemporaryValue("no_talents_cooldown", 1)
		eff.speedid = self:addTemporaryValue("movement_speed", -0.5)

		local tids = {}
		for tid, lev in pairs(self.talents) do
			local t = self:getTalentFromId(tid)
			if t and not self.talents_cd[tid] and t.mode == "activated" and not t.innate and t.no_energy ~= true then tids[#tids+1] = t end
		end
		for i = 1, 4 do
			local t = rng.tableRemove(tids)
			if not t then break end
			self.talents_cd[t.id] = 1 -- Just set cooldown to 1 since cooldown does not decrease while stunned
		end
	end,
	on_timeout = function(self, eff)
		DamageType:get(DamageType.FIRE).projector(eff.src, self.x, self.y, DamageType.FIRE, eff.power)
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("stunned", eff.tmpid)
		self:removeTemporaryValue("no_talents_cooldown", eff.tcdid)
		self:removeTemporaryValue("movement_speed", eff.speedid)
	end,
}

newEffect{
	name = "STUNNED", image = "effects/stunned.png",
	desc = "Stunned",
	kr_name = "기절",
	long_desc = function(self, eff) return ("기절 : 공격시 피해량 -70%% / 이동 속도 -50%% / 50%% 확률로 임의의 기술이 대기상태로 변경 / 재사용 대기시간이 줄어들지 않음"):format() end,
	type = "physical",
	subtype = { stun=true },
	status = "detrimental",
	parameters = {},
	on_gain = function(self, err) return "#Target1# 기절했습니다!", "+기절" end,
	on_lose = function(self, err) return "#Target1# 기절에서 깨어났습니다.", "-기절" end,
	activate = function(self, eff)
		eff.tmpid = self:addTemporaryValue("stunned", 1)
		eff.tcdid = self:addTemporaryValue("no_talents_cooldown", 1)
		eff.speedid = self:addTemporaryValue("movement_speed", -0.5)

		local tids = {}
		for tid, lev in pairs(self.talents) do
			local t = self:getTalentFromId(tid)
			if t and not self.talents_cd[tid] and t.mode == "activated" and not t.innate and t.no_energy ~= true then tids[#tids+1] = t end
		end
		for i = 1, 4 do
			local t = rng.tableRemove(tids)
			if not t then break end
			self.talents_cd[t.id] = 1 -- Just set cooldown to 1 since cooldown does not decrease while stunned
		end
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("stunned", eff.tmpid)
		self:removeTemporaryValue("no_talents_cooldown", eff.tcdid)
		self:removeTemporaryValue("movement_speed", eff.speedid)
	end,
}

newEffect{
	name = "DISARMED", image = "talents/disarm.png",
	desc = "Disarmed",
	kr_name = "무장 해제",
	long_desc = function(self, eff) return "무장 해제 : 무기 사용 불가능" end,
	type = "physical",
	subtype = { disarm=true },
	status = "detrimental",
	parameters = {},
	on_gain = function(self, err) return "#Target1# 무장 해제 되었습니다!", "+무장 해제" end,
	on_lose = function(self, err) return "#Target1# 다시 무장을 갖췄습니다.", "-무장 해제" end,
	activate = function(self, eff)
		eff.tmpid = self:addTemporaryValue("disarmed", 1)
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("disarmed", eff.tmpid)
	end,
}

newEffect{
	name = "CONSTRICTED", image = "talents/constrict.png",
	desc = "Constricted",
	kr_name = "목 막힘",
	long_desc = function(self, eff) return ("목 막힘 : 이동 불가능 / 질식 (매 턴마다 호흡 -%0.2f)"):format(eff.power) end,
	type = "physical",
	subtype = { grapple=true, pin=true },
	status = "detrimental",
	parameters = {power=10},
	on_gain = function(self, err) return "#Target#의 목이 막혔습니다!", "+목막힘" end,
	on_lose = function(self, err) return "#Target2# 이제 자유롭게 숨쉴 수 있습니다.", "-목막힘" end,
	activate = function(self, eff)
		eff.tmpid = self:addTemporaryValue("never_move", 1)
	end,
	on_timeout = function(self, eff)
		if core.fov.distance(self.x, self.y, eff.src.x, eff.src.y) > 1 or eff.src.dead or not game.level:hasEntity(eff.src) then
			return true
		end
		self:suffocate(eff.power, eff.src, (" %s에 의해 숨 막혀 죽음"):format((eff.src.kr_name or eff.src.name):capitalize()))
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("never_move", eff.tmpid)
	end,
}

newEffect{
	name = "DAZED", image = "effects/dazed.png",
	desc = "Dazed",
	kr_name = "혼절",
	long_desc = function(self, eff) return "혼절 : 이동 불가능 / 공격시 피해량 -50% / 회피도 -50% / 모든 내성 -50% / 정확도 -50% / 주문력 -50% / 정신력 -50% / 물리력 -50% \n피해를 받으면 즉시 혼절 제거" end,
	type = "physical",
	subtype = { stun=true },
	status = "detrimental",
	parameters = {},
	on_gain = function(self, err) return "#Target1# 혼절했습니다!", "+혼절" end,
	on_lose = function(self, err) return "#Target1# 혼절에서 깨어났습니다.", "-혼절" end,
	activate = function(self, eff)
		self:effectTemporaryValue(eff, "dazed", 1)
		self:effectTemporaryValue(eff, "never_move", 1)
	end,
	deactivate = function(self, eff)
	end,
}

newEffect{
	name = "EVASION", image = "talents/evasion.png",
	desc = "Evasion",
	kr_name = "회피",
	long_desc = function(self, eff) return ("%d%% 확률로 근접 공격 회피"):format(eff.chance) end,
	type = "physical",
	subtype = { evade=true },
	status = "beneficial",
	parameters = { chance=10 },
	on_gain = function(self, err) return "#Target1# 공격 회피를 시도합니다.", "+회피" end,
	on_lose = function(self, err) return "#Target1# 더이상 공격 회피를 하지 않습니다.", "-회피" end,
	activate = function(self, eff)
		eff.tmpid = self:addTemporaryValue("evasion", eff.chance)
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("evasion", eff.tmpid)
	end,
}

newEffect{
	name = "SPEED", image = "talents/shaloren_speed.png",
	desc = "Speed",
	kr_name = "빠름", --@@ '가속'은 magical.lua의 Haste에 사용해서, 여기는 '빠름'으로 사용함
	long_desc = function(self, eff) return ("모든 행동 속도 +%d%%"):format(eff.power * 100) end,
	type = "physical",
	subtype = { speed=true },
	status = "beneficial",
	parameters = { power=0.1 },
	on_gain = function(self, err) return "#Target1# 빨라졌습니다.", "+빠름" end,
	on_lose = function(self, err) return "#Target1# 느려졌습니다.", "-빠름" end,
	activate = function(self, eff)
		eff.tmpid = self:addTemporaryValue("global_speed_add", eff.power)
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("global_speed_add", eff.tmpid)
	end,
}

newEffect{
	name = "SLOW", image = "talents/slow.png",
	desc = "Slow",
	kr_name = "감속",
	long_desc = function(self, eff) return ("모든 행동 속도 -%d%%"):format( eff.power * 100) end,
	type = "physical",
	subtype = { slow=true },
	status = "detrimental",
	parameters = { power=0.1 },
	on_gain = function(self, err) return "#Target1# 느려졌습니다.", "+감속" end,
	on_lose = function(self, err) return "#Target1# 빨라졌습니다.", "-감속" end,
	activate = function(self, eff)
		eff.tmpid = self:addTemporaryValue("global_speed_add", -eff.power)
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("global_speed_add", eff.tmpid)
	end,
}

newEffect{
	name = "BLINDED", image = "effects/blinded.png",
	desc = "Blinded",
	kr_name = "실명",
	long_desc = function(self, eff) return "아무 것도 볼 수 없게 됨" end,
	type = "physical",
	subtype = { blind=true },
	status = "detrimental",
	parameters = {},
	on_gain = function(self, err) return "#Target1# 실명됐습니다!", "+실명" end,
	on_lose = function(self, err) return "#Target1# 시야를 회복했습니다.", "-실명" end,
	activate = function(self, eff)
		eff.tmpid = self:addTemporaryValue("blind", 1)
		if game.level then
			self:resetCanSeeCache()
			if self.player then for uid, e in pairs(game.level.entities) do if e.x then game.level.map:updateMap(e.x, e.y) end end game.level.map.changed = true end
		end
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("blind", eff.tmpid)
		if game.level then
			self:resetCanSeeCache()
			if self.player then for uid, e in pairs(game.level.entities) do if e.x then game.level.map:updateMap(e.x, e.y) end end game.level.map.changed = true end
		end
	end,
}

newEffect{
	name = "DWARVEN_RESILIENCE", image = "talents/dwarf_resilience.png",
	desc = "Dwarven Resilience",
	kr_name = "드워프의 체질",
	long_desc = function(self, eff) return ("피부 암석화 : 방어도 +%d / 물리내성 +%d / 주문내성 +%d"):format(eff.armor, eff.physical, eff.spell) end,
	type = "physical",
	subtype = { earth=true },
	status = "beneficial",
	parameters = { armor=10, spell=10, physical=10 },
	on_gain = function(self, err) return "#Target#의 피부가 암석화됩니다." end,
	on_lose = function(self, err) return "#Target#의 피부가 정상적으로 돌아왔습니다." end,
	activate = function(self, eff)
		eff.aid = self:addTemporaryValue("combat_armor", eff.armor)
		eff.pid = self:addTemporaryValue("combat_physresist", eff.physical)
		eff.sid = self:addTemporaryValue("combat_spellresist", eff.spell)
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("combat_armor", eff.aid)
		self:removeTemporaryValue("combat_physresist", eff.pid)
		self:removeTemporaryValue("combat_spellresist", eff.sid)
	end,
}

newEffect{
	name = "STONE_SKIN", image = "talents/stoneskin.png",
	desc = "Stoneskin",
	kr_name = "단단한 피부",
	long_desc = function(self, eff) return ("피부가 피해에 반응 : 방어도 +%d"):format(eff.power) end,
	type = "physical",
	subtype = { earth=true },
	status = "beneficial",
	parameters = { power=10 },
	activate = function(self, eff)
		eff.aid = self:addTemporaryValue("combat_armor", eff.power)
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("combat_armor", eff.aid)
	end,
}

newEffect{
	name = "THORNY_SKIN", image = "talents/stoneskin.png",
	desc = "Thorny Skin",
	kr_name = "가시돋힌 피부",
	long_desc = function(self, eff) return ("피부가 피해에 반응 : 방어도 +%d / 방어효율 +%d%%"):format(eff.ac, eff.hard) end,
	type = "physical",
	subtype = { nature=true },
	status = "beneficial",
	parameters = { ac=10, hard=10 },
	activate = function(self, eff)
		eff.aid = self:addTemporaryValue("combat_armor", eff.ac)
		eff.hid = self:addTemporaryValue("combat_armor_hardiness", eff.hard)
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("combat_armor", eff.aid)
		self:removeTemporaryValue("combat_armor_hardiness", eff.hid)
	end,
}

newEffect{
	name = "FROZEN_FEET", image = "talents/frozen_ground.png",
	desc = "Frozen Feet",
	kr_name = "얼어붙은 발",
	long_desc = function(self, eff) return "땅에 얼어붙은 발 : 이동 불가능 (다른 행동은 가능)." end,
	type = "physical",
	subtype = { cold=true, pin=true },
	status = "detrimental",
	parameters = {},
	on_gain = function(self, err) return "#Target#의 발이 땅에 얼어붙습니다!", "+빙결" end,
	on_lose = function(self, err) return "#Target#의 발이 녹았습니다.", "-빙결" end,
	activate = function(self, eff)
		eff.tmpid = self:addTemporaryValue("never_move", 1)
		eff.frozid = self:addTemporaryValue("frozen", 1)
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("never_move", eff.tmpid)
		self:removeTemporaryValue("frozen", eff.frozid)
	end,
}

newEffect{
	name = "FROZEN", image = "talents/freeze.png",
	desc = "Frozen",
	kr_name = "빙결",
	long_desc = function(self, eff) return ("얼음덩어리에 갇힘 : 모든 피해의 40%% 는 얼음덩어리가 흡수하고, 자신은 60%% 의 피해를 입음 / 회피 불가능 / 얼음덩어리만 공격 가능 / 다른 상태이상 효과에 완전 면역 / 공간이동 불가능 / 치료 불가능\n얼음덩어리의 남은 생명력 : %d"):format(eff.hp) end,
	type = "physical", -- Frozen has some serious effects beyond just being frozen, no healing, no teleport, etc.  But it can be applied by clearly non-magical sources i.e. Ice Breath
	subtype = { cold=true, stun=true },
	status = "detrimental",
	parameters = {},
	on_gain = function(self, err) return "#Target1# 얼음덩어리에 갇혔습니다!", "+빙결" end,
	on_lose = function(self, err) return "#Target1# 얼음덩어리에서 빠져나왔습니다.", "-빙결" end,
	activate = function(self, eff)
		-- Change color
		eff.old_r = self.color_r
		eff.old_g = self.color_g
		eff.old_b = self.color_b
		self.color_r = 0
		self.color_g = 255
		self.color_b = 155
		if not self.add_displays then
			self.add_displays = { Entity.new{image='npc/iceblock.png', display=' ', display_on_seen=true } }
			eff.added_display = true
		end
		self:removeAllMOs()
		game.level.map:updateMap(self.x, self.y)

		eff.hp = eff.hp or 100
		eff.tmpid = self:addTemporaryValue("encased_in_ice", 1)
		eff.healid = self:addTemporaryValue("no_healing", 1)
		eff.moveid = self:addTemporaryValue("never_move", 1)
		eff.frozid = self:addTemporaryValue("frozen", 1)
		eff.defid = self:addTemporaryValue("combat_def", -1000)
		eff.rdefid = self:addTemporaryValue("combat_def_ranged", -1000)
		eff.sefid = self:addTemporaryValue("negative_status_effect_immune", 1)

		self:setTarget(self)
	end,
	on_timeout = function(self, eff)
		self:setTarget(self)
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("encased_in_ice", eff.tmpid)
		self:removeTemporaryValue("no_healing", eff.healid)
		self:removeTemporaryValue("never_move", eff.moveid)
		self:removeTemporaryValue("frozen", eff.frozid)
		self:removeTemporaryValue("combat_def", eff.defid)
		self:removeTemporaryValue("combat_def_ranged", eff.rdefid)
		self:removeTemporaryValue("negative_status_effect_immune", eff.sefid)
		self.color_r = eff.old_r
		self.color_g = eff.old_g
		self.color_b = eff.old_b
		if eff.added_display then self.add_displays = nil end
		self:removeAllMOs()
		game.level.map:updateMap(self.x, self.y)
		self:setTarget(nil)
	end,
}

newEffect{
	name = "ETERNAL_WRATH", image = "talents/thaloren_wrath.png",
	desc = "Wrath of the Eternals",
	kr_name = "영원의 분노",
	long_desc = function(self, eff) return ("내면의 힘 : 공격시 피해량 +%d%% / 전체 저항 +%d%%"):format(eff.power, eff.power) end,
	type = "physical",
	subtype = { nature=true },
	status = "beneficial",
	parameters = { power=10 },
	on_gain = function(self, err) return "#Target1# 힘을 내뿜습니다." end,
	on_lose = function(self, err) return "#Target#에게 느껴지던 힘이 사라졌습니다." end,
	activate = function(self, eff)
		eff.pid1 = self:addTemporaryValue("inc_damage", {all=eff.power})
		eff.pid2 = self:addTemporaryValue("resists", {all=eff.power})
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("inc_damage", eff.pid1)
		self:removeTemporaryValue("resists", eff.pid2)
	end,
}

newEffect{
	name = "SHELL_SHIELD", image = "talents/shell_shield.png",
	desc = "Shell Shield",
	kr_name = "등껍질 보호막",
	long_desc = function(self, eff) return ("등껍질 : 전체 저항 +%d%%"):format(eff.power) end,
	type = "physical",
	subtype = { nature=true },
	status = "beneficial",
	parameters = { power=50 },
	on_gain = function(self, err) return "#Target1# 등껍질 속으로 몸을 웅크립니다.", "+등껍질 보호막" end,
	on_lose = function(self, err) return "#Target#의 몸이 등껍질 바깥으로 벗어났습니다.", "-등껍질 보호막" end,
	activate = function(self, eff)
		eff.pid = self:addTemporaryValue("resists", {all=eff.power})
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("resists", eff.pid)
	end,
}

newEffect{
	name = "PAIN_SUPPRESSION", image = "talents/infusion__wild.png",
	desc = "Pain Suppression",
	kr_name = "고통 억제",
	long_desc = function(self, eff) return ("고통 무시 : 전체 저항 +%d%%"):format(eff.power) end,
	type = "physical",
	subtype = { nature=true },
	status = "beneficial",
	parameters = { power=20 },
	on_gain = function(self, err) return "#Target1# 고통을 억제합니다.", "+고통 억제" end,
	on_lose = function(self, err) return "#Target1# 다시 고통을 느낍니다.", "-고통 억제" end,
	activate = function(self, eff)
		eff.pid = self:addTemporaryValue("resists", {all=eff.power})
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("resists", eff.pid)
	end,
}

newEffect{
	name = "PURGE_BLIGHT", image = "talents/infusion__wild.png",
	desc = "Purge Blight",
	kr_name = "황폐 정화",
	long_desc = function(self, eff) return ("자연의 힘 주입 : 황폐 저항 +%d%% / 주문내성 +%d / 질병에 완전 면역"):format(eff.power, eff.power) end,
	type = "physical",
	subtype = { nature=true },
	status = "beneficial",
	parameters = { power=20 },
	on_gain = function(self, err) return "#Target1# 황폐의 힘을 정화합니다!", "+정화" end,
	on_lose = function(self, err) return "#Target1# 다시 황폐에 취약해졌습니다.", "-정화" end,
	activate = function(self, eff)
		eff.pid = self:addTemporaryValue("resists", {[DamageType.BLIGHT]=eff.power})
		eff.spell_save = self:addTemporaryValue("combat_spellresist", eff.power)
		eff.disease = self:addTemporaryValue("disease_immune", 1)
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("combat_spellresist", eff.spell_save)
		self:removeTemporaryValue("disease_immune", eff.disease)
		self:removeTemporaryValue("resists", eff.pid)
	end,
}

newEffect{
	name = "SENSE", image = "talents/track.png",
	desc = "Sensing",
	kr_name = "감지",
	long_desc = function(self, eff) return "인지 능력 향상 : 보이지 않는 것들을 탐지" end,
	type = "physical",
	subtype = { sense=true },
	status = "beneficial",
	parameters = { range=10, actor=1, object=0, trap=0 },
	activate = function(self, eff)
		eff.rid = self:addTemporaryValue("detect_range", eff.range)
		eff.aid = self:addTemporaryValue("detect_actor", eff.actor)
		eff.oid = self:addTemporaryValue("detect_object", eff.object)
		eff.tid = self:addTemporaryValue("detect_trap", eff.trap)
		self.detect_function = eff.on_detect
		game.level.map.changed = true
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("detect_range", eff.rid)
		self:removeTemporaryValue("detect_actor", eff.aid)
		self:removeTemporaryValue("detect_object", eff.oid)
		self:removeTemporaryValue("detect_trap", eff.tid)
		self.detect_function = nil
	end,
}

newEffect{
	name = "HEROISM", image = "talents/infusion__heroism.png",
	desc = "Heroism",
	kr_name = "영웅",
	long_desc = function(self, eff) return ("가장 높은 능력치 세 가지 +%d"):format(eff.power) end,
	type = "physical",
	subtype = { nature=true },
	status = "beneficial",
	parameters = { power=1 },
	activate = function(self, eff)
		local l = { {Stats.STAT_STR, self:getStat("str")}, {Stats.STAT_DEX, self:getStat("dex")}, {Stats.STAT_CON, self:getStat("con")}, {Stats.STAT_MAG, self:getStat("mag")}, {Stats.STAT_WIL, self:getStat("wil")}, {Stats.STAT_CUN, self:getStat("cun")}, }
		table.sort(l, function(a,b) return a[2] > b[2] end)
		local inc = {}
		for i = 1, 3 do inc[l[i][1]] = eff.power end
		self:effectTemporaryValue(eff, "inc_stats", inc)
		self:effectTemporaryValue(eff, "die_at", -eff.die_at)
	end,
}

newEffect{
	name = "SUNDER_ARMOUR", image = "talents/sunder_armour.png",
	desc = "Sunder Armour",
	kr_name = "방어구 손상",
	long_desc = function(self, eff) return ("방어구 손상 : 방어도 -%d"):format(eff.power) end,
	type = "physical",
	subtype = { sunder=true },
	status = "detrimental",
	parameters = { power=10 },
	activate = function(self, eff)
		eff.tmpid = self:addTemporaryValue("combat_armor", -eff.power)
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("combat_armor", eff.tmpid)
	end,
}

newEffect{
	name = "SUNDER_ARMS", image = "talents/sunder_arms.png",
	desc = "Sunder Arms",
	kr_name = "팔 부상",
	long_desc = function(self, eff) return ("팔 부상 : 정확도 -%d"):format(eff.power) end,
	type = "physical",
	subtype = { sunder=true },
	status = "detrimental",
	parameters = { power=10 },
	activate = function(self, eff)
		eff.tmpid = self:addTemporaryValue("combat_atk", -eff.power)
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("combat_atk", eff.tmpid)
	end,
}

newEffect{
	name = "PINNED", image = "effects/pinned.png",
	desc = "Pinned to the ground",
	kr_name = "대지의 속박",
	long_desc = function(self, eff) return "대지의 속박 : 이동 불가능" end,
	type = "physical",
	subtype = { pin=true },
	status = "detrimental",
	parameters = {},
	on_gain = function(self, err) return "#Target1# 대지에 고정되었습니다.", "+속박" end,
	on_lose = function(self, err) return "#Target1# 속박에서 벗어났습니다.", "-속박" end,
	activate = function(self, eff)
		eff.tmpid = self:addTemporaryValue("never_move", 1)
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("never_move", eff.tmpid)
	end,
}

newEffect{
	name = "MIGHTY_BLOWS", image = "effects/mighty_blows.png",
	desc = "Mighty Blows",
	kr_name = "강력한 일격",
	long_desc = function(self, eff) return ("공격시 피해량 +%d"):format(eff.power) end,
	type = "physical",
	subtype = { golem=true },
	status = "beneficial",
	parameters = { power=10 },
	on_gain = function(self, err) return "#Target1# 더 위협적으로 보이기 시작합니다." end,
	on_lose = function(self, err) return "이제 #Target2# 덜 위협적으로 보입니다." end,
	activate = function(self, eff)
		eff.tmpid = self:addTemporaryValue("combat_dam", eff.power)
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("combat_dam", eff.tmpid)
	end,
}

newEffect{
	name = "CRIPPLE", image = "talents/cripple.png",
	desc = "Cripple",
	kr_name = "장애",
	long_desc = function(self, eff) return ("장애 : 근접공격 속도 -%d%% / 주문시전 속도 -%d%% / 사고속도 -%d%%"):format(eff.speed*100, eff.speed*100, eff.speed*100) end, --@@ 변수 조정
	type = "physical",
	subtype = { wound=true },
	status = "detrimental",
	parameters = { speed=0.3 },
	on_gain = function(self, err) return "#Target#에게 장애가 발생했습니다." end,
	on_lose = function(self, err) return "#Target#의 장애가 사라졌습니다." end,
	activate = function(self, eff)
		self:effectTemporaryValue(eff, "combat_physspeed", -eff.speed)
		self:effectTemporaryValue(eff, "combat_spellspeed", -eff.speed)
		self:effectTemporaryValue(eff, "combat_mindspeed", -eff.speed)
	end,
}

newEffect{
	name = "BURROW", image = "talents/burrow.png",
	desc = "Burrow",
	kr_name = "파고들기",
	long_desc = function(self, eff) return "벽 속으로 파고들기 가능" end,
	type = "physical",
	subtype = { earth=true },
	status = "beneficial",
	parameters = { },
	activate = function(self, eff)
		eff.pass = self:addTemporaryValue("can_pass", {pass_wall=1})
		eff.dig = self:addTemporaryValue("move_project", {[DamageType.DIG]=1})
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("can_pass", eff.pass)
		self:removeTemporaryValue("move_project", eff.dig)
	end,
}

newEffect{
	name = "DIM_VISION", image = "talents/sticky_smoke.png",
	desc = "Reduced Vision",
	kr_name = "시야 감소",
	long_desc = function(self, eff) return ("시야 -%d"):format(eff.sight) end,
	type = "physical",
	subtype = { sense=true },
	status = "detrimental",
	parameters = { sight=5 },
	on_gain = function(self, err) return "#Target1# 짙은 연기로 둘러싸였습니다.", "+침침한 시야" end,
	on_lose = function(self, err) return "#Target# 주변의 연기가 사라졌습니다.", "-침침한 시야" end,
	activate = function(self, eff)
		if self.sight - eff.sight < 1 then eff.sight = self.sight - 1 end
		eff.tmpid = self:addTemporaryValue("sight", -eff.sight)
		self:setTarget(nil) -- Loose target!
		self:doFOV()
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("sight", eff.tmpid)
		self:doFOV()
	end,
}

newEffect{
	name = "RESOLVE", image = "talents/resolve.png",
	desc = "Resolve",
	kr_name = "결의",
	long_desc = function(self, eff) return ("%s 저항 +%d%%"):format((DamageType:get(eff.damtype).kr_name or DamageType:get(eff.damtype).name), eff.res) end, --@@ 변수 순서 조정
	type = "physical",
	subtype = { antimagic=true, nature=true },
	status = "beneficial",
	parameters = { res=10, damtype=DamageType.ARCANE },
	on_gain = function(self, err) return "#Target1# 피해에 적응합니다.", "+결의" end,
	on_lose = function(self, err) return "#Target#의 적응력이 무뎌졌습니다.", "-결의" end,
	activate = function(self, eff)
		eff.tmpid = self:addTemporaryValue("resists", {[eff.damtype]=eff.res})
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("resists", eff.tmpid)
	end,
}

newEffect{
	name = "WILD_SPEED", image = "talents/infusion__movement.png",
	desc = "Wild Speed",
	kr_name = "야생의 속도",
	long_desc = function(self, eff) return ("이동 속도 +%d%% / 이동 외의 행동시 즉시 야생의 속도 제거"):format(eff.power) end,
	type = "physical",
	subtype = { nature=true, speed=true },
	status = "beneficial",
	parameters = {power=1000},
	on_gain = function(self, err) return "#Target1# 다음번 살해 목표를 위해 준비합니다!.", "+야생의 속도" end,
	on_lose = function(self, err) return "#Target1# 느려졌습니다.", "-야생의 속도" end,
	activate = function(self, eff)
		eff.tmpid = self:addTemporaryValue("wild_speed", 1)
		eff.moveid = self:addTemporaryValue("movement_speed", eff.power/100)
		if self.ai_state then eff.aiid = self:addTemporaryValue("ai_state", {no_talents=1}) end -- Make AI not use talents while using it
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("wild_speed", eff.tmpid)
		if eff.aiid then self:removeTemporaryValue("ai_state", eff.aiid) end
		self:removeTemporaryValue("movement_speed", eff.moveid)
	end,
}

newEffect{
	name = "STEP_UP", image = "talents/step_up.png",
	desc = "Step Up",
	kr_name = "진격",
	long_desc = function(self, eff) return ("이동 속도 +%d%%"):format(eff.power) end,
	type = "physical",
	subtype = { speed=true, tactic=true },
	status = "beneficial",
	parameters = {power=1000},
	on_gain = function(self, err) return "#Target1# 다음 목표를 위해 진격합니다!.", "+진격" end,
	on_lose = function(self, err) return "#Target1# 느려졌습니다.", "-진격" end,
	activate = function(self, eff)
		eff.tmpid = self:addTemporaryValue("step_up", 1)
		eff.moveid = self:addTemporaryValue("movement_speed", eff.power/100)
		if self.ai_state then eff.aiid = self:addTemporaryValue("ai_state", {no_talents=1}) end -- Make AI not use talents while using it
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("step_up", eff.tmpid)
		if eff.aiid then self:removeTemporaryValue("ai_state", eff.aiid) end
		self:removeTemporaryValue("movement_speed", eff.moveid)
	end,
}

newEffect{
	name = "LIGHTNING_SPEED", image = "talents/lightning_speed.png",
	desc = "Lightning Speed",
	kr_name = "번개의 속도",
	long_desc = function(self, eff) return ("순수한 번개로 변신 : 이동 속도 +%d%% / 전기 저항 +100%% / 물리 저항 +30%%"):format(eff.power) end,
	type = "physical",
	subtype = { lightning=true, speed=true },
	status = "beneficial",
	parameters = {},
	on_gain = function(self, err) return "#Target1# 순수한 번개로 변했습니다!.", "+번개의 속도" end,
	on_lose = function(self, err) return "#Target1# 보통의 상태로 돌아왔습니다.", "-번개의 속도" end,
	activate = function(self, eff)
		eff.tmpid = self:addTemporaryValue("lightning_speed", 1)
		eff.moveid = self:addTemporaryValue("movement_speed", eff.power/100)
		eff.resistsid = self:addTemporaryValue("resists", {
			[DamageType.PHYSICAL]=30,
			[DamageType.LIGHTNING]=100,
		})
		if self.ai_state then eff.aiid = self:addTemporaryValue("ai_state", {no_talents=1}) end -- Make AI not use talents while using it
		eff.particle = self:addParticles(Particles.new("bolt_lightning", 1))
	end,
	deactivate = function(self, eff)
		self:removeParticles(eff.particle)
		self:removeTemporaryValue("lightning_speed", eff.tmpid)
		self:removeTemporaryValue("resists", eff.resistsid)
		if eff.aiid then self:removeTemporaryValue("ai_state", eff.aiid) end
		self:removeTemporaryValue("movement_speed", eff.moveid)
	end,
}

newEffect{
	name = "DRAGONS_FIRE", image = "talents/fire_breath.png",
	desc = "Dragon's Fire",
	kr_name = "용의 화염",
	long_desc = function(self, eff) return ("용의 피 활성화 : 화염 브레스 사용 가능 (이미 사용 가능시 효과 증대)"):format() end,
	type = "physical",
	subtype = { fire=true },
	status = "beneficial",
	parameters = {power=1},
	on_gain = function(self, err) return "#Target#의 목구멍에서 불길이 피어오릅니다.", "+용의 화염" end,
	on_lose = function(self, err) return "#Target#의 목구멍이  잔잔히 가라앉았습니다.", "-용의 화염" end,
	activate = function(self, eff)
		local t_id = self.T_FIRE_BREATH
		if not self.talents[t_id] then
			-- Auto assign to hotkey
			if self.hotkey then
				for i = 1, 36 do
					if not self.hotkey[i] then
						self.hotkey[i] = {"talent", t_id}
						break
					end
				end
			end
		end

		eff.tmpid = self:addTemporaryValue("talents", {[t_id] = eff.power})
	end,
	deactivate = function(self, eff)
		local t_id = self.T_FIRE_BREATH
		self:removeTemporaryValue("talents", eff.tmpid)
		if self.talents[t_id] == 0 then
			self.talents[t_id] = nil
			if self.hotkey then
				for i, known_t_id in pairs(self.hotkey) do
					if known_t_id[1] == "talent" and known_t_id[2] == t_id then self.hotkey[i] = nil end
				end
			end
		end
	end,
}

newEffect{
	name = "GREATER_WEAPON_FOCUS", image = "talents/greater_weapon_focus.png",
	desc = "Greater Weapon Focus",
	kr_name = "향상된 염동적 악력",
	long_desc = function(self, eff) return ("%d%% 확률로 두 번 공격"):format(eff.chance) end,
	type = "physical",
	subtype = { tactic=true },
	status = "beneficial",
	parameters = { chance=50 },
	activate = function(self, eff)
	end,
	deactivate = function(self, eff)
	end,
}

-- Grappling stuff
newEffect{
	name = "GRAPPLING", image = "talents/clinch.png",
	desc = "Grappling",
	kr_name = "붙잡기",
	long_desc = function(self, eff) return ("붙잡기 : 이동이나 특수 맨손기술 사용시 붙잡기 해제"):format() end,
	type = "physical",
	subtype = { grapple=true, },
	status = "beneficial",
	parameters = {},
	on_gain = function(self, err) return "#Target1# 붙잡기 상태로 들어갑니다!", "+붙잡기" end,
	on_lose = function(self, err) return "#Target1# 붙잡고 있던 대상이 풀려났습니다.", "-붙잡기" end,
	on_timeout = function(self, eff)
		local p = eff.trgt:hasEffect(eff.trgt.EFF_GRAPPLED)
		local drain = 6 - (self:getTalentLevelRaw(self.T_CLINCH) or 0)
		if not p or p.src ~= self or core.fov.distance(self.x, self.y, eff.trgt.x, eff.trgt.y) > 1 or eff.trgt.dead or not game.level:hasEntity(eff.trgt) then
			self:removeEffect(self.EFF_GRAPPLING)
		else
			self:incStamina(-drain)
		end
	end,
	activate = function(self, eff)
	end,
	deactivate = function(self, eff)
	end,
}

newEffect{
	name = "GRAPPLED", image = "talents/grab.png",
	desc = "Grappled",
	kr_name = "붙잡힘",
	long_desc = function(self, eff) return ("붙잡힘 : 이동 불가능 / 회피도 -%d / 정확도 -%d"):format(eff.power, eff.power) end, --@@ 변수 조정
	type = "physical",
	subtype = { grapple=true, pin=true },
	status = "detrimental",
	parameters = {},
	remove_on_clone = true,
	on_gain = function(self, err) return "#Target1# 붙잡혔습니다!", "+붙잡힘" end,
	on_lose = function(self, err) return "붙잡혀 있던 #Target1# 풀려나왔습니다.", "-붙잡힘" end,
	activate = function(self, eff)
		eff.tmpid = self:addTemporaryValue("never_move", 1)
		eff.def = self:addTemporaryValue("combat_def", -eff.power)
		eff.atk = self:addTemporaryValue("combat_atk", -eff.power)
	end,
	on_timeout = function(self, eff)
		if core.fov.distance(self.x, self.y, eff.src.x, eff.src.y) > 1 or eff.src.dead or not game.level:hasEntity(eff.src) then
			self:removeEffect(self.EFF_GRAPPLED)
		end
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("combat_atk", eff.atk)
		self:removeTemporaryValue("combat_def", eff.def)
		self:removeTemporaryValue("never_move", eff.tmpid)
	end,
}

newEffect{
	name = "CRUSHING_HOLD", image = "talents/crushing_hold.png",
	desc = "Crushing Hold",
	kr_name = "눌려 졸림",
	long_desc = function(self, eff) return ("눌려 졸림 : 매 턴마다 피해 %d"):format(eff.power) end,
	type = "physical",
	subtype = { grapple=true },
	status = "detrimental",
	parameters = { power=1 },
	on_gain = function(self, err) return "#Target1# 눌렸습니다.", "+눌려 졸림" end,
	on_lose = function(self, err) return "눌려있던 #Target1# 풀려나왔습니다.", "-눌려 졸림" end,
	on_timeout = function(self, eff)
		local p = self:hasEffect(self.EFF_GRAPPLED)
		if core.fov.distance(self.x, self.y, eff.src.x, eff.src.y) > 1 or eff.src.dead or not game.level:hasEntity(eff.src) or not (p and p.src == eff.src) then
			self:removeEffect(self.EFF_CRUSHING_HOLD)
		else
			DamageType:get(DamageType.PHYSICAL).projector(eff.src or self, self.x, self.y, DamageType.PHYSICAL, eff.power)
		end
	end,
}

newEffect{
	name = "STRANGLE_HOLD", image = "talents/clinch.png",
	desc = "Strangle Hold",
	kr_name = "숨통 졸림",
	long_desc = function(self, eff) return ("숨통 졸림 : 주문 시전 불가능 / 매 턴마다 피해 %d"):format(eff.power) end,
	type = "physical",
	subtype = { grapple=true, silence=true },
	status = "detrimental",
	parameters = { power=1 },
	on_gain = function(self, err) return "#Target#의 숨통이 졸립니다.", "+숨통 졸림" end,
	on_lose = function(self, err) return "#Target#의 숨통이 풀렸습니다.", "-숨통 졸림" end,
	on_timeout = function(self, eff)
		local p = self:hasEffect(self.EFF_GRAPPLED)
		if core.fov.distance(self.x, self.y, eff.src.x, eff.src.y) > 1 or eff.src.dead or not game.level:hasEntity(eff.src) or not (p and p.src == eff.src) then
			self:removeEffect(self.EFF_STRANGLE_HOLD)
		elseif eff.damtype then
			local type = eff.damtype
			DamageType:get(DamageType[type]).projector(eff.src or self, self.x, self.y, DamageType[type], eff.power)
		else
			DamageType:get(DamageType.PHYSICAL).projector(eff.src or self, self.x, self.y, DamageType.PHYSICAL, eff.power)
		end
	end,
	activate = function(self, eff)
		eff.tmpid = self:addTemporaryValue("silence", 1)
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("silence", eff.tmpid)
	end,
}

newEffect{
	name = "MAIMED", image = "talents/maim.png",
	desc = "Maimed",
	kr_name = "꺾임",
	long_desc = function(self, eff) return ("꺾임 : 공격 피해량 -%d / 모든 행동 속도 -30%%"):format(eff.power) end,
	type = "physical",
	subtype = { wound=true, slow=true },
	status = "detrimental",
	parameters = { atk=10, dam=10 },
	on_gain = function(self, err) return "#Target1# 꺾였습니다.", "+꺾임" end,
	on_lose = function(self, err) return "꺾여 있던 #Target1# 풀려나왔습니다.", "-꺾임" end,
	activate = function(self, eff)
		eff.damid = self:addTemporaryValue("combat_dam", -eff.dam)
		eff.tmpid = self:addTemporaryValue("global_speed_add", -0.3)
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("combat_dam", eff.damid)
		self:removeTemporaryValue("global_speed_add", eff.tmpid)
	end,
}

newEffect{
	name = "COMBO", image = "talents/combo_string.png",
	desc = "Combo",
	kr_name = "연계",
	display_desc = function(self, eff) return "연계 "..eff.cur_power end,
	long_desc = function(self, eff) return ("연계기 사용중 : 현재 연계 점수 %d"):format(eff.cur_power) end,
	type = "physical",
	subtype = { tactic=true },
	status = "beneficial",
	parameters = { power=1, max=5 },
	on_merge = function(self, old_eff, new_eff)
		self:removeTemporaryValue("combo", old_eff.tmpid)
		old_eff.cur_power = math.min(old_eff.cur_power + new_eff.power, new_eff.max)
		old_eff.tmpid = self:addTemporaryValue("combo", {power = old_eff.cur_power})

		old_eff.dur = new_eff.dur
		return old_eff
	end,
	activate = function(self, eff)
		eff.cur_power = eff.power
		eff.tmpid = self:addTemporaryValue("combo", {eff.power})
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("combo", eff.tmpid)
	end,
}

newEffect{
	name = "DEFENSIVE_MANEUVER", image = "talents/set_up.png",
	desc = "Defensive Maneuver",
	kr_name = "방어적 전술",
	long_desc = function(self, eff) return ("회피도 +%d"):format(eff.power) end,
	type = "physical",
	subtype = { evade=true },
	status = "beneficial",
	parameters = {power = 1},
	on_gain = function(self, err) return "#Target1# 방어적으로 움직입니다!", "+방어적 전술" end,
	on_lose = function(self, err) return "#Target1# 더이상 방어적으로 움직이지 않습니다.", "-방어적 전술" end,
	activate = function(self, eff)
		eff.defense = self:addTemporaryValue("combat_def", eff.power)
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("combat_def", eff.defense)
	end,
}

newEffect{
	name = "SET_UP", image = "talents/set_up.png",
	desc = "Set Up",
	kr_name = "흐트러진 자세",
	long_desc = function(self, eff) return ("불균형 : 치명타에 맞을 확률 +%d%% / 모든 내성 -%d"):format(eff.power, eff.power) end,
	type = "physical",
	subtype = { tactic=true },
	status = "detrimental",
	parameters = {power = 1},
	on_gain = function(self, err) return "#Target#의 자세가 흐트러졌습니다!", "+흐트러진 자세" end,
	on_lose = function(self, err) return "#Target1# 자세를 바로잡았습니다.", "-흐트러진 자세" end,
	activate = function(self, eff)
		eff.mental = self:addTemporaryValue("combat_mentalresist", -eff.power)
		eff.spell = self:addTemporaryValue("combat_spellresist", -eff.power)
		eff.physical = self:addTemporaryValue("combat_physresist", -eff.power)
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("combat_mentalresist", eff.mental)
		self:removeTemporaryValue("combat_spellresist", eff.spell)
		self:removeTemporaryValue("combat_physresist", eff.physical)
	end,
}

newEffect{
	name = "Recovery",
	desc = "Recovery",
	kr_name = "회복",
	long_desc = function(self, eff) return ("회복 : 매 턴마다 생명력 +%d / 치유 효율 +%d%%"):format(eff.regen, eff.heal_mod) end,
	type = "physical",
	subtype = { heal=true },
	status = "beneficial",
	parameters = { power=10 },
	on_gain = function(self, err) return "#Target1# 피해로부터 회복하기 시작합니다!", "+회복" end,
	on_lose = function(self, err) return "#Target#의 회복이 끝났습니다.", "-회복" end,
	activate = function(self, eff)
		eff.regenid = self:addTemporaryValue("life_regen", eff.regen)
		eff.healid = self:addTemporaryValue("healing_factor", eff.heal_mod / 100)
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("life_regen", eff.regenid)
		self:removeTemporaryValue("healing_factor", eff.healid)
	end,
}

newEffect{
	name = "REFLEXIVE_DODGING", image = "talents/heightened_reflexes.png",
	desc = "Reflexive Dodging",
	kr_name = "반사신경 회피",
	long_desc = function(self, eff) return ("모든 행동 속도 +%d%%"):format(eff.power * 100) end,
	type = "physical",
	subtype = { evade=true, speed=true },
	status = "beneficial",
	parameters = { power=0.1 },
	on_gain = function(self, err) return "#Target1# 빨라졌습니다.", "+반사신경 회피" end,
	on_lose = function(self, err) return "#Target1# 느려졌습니다.", "-반사신경 회피" end,
	activate = function(self, eff)
		eff.tmpid = self:addTemporaryValue("global_speed_add", eff.power)
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("global_speed_add", eff.tmpid)
	end,
}

newEffect{
	name = "WEAKENED_DEFENSES", image = "talents/exploit_weakness.png",
	desc = "Weakened Defenses",
	kr_name = "약해진 방어",
	long_desc = function(self, eff) return ("물리 저항 -%d%%"):format(eff.cur_inc) end,
	type = "physical",
	subtype = { sunder=true },
	status = "detrimental",
	parameters = { inc=1, max=5 },
	on_merge = function(self, old_eff, new_eff)
		self:removeTemporaryValue("resists", old_eff.tmpid)
		old_eff.cur_inc = math.max(old_eff.cur_inc + new_eff.inc, new_eff.max)
		old_eff.tmpid = self:addTemporaryValue("resists", {[DamageType.PHYSICAL] = old_eff.cur_inc})

		old_eff.dur = new_eff.dur
		return old_eff
	end,
	activate = function(self, eff)
		eff.cur_inc = eff.inc
		eff.tmpid = self:addTemporaryValue("resists", {
			[DamageType.PHYSICAL] = eff.inc,
		})
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("resists", eff.tmpid)
	end,
}

newEffect{
	name = "WATERS_OF_LIFE", image = "talents/waters_of_life.png",
	desc = "Waters of Life",
	kr_name = "생명의 물",
	long_desc = function(self, eff) return ("모든 질병과 중독 정화 / 정화된 양만큼 치유 효율 상승") end,
	type = "physical",
	subtype = { nature=true, heal=true },
	status = "beneficial",
	parameters = { },
	activate = function(self, eff)
		eff.poisid = self:addTemporaryValue("purify_poison", 1)
		eff.diseid = self:addTemporaryValue("purify_disease", 1)
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("purify_poison", eff.poisid)
		self:removeTemporaryValue("purify_disease", eff.diseid)
	end,
}

newEffect{
	name = "ELEMENTAL_HARMONY", image = "effects/elemental_harmony.png",
	desc = "Elemental Harmony",
	kr_name = "원소의 조화",
	long_desc = function(self, eff)
		if eff.type == DamageType.FIRE then return ("모든 행동 속도 +%d%%"):format(100 * (0.1 + eff.power / 16))
		elseif eff.type == DamageType.COLD then return ("방어도 +%d"):format(3 + eff.power *2)
		elseif eff.type == DamageType.LIGHTNING then return ("모든 능력치 +%d"):format(math.floor(eff.power))
		elseif eff.type == DamageType.ACID then return ("생명력 재생 +%0.2f%%"):format(5 + eff.power * 2)
		elseif eff.type == DamageType.NATURE then return ("전체 저항 +%d%%"):format(5 + eff.power * 1.4)
		end
	end,
	type = "physical",
	subtype = { nature=true },
	status = "beneficial",
	parameters = { },
	activate = function(self, eff)
		if eff.type == DamageType.FIRE then
			eff.tmpid = self:addTemporaryValue("global_speed_add", 0.1 + eff.power / 16)
		elseif eff.type == DamageType.COLD then
			eff.tmpid = self:addTemporaryValue("combat_armor", 3 + eff.power * 2)
		elseif eff.type == DamageType.LIGHTNING then
			eff.tmpid = self:addTemporaryValue("inc_stats",
			{
				[Stats.STAT_STR] = math.floor(eff.power),
				[Stats.STAT_DEX] = math.floor(eff.power),
				[Stats.STAT_MAG] = math.floor(eff.power),
				[Stats.STAT_WIL] = math.floor(eff.power),
				[Stats.STAT_CUN] = math.floor(eff.power),
				[Stats.STAT_CON] = math.floor(eff.power),
			})
		elseif eff.type == DamageType.ACID then
			eff.tmpid = self:addTemporaryValue("life_regen", 5 + eff.power * 2)
		elseif eff.type == DamageType.NATURE then
			eff.tmpid = self:addTemporaryValue("resists", {all=5 + eff.power * 1.4})
		end
	end,
	deactivate = function(self, eff)
		if eff.type == DamageType.FIRE then
			self:removeTemporaryValue("global_speed_add", eff.tmpid)
		elseif eff.type == DamageType.COLD then
			self:removeTemporaryValue("combat_armor", eff.tmpid)
		elseif eff.type == DamageType.LIGHTNING then
			self:removeTemporaryValue("inc_stats", eff.tmpid)
		elseif eff.type == DamageType.ACID then
			self:removeTemporaryValue("life_regen", eff.tmpid)
		elseif eff.type == DamageType.NATURE then
			self:removeTemporaryValue("resists", eff.tmpid)
		end
	end,
}

newEffect{
	name = "HEALING_NEXUS", image = "talents/healing_nexus.png",
	desc = "Healing Nexus",
	kr_name = "회복력 강탈",
	long_desc = function(self, eff) return ("모든 생명력 회복량의 %d%%가 %s에게로 이동"):format(eff.pct * 100, (eff.src.kr_name or eff.src.name), eff.src.name) end, --@@ 변수 순서 조정
	type = "physical",
	subtype = { nature=true, heal=true },
	status = "detrimental",
	parameters = { pct = 1 },
	activate = function(self, eff)
	end,
	deactivate = function(self, eff)
	end,
}

newEffect{
	name = "PSIONIC_BIND", image = "effects/psionic_bind.png",
	desc = "Immobilized",
	kr_name = "이동불능",
	long_desc = function(self, eff) return "염동력에 의해 이동 불가능" end,
	type = "physical",
	subtype = { telekinesis=true, pin=true },
	status = "detrimental",
	parameters = {},
	on_gain = function(self, err) return "#F53CBE##Target1# 염동력에 의해 붙잡혔습니다!", "+마비" end,
	on_lose = function(self, err) return "#Target1# 염동력에서 풀려나왔습니다.", "-마비" end,
	activate = function(self, eff)
		--eff.particle = self:addParticles(Particles.new("gloom_stunned", 1))
		eff.tmpid = self:addTemporaryValue("never_move", 1)
	end,
	deactivate = function(self, eff)
		--self:removeParticles(eff.particle)
		self:removeTemporaryValue("never_move", eff.tmpid)
	end,
}

newEffect{
	name = "IMPLODING", image = "talents/implode.png",
	desc = "Slow",
	kr_name = "감속",
	long_desc = function(self, eff) return ("모든 행동 속도 -50%% / 매 턴마다 물리 피해 %d"):format( eff.power) end,
	type = "physical",
	subtype = { telekinesis=true, slow=true },
	status = "detrimental",
	parameters = {},
	on_gain = function(self, err) return "#Target1# 힘에 의해 짓눌렸습니다.", "+내파" end,
	on_lose = function(self, err) return "#Target3# 짓누르던 힘이 사라졌습니다.", "-내파" end,
	activate = function(self, eff)
		eff.tmpid = self:addTemporaryValue("global_speed_add", -0.5)
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("global_speed_add", eff.tmpid)
	end,
	on_timeout = function(self, eff)
		DamageType:get(DamageType.PHYSICAL).projector(eff.src, self.x, self.y, DamageType.PHYSICAL, eff.power)
	end,
}

newEffect{
	name = "FREE_ACTION", image = "effects/free_action.png",
	desc = "Free Action",
	kr_name = "자유로운 행동",
	long_desc = function(self, eff) return ("기절 면역력 +%d%% / 혼절 완전 면역 / 속박 완전 면역"):format(eff.power * 100) end,
	type = "physical",
	subtype = { nature=true },
	status = "beneficial",
	parameters = { power=1 },
	on_gain = function(self, err) return "#Target#의 움직임이 완전히 자유로워집니다.", "+자유로운 행동" end,
	on_lose = function(self, err) return "#Target#의 움직임이 조금 덜 자유로워졌습니다.", "-자유로운 행동" end,
	activate = function(self, eff)
		eff.stun = self:addTemporaryValue("stun_immune", eff.power)
		eff.daze = self:addTemporaryValue("daze_immune", eff.power)
		eff.pin = self:addTemporaryValue("pin_immune", eff.power)
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("stun_immune", eff.stun)
		self:removeTemporaryValue("daze_immune", eff.daze)
		self:removeTemporaryValue("pin_immune", eff.pin)
	end,
}

newEffect{
	name = "ADRENALINE_SURGE", image = "talents/adrenaline_surge.png",
	desc = "Adrenaline Surge",
	kr_name = "아드레날린 쇄도",
	long_desc = function(self, eff) return ("공격시 피해량 +%d / 체력 완전 소모시 체력 대신 생명력으로 기술 사용 가능"):format(eff.power) end,
	type = "physical",
	subtype = { frenzy=true },
	status = "beneficial",
	parameters = { power=10 },
	on_gain = function(self, err) return "#Target#의 아드레날린이 쇄도합니다." end,
	on_lose = function(self, err) return "#Target#의 아드레날린이 정상적으로 돌아왔습니다." end,
	activate = function(self, eff)
		eff.tmpid = self:addTemporaryValue("combat_dam", eff.power)
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("combat_dam", eff.tmpid)
	end,
}

newEffect{
	name = "BLINDSIDE_BONUS", image = "talents/blindside.png",
	desc = "Blindside Bonus",
	kr_name = "습격 보너스",
	long_desc = function(self, eff) return ("시야에서 사라짐 : 회피도 +%d"):format(eff.defenseChange) end,
	type = "physical",
	subtype = { evade=true },
	status = "beneficial",
	parameters = { defenseChange=10 },
	activate = function(self, eff)
		eff.defenseChangeId = self:addTemporaryValue("combat_def", eff.defenseChange)
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("combat_def", eff.defenseChangeId)
	end,
}

newEffect{
	name = "OFFBALANCE",
	desc = "Off-balance",
	kr_name = "불균형",
	long_desc = function(self, eff) return ("불균형 : 모든 행동 속도 -15%") end,
	type = "physical",
	subtype = { ["cross tier"]=true },
	status = "detrimental",
	parameters = {power = 1},
	on_gain = function(self, err) return nil, "+불균형" end,
	on_lose = function(self, err) return nil, "-불균형" end,
	activate = function(self, eff)
		eff.speedid = self:addTemporaryValue("global_speed_add", -0.15)
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("global_speed_add", eff.speedid)
	end,
}

newEffect{
	name = "OFFGUARD",
	desc = "Off-guard", image = "talents/precise_strikes.png",
	kr_name = "방어 해제",
	long_desc = function(self, eff) return ("방어 해제 : 물리 치명타에 맞을 확률 +10% / 물리 치명타 피해 +10%") end,
	type = "physical",
	subtype = { ["cross tier"]=true },
	status = "detrimental",
	parameters = {power = 1},
	on_gain = function(self, err) return nil, "+방어 해제" end,
	on_lose = function(self, err) return nil, "-방어 해제" end,
	activate = function(self, eff)
		eff.crit_vuln = self:addTemporaryValue("combat_crit_vulnerable", 10) -- increases chance to be crit
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("combat_crit_vulnerable", eff.crit_vuln)
	end,
}

newEffect{
	name = "SLOW_MOVE",
	desc = "Slow movement", image = "talents/slow.png",
	kr_name = "느린 이동",
	long_desc = function(self, eff) return ("이동 속도 -%d%%"):format(eff.power*100) end,
	type = "physical",
	subtype = { nature=true },
	status = "detrimental",
	parameters = {power = 1},
	on_gain = function(self, err) return nil, "+느린 이동" end,
	on_lose = function(self, err) return nil, "-느린 이동" end,
	activate = function(self, eff)
		eff.speedid = self:addTemporaryValue("movement_speed", -eff.power)
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("movement_speed", eff.speedid)
	end,
}

newEffect{
	name = "WEAKENED",
	desc = "Weakened", image = "talents/ruined_earth.png",
	kr_name = "약화",
	long_desc = function(self, eff) return ("약화 : 모든 피해 +%d%%"):format(eff.power) end,
	type = "physical",
	subtype = { curse=true },
	status = "detrimental",
	parameters = { power=10 },
	on_gain = function(self, err) return "#Target1# 약해졌습니다." end,
	on_lose = function(self, err) return "#Target1# 다시 강해집니다." end,
	activate = function(self, eff)
		eff.incDamageId = self:addTemporaryValue("inc_damage", {all=-eff.power})
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("inc_damage", eff.incDamageId)
	end,
}

newEffect{
	name = "LOWER_FIRE_RESIST",
	desc = "Lowered fire resistance",
	kr_name = "화염 저항 저하",
	long_desc = function(self, eff) return ("화염 저항 -%d%%"):format(eff.power) end,
	type = "physical",
	subtype = { nature=true },
	status = "detrimental",
	parameters = { power=20 },
	on_gain = function(self, err) return "#Target1# 불에 약해졌습니다.", "+화염 저항 저하" end,
	on_lose = function(self, err) return "#Target1# 불에 강해졌습니다.", "-화염 저항 저하" end,
	activate = function(self, eff)
		eff.pid = self:addTemporaryValue("resists", {[DamageType.FIRE]=-eff.power})
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("resists", eff.pid)
	end,
}
newEffect{
	name = "LOWER_COLD_RESIST",
	desc = "Lowered cold resistance",
	kr_name = "냉기 저항 저하",
	long_desc = function(self, eff) return ("냉기 저항 -%d%%"):format(eff.power) end,
	type = "physical",
	subtype = { nature=true },
	status = "detrimental",
	parameters = { power=20 },
	on_gain = function(self, err) return "#Target1# 냉기에 약해졌습니다.", "+냉기 저항 저하" end,
	on_lose = function(self, err) return "#Target1# 냉기에 강해졌습니다.", "-냉기 저항 저하" end,
	activate = function(self, eff)
		eff.pid = self:addTemporaryValue("resists", {[DamageType.COLD]=-eff.power})
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("resists", eff.pid)
	end,
}
newEffect{
	name = "LOWER_NATURE_RESIST",
	desc = "Lowered nature resistance",
	kr_name = "자연 저항 저하",
	long_desc = function(self, eff) return ("자연 저항 -%d%%"):format(eff.power) end,
	type = "physical",
	subtype = { nature=true },
	status = "detrimental",
	parameters = { power=20 },
	on_gain = function(self, err) return "#Target1# 자연의 힘에 약해졌습니다.", "+자연 저항 저하" end,
	on_lose = function(self, err) return "#Target1# 자연의 힘에 강해졌습니다.", "-자연 저항 저하" end,
	activate = function(self, eff)
		eff.pid = self:addTemporaryValue("resists", {[DamageType.NATURE]=-eff.power})
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("resists", eff.pid)
	end,
}
newEffect{
	name = "LOWER_PHYSICAL_RESIST",
	desc = "Lowered physical resistance",
	kr_name = "물리 저항 저하",
	long_desc = function(self, eff) return ("물리 저항 -%d%%"):format(eff.power) end,
	type = "physical",
	subtype = { nature=true },
	status = "detrimental",
	parameters = { power=20 },
	on_gain = function(self, err) return "#Target1# 물리력에 약해졌습니다.", "+물리 저항 저하" end,
	on_lose = function(self, err) return "#Target1# 물리력에 강해졌습니다.", "-물리 저항 저하" end,
	activate = function(self, eff)
		eff.pid = self:addTemporaryValue("resists", {[DamageType.PHYSICAL]=-eff.power})
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("resists", eff.pid)
	end,
}

newEffect{
	name = "CURSED_WOUND", image = "talents/slash.png",
	desc = "Cursed Wound",
	kr_name = "저주받은 상처",
	long_desc = function(self, eff) return ("저주받은 상처 : 치유 효율 -%d%%"):format(-eff.healFactorChange * 100) end,
	type = "physical",
	subtype = { wound=true }, no_ct_effect = true,
	status = "detrimental",
	parameters = { healFactorChange=-0.1 },
	on_gain = function(self, err) return "#Target#에게 저주받은 상처가 생겼습니다!", "+저주받은 상처" end,
	on_lose = function(self, err) return "#Target#의 저주받은 상처가 사라졌습니다.", "-저주받은 상처" end,
	activate = function(self, eff)
		eff.healFactorId = self:addTemporaryValue("healing_factor", eff.healFactorChange)
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("healing_factor", eff.healFactorId)
	end,
	on_merge = function(self, old_eff, new_eff)
		-- add the remaining healing reduction spread out over the new duration
		old_eff.healFactorChange = math.max(-0.75, (old_eff.healFactorChange / old_eff.totalDuration) * old_eff.dur + new_eff.healFactorChange)
		old_eff.dur = math.max(old_eff.dur, new_eff.dur)

		self:removeTemporaryValue("healing_factor", old_eff.healFactorId)
		old_eff.healFactorId = self:addTemporaryValue("healing_factor", old_eff.healFactorChange)
		game.logSeen(self, "%s의 저주받은 상처가 벌어졌습니다!", (self.kr_name or self.name):capitalize())

		return old_eff
	end,
}

newEffect{
	name = "LUMINESCENCE",
	desc = "Luminescence ", image = "talents/infusion__sun.png",
	kr_name = "발광",
	long_desc = function(self, eff) return ("발광 : 은신력 -%d"):format(eff.power) end,
	type = "physical",
	subtype = { nature=true, light=true },
	status = "detrimental",
	parameters = { power=20 },
	on_gain = function(self, err) return "#Target#의 몸이 발광하기 시작합니다.", "+발광" end,
	on_lose = function(self, err) return "#Target#의 몸이 더이상 발광하지 않습니다.", "-발광" end,
	activate = function(self, eff)
		eff.stealthid = self:addTemporaryValue("inc_stealth", -eff.power)
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("inc_stealth", eff.stealthid)
	end,
}

newEffect{
	name = "SPELL_DISRUPTION", image = "talents/mana_clash.png",
	desc = "Spell Disruption",
	kr_name = "주문 방해",
	long_desc = function(self, eff) return ("주문 방해 : 주문 시전시 %d%% 확률로 실패 / 매 턴마다 %d%% 확률로 유지 중인 주문이 종료"):format(eff.cur_power, eff.cur_power) end, --@@ 변수 조정
	type = "physical",
	subtype = { antimagic=true },
	status = "detrimental",
	parameters = { power=10, max=50 },
	on_gain = function(self, err) return "#Target#의 마법이 방해받기 시작합니다." end,
	on_lose = function(self, err) return "#Target#의 마법이 더이상 방해받지 않습니다." end,
	on_merge = function(self, old_eff, new_eff)
		self:removeTemporaryValue("spell_failure", old_eff.tmpid)
		old_eff.cur_power = math.min(old_eff.cur_power + new_eff.power, new_eff.max)
		old_eff.tmpid = self:addTemporaryValue("spell_failure", old_eff.cur_power)

		old_eff.dur = new_eff.dur
		return old_eff
	end,
	activate = function(self, eff)
		eff.cur_power = eff.power
		eff.tmpid = self:addTemporaryValue("spell_failure", eff.power)
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("spell_failure", eff.tmpid)
	end,
}

newEffect{
	name = "RESONANCE", image = "talents/alchemist_protection.png",
	desc = "Resonance",
	kr_name = "공진",
	long_desc = function(self, eff) return ("%s 공격시 피해량 +%d%%"):format((DamageType:get(eff.damtype).kr_name or DamageType:get(eff.damtype).name), eff.dam) end, --@@ 변수 순서 조정
	type = "physical",
	subtype = { nature=true },
	status = "beneficial",
	parameters = { dam=10, damtype=DamageType.ARCANE },
	on_gain = function(self, err) return "#Target1# 피해와 공진하기 시작합니다.", "+공진" end,
	on_lose = function(self, err) return "#Target#의 공진이 멈췄습니다.", "-공진" end,
	activate = function(self, eff)
		eff.tmpid = self:addTemporaryValue("inc_damage", {[eff.damtype]=eff.dam})
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("inc_damage", eff.tmpid)
	end,
}

newEffect{
	name = "THORN_GRAB", image = "talents/thorn_grab.png",
	desc = "Thorn Grab",
	kr_name = "가시덩굴",
	long_desc = function(self, eff) return ("가시덩굴에 휘감김 : 매 턴마다 자연 피해 %d / 모든 행동 속도 -%d%%"):format(eff.dam, eff.speed*100) end,
	type = "physical",
	subtype = { nature=true },
	status = "detrimental",
	parameters = { dam=10, speed=20 },
	activate = function(self, eff)
		eff.tmpid = self:addTemporaryValue("global_speed_add", -eff.speed)
	end,
	on_timeout = function(self, eff)
		DamageType:get(DamageType.NATURE).projector(eff.src or self, self.x, self.y, DamageType.NATURE, eff.dam)
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("global_speed_add", eff.tmpid)
	end,
}

newEffect{
	name = "LEAVES_COVER", image = "talents/leaves_tide.png",
	desc = "Leaves Cover",
	kr_name = "잎사귀 덮개",
	long_desc = function(self, eff) return ("잎사귀 덮개 : %d%% 확률로 피해 무효화"):format(eff.power) end,
	type = "physical",
	subtype = { nature=true },
	status = "beneficial",
	parameters = { power=10 },
	on_gain = function(self, err) return "#Target1# 두꺼운 잎사귀들로 보호받습니다.", "+잎사귀 덮개" end,
	on_lose = function(self, err) return "#Target3# 뒤덮던 잎사귀가 흩어졌습니다.", "-잎사귀 덮개" end,
	activate = function(self, eff)
		eff.tmpid = self:addTemporaryValue("cancel_damage_chance", eff.power)
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("cancel_damage_chance", eff.tmpid)
	end,
}

newEffect{
	name = "BLOCKING", image = "talents/block.png",
	desc = "Blocking",
	kr_name = "막기",
	long_desc = function(self, eff) return ("막을 수 있는 공격의 피해량을 %d 까지 막아냄"):format(eff.power) end,
	type = "physical",
	subtype = { tactic=true },
	status = "beneficial",
	parameters = { nb=1 },
	on_gain = function(self, eff) return nil, nil end,
	on_lose = function(self, eff) return nil, nil end,
	do_block = function(type, dam, eff, self, src)
		local dur_inc = 0
		local crit_inc = 0
		local nb = 1
		if self:knowTalent(self.T_RIPOSTE) then
			local t = self:getTalentFromId(self.T_RIPOSTE)
			dur_inc = t.getDurInc(self, t)
			crit_inc = t.getCritInc(self, t)
			nb = nb + dur_inc
		end
		local b = false
		if eff.d_types[type] then b = true end
		if not b then return dam end
		if not self:knowTalent(self.T_ETERNAL_GUARD) then eff.dur = 0 end
		local amt = util.bound(dam - eff.power, 0, dam)
		local blocked = dam - amt
		local shield = self:hasShield()
		if shield then shield:check("on_block", self, src, type, dam, eff) end
		if eff.properties.br then self:heal(blocked) end
		if eff.properties.ref and src.life then DamageType.defaultProjector(src, src.x, src.y, type, blocked, tmp, true) end
		if (self:knowTalent(self.T_RIPOSTE) or amt == 0) and src.life then src:setEffect(src.EFF_COUNTERSTRIKE, 1 + dur_inc, {power=eff.power, no_ct_effect=true, src=self, crit_inc=crit_inc, nb=nb}) end
		return amt
	end,
	activate = function(self, eff)
		eff.tmpid = self:addTemporaryValue("block", eff.power)
		eff.def = self:addTemporaryValue("combat_def", -eff.power)
		eff.ctdef = self:addTemporaryValue("combat_def_ct", eff.power)
		if eff.properties.sp then eff.spell = self:addTemporaryValue("combat_spellresist", eff.power) end
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("block", eff.tmpid)
		self:removeTemporaryValue("combat_def", eff.def)
		self:removeTemporaryValue("combat_def_ct", eff.ctdef)
		if eff.properties.sp then self:removeTemporaryValue("combat_spellresist", eff.spell) end
	end,
}

newEffect{
	name = "COUNTERSTRIKE", image = "effects/counterstrike.png",
	desc = "Counterstrike",
	kr_name = "반격",
	long_desc = function(self, eff) return "반격 : 근접 공격에 맞으면 100% 더 큰 피해를 입음" end,
	type = "physical",
	subtype = { tactic=true },
	status = "detrimental",
	parameters = { nb=1 },
	on_gain = function(self, eff) return nil, "+반격" end,
	on_lose = function(self, eff) return nil, "-반격" end,
	activate = function(self, eff)
		eff.tmpid = self:addTemporaryValue("counterstrike", 1)
		eff.def = self:addTemporaryValue("combat_def", -eff.power)
		eff.crit = self:addTemporaryValue("combat_crit_vulnerable", eff.crit_inc or 0)
		eff.dur = math.ceil(eff.dur * (self.global_speed or 1))
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("counterstrike", eff.tmpid)
		self:removeTemporaryValue("combat_def", eff.def)
		self:removeTemporaryValue("combat_crit_vulnerable", eff.crit)
	end,
}

newEffect{
	name = "RAVAGE", image = "talents/ravage.png",
	desc = "Ravage",
	kr_name = "유린",
	long_desc = function(self, eff)
		local ravaged = "(매 턴마다)"
		if eff.ravage then ravaged = "/ 매 턴마다 좋은 물리적 상태효과 하나 제거" end
		return ("왜곡에 의해 유린당함 : 매 턴마다 물리 피해 %0.2f %s"):format(eff.dam, ravaged)
	end,
	type = "physical",
	subtype = { distortion=true },
	status = "detrimental",
	parameters = {dam=1},
	on_gain = function(self, err) return  nil, "+유린" end,
	on_lose = function(self, err) return "#Target1# 더이상 유린당하지 않습니다." or nil, "-유린" end,
	on_timeout = function(self, eff)
		if eff.ravage then
			-- Go through all physical effects
			local effs = {}
			for eff_id, p in pairs(self.tmp) do
				local e = self.tempeffect_def[eff_id]
				if e.type == "physical" and e.status == "beneficial" then
					effs[#effs+1] = {"effect", eff_id}
				end
			end

			-- Go through all sustained techniques
			for tid, act in pairs(self.sustain_talents) do
				if act then
					local talent = self:getTalentFromId(tid)
					if talent.type[1]:find("^technique/") then effs[#effs+1] = {"talent", tid} end
				end
			end

			if #effs > 0 then
				local eff = rng.tableRemove(effs)
				if eff[1] == "effect" then
					self:removeEffect(eff[2])
				else
					self:forceUseTalent(eff[2], {ignore_energy=true})
				end
			end
		end
		self:setEffect(self.EFF_DISTORTION, 2, {})
		DamageType:get(DamageType.PHYSICAL).projector(eff.src or self, self.x, self.y, DamageType.PHYSICAL, eff.dam)
	end,
	activate = function(self, eff)
		self:setEffect(self.EFF_DISTORTION, 2, {})
		if eff.ravage then
			game.logSeen(self, "#LIGHT_RED#%s 왜곡에 의해 유린당합니다!", (self.kr_name or self.name):capitalize():addJosa("가"))
			eff.dam = eff.dam * 1.5
		end
		eff.particle = self:addParticles(Particles.new("ultrashield", 1, {rm=255, rM=255, gm=180, gM=255, bm=220, bM=255, am=35, aM=90, radius=0.2, density=15, life=28, instop=40}))
	end,
	deactivate = function(self, eff)
		self:removeParticles(eff.particle)
	end,
}

newEffect{
	name = "DISABLE", image = "talents/cripple.png",
	desc = "Disable",
	kr_name = "무력화",
	long_desc = function(self, eff) return ("무력화 : 이동 속도 -%d%% / 물리력 -%d"):format(eff.speed * 100, eff.atk) end,
	type = "physical",
	subtype = { wound=true },
	status = "detrimental",
	parameters = { speed=0.15, atk=10 },
	on_gain = function(self, err) return "#Target1# 무력화되었습니다.", "+무력화" end,
	on_lose = function(self, err) return "#Target#의 힘이 돌아옵니다.", "-무력화" end,
	activate = function(self, eff)
		eff.speedid = self:addTemporaryValue("movement_speed", -eff.speed)
		eff.atkid = self:addTemporaryValue("combat_atk", -eff.atk)
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("movement_speed", eff.speedid)
		self:removeTemporaryValue("combat_atk", eff.atkid)
	end,
}

newEffect{
	name = "ANGUISH", image = "talents/agony.png",
	desc = "Anguish",
	kr_name = "고뇌",
	long_desc = function(self, eff) return ("고뇌 : 전술적 행동 불가능 / 의지 -%d / 교활함 -%d"):format(eff.will, eff.cun) end,
	type = "physical",
	subtype = { wound=true },
	status = "detrimental",
	parameters = { will=5, cun=5 },
	on_gain = function(self, err) return "#Target1# 고뇌에 빠집니다.", "+고뇌" end,
	on_lose = function(self, err) return "#Target#의 고뇌가 사라졌습니다.", "-고뇌" end,
	activate = function(self, eff)
		eff.sid = self:addTemporaryValue("inc_stats", {[Stats.STAT_WIL]=-eff.will, [Stats.STAT_CUN]=-eff.cun})
--		if self.ai_state then eff.ai = self:addTemporaryValue("ai_state", {forbid_tactical=1}) end
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("inc_stats", eff.sid)
--		if eff.ai then self:removeTemporaryValue("ai_state", eff.ai) end
	end,
}

newEffect{
	name = "FAST_AS_LIGHTNING", image = "talents/fast_as_lightning.png",
	desc = "Fast As Lightning",
	kr_name = "번개보다 빠르게",
	long_desc = function(self, eff) return ("두 턴 이상 같은 방향으로 움직이면, 장애물 통과 가능"):format() end,
	type = "physical",
	subtype = { speed=true },
	status = "beneficial",
	parameters = { },
	on_merge = function(self, old_eff, new_eff)
		return old_eff
	end,
	on_gain = function(self, err) return "#Target1# 빨라졌습니다.", "+번개보다 빠르게" end,
	on_lose = function(self, err) return "#Target1# 느려졌습니다.", "-번개보다 빠르게" end,
	activate = function(self, eff)
	end,
	deactivate = function(self, eff)
		if eff.particle then
			self:removeParticles(eff.particle)
		end
	end,
}

newEffect{
	name = "ELEMENTAL_SURGE_NATURE", image = "talents/elemental_surge.png",
	desc = "Elemental Surge: Nature",
	kr_name = "속성 고조 : 자연",
	long_desc = function(self, eff) return ("나쁜 물리적 상태이상 효과에 완전 면역") end,
	type = "physical",
	subtype = { status=true },
	status = "beneficial",
	parameters = { },
	activate = function(self, eff)
		self:effectTemporaryValue(eff, "spell_negative_status_effect_immune", 1)
	end,
}

newEffect{
	name = "STEAMROLLER", image = "talents/steamroller.png",
	desc = "Steamroller",
	kr_name = "강압됨",
	long_desc = function(self, eff) return ("사망시 강압 사용자의 '돌진' 기술 재사용 대기시간 초기화") end,
	type = "physical",
	subtype = { status=true },
	status = "detrimental",
	parameters = { },
	activate = function(self, eff)
		self.reset_rush_on_death = eff.src
	end,
	deactivate = function(self, eff)
		self.reset_rush_on_death = nil
	end,
}


newEffect{
	name = "STEAMROLLER_USER", image = "talents/steamroller.png",
	desc = "Steamroller",
	kr_name = "강압",
	long_desc = function(self, eff) return ("공격시 피해량 +%d%%"):format(eff.buff) end,
	type = "physical",
	subtype = { status=true },
	status = "beneficial",
	parameters = { buff=20 },
	on_merge = function(self, old_eff, new_eff)
		new_eff.buff = math.min(100, old_eff.buff + new_eff.buff)
		self:removeTemporaryValue("inc_damage", old_eff.buffid)
		new_eff.buffid = self:addTemporaryValue("inc_damage", {all=new_eff.buff})
		return new_eff
	end,
	activate = function(self, eff)
		eff.buffid = self:addTemporaryValue("inc_damage", {all=eff.buff})
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("inc_damage", eff.buffid)
	end,
}

newEffect{
	name = "SPINE_OF_THE_WORLD", image = "talents/spine_of_the_world.png",
	desc = "Spine of the World",
	kr_name = "세계 최강의 척추",
	long_desc = function(self, eff) return ("나쁜 물리적 생태이상 효과에 완전 면역") end,
	type = "physical",
	subtype = { status=true },
	status = "beneficial",
	parameters = { },
	on_gain = function(self, err) return "#Target1# 물리 효과에 강해졌습니다.", "+세계 최강의 척추" end,
	on_lose = function(self, err) return "#Target1# 물리 효과에 약해졌습니다.", "-세계 최강의 척추" end,
	activate = function(self, eff)
		self:effectTemporaryValue(eff, "physical_negative_status_effect_immune", 1)
	end,
}

newEffect{
	name = "FUNGAL_BLOOD", image = "talents/fungal_blood.png",
	desc = "Fungal Blood",
	kr_name = "미생물 혈액",
	long_desc = function(self, eff) return ("%d 미생물 수치를 치료에 사용"):format(eff.power) end,
	type = "physical",
	subtype = { heal=true },
	status = "beneficial",
	parameters = { power = 10 },
	on_gain = function(self, err) return nil, "+균성 혈액" end,
	on_lose = function(self, err) return nil, "-균성 혈액" end,
	on_merge = function(self, old_eff, new_eff)
		new_eff.power = new_eff.power + old_eff.power
		return new_eff
	end,
	on_timeout = function(self, eff)
		eff.power = math.max(0, eff.power - 10)
	end,
}

newEffect{
	name = "MUCUS", image = "talents/mucus.png",
	desc = "Mucus",
	kr_name = "점액",
	long_desc = function(self, eff) return ("지나간 장소에 점액 분출"):format() end,
	type = "physical",
	subtype = { mucus=true },
	status = "beneficial",
	parameters = { },
	on_gain = function(self, err) return nil, "+Mucus" end,
	on_lose = function(self, err) return nil, "-Mucus" end,
	on_timeout = function(self, eff)
		self:callTalent(self.T_MUCUS, nil, self.x, self.y, self:getTalentLevel(self.T_MUCUS) >=4 and 1 or 0)
	end,
}

newEffect{
	name = "CORROSIVE_NATURE", image = "talents/corrosive_nature.png",
	desc = "Corrosive Nature",
	kr_name = "부식성 자연",
	long_desc = function(self, eff) return ("산성 저항 -%d%%"):format(eff.power) end,
	type = "physical",
	subtype = { nature=true, acid=true },
	status = "detrimental",
	parameters = { power=10 },
	on_gain = function(self, err) return "#Target1# 산성에 취약해졌습니다.", "+부식성 자연" end,
	on_lose = function(self, err) return "#Target1# 산성에 조금 강해졌습니다.", "-부식성 자연" end,
	activate = function(self, eff)
		self:effectTemporaryValue(eff, "resists", {[DamageType.ACID]=-eff.power})
	end,
}

newEffect{
	name = "NATURAL_ACID", image = "talents/natural_acid.png",
	desc = "Natural Acid",
	kr_name = "자연적인 산성 물질",
	long_desc = function(self, eff) return ("자연 저항 -%d%%"):format(eff.power) end,
	type = "physical",
	subtype = { nature=true, acid=true },
	status = "detrimental",
	parameters = { power=10 },
	on_gain = function(self, err) return "#Target1# 자연 속성에 취약해졌습니다.", "+자연적인 산성 물질" end,
	on_lose = function(self, err) return "#Target1# 자연 속성에 조금 강해졌습니다.", "-자연적인 산성 물질" end,
	activate = function(self, eff)
		self:effectTemporaryValue(eff, "resists", {[DamageType.NATURE]=-eff.power})
	end,
}

newEffect{
	name = "CORRODE", image = "talents/blightzone.png",
	desc = "Corrode",
	kr_name = "부식",
	long_desc = function(self, eff) return ("부식 : 정확도 -%d / 방어도 -%d / 회피도 -%d"):format(eff.atk, eff.armor, eff.defense) end,
	type = "physical",
	subtype = { acid=true },
	status = "detrimental",
	parameters = { atk=5, armor=5, defense=10 }, no_ct_effect = true,
	on_gain = function(self, err) return "#Target1# 부식되었습니다." end,
	on_lose = function(self, err) return "#Target#의 부식이 사라졌습니다." end,
	activate = function(self, eff)
		self:effectTemporaryValue(eff, "combat_atk", -eff.atk)
		self:effectTemporaryValue(eff, "combat_armor", -eff.armor)
		self:effectTemporaryValue(eff, "combat_def", -eff.defense)
	end,
}

newEffect{
	name = "SLIPPERY_MOSS", image = "talents/slippery_moss.png",
	desc = "Slippery Moss",
	kr_name = "미끄러운 이끼",
	long_desc = function(self, eff) return ("미끄러운 이끼에 둘러싸임 : %d%% 확률로 기술 사용 실패"):format(eff.fail) end,
	type = "physical",
	subtype = { moss=true, nature=true },
	status = "detrimental",
	parameters = {fail=5},
	on_gain = function(self, err) return "#Target1# 미끄러운 이끼에 둘러싸였습니다!", "+미끄러운 이끼" end,
	on_lose = function(self, err) return "#Target1# 미끄러운 이끼로부터 벗어났습니다.", "-미끄러운 이끼" end,
	activate = function(self, eff)
		eff.tmpid = self:addTemporaryValue("talent_fail_chance", eff.fail)
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("talent_fail_chance", eff.tmpid)
	end,
}