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
	name = "Waters of Life",
	kr_name = "생명의 물",
	type = {"wild-gift/harmony", 1},
	require = gifts_req1,
	points = 5,
	cooldown = 30,
	equilibrium = 10,
	tactical = { HEAL=2 },
	no_energy = true,
	on_pre_use = function(self, t)
		for eff_id, p in pairs(self.tmp) do
			local e = self.tempeffect_def[eff_id]
			if e.subtype.disease or e.subtype.poison then
				return true
			end
		end
		return false
	end,
	is_heal = true,
	action = function(self, t)
		local nb = 0
		for eff_id, p in pairs(self.tmp) do
			local e = self.tempeffect_def[eff_id]
			if e.subtype.disease or e.subtype.poison then
				nb = nb + 1
			end
		end
		self:heal(self:mindCrit(nb * self:combatTalentStatDamage(t, "wil", 20, 60)))

		self:setEffect(self.EFF_WATERS_OF_LIFE, 5 + self:getTalentLevel(t), {})

		game:playSoundNear(self, "talents/spell_generic2")
		return true
	end,
	info = function(self, t)
		return ([[생명의 물이 몸을 타고 흘러, 독과 질병을 정화시킵니다.
		%d 턴 동안 모든 독과 질병이 피해를 주지 않으며, 오히려 생명력을 회복시켜줍니다.
		또한, 걸려있던 독이나 질병 하나 당 %d 생명력이 회복됩니다.
		생명력 회복량은 의지 능력치의 영향을 받아 증가합니다.]]):
		format(5 + self:getTalentLevel(t), self:combatTalentStatDamage(t, "wil", 20, 60))
	end,
}

newTalent{
	name = "Elemental Harmony",
	kr_name = "원소의 조화",
	type = {"wild-gift/harmony", 2},
	require = gifts_req2,
	points = 5,
	mode = "sustained",
	sustain_equilibrium = 20,
	cooldown = 30,
	tactical = { BUFF = 3 },
	activate = function(self, t)
		return {
			tmpid = self:addTemporaryValue("elemental_harmony", self:getTalentLevel(t)),
		}
	end,
	deactivate = function(self, t, p)
		self:removeTemporaryValue("elemental_harmony", p.tmpid)
		return true
	end,
	info = function(self, t)
		local power = self:getTalentLevel(t)
		local turns = 5 + math.ceil(power)
		local fire = 100 * (0.1 + power / 16)
		local cold = 3 + power * 2
		local lightning = math.floor(power)
		local acid = 5 + power * 2
		local nature = 5 + power * 1.4
		return ([[자연을 구성하는 원소와의 친화력이 높아집니다. 해당 속성에 피해를 받을 때마다, %d 턴 동안 특수한 효과가 발생합니다. 이 기술은 한번 발동하면 %d 턴 동안은 다시 발동하지 않습니다.
		- 화염 : 전체 속도 +%d%%
		- 냉기 : 방어도 +%d
		- 전기 : 모든 능력치 +%d
		- 산성 : 턴 당 생명력 회복 +%0.2f
		- 자연 : 전체 저항력 +%d%%]]):
		format(turns, turns, fire, cold, lightning, acid, nature)
	end,
}

newTalent{
	name = "One with Nature",
	kr_name = "자연과의 교감",
	type = {"wild-gift/harmony", 3},
	require = gifts_req3,
	points = 5,
	equilibrium = 15,
	cooldown = 30,
	no_energy = true,
	tactical = { BUFF = 2 },
	on_pre_use = function(self, t) return self:hasEffect(self.EFF_INFUSION_COOLDOWN) end,
	action = function(self, t)
		self:removeEffect(self.EFF_INFUSION_COOLDOWN)
		local tids = {}
		local nb = self:getTalentLevelRaw(t)
		for tid, _ in pairs(self.talents_cd) do
			local tt = self:getTalentFromId(tid)
			if tt.type[1] == "inscriptions/infusions" and self:isTalentCoolingDown(tt) then tids[#tids+1] = tid end
		end
		for i = 1, nb do
			if #tids == 0 then break end
			local tid = rng.tableRemove(tids)
			self.talents_cd[tid] = self.talents_cd[tid] - (1 + math.floor(self:getTalentLevel(t) / 2))
			if self.talents_cd[tid] <= 0 then self.talents_cd[tid] = nil end
		end
		game:playSoundNear(self, "talents/spell_generic2")
		return true
	end,
	info = function(self, t)
		local turns = 1 + math.floor(self:getTalentLevel(t) / 2)
		local nb = self:getTalentLevelRaw(t)
		return ([[자연과 교감하여, 주입 포화 효과를 제거하고 주입 능력 %d 개의 재사용 대기시간을 %d 턴 줄입니다.]]):
		format(nb, turns)
	end,
}

newTalent{
	name = "Healing Nexus",
	kr_name = "집중 회복",
	type = {"wild-gift/harmony", 4},
	require = gifts_req4,
	points = 5,
	equilibrium = 24,
	cooldown = 20,
	range = 10,
	tactical = { DISABLE = 3, HEAL = 0.5 },
	direct_hit = true,
	requires_target = true,
	range = 0,
	radius = function(self, t) return 1 + self:getTalentLevelRaw(t) end,
	target = function(self, t) return {type="ball", range=self:getTalentRange(t), radius=self:getTalentRadius(t), selffire=true, talent=t} end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local grids = self:project(tg, self.x, self.y, function(px, py)
			local target = game.level.map(px, py, Map.ACTOR)
			if not target then return end
			target:setEffect(target.EFF_HEALING_NEXUS, 3 + self:getTalentLevelRaw(t), {src=self, pct=0.4 + self:getTalentLevel(t) / 10, eq=5 + self:getTalentLevel(t)})
		end)
		game.level.map:particleEmitter(self.x, self.y, tg.radius, "ball_acid", {radius=tg.radius})
		game:playSoundNear(self, "talents/spell_generic2")
		return true
	end,
	info = function(self, t)
		return ([[자연의 힘을 주변 %d 칸 반경에 흘려보내, %d 턴 동안 집중 회복 지역을 만듭니다.
		집중 회복 지역에서 이루어지는 모든 회복 효과는 %d%% 효율로 시전자에게 흘러들어오며, 이 때문에 다른 적들은 이곳에서 생명력을 회복할 수 없게 됩니다.
		회복 흡수를 할 때마다 %d 만큼 평정을 되찾게 됩니다.]]):
		format(self:getTalentRadius(t), 3 + self:getTalentLevelRaw(t), (0.4 + self:getTalentLevel(t) / 10) * 100, 5 + self:getTalentLevel(t))
	end,
}
