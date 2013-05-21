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
	name = "Weapon Folding",
	kr_name = "무기의 차원 접기",
	type = {"chronomancy/spacetime-folding", 1},
	mode = "sustained",
	require = temporal_req1,
	sustain_paradox = 75,
	cooldown = 10,
	tactical = { BUFF = 2 },
	points = 5,
	getDamage = function(self, t) return self:combatTalentSpellDamage(t, 15, 25) end,
	getParadoxReduction = function(self, t) return self:getTalentLevel(t) / 2 end,
	activate = function(self, t)
		return {}
	end,
	deactivate = function(self, t, p)
		return true
	end,
	info = function(self, t)
		local damage = t.getDamage(self, t)
		local paradox_reduction = t.getParadoxReduction(self, t)
		return ([[무기나 발사체의 차원을 한 단계 접어, 공격할 때마다 %0.2f 시간 피해를 추가로 주고 (발사체는 %0.2f 시간 피해) 공격에 성공할 때마다 괴리 수치를 %0.1f 감소시킵니다. (발사체는 괴리 %0.1f 감소)
		피해량은 주문력의 영향을 받아 증가합니다.]]):format(damDesc(self, DamageType.TEMPORAL, damage), damDesc(self, DamageType.TEMPORAL, damage * 2), paradox_reduction, paradox_reduction * 2)
	end,
}

newTalent{
	name = "Swap",
	kr_name = "교대",
	type = {"chronomancy/spacetime-folding", 2},
	require = temporal_req2,
	points = 5,
	paradox = 5,
	cooldown = 10,
	tactical = { DISABLE = 2, },
	requires_target = true,
	direct_hit = true,
	range = function(self, t)
		return 2 + math.floor(self:getTalentLevel(t))
	end,
	getConfuseDuration = function(self, t) return math.floor((self:getTalentLevel(t) + 2) * getParadoxModifier(self, pm)) end,
	getConfuseEfficency = function(self, t) return math.min(50, self:getTalentLevelRaw(t) * 10) end,
	action = function(self, t)
		local tg = {type="hit", range=self:getTalentRange(t)}
		local tx, ty, target = self:getTarget(tg)
		if not tx or not ty then return nil end
		tx, ty = checkBackfire(self, tx, ty)
		if tx then
			local _ _, tx, ty = self:canProject(tg, tx, ty)
			if tx then
				target = game.level.map(tx, ty, Map.ACTOR)
				if not target then return nil end
			end
		end
		
		-- checks for spacetime mastery hit bonus
		local power = self:combatSpellpower()
		if self:knowTalent(self.T_SPACETIME_MASTERY) then
			power = self:combatSpellpower() * (1 + self:getTalentLevel(self.T_SPACETIME_MASTERY)/10)
		end
		
		if target:canBe("teleport") and self:checkHit(power, target:combatSpellResist() + (target:attr("continuum_destabilization") or 0)) then
			target:crossTierEffect(target.EFF_SPELLSHOCKED, self:combatSpellpower())
			-- first remove the target so the destination tile is empty
			game.level.map:remove(target.x, target.y, Map.ACTOR)
			local px, py 
			px, py = self.x, self.y
			if self:teleportRandom(tx, ty, 0) then
				-- return the target at the casters old location
				game.level.map(px, py, Map.ACTOR, target)
				self.x, self.y, target.x, target.y = target.x, target.y, px, py
				game.level.map:particleEmitter(target.x, target.y, 1, "temporal_teleport")
				game.level.map:particleEmitter(self.x, self.y, 1, "temporal_teleport")
				target:setEffect(target.EFF_CONTINUUM_DESTABILIZATION, 100, {power=self:combatSpellpower(0.3)})
				-- confuse them
				self:project(tg, target.x, target.y, DamageType.CONFUSION, { dur = t.getConfuseDuration(self, t), dam = t.getConfuseEfficency(self, t),	})
			else
				-- return the target without effect
				game.level.map(target.x, target.y, Map.ACTOR, target)
				game.logSeen(self, "주문이 헛나갔습니다!")
			end
		else
			game.logSeen(target, "%s 자리 교체를 저항했습니다!", (target.kr_name or target.name):capitalize():addJosa("가"))
		end

		game:playSoundNear(self, "talents/teleport")
		return true
	end,
	info = function(self, t)
		local range = self:getTalentRange(t)
		local duration = t.getConfuseDuration(self, t)
		local power = t.getConfuseEfficency(self, t)
		return ([[시공간 연속체를 다루어, 주변 %d 칸 내의 대상과 서로 자리를 바꿉니다. 대상은 %d 턴 동안 혼란 상태에 빠집니다. (혼란 수치 +%d%%)
		마법의 성공 확률은 주문력의 영향을 받아 증가합니다.]]):format (range, duration, power)
	end,
}

