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
	name = "Throw Bomb",
	kr_display_name = "연금술 폭탄",
	type = {"spell/explosives", 1},
	require = spells_req1,
	points = 5,
	mana = 5,
	cooldown = 4,
	range = function(self, t)
		return math.ceil(4 + self:getTalentLevelRaw(t))
	end,
	radius = function(self, t)
		return util.bound(1+self:getTalentLevelRaw(self.T_EXPLOSION_EXPERT), 1, 6)
	end,
	direct_hit = true,
	requires_target = true,
	target = function(self, t)
		local ammo = self:hasAlchemistWeapon()
		if not ammo then return end
		-- Using friendlyfire, although this could affect escorts etc.
		local friendlyfire = true
		local prot = self:getTalentLevelRaw(self.T_ALCHEMIST_PROTECTION) * 20
		if prot > 0 then
			friendlyfire = 100 - prot
		end
		return {type="ball", range=self:getTalentRange(t)+(ammo and ammo.alchemist_bomb and ammo.alchemist_bomb.range or 0), radius=self:getTalentRadius(t), friendlyfire=friendlyfire, talent=t}
	end,
	tactical = { ATTACKAREA = function(self, t, target)
		if self:isTalentActive(self.T_ACID_INFUSION) then return { ACID = 2 }
		elseif self:isTalentActive(self.T_LIGHTNING_INFUSION) then return { LIGHTNING = 2 }
		elseif self:isTalentActive(self.T_FROST_INFUSION) then return { COLD = 2 }
		else return { FIRE = 2 }
		end
	end },
	computeDamage = function(self, t, ammo)
		local inc_dam = 0
		local damtype = DamageType.FIRE
		local particle = "ball_fire"
		local acidi = self:getTalentFromId(Talents.T_ACID_INFUSION)
		local lightningi = self:getTalentFromId(Talents.T_LIGHTNING_INFUSION)
		local frosti = self:getTalentFromId(Talents.T_FROST_INFUSION)
		local fireinf = self:getTalentFromId(Talents.T_FIRE_INFUSION)
		if self:isTalentActive(self.T_ACID_INFUSION) then inc_dam = acidi.getIncrease(self,acidi); damtype = DamageType.ACID_BLIND; particle = "ball_acid"
		elseif self:isTalentActive(self.T_LIGHTNING_INFUSION) then inc_dam = lightningi.getIncrease(self,lightningi); damtype = DamageType.LIGHTNING_DAZE; particle = "ball_lightning_beam"
		elseif self:isTalentActive(self.T_FROST_INFUSION) then inc_dam = frosti.getIncrease(self,frosti); damtype = DamageType.ICE; particle = "ball_ice"
		else inc_dam = fireinf.getIncrease(self,fireinf); damtype = self:knowTalent(self.T_FIRE_INFUSION) and DamageType.FIREBURN or DamageType.FIRE
		end
		inc_dam = inc_dam + (ammo.alchemist_bomb and ammo.alchemist_bomb.power or 0) / 100
		local dam = self:combatTalentSpellDamage(t, 15, 150, ((ammo.alchemist_power or 0) + self:combatSpellpower()) / 2)
		dam = dam * (1 + inc_dam)
		return dam, damtype, particle
	end,
	action = function(self, t)
		local ammo = self:hasAlchemistWeapon()
		if not ammo then
			game.logPlayer(self, "연금술 폭탄을 던지려면 연금술용 보석을 손에 들고있어야 합니다.")
			return
		end

		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end

		ammo = self:removeObject(self:getInven("QUIVER"), 1)
		if not ammo then return end

		local dam, damtype, particle = t.computeDamage(self, t, ammo)
		dam = self:spellCrit(dam)
		local prot = self:getTalentLevelRaw(self.T_ALCHEMIST_PROTECTION) * 0.2
		local golem
		if self.alchemy_golem then
			golem = game.level:hasEntity(self.alchemy_golem) and self.alchemy_golem or nil
		end
		local dam_done = 0

		-- Compare theorical AOE zone with actual zone and adjust damage accordingly
		if self:knowTalent(self.T_EXPLOSION_EXPERT) then
			local theorical_nb = ({ 9, 25, 45, 77, 109, 145 })[tg.radius] or 145
			local nb = 0
			local grids = self:project(tg, x, y, function(tx, ty) end)
			if grids then for px, ys in pairs(grids or {}) do for py, _ in pairs(ys) do nb = nb + 1 end end end
			nb = theorical_nb - nb
			if nb > 0 then
				local mult = math.log10(nb) / (6 - math.min(self:getTalentLevelRaw(self.T_EXPLOSION_EXPERT), 5))
				print("Adjusting explosion damage to account for ", nb, " lost tiles => ", mult * 100)
				dam = dam + dam * mult
			end
		end

		local tmp = {}
		local grids = self:project(tg, x, y, function(tx, ty)
			local d = dam
			-- Protect yourself
			if tx == self.x and ty == self.y then d = dam * (1 - prot) end
			-- Protect the golem
			if golem and tx == golem.x and ty == golem.y then d = dam * (1 - prot) end
			if d == 0 then return end

			local target = game.level.map(tx, ty, Map.ACTOR)
			dam_done = dam_done + DamageType:get(damtype).projector(self, tx, ty, damtype, d, tmp)
			if ammo.alchemist_bomb and ammo.alchemist_bomb.splash then
				DamageType:get(DamageType[ammo.alchemist_bomb.splash.type]).projector(self, tx, ty, DamageType[ammo.alchemist_bomb.splash.type], ammo.alchemist_bomb.splash.dam)
			end
			if not target then return end
			if ammo.alchemist_bomb and ammo.alchemist_bomb.stun and rng.percent(ammo.alchemist_bomb.stun.chance) and target:canBe("stun") then
				target:setEffect(target.EFF_STUNNED, ammo.alchemist_bomb.stun.dur, {apply_power=self:combatSpellpower()})
			end
			if ammo.alchemist_bomb and ammo.alchemist_bomb.daze and rng.percent(ammo.alchemist_bomb.daze.chance) and target:canBe("stun") then
				target:setEffect(target.EFF_DAZED, ammo.alchemist_bomb.daze.dur, {apply_power=self:combatSpellpower()})
			end
		end)

		if ammo.alchemist_bomb and ammo.alchemist_bomb.leech then self:heal(math.min(self.max_life * ammo.alchemist_bomb.leech / 100, dam_done)) end

		local _ _, x, y = self:canProject(tg, x, y)
		game.level.map:particleEmitter(x, y, tg.radius, particle, {radius=tg.radius, grids=grids, tx=x, ty=y})

		if ammo.alchemist_bomb and ammo.alchemist_bomb.mana then self:incMana(ammo.alchemist_bomb.mana) end

		game:playSoundNear(self, "talents/arcane")
		return true
	end,
	info = function(self, t)
		local ammo = self:hasAlchemistWeapon()
		local dam, damtype = 1, DamageType.FIRE
		if ammo then dam, damtype = t.computeDamage(self, t, ammo) end
		dam = damDesc(self, damtype, dam)
		return ([[연금술용 보석에 폭발력을 불어넣어 던집니다. 던져진 보석은 폭발하여 %0.2f 피해를 줍니다. (속성 : %s)
		보석의 종류마다 폭발할 때 발생하는 효과가 달라집니다.
		연금술 폭탄의 피해량은 보석의 등급과 주문력의 영향을 받아 증가합니다.]]):format(dam, DamageType:get(damtype).name)
	end,
}

