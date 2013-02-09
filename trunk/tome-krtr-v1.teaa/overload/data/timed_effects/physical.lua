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

local Stats = require "engine.interface.ActorStats"
local Particles = require "engine.Particles"
local Entity = require "engine.Entity"
local Chat = require "engine.Chat"
local Map = require "engine.Map"
local Level = require "engine.Level"

newEffect{
	name = "CUT", image = "effects/cut.png",
	desc = "Bleeding",
	kr_display_name = "출혈",
	long_desc = function(self, eff) return ("피 흘리는 큰 상처로 턴당 물리 피해 %0.2f 발생."):format(eff.power) end,
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
	kr_display_name = "깊은 상처",
	long_desc = function(self, eff) return ("피 흘리는 큰 상처로 턴당 물리 피해 %0.2f 발생, 치유 증가율 %d%% 감소."):format(eff.power, eff.heal_factor) end,
	type = "physical",
	subtype = { wound=true, cut=true },
	status = "detrimental",
	parameters = {power=10, heal_factor=30},
	on_gain = function(self, err) return "#Target1# 피를 할리기 시작합니다.", "+깊은 상처" end,
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
	kr_display_name = "재생",
	long_desc = function(self, eff) return ("주변으로 생명력이 흘러 턴당 생명력 재생 %0.2f 상승."):format(eff.power) end,
	type = "physical",
	subtype = { nature=true, healing=true },
	status = "beneficial",
	parameters = { power=10 },
	on_gain = function(self, err) return "#Target#의 생명력이 빠르게 재생됩니다.", "+재생" end,
	on_lose = function(self, err) return "#Target#의 빠른 생명력 재생이 사라집니다.", "-재생" end,
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
	kr_display_name = "중독",
	long_desc = function(self, eff) return ("중독으로 턴당 자연 피해 %0.2f 발생."):format(eff.power) end,
	type = "physical",
	subtype = { poison=true, nature=true }, no_ct_effect = true,
	status = "detrimental",
	parameters = { power=10 },
	on_gain = function(self, err) return "#Target1# 중독되었습니다!", "+중독" end,
	on_lose = function(self, err) return "#Target#의 중독이 나았습니다.", "-중독" end,
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
	kr_display_name = "거미독",
	long_desc = function(self, eff) return ("중독으로 턴당 자연 피해 %0.2f 발생, 이동 불가능 (다른 행동은 가능)."):format(eff.power) end,
	type = "physical",
	subtype = { poison=true, pin=true, nature=true }, no_ct_effect = true,
	status = "detrimental",
	parameters = {power=10},
	on_gain = function(self, err) return "#Target1# 중독되어 이동할 수 없습니다!", "+거미독" end,
	on_lose = function(self, err) return "#Target#의 중독이 나았습니다.", "-거미독" end,
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
	kr_display_name = "잠식형 독",
	long_desc = function(self, eff) return ("중독으로 턴당 자연 피해 %0.2f 발생, 치유 증가율 %d%% 감소."):format(eff.power, eff.heal_factor) end,
	type = "physical",
	subtype = { poison=true, nature=true }, no_ct_effect = true,
	status = "detrimental",
	parameters = {power=10, heal_factor=30},
	on_gain = function(self, err) return "#Target1# 중독되었습니다!", "+잠식형 독" end,
	on_lose = function(self, err) return "#Target#의 중독이 나았습니다.", "-잠식형 독" end,
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
	kr_display_name = "무력형 독",
	long_desc = function(self, eff) return ("중독으로 턴당 자연 피해 %0.2f 발생, 기술 사용시 %d%% 확률로 사용 실패."):format(eff.power, eff.fail) end,
	type = "physical",
	subtype = { poison=true, nature=true }, no_ct_effect = true,
	status = "detrimental",
	parameters = {power=10, fail=5},
	on_gain = function(self, err) return "#Target1# 중독되었습니다!", "+무력형 독" end,
	on_lose = function(self, err) return "#Target#의 중독이 나았습니다.", "-무력형 독" end,
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
	kr_display_name = "마비형 독",
	long_desc = function(self, eff) return ("중독으로 턴당 자연 피해 %0.2f 발생, 공격시 모든 피해 %d%% 감소."):format(eff.power, eff.reduce) end,
	type = "physical",
	subtype = { poison=true, nature=true }, no_ct_effect = true,
	status = "detrimental",
	parameters = {power=10, reduce=5},
	on_gain = function(self, err) return "#Target1# 중독되었습니다!", "+마비형 독" end,
	on_lose = function(self, err) return "#Target#의 중독이 나았습니다.", "-마비형 독" end,
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
	kr_display_name = "석화형 독",
	long_desc = function(self, eff) return ("중독으로 턴당 자연 피해 %0.2f 발생. 해독시 %d 턴 동안 석화 효과 발생."):format(eff.power, eff.stone) end,
	type = "physical",
	subtype = { poison=true, earth=true }, no_ct_effect = true,
	status = "detrimental",
	parameters = {power=10, reduce=5},
	on_gain = function(self, err) return "#Target1# 중독되었습니다!", "+석화형 독" end,
	on_lose = function(self, err) return "#Target#의 중독이 나았습니다.", "-석화형 독" end,
	-- Damage each turn
	on_timeout = function(self, eff)
		if self:attr("purify_poison") then self:heal(eff.power)
		else DamageType:get(DamageType.NATURE).projector(eff.src, self.x, self.y, DamageType.NATURE, eff.power)
		end
	end,
	activate = function(self, eff)
	end,
	deactivate = function(self, eff)
		if self:canBe("stun") and self:canBe("stone") and self:canBe("instakill") then
			self:setEffect(self.EFF_STONED, eff.stone, {})
		end
	end,
}

