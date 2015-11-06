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

-- some helpers

local function cooldown_folds(self, t)
	for tid, cd in pairs(self.talents_cd) do
		local tt = self:getTalentFromId(tid)
		if tt.type[1]:find("^chronomancy/manifold") and t ~= tt then
			self:alterTalentCoolingdown(tt, -1)
		end
	end
end

local function do_folds(self, target)
	for tid, _ in pairs(self.talents) do
		local tt = self:getTalentFromId(tid)
		if tt.type[1]:find("^chronomancy/manifold") and self:knowTalent(tid) then
			self:callTalent(tid, "doFold", target)
		end
	end
end

newTalent{
	name = "Fold Fate",
	kr_name = "운명 감기",
	type = {"chronomancy/manifold", 1},
	cooldown = 8,
	points = 5,
	mode = "passive",
	range = 10,
	target = function(self, t)
		return {type="ball", range=self:getTalentRange(t), radius=self:getTalentRadius(t), friendlyfire=false, talent=t}
	end,
	radius = function(self, t) return self:getTalentLevel(self.T_WEAPON_MANIFOLD) >= 4 and 2 or 1 end,
	getChance = function(self, t) return self:callTalent(self.T_WEAPON_MANIFOLD, "getChance") end, 
	getDamage = function(self, t) return self:callTalent(self.T_WEAPON_MANIFOLD, "getDamage") end,
	getResists = function(self, t) return self:callTalent(self.T_WEAPON_MANIFOLD, "getResists") end,
	getDuration = function(self, t) return self:callTalent(self.T_WEAPON_MANIFOLD, "getDuration") end,
	doFold = function(self, t, target)
		if rng.percent(t.getChance(self, t)) then
			if not self:isTalentCoolingDown(t.id) then
				-- Temporal Burst
				local tg = self:getTalentTarget(t)
				self:project(tg, target.x, target.y, function(px, py, tg, self)
					local target = game.level.map(px, py, Map.ACTOR)
					if target then
						DamageType:get(DamageType.TEMPORAL).projector(self, target.x, target.y, DamageType.TEMPORAL, t.getDamage(self, t))
						target:setEffect(target.EFF_FOLD_FATE, t.getDuration(self, t), {power=t.getResists(self, t), apply_power=getParadoxSpellpower(self, t), no_ct_effect=true})
					end
				end)
				
				self:startTalentCooldown(t.id)
				game.level.map:particleEmitter(target.x, target.y, tg.radius, "generic_sploom", {rm=230, rM=255, gm=230, gM=255, bm=30, bM=51, am=35, aM=90, radius=tg.radius, basenb=60})
			else
				cooldown_folds(self, t)
			end
		end	
	end,
	info = function(self, t)
		local chance = t.getChance(self, t)
		local damage = t.getDamage(self, t)
		local radius = self:getTalentRadius(t)
		local resists = t.getResists(self, t)
		local duration = t.getDuration(self, t)
		return ([[당신이 무기 덧대기가 활성화 된 상태로 공격이 적중하였을 때, %d%% 확률로 추가적인 %0.2f 의 시간 피해를 %d 범위 내의 적에게 입힙니다. 영향을 받은 목표는 %d%% 의 물리, 시간 저항력을 %d 턴간 잃을 수 있습니다.
		이 기술은 재사용 대기 시간이 있습니다. 만약 이 스킬이 대기 시간 도중에 발동 된다면, 피해를 주는 대신에 중력 감기와 왜곡 감기의 재사용 대기 시간이 1 턴 줄어듭니다.]])
		:format(chance, damDesc(self, DamageType.TEMPORAL, damage), radius, resists, duration)
	end,
}

