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
local function aura_strength(self, t)
	return self:combatTalentMindDamage(t, 10, 40)
end

local function aura_spike_strength(self, t)
	return aura_strength(self, t) * 10
end

local function aura_mastery(self, t)
	return 9 + self:getTalentLevel(t)
end

local function aura_range(self, t)
	-- Spiked ability
	if self:isTalentActive(t.id) then
		if type(t.getSpikedRange) == "function" then return t.getSpikedRange(self, t) end
		return t.getSpikedRange
	-- Normal ability
	else
		if type(t.getNormalRange) == "function" then return t.getNormalRange(self, t) end
		return t.getNormalRange
	end
end

local function aura_radius(self, t)
	-- Spiked ability
	if self:isTalentActive(t.id) then
		if type(t.getSpikedRadius) == "function" then return t.getSpikedRadius(self, t) end
		return t.getSpikedRadius
	-- Normal ability
	else
		if type(t.getNormalRadius) == "function" then return t.getNormalRadius(self, t) end
		return t.getNormalRadius
	end
end

local function aura_target(self, t)
	-- Spiked ability
	if self:isTalentActive(t.id) then
		if type(t.getSpikedTarget) == "function" then return t.getSpikedTarget(self, t) end
		return t.getSpikedTarget
	-- Normal ability
	else
		if type(t.getNormalTarget) == "function" then return t.getNormalTarget(self, t) end
		return t.getNormalTarget
	end
end

newTalent{
	name = "Kinetic Aura",
	kr_name = "동역학적 오러 발산",
	type = {"psionic/projection", 1},
	require = psi_wil_req1, no_sustain_autoreset = true,
	points = 5,
	mode = "sustained",
	sustain_psi = 10,
	remove_on_zero = true,
	cooldown = 10,
	tactical = { ATTACKAREA = { PHYSICAL = 2 } },
	on_pre_use = function(self, t, silent)
		if self:isTalentActive(self.T_THERMAL_AURA) and self:isTalentActive(self.T_CHARGED_AURA) then
			if not silent then game.logSeen(self, "한 번에 2 개의 오러만을 유지할 수 있습니다. 오러 발산이 취소됩니다.") end
			return false
		end
		return true
	end,
	range = aura_range,
	radius = aura_radius,
	target = aura_target,
	getSpikedRange = function(self, t) return 6 end,
	getNormalRange = function(self, t)
		return 0
	end,
	getSpikedRadius = function(self, t)
		return 0
	end,
	getNormalRadius = function(self, t)
		if self:hasEffect(self.EFF_TRANSCENDENT_TELEKINESIS) then return 2 end
		return 1
	end,
	getSpikedTarget = function(self, t)
		return {type="beam", nolock=true, range=t.getSpikedRange(self, t), talent=t}
	end,
	getNormalTarget = function(self, t)
		return {type="ball", range=t.getNormalRange(self, t), radius=t.getNormalRadius(self, t), selffire=false, friendlyfire=false}
	end,
	requires_target = function(self, t)
		-- Spiked ability
		if self:isTalentActive(t.id) and self:getPsi() > t.getSpikeCost(self, t) then
			return true
		-- Normal ability
		else
			return false
		end
	end,
	getSpikeCost = function(self, t)
		return t.sustain_psi*2/3
	end,
	getAuraStrength = function(self, t)
		return aura_strength(self, t)
	end,
	getAuraSpikeStrength = function(self, t)
		return aura_spike_strength(self, t)
	end,
	getKnockback = function(self, t)
		return 3 + math.floor(self:getTalentLevel(t))
	end,
	do_kineticaura = function(self, t)
		local mast = aura_mastery(self, t)
		local dam = t.getAuraStrength(self, t)
		local tg = t.getNormalTarget(self, t)
		self:project(tg, self.x, self.y, function(tx, ty)
			local act = game.level.map(tx, ty, engine.Map.ACTOR)
			if act then
				self:incPsi(-dam/mast)
				self:breakStepUp()
			end
			DamageType:get(DamageType.PHYSICAL).projector(self, tx, ty, DamageType.PHYSICAL, dam)
		end)
	end,
	do_combat = function(self, t, target) -- called by  _M:attackTargetWith in mod.class.interface.Combat.lua
		local k_dam = t.getAuraStrength(self, t)
		DamageType:get(DamageType.PHYSICAL).projector(self, target.x, target.y, DamageType.PHYSICAL, k_dam)
	end,
	activate = function(self, t)
		self.energy.value = self.energy.value + game.energy_to_act * self:combatMindSpeed()
		return {}
	end,
	deactivate = function(self, t, p)
		if self:attr("save_cleanup") then return true end
		local dam = t.getAuraSpikeStrength(self, t)
		local cost = t.getSpikeCost(self, t)
		if self:getPsi() <= cost then
			game.logPlayer(self, "아무 반응 없이, 동역학적 오러가 사라졌습니다.")
			return true
		end

		local tg = t.getSpikedTarget(self, t)
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		local actor = game.level.map(x, y, Map.ACTOR)
		--if core.fov.distance(self.x, self.y, x, y) == 1 and not actor then return true end
		if core.fov.distance(self.x, self.y, x, y) == 0 then return true end
		self:project(tg, x, y, DamageType.MINDKNOCKBACK, self:mindCrit(rng.avg(0.8*dam, dam)))
		local _ _, x, y = self:canProject(tg, x, y)
		game.level.map:particleEmitter(self.x, self.y, tg.radius, "matter_beam", {tx=x-self.x, ty=y-self.y})
		self:incPsi(-cost)

		return true
	end,

	info = function(self, t)
		local dam = t.getAuraStrength(self, t)
		local spikedam = t.getAuraSpikeStrength(self, t)
		local mast = aura_mastery(self, t)
		local spikecost = t.getSpikeCost(self, t)
		return ([[주변의 대기에 동역학적 힘을 불어넣어, 근처의 적들에게 피해를 줍니다.
		염동력으로 보석이나 마석을 쥐고 있을 경우, 접근하는 적들에게 %0.1f 물리 피해를 가합니다.
		오러로 총 %0.1f 피해를 줄 때마다 염력이 1 씩 소모됩니다.
		염동력으로 무기를 쥐고 있을 경우, 무기 피해에 추가적으로 %0.1f 물리 피해가 더해집니다.
		동역학적 오러를 해제할 때, %d 염력을 사용하여 강력한 동역학적 반응을 일으킬 수 있습니다. 이 반응은 최대 %d 의 물리 피해를 주고 적들을 밀어내며, 적을 관통하는 사정거리 %d 칸의 화살 형태로 발사됩니다.
		#{bold}#오러 발산에는 시간이 소모되지 않지만, 오러 해제에는 시간이 소모됩니다.#{normal}#
		동역학적 반응을 일으키지 않으려면, 동역학적 오러를 해제하고 자기 자신을 반응의 대상으로 삼으면 됩니다. 
		피해량은 정신력의 영향을 받아 증가합니다.]]): 
		format(damDesc(self, DamageType.PHYSICAL, dam), mast, damDesc(self, DamageType.PHYSICAL, dam), spikecost,
		damDesc(self, DamageType.PHYSICAL, spikedam), t.getSpikedRange(self, t)) --@ 변수 순서 조정
	end,
}


