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

newTalent{
	name = "Congeal Time",
	kr_name = "얼어붙은 시간",
	type = {"spell/temporal",1},
	require = spells_req1,
	points = 5,
	random_ego = "utility",
	mana = 10,
	cooldown = 30,
	tactical = { DISABLE = 2 },
	reflectable = true,
	proj_speed = 2,
	range = 6,
	direct_hit = true,
	requires_target = true,
	getSlow = function(self, t) return math.min(self:getTalentLevel(t) * 0.08, 0.6) end,
	getProj = function(self, t) return math.min(90, 5 + self:combatTalentSpellDamage(t, 5, 700) / 10) end,
	action = function(self, t)
		local tg = {type="beam", range=self:getTalentRange(t), talent=t, display={particle="bolt_arcane"}}
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		self:projectile(tg, x, y, DamageType.CONGEAL_TIME, {
			slow = 1 - 1 / (1 + t.getSlow(self, t)),
			proj = t.getProj(self, t),
		}, {type="manathrust"})
		game:playSoundNear(self, "talents/spell_generic")
		return true
	end,
	info = function(self, t)
		local slow = t.getSlow(self, t)
		local proj = t.getProj(self, t)
		return ([[시간을 왜곡시키는 마법 화살을 발사하여, 7 턴 동안 대상의 전체 속도를 %d%% 감소시키고 대상이 발사하는 모든 발사체의 속도를 %d%% 느리게 만듭니다.]]):
		format(100 * slow, proj)
	end,
}

newTalent{
	name = "Time Shield",
	kr_name = "시간의 보호막",
	type = {"spell/temporal", 2},
	require = spells_req2,
	points = 5,
	mana = 25,
	cooldown = 18,
	tactical = { DEFEND = 2 },
	range = 10,
	no_energy = true,
	getMaxAbsorb = function(self, t) return 50 + self:combatTalentSpellDamage(t, 50, 450) end,
	getDuration = function(self, t) return util.bound(5 + math.floor(self:getTalentLevel(t)), 5, 15) end,
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
		이 보호막은 사라지면서 5 턴 동안 시간 복구 지역을 만들어내, 매 턴마다 보호막에 누적됐던 피해량의 10%% 만큼 생명력을 회복시켜줍니다. (이 비율은 수호 기술을 통해 증가시킬 수 있습니다)
		시간의 보호막이 시전된 동안 가해지는 모든 상태효과는, 보호막의 효과로 인해 지속시간이 %d%% 감소하게 됩니다.
		보호막의 최대 흡수량은 주문력의 영향을 받아 증가합니다.]]): 
		format(maxabsorb, duration, time_reduc)
	end,
}

newTalent{
	name = "Time Prison",
	kr_name = "시간의 감옥",
	type = {"spell/temporal", 3},
	require = spells_req3,
	points = 5,
	random_ego = "utility",
	mana = 100,
	cooldown = 40,
	tactical = { DISABLE = 1, ESCAPE = 3, PROTECT = 3 },
	range = 10,
	direct_hit = true,
	reflectable = true,
	requires_target = true,
	getDuration = function(self, t) return 4 + self:combatSpellpower(0.03) * self:getTalentLevel(t) end,
	action = function(self, t)
		local tg = {type="hit", range=self:getTalentRange(t), talent=t}
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		self:project(tg, x, y, DamageType.TIME_PRISON, t.getDuration(self, t), {type="manathrust"})
		game:playSoundNear(self, "talents/spell_generic")
		return true
	end,
	info = function(self, t)
		local duration = t.getDuration(self, t)
		return ([[대상을 %d 턴 동안 시간의 흐름에서 벗어나게 만듭니다. 그동안 대상은 행동할 수 없지만, 피해를 받지도 않게 됩니다.
		대상의 시간이 흐르지 않기 때문에 기술의 지연시간도 감소하지 않고, 각종 원천력의 재생도 일어나지 않는 등의 효과가 발생합니다.
		마법의 지속시간은 주문력의 영향을 받아 증가합니다.]]):
		format(duration)
	end,
}

newTalent{
	name = "Essence of Speed",
	kr_name = "속도의 본질",
	type = {"spell/temporal",4},
	require = spells_req4,
	points = 5,
	mode = "sustained",
	sustain_mana = 250,
	cooldown = 30,
	tactical = { BUFF = 2 },
	getHaste = function(self, t) return self:getTalentLevel(t) * 0.09 end,
	activate = function(self, t)
		game:playSoundNear(self, "talents/spell_generic")
		local power = t.getHaste(self, t)
		return {
			speed = self:addTemporaryValue("global_speed_add", power),
		}
	end,
	deactivate = function(self, t, p)
		self:removeTemporaryValue("global_speed_add", p.speed)
		return true
	end,
	info = function(self, t)
		local haste = t.getHaste(self, t)
		return ([[시전자의 전체 속도가 %d%% 상승합니다.]]):
		format(100 * haste)
	end,
}