newTalent{
	name = "Fold Warp",
	kr_name = "왜곡 감기",
	type = {"chronomancy/manifold", 1},
	cooldown = 8,
	points = 5,
	mode = "passive",
	range = 10,
	target = function(self, t)
		return {type="ball", range=self:getTalentRange(t), radius=self:getTalentRadius(t), friendlyfire=false, talent=t}
	end,
	radius = function(self, t) return self:getTalentLevel(self.T_WEAPON_MANIFOLD) >= 4 and 2 or 1 end,
	getChance = function(self, t) return self:callTalent(self.T_WEAPON_MANIFOLD, "getChance") end, 
	getDamage = function(self, t) return self:callTalent(self.T_WEAPON_MANIFOLD, "getDamage") end,
	getDuration = function(self, t) return self:callTalent(self.T_WEAPON_MANIFOLD, "getDuration") end,
	doFold = function(self, t, target)
		if rng.percent(t.getChance(self, t)) then
			if not self:isTalentCoolingDown(t.id) then
				-- Warp Burst
				local tg = self:getTalentTarget(t)
				self:project(tg, target.x, target.y, function(px, py, tg, self)
					local target = game.level.map(px, py, Map.ACTOR)
					if target then
						DamageType:get(DamageType.WARP).projector(self, px, py, DamageType.WARP, t.getDamage(self, t))
						DamageType:get(DamageType.RANDOM_WARP).projector(self, px, py, DamageType.RANDOM_WARP, {dur=t.getDuration(self, t), apply_power=getParadoxSpellpower(self, t)})
					end
				end)
				
				self:startTalentCooldown(t.id)
				game.level.map:particleEmitter(target.x, target.y, tg.radius, "generic_sploom", {rm=64, rM=64, gm=134, gM=134, bm=170, bM=170, am=35, aM=90, radius=tg.radius, basenb=60})
			else
				cooldown_folds(self, t)
			end
		end	
	end,
	info = function(self, t)
		local chance = t.getChance(self, t)
		local damage = t.getDamage(self, t)
		local radius = self:getTalentRadius(t)
		local duration = t.getDuration(self, t)
		return ([[당신이 무기 덧대기가 활성화 된 상태로 공격이 적중하였을 때, %d%% 확률로 추가적인 %0.2f 의 물리 피해와, %0.2f 의 시간 피해를 %d 범위 내의 적에게 입힙니다. 영향을 받은 목표는 %d 턴 동안 기절, 실명, 혼란, 속박 될 수 있습니다.
		이 기술은 재사용 대기 시간이 있습니다. 만약 이 스킬이 대기 시간 도중에 발동 된다면, 피해를 주는 대신에 중력 감기와 운명 감기의 재사용 대기 시간이 1 턴 줄어듭니다.]])
		:format(chance, damDesc(self, DamageType.TEMPORAL, damage/2), damDesc(self, DamageType.PHYSICAL, damage/2), radius, duration)
	end,
}

newTalent{
	name = "Fold Gravity",
	kr_name = "중력 감기",
	type = {"chronomancy/manifold", 1},
	cooldown = 8,
	points = 5,
	mode = "passive",
	range = 10,
	radius = function(self, t) return self:getTalentLevel(self.T_WEAPON_MANIFOLD) >= 4 and 2 or 1 end,
	target = function(self, t)
		return {type="ball", range=self:getTalentRange(t), radius=self:getTalentRadius(t), friendlyfire=false, talent=t}
	end,
	getChance = function(self, t) return self:callTalent(self.T_WEAPON_MANIFOLD, "getChance") end, 
	getDamage = function(self, t) return self:callTalent(self.T_WEAPON_MANIFOLD, "getDamage") end,
	getDuration = function(self, t) return self:callTalent(self.T_WEAPON_MANIFOLD, "getDuration") end,
	getSlow = function(self, t) return self:callTalent(self.T_WEAPON_MANIFOLD, "getSlow") end,
	doFold = function(self, t, target)
		if rng.percent(t.getChance(self, t)) then
			if not self:isTalentCoolingDown(t.id) then
				-- Gravity Burst
				local tg = self:getTalentTarget(t)
				self:project(tg, target.x, target.y, function(px, py, tg, self)
					local target = game.level.map(px, py, Map.ACTOR)
					if target then
						target:setEffect(target.EFF_SLOW, t.getDuration(self, t), {power=t.getSlow(self, t)/100, apply_power=getParadoxSpellpower(self, t), no_ct_effect=true})
						DamageType:get(DamageType.GRAVITY).projector(self, target.x, target.y, DamageType.GRAVITY, t.getDamage(self, t))
					end
				end)
				
				self:startTalentCooldown(t.id)
				game.level.map:particleEmitter(target.x, target.y, tg.radius, "generic_sploom", {rm=205, rM=205, gm=133, gM=133, bm=63, bM=63, am=35, aM=90, radius=tg.radius, basenb=60})
			else
				cooldown_folds(self, t)
			end
		end	
	end,
	info = function(self, t)
		local chance = t.getChance(self, t)
		local damage = t.getDamage(self, t)
		local radius = self:getTalentRadius(t)
		local slow = t.getSlow(self, t)
		local duration = t.getDuration(self, t)
		return ([[당신이 무기 덧대기가 활성화 된 상태로 공격이 적중하였을 때, %d%% 확률로 추가적인 %0.2f 의 물리 피해를 %d 범위 내의 적에게 입힙니다. 영향을 받은 목표는 %d%% 만큼 %d 턴 동안 느려집니다.
		이 기술은 재사용 대기 시간이 있습니다. 만약 이 스킬이 대기 시간 도중에 발동 된다면, 피해를 주는 대신에 운명 감기와 왜곡 감기의 재사용 대기 시간이 1 턴 줄어듭니다.]])
		:format(chance, damDesc(self, DamageType.PHYSICAL, damage), radius, slow, duration)
	end,
}