newEffect{
	name = "BURNING", image = "talents/flame.png",
	desc = "Burning",
	kr_display_name = "불 붙음",
	long_desc = function(self, eff) return ("불 붙은 동안 턴당 화염 피해 %0.2f 발생."):format(eff.power) end,
	type = "physical",
	subtype = { fire=true },
	status = "detrimental",
	parameters = { power=10 },
	on_gain = function(self, err) return "#Target#에게 불이 붙었습니다!", "+불 붙음" end,
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
	kr_display_name = "화염 충격",
	long_desc = function(self, eff) return ("불 붙은 동안 턴당 화염 피해 %0.2f 발생, 공격시 피해 70%% 감소, 50%% 확률로 임의의 기술이 대기상태로 변경, 이동 속도 50%% 감소, 대기지연시간이 줄어들지 않음."):format(eff.power) end,
	type = "physical",
	subtype = { fire=true, stun=true },
	status = "detrimental",
	parameters = {},
	on_gain = function(self, err) return "#Target1# 화염 충격으로 기절했습니다!", "+화염 충격" end,
	on_lose = function(self, err) return "#Target1# 기절에서 깼습니다.", "-화염 충격" end,
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
	kr_display_name = "기절",
	long_desc = function(self, eff) return ("기절한 동안 공격시 피해 70%% 감소, 50%% 확률로 임의의 기술이 대기상태로 변경, 이동 속도 50%% 감소, 대기지연시간이 줄어들지 않음."):format() end,
	type = "physical",
	subtype = { stun=true },
	status = "detrimental",
	parameters = {},
	on_gain = function(self, err) return "#Target1# 기절했습니다!", "+기절" end,
	on_lose = function(self, err) return "#Target1# 기절에서 깼습니다.", "-기절" end,
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
	kr_display_name = "무장 해제",
	long_desc = function(self, eff) return "무장 해제된 동안 무기를 쥘 수 없음." end,
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
	kr_display_name = "목막힘",
	long_desc = function(self, eff) return ("목이 막혀 있는 동안 이동 불가능, 질식 (턴당 호흡 %0.2f 감소)."):format(eff.power) end,
	type = "physical",
	subtype = { grapple=true, pin=true },
	status = "detrimental",
	parameters = {power=10},
	on_gain = function(self, err) return "#Target#의 목이 막혔습니다!", "+목막힘" end,
	on_lose = function(self, err) return "#Target1# 자유롭게 숨쉴수 있습니다.", "-목막힘" end,
	activate = function(self, eff)
		eff.tmpid = self:addTemporaryValue("never_move", 1)
	end,
	on_timeout = function(self, eff)
		if core.fov.distance(self.x, self.y, eff.src.x, eff.src.y) > 1 or eff.src.dead or not game.level:hasEntity(eff.src) then
			return true
		end
		self:suffocate(eff.power, eff.src, (" %s에 의해 숨막혀 죽음"):format((eff.src.kr_display_name or eff.src.name):capitalize()))
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("never_move", eff.tmpid)
	end,
}

