-- ToME - Tales of Maj'Eyal
-- Copyright (C) 2009 - 2014 Nicolas Casalini
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

-- This concept plays well but vs. low damage levels spam bumping can make stupidly large shields
-- Leaving as is for now but will likely change somehow
newTalent{
	name = "Weapon of Light",
	kr_name = "빛의 무기",
	type = {"celestial/combat", 1},
	mode = "sustained",
	require = divi_req1,
	points = 5,
	cooldown = 10,
	sustain_positive = 10,
	tactical = { BUFF = 2 },
	range = 10,
	getDamage = function(self, t) return 7 + self:combatSpellpower(0.092) * self:combatTalentScale(t, 1, 7) end,
	getShieldFlat = function(self, t)
		return t.getDamage(self, t) / 2
	end,
	activate = function(self, t)
		game:playSoundNear(self, "talents/spell_generic2")
		local ret = {
			dam = self:addTemporaryValue("melee_project", {[DamageType.LIGHT]=t.getDamage(self, t)}),
		}
		return ret
	end,
	deactivate = function(self, t, p)
		self:removeTemporaryValue("melee_project", p.dam)
		return true
	end,
	callbackOnMeleeAttack = function(self, t, target, hitted, crit, weapon, damtype, mult, dam)
		if hitted and self:hasEffect(self.EFF_DAMAGE_SHIELD) and (self:reactionToward(target) < 0) then
			-- Shields can't usually merge, so change the parameters manually 
			local shield = self:hasEffect(self.EFF_DAMAGE_SHIELD)
			local shield_power = t.getShieldFlat(self, t)

			shield.power = shield.power + shield_power
			self.damage_shield_absorb = self.damage_shield_absorb + shield_power
			self.damage_shield_absorb_max = self.damage_shield_absorb_max + shield_power
			shield.dur = math.max(2, shield.dur)

			-- Limit the number of times a shield can be extended, Bathe in Light also uses this code
			if shield.dur_extended then
				shield.dur_extended = shield.dur_extended + 1
				if shield.dur_extended >= 20 then
					game.logPlayer(self, "#DARK_ORCHID#피해 보호막은 이 이상 재충전될 수 없습니다. 보호막이 폭발했습니다.") 
					self:removeEffect(self.EFF_DAMAGE_SHIELD)
				end
			else shield.dur_extended = 1 end
		end

	end,
	info = function(self, t)
		local damage = t.getDamage(self, t)
		local shieldflat = t.getShieldFlat(self, t)
		return ([[무기에 태양의 힘을 불어넣어, 근접 공격마다 %0.1f 빛 피해를 추가로 줍니다.
		또한 일시적인 피해 보호막이 발동 중일 경우, 근접 공격이 보호막을 재충전시켜 피해 흡수량을 %d 만큼 증가시킵니다.
		하나의 피해 보호막을 20 회 이상 재충전시킬 경우, 보호막이 불안정해져 사라지게 됩니다.
		피해량과 보호막 충전량은 주문력의 영향을 받아 증가합니다.]]): 
		format(damDesc(self, DamageType.LIGHT, damage), shieldflat)
	end,
}

-- A potentially very powerful ranged attack that gets more effective with range
-- 2nd attack does reduced damage to balance high damage on 1st attack (so that the talent is always useful at low levels and close ranges)
newTalent{
	name = "Wave of Power",
	kr_name = "힘의 파동",
	type = {"celestial/combat",2},
	require = divi_req2,
	points = 5,
	random_ego = "attack",
	cooldown = 6,
	positive = 15,
	tactical = { ATTACK = 2 },
	requires_target = true,
	range = function(self, t) return 2 + math.max(0, self:combatStatScale("str", 0.8, 8)) end,
	SecondStrikeChance = function(self, t, range)
		return self:combatLimit(self:getTalentLevel(t)*range, 100, 15, 4, 70, 50)
	end, -- 15% for TL 1.0 at range 4, 70% for TL 5.0 at range 10
	getDamage = function(self, t, second)
		if second then
			return self:combatTalentWeaponDamage(t, 0.9, 2)*self:combatTalentLimit(t, 1.0, 0.4, 0.65)
		else
			return self:combatTalentWeaponDamage(t, 0.9, 2)
		end
	end,
	action = function(self, t)
		local tg = {type="hit", range=self:getTalentRange(t), talent=t}
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		local _ _, x, y = self:canProject(tg, x, y)
		local target = game.level.map(x, y, Map.ACTOR)
		if target then
			self:attackTarget(target, nil, t.getDamage(self, t), true)
			local range = core.fov.distance(self.x, self.y, target.x, target.y)
			if range > 1 and rng.percent(t.SecondStrikeChance(self, t, range)) then
				game.logSeen(self, "#CRIMSON#"..(self.kr_name or self.name).."의 두 번째 힘의 파동이 발사됩니다!#NORMAL#") 
				self:attackTarget(target, nil, t.getDamage(self, t, true), true)
			end
		else
			return
		end
		return true
	end,
	info = function(self, t)
		local range = self:getTalentRange(t)
		return ([[순수한 힘을 방출하여, 원거리에 있는 적에게 %d%% 무기 피해를 줍니다.
		적이 근접공격 범위 밖에 있다면, %d%% 의 무기 피해로 두 번째 공격을 발사할 확률이 존재합니다.
		두 번 공격할 확률은 거리에 따라 증가하여, 2 칸 밖의 적에게 %0.1f%% / 최대 %d 칸 밖의 적에게 %0.1f%% 확률을 가집니다.
		최대 사거리는 힘 능력치의 영향을 받아 증가합니다.]]): 
		format(t.getDamage(self, t)*100, t.getDamage(self, t, true)*100, t.SecondStrikeChance(self, t, 2), range, t.SecondStrikeChance(self, t, range))
	end,
}