newTalent{
	name = "Weapon Folding",
	kr_name = "무기 덧대기",
	type = {"chronomancy/temporal-combat", 1},
	mode = "sustained",
	require = chrono_req1,
	sustain_paradox = 12,
	cooldown = 10,
	tactical = { BUFF = 2 },
	points = 5,
	getChance = function(self, t) return self:combatTalentLimit(t, 40, 10, 30) end,
	activate = function(self, t)
		game:playSoundNear(self, "talents/spell_generic")
		
		return {}
	end,
	deactivate = function(self, t, p)
		return true
	end,
	getDamage = function(self, t) return 7 + getParadoxSpellpower(self, t, 0.092) * self:combatTalentScale(t, 1, 7) end,
	doWeaponFolding = function(self, t, target)
		if rng.percent(t.getChance(self, t)) then
			self.energy.value = self.energy.value + 100
		end	
		
		-- Check folds?
		do_folds(self, target)
	
		local dam = t.getDamage(self, t)
		if not target.dead then
			DamageType:get(DamageType.TEMPORAL).projector(self, target.x, target.y, DamageType.TEMPORAL, dam)
		end
	end,
	info = function(self, t)
		local damage = t.getDamage(self, t)
		local chance = t.getChance(self, t)
		return ([[당신의 무기 (혹은 투사체)에 하나의 차원을 덧대어 공격을 맞출 때마다 %0.2f 의 시간 피해를 추가합니다.
		또한 무기 공격 성공시 당신은 %d%% 의 확률로 10%%의 턴을 얻을 수 있습니다.
		피해량은 주문력에 비례하여 상승합니다.]]):format(damDesc(self, DamageType.TEMPORAL, damage), chance)
	end,
}

newTalent{
	name = "Invigorate",
	kr_name = "활성화",
	type = {"chronomancy/temporal-combat", 2},
	require = chrono_req2,
	points = 5,
	paradox = function (self, t) return getParadoxCost(self, t, 12) end,
	cooldown = 24,
	fixed_cooldown = true,
	tactical = { HEAL = 1 },
	getDuration = function(self, t) return getExtensionModifier(self, t, math.floor(self:combatTalentLimit(t, 14, 4, 8))) end, -- Limit < 14
	getPower = function(self, t) return self:combatTalentSpellDamage(t, 10, 50, getParadoxSpellpower(self, t)) end,
	action = function(self, t)
		self:setEffect(self.EFF_INVIGORATE, t.getDuration(self,t), {power=t.getPower(self, t)})
		
		game:playSoundNear(self, "talents/heal")
		return true
	end,
	info = function(self, t)
		local power = t.getPower(self, t)
		local duration = t.getDuration(self, t)
		return ([[다음 %d 턴 동안 매 턴마다 %0.1f 생명력을 회복하고, 재사용 대기 시간이 고정된 기술을 제외한 모든 기술들의 재사용 대기 시간이 2 배 빨리 감소됩니다.
		생명력 회복은 주문력에 비례하여 상승합니다.]]):format(duration, power)
	end,
}