newEffect{
	name = "DAZED", image = "effects/dazed.png",
	desc = "Dazed",
	kr_display_name = "혼절",
	long_desc = function(self, eff) return "혼절한 동안 이동 불가능. 공격시 피해, 회피도, 모든 내성, 정확도, 주문력, 정신력, 물리력 절반으로 감소. 피해를 받으면 혼절 제거." end,
	type = "physical",
	subtype = { stun=true },
	status = "detrimental",
	parameters = {},
	on_gain = function(self, err) return "#Target1# 혼절했습니다!", "+혼절" end,
	on_lose = function(self, err) return "#Target1# 혼절에서 깼습니다.", "-혼절" end,
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
	kr_display_name = "회피",
	long_desc = function(self, eff) return ("%d%% 확률로 근접 공격 회피."):format(eff.chance) end,
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
	kr_display_name = "가속",
	long_desc = function(self, eff) return ("전체 행동 속도 %d%% 증가."):format(eff.power * 100) end,
	type = "physical",
	subtype = { speed=true },
	status = "beneficial",
	parameters = { power=0.1 },
	on_gain = function(self, err) return "#Target#의 속도가 빨라집니다.", "+가속" end,
	on_lose = function(self, err) return "#Target#의 속도가 느려집니다.", "-가속" end,
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
	kr_display_name = "감속",
	long_desc = function(self, eff) return ("전체 행동 속도 %d%% 감속."):format( eff.power * 100) end,
	type = "physical",
	subtype = { slow=true },
	status = "detrimental",
	parameters = { power=0.1 },
	on_gain = function(self, err) return "#Target#의 속도가 느려집니다.", "+감속" end,
	on_lose = function(self, err) return "#Target#의 속도가 빨라집니다.", "-감속" end,
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
	kr_display_name = "실명",
	long_desc = function(self, eff) return "아무것도 보지못함." end,
	type = "physical",
	subtype = { blind=true },
	status = "detrimental",
	parameters = {},
	on_gain = function(self, err) return "#Target1# 보이지 않습니다!", "+실명" end,
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
	kr_display_name = "드워프의 체질",
	long_desc = function(self, eff) return ("피부가 암석화 되어있는 동안 방어도 %d, 물리내성 %d, 주문내성 %d 상승."):format(eff.armor, eff.physical, eff.spell) end,
	type = "physical",
	subtype = { earth=true },
	status = "beneficial",
	parameters = { armor=10, spell=10, physical=10 },
	on_gain = function(self, err) return "#Target#의 피부가 암석화됩니다." end,
	on_lose = function(self, err) return "#Target#의 피부가 정상적으로 돌아옵니다." end,
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
	kr_display_name = "단단한 피부",
	long_desc = function(self, eff) return ("피부가 피해에 반응하여 방어도 %s 상승."):format(eff.power) end,
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
	kr_display_name = "가시돋힌 피부",
	long_desc = function(self, eff) return ("피부가 피해에 반응하여 방어도 %d, 방어효율 %d%% 상승."):format(eff.ac, eff.hard) end,
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
	kr_display_name = "얼어붙은 발",
	long_desc = function(self, eff) return "발이 땅에 얼어붙어 이동 불가능 (다른 행동은 가능)." end,
	type = "physical",
	subtype = { cold=true, pin=true },
	status = "detrimental",
	parameters = {},
	on_gain = function(self, err) return "#Target#의 발이 땅에 얼어붙습니다!", "+동결" end,
	on_lose = function(self, err) return "#Target1# 녹았습니다.", "-동결" end,
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
	kr_display_name = "동결",
	long_desc = function(self, eff) return ("얼음에 갇힌 동안 방어시 모든 피해의 40%%는 얼음이 흡수하고 60%%의 피해를 입음, 회피도 무시, 공격은 얼음에게로만 가능, 새로운 나쁜 상태 효과에 면역, 공간이동 불가능, 치료 불가능. 남아있는 얼음의 지속력(HP) %d."):format(eff.hp) end,
	type = "physical", -- Frozen has some serious effects beyond just being frozen, no healing, no teleport, etc.  But it can be applied by clearly non-magical sources i.e. Ice Breath
	subtype = { cold=true, stun=true },
	status = "detrimental",
	parameters = {},
	on_gain = function(self, err) return "#Target1# 얼음에 갇혔습니다!", "+동결" end,
	on_lose = function(self, err) return "#Target1# 얼음으로부터 빠져나왔습니다.", "-동결" end,
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
	kr_display_name = "불멸의 분노",
	long_desc = function(self, eff) return ("내면의 힘을 사용하는 동안 공격시 모든 피해 %d%% 상승, 방어시 모든 피해 %d%% 감소."):format(eff.power, eff.power) end,
	type = "physical",
	subtype = { nature=true },
	status = "beneficial",
	parameters = { power=10 },
	on_gain = function(self, err) return "#Target1# 힘을 내뿜습니다." end,
	on_lose = function(self, err) return "#Target#의 힘의 오러가 사라집니다." end,
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
	kr_display_name = "등껍질 보호막",
	long_desc = function(self, eff) return ("등껍질로 뒤덮어 방어시 모든 피해 %d%% 감소."):format(eff.power) end,
	type = "physical",
	subtype = { nature=true },
	status = "beneficial",
	parameters = { power=50 },
	on_gain = function(self, err) return "#Target1# 등껍질 아래로 몸을 감쌉니다.", "+등껍질 보호막" end,
	on_lose = function(self, err) return "#Target1# 등껍질 바깥으로 벗어납니다.", "-등껍질 보호막" end,
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
	kr_display_name = "고통 억제",
	long_desc = function(self, eff) return ("고통을 무시하여 방어시 모든 피해 %d%% 감소."):format(eff.power) end,
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
	kr_display_name = "황폐의 정화",
	long_desc = function(self, eff) return ("자연의 힘이 주입된 동안 방어시 모든 황폐 피해 %d%% 감소, 주문내성 %d 상승, 질병에 면역."):format(eff.power, eff.power) end,
	type = "physical",
	subtype = { nature=true },
	status = "beneficial",
	parameters = { power=20 },
	on_gain = function(self, err) return "#Target1# 황폐화를 거부합니다!", "+정화" end,
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
	kr_display_name = "감지",
	long_desc = function(self, eff) return "인지 능력 향상으로 보이지 않는 것들을 탐지." end,
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
	kr_display_name = "영웅주의",
	long_desc = function(self, eff) return ("가장 높은 능력치 세가지를 %d 상승."):format(eff.power) end,
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
	kr_display_name = "방어구 손상",
	long_desc = function(self, eff) return ("방어구가 손상된 동안 방어도 %d 감소."):format(eff.power) end,
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
	kr_display_name = "팔 부상",
	long_desc = function(self, eff) return ("팔이 부상당한 동안 정확도 %d 감소."):format(eff.power) end,
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
	kr_display_name = "대지에 속박",
	long_desc = function(self, eff) return "대지에 속박된 동안 이동 불가능." end,
	type = "physical",
	subtype = { pin=true },
	status = "detrimental",
	parameters = {},
	on_gain = function(self, err) return "#Target1# 대지에 고정되었습니다.", "+속박" end,
	on_lose = function(self, err) return "#Target1# 속박에서 벗어납니다.", "-속박" end,
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
	kr_display_name = "강력한 일격",
	long_desc = function(self, eff) return ("공격시 피해 %d 상승."):format(eff.power) end,
	type = "physical",
	subtype = { golem=true },
	status = "beneficial",
	parameters = { power=10 },
	on_gain = function(self, err) return "#Target1# 더 위협적으로 보입니다." end,
	on_lose = function(self, err) return "#Target#의 위협이 줄어듭니다." end,
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
	kr_display_name = "장애",
	long_desc = function(self, eff) return ("장애가 발생한 동안 근접공격, 주문시전, 사고속도 %d%% 감소."):format(eff.speed*100) end,
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
	kr_display_name = "파고들기",
	long_desc = function(self, eff) return "벽 속으로 파고들기 가능." end,
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
	kr_display_name = "시야 감소",
	long_desc = function(self, eff) return ("The target's vision range is decreased by %d."):format(eff.sight) end,
	type = "physical",
	subtype = { sense=true },
	status = "detrimental",
	parameters = { sight=5 },
	on_gain = function(self, err) return "#Target# is surrounded by a thick smoke.", "+Dim Vision" end,
	on_lose = function(self, err) return "The smoke around #target# dissipate.", "-Dim Vision" end,
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
	kr_display_name = "결의",
	long_desc = function(self, eff) return ("You gain %d%% resistance against %s."):format(eff.res, DamageType:get(eff.damtype).name) end,
	type = "physical",
	subtype = { antimagic=true, nature=true },
	status = "beneficial",
	parameters = { res=10, damtype=DamageType.ARCANE },
	on_gain = function(self, err) return "#Target# attunes to the damage.", "+Resolve" end,
	on_lose = function(self, err) return "#Target# is no longer attuned.", "-Resolve" end,
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
	kr_display_name = "야생의 속도",
	long_desc = function(self, eff) return ("The movement infusion allows you to run at extreme fast pace. Any other action other than movement will cancel it. Movement is %d%% faster."):format(eff.power) end,
	type = "physical",
	subtype = { nature=true, speed=true },
	status = "beneficial",
	parameters = {power=1000},
	on_gain = function(self, err) return "#Target# prepares for the next kill!.", "+Wild Speed" end,
	on_lose = function(self, err) return "#Target# slows down.", "-Wild Speed" end,
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
	kr_display_name = "진격",
	long_desc = function(self, eff) return ("Movement is %d%% faster."):format(eff.power) end,
	type = "physical",
	subtype = { speed=true, tactic=true },
	status = "beneficial",
	parameters = {power=1000},
	on_gain = function(self, err) return "#Target# prepares for the next kill!.", "+Step Up" end,
	on_lose = function(self, err) return "#Target# slows down.", "-Step Up" end,
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
	kr_display_name = "번개의 속도",
	long_desc = function(self, eff) return ("Turn into pure lightning, moving %d%% faster. It also increases your lightning resistance by 100%% and your physical resistance by 30%%."):format(eff.power) end,
	type = "physical",
	subtype = { lightning=true, speed=true },
	status = "beneficial",
	parameters = {},
	on_gain = function(self, err) return "#Target# turns into pure lightning!.", "+Lightning Speed" end,
	on_lose = function(self, err) return "#Target# is back to normal.", "-Lightning Speed" end,
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
	kr_display_name = "용의 화염",
	long_desc = function(self, eff) return ("Dragon blood runs through your veins. You can breathe fire (or have it improved if you already could)."):format() end,
	type = "physical",
	subtype = { fire=true },
	status = "beneficial",
	parameters = {power=1},
	on_gain = function(self, err) return "#Target#'s throat seems to be burning.", "+Dragon's fire" end,
	on_lose = function(self, err) return "#Target#'s throat seems to cool down.", "-Dragon's fire" end,
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
	kr_display_name = "향상된 염동적 악력",
	long_desc = function(self, eff) return ("%d%% chance to score a secondary blow."):format(eff.chance) end,
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
	kr_display_name = "붙잡기",
	long_desc = function(self, eff) return ("The target is engaged in a grapple.  Any movement will break the effect as will some unarmed talents."):format() end,
	type = "physical",
	subtype = { grapple=true, },
	status = "beneficial",
	parameters = {},
	on_gain = function(self, err) return "#Target# is engaged in a grapple!", "+Grappling" end,
	on_lose = function(self, err) return "#Target# has released the hold.", "-Grappling" end,
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
	kr_display_name = "붙잡힘",
	long_desc = function(self, eff) return ("The target is grappled, unable to move, and has its defense and attack reduced by %d."):format(eff.power) end,
	type = "physical",
	subtype = { grapple=true, pin=true },
	status = "detrimental",
	parameters = {},
	remove_on_clone = true,
	on_gain = function(self, err) return "#Target# is grappled!", "+Grappled" end,
	on_lose = function(self, err) return "#Target# is free from the grapple.", "-Grappled" end,
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
	kr_display_name = "눌러 조르기",
	long_desc = function(self, eff) return ("The target is being crushed and suffers %d damage each turn"):format(eff.power) end,
	type = "physical",
	subtype = { grapple=true },
	status = "detrimental",
	parameters = { power=1 },
	on_gain = function(self, err) return "#Target# is being crushed.", "+Crushing Hold" end,
	on_lose = function(self, err) return "#Target# has escaped the crushing hold.", "-Crushing Hold" end,
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
	kr_display_name = "숨통 조르기",
	long_desc = function(self, eff) return ("The target is being strangled and may not cast spells and suffers %d damage each turn."):format(eff.power) end,
	type = "physical",
	subtype = { grapple=true, silence=true },
	status = "detrimental",
	parameters = { power=1 },
	on_gain = function(self, err) return "#Target# is being strangled.", "+Strangle Hold" end,
	on_lose = function(self, err) return "#Target# has escaped the strangle hold.", "-Strangle Hold" end,
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
	kr_display_name = "꺽기",
	long_desc = function(self, eff) return ("The target is maimed, reducing damage by %d and global speed by 30%%."):format(eff.power) end,
	type = "physical",
	subtype = { wound=true, slow=true },
	status = "detrimental",
	parameters = { atk=10, dam=10 },
	on_gain = function(self, err) return "#Target# is maimed.", "+Maimed" end,
	on_lose = function(self, err) return "#Target# has recovered from the maiming.", "-Maimed" end,
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
	kr_display_name = "연계",
	display_desc = function(self, eff) return eff.cur_power.." Combo" end,
	long_desc = function(self, eff) return ("The target is in the middle of a combo chain and has earned %d combo points."):format(eff.cur_power) end,
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
	kr_display_name = "방어적 전술",
	long_desc = function(self, eff) return ("The target's defense is increased by %d."):format(eff.power) end,
	type = "physical",
	subtype = { evade=true },
	status = "beneficial",
	parameters = {power = 1},
	on_gain = function(self, err) return "#Target# is moving defensively!", "+Defensive Maneuver" end,
	on_lose = function(self, err) return "#Target# isn't moving as defensively anymore.", "-Defensive Maneuver" end,
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
	kr_display_name = "흐트러진 자세",
	long_desc = function(self, eff) return ("The target is off balance and is %d%% more likely to be crit by the target that set it up.  In addition all its saves are reduced by %d."):format(eff.power, eff.power) end,
	type = "physical",
	subtype = { tactic=true },
	status = "detrimental",
	parameters = {power = 1},
	on_gain = function(self, err) return "#Target# has been set up!", "+Set Up" end,
	on_lose = function(self, err) return "#Target# has survived the set up.", "-Set Up" end,
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
	kr_display_name = "회복",
	long_desc = function(self, eff) return ("The target is recovering %d life each turn and its healing modifier has been increased by %d%%."):format(eff.regen, eff.heal_mod) end,
	type = "physical",
	subtype = { heal=true },
	status = "beneficial",
	parameters = { power=10 },
	on_gain = function(self, err) return "#Target# is recovering from the damage!", "+Recovery" end,
	on_lose = function(self, err) return "#Target# has finished recovering.", "-Recovery" end,
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
	kr_display_name = "반사적 회피",
	long_desc = function(self, eff) return ("Increases global action speed by %d%%."):format(eff.power * 100) end,
	type = "physical",
	subtype = { evade=true, speed=true },
	status = "beneficial",
	parameters = { power=0.1 },
	on_gain = function(self, err) return "#Target# speeds up.", "+Reflexive Dodging" end,
	on_lose = function(self, err) return "#Target# slows down.", "-Reflexive Dodging" end,
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
	kr_display_name = "약해진 방어",
	long_desc = function(self, eff) return ("The target's physical resistance has been reduced by %d%%."):format(eff.cur_inc) end,
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
	kr_display_name = "생명의 물",
	long_desc = function(self, eff) return ("The target purifies all diseases and poisons, turning them into healing effects.") end,
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
	kr_display_name = "정령의 조화",
	long_desc = function(self, eff)
		if eff.type == DamageType.FIRE then return ("Increases global speed by %d%%."):format(100 * (0.1 + eff.power / 16))
		elseif eff.type == DamageType.COLD then return ("Increases armour by %d."):format(3 + eff.power *2)
		elseif eff.type == DamageType.LIGHTNING then return ("Increases all stats by %d."):format(math.floor(eff.power))
		elseif eff.type == DamageType.ACID then return ("Increases life regen by %0.2f%%."):format(5 + eff.power * 2)
		elseif eff.type == DamageType.NATURE then return ("Increases all resists by %d%%."):format(5 + eff.power * 1.4)
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
	kr_display_name = "회복력 집중",
	long_desc = function(self, eff) return ("All healing done to the target is instead redirected to %s by %d%%."):format(eff.src.name, eff.pct * 100, eff.src.name) end,
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
	kr_display_name = "이동불능",
	long_desc = function(self, eff) return "Immobilized by telekinetic forces." end,
	type = "physical",
	subtype = { telekinesis=true, pin=true },
	status = "detrimental",
	parameters = {},
	on_gain = function(self, err) return "#F53CBE##Target# is bound by telekinetic forces!", "+Paralyzed" end,
	on_lose = function(self, err) return "#Target# shakes free of the telekinetic binding", "-Paralyzed" end,
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
	kr_display_name = "감속",
	long_desc = function(self, eff) return ("Slowed by 50%% and taking %d crushing damage per turn."):format( eff.power) end,
	type = "physical",
	subtype = { telekinesis=true, slow=true },
	status = "detrimental",
	parameters = {},
	on_gain = function(self, err) return "#Target# is being crushed.", "+Imploding" end,
	on_lose = function(self, err) return "#Target# shakes off the crushing forces.", "-Imploding" end,
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
	kr_display_name = "자유로운 행동",
	long_desc = function(self, eff) return ("The target gains %d%% stun, daze and pinning immunity."):format(eff.power * 100) end,
	type = "physical",
	subtype = { nature=true },
	status = "beneficial",
	parameters = { power=1 },
	on_gain = function(self, err) return "#Target# is moving freely.", "+Free Action" end,
	on_lose = function(self, err) return "#Target# is moving less freely.", "-Free Action" end,
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
	kr_display_name = "아드레날린 쇄도",
	long_desc = function(self, eff) return ("The target's combat damage is improved by %d and it an continue to fight past the point of exhaustion, supplementing life for stamina."):format(eff.power) end,
	type = "physical",
	subtype = { frenzy=true },
	status = "beneficial",
	parameters = { power=10 },
	on_gain = function(self, err) return "#Target# feels a surge of adrenaline." end,
	on_lose = function(self, err) return "#Target#'s adrenaline surge has come to an end." end,
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
	kr_display_name = "습격 보너스",
	long_desc = function(self, eff) return ("The target has appeared out of nowhere! It's defense is boosted by %d."):format(eff.defenseChange) end,
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
	kr_display_name = "불균형",
	long_desc = function(self, eff) return ("Badly off balance. Global speed is reduced by 15%.") end,
	type = "physical",
	subtype = { ["cross tier"]=true },
	status = "detrimental",
	parameters = {power = 1},
	on_gain = function(self, err) return nil, "+Off-balance" end,
	on_lose = function(self, err) return nil, "-Off-balance" end,
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
	kr_display_name = "방어 해제",
	long_desc = function(self, eff) return ("Badly off guard. Attackers gain a 10% bonus to physical critical strike chance and physical critcal strike power.") end,
	type = "physical",
	subtype = { ["cross tier"]=true },
	status = "detrimental",
	parameters = {power = 1},
	on_gain = function(self, err) return nil, "+Off-guard" end,
	on_lose = function(self, err) return nil, "-Off-guard" end,
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
	kr_display_name = "느린 이동",
	long_desc = function(self, eff) return ("Movement speed is reduced by %d%%."):format(eff.power*100) end,
	type = "physical",
	subtype = { nature=true },
	status = "detrimental",
	parameters = {power = 1},
	on_gain = function(self, err) return nil, "+Slow movement" end,
	on_lose = function(self, err) return nil, "-Slow movement" end,
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
	kr_display_name = "약화",
	long_desc = function(self, eff) return ("The target has been weakened, reducing all damage inclicted by %d%%."):format(eff.power) end,
	type = "physical",
	subtype = { curse=true },
	status = "detrimental",
	parameters = { power=10 },
	on_gain = function(self, err) return "#Target# has been weakened." end,
	on_lose = function(self, err) return "#Target#'s is no longer weakened." end,
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
	kr_display_name = "화염 저항 저하",
	long_desc = function(self, eff) return ("The target fire resistance is reduced by %d%%."):format(eff.power) end,
	type = "physical",
	subtype = { nature=true },
	status = "detrimental",
	parameters = { power=20 },
	on_gain = function(self, err) return "#Target# becomes more vulnerable to fire.", "+Low. fire resist" end,
	on_lose = function(self, err) return "#Target# is less vulnerable to fire.", "-Low. fire resist" end,
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
	kr_display_name = "추위 저항 저하",
	long_desc = function(self, eff) return ("The target cold resistance is reduced by %d%%."):format(eff.power) end,
	type = "physical",
	subtype = { nature=true },
	status = "detrimental",
	parameters = { power=20 },
	on_gain = function(self, err) return "#Target# becomes more vulnerable to cold.", "+Low. cold resist" end,
	on_lose = function(self, err) return "#Target# is less vulnerable to cold.", "-Low. cold resist" end,
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
	kr_display_name = "자연 저항 저하",
	long_desc = function(self, eff) return ("The target nature resistance is reduced by %d%%."):format(eff.power) end,
	type = "physical",
	subtype = { nature=true },
	status = "detrimental",
	parameters = { power=20 },
	on_gain = function(self, err) return "#Target# becomes more vulnerable to nature.", "+Low. nature resist" end,
	on_lose = function(self, err) return "#Target# is less vulnerable to nature.", "-Low. nature resist" end,
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
	kr_display_name = "물리 저항 저하",
	long_desc = function(self, eff) return ("The target physical resistance is reduced by %d%%."):format(eff.power) end,
	type = "physical",
	subtype = { nature=true },
	status = "detrimental",
	parameters = { power=20 },
	on_gain = function(self, err) return "#Target# becomes more vulnerable to physical.", "+Low. physical resist" end,
	on_lose = function(self, err) return "#Target# is less vulnerable to physical.", "-Low. physical resist" end,
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
	kr_display_name = "저주받은 상처",
	long_desc = function(self, eff) return ("The target's has a cursed wound, reducing healing by %d%%."):format(-eff.healFactorChange * 100) end,
	type = "physical",
	subtype = { wound=true }, no_ct_effect = true,
	status = "detrimental",
	parameters = { healFactorChange=-0.1 },
	on_gain = function(self, err) return "#Target# has a cursed wound!", "+Cursed Wound" end,
	on_lose = function(self, err) return "#Target# no longer has a cursed wound.", "-Cursed Wound" end,
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
		game.logSeen(self, "%s has re-opened a cursed wound!", self.name:capitalize())

		return old_eff
	end,
}