newTalent{
	name = "Thermal Aura",
	kr_name = "열역학적 오러 발산",
	type = {"psionic/projection", 1},
	require = psi_wil_req2, no_sustain_autoreset = true,
	points = 5,
	mode = "sustained",
	sustain_psi = 10,
	remove_on_zero = true,
	cooldown = 10,
	tactical = { ATTACKAREA = { FIRE = 2 } },
	on_pre_use = function(self, t, silent)
		if self:isTalentActive(self.T_KINETIC_AURA) and self:isTalentActive(self.T_CHARGED_AURA) then
			if not silent then game.logSeen(self, "한 번에 2 개의 오러만을 유지할 수 있습니다. 오러 발산이 취소됩니다.") end
			return false
		end
		return true
	end,
	range = aura_range,
	radius = aura_radius,
	target = aura_target,
	getSpikedRange = function(self, t)
		return 0
	end,
	getNormalRange = function(self, t)
		return 0
	end,
	getSpikedRadius = function(self, t) return 6 end,
	getNormalRadius = function(self, t)
		if self:hasEffect(self.EFF_TRANSCENDENT_PYROKINESIS) then return 2 end
		return 1
	end,
	getSpikedTarget = function(self, t)
		return {type="cone", range=t.getSpikedRange(self, t), radius=t.getSpikedRadius(self, t), selffire=false, talent=t}
	end,
	getNormalTarget = function(self, t)
		return {type="ball", range=t.getNormalRange(self, t), radius=t.getNormalRadius(self, t), selffire=false, friendlyfire=false}
	end,
	requires_target = function(self, t)
		-- Spiked ability
		if self:isTalentActive(t.id) and self:getPsi() > t.getSpikeCost(self, t) then
			return true
		-- Normal ability
		else
			return false
		end
	end,
	getAuraStrength = function(self, t)
		return aura_strength(self, t)
	end,
	getAuraSpikeStrength = function(self, t)
		return aura_spike_strength(self, t)
	end,
	getSpikeCost = function(self, t)
		return t.sustain_psi*2/3
	end,
	do_thermalaura = function(self, t)
		local mast = aura_mastery(self, t)
		local dam = t.getAuraStrength(self, t)
		local tg = t.getNormalTarget(self, t)
		self:project(tg, self.x, self.y, function(tx, ty)
			local act = game.level.map(tx, ty, engine.Map.ACTOR)
			if act then
				self:incPsi(-dam/mast)
				self:breakStepUp()
			end
			DamageType:get(DamageType.FIRE).projector(self, tx, ty, DamageType.FIRE, dam)
		end)
	end,
	do_combat = function(self, t, target) -- called by  _M:attackTargetWith in mod.class.interface.Combat.lua
		local t_dam = t.getAuraStrength(self, t)
		DamageType:get(DamageType.FIRE).projector(self, target.x, target.y, DamageType.FIRE, t_dam)
	end,
	activate = function(self, t)
		self.energy.value = self.energy.value + game.energy_to_act * self:combatMindSpeed()
		return {}
	end,
	deactivate = function(self, t, p)
		if self:attr("save_cleanup") then return true end
		local dam = t.getAuraSpikeStrength(self, t)
		local cost = t.getSpikeCost(self, t)
		--if self:isTalentActive(self.T_CONDUIT) then return true end
		if self:getPsi() <= cost then
			game.logPlayer(self, "아무 반응 없이, 열역학적 오러가 사라졌습니다.")
			return true
		end

		local tg = t.getSpikedTarget(self, t)
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		local actor = game.level.map(x, y, Map.ACTOR)
		--if core.fov.distance(self.x, self.y, x, y) == 1 and not actor then return true end
		if core.fov.distance(self.x, self.y, x, y) == 0 then return true end
		self:project(tg, x, y, DamageType.FIREBURN, self:mindCrit(rng.avg(0.8*dam, dam)))
		game.level.map:particleEmitter(self.x, self.y, tg.radius, "breath_fire", {radius=tg.radius, tx=x-self.x, ty=y-self.y})
		game:playSoundNear(self, "talents/fire")
		self:incPsi(-cost)
		return true
	end,

	info = function(self, t)
		local dam = t.getAuraStrength(self, t)
		local rad = t.getSpikedRadius(self,t)
		local spikedam = t.getAuraSpikeStrength(self, t)
		local mast = aura_mastery(self, t)
		local spikecost = t.getSpikeCost(self, t)
		return ([[주변의 대기에 열역학적 힘을 불어넣어, 근처의 적들에게 피해를 줍니다.
		염동력으로 보석이나 마석을 쥐고 있을 경우, 접근하는 적들에게 %0.1f 화염 피해를 가합니다.
		오러로 총 %0.1f 피해를 줄 때마다 염력이 1 씩 소모됩니다.
		염동력으로 무기를 쥐고 있을 경우, 무기 피해에 추가적으로 %0.1f 화염 피해가 더해집니다.
		열역학적 오러를 해제할 때, %d 염력을 사용하여 강력한 열역학적 반응을 일으킬 수 있습니다. 이 반응은 전방 %d 칸의 원뿔 반경에 최대 %d 화염 피해를 몇 턴 동안 나눠서 줍니다.
		#{bold}#오러 발산에는 시간이 소모되지 않지만, 오러 해제에는 시간이 소모됩니다.#{normal}#
		열역학적 반응을 일으키지 않으려면, 열역학적 오러를 해제하고 자기 자신을 반응의 대상으로 삼으면 됩니다. 
		피해량은 정신력의 영향을 받아 증가합니다.]]): 
		format(damDesc(self, DamageType.FIRE, dam), mast, damDesc(self, DamageType.FIRE, dam), spikecost, rad,
		damDesc(self, DamageType.FIRE, spikedam))
	end,
}

