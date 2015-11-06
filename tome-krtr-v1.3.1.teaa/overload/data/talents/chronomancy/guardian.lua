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

-- EDGE TODO: Particles, Timed Effect Particles

newTalent{
	name = "Strength of Purpose",
	kr_name = "목표의 힘",
	type = {"chronomancy/guardian", 1},
	points = 5,
	require = { stat = { mag=function(level) return 12 + level * 6 end }, },
	mode = "passive",
	getDamage = function(self, t) return self:getTalentLevel(t) * 10 end,
	getPercentInc = function(self, t) return math.sqrt(self:getTalentLevel(t) / 5) / 2 end,
	info = function(self, t)
		local damage = t.getDamage(self, t)
		local inc = t.getPercentInc(self, t)
		return ([[물리력이 %d만큼 상승하고, 검, 도끼, 둔기, 단검, 활을 사용할 때의 무기 피해량을 %d%%만큼 상승시킵니다.
		당신은 또한 무기 착용시 요구 능력치나, 무기 피해에 능력치를 고려 할때, 힘 능력치 대신에 마법 능력치가 적용됩니다.
		물리력 상승이나 무기 피해량 상승은 무기 수련이나 단검 수련, 활 수련에 같이 적용 되지 않습니다.]]):
		format(damage, 100*inc)
	end,
}

newTalent{
	name = "Guardian Unity",
	kr_name = "수호자 연합",
	type = {"chronomancy/guardian", 2},
	require = chrono_req2,
	points = 5,
	mode = "passive",
	cooldown = 10,
	getDuration = function(self, t) return getExtensionModifier(self, t, 2) end,
	getLifeTrigger = function(self, t) return self:combatTalentLimit(t, 10, 30, 15)	end,
	getDamageSplit = function(self, t) return self:combatTalentLimit(t, 40, 10, 30)/100 end, -- Limit < 40%
	remove_on_clone = true,
	callbackOnHit = function(self, t, cb, src)
		local split = cb.value * t.getDamageSplit(self, t)

		-- If we already have a guardian, split the damage
		if self.unity_warden and game.level:hasEntity(self.unity_warden) then
		
			game:delayedLogDamage(src, self.unity_warden, split, ("#STEEL_BLUE#(%d 나눠 줌)#LAST#"):format(split), nil)
			cb.value = cb.value - split
			self.unity_warden:takeHit(split, src)
		
		-- Otherwise, summon a new Guardian
		elseif not self:isTalentCoolingDown(t) and self.max_life and cb.value >= self.max_life * (t.getLifeTrigger(self, t)/100) then
		
			-- Look for space first
			local tx, ty = util.findFreeGrid(self.x, self.y, 5, true, {[Map.ACTOR]=true})
			if tx and ty then
				-- Put the talent on cooldown
				self:startTalentCooldown(t)
				
				-- clone our caster
				local m = makeParadoxClone(self, self, t.getDuration(self, t))
				-- Handle some AI stuff
				m.ai_state = { talent_in=1, ally_compassion=10 }
				m.ai_state.tactic_leash = 10
				-- Try to use stored AI talents to preserve tweaking over multiple summons
				m.ai_talents = self.stored_ai_talents and self.stored_ai_talents[m.name] or {}
				-- alter some values
				m.remove_from_party_on_death = true
				m:attr("archery_pass_friendly", 1)
				m.generic_damage_penalty = 50
				m.on_die = function(self)
					local summoner = self.summoner
					if summoner.unity_warden then summoner.unity_warden = nil end
				end

				-- add our clone
				game.zone:addEntity(game.level, m, "actor", tx, ty)
				game.level.map:particleEmitter(tx, ty, 1, "temporal_teleport")

				if game.party:hasMember(self) then
					game.party:addMember(m, {
						control="order",
						type="temporal-clone",
						title="Guardian",
						orders = {target=true, leash=true, anchor=true, talents=true},
					})
				end
				
				-- split the damage
				cb.value = cb.value - (split * 2)
				self.unity_warden = m
				m:takeHit(split, src)
				m:setTarget(src or nil)
				game:delayedLogMessage(self, nil, "guardian_damage", "#STEEL_BLUE##Source# 피해를 %s의 수호자에게 나눠 주었습니다!", string.his_her(self))
				game:delayedLogDamage(src or self, self, 0, ("#STEEL_BLUE#(%d 나눠 줌)#LAST#"):format(split), nil)

			else
				game.logPlayer(self, "감시자를 소환하기 위한 공간이 부족합니다!")
			end
		end
		
		return cb.value
	end,
	info = function(self, t)
		local trigger = t.getLifeTrigger(self, t)
		local split = t.getDamageSplit(self, t) * 100
		local duration = t.getDuration(self, t)
		local cooldown = self:getTalentCooldown(t)
		return ([[만약 하나의 공격이 당신의 최대 생명력의 %d%% 보다 많이 피해를 입혔다면, 또 다른 당신이 나타나 %d%%의 피해를 가져가고 다음에 입을 피해 또한 %d%% 만큼 %d턴 간 가져갑니다.
		또 다른 당신은 이 현실의 위상에서 벗어나 있기 때문에 50%% 만큼 적은 피해를 입히지만, 그의 화살은 아군을 통과 할 수 있습니다.
		이 스킬은 재사용 대기시간이 있습니다.]]):format(trigger, split * 2, split, duration)
	end,
}