newEffect{
	name = "LUMINESCENCE",
	desc = "Luminescence ", image = "talents/infusion__sun.png",
	kr_display_name = "발광",
	long_desc = function(self, eff) return ("The target has been revealed, reducing its stealth power by %d."):format(eff.power) end,
	type = "physical",
	subtype = { nature=true, light=true },
	status = "detrimental",
	parameters = { power=20 },
	on_gain = function(self, err) return "#Target# has been illuminated.", "+Luminescence" end,
	on_lose = function(self, err) return "#Target# is no longer illuminated.", "-Luminescence" end,
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
	kr_display_name = "주문 방해",
	long_desc = function(self, eff) return ("The target has a %d%% chance to fail any spell it casts and a chance each turn to lose spell sustains."):format(eff.cur_power) end,
	type = "physical",
	subtype = { antimagic=true },
	status = "detrimental",
	parameters = { power=10, max=50 },
	on_gain = function(self, err) return "#Target#'s magic has been disrupted." end,
	on_lose = function(self, err) return "#Target#'s is no longer disrupted." end,
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
	kr_display_name = "공진",
	long_desc = function(self, eff) return ("+%d%% %s damage."):format(eff.dam, DamageType:get(eff.damtype).name) end,
	type = "physical",
	subtype = { nature=true },
	status = "beneficial",
	parameters = { dam=10, damtype=DamageType.ARCANE },
	on_gain = function(self, err) return "#Target# resonates with the damage.", "+Resonance" end,
	on_lose = function(self, err) return "#Target# is no longer resonating.", "-Resonance" end,
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
	kr_display_name = "가시덩굴 붙잡기",
	long_desc = function(self, eff) return ("The target is encased in thorny vines, dealing %d nature damage each turn and reducing its speed by %d%%."):format(eff.dam, eff.speed*100) end,
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
	kr_display_name = "잎사귀 덮개",
	long_desc = function(self, eff) return ("%d%% chance to fully absorb any damaging actions."):format(eff.power) end,
	type = "physical",
	subtype = { nature=true },
	status = "beneficial",
	parameters = { power=10 },
	on_gain = function(self, err) return "#Target# is protected by a layer of thick leaves.", "+Leaves Cover" end,
	on_lose = function(self, err) return "#Target# cover of leaves falls apart.", "-Leaves Cover" end,
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
	kr_display_name = "막기",
	long_desc = function(self, eff) return ("Absorbs %d damage from the next blockable attack."):format(eff.power) end,
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
	kr_display_name = "반격",
	long_desc = function(self, eff) return "Vulnerable to deadly counterstrikes. Next melee attack will inflict double damage." end,
	type = "physical",
	subtype = { tactic=true },
	status = "detrimental",
	parameters = { nb=1 },
	on_gain = function(self, eff) return nil, "+Counter" end,
	on_lose = function(self, eff) return nil, "-Counter" end,
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
	kr_display_name = "유린",
	long_desc = function(self, eff)
		local ravaged = "each turn."
		if eff.ravage then ravaged = "and is losing one physical effect turn." end
		return ("The target is being ravaged by distortion, taking %0.2f physical damage %s"):format(eff.dam, ravaged)
	end,
	type = "physical",
	subtype = { distortion=true },
	status = "detrimental",
	parameters = {dam=1},
	on_gain = function(self, err) return  nil, "+Ravage" end,
	on_lose = function(self, err) return "#Target# is no longer being ravaged." or nil, "-Ravage" end,
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
			game.logSeen(self, "#LIGHT_RED#%s is being ravaged by distortion!", self.name:capitalize())
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
	kr_display_name = "부자유",
	long_desc = function(self, eff) return ("The target is disabled, reducing movement speed by %d%% and physical power by %d."):format(eff.speed * 100, eff.atk) end,
	type = "physical",
	subtype = { wound=true },
	status = "detrimental",
	parameters = { speed=0.15, atk=10 },
	on_gain = function(self, err) return "#Target# is disabled.", "+Disabled" end,
	on_lose = function(self, err) return "#Target# is not disabled anymore.", "-Disabled" end,
	activate = function(self, eff)
		eff.speedid = self:addTemporaryValue("movement_speed", -eff.speed)
		eff.atkid = self:addTemporaryValue("combat_atk", -eff.atk)
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("movement_speed", eff.speedid)
		self:removeTemporaryValue("combat_atk", eff.atk)
	end,
}