newTalent{
	name = "Alchemist Protection",
	kr_display_name = "연금술 보호대책",
	type = {"spell/explosives", 2},
	require = spells_req2,
	mode = "passive",
	points = 5,
	on_learn = function(self, t)
		self.resists[DamageType.FIRE] = (self.resists[DamageType.FIRE] or 0) + 3
		self.resists[DamageType.COLD] = (self.resists[DamageType.COLD] or 0) + 3
		self.resists[DamageType.LIGHTNING] = (self.resists[DamageType.LIGHTNING] or 0) + 3
		self.resists[DamageType.ACID] = (self.resists[DamageType.ACID] or 0) + 3
	end,
	on_unlearn = function(self, t)
		self.resists[DamageType.FIRE] = self.resists[DamageType.FIRE] - 3
		self.resists[DamageType.COLD] = self.resists[DamageType.COLD] - 3
		self.resists[DamageType.LIGHTNING] = self.resists[DamageType.LIGHTNING] - 3
		self.resists[DamageType.ACID] = self.resists[DamageType.ACID] - 3
	end,
	info = function(self, t)
		return ([[특수한 보호대책을 마련하여 자신의 연금술 폭탄에 대한 속성 피해를 %d%% 감소시키고, 기타 일반적인 속성 피해도 %d%% 감소시킵니다. (적용 속성 : 화염, 냉기, 전격, 산성)
		기술 레벨이 5 가 되면, 연금술 폭탄으로 발생하는 특수효과까지 무시할 수 있습니다.
		연금술 보호대책은 자신의 골렘에게도 적용됩니다.]]):
		format(self:getTalentLevelRaw(t) * 20, self:getTalentLevelRaw(t) * 3)
	end,
}

