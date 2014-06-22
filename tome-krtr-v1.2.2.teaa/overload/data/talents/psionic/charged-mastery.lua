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
	name = "Transcendent Electrokinesis",
	kr_name = "초월 - 전기역학",
	type = {"psionic/charged-mastery", 1},
	require = psi_cun_high1,
	points = 5,
	psi = 20,
	cooldown = 30,
	tactical = { BUFF = 3 },
	getPower = function(self, t) return self:combatTalentMindDamage(t, 10, 30) end,
	getPenetration = function(self, t) return self:combatLimit(self:combatTalentMindDamage(t, 10, 20), 100, 4.2, 4.2, 13.4, 13.4) end, -- Limit < 100%
	getConfuse = function(self, t) return self:combatTalentLimit(t, 50, 15, 35) end, --Limit < 50%
	getDuration = function(self, t) return math.floor(self:combatTalentLimit(t, 30, 5, 10)) end, --Limit < 30
	action = function(self, t)
		self:setEffect(self.EFF_TRANSCENDENT_ELECTROKINESIS, t.getDuration(self, t), {power=t.getPower(self, t), penetration = t.getPenetration(self, t), confuse=t.getConfuse(self, t)})
		self:removeEffect(self.EFF_TRANSCENDENT_PYROKINESIS)
		self:removeEffect(self.EFF_TRANSCENDENT_TELEKINESIS)
		self:alterTalentCoolingdown(self.T_CHARGED_SHIELD, -1000)
		self:alterTalentCoolingdown(self.T_CHARGED_STRIKE, -1000)
		self:alterTalentCoolingdown(self.T_CHARGED_AURA, -1000)
		self:alterTalentCoolingdown(self.T_CHARGE_LEECH, -1000)
		self:alterTalentCoolingdown(self.T_BRAIN_STORM, -1000)
		return true
	end,
	info = function(self, t)
		return ([[%d 턴 동안, 한계를 뛰어넘은 초월적인 전기역학을 다룰 수 있게 됩니다.
		- 전기 피해량이 %d%% / 전기 저항 관통력이 %d%% 상승합니다.
		- 전하적 보호막, 전하적 오러 발산, 뇌파 폭풍, 전하적 흡수 기술의 재사용 대기 시간이 초기화됩니다.
		- 전하적 보호막의 흡수 효율이 100%% 가 되며, 최대 흡수 가능량이 2 배 증가합니다.
		- 전하적 오러 발산이 주변 2 칸 범위에 영향을 미치며, 피해량 추가가 적용 가능한 모든 무기에 적용됩니다.
		- 뇌파 폭풍이 실명 효과를 추가로 부여합니다.
		- 전하적 흡수가 %d%% 효과의 혼란 효과를 추가로 부여합니다.
		- 전하적 타격이 두 번째 실명성 전기 폭발을 일으켜, 3 칸 이내에 있는 최대 3 명의 대상에게 연계됩니다.
		피해량 증가와 저항 관통력은 정신력의 영향을 받아 증가합니다.
		한번에 하나의 '초월' 기술만을 사용할 수 있습니다.]]):format(t.getDuration(self, t), t.getPower(self, t), t.getPenetration(self, t), t.getConfuse(self, t))
	end,
}

newTalent{
	name = "Thought Sense",
	kr_name = "사고 감지",
	type = {"psionic/charged-mastery", 2},
	require = psi_cun_high2, 
	points = 5,
	psi = 20,
	cooldown = 30,
	tactical = { BUFF = 3 },
	getDefense = function(self, t) return self:combatTalentMindDamage(t, 20, 40) end,
	getDuration = function(self, t) return math.floor(self:combatTalentScale(t, 6, 12)) end,
	radius = function(self, t) return math.floor(self:combatScale(self:getWil(10, true) * self:getTalentLevel(t), 10, 0, 15, 50)) end,
	action = function(self, t)
		self:setEffect(self.EFF_THOUGHTSENSE, t.getDuration(self, t), {range=t.radius(self, t), def=t.getDefense(self, t)})
		return true
	end,
	info = function(self, t)
		return ([[주변 %d 칸 반경에 있는 적들의 정신 활동을 %d 턴 동안 감지합니다.
		이를 통해 적들의 위치를 감지하며, 시전자의 회피도가 %d 상승합니다.
		지속 시간, 회피도 상승량, 감지 반경은 정신력의 영향을 받아 증가합니다.]]):format(t.radius(self, t), t.getDuration(self, t), t.getDefense(self, t))
	end,
}