newEffect{
	name = "ANGUISH", image = "talents/agony.png",
	desc = "Anguish",
	kr_display_name = "고뇌",
	long_desc = function(self, eff) return ("The target is in extreme anguish, preventing them from making tactical decisions, and reducing Willpower by %d and Cunning by %d."):format(eff.will, eff.cun) end,
	type = "physical",
	subtype = { wound=true },
	status = "detrimental",
	parameters = { will=5, cun=5 },
	on_gain = function(self, err) return "#Target# is in anguish.", "+Anguish" end,
	on_lose = function(self, err) return "#Target# is no longer in anguish.", "-Anguish" end,
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
	kr_display_name = "번개보다 빠르게",
	long_desc = function(self, eff) return ("The target is so fast it may blink throught obstacles if moving in the same direction for over two turns."):format() end,
	type = "physical",
	subtype = { speed=true },
	status = "beneficial",
	parameters = { },
	on_merge = function(self, old_eff, new_eff)
		return old_eff
	end,
	on_gain = function(self, err) return "#Target# is speeding up.", "+Fast As Lightning" end,
	on_lose = function(self, err) return "#Target# is slowing down.", "-Fast As Lightning" end,
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
	kr_display_name = "속성 고조: 자연",
	long_desc = function(self, eff) return ("Immune to physical effects.") end,
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
	kr_display_name = "강압",
	long_desc = function(self, eff) return ("Resets Rush cooldown if killed.") end,
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
	kr_display_name = "강압",
	long_desc = function(self, eff) return ("Grants a +%d%% damage bonus."):format(eff.buff) end,
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
	kr_display_name = "세계 최강의 척추",
	long_desc = function(self, eff) return ("Immune to physical effects.") end,
	type = "physical",
	subtype = { status=true },
	status = "beneficial",
	parameters = { },
	on_gain = function(self, err) return "#Target# become imprevious to physical effects.", "+Spine of the World" end,
	on_lose = function(self, err) return "#Target# is less imprevious to physical effects.", "-Spine of the World" end,
	activate = function(self, eff)
		self:effectTemporaryValue(eff, "physical_negative_status_effect_immune", 1)
	end,
}