newTalent{
	name = "Explosion Expert",
	kr_display_name = "폭발물 전문가",
	type = {"spell/explosives", 3},
	require = spells_req3,
	mode = "passive",
	points = 5,
	info = function(self, t)
		local theorical_nb = ({ 9, 25, 45, 77, 109, 145 })[1 + self:getTalentLevelRaw(self.T_EXPLOSION_EXPERT)] or 145
		local min = 1
		local min = (math.log10(min) / (6 - self:getTalentLevelRaw(self.T_EXPLOSION_EXPERT)))
		local max = theorical_nb
		local max = (math.log10(max) / (6 - self:getTalentLevelRaw(self.T_EXPLOSION_EXPERT)))

		return ([[연금술 폭탄의 폭발 범위가 %d 칸 넓어집니다.
		또한 최대 폭발 범위에서 1 칸 부족한 범위까지는 폭발 피해량이 %d%% 증가하며, 폭발의 중심부는 피해량이 %d%% 증가합니다.]]):format(self:getTalentLevelRaw(t), min*100, max*100)
	end,
}

newTalent{
	name = "Shockwave Bomb",
	kr_display_name = "충격적 폭탄",
	type = {"spell/explosives",4},
	require = spells_req4,
	points = 5,
	mana = 32,
	cooldown = 10,
	range = function(self, t)
		return math.ceil(4 + self:getTalentLevelRaw(t))
	end,
	radius = 2,
	direct_hit = true,
	requires_target = true,
	target = function(self, t)
		local ammo = self:hasAlchemistWeapon()
		-- Using friendlyfire, although this could affect escorts etc.
		local friendlyfire = true
		local prot = self:getTalentLevelRaw(self.T_ALCHEMIST_PROTECTION) * 20
		if prot > 0 then
			friendlyfire = 100 - prot
		end
		return {type="ball", range=self:getTalentRange(t)+(ammo and ammo.alchemist_bomb and ammo.alchemist_bomb.range or 0), radius=self:getTalentRadius(t), friendlyfire=friendlyfire, talent=t}
	end,
	tactical = { ATTACKAREA = { PHYSICAL = 2 }, DISABLE = { knockback = 2 } },
	computeDamage = function(self, t, ammo)
		local inc_dam = 0
		local damtype = DamageType.SPELLKNOCKBACK
		local particle = "ball_fire"
		inc_dam = (ammo.alchemist_bomb and ammo.alchemist_bomb.power or 0) / 100
		local dam = self:combatTalentSpellDamage(t, 15, 120, ((ammo.alchemist_power or 0) + self:combatSpellpower()) / 2)
		dam = dam * (1 + inc_dam)
		return dam, damtype, particle
	end,
	action = function(self, t)
		local ammo = self:hasAlchemistWeapon()
		if not ammo or ammo:getNumber() < 2 then
			game.logPlayer(self, "이 기술을 사용하려면 2 개의 연금술용 보석을 손에 들고있어야 합니다.")
			return
		end

		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end

		self:removeObject(self:getInven("QUIVER"), 1)
		ammo = self:removeObject(self:getInven("QUIVER"), 1)
		if not ammo then return end

		local dam, damtype, particle = t.computeDamage(self, t, ammo)
		dam = self:spellCrit(dam)
		local prot = self:getTalentLevelRaw(self.T_ALCHEMIST_PROTECTION) * 0.2
		local golem
		if self.alchemy_golem then
			golem = game.level:hasEntity(self.alchemy_golem) and self.alchemy_golem or nil
		end
		local dam_done = 0

		local tmp = {}
		local grids = self:project(tg, x, y, function(tx, ty)
			local d = dam
			-- Protect yourself
			if tx == self.x and ty == self.y then d = dam * (1 - prot) end
			-- Protect the golem
			if golem and tx == golem.x and ty == golem.y then d = dam * (1 - prot) end
			if d == 0 then return end

			local target = game.level.map(tx, ty, Map.ACTOR)
			dam_done = dam_done + DamageType:get(damtype).projector(self, tx, ty, damtype, d, tmp)
			if ammo.alchemist_bomb and ammo.alchemist_bomb.splash then
				DamageType:get(DamageType[ammo.alchemist_bomb.splash.type]).projector(self, tx, ty, DamageType[ammo.alchemist_bomb.splash.type], ammo.alchemist_bomb.splash.dam)
			end
			if not target then return end
			if ammo.alchemist_bomb and ammo.alchemist_bomb.stun and rng.percent(ammo.alchemist_bomb.stun.chance) and target:canBe("stun") then
				target:setEffect(target.EFF_STUNNED, ammo.alchemist_bomb.stun.dur, {apply_power=self:combatSpellpower()})
			end
			if ammo.alchemist_bomb and ammo.alchemist_bomb.daze and rng.percent(ammo.alchemist_bomb.daze.chance) and target:canBe("stun") then
				target:setEffect(target.EFF_DAZED, ammo.alchemist_bomb.daze.dur, {apply_power=self:combatSpellpower()})
			end
		end)

		if ammo.alchemist_bomb and ammo.alchemist_bomb.leech then self:heal(math.min(self.max_life * ammo.alchemist_bomb.leech / 100, dam_done)) end

		local _ _, x, y = self:canProject(tg, x, y)
		game.level.map:particleEmitter(x, y, tg.radius, particle, {radius=tg.radius, grids=grids, tx=x, ty=y})

		if ammo.alchemist_bomb and ammo.alchemist_bomb.mana then self:incMana(ammo.alchemist_bomb.mana) end

		game:playSoundNear(self, "talents/arcane")
		return true
	end,
	info = function(self, t)
		local ammo = self:hasAlchemistWeapon()
		local dam, damtype = 1
		if ammo then dam = t.computeDamage(self, t, ammo) end
		dam = damDesc(self, DamageType.PHYSICAL, dam)
		return ([[두 개의 연금술용 보석을 강제로 섞어, 극도로 불안정한 상태로 만듭니다. 이렇게 만들어진 연금술 폭탄으로 강렬한 폭발을 만들어내 %0.2f 물리 피해를 주고, 폭발에 휩쓸린 모든 적들을 밀어냅니다.
		폭발할 때,두 개의 보석이 원래 가지고 있던 특수효과가 각각 발생합니다.
		폭발의 피해량은 보석의 등급과 주문력의 영향을 받아 증가합니다.]]):format(dam)
	end,
}