newTalent{
	name = "Vigilance",
	kr_name = "경계",
	type = {"chronomancy/guardian", 3},
	require = chrono_req3,
	points = 5,
	mode = "passive",
	getSense = function(self, t) return self:combatTalentStatDamage(t, "mag", 10, 50) end,
	getPower = function(self, t) return self:combatTalentLimit(t, 40, 10, 30) end, -- Limit < 40%
	passives = function(self, t, p)
		self:talentTemporaryValue(p, "see_stealth", t.getSense(self, t))
		self:talentTemporaryValue(p, "see_invisible", t.getSense(self, t))
	end,
	callbackOnStatChange = function(self, t, stat, v)
		if stat == self.STAT_MAG then
			self:updateTalentPassives(t)
		end
	end,
	callbackOnActBase = function(self, t)
		if rng.percent(t.getPower(self, t)) then
			if self:removeEffectsFilter({status="detrimental", ignore_crosstier=true}, 1) > 0 then
				game.logSeen(self, "#ORCHID#%s has recovered!#LAST#", self.name:capitalize())
			end
		end
	end,
	info = function(self, t)
		local sense = t.getSense(self, t)
		local power = t.getPower(self, t)
		return ([[투명체 감지 능력을 +%d 만큼, 은신 감지 능력을 +%d만큼 상승 시킵니다. 또한 당신은 매턴 %d%% 확률로 하나의 부정적인 효과를 회복 할 수 있습니다.
			감지 능력은 마법 능력치에 비례하여 상승합니다.]]):
		format(sense, sense, power)
	end,
}

newTalent{
	name = "Warden's Focus", short_name=WARDEN_S_FOCUS,
	kr_name = "감시자의 주목"
	type = {"chronomancy/guardian", 4},
	require = chrono_req4,
	points = 5,
	cooldown = 6,
	paradox = function (self, t) return getParadoxCost(self, t, 10) end,
	tactical = { BUFF = 2, DEFEND = 2 },
	direct_hit = true,
	requires_target = true,
	range = function(self, t)
		if self:hasArcheryWeapon() then return util.getval(archery_range, self, t) end
		return 1
	end,
	target = function(self, t)
		return {type="bolt", range=self:getTalentRange(t), talent=t, friendlyfire=false, friendlyblock=false}
	end,
	is_melee = function(self, t) return not self:hasArcheryWeapon() end,
	speed = function(self, t) return self:hasArcheryWeapon() and "archery" or "weapon" end,
	on_pre_use = function(self, t, silent) if self:attr("disarmed") then if not silent then game.logPlayer(self, "당신은 이 기술을 사용하기 위해서는 무기가 필요합니다.") end return false end return true end,
	getPower = function(self, t) return self:combatTalentLimit(t, 40, 10, 30) end, -- Limit < 40%
	getDamage = function(self, t) return 1.2 end,
	getDuration = function(self, t) return getExtensionModifier(self, t, 10) end,
	action = function(self, t)
		-- Grab our target so we can set our effect
		local tg = self:getTalentTarget(t)
		local _, x, y = self:canProject(tg, self:getTarget(tg))
		local target = game.level.map(x, y, game.level.map.ACTOR)
		if not x or not y or not target then game.logPlayer(self, "당신은 주목할 상대를 선택해야 합니다.")return nil end

		if self:hasArcheryWeapon() then
			-- Ranged attack
			local targets = self:archeryAcquireTargets({type="bolt"}, {x=x, y=y, one_shot=true, no_energy = true})
			if not targets then return end
			self:archeryShoot(targets, t, {type="bolt"}, {mult=t.getDamage(self, t)})
		else
			-- Melee attack
			self:attackTarget(target, nil, t.getDamage(self, t), true)
		end
		
		self:setEffect(self.EFF_WARDEN_S_FOCUS, t.getDuration(self, t), {target=target, power=t.getPower(self, t)})
		target:setEffect(target.EFF_WARDEN_S_TARGET, t.getDuration(self, t), {src=self})
		
		return true
	end,
	info = function(self, t)
		local damage = t.getDamage(self, t) * 100
		local power = t.getPower(self, t)
		local duration = t.getDuration(self, t)
		return ([[당신의 목표를 원거리 무기나, 근접 무기 중 하나로 %d%%의 무기 피해를 입힙니다. 다음 %d 턴 동안 무작위 상대를 고르는 기술(칼날 명멸이나 감시자의 부름 같은)은 이제 이 목표에게 집중되게 됩니다.
		이 목표에 대한 공격은 %d%%의 추가 치명타 확률과 치명타 배율을 가지며 목표보다 낮은 랭크의 적에게서 받는 피해를 %d%% 만큼 줄입니다.]])
		:format(damage, duration, power, power, power)
	end
}
