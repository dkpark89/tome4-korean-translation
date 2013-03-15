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

require "engine.krtrUtils"

newTalent{
	name = "Channel Staff",
	kr_name = "지팡이 발동술",
	type = {"spell/staff-combat", 1},
	require = spells_req1,
	points = 5,
	mana = 5,
	tactical = { ATTACK = 1 },
	range = 8,
	reflectable = true,
	proj_speed = 20,
	requires_target = true,
	target = function(self, t)
		return {type="bolt", range=self:getTalentRange(t), talent=t, display = {particle=particle, trail=trail}, friendlyfire=false,
			friendlyblock=false,
		}
	end,
	getDamageMod = function(self, t) return self:combatTalentWeaponDamage(t, 0.4, 1.1) end,
	action = function(self, t)
		local weapon = self:hasStaffWeapon()
		if not weapon then
			game.logPlayer(self, "이 마법을 사용하려면 지팡이를 장비해야 합니다.")
			return
		end
		local combat = weapon.combat

		local trail = "firetrail"
		local particle = "bolt_fire"
		local explosion = "flame"

		local damtype = combat.damtype
		if     damtype == DamageType.FIRE then      explosion = "flame"               particle = "bolt_fire"      trail = "firetrail"
		elseif damtype == DamageType.COLD then      explosion = "freeze"              particle = "ice_shards"     trail = "icetrail"
		elseif damtype == DamageType.ACID then      explosion = "acid"                particle = "bolt_acid"      trail = "acidtrail"
		elseif damtype == DamageType.LIGHTNING then explosion = "lightning_explosion" particle = "bolt_lightning" trail = "lightningtrail"
		elseif damtype == DamageType.LIGHT then     explosion = "light"               particle = "bolt_light"     trail = "lighttrail"
		elseif damtype == DamageType.DARKNESS then  explosion = "dark"                particle = "bolt_dark"      trail = "darktrail"
		elseif damtype == DamageType.NATURE then    explosion = "slime"               particle = "bolt_slime"     trail = "slimetrail"
		elseif damtype == DamageType.BLIGHT then    explosion = "slime"               particle = "bolt_slime"     trail = "slimetrail"
		elseif damtype == DamageType.PHYSICAL then  explosion = "dark"                particle = "stone_shards"   trail = "earthtrail"
		elseif damtype == DamageType.TEMPORAL then  explosion = "light"				  particle = "temporal_bolt"  trail = "lighttrail"
		else                                        explosion = "manathrust"          particle = "bolt_arcane"    trail = "arcanetrail" damtype = DamageType.ARCANE
		end

		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end

		-- Compute damage
		local dam = self:combatDamage(combat)
		local damrange = self:combatDamageRange(combat)
		dam = rng.range(dam, dam * damrange)
		dam = self:spellCrit(dam)
		dam = dam * t.getDamageMod(self, t)

		self:projectile(tg, x, y, damtype, dam, {type=explosion})

		game:playSoundNear(self, "talents/arcane")
		return true
	end,
	info = function(self, t)
		local damagemod = t.getDamageMod(self, t)
		return ([[지팡이에 잠든 순수한 마력을 끌어내, 지팡이 공격력의 %d%% 만큼 피해를 주는 마법 화살을 발사합니다.
		마법 화살의 속성은 지팡이의 공격 속성을 따르며, 이 마법 화살은 아군을 무시하고 적에게만 피해를 줍니다.
		이 기술의 명중률은 언제나 100%% 이며, 대상의 방어도를 무시합니다.]]):
		format(damagemod * 100)
	end,
}

