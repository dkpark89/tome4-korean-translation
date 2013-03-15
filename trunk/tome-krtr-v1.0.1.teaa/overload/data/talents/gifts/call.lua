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
	name = "Meditation",
	kr_name = "명상",
	type = {"wild-gift/call", 1},
	require = gifts_req1,
	points = 5,
	message = "@Source1@ 자연 위에서 명상합니다.",
	mode = "sustained",
	cooldown = 20,
	range = 10,
	no_npc_use = true,
	no_energy = true,
	on_learn = function(self, t)
		self.equilibrium_regen_on_rest = (self.equilibrium_regen_on_rest or 0) - 0.5
	end,
	on_unlearn = function(self, t)
		self.equilibrium_regen_on_rest = (self.equilibrium_regen_on_rest or 0) + 0.5
	end,
	activate = function(self, t)
		local ret = {}

		local pt = 2 + self:combatTalentMindDamage(t, 20, 120) / 10
		local save = 5 + self:combatTalentMindDamage(t, 10, 40)
		local heal = 5 + self:combatTalentMindDamage(t, 12, 30)
		
		if self:knowTalent(self.T_EARTH_S_EYES) then
			local te = self:getTalentFromId(self.T_EARTH_S_EYES)
			self:talentTemporaryValue(ret, "esp_all", 1)
			self:talentTemporaryValue(ret, "esp_range", te.radius_esp(self, te) - 10)
		end

		game:playSoundNear(self, "talents/heal")
		self:talentTemporaryValue(ret, "equilibrium_regen", -pt)
		self:talentTemporaryValue(ret, "combat_mentalresist", save)
		self:talentTemporaryValue(ret, "healing_factor", heal / 100)
		self:talentTemporaryValue(ret, "numbed", 50)
		return ret
	end,
	deactivate = function(self, t, p)
		return true
	end,
	info = function(self, t)
		local pt = 2 + self:combatTalentMindDamage(t, 20, 120) / 10
		local save = 5 + self:combatTalentMindDamage(t, 10, 40)
		local heal = 5 + self:combatTalentMindDamage(t, 12, 30)
		local rest = 0.5 * self:getTalentLevelRaw(t)
		return ([[자연을 느끼며 명상에 빠집니다.
		명상 중에는 매 턴마다 %d 만큼의 평정을 찾으며, 정신 내성이 %d 증가하고 회복 효율이 %d%% 상승합니다.
		하지만 명상에 지나치게 빠지게 되어, 적에게 주는 피해량이 50%% 감소하게 됩니다.
		명상 상태가 아니더라도, 휴식할 때 가볍게 명상하여 매 턴마다 %d 만큼의 평정을 찾게 됩니다.
		이 효과는 정신력의 영향을 받아 증가합니다.]]):
		format(pt, save, heal, rest)
	end,
}

newTalent{ short_name = "NATURE_TOUCH",
	name = "Nature's Touch",
	kr_name = "자연의 손길",
	type = {"wild-gift/call", 2},
	require = gifts_req2,
	random_ego = "defensive",
	points = 5,
	equilibrium = 10,
	cooldown = 15,
	range = 1,
	requires_target = true,
	tactical = { HEAL = 2 },
	is_heal = true,
	action = function(self, t)
		local tg = {default_target=self, type="hit", nowarning=true, range=self:getTalentRange(t), first_target="friend"}
		local x, y, target = self:getTarget(tg)
		if not x or not y or not target then return nil end
		if core.fov.distance(self.x, self.y, x, y) > 1 then return nil end
		if not target:attr("undead") then
			target:attr("allow_on_heal", 1)
			target:heal(self:mindCrit(20 + self:combatTalentMindDamage(t, 20, 500)))
			target:attr("allow_on_heal", -1)
		end
		game:playSoundNear(self, "talents/heal")
		return true
	end,
	info = function(self, t)
		return ([[대상 (혹은 자신) 에 자연의 힘을 불어넣어, %d 생명력을 회복시킵니다. 언데드에게는 사용할 수 없습니다.
		생명력 회복량은 정신력의 영향을 받아 증가합니다.]]):
		format(20 + self:combatTalentMindDamage(t, 20, 500))
	end,
}

newTalent{
	name = "Earth's Eyes",
	kr_name = "대지의 눈",
	type = {"wild-gift/call", 3},
	require = gifts_req3,
	points = 5,
	random_ego = "utility",
	equilibrium = 3,
	cooldown = 10,
	radius = function(self, t) return math.ceil(5 + self:getTalentLevel(t) * 1.3) end,
	radius_esp = function(self, t) return math.floor(3 + self:getTalentLevel(t) / 2) end,
	requires_target = true,
	no_npc_use = true,
	action = function(self, t)
		self:magicMap(math.ceil(5 + self:getTalentLevel(t) * 1.3), self.x, self.y)
		game:playSoundNear(self, "talents/spell_generic2")
		return true
	end,
	info = function(self, t)
		local radius = self:getTalentRadius(t)
		local radius_esp = t.radius_esp(self, t)
		return ([[자신과 자연 사이의 연결고리를 통해, 주변 %d 칸 반경의 지형을 볼 수 있게 됩니다.
		그리고 명상 기술을 사용할 때, 주변 %d 칸 반경에 있는 적들의 위치를 감지하는 능력이 추가됩니다.]]):
		format(radius, radius_esp)
	end,
}

newTalent{
	name = "Nature's Balance",
	kr_name = "자연의 균형",
	type = {"wild-gift/call", 4},
	require = gifts_req4,
	points = 5,
	equilibrium = 20,
	cooldown = 50,
	range = 10,
	tactical = { BUFF = 2 },
	action = function(self, t)
		local nb = math.ceil(self:getTalentLevel(t) + 2)
		local tids = {}
		for tid, _ in pairs(self.talents_cd) do
			local tt = self:getTalentFromId(tid)
			if tt.type[2] <= self:getTalentLevelRaw(t) and tt.type[1]:find("^wild%-gift/") then
				tids[#tids+1] = tid
			end
		end
		for i = 1, nb do
			if #tids == 0 then break end
			local tid = rng.tableRemove(tids)
			self.talents_cd[tid] = nil
		end
		self.changed = true
		game:playSoundNear(self, "talents/spell_generic2")
		return true
	end,
	info = function(self, t)
		return ([[자연과의 깊은 연결을 통해, 자연의 권능 계통 기술의 재사용 대기시간을 초기화시킵니다.
		%d 레벨 이하의 무작위한 기술 %d 개에 적용됩니다.]]):
		format(self:getTalentLevelRaw(t), math.ceil(self:getTalentLevel(t) + 2))
	end,
}

