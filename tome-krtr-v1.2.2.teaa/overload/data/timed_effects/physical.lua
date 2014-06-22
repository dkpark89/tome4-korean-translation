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
local Particles = require "engine.Particles"
local Entity = require "engine.Entity"
local Chat = require "engine.Chat"
local Map = require "engine.Map"
local Level = require "engine.Level"

-- Item specific
newEffect{
	name = "ITEM_ANTIMAGIC_SCOURED", image = "talents/acidic_skin.png",
	desc = "Scoured",
	kr_desc = "세척",
	long_desc = function(self, eff) return ("자연적인 산성으로 세척 : 공격력 %d%% 감소."):format(eff.pct*100 or 0) end,
	type = "physical",
	subtype = { acid=true },
	status = "detrimental",
	parameters = {pct = 0.3, spell = 0, mind = 0, phys = 0, power_str = ""},
	on_gain = function(self, err) return "#Target#의 공격력이 크게 줄었습니다!" end,
	on_lose = function(self, err) return "#Target#의 공격력이 회복되었습니다." end,
	on_timeout = function(self, eff)
	end,
	activate = function(self, eff)
		self:effectTemporaryValue(eff, "scoured", 1)
	end,
	deactivate = function(self, eff)

	end,
}

newEffect{
	name = "RELENTLESS_TEMPO", image = "talents/sunder_mind.png",
	desc = "Relentless Tempo",
	kr_desc = "무자비한 전투의 흐름",
	long_desc = function(self, eff) return ("전투의 흐름에 적응 : 전투 능력치 상승\n회피도 :  %d\n공격시 전체 피해 :  %d%%\n체력 재생 :  %d\n%s"):
		format( eff.cur_defense or 0, eff.cur_damage or 0, eff.cur_stamina or 0, eff.stacks >= 5 and "전체 저항 :  20%" or "") end,
	charges = function(self, eff) return eff.stacks end,
	type = "physical",
	subtype = { tempo=true },
	status = "beneficial",
	on_gain = function(self, err) return "#Target1# 전투의 흐름에 익숙해집니다.", "+전투적응" end,
	on_lose = function(self, err) return "#Target1# 전투의 흐름에서 벗어납니다.", "-전투적응" end,
	parameters = { stamina = 0, defense = 0, damage = 0, stacks = 0, resists = 0 },
	on_merge = function(self, old_eff, new_eff)
		old_eff.dur =3

		if old_eff.stacks >= 5 then
			if old_eff.resists ~= 20 then
				old_eff.resists = 20
				old_eff.resid = self:addTemporaryValue("resists", {all=old_eff.resists})
			end
			return old_eff
		end

		old_eff.stacks = old_eff.stacks + 1

		self:removeTemporaryValue("stamina_regen", old_eff.staminaid)
		self:removeTemporaryValue("combat_def", old_eff.defenseid)
		self:removeTemporaryValue("inc_damage", old_eff.damageid)

		old_eff.cur_stamina = old_eff.cur_stamina + new_eff.stamina
		old_eff.cur_defense = old_eff.cur_defense + new_eff.defense
		old_eff.cur_damage = old_eff.cur_damage + new_eff.damage

		old_eff.staminaid = self:addTemporaryValue("stamina_regen", old_eff.cur_stamina)
		old_eff.defenseid = self:addTemporaryValue("combat_def", old_eff.cur_defense)
		old_eff.damageid = self:addTemporaryValue("inc_damage", {all = old_eff.cur_damage})

		return old_eff
	end,
	activate = function(self, eff)
		eff.stacks = 1
		eff.cur_stamina = eff.stamina
		eff.cur_defense = eff.defense
		eff.cur_damage = eff.damage

		eff.staminaid = self:addTemporaryValue("stamina_regen", eff.cur_stamina)
		eff.defenseid = self:addTemporaryValue("combat_def", eff.cur_defense)
		eff.damageid = self:addTemporaryValue("inc_damage", {all = eff.cur_damage})
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("stamina_regen", eff.staminaid)
		self:removeTemporaryValue("combat_def", eff.defenseid)
		self:removeTemporaryValue("inc_damage", eff.damageid)
		if eff.resid then self:removeTemporaryValue("resists", eff.resid) end
	end,
}


newEffect{
	name = "DELIRIOUS_CONCUSSION", image = "talents/slippery_moss.png",
	desc = "Concussion",
	kr_desc = "뇌진탕",
	long_desc = function(self, eff) return ("사고 방해 : 기술 사용 실패 유발."):format() end,
	type = "physical",
	subtype = { concussion=true },
	status = "detrimental",
	parameters = {},
	on_gain = function(self, err) return "#Target#의 두뇌가 제대로 작동하지 않습니다!", "+뇌진탕" end,
	on_lose = function(self, err) return "#Target1# 집중력을 되찾았습니다.", "-뇌진탕" end,
	activate = function(self, eff)
		eff.tmpid = self:addTemporaryValue("talent_fail_chance", 100)
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("talent_fail_chance", eff.tmpid)
	end,
}



newEffect{
	name = "CUT", image = "effects/cut.png",
	desc = "Bleeding",
	kr_desc = "출혈",
	long_desc = function(self, eff) return ("출혈상 : 매 턴마다 물리 피해 %0.2f"):format(eff.power) end,
	type = "physical",
	subtype = { wound=true, cut=true, bleed=true },
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
	activate = function(self, eff)
		if eff.src and eff.src:knowTalent(self.T_BLOODY_BUTCHER) then
			local t = eff.src:getTalentFromId(eff.src.T_BLOODY_BUTCHER)
			local resist = math.min(t.getResist(eff.src, t), math.max(0, self:combatGetResist(DamageType.PHYSICAL)))
			self:effectTemporaryValue(eff, "resists", {[DamageType.PHYSICAL] = -resist})
		end
	end,
	on_timeout = function(self, eff)
		DamageType:get(DamageType.PHYSICAL).projector(eff.src or self, self.x, self.y, DamageType.PHYSICAL, eff.power)
	end,
}

newEffect{
	name = "DEEP_WOUND", image = "talents/bleeding_edge.png",
	desc = "Deep Wound",
	kr_desc = "깊은 상처",
	long_desc = function(self, eff) return ("깊은 상처 : 매 턴마다 물리 피해 %0.2f / 치유 효율 -%d%%"):format(eff.power, eff.heal_factor) end,
	type = "physical",
	subtype = { wound=true, cut=true, bleed=true },
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
	kr_desc = "재생",
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

		if core.shader.active(4) then
			eff.particle1 = self:addParticles(Particles.new("shader_shield", 1, {toback=true,  size_factor=1.5, y=-0.3, img="healarcane"}, {type="healing", time_factor=4000, noup=2.0, circleColor={0,0,0,0}, beamsCount=9}))
			eff.particle2 = self:addParticles(Particles.new("shader_shield", 1, {toback=false, size_factor=1.5, y=-0.3, img="healarcane"}, {type="healing", time_factor=4000, noup=1.0, circleColor={0,0,0,0}, beamsCount=9}))
		end

		if self:knowTalent(self.T_ANCESTRAL_LIFE) and not self:attr("disable_ancestral_life") then
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
		self:removeParticles(eff.particle1)
		self:removeParticles(eff.particle2)
		self:removeTemporaryValue("life_regen", eff.tmpid)
	end,
}

newEffect{
	name = "POISONED", image = "effects/poisoned.png",
	desc = "Poison",
	kr_desc = "중독",
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
		if self:attr("purify_poison") then self:heal(eff.power, eff.src)
		else DamageType:get(DamageType.NATURE).projector(eff.src, self.x, self.y, DamageType.NATURE, eff.power)
		end
	end,
}

