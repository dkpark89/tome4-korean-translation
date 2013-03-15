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

local function cancelInfusions(self)
	local chants = {self.T_ACID_INFUSION, self.T_LIGHTNING_INFUSION, self.T_FROST_INFUSION}
	for i, t in ipairs(chants) do
		if self:isTalentActive(t) then
			self:forceUseTalent(t, {ignore_energy=true})
		end
	end
end

newTalent{
	name = "Fire Infusion",
	kr_name = "화염 주입",
	type = {"spell/infusion", 1},
	mode = "passive",
	require = spells_req1,
	points = 5,
	getIncrease = function(self, t) return self:getTalentLevel(t) * 0.07 end,
	info = function(self, t)
		local daminc = t.getIncrease(self, t)
		return ([[연금술 폭탄을 던질 때 화염의 힘을 주입하여 연금술 폭탄의 피해량이 %d%% 증가하고, 적들에게 화상 상태효과를 일으킵니다.]]):
		format(100 * daminc)
	end,
}

newTalent{
	name = "Acid Infusion",
	kr_name = "강산 주입",
	type = {"spell/infusion", 2},
	mode = "sustained",
	require = spells_req2,
	sustain_mana = 30,
	points = 5,
	cooldown = 30,
	tactical = { BUFF = 2 },
	getIncrease = function(self, t) return self:getTalentLevel(t) * 0.05 end,
	getConvert = function(self, t) return self:getTalentLevelRaw(t) * 15 end,
	activate = function(self, t)
		cancelInfusions(self)
		game:playSoundNear(self, "talents/arcane")
		self.fire_convert_to = {DamageType.ACID, t.getConvert(self, t)}
		return {
		}
	end,
	deactivate = function(self, t, p)
		self.fire_convert_to = nil
		return true
	end,
	info = function(self, t)
		local daminc = t.getIncrease(self, t)
		local conv = t.getConvert(self, t)
		return ([[연금술 폭탄을 던질 때 산을 주입하여 연금술 폭탄의 피해량이 %d%% 증가하고, 적들에게 실명 상태효과를 일으킵니다.
		그리고 모든 화염 피해의 %d%% 가 산성 피해로 전환됩니다. (이 때, 특수효과는 발생하지 않습니다)]]):
		format(100 * daminc, conv)
	end,
}

newTalent{
	name = "Lightning Infusion",
	kr_name = "뇌전 주입",
	type = {"spell/infusion", 3},
	mode = "sustained",
	require = spells_req3,
	sustain_mana = 30,
	points = 5,
	cooldown = 30,
	tactical = { BUFF = 2 },
	getIncrease = function(self, t) return self:getTalentLevel(t) * 0.05 end,
	getConvert = function(self, t) return self:getTalentLevelRaw(t) * 15 end,
	activate = function(self, t)
		cancelInfusions(self)
		game:playSoundNear(self, "talents/arcane")
		self.fire_convert_to = {DamageType.LIGHTNING, t.getConvert(self, t)}
		return {
		}
	end,
	deactivate = function(self, t, p)
		self.fire_convert_to = nil
		return true
	end,
	info = function(self, t)
		local daminc = t.getIncrease(self, t)
		local conv = t.getConvert(self, t)
		return ([[연금술 폭탄을 던질 때 번개의 힘을 주입하여 연금술 폭탄의 피해량이 %d%% 증가하고, 적들에게 혼절 상태효과를 일으킵니다.
		그리고 모든 화염 피해의 %d%% 가 전기 피해로 전환됩니다. (이 때, 특수효과는 발생하지 않습니다)]]):
		format(100 * daminc, conv)
	end,
}

newTalent{
	name = "Frost Infusion",
	kr_name = "서리 주입",
	type = {"spell/infusion", 4},
	mode = "sustained",
	require = spells_req4,
	sustain_mana = 30,
	points = 5,
	cooldown = 30,
	tactical = { BUFF = 2 },
	getIncrease = function(self, t) return self:getTalentLevel(t) * 0.05 end,
	getConvert = function(self, t) return self:getTalentLevelRaw(t) * 15 end,
	activate = function(self, t)
		cancelInfusions(self)
		game:playSoundNear(self, "talents/arcane")
		self.fire_convert_to = {DamageType.COLD, t.getConvert(self, t)}
		return {
		}
	end,
	deactivate = function(self, t, p)
		self.fire_convert_to = nil
		return true
	end,
	info = function(self, t)
		local daminc = t.getIncrease(self, t)
		local conv = t.getConvert(self, t)
		return ([[연금술 폭탄을 던질 때 얼음의 힘을 주입하여 연금술 폭탄의 피해량이 %d%% 증가하고, 적들에게 빙결 상태효과를 일으킵니다.
		그리고 모든 화염 피해의 %d%% 가 냉기 피해로 전환됩니다. (이 때, 특수효과는 발생하지 않습니다)]]):
		format(100 * daminc, conv)
	end,
}
