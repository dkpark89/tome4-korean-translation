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

-- NOTE:  2H may seem to have more defense than 1H/Shield at a glance but this isn't true
-- Mechanically, 2H gets bigger numbers on its defenses because they're all active, they don't do anything when you get hit at range 10 before you've taken an action unlike Retribution/Shield of Light
-- Thematically, 2H feels less defensive for the same reason--when you get hit it hurts, but you're encouraged to be up in their face fighting

-- Part of 2H core defense to be compared with Shield of Light, Retribution, etc
newTalent{
	name = "Absorption Strike",
	kr_name = "흡수 타격",
	type = {"celestial/crusader", 1},
	require = divi_req_high1,
	points = 5,
	cooldown = 8,
	positive = -7,
	tactical = { ATTACK = 2, DISABLE = 1 },
	range = 1,
	requires_target = true,
	getWeakness = function(self, t) return self:combatTalentScale(t, 5, 20, 0.75) end,
	getNumb = function(self, t) return math.min(30, self:combatTalentScale(t, 1, 15, 0.75)) end,
	getDamage = function(self, t) return self:combatTalentWeaponDamage(t, 1.1, 2.3) end,
	on_pre_use = function(self, t, silent) if not self:hasTwoHandedWeapon() then if not silent then game.logPlayer(self, "You require a two handed weapon to use this talent.") end return false end return true end,
	action = function(self, t)
		local tg = {type="hit", range=self:getTalentRange(t)}
		local x, y, target = self:getTarget(tg)
		if not x or not y or not target then return nil end
		if core.fov.distance(self.x, self.y, x, y) > 1 then return nil end
		local hit = self:attackTarget(target, nil, t.getDamage(self, t), true)
		if hit then
			
			self:project({type="ball", radius=2, selffire=false}, self.x, self.y, function(px, py)
				local a = game.level.map(px, py, Map.ACTOR)
				if a then
					-- No power check, this is essentially a defensive talent in debuff form.  Instead of taking less damage passively 2H has to stay active, but we still want the consistency of a sustain/passive
					a:setEffect(a.EFF_ABSORPTION_STRIKE, 5, {power=t.getWeakness(self, t), numb = t.getNumb(self, t)})
				end
			end)
		end
		return true
	end,
	info = function(self, t)
		local damage = t.getDamage(self, t)
		return ([[양손무기로 적을 공격하여 %d%% 의 무기 피해를 줍니다. 
61 		공격이 명중할 경우, 5 턴 동안 주변 2 칸 반경에 있는 모든 적들의 빛 저항력이 %d%% / 피해량이 %d%% 감소합니다.]]): 
62 		format(100 * damage, t.getWeakness(self, t), t.getNumb(self, t)) 
	end,
}

-- Part of 2H core defense to be compared with Shield of Light, Retribution, etc
newTalent{
	name = "Mark of Light",
	kr_name = "빛의 표식",
	type = {"celestial/crusader", 2},
	require = divi_req_high2,
	points = 5,
	no_energy = true,
	cooldown = 15,
	positive = 20,
	tactical = { DISABLE=2, HEAL=2 },
	range = 5,
	requires_target = true,
	getPower = function(self, t) return self:combatTalentLimit(t, 100, 15, 50) end, --Limit < 100%
	on_pre_use = function(self, t, silent) if not self:hasTwoHandedWeapon() then if not silent then game.logPlayer(self, "You require a two handed weapon to use this talent.") end return false end return true end,
	action = function(self, t)
		local tg = {type="hit", range=self:getTalentRange(t)}
		local x, y, target = self:getTarget(tg)
		if not x or not y or not target then return nil end
		if core.fov.distance(self.x, self.y, x, y) > 5 then return nil end
		target:setEffect(target.EFF_MARK_OF_LIGHT, 5, {src=self, power=t.getPower(self, t)})
		
		return true
	end,
	info = function(self, t)
		return ([[대상에게 5 턴 동안 빛의 표식을 부여합니다. 표식이 부여된 적에게 근접 피해를 줄 경우, 자신의 생명력이 피해량의 %d%% 만큼 회복됩니다.]]): 
92 		format(t.getPower(self, t)) 
	end,
}