-- Interesting interactions with shield timing, lots of synergy and antisynergy in general
newTalent{
	name = "Weapon of Wrath",
	kr_name = "분노의 무기", 
	type = {"celestial/combat", 3},
	mode = "sustained",
	require = divi_req3,
	points = 5,
	cooldown = 10,
	sustain_positive = 10,
	tactical = { BUFF = 2 },
	range = 10,
	getMartyrDamage = function(self, t) return self:combatTalentLimit(t, 50, 5, 25) end, --Limit < 50%
	getLifeDamage = function(self, t) return self:combatTalentLimit(t, 1.0, 0.1, 0.8) end, -- Limit < 100%
	getMaxDamage = function(self, t) return self:combatTalentSpellDamage(t, 10, 400) end,
	getDamage = function(self, t)
		local damage = (self:attr("weapon_of_wrath_life") or t.getLifeDamage(self, t)) * (self.max_life - math.max(0, self.life)) -- avoid problems with die_at
		return math.min(t.getMaxDamage(self, t), damage) -- The Martyr effect provides the upside for high HP NPC's
	end,
	activate = function(self, t)
		game:playSoundNear(self, "talents/spell_generic2")
		-- Is this any better than having the callback call getLifeDamage?  I figure its better to calculate it once
		local ret = {
			martyr = self:addTemporaryValue("weapon_of_wrath_martyr", t.getMartyrDamage(self, t)),
			damage = self:addTemporaryValue("weapon_of_wrath_life", t.getLifeDamage(self, t)),
		}
		return ret
	end,
	deactivate = function(self, t, p)
		self:removeTemporaryValue("weapon_of_wrath_martyr", p.martyr)
		self:removeTemporaryValue("weapon_of_wrath_life", p.damage)
		return true
	end,
	callbackOnMeleeAttack = function(self, t, target, hitted, crit, weapon, damtype, mult, dam)
		if hitted and self:attr("weapon_of_wrath_martyr") and not self.turn_procs.weapon_of_wrath and not target.dead then
			target:setEffect(target.EFF_MARTYRDOM, 4, {power = self:attr("weapon_of_wrath_martyr")})
			local damage = t.getDamage(self, t)
			if damage == 0 then return end
			local tg = {type="hit", range=10, selffire=true, talent=t}
			self:project(tg, target.x, target.y, DamageType.FIRE, damage)
			self.turn_procs.weapon_of_wrath = true
		end
	end,
	info = function(self, t)
		local martyr = t.getMartyrDamage(self, t)
		local damagepct = t.getLifeDamage(self, t)
		local damage = t.getDamage(self, t)
		return ([[무기가 정당한 분노로 타올라, 잃은 생명력의 %d%% 만큼 적에게 추가 피해를 입힙니다. (최대 피해량 : %d / 현재 피해량 : %d)
		또한 피해를 입은 적은 고난 상태효과에 걸려, 4 턴 동안 대상이 가한 피해량의 %d%% 만큼 대상 스스로도 피해를 입게 됩니다.]]): 
		format(damagepct*100, t.getMaxDamage(self, t, 10, 400), damage, martyr)
	end,
} 

-- Core class defense to be compared with Bone Shield, Aegis, Indiscernable Anatomy, etc
-- !H/Shield could conceivably reactivate this in the same fight with Crusade spam if it triggers with Suncloak up, 2H never will without running
newTalent{
	name = "Second Life",
	kr_name = "두번째 생명",
	type = {"celestial/combat", 4},
	require = divi_req4, no_sustain_autoreset = true,
	points = 5,
	mode = "sustained",
	sustain_positive = 20,
	cooldown = 30,
	tactical = { DEFEND = 2 },
	getLife = function(self, t) return self.max_life * self:combatTalentLimit(t, 1.5, 0.09, 0.4) end, -- Limit < 150% max life (to survive a large string of hits between turns)
	activate = function(self, t)
		game:playSoundNear(self, "talents/heal")
		local ret = {}
		if core.shader.active(4) then
			ret.particle = self:addParticles(Particles.new("shader_ring_rotating", 1, {toback=true, a=0.6, rotation=0, radius=2, img="flamesgeneric"}, {type="sunaura", time_factor=6000}))
		else
			ret.particle = self:addParticles(Particles.new("golden_shield", 1))
		end
		return ret
	end,
	deactivate = function(self, t, p)
		self:removeParticles(p.particle)
		return true
	end,
	info = function(self, t)
		return ([[공격을 받아 생명력이 1 밑으로 떨어지게 되면, 두번째 생명이 발동되어 기술 유지가 해제되고 생명력이 %d 인 상태가 됩니다.]]):
		format(t.getLife(self, t))
	end,
}