newEffect{
	name = "FUNGAL_BLOOD", image = "talents/fungal_blood.png",
	desc = "Fungal Blood",
	kr_display_name = "균성 혈액",
	long_desc = function(self, eff) return ("You have %d fungal energies stored. Release them to heal by using the Fungal Blood prodigy."):format(eff.power) end,
	type = "physical",
	subtype = { heal=true },
	status = "beneficial",
	parameters = { power = 10 },
	on_gain = function(self, err) return nil, "+Fungal Blood" end,
	on_lose = function(self, err) return nil, "-Fungal Blood" end,
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
	kr_display_name = "점액",
	long_desc = function(self, eff) return ("You lay mucus where you walk."):format() end,
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
	name = "MITOSIS", image = "talents/mitosis.png",
	desc = "Mitosis",
	kr_display_name = "유사분열",
	long_desc = function(self, eff) return ("You are split, both of you share the same healthpool but you gain %d%% damage reduction."):format(eff.power) end,
	type = "physical",
	subtype = { status=true },
	status = "beneficial",
	parameters = { power=10 },
	on_gain = function(self, err) return "#Target# splits.", "+Mitosis" end,
	activate = function(self, eff)
		self:effectTemporaryValue(eff, "resists", {all=eff.power})
	end,
}

newEffect{
	name = "MITOSIS_SWAP", image = "talents/mitosis_swap.png",
	desc = "Swap",
	kr_display_name = "위치 교체",
	long_desc = function(self, eff) return ("You recently swaped with your other self, boosting your damage by %d%%."):format(eff.power) end,
	type = "physical",
	subtype = { status=true },
	status = "beneficial",
	parameters = { power=10 },
	on_gain = function(self, err) return "#Target# swaps places.", "+Swap" end,
	activate = function(self, eff)
		self:effectTemporaryValue(eff, "inc_damage", {all=eff.power})
	end,
}

newEffect{
	name = "CORRODE", image = "talents/blightzone.png",
	desc = "Corrode",
	kr_display_name = "부식",
	long_desc = function(self, eff) return ("The target is corroded, reducing their accuracy by %d, their armor by %d, and their defense by %d."):format(eff.atk, eff.armor, eff.defense) end,
	type = "physical",
	subtype = { acid=true },
	status = "detrimental",
	parameters = { atk=5, armor=5, defense=10 }, no_ct_effect = true,
	on_gain = function(self, err) return "#Target# is corroded." end,
	on_lose = function(self, err) return "#Target# has shook off the effects of their corrosion." end,
	activate = function(self, eff)
		self:effectTemporaryValue(eff, "combat_atk", -eff.atk)
		self:effectTemporaryValue(eff, "combat_armor", -eff.armor)
		self:effectTemporaryValue(eff, "combat_def", -eff.defense)
	end,
}