newTalent{
	name = "Displace Damage",
	kr_name = "피해 대체",
	type = {"chronomancy/spacetime-folding", 3},
	mode = "sustained",
	require = temporal_req3,
	sustain_paradox = 125,
	cooldown = 10,
	tactical = { BUFF = 2 },
	points = 5,
	no_energy = true,
	activate = function(self, t)
		return {}
	end,
	deactivate = function(self, t, p)
		return true
	end,
	info = function(self, t)
		return ([[주변의 공간을 구부려, %d%% 확률로 자신이 받은 피해량의 절반을 주변 %d 칸 범위 내의 적이 대신 받게 됩니다.]]):format(5 + self:getTalentLevel(t) * 5, self:getTalentLevelRaw(t) * 2)
	end,
}

newTalent{
	name = "Temporal Wake",
	kr_name = "시간의 흔적",
	type = {"chronomancy/spacetime-folding", 4},
	require = temporal_req4,
	points = 5,
	random_ego = "attack",
	paradox = 10,
	cooldown = 10,
	tactical = { ATTACK = {TEMPORAL = 1}, CLOSEIN = 2 },
	direct_hit = true,
	reflectable = true,
	requires_target = true,
	target = function(self, t)
		return {type="beam", range=self:getTalentRange(t), friendlyfire=false, talent=t}
	end,
	getDamage = function(self, t) return self:combatTalentSpellDamage(t, 20, 230) * getParadoxModifier(self, pm) end,
	range = function(self, t)
		return 2 + math.ceil(self:getTalentLevel(t)/2)
	end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		if not self:hasLOS(x, y) or game.level.map:checkEntity(x, y, Map.TERRAIN, "block_move") then game.logSeen(self, "그곳으로 이동할 수 없습니다.") return nil	end
		x, y = checkBackfire(self, x, y)
		local _ _, x, y = self:canProject(tg, x, y)
		
		-- indirect fire after the teleport from the x, y to our old starting spot would be best here 
		-- but checking for no_teleport we can make an educated guess rather or not the teleport will work
		if not game.level.map.attrs(x, y, "no_teleport") then
			local y = y
			if game.level.data.no_teleport_south and y  > self.y then 
				y = self.y
			end
			local dam = self:spellCrit(t.getDamage(self, t))
			self:project(tg, x, y, DamageType.TEMPORALSTUN, dam)
			game.level.map:particleEmitter(self.x, self.y, math.max(math.abs(x-self.x), math.abs(y-self.y)), "temporal_lightning", {tx=x-self.x, ty=y-self.y})
			game:playSoundNear(self, "talents/lightning")
		end
		
		-- since we're using a precise teleport we'll look for a free grid first
		local tx, ty = util.findFreeGrid(x, y, 5, true, {[Map.ACTOR]=true})
		if tx and ty then
			if not self:teleportRandom(tx, ty, 0) then
				game.logSeen(self, "주문이 헛나갔습니다!")
			end
		end
		
		return true
	end,
	info = function(self, t)
		local damage = t.getDamage(self, t)
		return ([[범위 내의 한 지점과 자신 사이의 공간을 강제로 접어, 해당 지점으로 이동합니다. 이동하면서 시간의 흔적을 남겨, 이동 경로에 있는 모든 적들에게 %0.2f 시간 피해를 주고 4 턴 동안 기절시킵니다.
		피해량은 괴리 수치와 주문력 수치, 이동 범위는 기술 레벨의 영향을 받아 증가합니다.]]):
		format(damDesc(self, DamageType.TEMPORAL, damage))
	end,
}

--[=[newTalent{
	name = "Kinetic Folding",
	kr_name = "동역학적 공간 접기",
	type = {"chronomancy/spacetime-folding", 4},
	require = temporal_req4,
	points = 5,
	paradox = 10,
	cooldown = 12,
	tactical = { ATTACK = 2 },
	range = 10,
	direct_hit = true,
	requires_target = true,
	target = function(self, t)
		return {type="hit", range=self:getTalentRange(t), talent=t}
	end,
	on_pre_use = function(self, t, silent) if not self:hasDualWeapon() then if not silent then game.logPlayer(self, "이 기술을 사용하려면 쌍수 무장을 해야 합니다.") end return false end return true end,
	getDamage = function(self, t) return self:combatTalentWeaponDamage(t, 1.1, 1.9) * getParadoxModifier(self, pm) end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		x, y = checkBackfire(self, x, y)
		local target = game.level.map(x, y, Map.ACTOR)
		if target then
			self:attackTarget(target, nil, t.getDamage(self, t), true)
		else
			return
		end
		return true
	end,
	info = function(self, t)
		local damage = t.getDamage(self, t)
		return ([[당신은 잠시 당신과 목표 사이의 공간을 접고, 두 손의 무기로 공격하여 %d%% 의 무기 피해를 줍니다.
		피해량은 괴리 수치의 영향을 받아 증가합니다.]]):
		format (damage*100)
	end,
}]=]
