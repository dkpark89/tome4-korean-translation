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

newTalent{
	name = "Blood Spray",
	kr_display_name = "피 뿌리기",
	type = {"corruption/blood", 1},
	require = corrs_req1,
	points = 5,
	cooldown = 7,
	vim = 24,
	tactical = { ATTACKAREA = {BLIGHT = 2} },
	range = 0,
	radius = function(self, t)
		return math.ceil(3 + self:getTalentLevel(t))
	end,
	direct_hit = true,
	requires_target = true,
	target = function(self, t)
		return {type="cone", range=self:getTalentRange(t), radius=self:getTalentRadius(t), talent=t}
	end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		self:project(tg, x, y, DamageType.CORRUPTED_BLOOD, {
			dam = self:spellCrit(self:combatTalentSpellDamage(t, 10, 190)),
			disease_chance = 20 + self:getTalentLevel(t) * 10,
			disease_dam = self:spellCrit(self:combatTalentSpellDamage(t, 10, 220)) / 6,
			disease_power = self:combatTalentSpellDamage(t, 10, 20),
			dur = 6,
		})
		game.level.map:particleEmitter(self.x, self.y, tg.radius, "breath_blood", {radius=tg.radius, tx=x-self.x, ty=y-self.y})
		game:playSoundNear(self, "talents/slime")
		return true
	end,
	info = function(self, t)
		return ([[전방 %d 칸 범위에 자신의 오염된 피를 뿌려, %0.2f 황폐화 피해를 줍니다.
		오염된 피에 닿은 적은 %d%% 확률로 질병에 걸려, 6 턴 동안 매 턴마다 %0.2f 황폐화 피해를 받고 힘, 체격, 민첩 능력치 중 하나가 감소됩니다.
		피해량은 주문력 능력치의 영향을 받아 증가합니다.]]):format(self:getTalentRadius(t), damDesc(self, DamageType.BLIGHT, self:combatTalentSpellDamage(t, 10, 190)), 20 + self:getTalentLevel(t) * 10, damDesc(self, DamageType.BLIGHT, self:combatTalentSpellDamage(t, 10, 220)))
	end,
}

newTalent{
	name = "Blood Grasp",
	kr_display_name = "피의 속박",
	type = {"corruption/blood", 2},
	require = corrs_req2,
	points = 5,
	cooldown = 5,
	vim = 20,
	range = 10,
	proj_speed = 20,
	tactical = { ATTACK = {BLIGHT = 2}, HEAL = 2 },
	requires_target = true,
	target = function(self, t)
		return {type="bolt", range=self:getTalentRange(t), talent=t, display={particle="bolt_blood"}}
	end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		self:projectile(tg, x, y, DamageType.DRAINLIFE, {dam=self:spellCrit(self:combatTalentSpellDamage(t, 10, 290)), healfactor=0.5}, {type="blood"})
		game:playSoundNear(self, "talents/slime")
		return true
	end,
	info = function(self, t)
		return ([[오염된 피의 화살을 발사하여 %0.2f 황폐화 피해를 주고, 피해량의 절반에 해당하는 생명력을 회복합니다.
		피해량은 주문력 능력치의 영향을 받아 증가합니다.]]):format(damDesc(self, DamageType.BLIGHT, self:combatTalentSpellDamage(t, 10, 290)))
	end,
}

newTalent{
	name = "Blood Boil",
	kr_display_name = "끓어오르는 피",
	type = {"corruption/blood", 3},
	require = corrs_req3,
	points = 5,
	cooldown = 12,
	vim = 30,
	tactical = { ATTACKAREA = {BLIGHT = 2}, DISABLE = 2 },
	range = 0,
	radius = function(self, t)
		return 2 + self:getTalentLevelRaw(t)
	end,
	requires_target = true,
	target = function(self, t)
		return {type="ball", range=self:getTalentRange(t), radius=self:getTalentRadius(t), selffire=false, talent=t}
	end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local grids = self:project(tg, self.x, self.y, DamageType.BLOOD_BOIL, self:spellCrit(self:combatTalentSpellDamage(t, 28, 190)))
		game.level.map:particleEmitter(self.x, self.y, tg.radius, "ball_blood", {radius=tg.radius})
		game:playSoundNear(self, "talents/slime")
		return true
	end,
	info = function(self, t)
		return ([[주변 %d 칸 반경에 있는 적들의 피를 끓어오르게 만들어, %0.2f 황폐화 피해를 주고 전체 속도를 20%% 감속시킵니다.
		피해량은 주문력 능력치의 영향을 받아 증가합니다.]]):format(self:getTalentRadius(t), damDesc(self, DamageType.BLIGHT, self:combatTalentSpellDamage(t, 28, 190)))
	end,
}

newTalent{
	name = "Blood Fury",
	kr_display_name = "피의 분노",
	type = {"corruption/blood", 4},
	mode = "sustained",
	require = corrs_req4,
	points = 5,
	sustain_vim = 60,
	cooldown = 30,
	tactical = { BUFF = 2 },
	on_crit = function(self, t)
		self:setEffect(self.EFF_BLOOD_FURY, 5, {power=self:combatTalentSpellDamage(t, 10, 30)})
	end,
	activate = function(self, t)
		game:playSoundNear(self, "talents/slime")
		local ret = {
			per = self:addTemporaryValue("combat_spellcrit", self:combatTalentSpellDamage(t, 10, 14)),
		}
		return ret
	end,
	deactivate = function(self, t, p)
		self:removeTemporaryValue("combat_spellcrit", p.per)
		return true
	end,
	info = function(self, t)
		return ([[자신의 오염과 타락에 집중하여, 주문 치명타율을 %d%% 올립니다.
		주문 치명타가 발생할 때마다, 5 턴 동안 피의 분노 상태가 되어 황폐화 피해와 산성 피해량이 %d%% 증가합니다.
		치명타율 증가와 피해량은 주문력 능력치의 영향을 받아 증가합니다.]]):
		format(self:combatTalentSpellDamage(t, 10, 14), self:combatTalentSpellDamage(t, 10, 30))
	end,
}
