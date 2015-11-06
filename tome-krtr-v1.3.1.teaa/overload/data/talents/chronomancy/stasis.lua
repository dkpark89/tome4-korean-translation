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
	name = "Spacetime Stability",
	kr_name = "시공간 안정성",
	type = {"chronomancy/stasis", 1},
	require = chrono_req1,
	mode = "passive",
	points = 5,
	getTuning = function(self, t) return 1 + self:combatTalentLimit(t, 6, 0, 3) end,
	callbackOnActBase = function(self, t)
		if not self:hasEffect(self.EFF_SPACETIME_TUNING) then
			tuneParadox(self, t, t.getTuning(self, t))
		end
	end,
	info = function(self, t)
		local tune = t.getTuning(self, t)
		return ([[당신은 당신의 괴리 수치를 매턴 %0.2f 만큼 지정한 괴리 수치로 자동으로 조정합니다.
		시공간 조율 기술을 사용 하는 중이라면 이 값은 두배로 늘어납니다.]]):
		format(tune)
	end,
}

newTalent{
	name = "Time Shield", short_name = "CHRONO_TIME_SHIELD",
	kr_name = "시간의 보호막",
	type = {"chronomancy/stasis",2},
	require = chrono_req2,
	points = 5,
	paradox = function (self, t) return getParadoxCost(self, t, 48) end,
	cooldown = 18,
	tactical = { DEFEND = 2 },
	no_energy = true,
	getMaxAbsorb = function(self, t) return 50 + self:combatTalentSpellDamage(t, 50, 450, getParadoxSpellpower(self, t)) end,
	getDuration = function(self, t) return getExtensionModifier(self, t, util.bound(5 + math.floor(self:getTalentLevel(t)), 5, 15)) end,
	getTimeReduction = function(self, t) return 25 + util.bound(15 + math.floor(self:getTalentLevel(t) * 2), 15, 35) end,
	action = function(self, t)
		self:setEffect(self.EFF_TIME_SHIELD, t.getDuration(self, t), {power=t.getMaxAbsorb(self, t), dot_dur=5, time_reducer=t.getTimeReduction(self, t)})
		game:playSoundNear(self, "talents/spell_generic")
		return true
	end,
	info = function(self, t)
		local maxabsorb = t.getMaxAbsorb(self, t)
		local duration = t.getDuration(self, t)
		local time_reduc = t.getTimeReduction(self,t)
		return ([[시전자 주변에 시간의 보호막을 즉시 만들어내는, 복잡한 마법입니다. 
		시간의 보호막은 모든 피해를 흡수하여 미래로 보내버리며, 보호막이 총 %d 이상의 피해량을 흡수하거나 %d 턴이 지나 지속시간이 끝나면 보호막이 사라집니다. 
		이 보호막은 사라지면서 5 턴 동안 시간의 회복장을 만들어내, 매 턴마다 보호막에 누적됐던 피해량의 10%% 만큼 생명력을 회복시켜줍니다. 
		시간의 보호막이 시전되는 동안 가해진 모든 상태효과는, 보호막의 효과로 인해 지속시간이 %d%% 감소하게 됩니다.
		보호막의 최대 흡수량은 주문력의 영향을 받아 증가합니다.]]):
		format(maxabsorb, duration, time_reduc)
	end,
}

newTalent{
	name = "Stop",
	kr_name = "정지",
	type = {"chronomancy/stasis",3},
	require = chrono_req3,
	points = 5,
	paradox = function (self, t) return getParadoxCost(self, t, 20) end,
	cooldown = 8,
	tactical = { ATTACKAREA = { TEMPORAL = 1 }, DISABLE = { stun = 3 } },
	range = 10,
	radius = function(self, t) return math.floor(self:combatTalentScale(t, 1.3, 2.7)) end,
	direct_hit = true,
	requires_target = true,
	target = function(self, t)
		return {type="ball", range=self:getTalentRange(t), radius=self:getTalentRadius(t), selffire=self:spellFriendlyFire(), talent=t}
	end,
	getDuration = function(self, t) return getExtensionModifier(self, t, math.ceil(self:combatTalentScale(t, 2.3, 4.3))) end,
	getDamage = function(self, t) return self:combatTalentSpellDamage(t, 20, 220, getParadoxSpellpower(self, t)) end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		local _ _, _, _, x, y = self:canProject(tg, x, y)
		
		local dam = self:spellCrit(t.getDamage(self, t))
		local dur = t.getDuration(self, t)
		
		local grids = self:project(tg, x, y, function(px, py)
			local target = game.level.map(px, py, Map.ACTOR)
			if target then
				self:project({type="hit"}, px, py, DamageType.TEMPORAL, dam)
				if target:canBe("stun") then
					target:setEffect(target.EFF_STUNNED, dur, {apply_power=getParadoxSpellpower(self, t)})
				end
			end
		end)
		
		game.level.map:particleEmitter(x, y, tg.radius, "generic_sploom", {rm=230, rM=255, gm=230, gM=255, bm=30, bM=51, am=35, aM=90, radius=tg.radius, basenb=120})
		game:playSoundNear(self, "talents/tidalwave")
		return true
	end,
	info = function(self, t)
		local damage = t.getDamage(self, t)
		local radius = self:getTalentRadius(t)
		local duration = t.getDuration(self, t)
		return ([[%0.2f 의 시간 피해를 %d 칸 범위 내의 있는 모든 목표들에게 가하고, %d 턴 동안 기절 상태에 빠트립니다.
		피해량은 주문력에 비례하여 상승합니다.]]):
		format(damDesc(self, DamageType.TEMPORAL, damage), radius, duration)
	end,
}

newTalent{
	name = "Static History",
	kr_name = "고정된 역사",
	type = {"chronomancy/stasis",4},
	require = chrono_req4,
	points = 5,
	cooldown = 24,
	tactical = { PARADOX = 2 },
	getDuration = function(self, t) return getExtensionModifier(self, t, math.floor(1 + self:combatTalentScale(t, 1, 7))) end,
	no_energy = true,
	action = function(self, t)
		self:setEffect(self.EFF_STATIC_HISTORY, t.getDuration(self, t), {})
		
		game:playSoundNear(self, "talents/spell_generic")
		return true
	end,
	info = function(self, t)
		local duration = t.getDuration(self, t)
		return ([[다음 %d 턴 동안 당신은 비주요 이상 현상을 일으키지 않습니다. 원래 일어났어야 할 이상 현상 때문에 괴리 수치를 회복하지도, 마법이 취소되지도 않습니다.
		이 마법은 주요 이상 현상에는 아무 효과가 없습니다.]]):
		format(duration)
	end,
}
