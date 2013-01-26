-- ToME - Tales of Maj'Eyal
-- Copyright (C) 2009, 2010, 2011, 2012 Nicolas Casalini
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
	name = "Solipsism",
	kr_display_name = "유아론",
	type = {"psionic/solipsism", 1},
	points = 5, 
	require = psi_wil_req1,
	mode = "passive",
	no_unlearn_last = true,
	getConversionRatio = function(self, t) return math.min(0.25 + self:getTalentLevel(t) * 0.1, 1) end,
	on_learn = function(self, t)
		if self:getTalentLevelRaw(t) == 1 then
			self.inc_resource_multi.psi = (self.inc_resource_multi.psi or 0) + 0.5
			self.inc_resource_multi.life = (self.inc_resource_multi.life or 0) - 0.25
			self.life_rating = math.ceil(self.life_rating/2)
			self.psi_rating =  self.psi_rating + 5
			self.solipsism_threshold = (self.solipsism_threshold or 0) + 0.2
			
			-- Adjust the values onTickEnd for NPCs to make sure these table values are resolved
			-- If we're not the player, we resetToFull to ensure correct values
			game:onTickEnd(function()
				self:incMaxPsi((self:getWil()-10) * 1)
				self.max_life = self.max_life - (self:getCon()-10) * 0.5
				if self ~= game.player then self:resetToFull() end
			end)
		end
	end,
	on_unlearn = function(self, t)
		if not self:knowTalent(t) then
			self:incMaxPsi(-(self:getWil()-10) * 0.5)
			self.max_life = self.max_life + (self:getCon()-10) * 0.25
			self.inc_resource_multi.psi = self.inc_resource_multi.psi - 0.5
			self.inc_resource_multi.life = self.inc_resource_multi.life + 0.25
			self.solipsism_threshold = self.solipsism_threshold - 0.2
		end
	end,
	info = function(self, t)
		local conversion_ratio = t.getConversionRatio(self, t)
		return ([[실재하는 것은 자아 뿐이고, 다른 모든 것들은 현상에 불과한 것이라고 생각합니다. 
		레벨이 오를 때마다 염력 최대량이 5 증가하지만, 생명력 증가량은 50%% 줄어들게 됩니다. (기술 레벨이 1 이 될 때, 한 번만 적용됩니다)
		정신력으로 피해를 극복하는 법을 배워 적에게 받는 피해량의 %d%% 가 생명력 대신 염력을 소진시키고, 생명력 회복량의 %d%% 가 생명력 대신 염력을 회복시킵니다.
		기술 레벨이 1 이 될 때, 의지 능력치 1 당 최대 염력이 0.5 증가하게 되지만 그 대신 체격 능력치 1 당 최대 생명력이 0.25 감소하게 됩니다. 
		또한 독존 한계량이 기본적으로 20%% (현재 : %d%%) 가 되며, 현재 염력이 독존 한계량보다 부족할 경우 부족한 %% 만큼 전체 속도가 1%% 감소하게 됩니다.]]):format(conversion_ratio * 100, conversion_ratio * 100, (self.solipsism_threshold or 0) * 100)
	end,
}

newTalent{
	name = "Balance",
	kr_display_name = "균형",
	type = {"psionic/solipsism", 2},
	points = 5, 
	require = psi_wil_req2,
	mode = "passive",
	getBalanceRatio = function(self, t) return math.min(0.25 + self:getTalentLevel(t) * 0.1, 1) end,
	on_learn = function(self, t)
		if self:getTalentLevelRaw(t) == 1 then
			self.inc_resource_multi.psi = (self.inc_resource_multi.psi or 0) + 0.5
			self.inc_resource_multi.life = (self.inc_resource_multi.life or 0) - 0.25
			self.solipsism_threshold = (self.solipsism_threshold or 0) + 0.1
			-- Adjust the values onTickEnd for NPCs to make sure these table values are filled out
			-- If we're not the player, we resetToFull to ensure correct values
			game:onTickEnd(function()
				self:incMaxPsi((self:getWil()-10) * 0.5)
				self.max_life = self.max_life - (self:getCon()-10) * 0.25
				if self ~= game.player then self:resetToFull() end
			end)
		end
	end,
	on_unlearn = function(self, t)
		if not self:knowTalent(t) then
			self:incMaxPsi(-(self:getWil()-10) * 0.5)
			self.max_life = self.max_life + (self:getCon()-10) * 0.25
			self.inc_resource_multi.psi = self.inc_resource_multi.psi - 0.5
			self.inc_resource_multi.life = self.inc_resource_multi.life + 0.25
			self.solipsism_threshold = self.solipsism_threshold - 0.1
		end
	end,
	info = function(self, t)
		local ratio = t.getBalanceRatio(self, t) * 100
		return ([[물리 내성과 주문 내성의 %d%% 만큼을 버리고, 정신 내성의 %d%% 로 대체합니다. (즉 이 비율이 100%% 가 되면, 정신 내성이 물리 내성과 주문 내성을 완전히 대체하게 됩니다)
		기술 레벨이 1 이 될 때, 의지 능력치 1 당 최대 염력이 0.5 증가하게 되지만 그 대신 체격 능력치 1 당 최대 생명력이 0.25 감소하게 됩니다. 
		이 기술을 배우면 독존 한계량이 10%% 증가하게 됩니다. (현재 : %d%%)]]):format(ratio, ratio, (self.solipsism_threshold or 0) * 100)
	end,
}