newEffect{
	name = "SPYDRIC_POISON", image = "effects/spydric_poison.png",
	desc = "Spydric Poison",
	kr_desc = "거미독",
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
	-- There are situations this matters, such as copyEffect
	on_merge = function(self, old_eff, new_eff)
		old_eff.dur = math.max(old_eff.dur, new_eff.dur)
		return old_eff
	end,
	on_timeout = function(self, eff)
		if self:attr("purify_poison") then self:heal(eff.power, eff.src)
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
	kr_desc = "잠식형 독",
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
	-- There are situations this matters, such as copyEffect
	on_merge = function(self, old_eff, new_eff)
		old_eff.dur = math.max(old_eff.dur, new_eff.dur)
		return old_eff
	end,
	on_timeout = function(self, eff)
		if self:attr("purify_poison") then self:heal(eff.power, eff.src)
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
	kr_desc = "무력형 독",
	long_desc = function(self, eff) return ("중독 : 매 턴마다 자연 피해 %0.2f / 기술 사용시 %d%% 확률로 사용 실패"):format(eff.power, eff.fail) end,
	type = "physical",
	subtype = { poison=true, nature=true }, no_ct_effect = true,
	status = "detrimental",
	parameters = {power=10, fail=5},
	on_gain = function(self, err) return "#Target1# 중독되었습니다!", "+무력형 독" end,
	on_lose = function(self, err) return "#Target#의 중독이 회복되었습니다.", "-무력형 독" end,
	-- Damage each turn
	on_timeout = function(self, eff)
		if self:attr("purify_poison") then self:heal(eff.power, eff.src)
		else DamageType:get(DamageType.NATURE).projector(eff.src, self.x, self.y, DamageType.NATURE, eff.power)
		end
	end,
	-- There are situations this matters, such as copyEffect
	on_merge = function(self, old_eff, new_eff)
		old_eff.dur = math.max(old_eff.dur, new_eff.dur)
		return old_eff
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
	kr_desc = "마비형 독",
	long_desc = function(self, eff) return ("중독 : 매 턴마다 자연 피해 %0.2f / 공격시 피해량 -%d%%"):format(eff.power, eff.reduce) end,
	type = "physical",
	subtype = { poison=true, nature=true }, no_ct_effect = true,
	status = "detrimental",
	parameters = {power=10, reduce=5},
	on_gain = function(self, err) return "#Target1# 중독되었습니다!", "+마비형 독" end,
	on_lose = function(self, err) return "#Target#의 중독이 회복되었습니다.", "-마비형 독" end,
	-- Damage each turn
	on_timeout = function(self, eff)
		if self:attr("purify_poison") then self:heal(eff.power, eff.src)
		else DamageType:get(DamageType.NATURE).projector(eff.src, self.x, self.y, DamageType.NATURE, eff.power)
		end
	end,
	-- There are situations this matters, such as copyEffect
	on_merge = function(self, old_eff, new_eff)
		old_eff.dur = math.max(old_eff.dur, new_eff.dur)
		return old_eff
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
	kr_desc = "석화형 독",
	long_desc = function(self, eff) return ("중독 : 매 턴마다 자연 피해 %0.2f / 효과 종료시 %d 턴 동안 석화"):format(eff.power, eff.stone) end,
	type = "physical",
	subtype = { poison=true, earth=true }, no_ct_effect = true,
	status = "detrimental",
	parameters = {power=10, reduce=5},
	on_gain = function(self, err) return "#Target1# 중독되었습니다!", "+석화형 독" end,
	on_lose = function(self, err) return "#Target#의 중독이 회복되었습니다.", "-석화형 독" end,
	-- Damage each turn
	on_timeout = function(self, eff)
		if self:attr("purify_poison") then self:heal(eff.power, eff.src)
		else DamageType:get(DamageType.NATURE).projector(eff.src, self.x, self.y, DamageType.NATURE, eff.power)
		end
	end,
	-- There are situations this matters, such as copyEffect
	on_merge = function(self, old_eff, new_eff)
		old_eff.dur = math.max(old_eff.dur, new_eff.dur)
		return old_eff
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
	kr_desc = "불 붙음",
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
	kr_desc = "화염 충격",
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
			if t and not self.talents_cd[tid] and t.mode == "activated" and not t.innate and util.getval(t.no_energy, self, t) ~= true then tids[#tids+1] = t end
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
	kr_desc = "기절",
	long_desc = function(self, eff) return ("기절 : 공격시 피해량 -60%% / 이동 속도 -50%% / 50%% 확률로 세가지 임의의 기술이 대기상태로 변경 / 재사용 대기시간이 줄어들지 않음"):format() end,
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
			if t and not self.talents_cd[tid] and t.mode == "activated" and not t.innate and util.getval(t.no_energy, self, t) ~= true then tids[#tids+1] = t end
		end
		for i = 1, 3 do
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
	kr_desc = "무장 해제",
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
		self:removeEffect(self.EFF_COUNTER_ATTACKING) -- Cannot parry or counterattack while disarmed
		self:removeEffect(self.EFF_DUAL_WEAPON_DEFENSE) 
		self:removeTemporaryValue("disarmed", eff.tmpid)
	end,
}

newEffect{
	name = "CONSTRICTED", image = "talents/constrict.png",
	desc = "Constricted",
	kr_desc = "목 막힘",
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
	kr_desc = "혼절",
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
	kr_desc = "회피",
	long_desc = function(self, eff) 
		return ("%d%% 확률로 근접 공격 회피"):format(eff.chance) .. ((eff.defense>0 and (" / 회피도 +%d"):format(eff.defense)) or "")  
	end,
	type = "physical",
	subtype = { evade=true },
	status = "beneficial",
	parameters = { chance=10, defense=0 },
	on_gain = function(self, err) return "#Target1# 공격 회피를 시도합니다.", "+회피" end,
	on_lose = function(self, err) return "#Target1# 더이상 공격 회피를 하지 않습니다.", "-회피" end,
	activate = function(self, eff)
		eff.tmpid = self:addTemporaryValue("evasion", eff.chance)
		eff.defid = self:addTemporaryValue("combat_def", eff.defense)
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("evasion", eff.tmpid)
		self:removeTemporaryValue("combat_def", eff.defid)
	end,
}

newEffect{
	name = "SPEED", image = "talents/shaloren_speed.png",
	desc = "Speed",
	kr_desc = "빠름", --@ '가속'은 magical.lua의 Haste에 사용해서, 여기는 '빠름'으로 사용함
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
	kr_desc = "감속",
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
	kr_desc = "실명",
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
	kr_desc = "드워프의 체질",
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
	kr_desc = "단단한 피부",
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
	kr_desc = "가시돋힌 피부",
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
	kr_desc = "얼어붙은 발",
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
	kr_desc = "빙결",
	long_desc = function(self, eff) return ("얼음덩어리에 갇힘 : 모든 피해의 40%% 는 얼음덩어리가 흡수하고, 대상은 60%% 의 피해를 입음 / 회피 불가능 / 얼음덩어리만 공격 가능 / 다른 상태이상 효과에 완전 면역 / 공간이동 불가능 / 치료 불가능\n얼음덩어리의 남은 생명력 : %d"):format(eff.hp) end,
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
		eff.ice = mod.class.Object.new{name = "Iceblock", kr_name = "얼음덩어리", type = "wall", image='npc/iceblock.png', display = ' '} -- use type Object to facilitate the combat log
		self:removeAllMOs()
		game.level.map:updateMap(self.x, self.y)

		eff.hp = eff.hp or 100
		eff.tmpid = self:addTemporaryValue("encased_in_ice", 1)
		eff.healid = self:addTemporaryValue("no_healing", 1)
		eff.moveid = self:addTemporaryValue("never_move", 1)
		eff.frozid = self:addTemporaryValue("frozen", 1)
		eff.defid = self:addTemporaryValue("combat_def", -self:combatDefenseBase()-10)
		eff.rdefid = self:addTemporaryValue("combat_def_ranged", -self:combatDefenseBase()-10)
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
	kr_desc = "영원의 분노",
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
	kr_desc = "등껍질 보호막",
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
	kr_desc = "고통 억제",
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

-- artifact wild infusion
newEffect{
	name = "PRIMAL_ATTUNEMENT", image = "talents/infusion__wild.png",
	desc = "Primal Attunement",
	kr_desc = "근원의 조율",
	long_desc = function(self, eff) return ("야생에 적응 : 전체 피해 친화 %d%% 상승."):format(eff.power) end,
	type = "physical",
	subtype = { nature=true },
	status = "beneficial",
	parameters = { power=20 },
	on_gain = function(self, err) return "#Target1# 야생에 적응했습니다.", "+근원" end,
	on_lose = function(self, err) return "#Target2# 더이상 자연과 하나가 되지 못합니다.", "-근원" end,
	activate = function(self, eff)
		eff.pid = self:addTemporaryValue("damage_affinity", {all=eff.power})
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("damage_affinity", eff.pid)
	end,
}

newEffect{
	name = "PURGE_BLIGHT", image = "talents/infusion__wild.png",
	desc = "Purge Blight",
	kr_desc = "황폐 정화",
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
	kr_desc = "감지",
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
	kr_desc = "영웅",
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
	kr_desc = "방어구 손상",
	long_desc = function(self, eff) return ("방어구와 내성 손상 : 방어도 -%d, 모든 내성 -%d"):format(eff.power, eff.power) end, --@ 변수 추가
	type = "physical",
	subtype = { sunder=true },
	status = "detrimental",
	parameters = { power=10 },
	activate = function(self, eff)
		self:effectTemporaryValue(eff, "combat_armor", -eff.power)
		self:effectTemporaryValue(eff, "combat_physresist", -eff.power)
		self:effectTemporaryValue(eff, "combat_spellresist", -eff.power)
		self:effectTemporaryValue(eff, "combat_mentalresist", -eff.power)
	end,
}

newEffect{
	name = "SUNDER_ARMS", image = "talents/sunder_arms.png",
	desc = "Sunder Arms",
	kr_desc = "무기 손상",
	long_desc = function(self, eff) return ("무기 손상 : 정확도 -%d"):format(eff.power) end,
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
	kr_desc = "대지의 속박",
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
	name = "BONE_GRAB", image = "talents/bone_grab.png",
	desc = "Pinned to the ground",
	kr_desc = "대지에 묶임",
	long_desc = function(self, eff) return "대지에 묶임 : 이동 불가능." end,
	type = "physical",
	subtype = { pin=true },
	status = "detrimental",
	parameters = {},
	on_gain = function(self, err) return "#Target1# 대지에 묶였습니다.", "+뼈의 속박" end,
	on_lose = function(self, err) return "#Target2# 더이상 대지에 묶여있지 않습니다.", "-뼈의 속박" end,
	activate = function(self, eff)
		eff.tmpid = self:addTemporaryValue("never_move", 1)

		if not self.add_displays then
			self.add_displays = { Entity.new{image='npc/bone_grab_pin.png', display=' ', display_on_seen=true } }
			eff.added_display = true
		end
		self:removeAllMOs()
		game.level.map:updateMap(self.x, self.y)
	end,
	deactivate = function(self, eff)
		if eff.added_display then self.add_displays = nil end
		self:removeAllMOs()
		game.level.map:updateMap(self.x, self.y)

		self:removeTemporaryValue("never_move", eff.tmpid)
	end,
}

newEffect{
	name = "MIGHTY_BLOWS", image = "effects/mighty_blows.png",
	desc = "Mighty Blows",
	kr_desc = "강력한 일격",
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
	kr_desc = "장애",
	long_desc = function(self, eff) return ("장애 : 근접공격 속도 -%d%% / 주문시전 속도 -%d%% / 사고속도 -%d%%"):format(eff.speed*100, eff.speed*100, eff.speed*100) end, --@ 변수 조정
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
	kr_desc = "파고들기",
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
	kr_desc = "시야 감소",
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
	kr_desc = "결의",
	long_desc = function(self, eff) return ("%s 저항 +%d%%"):format((DamageType:get(eff.damtype).kr_name or DamageType:get(eff.damtype).name), eff.res) end, --@ 변수 순서 조정
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
	kr_desc = "야생의 속도",
	long_desc = function(self, eff) return ("이동 속도 +%d%% / 이동 외의 행동시 즉시 야생의 속도 제거"):format(eff.power) end,
	type = "physical",
	subtype = { nature=true, speed=true },
	status = "beneficial",
	parameters = {power=1000},
	on_gain = function(self, err) return "#Target1# 다음번 살해 목표를 위해 준비합니다!.", "+야생의 속도" end,
	on_lose = function(self, err) return "#Target1# 느려졌습니다.", "-야생의 속도" end,
	get_fractional_percent = function(self, eff)
		local d = game.turn - eff.start_turn
		return util.bound(360 - d / eff.possible_end_turns * 360, 0, 360)
	end,
	activate = function(self, eff)
		eff.start_turn = game.turn
		eff.possible_end_turns = 10 * (eff.dur+1)
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
	name = "HUNTER_SPEED", image = "talents/infusion__movement.png",
	desc = "Hunter",
	kr_desc = "사냥꾼",
	long_desc = function(self, eff) return ("새로운 사냥감을 탐색 중 : 이동 속도 +%d%% / 이동 외의 행동시 즉시 사냥꾼 제거"):format(eff.power) end,
	type = "physical",
	subtype = { nature=true, speed=true },
	status = "beneficial",
	parameters = {power=1000},
	on_gain = function(self, err) return "#Target1# 다음 사냥감을 위한 준비를 시작합니다!.", "+사냥꾼" end,
	on_lose = function(self, err) return "#Target1# 느려졌습니다.", "-사냥꾼" end,
	get_fractional_percent = function(self, eff)
		local d = game.turn - eff.start_turn
		return util.bound(360 - d / eff.possible_end_turns * 360, 0, 360)
	end,
	activate = function(self, eff)
		eff.start_turn = game.turn
		eff.possible_end_turns = 10 * (eff.dur+1)
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
	kr_desc = "진격",
	long_desc = function(self, eff) return ("이동 속도 +%d%%"):format(eff.power) end,
	type = "physical",
	subtype = { speed=true, tactic=true },
	status = "beneficial",
	parameters = {power=1000},
	on_gain = function(self, err) return "#Target1# 다음 목표를 위해 진격합니다!.", "+진격" end,
	on_lose = function(self, err) return "#Target1# 느려졌습니다.", "-진격" end,
	get_fractional_percent = function(self, eff)
		local d = game.turn - eff.start_turn
		return util.bound(360 - d / eff.possible_end_turns * 360, 0, 360)
	end,
	activate = function(self, eff)
		eff.start_turn = game.turn
		eff.possible_end_turns = 10 * (eff.dur+1)
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
	kr_desc = "번개의 속도",
	long_desc = function(self, eff) return ("순수한 번개로 변신 : 이동 속도 +%d%% / 전기 저항 +100%% / 물리 저항 +30%%"):format(eff.power) end,
	type = "physical",
	subtype = { lightning=true, speed=true },
	status = "beneficial",
	parameters = {},
	on_gain = function(self, err) return "#Target1# 순수한 번개로 변했습니다!.", "+번개의 속도" end,
	on_lose = function(self, err) return "#Target1# 보통의 상태로 돌아왔습니다.", "-번개의 속도" end,
	get_fractional_percent = function(self, eff)
		local d = game.turn - eff.start_turn
		return util.bound(360 - d / eff.possible_end_turns * 360, 0, 360)
	end,
	activate = function(self, eff)
		eff.start_turn = game.turn
		eff.possible_end_turns = 10 * (eff.dur+1)
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
	kr_desc = "용의 화염",
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
	kr_desc = "향상된 염동적 악력",
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
	kr_desc = "붙잡기",
	long_desc = function(self, eff) return ("붙잡기 유지 : 매 턴 마다 체력 %d 소모 / 대상이 받는 모든 피해의 %d%% 만큼 %s에게 전달 / 움직이거나 특별한 맨손 기술 사용시 붙잡기 종료."):format(eff.drain, eff.sharePct*100, eff.trgt.kr_name or eff.trgt.name or "누군가") end,
	type = "physical",
	subtype = { grapple=true, },
	status = "beneficial",
	parameters = {trgt, sharePct = 0.1, drain = 0},
	on_gain = function(self, err) return "#Target1# 붙잡기 상태로 들어갑니다!", "+붙잡기" end,
	on_lose = function(self, err) return "#Target1# 붙잡고 있던 대상이 풀려났습니다.", "-붙잡기" end,
	on_timeout = function(self, eff)
		local p = eff.trgt:hasEffect(eff.trgt.EFF_GRAPPLED)
		if not p or p.src ~= self or core.fov.distance(self.x, self.y, eff.trgt.x, eff.trgt.y) > 1 or eff.trgt.dead or not game.level:hasEntity(eff.trgt) then
			self:removeEffect(self.EFF_GRAPPLING)
		else
			self:incStamina(-eff.drain)
		end
	end,
	activate = function(self, eff)
	end,
	deactivate = function(self, eff)
	end,
	callbackOnHit = function(self, eff, cb, src)
		if not src then return cb.value end
		local share = cb.value * eff.sharePct
		
		-- deal the redirected damage as physical because I don't know how to preserve the damage type in a callback
		if not self.__grapling_feedback_damage then
			self.__grapling_feedback_damage = true
			DamageType:get(DamageType.PHYSICAL).projector(self or eff.src, eff.trgt.x, eff.trgt.y, DamageType.PHYSICAL, share)
			self.__grapling_feedback_damage = nil
		end
		
		return cb.value - share
	end,
}

newEffect{
	name = "GRAPPLED", image = "talents/grab.png",
	desc = "Grappled",
	kr_desc = "붙잡힘",
	long_desc = function(self, eff) return ("붙잡힘 : 이동 불가능 / 공격 능력이 제한됨.\n#RED#침묵됨\n속박됨\n%s\n%s\n%s"):format("공격력 " .. math.ceil(eff.reduce) .. " 감소", "전체 속도 " .. eff.slow .. " 감소", "매 턴 마다 피해를 " .. math.ceil(eff.power) .. " 씩 받음" ) end,
	type = "physical",
	subtype = { grapple=true, pin=true },
	status = "detrimental",
	parameters = {silence = 0, slow = 0, reduce = 1, power = 1},
	remove_on_clone = true,
	on_gain = function(self, err) return "#Target1# 붙잡혔습니다!", "+붙잡힘" end,
	on_lose = function(self, err) return "붙잡혀 있던 #Target1# 풀려나왔습니다.", "-붙잡힘" end,
	activate = function(self, eff)
		self:effectTemporaryValue(eff, "never_move", 1)
		self:effectTemporaryValue(eff, "combat_dam", -eff.reduce)
		if (eff.silence > 0) then
			self:effectTemporaryValue(eff, "silence", 1)
		end
		if (eff.slow > 0) then
			self:effectTemporaryValue(eff, "global_speed_add", -eff.slow)
		end
	end,
	on_timeout = function(self, eff)
		if not self.x or not eff.src or not eff.src.x or core.fov.distance(self.x, self.y, eff.src.x, eff.src.y) > 1 or eff.src.dead or not game.level:hasEntity(eff.src) then
			self:removeEffect(self.EFF_GRAPPLED)
		else
			DamageType:get(DamageType.PHYSICAL).projector(eff.src or self, self.x, self.y, DamageType.PHYSICAL, eff.power)
		end
	end,
	deactivate = function(self, eff)

	end, 
}

newEffect{
	name = "CRUSHING_HOLD", image = "talents/crushing_hold.png",
	desc = "Crushing Hold",
	kr_desc = "눌려 졸림",
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
	kr_desc = "숨통 졸림",
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
	kr_desc = "꺾임",
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
	kr_desc = "연계",
	display_desc = function(self, eff) return "연계 "..eff.cur_power end,
	long_desc = function(self, eff) return ("연계기 사용중 : 현재 연계 점수 %d"):format(eff.cur_power) end,
	type = "physical",
	subtype = { tactic=true },
	status = "beneficial",
	parameters = { power=1, max=5 },
	charges = function(self, eff) return eff.cur_power end,
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
	kr_desc = "방어적 전술",
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
	kr_desc = "흐트러진 자세",
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
	kr_desc = "회복",
	long_desc = function(self, eff) return ("회복 : 매 턴마다 생명력 +%d"):format(eff.power + eff.pct * self.max_life) end,
	type = "physical",
	subtype = { heal=true },
	status = "beneficial",
	parameters = { power=10, pct = 0.01 },
	on_gain = function(self, err) return "#Target1# 피해로부터 회복하기 시작합니다!", "+회복" end,
	on_lose = function(self, err) return "#Target#의 회복이 끝났습니다.", "-회복" end,
	activate = function(self, eff)
		--eff.regenid = self:addTemporaryValue("life_regen", eff.regen)
		--eff.healid = self:addTemporaryValue("healing_factor", eff.heal_mod / 100)
		if core.shader.active(4) then
			eff.particle1 = self:addParticles(Particles.new("shader_shield", 1, {toback=true,  size_factor=1.5, y=-0.3, img="healarcane"}, {type="healing", time_factor=4000, noup=2.0, beamColor1={0xff/255, 0x22/255, 0x22/255, 1}, beamColor2={0xff/255, 0x60/255, 0x60/255, 1}, circleColor={0,0,0,0}, beamsCount=8}))
			eff.particle2 = self:addParticles(Particles.new("shader_shield", 1, {toback=false, size_factor=1.5, y=-0.3, img="healarcane"}, {type="healing", time_factor=4000, noup=1.0, beamColor1={0xff/255, 0x22/255, 0x22/255, 1}, beamColor2={0xff/255, 0x60/255, 0x60/255, 1}, circleColor={0,0,0,0}, beamsCount=8}))
		end
	end,
	on_timeout = function(self, eff)
		local heal = (eff.power or 0) + self.max_life * eff.pct
		self:heal(heal, src)
	end,
	deactivate = function(self, eff)
		self:removeParticles(eff.particle1)
		self:removeParticles(eff.particle2)
		--self:removeTemporaryValue("life_regen", eff.regenid)
		--self:removeTemporaryValue("healing_factor", eff.healid)
	end,
}

newEffect{
	name = "REFLEXIVE_DODGING", image = "talents/heightened_reflexes.png",
	desc = "Reflexive Dodging",
	kr_desc = "반사신경 회피",
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
	kr_desc = "약해진 방어",
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
	kr_desc = "생명의 물",
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
	kr_desc = "원소의 조화",
	long_desc = function(self, eff)
		if eff.type == DamageType.FIRE then return ("모든 행동 속도 +%d%%."):format(100 * self:callTalent(self.T_ELEMENTAL_HARMONY, "fireSpeed"))
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
			eff.tmpid = self:addTemporaryValue("global_speed_add", self:callTalent(self.T_ELEMENTAL_HARMONY, "fireSpeed"))
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
	kr_desc = "회복력 강탈",
	long_desc = function(self, eff) return ("모든 생명력 회복량의 %d%%가 %s에게로 이동"):format(eff.pct * 100, (eff.src.kr_name or eff.src.name), eff.src.name) end, --@ 변수 순서 조정
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
	kr_desc = "이동불능",
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
	desc = "Imploding (slow)",
	kr_desc = "내파 (감속)",
	long_desc = function(self, eff) return ("모든 행동 속도 -50%% / 매 턴마다 물리 피해 %d"):format( eff.power) end,
	type = "physical",
	subtype = { telekinesis=true, slow=true },
	status = "detrimental",
	parameters = {},
	on_gain = function(self, err) return "#Target1# 힘에 의해 짓눌렸습니다.", "+내파" end,
	on_lose = function(self, err) return "#Target3# 짓누르던 힘이 사라졌습니다.", "-내파" end,
	activate = function(self, eff)
		if core.shader.allow("distort") then eff.particle = self:addParticles(Particles.new("gravity_well2", 1, {radius=1})) end
		eff.tmpid = self:addTemporaryValue("global_speed_add", -0.5)
	end,
	deactivate = function(self, eff)
		if eff.particle then self:removeParticles(eff.particle) end
		self:removeTemporaryValue("global_speed_add", eff.tmpid)
	end,
	on_timeout = function(self, eff)
		DamageType:get(DamageType.PHYSICAL).projector(eff.src, self.x, self.y, DamageType.PHYSICAL, eff.power)
	end,
}

newEffect{
	name = "FREE_ACTION", image = "effects/free_action.png",
	desc = "Free Action",
	kr_desc = "자유로운 행동",
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
	kr_desc = "아드레날린 쇄도",
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
	kr_desc = "습격 보너스",
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
	kr_desc = "불균형",
	long_desc = function(self, eff) return ("불균형 : 모든 피해량 -15%") end,
	type = "physical",
	subtype = { ["cross tier"]=true },
	status = "detrimental",
	parameters = {power = 1},
	on_gain = function(self, err) return nil, "+불균형" end,
	on_lose = function(self, err) return nil, "-불균형" end,
	activate = function(self, eff)
		eff.speedid = self:addTemporaryValue("numbed", 15)
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("numbed", eff.speedid)
	end,
}

newEffect{
	name = "OFFGUARD",
	desc = "Off-guard", image = "talents/precise_strikes.png",
	kr_desc = "방어 해제",
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
	kr_desc = "느린 이동",
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
	kr_desc = "약화",
	long_desc = function(self, eff) return ("약화 : 모든 피해 -%d%%"):format(eff.power) end,
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
	kr_desc = "화염 저항 저하",
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
	kr_desc = "냉기 저항 저하",
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
	kr_desc = "자연 저항 저하",
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
	kr_desc = "물리 저항 저하",
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
	kr_desc = "저주받은 상처",
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
	kr_desc = "발광",
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
	kr_desc = "주문 방해",
	long_desc = function(self, eff) return ("주문 방해 : 주문 시전시 %d%% 확률로 실패 / 매 턴마다 %d%% 확률로 유지 중인 주문이 종료"):format(eff.cur_power, eff.cur_power) end, --@ 변수 조정
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
	kr_desc = "반향",
	long_desc = function(self, eff) return ("%s 공격시 피해량 +%d%%"):format((DamageType:get(eff.damtype).kr_name or DamageType:get(eff.damtype).name), eff.dam) end, --@ 변수 순서 조정
	type = "physical",
	subtype = { nature=true },
	status = "beneficial",
	parameters = { dam=10, damtype=DamageType.ARCANE },
	on_gain = function(self, err) return "#Target1# 피해와 반향하기 시작합니다.", "+반향" end,
	on_lose = function(self, err) return "#Target#의 반향이 멈췄습니다.", "-반향" end,
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
	kr_desc = "가시덩굴",
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
	kr_desc = "잎사귀 덮개",
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

newEffect{ -- Note: This effect is cancelled by EFF_DISARMED
	name = "DUAL_WEAPON_DEFENSE", image = "talents/dual_weapon_defense.png",
	desc = "Parrying",
	kr_desc = "무기 쳐내기",
	deflectchance = function(self, eff) -- The last partial deflect has a reduced chance to happen
		if self:attr("encased_in_ice") or self:hasEffect(self.EFF_DISARMED) then return 0 end
		return util.bound(eff.deflects>=1 and eff.chance or eff.chance*math.mod(eff.deflects,1),0,100)
	end,
	long_desc = function(self, eff)
		return ("무기로 근접 공격을 흘려냄 : %d%% 확률로, 최대 %d 피해량까지 막아냄. 앞으로 %0.1f 회 가능"):format(self.tempeffect_def.EFF_DUAL_WEAPON_DEFENSE.deflectchance(self, eff),eff.dam, math.max(eff.deflects,1))
	end,
	charges = function(self, eff) return math.ceil(eff.deflects) end,
	type = "physical",
	subtype = {tactic=true},
	status = "beneficial",
	decrease = 0,
	no_stop_enter_worlmap = true, no_stop_resting = true,
	parameters = {chance=10,dam = 1, deflects = 1},
	activate = function(self, eff)
--		if self:attr("disarmed") or not self:hasDualWeapon() then eff.dur = 0 return end
		if self:attr("disarmed") or not self:hasDualWeapon() then
			eff.dur = 0 self:removeEffect(self.EFF_DUAL_WEAPON_DEFENSE) return
			end
		eff.dam = self:callTalent(self.T_DUAL_WEAPON_DEFENSE,"getDamageChange")
		eff.deflects = self:callTalent(self.T_DUAL_WEAPON_DEFENSE,"getDeflects")
		eff.chance = self:callTalent(self.T_DUAL_WEAPON_DEFENSE,"getDeflectChance")
		if eff.dam <= 0 or eff.deflects <= 0 then eff.dur = 0 end
	end,
	deactivate = function(self, eff)
	end,
}

newEffect{
	name = "BLOCKING", image = "talents/block.png",
	desc = "Blocking",
	kr_desc = "막기",
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
		if shield and shield.on_block and shield.on_block.fct then shield.on_block.fct(shield, self, src, type, dam, eff) end
		if eff.properties.br then
			self:heal(blocked, src)
			game:delayedLogMessage(self, src, "block_heal", "#CRIMSON##Source#의 회복 효과가 %s의 방패에 의해 막혔습니다!", string.his_her(self):krHisHer()) 
		end
		if eff.properties.ref and src.life then DamageType.defaultProjector(src, src.x, src.y, type, blocked, tmp, true) end
		if (self:knowTalent(self.T_RIPOSTE) or amt == 0) and src.life then
			src:setEffect(src.EFF_COUNTERSTRIKE, (1 + dur_inc) * math.max(1, (src.global_speed or 1)), {power=eff.power, no_ct_effect=true, src=self, crit_inc=crit_inc, nb=nb})
			if eff.properties.sb then
				if src:canBe("disarm") then
					src:setEffect(src.EFF_DISARMED, 3, {apply_power=self:combatPhysicalpower()})
				else
					game.logSeen(src, "%s 무장해제 시도를 저항했습니다!", (src.kr_name or src.name):capitalize():addJosa("가"))
				end
			end
		end-- specify duration here to avoid stacking for high speed attackers
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
	name = "COUNTER_ATTACKING", image = "talents/counter_attack.png",
	kr_desc = "반격",
	desc = "Counter Attacking",
	counterchance = function(self, eff) --The last partial counter attack has a reduced chance to happen
		if self:attr("encased_in_ice") or self:hasEffect(self.EFF_DISARMED) then return 0 end
		return util.bound(eff.counterattacks>=1 and eff.chance or eff.chance*math.mod(eff.counterattacks,1),0,100)
	end,
	long_desc = function(self, eff)
		return ("근접 공격 반격 : %d%% 확률로 근접 공격을 피하고 자동 반격. (앞으로 %0.1f 회 반격 가능))"):format(self.tempeffect_def.EFF_COUNTER_ATTACKING.counterchance(self, eff), math.max(eff.counterattacks,1))
	end,
	charges = function(self, eff) return math.ceil(eff.counterattacks) end,
	type = "physical",
	subtype = {tactic=true},
	status = "beneficial",
	decrease = 0,
	no_stop_enter_worlmap = true, no_stop_resting = true,
	parameters = {chance=10, counterattacks = 1},
	activate = function(self, eff)
		if self:attr("disarmed") then eff.dur = 0 return end
		eff.counterattacks = self:callTalent(self.T_COUNTER_ATTACK,"getCounterAttacks")
		eff.chance = self:callTalent(self.T_COUNTER_ATTACK,"counterchance")
		if eff.counterattacks <= 0 or eff.chance <= 0 then eff.dur = 0 end
	end,
	deactivate = function(self, eff)
	end,
}

newEffect{
	name = "BRAWLER_BLOCK", image = "talents/block.png",
	desc = "Blocking",
	kr_desc = "막기",
	long_desc = function(self, eff)
		return ("총 %d 피해를 막아냄."):
			format(self.brawler_block or 0)
	end,
	type = "physical",
	subtype = {tactic=true},
	status = "beneficial",
	parameters = {block = 0},
	activate = function(self, eff)
		self.brawler_block = eff.block
	end,
	deactivate = function(self, eff)
		self.brawler_block = nil
	end,
	callbackOnTakeDamage = function(self, eff, src, x, y, type, value, tmp)
		if not (self:attr("brawler_block") ) or value <= 0 then return end
		print("[PALM CALLBACK] dam start", value)

		local dam = value
		game:delayedLogDamage(src, self, 0, ("#STEEL_BLUE#(%d 막기)#LAST#"):format(math.min(dam, self.brawler_block)), false)
		if dam < self.brawler_block then
			self.brawler_block = self.brawler_block - dam
			dam = 0
		else
			dam = dam - self.brawler_block
			self.brawler_block = 0
		end

		-- If we are at the end of the capacity, release the time shield damage
		if self.brawler_block <= 0 then
			game.logPlayer(self, "#ORCHID#당신은 더이상 공격을 막을 수 없습니다!#LAST#")
			self:removeEffect(self.EFF_BRAWLER_BLOCK)
		end

		print("[PALM CALLBACK] dam end", dam)

		return {dam = dam}
	end,
}

newEffect{ 
	name = "DEFENSIVE_GRAPPLING", image = "talents/defensive_throw.png",
	desc = "Grappling Defensively",
	kr_desc = "되치기",
	throwchance = function(self, eff) -- the last partial defensive throw has a reduced chance to happen
		if not self:isUnarmed() or self:attr("encased_in_ice") then return 0 end	-- Must be unarmed
		return util.bound(eff.throws>=1 and eff.chance or eff.chance*math.mod(eff.throws,1),0,100)
	end,
	long_desc = function(self, eff)
		return ("%d%% 확률로 근접 공격을 피하고, 되치기로 반격. 대상을 집어던지고 기절시킬 확률 존재 (앞으로 %0.1f 회 던지기 가능)"):format(self.tempeffect_def.EFF_DEFENSIVE_GRAPPLING.throwchance(self, eff), math.max(eff.throws,1))
	end,
	charges = function(self, eff) return math.ceil(eff.throws) end,
	type = "physical",
	subtype = {tactic=true},
	status = "beneficial",
	decrease = 0,
	no_stop_enter_worlmap = true, no_stop_resting = true,
	parameters = {chance=10, throws = 1},
	activate = function(self, eff)
		if not self:isUnarmed() then eff.dur = 0 self:removeEffect(self.EFF_DEFENSIVE_GRAPPLING) return end
--		if not self:isUnarmed() then eff.dur = 0 return end
		eff.throws = self:callTalent(self.T_DEFENSIVE_THROW,"getThrows")
		eff.chance = self:callTalent(self.T_DEFENSIVE_THROW,"getchance")
		if eff.throws <= 0 or eff.chance <= 0 then eff.dur = 0 end
	end,
	deactivate = function(self, eff)
	end,
}

newEffect{
	name = "COUNTERSTRIKE", image = "effects/counterstrike.png",
	desc = "Counterstrike",
	kr_desc = "반격 대상",
	long_desc = function(self, eff) return "반격 대상 : 근접 공격에 맞으면 100% 더 큰 피해를 입음" end,
	type = "physical",
	subtype = { tactic=true },
	status = "detrimental",
	parameters = { nb=1 },
	on_gain = function(self, eff) return nil, "+반격 대상" end,
	on_lose = function(self, eff) return nil, "-반격 대상" end,
	onStrike = function(self, eff, dam, src)
		eff.nb = eff.nb - 1
		if eff.nb <= 0 then self:removeEffect(self.EFF_COUNTERSTRIKE) end

		if self.x and src.x and core.fov.distance(self.x, self.y, src.x, src.y) >= 5 then
			game:setAllowedBuild("rogue_skirmisher", true)
		end

		return dam * 2
	end,
	activate = function(self, eff)
		eff.tmpid = self:addTemporaryValue("counterstrike", 1)
		eff.def = self:addTemporaryValue("combat_def", -eff.power)
		eff.crit = self:addTemporaryValue("combat_crit_vulnerable", eff.crit_inc or 0)
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
	kr_desc = "유린",
	long_desc = function(self, eff)
		local ravaged = "(매 턴마다)"
		if eff.ravage then ravaged = "/ 매 턴마다 좋은 물리적 상태효과 하나 제거" end
		return ("왜곡에 의해 유린당함 : 매 턴마다 물리 피해 %0.2f %s"):format(eff.dam, ravaged)
	end,
	type = "physical",
	subtype = { distortion=true },
	status = "detrimental",
	parameters = {dam=1, distort=0},
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
		self:setEffect(self.EFF_DISTORTION, 2, {power=eff.distort})
		DamageType:get(DamageType.PHYSICAL).projector(eff.src or self, self.x, self.y, DamageType.PHYSICAL, eff.dam)
	end,
	activate = function(self, eff)
		self:setEffect(self.EFF_DISTORTION, 2, {power=eff.distort})
		if eff.ravage then
			game.logSeen(self, "#LIGHT_RED#%s 왜곡에 의해 유린당합니다!", (self.kr_name or self.name):capitalize():addJosa("가"))
			eff.dam = eff.dam * 1.5
		end
		local particle = Particles.new("ultrashield", 1, {rm=255, rM=255, gm=180, gM=255, bm=220, bM=255, am=35, aM=90, radius=0.2, density=15, life=28, instop=40})
		if core.shader.allow("distort") then particle:setSub("gravity_well2", 1, {radius=1}) end
		eff.particle = self:addParticles(particle)
	end,
	deactivate = function(self, eff)
		self:removeParticles(eff.particle)
	end,
}

newEffect{
	name = "DISTORTION", image = "talents/maelstrom.png",
	desc = "Distortion",
	kr_desc = "왜곡",
	long_desc = function(self, eff) return ("왜곡 피해 : 왜곡 효과에 취약해짐 / 물리 저항 -%d%%"):format(eff.power) end,
	type = "physical",
	subtype = { distortion=true },
	status = "detrimental",
	parameters = {power=0},
	on_gain = function(self, err) return  nil, "+왜곡" end,
	on_lose = function(self, err) return "#Target1# 왜곡에서 벗어났습니다." or nil, "-왜곡" end,
	activate = function(self, eff)
		self:effectTemporaryValue(eff, "resists", {[DamageType.PHYSICAL]=-eff.power})
	end,

}

newEffect{
	name = "DISABLE", image = "talents/cripple.png",
	desc = "Disable",
	kr_desc = "무력화",
	long_desc = function(self, eff) return ("무력화 : 이동 속도 -%d%% / 정확도 -%d"):format(eff.speed * 100, eff.atk) end,
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
	kr_desc = "고뇌",
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
	kr_desc = "번개보다 빠르게",
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
	kr_desc = "속성 고조 : 자연",
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
	kr_desc = "강압됨",
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
	kr_desc = "강압",
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
	kr_desc = "최강의 척추신경",
	long_desc = function(self, eff) return ("나쁜 물리적 상태이상 효과에 완전 면역") end,
	type = "physical",
	subtype = { status=true },
	status = "beneficial",
	parameters = { },
	on_gain = function(self, err) return "#Target1# 물리 효과에 강해졌습니다.", "+최강의 척추신경" end,
	on_lose = function(self, err) return "#Target1# 물리 효과에 약해졌습니다.", "-최강의 척추신경" end,
	activate = function(self, eff)
		self:effectTemporaryValue(eff, "physical_negative_status_effect_immune", 1)
	end,
}

newEffect{
	name = "FUNGAL_BLOOD", image = "talents/fungal_blood.png",
	desc = "Fungal Blood",
	kr_desc = "미생물 혈액",
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
		eff.power = util.bound(eff.power * 0.9, 0, eff.power - 10)
	end,
}

newEffect{
	name = "MUCUS", image = "talents/mucus.png",
	desc = "Mucus",
	kr_desc = "점액",
	long_desc = function(self, eff) return ("지나간 장소에 점액 분출"):format() end,
	type = "physical",
	subtype = { mucus=true },
	status = "beneficial",
	parameters = { },
	on_gain = function(self, err) return nil, "+점액" end,
	on_lose = function(self, err) return nil, "-점액" end,
	on_timeout = function(self, eff)
		self:callTalent(self.T_MUCUS, nil, self.x, self.y, self:getTalentLevel(self.T_MUCUS) >=4 and 1 or 0, eff)
	end,
}

newEffect{
	name = "CORROSIVE_NATURE", image = "talents/corrosive_nature.png",
	desc = "Corrosive Nature",
	kr_desc = "부식성 자연",
	long_desc = function(self, eff) return ("공격시 산성 피해량 %d%% 증가."):format(eff.power) end,
	type = "physical",
	subtype = { nature=true, acid=true },
	status = "beneficial",
	parameters = { power=1, bonus_level=1},
	charges = function(self, eff) return math.round(eff.power) end,
	on_gain = function(self, err) return "#Target#의 산성 공격력이 더욱 강해졌습니다.", "+부식성 자연" end,
	on_lose = function(self, err) return "#Target#의 산성 공격력이 더이상 강력하지 않습니다.", "-부식성 자연" end,
	on_merge = function(self, eff, new_eff)
		if game.turn < eff.last_update + 10 then return eff end -- update once a turn
		local t = self:getTalentFromId(self.T_CORROSIVE_NATURE)
		eff.dur = t.getDuration(self, t)
		if eff.bonus_level >=5 then return eff end
		game.logSeen(self, "%s의 부식성 자연이 더욱 강렬해졌습니다!",(self.kr_name or self.name):capitalize())
		eff.last_update = game.turn
		eff.bonus_level = eff.bonus_level + 1
		eff.power = t.getAcidDamage(self, t, eff.bonus_level)
		self:removeTemporaryValue("inc_damage", eff.dam_id)
		eff.dam_id = self:addTemporaryValue("inc_damage", {[DamageType.ACID]=eff.power})
		return eff
	end,
	activate = function(self, eff)
		eff.power = self:callTalent(self.T_CORROSIVE_NATURE, "getAcidDamage")
		eff.dam_id = self:addTemporaryValue("inc_damage", {[DamageType.ACID]=eff.power})
		eff.last_update = game.turn
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("inc_damage", eff.dam_id)
	end,
}

newEffect{
	name = "NATURAL_ACID", image = "talents/natural_acid.png",
	desc = "Natural Acid",
	kr_desc = "자연적 산성 물질",
	long_desc = function(self, eff) return ("공격시 자연 피해량 %d%% 증가."):format(eff.power) end,
	type = "physical",
	subtype = { nature=true, acid=true },
	status = "beneficial",
	parameters = { power=1, bonus_level=1},
	charges = function(self, eff) return math.round(eff.power) end,
	on_gain = function(self, err) return "#Target#의 자연 속성 공격력이 더욱 강해졌습니다.", "+자연적 산성 물질" end,
	on_lose = function(self, err) return "#Target#의 자연 속성 공격력이 더이상 강력하지 않습니다.", "-자연적 산성 물질" end,
	on_merge = function(self, eff, new_eff)
		if game.turn < eff.last_update + 10 then return eff end -- update once a turn
		local t = self:getTalentFromId(self.T_NATURAL_ACID)
		eff.dur = t.getDuration(self, t)
		if eff.bonus_level >=5 then return eff end
		game.logSeen(self, "%s의 자연적 산성 물질이 더욱 농축되었습니다!",(self.kr_name or self.name):capitalize())
		eff.last_update = game.turn
		eff.bonus_level = eff.bonus_level + 1
		eff.power = t.getNatureDamage(self, t, eff.bonus_level)
		self:removeTemporaryValue("inc_damage", eff.dam_id)
		eff.dam_id = self:addTemporaryValue("inc_damage", {[DamageType.NATURE]=eff.power})
		return eff
	end,
	activate = function(self, eff)
		eff.power = self:callTalent(self.T_NATURAL_ACID, "getNatureDamage")
		eff.dam_id = self:addTemporaryValue("inc_damage", {[DamageType.NATURE]=eff.power})
		eff.last_update = game.turn
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("inc_damage", eff.dam_id)
	end,
}

newEffect{
	name = "CORRODE", image = "talents/blightzone.png",
	desc = "Corrode",
	kr_desc = "부식",
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
	kr_desc = "미끄러운 이끼",
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

newEffect{
	name = "JUGGERNAUT", image = "talents/juggernaut.png",
	desc = "Juggernaut",
	kr_desc = "저돌적인 전투",
	long_desc = function(self, eff) return ("대상이 받는 물리 속성 피해 %d%% 감소 / %d%% 확률로 치명타 피해 감소."):format(eff.power, eff.crits) end,
	type = "physical",
	subtype = { superiority=true },
	status = "beneficial",
	parameters = { power=10 },
	on_gain = function(self, err) return "#Target#의 피부가 단단해졌습니다.", "+저돌적인 전투" end,
	on_lose = function(self, err) return "#Target#의 피부가 원래 상태로 돌아갔습니다.", "-저돌적인 전투" end,
	activate = function(self, eff)
		eff.particle = self:addParticles(Particles.new("stone_skin", 1, {density=4}))
		self:effectTemporaryValue(eff, "resists", {[DamageType.PHYSICAL]=eff.power})
		self:effectTemporaryValue(eff, "ignore_direct_crits", eff.crits)
	end,
	deactivate = function(self, eff)
		self:removeParticles(eff.particle)
	end,
}

newEffect{
	name = "NATURE_REPLENISHMENT", image = "talents/meditation.png",
	desc = "Natural Replenishment",
	kr_desc = "자연적 보급",
	long_desc = function(self, eff) return ("마법 에너지에 직접적 노출, 자연과의 연결점에 반응 : 매 턴 마다 %0.1f 평정 회복."):format(eff.power) end,
	type = "physical",
	subtype = { nature=true },
	status = "beneficial",
	parameters = {power=1},
	on_gain = function(self, err) return ("#Target2# %s 자연의 연결점에 적대적으로 반응합니다!"):format(string.his_her(self):krHisHer():addJosa("와")), "+자연적 보급" end, 
	on_lose = function(self, err) return "#Target#의 평정 회복이 멈췄습니다.", "-자연적 보급" end,
	on_timeout = function(self, eff)
		self:incEquilibrium(-eff.power)
	end,
}


newEffect{
	name = "BERSERKER_RAGE", image = "talents/berserker.png",
	desc = "Berserker Rage",
	kr_desc = "광전사의 분노",
	long_desc = function(self, eff) return ("치명타 확률 %d%% 증가."):format(eff.power) end,
	type = "physical",
	subtype = { tactic=true },
	status = "beneficial",
	decrease = 0, no_remove = true,
	parameters = {power=1},
	charges = function(self, eff) return ("%0.1f%%"):format(eff.power) end,
	activate = function(self, eff)
		self:effectTemporaryValue(eff, "combat_physcrit", eff.power)
	end,
}


newEffect{
	name = "RELENTLESS_FURY", image = "talents/relentless_fury.png",
	desc = "Relentless Fury",
	kr_desc = "무자비한 분노",
	long_desc = function(self, eff) return ("체력 재생 %d 증가 / 이동속도 %d%% 증가 / 공격속도 %d%% 증가."):format(eff.stamina, eff.speed, eff.speed) end, --@ 변수 조정
	type = "physical",
	subtype = { tactic=true },
	status = "beneficial",
	parameters = {stamina=1, speed=10},
	activate = function(self, eff)
		self:effectTemporaryValue(eff, "stamina_regen", eff.stamina)
		self:effectTemporaryValue(eff, "movement_speed", eff.speed/100)
		self:effectTemporaryValue(eff, "combat_physspeed", eff.speed/100)
	end,
}

local normalize_direction = function(direction)
	return direction % (2*math.pi)
end

local in_angle = function(angle, min, max)
	if min <= max then
		return min <= angle and angle <= max
	else
		return min <= angle or angle <= max
	end
end

newEffect {
	name = "SKIRMISHER_DIRECTED_SPEED",
	desc = "Directed Speed",
	kr_desc = "통제된 속도",
	type = "physical",
	subtype = {speed = true},
	parameters = {
		-- Movement direction in radians.
		direction = 0,
		-- Allowed deviation from movement direction in radians.
		leniency = math.pi * 0.1,
		-- Movement speed bonus
		move_speed_bonus = 1.00
	},
	status = "beneficial",
	on_lose = function(self, eff) return "#Target2# 속도를 유지하지 못하게 되었습니다.", "-통제된 속도" end,
	callbackOnMove = function(self, eff, moved, force, ox, oy)
		local angle_start = normalize_direction(math.atan2(self.y - eff.start_y, self.x - eff.start_x))
		local angle_last = normalize_direction(math.atan2(self.y - eff.last_y, self.x - eff.last_x))
		if ((self.x ~= eff.start_x or self.y ~= eff.start_y) and
				not in_angle(angle_start, eff.min_angle_start, eff.max_angle_start)) or
			((self.x ~= eff.last_x or self.y ~= eff.last_y) and
			 not in_angle(angle_last, eff.min_angle_last, eff.max_angle_last))
		then
			self:removeEffect(self.EFF_SKIRMISHER_DIRECTED_SPEED)
		end
		eff.last_x = self.x
		eff.last_y = self.y
		eff.min_angle_last = normalize_direction(angle_last - eff.leniency_last)
		eff.max_angle_last = normalize_direction(angle_last + eff.leniency_last)
	end,
	activate = function(self, eff)
		self:effectTemporaryValue(eff, "movement_speed", eff.move_speed_bonus)
		eff.leniency_last = math.max(math.pi * 0.25, eff.leniency)

		eff.start_x = self.x
		eff.start_y = self.y
		eff.min_angle_start = normalize_direction(eff.direction - eff.leniency)
		eff.max_angle_start = normalize_direction(eff.direction + eff.leniency)
		eff.last_x = self.x
		eff.last_y = self.y
		eff.min_angle_last = normalize_direction(eff.direction - eff.leniency_last)
		eff.max_angle_last = normalize_direction(eff.direction + eff.leniency_last)

		-- AI won't use talents while active.
		if self.ai_state then
			self:effectTemporaryValue(eff, "ai_state", {no_talents=1})
		end
	end,
	long_desc = function(self, eff)
		return ([[대상은 한쪽 방향으로 움직일 때 %d%% 만큼 추가적인 속도를 낼 수 있습니다 (현재 방향 : %s). 멈추거나 움직이는 방향을 바꾸면 이 효과는 사라집니다.]])
		:format(eff.move_speed_bonus * 100, eff.compass or "알수없는 방향") --@ 한글화 여부 검사 : eff.compass
	end,
}

-- If they don't have stun, stun them. If they do, increase its
-- duration.
newEffect {
	name = "SKIRMISHER_STUN_INCREASE",
	desc = "Stun Lengthen",
	kr_desc = "기절 연장",
	type = "physical",
	subtype = {stun = true},
	status = "detrimental",
	on_gain = function(self, eff)
		local stun = self:hasEffect(self.EFF_STUNNED)
		if stun and stun.dur and stun.dur > 1 then
			return ("#Target2# 더 오래 기절합니다! (현재 %d 턴)"):format(stun.dur), "기절 연장"
		end
	end,
	activate = function(self, eff)
		local stun = self:hasEffect(self.EFF_STUNNED)
		if stun then
			stun.dur = stun.dur + eff.dur
		else
			self:setEffect(self.EFF_STUNNED, eff.dur, {})
		end
		self:removeEffect(self.EFF_SKIRMISHER_STUN_INCREASE)
	end,
}

newEffect {
	name = "SKIRMISHER_ETERNAL_WARRIOR",
	desc = "Eternal Warrior",
	kr_desc = "불멸의 전사",
	image = "talents/skirmisher_the_eternal_warrior.png",
	type = "mental",
	subtype = { morale=true },
	status = "beneficial",
	parameters = {
		-- Resist all increase
		res=.5,
		-- Resist caps increase
		cap=.5,
		-- Maximum stacking applications
		max=5
	},
	on_gain = function(self, err) return nil, "+불멸의 전사" end,
	on_lose = function(self, err) return nil, "-불멸의 전사" end,
	long_desc = function(self, eff)
		return ("강력함을 유지 : 전체 저항 %0.1f%% 상승 / 전체 한계 저항 %0.1f%% 상승."):
		format(eff.res, eff.cap)
	end,
	activate = function(self, eff)
		eff.res_id = self:addTemporaryValue("resists", {all = eff.res})
		eff.cap_id = self:addTemporaryValue("resists_cap", {all = eff.cap})
	end,
	on_merge = function(self, old_eff, new_eff)
		self:removeTemporaryValue("resists", old_eff.res_id)
			self:removeTemporaryValue("resists_cap", old_eff.cap_id)
		new_eff.res = math.min(new_eff.res + old_eff.res, new_eff.res * new_eff.max)
		new_eff.cap = math.min(new_eff.cap + old_eff.cap, new_eff.cap * new_eff.max)
		new_eff.res_id = self:addTemporaryValue("resists", {all = new_eff.res})
		new_eff.cap_id = self:addTemporaryValue("resists_cap", {all = new_eff.cap})
		return new_eff
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("resists", eff.res_id)
		self:removeTemporaryValue("resists_cap", eff.cap_id)
	end,
}

newEffect {
	name = "SKIRMISHER_TACTICAL_POSITION",
	desc = "Tactical Position",
	kr_desc = "전략적 위치선정",
	type = "physical",
	subtype = {tactic = true},
	status = "beneficial",
	parameters = {combat_physcrit = 10},
	long_desc = function(self, eff)
		return ([[유리한 위치 선정 : 물리 치명타 확률 +%d%%.]])
		:format(eff.combat_physcrit)
	end,
	on_gain = function(self, eff) return "#Target1# 공격하기 위한 자세를 잡습니다!" end,
	activate = function(self, eff)
		self:effectTemporaryValue(eff, "combat_physcrit", eff.combat_physcrit)
	end,
}

newEffect {
	name = "SKIRMISHER_DEFENSIVE_ROLL",
	desc = "Defensive Roll",
	kr_desc = "방어용 몸놀림",
	type = "physical",
	subtype = {tactic = true},
	status = "beneficial",
	parameters = {
		-- percent of all damage to ignore
		reduce = 50
	},
	on_gain = function(self, eff) return "#Target1# 피해를 회피하기 위해 몸을 돌렸습니다!" end,
	activate = function(self, eff)
		self:effectTemporaryValue(eff, "incoming_reduce", eff.reduce)
	end,
	long_desc = function(self, eff)
		return ([[방어용 몸놀림 : 전체 피해 중 %d%% 무시.]])
		:format(eff.reduce)
	end,
}

newEffect {
	name = "SKIRMISHER_TRAINED_REACTIONS_COOLDOWN",
	desc = "Trained Reactions Cooldown",
	kr_desc = "훈련된 반사반응의 지연시간",
	type = "other",
	subtype = {cooldown = true},
	status = "detrimental",
	no_stop_resting = true,
	on_lose = function(self, eff) return "#LIGHT_BLUE##Target2# 이번에도 회피할 것 같습니다.", "+훈련된 반사반응" end,
	long_desc = function(self, eff)
		return "훈련된 반사반응을 수행하지 못합니다."
	end,
}

newEffect {
	name = "SKIRMISHER_SUPERB_AGILITY",
	desc = "Superb Agility",
	kr_desc = "기막힌 몸놀림",
	image = "talents/skirmisher_superb_agility.png",
	type = "physical",
	subtype = {speed = true},
	status = "beneficial",
	parameters = {
		global_speed_add = 0.1,
	},
	on_gain = function(self, eff) return "#Target1# 속도를 높입니다!" end,
	activate = function(self, eff)
		self:effectTemporaryValue(eff, "global_speed_add", eff.global_speed_add)
	end,
	long_desc = function(self, eff)
		return ([[반응이 빨라짐 : 전체 속도 +%d%%.]])
		:format(eff.global_speed_add * 100)
	end,
}