newTalent{
	name = "Charged Aura",
	kr_name = "전하적 오러 발산",
	type = {"psionic/projection", 1},
	require = psi_wil_req3, no_sustain_autoreset = true,
	points = 5,
	mode = "sustained",
	sustain_psi = 10,
	remove_on_zero = true,
	cooldown = 10,
	tactical = { ATTACKAREA = { LIGHTNING = 2 } },
	on_pre_use = function(self, t, silent)
		if self:isTalentActive(self.T_KINETIC_AURA) and self:isTalentActive(self.T_THERMAL_AURA) then
			if not silent then game.logSeen(self, "한 번에 2 개의 오러만을 유지할 수 있습니다. 오러 발산이 취소됩니다.") end
			return false
		end
		return true
	end,
	range = aura_range,
	radius = aura_radius,
	target = aura_target,
	getSpikedRange = function(self, t) return 6 end,
	getNormalRange = function(self, t)
		return 0
	end,
	getSpikedRadius = function(self, t)
		return 10
	end,
	getNormalRadius = function(self, t)
		if self:hasEffect(self.EFF_TRANSCENDENT_ELECTROKINESIS) then return 2 end
		return 1
	end,
	getSpikedTarget = function(self, t)
		return {type="ball", range=t.getSpikedRange(self, t), radius=t.getSpikedRadius(self, t), friendlyfire=false}
	end,
	getNormalTarget = function(self, t)
		return {type="ball", range=t.getNormalRange(self, t), radius=t.getNormalRadius(self, t), selffire=false, friendlyfire=false}
	end,
	requires_target = function(self, t)
		-- Spiked ability
		if self:isTalentActive(t.id) and self:getPsi() > t.getSpikeCost(self, t) then
			return true
		-- Normal ability
		else
			return false
		end
	end,
	getSpikeCost = function(self, t)
		return t.sustain_psi*2/3
	end,
	getAuraStrength = function(self, t)
		return aura_strength(self, t)
	end,
	getAuraSpikeStrength = function(self, t)
		return aura_spike_strength(self, t)
	end,
	getNumSpikeTargets = function(self, t)
		return 1 + math.floor(0.5*self:getTalentLevel(t))
	end,
	do_chargedaura = function(self, t)
		local mast = aura_mastery(self, t)
		local dam = t.getAuraStrength(self, t)
		local tg = t.getNormalTarget(self, t)
		self:project(tg, self.x, self.y, function(tx, ty)
			local act = game.level.map(tx, ty, engine.Map.ACTOR)
			if act then
				self:incPsi(-dam/mast)
				self:breakStepUp()
			end
			DamageType:get(DamageType.LIGHTNING).projector(self, tx, ty, DamageType.LIGHTNING, dam)
		end)
	end,
	do_combat = function(self, t, target) -- called by  _M:attackTargetWith in mod.class.interface.Combat.lua
		local c_dam = t.getAuraStrength(self, t)
		DamageType:get(DamageType.LIGHTNING).projector(self, target.x, target.y, DamageType.LIGHTNING, c_dam)
	end,
	activate = function(self, t)
		game:playSoundNear(self, "talents/thunderstorm")
			self.energy.value = self.energy.value + game.energy_to_act * self:combatMindSpeed()
		return {}
	end,
	deactivate = function(self, t, p)
		if self:attr("save_cleanup") then return true end
		local dam = t.getAuraSpikeStrength(self, t)
		local cost = t.getSpikeCost(self, t)
		--if self:isTalentActive(self.T_CONDUIT) then return true end
		if self:getPsi() <= cost then
			game.logPlayer(self, "아무 반응 없이, 전하적 오러가 사라졌습니다.")
			return true
		end

		local tg = {type="bolt", nolock=true, range=self:getTalentRange(t), talent=t}
		local fx, fy = self:getTarget(tg)
		if not fx or not fy then return nil end
		if core.fov.distance(self.x, self.y, fx, fy) == 0 then return true end

		local nb = t.getNumSpikeTargets(self, t)
		local affected = {}
		local first = nil
		--Here's the part where deactivating the aura fires off a huge chain lightning
		self:project(tg, fx, fy, function(dx, dy)
			print("[Chain lightning] targetting", fx, fy, "from", self.x, self.y)
			local actor = game.level.map(dx, dy, Map.ACTOR)
			if actor and not affected[actor] then
				ignored = false
				affected[actor] = true
				first = actor

				print("[Chain lightning] looking for more targets", nb, " at ", dx, dy, "radius ", 10, "from", actor.name)
				self:project({type="ball", friendlyfire=false, x=dx, y=dy, radius=self:getTalentRange(t), range=0}, dx, dy, function(bx, by)
					local actor = game.level.map(bx, by, Map.ACTOR)
					if actor and not affected[actor] and self:reactionToward(actor) < 0 then
						print("[Chain lightning] found possible actor", actor.name, bx, by, "distance", core.fov.distance(dx, dy, bx, by))
						affected[actor] = true
					end
				end)
				return true
			end
		end)

		if not first then return true end
		local targets = { first }
		affected[first] = nil
		local possible_targets = table.listify(affected)
		print("[Chain lightning] Found targets:", #possible_targets)
		for i = 2, nb do
			if #possible_targets == 0 then break end
			local act = rng.tableRemove(possible_targets)
			targets[#targets+1] = act[1]
		end

		local sx, sy = self.x, self.y
		for i, actor in ipairs(targets) do
			local tgr = {type="beam", range=self:getTalentRange(t), friendlyfire=false, talent=t, x=sx, y=sy}
			print("[Chain lightning] jumping from", sx, sy, "to", actor.x, actor.y)
			self:project(tgr, actor.x, actor.y, DamageType.LIGHTNING_DAZE, {power_check=self:combatMindpower(), dam=self:mindCrit(rng.avg(0.8*dam, dam)), daze=50})
			game.level.map:particleEmitter(sx, sy, math.max(math.abs(actor.x-sx), math.abs(actor.y-sy)), "lightning", {tx=actor.x-sx, ty=actor.y-sy, nb_particles=150, life=6})
			sx, sy = actor.x, actor.y
		end
		game:playSoundNear(self, "talents/lightning")
		self:incPsi(-cost)
		return true
	end,

	info = function(self, t)
		local dam = t.getAuraStrength(self, t)
		local spikedam = t.getAuraSpikeStrength(self, t)
		local mast = aura_mastery(self, t)
		local spikecost = t.getSpikeCost(self, t)
		local nb = t.getNumSpikeTargets(self, t)
		return ([[주변의 대기에 전하적 힘을 불어넣어, 근처의 적들에게 피해를 줍니다.
		염동력으로 보석이나 마석을 쥐고 있을 경우, 접근하는 적들에게 %0.1f 전기 피해를 가합니다.
		오러로 총 %0.1f 피해를 줄 때마다 염력이 1 씩 소모됩니다.
		염동력으로 무기를 쥐고 있을 경우, 무기 피해에 추가적으로 %0.1f 전기 피해가 더해집니다.
		전하적 오러를 해제할 때, %d 염력을 사용하여 강력한 전하적 반응을 일으킬 수 있습니다. 이 반응은 가장 가까운 적에게서부터 총 %d 번 연계되며, 각각 최대 %0.1f 전기 피해를 주고 50%% 확률로 혼절시킵니다.
		#{bold}#오러 발산에는 시간이 소모되지 않지만, 오러 해제에는 시간이 소모됩니다.#{normal}#
		전하적 반응을 일으키지 않으려면, 전하적 오러를 해제하고 자기 자신을 반응의 대상으로 삼으면 됩니다. 
		피해량은 정신력의 영향을 받아 증가합니다.]]): 
		format(damDesc(self, DamageType.LIGHTNING, dam), mast, damDesc(self, DamageType.LIGHTNING, dam), spikecost, nb, damDesc(self, DamageType.LIGHTNING, spikedam))
	end,
}

newTalent{
	name = "Frenzied Focus",
	kr_name = "광포한 집중", 
	type = {"psionic/projection", 4},
	require = psi_wil_req4,
	cooldown = 20,
	psi = 30,
	points = 5,
	tactical = { ATTACK = { PHYSICAL = 3 } },
	getTargNum = function(self,t)
		return math.ceil(self:combatTalentScale(t, 1.2, 2.1, "log"))
	end,
	getDamage = function (self, t)
		return math.floor(self:combatTalentMindDamage(t, 10, 200))
	end,
	duration = function(self,t) return math.floor(self:combatTalentScale(t, 4, 8)) end,
	action = function(self, t)
		self:setEffect(self.EFF_PSIFRENZY, t.duration(self,t), {power=t.getTargNum(self,t), damage=t.getDamage(self,t)})
		return true
	end,
	info = function(self, t)
		local targets = t.getTargNum(self,t)
		local dur = t.duration(self,t)
		return ([[%d 턴 동안 염동력을 과부화시켜, 염동력으로 쥐고 있는 장비에 따라 각각 다른 효과를 일으킵니다.
		염동력으로 쥐고 있는 무기는 광폭화 상태가 되어, 매 턴마다 %d 명의 적을 동시에 공격하며 공격 범위가 %d 칸 넓어집니다.
		염동력으로 쥐고 있는 마석은 사거리 내의 모든 적들을 동시에 끌어오려 시도하게 됩니다.
		염동력으로 쥐고 있는 보석은 주변 6 칸 내의 무작위한 적에게 보석의 힘이 응축된 화살을 발사하여, 매 턴마다 %0.1f 피해를 줍니다. 화살의 공격 속성은 보석의 색에 따라 결정되며, 피해량은 정신력의 영향을 받아 증가합니다.]]): 
		format(dur, targets, targets, t.getDamage(self,t))
	end,
}