newTalent{
	name = "Weapon Manifold",
	kr_name = "무기 감싸기",
	type = {"chronomancy/temporal-combat", 3},
	require = chrono_req3,
	mode = "passive",
	points = 5,
	cooldown = 8,
	on_learn = function(self, t)
		local lev = self:getTalentLevelRaw(t)
		if lev == 1 then
			self:learnTalent(Talents.T_FOLD_FATE, true, nil, {no_unlearn=true})
			self:learnTalent(Talents.T_FOLD_GRAVITY, true, nil, {no_unlearn=true})
			self:learnTalent(Talents.T_FOLD_WARP, true, nil, {no_unlearn=true})
		end
	end,
	on_unlearn = function(self, t)
		local lev = self:getTalentLevelRaw(t)
		if lev == 0 then
			self:unlearnTalent(Talents.T_FOLD_FATE)
			self:unlearnTalent(Talents.T_FOLD_GRAVITY)
			self:unlearnTalent(Talents.T_FOLD_WARP)
		end
	end,
	radius = function(self, t) return self:getTalentLevel(t) >= 4 and 2 or 1 end,
	getDuration = function(self, t) return getExtensionModifier(self, t, 2) end,
	getDamage = function(self, t) return 7 + getParadoxSpellpower(self, t, 0.092) * self:combatTalentScale(t, 1, 7) end,
	getChance = function(self, t) return self:combatTalentLimit(t, 40, 10, 30) end,
	getSlow = function(self, t) return 30 end,
	getResists = function(self, t) return 30 end,
	info = function(self, t)
		local chance = t.getChance(self, t)
		local damage = t.getDamage(self, t)
		local radius = self:getTalentRadius(t)
		local slow = t.getSlow(self, t)
		local duration = t.getDuration(self, t)
		local resists = t.getResists(self, t)
		return ([[당신은 이제 %d%% 의 확률로 무기 덧대기 피해에 운명, 중력, 왜곡을 감을 수 있습니다.
		
		운명 감기: %0.2f 의 시간 피해를 %d 범위 내의 적에게 입힙니다. 영향을 받은 목표는 %d%% 의 물리, 시간 저항력을 %d 턴간 잃을 수 있습니다.
		왜곡 감기: %0.2f 의 물리 피해와, %0.2f 의 시간 피해를 %d 범위 내의 적에게 입힙니다. 영향을 받은 목표는 %d 턴 동안 기절, 실명, 혼란, 속박 될 수 있습니다.
		중력 감기: %0.2f 의 물리 피해를 %d 범위 내의 적에게 입힙니다. 영향을 받은 목표는 %d%% 만큼 %d 턴 동안 느려집니다.
		각각의 무기 감써기는 8 턴의 재사용 대기 시간이 있습니다. 만약 대기 시간 도중에 효과가 발동 되었다면 다른 두 무기 감싸기의 대기 시간을 1 턴 줄입니다.]])
		:format(chance, damDesc(self, DamageType.TEMPORAL, damage), radius, resists, duration, damDesc(self, DamageType.PHYSICAL, damage/2), damDesc(self, DamageType.TEMPORAL, damage/2), radius,
		duration, damDesc(self, DamageType.PHYSICAL, damage), radius, slow, duration)
	end,
}

newTalent{
	name = "Breach",
	kr_name = "관통",
	type = {"chronomancy/temporal-combat", 4},
	require = chrono_req4,
	points = 5,
	cooldown = 8,
	paradox = function (self, t) return getParadoxCost(self, t, 12) end,
	tactical = { ATTACK = {weapon = 2}, DISABLE = 3 },
	requires_target = true,
	range = function(self, t)
		if self:hasArcheryWeapon() then return util.getval(archery_range, self, t) end
		return 1
	end,
	is_melee = function(self, t) return not self:hasArcheryWeapon() end,
	speed = function(self, t) return self:hasArcheryWeapon() and "archery" or "weapon" end,
	getDamage = function(self, t) return self:combatTalentWeaponDamage(t, 1, 1.5) end,
	getDuration = function(self, t) return getExtensionModifier(self, t, math.floor(self:combatTalentScale(t, 3, 7))) end,
	on_pre_use = function(self, t, silent) if self:attr("disarmed") then if not silent then game.logPlayer(self, "이 기술을 사용하기 위해서는 무기가 필요합니다.") end return false end return true end,
	archery_onhit = function(self, t, target, x, y)
		target:setEffect(target.EFF_BREACH, t.getDuration(self, t), {apply_power=getParadoxSpellpower(self, t)})
	end,
	action = function(self, t)

		if self:hasArcheryWeapon() then
			-- Ranged attack
			local targets = self:archeryAcquireTargets({type="bolt"}, {one_shot=true, no_energy = true})
			if not targets then return end
			self:archeryShoot(targets, t, {type="bolt"}, {mult=t.getDamage(self, t)})
		else
			-- Melee attack
			local tg = {type="hit", range=self:getTalentRange(t), talent=t}
			local _, x, y = self:canProject(tg, self:getTarget(tg))
			local target = game.level.map(x, y, game.level.map.ACTOR)
			if not target then return nil end
			
			local hitted = self:attackTarget(target, nil, t.getDamage(self, t), true)

			if hitted then
				target:setEffect(target.EFF_BREACH, t.getDuration(self, t), {apply_power=getParadoxSpellpower(self, t)})
			end
		end

		return true
	end,
	info = function(self, t)
		local duration = t.getDuration(self, t)
		local damage = t.getDamage(self, t) * 100
		return ([[목표를 당신의 장거리 혹은 근거리 무기로 공격하여 %d%% 무기 피해를 입힙니다.
		만약 공격이 맞았다면 당신은 목표의 방어를 부수어, %d 턴동안 방어율, 기절, 속박, 실명, 혼란 저항력을 반으로 깎아 내립니다.
		관통 확률은 주문력에 비례하여 상승합니다.]])
		:format(damage, duration)
	end
}
