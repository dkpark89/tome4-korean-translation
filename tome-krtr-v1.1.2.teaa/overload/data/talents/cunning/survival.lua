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
	name = "Heightened Senses",
	kr_name = "향상된 감각",
	type = {"cunning/survival", 1},
	require = cuns_req1,
	mode = "passive",
	points = 5,
	sense = function(self, t) return math.floor(self:combatTalentScale(t, 5, 9)) end,
	trapPower = function(self, t) return self:combatScale(self:getTalentLevel(t) * self:getCun(25, true), 0, 0, 125, 125) end,
	passives = function(self, t, p)
		self:talentTemporaryValue(p, "heightened_senses", t.sense(self, t))
	end,
	info = function(self, t)
		return ([[남들이 찾지 못하는 작은 것까지 볼 수 있게 되어, 주변 %d 칸 반경의 적들을 빛이 없어도 볼 수 있게 됩니다.
		하지만 이 능력이 초능력은 아니기 때문에, 시야 반경 밖을 내다볼 수는 없습니다.
		향상된 감각을 통해, 주변의 함정 역시 찾아낼 수 있게 됩니다. (함정 탐지력 +%d)
		기술 레벨이 3 이상이면, 발견한 함정을 해체할 수 있게 됩니다. (함정 해체력 +%d)
		함정 탐지 및 해체 능력은 교활함 능력치의 영향을 받아 증가합니다.]]):
		format(t.sense(self,t),t.trapPower(self,t),t.trapPower(self,t))
	end,
}

newTalent{
	name = "Charm Mastery",
	kr_name = "도구 수련",
	type = {"cunning/survival", 2},
	require = cuns_req2,
	mode = "passive",
	points = 5,
	cdReduc = function(tl) 
		if tl <=0 then return 0 end
		return math.floor(100*tl/(tl+7.5)) --I5 Limit < 100%
	end,
	passives = function(self, t, p)
		self:talentTemporaryValue(p, "use_object_cooldown_reduce", t.cdReduc(self:getTalentLevel(t))) --I5
	end,
--	on_unlearn = function(self, t)
--	end,
	info = function(self, t)
		return ([[마법봉, 토템, 주술고리 등의 도구를 더 효율적으로 사용할 수 있게 되어, 재사용 대기시간이 %d%% 감소합니다.]]):
		format(t.cdReduc(self:getTalentLevel(t))) --I5
	end,
}

newTalent{
	name = "Piercing Sight",
	kr_name = "날카로운 시야",
	type = {"cunning/survival", 3},
	require = cuns_req3,
	mode = "passive",
	points = 5,
	--  called by functions _M:combatSeeStealth and _M:combatSeeInvisible functions mod\class\interface\Combat.lua	
	seePower = function(self, t) return self:combatScale(self:getCun(15, true)*self:getTalentLevel(t), 5, 0, 80, 75) end, --I5 
	info = function(self, t)
		return ([[주변을 더 뚜렷하게 볼 수 있게 되어, 은신이나 투명한 적을 더 잘 발견할 수 있게 됩니다.
		은신 감지력이 %d / 투명 감지력이 %d 증가합니다.
		감지력은 교활함 능력치의 영향을 받아 증가합니다.]]):
		format(t.seePower(self,t), t.seePower(self,t))
	end,
}

newTalent{
	name = "Evasion",
	kr_name = "회피",
	type = {"cunning/survival", 4},
	points = 5,
	require = cuns_req4,
	random_ego = "defensive",
	tactical = { ESCAPE = 2, DEFEND = 2 },
	cooldown = 30,
	getDur = function(self) return math.floor(self:combatStatLimit("wil", 30, 6, 15)) end, -- Limit < 30
	getChanceDef = function(self, t)
		if self.perfect_evasion then return 100, 0 end
		return self:combatLimit(5*self:getTalentLevel(t) + self:getCun(25,true) + self:getDex(25,true), 50, 10, 10, 37.5, 75),
		self:combatScale(self:getTalentLevel(t) * (self:getCun(25, true) + self:getDex(25, true)), 0, 0, 55, 250, 0.75)
		-- Limit evasion chance < 50%, defense bonus ~= 55 at level 50
	end,
	action = function(self, t)
		local dur = t.getDur(self)
		local chance, def = t.getChanceDef(self,t)
		self:setEffect(self.EFF_EVASION, dur, {chance=chance, defense = def})
		return true
	end,
	info = function(self, t)
		local chance, def = t.getChanceDef(self,t)
		return ([[재빠른 몸놀림을 통해 공격이 닿기 전에 피합니다. %d 턴 동안 %d%% 확률로 근접 공격을 완전히 회피하고 %d의 최소 회피도가 보장됩니다.
		지속시간은 의지력, 회피 확률과 회피도는 교활함과 민첩 능력치의 영향을 받아 증가합니다.]]):
		format(t.getDur(self), chance, def) --@ 변수 순서 조정
	end,
}
