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
	name = "Wild Growth",
	kr_name = "미생물 배양",
	type = {"wild-gift/fungus", 1},
	require = gifts_req1,
	points = 5,
	mode = "sustained",
	sustain_equilibrium = 15,
	cooldown = 20,
	tactical = { BUFF = 2 },
	getDur = function(self, t) return math.max(1,  math.floor(self:getTalentLevel(t))) end,
	activate = function(self, t)
		local dur = t.getDur(self, t)
		game:playSoundNear(self, "talents/heal")
		local ret = {
			dur = self:addTemporaryValue("liferegen_dur", dur),
		}
		if self:knowTalent(self.T_FUNGAL_GROWTH) then
			local t= self:getTalentFromId(self.T_FUNGAL_GROWTH)
			ret.fg = self:addTemporaryValue("fungal_growth", t.getPower(self, t))
		end
		return ret
	end,
	deactivate = function(self, t, p)
		self:removeTemporaryValue("liferegen_dur", p.dur)
		if p.fg then self:removeTemporaryValue("fungal_growth", p.fg) end
		return true
	end,
	info = function(self, t)
		local dur = t.getDur(self, t)
		return ([[주변에 수많은 미생물이 생겨나, 생명력 재생을 도와줍니다.
		모든 생명력 재생 효과의 지속시간이 %d 턴 증가합니다.]]):
		format(dur)
	end,
}

newTalent{
	name = "Fungal Growth",
	kr_name = "미생물 성장",
	type = {"wild-gift/fungus", 2},
	require = gifts_req2,
	points = 5,
	mode = "passive",
	getPower = function(self, t) return 20 + self:combatTalentMindDamage(t, 5, 500) / 10 end,
	info = function(self, t)
		local p = t.getPower(self, t)
		return ([[생명력을 회복할 때마다, 미생물의 도움으로 추가적인 생명력을 회복합니다.
		생명력을 회복할 때마다, 6 턴 동안 회복량의 %d%% 만큼이 추가로 재생됩니다.
		생명력 재생은 정신력의 영향을 받아 증가합니다.]]):
		format(p)
	end,
}

newTalent{
	name = "Ancestral Life",
	kr_name = "고대의 생명력",
	type = {"wild-gift/fungus", 3},
	require = gifts_req3,
	points = 5,
	mode = "passive",
	getEq = function(self, t) return util.bound(math.ceil(self:getTalentLevel(t) / 2), 1, 4) end,
	getTurn = function(self, t) return util.bound(50 + self:combatTalentMindDamage(t, 5, 500) / 10, 50, 160) end,
	info = function(self, t)
		local eq = t.getEq(self, t)
		local turn = t.getTurn(self, t)
		return ([[옛 시대에서부터 이어져 내려온 미생물을 통해, 고대의 능력을 얻게 됩니다.
		생명력 재생 효과가 발동하는 기술을 사용할 경우 지속 시간이 %d%% 만큼 증가하며, 생명력이 재생되는 동안에는 매 턴마다 평정을 %d 만큼 찾게 됩니다.
		기술의 효과는 정신력의 영향을 받아 증가합니다.]]):
		format(turn, eq)
	end,
}

newTalent{
	name = "Sudden Growth",
	kr_name = "급격한 성장",
	type = {"wild-gift/fungus", 4},
	require = gifts_req4,
	points = 5,
	equilibrium = 22,
	cooldown = 25,
	tactical = { HEAL = function(self, t, target) return self.life_regen * 10 end },
	getMult = function(self, t) return util.bound(5 + self:getTalentLevel(t), 3, 12) end,
	action = function(self, t)
		local amt = self.life_regen * t.getMult(self, t)

		self:heal(amt)

		game:playSoundNear(self, "talents/heal")
		return true
	end,
	info = function(self, t)
		local mult = t.getMult(self, t)
		return ([[에너지의 파동이 미생물에 퍼져, 생명력을 즉시 회복시킵니다. 턴 당 재생되는 생명력 수치의 %d%% 만큼이 즉시 회복됩니다.]]):
		format(mult * 100)
	end,
}