newTalent{
	name = "Static Net",
	kr_name = "정전기 망",
	type = {"psionic/charged-mastery", 3},
	require = psi_cun_high3,
	points = 5,
	random_ego = "attack",
	psi = 32,
	cooldown = 13,
	tactical = { ATTACKAREA = { LIGHTNING = 2 } },
	range = 8,
	radius = function(self,t) return self:combatTalentScale(t, 2, 5) end,
	direct_hit = true,
	requires_target = true,
	target = function(self, t)
		return {type="ball", range=self:getTalentRange(t), radius=self:getTalentRadius(t)}
	end,
	getSlow = function(self, t) return self:combatLimit(self:combatTalentMindDamage(t, 5, 50), 50, 4, 4, 34, 34) end, -- Limit < 50%
	getDamage = function(self, t) return self:combatTalentMindDamage(t, 20, 130) end,
	getWeaponDamage = function(self, t) return self:combatTalentMindDamage(t, 10, 50) end,
	getDuration = function(self, t) return math.floor(self:combatTalentScale(t, 3, 9)) end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		local _ _, _, _, x, y = self:canProject(tg, x, y)
		-- Add a lasting map effect
		game.level.map:addEffect(self,
			x, y, t.getDuration(self, t),
			DamageType.STATIC_NET, {dam=t.getDamage(self, t), slow=t.getSlow(self, t), weapon=t.getWeaponDamage(self, t)},
			self:getTalentRadius(t),
			5, nil,
			{type="ice_vapour"},
			nil, true
		)
		game:playSoundNear(self, "talents/lightning")
		return true
	end,
	info = function(self, t)
		local damage = t.getDamage(self, t)
		local duration = t.getDuration(self, t)
		return ([[%d 칸 반경에 %d 턴 동안 정전기 망을 설치합니다.
		정전기 망 안에 있는 적은 %0.1f 전기 피해를 입고 %d%% 감속됩니다.
		시전자가 정전기 망 안으로 들어갈 경우, %0.1f 만큼의 전하적 충전이 무기에 적용되어 다음 공격에 방출됩니다. 이 효과는 정전기 망 안에 있는 동안 계속 누적됩니다.
		기술의 효과는 정신력의 영향을 받아 증가합니다.]]):
		format(self:getTalentRadius(t), duration, damDesc(self, DamageType.LIGHTNING, damage), t.getSlow(self, t), damDesc(self, DamageType.LIGHTNING, t.getWeaponDamage(self, t)))
	end,
}

newTalent{
	name = "Heartstart",
	kr_name = "제세동기",
	type = {"psionic/charged-mastery", 4},
	require = psi_cun_high4,
	points = 5,
	mode = "sustained",
	sustain_psi = 30,
	cooldown = 60,
	tactical = { BUFF = 10},
	getPower = function(self, t) -- Similar to blurred mortality
		return self:combatTalentMindDamage(t, 0, 300) + self.max_life * self:combatTalentLimit(t, 1, .01, .05)
	end,
	getDuration = function(self, t) return math.floor(self:combatTalentScale(t, 1, 5)) end,
	activate = function(self, t)
		return {}
	end,
	deactivate = function(self, t, p)
		local effs = {}
		-- Go through all spell effects
		for eff_id, p in pairs(self.tmp) do
			local e = self.tempeffect_def[eff_id]
			if e.status == "detrimental" and e.subtype.stun then
				self:removeEffect(eff_id)
			end
		end
		self:setEffect(self.EFF_HEART_STARTED, t.getDuration(self, t), {power=t.getPower(self, t)})
		return true
	end,
	info = function(self, t)
		return ([[나중을 위해 일정량의 전하를 충전해놓습니다.
		생명력이 0 이하로 떨어질 경우, 충전된 전하가 방출되어 모든 기절/혼절/빙결 상태효과를 해제시키고 %d 이하로 생명력이 떨어져야 죽을 수 있는 상태가 됩니다. 이 효과는 %d 턴 동안 유지됩니다.
		최저 생명력 한계수치는 정신력과 최대 생명력의 영향을 받아 증가합니다.]]):
		format(t.getPower(self, t), t.getDuration(self, t))
	end,
}