newTalent{
	name = "Clarity",
	kr_display_name = "명석",
	type = {"psionic/solipsism", 3},
	points = 5, 
	require = psi_wil_req3,
	mode = "passive",
	getClarityThreshold = function(self, t) return math.max(0.95 - self:getTalentLevel(t) * 0.06, 0.5) end,
	on_learn = function(self, t)
		if self:getTalentLevelRaw(t) == 1 then
			self.inc_resource_multi.psi = (self.inc_resource_multi.psi or 0) + 0.5
			self.inc_resource_multi.life = (self.inc_resource_multi.life or 0) - 0.25
			self.solipsism_threshold = (self.solipsism_threshold or 0) + 0.1
			-- Adjust the values onTickEnd for NPCs to make sure these table values are resolved
			-- If we're not the player, we resetToFull to ensure correct values
			game:onTickEnd(function()
				self:incMaxPsi((self:getWil()-10) * 0.5)
				self.max_life = self.max_life - (self:getCon()-10) * 0.25
				if self ~= game.player then self:resetToFull() end
			end)
		end
	end,
	on_unlearn = function(self, t)
		if not self:knowTalent(t) then
			self:incMaxPsi(-(self:getWil()-10) * 0.5)
			self.max_life = self.max_life + (self:getCon()-10) * 0.25
			self.inc_resource_multi.psi = self.inc_resource_multi.psi - 0.5
			self.inc_resource_multi.life = self.inc_resource_multi.life + 0.25
			self.solipsism_threshold = self.solipsism_threshold - 0.1
		end
	end,
	info = function(self, t)
		local threshold = t.getClarityThreshold(self, t)
		return ([[현재 염력이 최대 염력의 %d%% 이상일 경우, 넘치는 %% 만큼 전체 속도가 증가합니다. (최대 50%%)
		기술 레벨이 1 이 될 때, 의지 능력치 1 당 최대 염력이 0.5 증가하게 되지만 그 대신 체격 능력치 1 당 최대 생명력이 0.25 감소하게 됩니다. 
		이 기술을 배우면 독존 한계량이 10%% 증가하게 됩니다. (현재 : %d%%)]]):format(threshold * 100, (self.solipsism_threshold or 0) * 100)
	end,
}

newTalent{
	name = "Dismissal",
	kr_display_name = "묵살",
	type = {"psionic/solipsism", 4},
	points = 5, 
	require = psi_wil_req4,
	mode = "passive",
	getSavePercentage = function(self, t) return math.min(0.25 + self:getTalentLevel(t) * 0.1, 1) end,
	on_learn = function(self, t)
		if self:getTalentLevelRaw(t) == 1 then
			self.inc_resource_multi.psi = (self.inc_resource_multi.psi or 0) + 0.5
			self.inc_resource_multi.life = (self.inc_resource_multi.life or 0) - 0.25
			self.solipsism_threshold = (self.solipsism_threshold or 0) + 0.1
			-- Adjust the values onTickEnd for NPCs to make sure these table values are resolved
			-- If we're not the player, we resetToFull to ensure correct values
			game:onTickEnd(function()
				self:incMaxPsi((self:getWil()-10) * 0.5)
				self.max_life = self.max_life - (self:getCon()-10) * 0.25
				if self ~= game.player then self:resetToFull() end
			end)
		end
	end,
	on_unlearn = function(self, t)
		if not self:knowTalent(t) then
			self:incMaxPsi(-(self:getWil()-10) * 0.5)
			self.max_life = self.max_life + (self:getCon()-10) * 0.25
			self.inc_resource_multi.psi = self.inc_resource_multi.psi - 0.5
			self.inc_resource_multi.life = self.inc_resource_multi.life + 0.25
			self.solipsism_threshold = self.solipsism_threshold - 0.1
		end
	end,
	doDismissalOnHit = function(self, value, src, t)
		local saving_throw = self:combatMentalResist() * t.getSavePercentage(self, t)
		print("[Dismissal] ", self.name:capitalize(), " attempting to ignore ", value, "damage from ", src.name:capitalize(), "using", saving_throw,  "mental save.")
		if self:checkHit(saving_throw, value) then
			game.logSeen(self, "%s %s부터의 피해를 묵살하였습니다!", (self.kr_display_name or self.name):capitalize():addJosa("가"), (src.kr_display_name or src.name):capitalize():addJosa("로"))
			return value * math.max(0, 1 - self:mindCrit(0.5))
		else
			return value
		end
	end,
	info = function(self, t)
		local save_percentage = t.getSavePercentage(self, t)
		return ([[피해를 받을 때마다, 정신 내성의 %d%% 를 이용해서 저항을 시도합니다. 저항이 성공할 경우, 받는 피해량이 50%% 감소합니다.
		기술 레벨이 1 이 될 때, 의지 능력치 1 당 최대 염력이 0.5 증가하게 되지만 그 대신 체격 능력치 1 당 최대 생명력이 0.25 감소하게 됩니다. 
		이 기술을 배우면 독존 한계량이 10%% 증가하게 됩니다. (현재 : %d%%)]]):format(save_percentage * 100, (self.solipsism_threshold or 0) * 100)
	end,
}