newTalent{
	name = "Staff Mastery",
	kr_name = "지팡이 수련",
	type = {"spell/staff-combat", 2},
	mode = "passive",
	require = spells_req2,
	points = 5,
	getDamage = function(self, t) return self:getTalentLevel(t) * 10 end,
	getPercentInc = function(self, t) return math.sqrt(self:getTalentLevel(t) / 5) / 2 end,
	info = function(self, t)
		local damage = t.getDamage(self, t)
		local inc = t.getPercentInc(self, t)
		return ([[지팡이를 사용할 때 물리력을 %d / 무기 피해량을 %d%% 올려줍니다.]]):
		format(damage, 100 * inc)
	end,
}

newTalent{
	name = "Defensive Posture",
	kr_name = "방어 자세",
	type = {"spell/staff-combat", 3},
	require = spells_req3,
	mode = "sustained",
	points = 5,
	sustain_mana = 20,
	cooldown = 30,
	tactical = { BUFF = 2 },
	getDefense = function(self, t) return self:combatTalentSpellDamage(t, 10, 20) end,
	on_pre_use = function(self, t, silent) if not self:hasStaffWeapon() then if not silent then game.logPlayer(self, "이 기술을 사용하려면 지팡이를 장비해야 합니다.") end return false end return true end,
	activate = function(self, t)

		local power = t.getDefense(self, t)
		game:playSoundNear(self, "talents/arcane")
		return {
			arm = self:addTemporaryValue("combat_armor", power),
			def = self:addTemporaryValue("combat_def", power),
		}
	end,
	deactivate = function(self, t, p)
		self:removeTemporaryValue("combat_armor", p.arm)
		self:removeTemporaryValue("combat_def", p.def)
		return true
	end,
	info = function(self, t)
		local defense = t.getDefense(self, t)
		return ([[방어 자세를 취해, 회피도와 방어도를 %d 올립니다.]]):
		format(defense)
	end,
}

newTalent{
	name = "Blunt Thrust",
	kr_name = "둔중한 찌르기",
	type = {"spell/staff-combat",4},
	require = spells_req4,
	points = 5,
	mana = 12,
	cooldown = 12,
	tactical = { ATTACK = 1, DISABLE = 2, ESCAPE = 1 },
	range = 1,
	requires_target = true,
	target = function(self, t)
		return {type="hit", range=self:getTalentRange(t)}
	end,
	getDamage = function(self, t) return self:combatTalentWeaponDamage(t, 1, 1.5) end,
	getDazeDuration = function(self, t) return 1 + self:getTalentLevel(t) end,
	action = function(self, t)
		local weapon = self:hasStaffWeapon()
		if not weapon then
			game.logPlayer(self, "양손무기를 들지 않으면 둔중한 찌르기를 사용할 수 없습니다!")
			return nil
		end

		local tg = self:getTalentTarget(t)
		local x, y, target = self:getTarget(tg)
		if not x or not y or not target then return nil end
		if core.fov.distance(self.x, self.y, x, y) > 1 then return nil end
		if self:getTalentLevel(t) >= 5 then self.combat_atk = self.combat_atk + 1000 end
		local speed, hit = self:attackTargetWith(target, weapon.combat, nil, t.getDamage(self, t))
		if self:getTalentLevel(t) >= 5 then self.combat_atk = self.combat_atk - 1000 end
		
		-- Try to stun !
		if hit then
			if target:canBe("stun") then
				target:setEffect(target.EFF_STUNNED, t.getDazeDuration(self, t), {apply_power=self:combatSpellpower()})
			else
				game.logSeen(target, "%s 기절하지 않았습니다!", (target.kr_name or target.name):capitalize():addJosa("가"))
			end
		end

		return true
	end,
	info = function(self, t)
		local damage = t.getDamage(self, t)
		local dazedur = t.getDazeDuration(self, t)
		return ([[대상에게 무기를 찔러넣어 %d%% 물리 피해를 주고, %d 턴 동안 기절시킵니다.
		기절 확률은 기술 레벨의 영향을 받아 증가합니다.
		기술 레벨이 5 이상이 되면, 공격이 절대 빗나가지 않습니다.]]):
		format(100 * damage, dazedur)
	end,
}

