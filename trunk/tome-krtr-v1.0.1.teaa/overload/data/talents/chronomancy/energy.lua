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

newTalent{
	name = "Energy Decomposition",
	kr_name = "에너지 분해",
	type = {"chronomancy/energy",1},
	mode = "sustained",
	require = chrono_req1,
	points = 5,
	sustain_paradox = 75,
	cooldown = 10,
	tactical = { BUFF = 2 },
	getAbsorption = function(self, t) return self:combatTalentSpellDamage(t, 5, 50) end,
	on_damage = function(self, t, damtype, dam)
		if not DamageType:get(damtype).antimagic_resolve then return dam end
		local absorb = t.getAbsorption(self, t)
		-- works like armor with 30% hardiness for projected energy effects
		dam = math.max(dam * 0.3 - absorb, 0) + (dam * 0.7)
		print("[PROJECTOR] after static reduction dam", dam)
		return dam
	end,
	activate = function(self, t)
		game:playSoundNear(self, "talents/heal")
		return {
			particle = self:addParticles(Particles.new("temporal_focus", 1)),
		}
	end,
	deactivate = function(self, t, p)
		self:removeParticles(p.particle)
		return true
	end,
	info = function(self, t)
		local absorption = t.getAbsorption(self, t)
		return ([[에너지로 이루어진 공격, 즉 마법 공격을 받을 때 피해량을 30%% 감소시킵니다. (최대 피해 감소량 : %d)
		최대 피해 감소량은 주문력의 영향을 받아 증가합니다.]]):format(absorption)
	end,
}

newTalent{
	name = "Entropic Field",
	kr_name = "엔트로피 역장",
	type = {"chronomancy/energy",2},
	mode = "sustained",
	require = chrono_req2,
	points = 5,
	sustain_paradox = 100,
	cooldown = 10,
	tactical = { BUFF = 2 },
	getPower = function(self, t) return math.min(90, 10 + (self:combatTalentSpellDamage(t, 10, 50))) end,
	activate = function(self, t)
		game:playSoundNear(self, "talents/heal")
		return {
			particle = self:addParticles(Particles.new("time_shield", 1)),
			phys = self:addTemporaryValue("resists", {[DamageType.PHYSICAL]=t.getPower(self, t)/2}),
			proj = self:addTemporaryValue("slow_projectiles", t.getPower(self, t)),
		}
	end,
	deactivate = function(self, t, p)
		self:removeParticles(p.particle)
		self:removeTemporaryValue("resists", p.phys)
		self:removeTemporaryValue("slow_projectiles", p.proj)
		return true
	end,
	info = function(self, t)
		local power = t.getPower(self, t)
		return ([[엔트로피 역장을 주변에 만들어 투사체의 속도를 %d%% 감소시키고, 물리 저항력을 %d%% 증가시킵니다.
		마법의 효과는 주문력의 영향을 받아 증가합니다.]]):format(power, power / 2)
	end,
}

newTalent{
	name = "Energy Absorption",
	kr_name = "에너지 흡수",
	type = {"chronomancy/energy", 3},
	require = chrono_req3,
	points = 5,
	paradox = 10,
	cooldown = 10,
	tactical = { DISABLE = 2 },
	direct_hit = true,
	requires_target = true,
	range = 6,
	getTalentCount = function(self, t) return 1 + math.floor(self:getTalentLevel(t) * getParadoxModifier(self, pm)/2) end,
	getCooldown = function(self, t) return 1 + math.ceil(self:getTalentLevel(t)/3) end,
	action = function(self, t)
		local tg = {type="hit", range=self:getTalentRange(t)}
		local tx, ty = self:getTarget(tg)
		if not tx or not ty then return nil end
		local _ _, tx, ty = self:canProject(tg, tx, ty)
		tx, ty = checkBackfire(self, tx, ty)
		local target = game.level.map(tx, ty, Map.ACTOR)
		if not target then return end

		if not self:checkHit(self:combatSpellpower(), target:combatSpellResist()) then
			game.logSeen(target, "%s 저항했습니다!", (target.kr_name or target.name):capitalize():addJosa("가"))
			return true
		end

		local tids = {}
		for tid, lev in pairs(target.talents) do
			local t = target:getTalentFromId(tid)
			if t and not target.talents_cd[tid] and t.mode == "activated" and not t.innate then tids[#tids+1] = t end
		end

		local count = 0
		local cdr = t.getCooldown(self, t)

		for i = 1, t.getTalentCount(self, t) do
			local t = rng.tableRemove(tids)
			if not t then break end
			target.talents_cd[t.id] = cdr
			game.logSeen(target, "%s의 %s 기술 에너지가 흡수당했습니다!", (target.kr_name or target.name):capitalize(), (t.kr_name or t.name))
			count = count + 1
		end

		if count >= 1 then
			local tids = {}
			for tid, _ in pairs(self.talents_cd) do
				local tt = self:getTalentFromId(tid)
				if tt.type[1]:find("^chronomancy/") then
					tids[#tids+1] = tid
				end
			end
			for i = 1, count do
				if #tids == 0 then break end
				local tid = rng.tableRemove(tids)
				self.talents_cd[tid] = self.talents_cd[tid] - cdr
			end
		end
		target:crossTierEffect(target.EFF_SPELLSHOCKED, self:combatSpellpower())
		game.level.map:particleEmitter(tx, ty, 1, "generic_charge", {rm=10, rM=110, gm=10, gM=50, bm=20, bM=125, am=25, aM=255})
		game.level.map:particleEmitter(self.x, self.y, 1, "generic_charge", {rm=200, rM=255, gm=200, gM=255, bm=200, bM=255, am=125, aM=125})
		game:playSoundNear(self, "talents/spell_generic")
		return true
	end,
	info = function(self, t)
		local talentcount = t.getTalentCount(self, t)
		local cooldown = t.getCooldown(self, t)
		return ([[대상의 기술 에너지를 흡수해, 자신의 것으로 만듭니다. 
		대상의 기술 %d 개가 %d 턴의 재사용 대기시간을 갖게 되며, 대상의 기술이 하나 지연될 때마다 자신의 시공 계열 마법 중 하나의 재사용 대기시간이 %d 턴 줄어듭니다.
		적용되는 기술의 갯수는 괴리 능력치의 영향을 받아 증가합니다.]]):
		format(talentcount, cooldown, cooldown)
	end,
}

newTalent{
	name = "Redux",
	kr_name = "재현",
	type = {"chronomancy/energy",4},
	require = chrono_req4,
	points = 5,
	paradox = 20,
	cooldown = 12,
	tactical = { BUFF = 2 },
	no_energy = true,
	getMaxLevel = function(self, t) return self:getTalentLevel(t) end,
	action = function(self, t)
		-- effect is handled in actor postUse
		self:setEffect(self.EFF_REDUX, 5, {})
		game:playSoundNear(self, "talents/heal")
		return true
	end,
	info = function(self, t)
		local maxlevel = t.getMaxLevel(self, t)
		return ([[이 마법을 사용하면, 다음 5 턴 이내에 시전한 시공 계열 마법이 두 번 연속으로 시전됩니다. (%0.1f 기술 레벨의 마법까지 가능)
		마법의 재사용 대기시간을 무시하고 연속으로 사용할 수 있지만, 두 번째 시전된 마법도 괴리 수치 증가나 시전시간 소모는 똑같이 이루어집니다.
		이 마법은 시전시간 없이 즉시 사용할 수 있습니다.]]):
		format(maxlevel)
	end,
}