-- Sustain because dealing damage is not strictly beneficial (radiants) and because 2H needed some sustain cost
newTalent{
	name = "Righteous Strength",
	kr_name = "올바른 힘",
	type = {"celestial/crusader",3},
	require = divi_req_high3,
	points = 5,
	mode = "sustained",
	sustain_positive = 20,
	getArmor = function(self, t) return self:combatTalentScale(t, 5, 30) end,
	getDamage = function(self, t) return self:combatTalentSpellDamage(t, 10, 120) end,
	getCrit = function(self, t) return self:combatTalentScale(t, 3, 10, 0.75) end,
	getPower = function(self, t) return self:combatTalentScale(t, 5, 15) end,
	activate = function(self, t)
		local ret = {}
		self:talentTemporaryValue(ret, "combat_physcrit", t.getCrit(self, t))
		return ret
	end,
	deactivate = function(self, t, p)
		return true
	end,
	callbackOnCrit = function(self, t, kind, dam, chance, target)
		if not self:hasTwoHandedWeapon() then return end
		if kind ~= "physical" or not target then return end
		if self.turn_procs.righteous_strength then return end
		self.turn_procs.righteous_strength = true
		target:setEffect(target.EFF_LIGHTBURN, 5, {apply_power=self:combatSpellpower(), src=self, dam=t.getDamage(self, t)/5, armor=t.getArmor(self, t)})
		self:setEffect(self.EFF_RIGHTEOUS_STRENGTH, 4, {power=t.getPower(self, t), max_power=t.getPower(self, t) * 3})
	end,
	info = function(self, t)
		return ([[양손 무기를 들고 있는 동안, 물리 치명타율이 %d%% 상승합니다. 또한 근접 치명타를 성공시킬 경우, 올바른 힘이 몸에 스며들어 물리 피해량과 빛 피해량이 %d%% 상승합니다. (최대 3회까지 중첩) 
127 		추가적으로, 근접 치명타가 대상에게 빛에 의한 화상을 일으켜 5 턴 동안 %0.2f 빛 피해를 가하며 방어도를 %d 감소시키게 됩니다. 
128 		피해량은 주문력의 영향을 받아 증가합니다.]]): 
		format(t.getCrit(self, t), t.getPower(self, t), damDesc(self, DamageType.LIGHT, t.getDamage(self, t)), t.getArmor(self, t))
	end,
}

-- Low damage, 2H Assault has plenty of AoE damage strikes, this one is fundamentally defensive or strong only if Light is scaled up
-- Part of 2H core defense to be compared with Shield of Light, Retribution, etc
newTalent{
	name = "Flash of the Blade",
	kr_name = "검의 섬광",
	type = {"celestial/crusader", 4},
	require = divi_req_high4,
	random_ego = "attack",
	points = 5,
	cooldown = 9,
	positive = 15,
	tactical = { ATTACKAREA = {LIGHT = 2} },
	range = 0,
	radius = 2,
	requires_target = true,
	target = function(self, t)
		return {type="ball", range=self:getTalentRange(t), selffire=false, radius=self:getTalentRadius(t)}
	end,
	on_pre_use = function(self, t, silent) if not self:hasTwoHandedWeapon() then if not silent then game.logPlayer(self, "You require a two handed weapon to use this talent.") end return false end return true end,
	get1Damage = function(self, t) return self:combatTalentWeaponDamage(t, 0.5, 1.3) end,
	get2Damage = function(self, t) return self:combatTalentWeaponDamage(t, 0.3, 1.5) end,
	action = function(self, t)
		local tg1 = self:getTalentTarget(t) tg1.radius = 1
		local tg2 = self:getTalentTarget(t)
		self:project(tg1, self.x, self.y, function(px, py, tg, self)
			local target = game.level.map(px, py, Map.ACTOR)
			if target and target ~= self then
				self:attackTarget(target, nil, t.get1Damage(self, t), true)
			end
		end)

		self:project(tg2, self.x, self.y, function(px, py, tg, self)
			local target = game.level.map(px, py, Map.ACTOR)
			if target and target ~= self then
				self:attackTarget(target, DamageType.LIGHT, t.get2Damage(self, t), true)
			end
		end)

		if self:getTalentLevel(t) >= 4 then
			self:setEffect(self.EFF_FLASH_SHIELD, 1, {})
		end

		self:addParticles(Particles.new("meleestorm", 2, {radius=2, img="spinningwinds_yellow"}))
		self:addParticles(Particles.new("meleestorm", 1, {img="spinningwinds_yellow"}))
		return true
	end,
	info = function(self, t)
		return ([[양손 무기에 빛의 힘을 불어넣은 뒤, 몸을 팽이처럼 회전시켜 공격합니다. 
181 		주변 1 칸 반경에 있는 모든 적들에게 %d%% 의 무기 피해를 줍니다. 
182 		또한 무기에 주입된 빛의 힘이 너무나 밝아, 주변 2 칸 반경에 있는 모든 적들에게 %d%% 무기 피해를 빛 속성으로 가합니다. 
183 		기술 레벨이 4 이상일 경우, 회전하는 검이 모든 피해를 막아주는 보호막을 1 턴 동안 생성합니다.]]): 
		format(t.get1Damage(self, t) * 100, t.get2Damage(self, t) * 100)
	end,
}
