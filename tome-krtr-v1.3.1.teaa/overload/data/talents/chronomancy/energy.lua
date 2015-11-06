-- ToME - Tales of Maj'Eyal
-- Copyright (C) 2009 - 2015 Nicolas Casalini
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

-- EDGE TODO: Particles, Timed Effect Particles

newTalent{
	name = "Energy Decomposition",
	kr_name = "에너지 분해",
	type = {"chronomancy/energy",1},
	mode = "sustained",
	require = chrono_req1,
	points = 5,
	sustain_paradox = 24,
	cooldown = 10,
	tactical = { BUFF = 2 },
	getDecomposition = function(self, t) return  self:combatTalentSpellDamage(t, 5, 50, getParadoxSpellpower(self, t)) end, -- Increase shield strength
	callbackOnTakeDamage = function(self, t, src, x, y, type, dam, tmp)
		local decomp = t.getDecomposition(self, t)
		local lastdam = dam

		-- works like armor with 30% hardiness
		dam = math.max(dam * 0.3 - decomp, 0) + (dam * 0.7)
		print("[PROJECTOR] after static reduction dam", dam)
		game:delayedLogDamage(src or self, self, 0, ("%s(%d dissipated)#LAST#"):format(DamageType:get(type).text_color or "#aaaaaa#", lastdam - dam), false)
		return {dam=dam}
	end,
	activate = function(self, t)
		game:playSoundNear(self, "talents/heal")
		local ret = {}
		if core.shader.active(4) then
			ret.particle = self:addParticles(Particles.new("shader_shield", 1, {size_factor=1.2, img="forcefield"}, {type="shield", shieldIntensity=0.05, color={1,1,1}}))
		end
		return ret
	end,
	deactivate = function(self, t, p)
		self:removeParticles(p.particle)
		return true
	end,
	info = function(self, t)
		local decomp = t.getDecomposition(self, t)
		return ([[모든 피해를 부분적으로 소멸 시켜, 피해의 30%% 를 줄입니다. (최대 %d)
		최대 피해량 감소는 주문력에 비례하여 상승합니다.]]):format(decomp)
	end,
}

newTalent{
	name = "Energy Absorption",
	kr_name = "에너지 흡수",
	type = {"chronomancy/energy", 2},
	require = chrono_req2,
	points = 5,
	paradox = function (self, t) return getParadoxCost(self, t, 10) end,
	cooldown = 6,
	fixed_cooldown = true,
	tactical = { DISABLE = 2 },
	direct_hit = true,
	requires_target = true,
	range = 10,
	getTalentCount = function(self, t)
		return 1 + math.floor(self:combatTalentLimit(t, 3, 0, 2))
	end,
	getCooldown = function(self, t) return math.ceil(self:combatTalentScale(t, 1, 2.6)) end,
	target = function (self, t)
		return {type="hit", range=self:getTalentRange(t), talent=t}
	end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local tx, ty = self:getTarget(tg)
		if not tx or not ty then return nil end
		local _ _, tx, ty = self:canProject(tg, tx, ty)
		local target = game.level.map(tx, ty, Map.ACTOR)
		if not target then return end

		if not self:checkHit(getParadoxSpellpower(self, t), target:combatSpellResist()) then
			game.logSeen(target, "%s 저항했습니다!", target.name:capitalize())
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
			game.logSeen(target, "%s의 %s 기술이 흡수 당했습니다!", target.name:capitalize(), t.name)
			count = count + 1
		end

		if count >= 1 then
			local tids = {}
			for tid, _ in pairs(self.talents_cd) do
				local tt = self:getTalentFromId(tid)
				if not tt.fixed_cooldown then
					tids[#tids+1] = tt
				end
			end

			for i = 1, count do
				if #tids == 0 then break end
				local tid = rng.tableRemove(tids)
				self:alterTalentCoolingdown(tid, - cdr)
			end
		end

		target:crossTierEffect(target.EFF_SPELLSHOCKED, getParadoxSpellpower(self, t))
		game.level.map:particleEmitter(tx, ty, 1, "generic_charge", {rm=10, rM=110, gm=10, gM=50, bm=20, bM=125, am=25, aM=125})
		game.level.map:particleEmitter(self.x, self.y, 1, "generic_charge", {rm=200, rM=255, gm=200, gM=255, bm=0, bM=0, am=25, aM=125})
		game:playSoundNear(self, "talents/spell_generic")
		return true
	end,
	info = function(self, t)
		local talentcount = t.getTalentCount(self, t)
		local cooldown = t.getCooldown(self, t)
		return ([[당신은 목표의 에너지를 약화 시킨 후에 그것을 자신의 것으로 만듭니다. 영향을 받은 목표는 최대 %d 개의 무작위의 기술이 %d 턴의 재사용 대기시간 상태로 변합니다. 
		재사용 대기시간으로 바꾼 기술 하나마다, 당신의 현재 재사용 대기 상태인 기술 중 하나의 대기시간이 %d 턴 줄어듭니다.]]):
		format(talentcount, cooldown, cooldown)
	end,
}

newTalent{
	name = "Redux",
	kr_name = "재현",
	type = {"chronomancy/energy",3},
	require = chrono_req3,
	points = 5,
	paradox = function (self, t) return getParadoxCost(self, t, 20) end,
	cooldown = 12,
	tactical = { BUFF = 2 },
	fixed_cooldown = true,
	getDuration = function(self, t) return getExtensionModifier(self, t, 4) end,
	getMaxCooldown = function(self, t) return 1 + math.floor(self:combatTalentScale(t, 3, 8)) end,
	action = function(self, t)
		-- effect is handled in actor postUse
		self:setEffect(self.EFF_REDUX, t.getDuration(self, t), {max_cd=t.getMaxCooldown(self, t)})
		game:playSoundNear(self, "talents/heal")
		return true
	end,
	info = function(self, t)
		local duration = t.getDuration(self, t)
		local cooldown = t.getMaxCooldown(self, t)
		return ([[다음에 시전하는 당신의 기술이 %d 턴 이하의 재사용 대기시간을 가졌다면, 대기시간을 가지지 않게 됩니다.
		이 효과는 %d 턴간 지속되며, 한 번 기술의 대기시간을 없앴다면 사라집니다.]]):
		format(cooldown, duration)
	end,
}

newTalent{
	name = "Entropy",
	kr_name = "엔트로피",
	type = {"chronomancy/energy",4},
	require = chrono_req4,
	points = 5,
	paradox = function (self, t) return getParadoxCost(self, t, 20) end,
	cooldown = 12,
	tactical = { DISABLE = 2 },
	range = 10,
	getDuration = function(self, t) return getExtensionModifier(self, t, math.floor(self:combatTalentScale(t, 1, 7))) end,
	target = function(self, t)
		return {type="hit", range=self:getTalentRange(t), talent=t}
	end,
	requires_target = true,
	direct_hit = true,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y, target = self:getTarget(tg)
		local _ _, x, y = self:canProject(tg, x, y)
		local target = game.level.map(x, y, Map.ACTOR)
		if not x or not y or not target then return nil end

		target:setEffect(target.EFF_ENTROPY, t.getDuration(self, t), {apply_power=getParadoxSpellpower(self, t)})

		game:playSoundNear(self, "talents/dispel")

		return true
	end,
	info = function(self, t)
		local duration = t.getDuration(self, t)
		return ([[이 기술이 유지 되는 %d 턴 동안, 목표의 유지 기술이 하나씩 매턴 취소됩니다.]]):format(duration)
	end,
}
