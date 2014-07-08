-- Skirmisher, a class for Tales of Maj'Eyal 1.1.5
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

local sling_equipped = function(self, silent)
	if not self:hasArcheryWeapon("sling") then
		if not silent then
			game.logPlayer(self, "투석구를 장착해야 합니다!")
		end
		return false
	end
	return true
end

-- Currently just a copy of Sling Mastery.
newTalent {
	short_name = "SKIRMISHER_SLING_SUPREMACY",
	name = "Sling Supremacy",
	kr_name = "투석구 우월주의",
	image = "talents/sling_mastery.png",
	type = {"technique/skirmisher-slings", 1},
	points = 5,
	require = { stat = { dex=function(level) return 12 + level * 6 end }, },
	mode = "passive",
	getDamage = function(self, t) return self:getTalentLevel(t) * 10 end,
	getPercentInc = function(self, t) return math.sqrt(self:getTalentLevel(t) / 5) / 2 end,
	ammo_mastery_reload = function(self, t)
		return math.floor(self:combatTalentScale(t, 0, 2.7, "log"))
	end,
	passives = function(self, t, p)
		self:talentTemporaryValue(p, 'ammo_mastery_reload', t.ammo_mastery_reload(self, t))
	end,
	info = function(self, t)
		local damage = t.getDamage(self, t)
		local inc = t.getPercentInc(self, t)
		local reloads = t.ammo_mastery_reload(self, t)
		return ([[투석구를 사용할 때 물리력이 %d / 무기 피해량이 %d%% 상승합니다.
		또한, 한번에 %d 발의 탄환을 추가로 재장전할 수 있게 됩니다.]]):format(damage, inc * 100, reloads)
	end,
}

newTalent {
	short_name = "SKIRMISHER_SWIFT_SHOT",
	name = "Swift Shot",
	kr_name = "속사",
	type = {"technique/skirmisher-slings", 2},
	require = techs_dex_req2,
	points = 5,
	no_energy = "fake",
	random_ego = "attack",
	tactical = {ATTACK = {weapon = 2}},
	range = archery_range,
	cooldown = 5,
	stamina = 15,
	requires_target = true,
	on_pre_use = function(self, t, silent) return sling_equipped(self, silent) end,
	getDamage = function(self, t)
		return self:combatTalentWeaponDamage(t, 0.4, 1.6)
	end,
	callbackOnMove = function(self, t, moved, force, ox, oy)
		local cooldown = self.talents_cd[t.id] or 0
		if cooldown > 0 then
			self.talents_cd[t.id] = math.max(cooldown - 1, 0)
		end
	end,
	action = function(self, t)
		local old_speed = self.combat_physspeed
		self.combat_physspeed = old_speed * 2

		local targets = self:archeryAcquireTargets(nil, {one_shot=true})
		if not targets then
			self.combat_physspeed = old_speed
			return
		end

		self:archeryShoot(targets, t, nil, {mult=t.getDamage(self, t)})

		-- Cooldown Hurricane Shot by 1.
		local hurricane_cd = self.talents_cd["T_SKIRMISHER_HURRICANE_SHOT"]
		if hurricane_cd then
			self.talents_cd["T_SKIRMISHER_HURRICANE_SHOT"] = math.max(0, hurricane_cd - 1)
		end

		self.combat_physspeed = old_speed
		return true
	end,
	info = function(self, t)
		return ([[투석구 탄환을 빠르게 발사하여, %d%% 피해를 가합니다. 이 공격은 기존 공격보다 2 배 빠르게 공격하며, 이동할 때마다 재사용 대기 시간이 추가로 1 턴 감소합니다.]])
			:format(t.getDamage(self, t) * 100)
	end,
}

newTalent {
	short_name = "SKIRMISHER_HURRICANE_SHOT",
	name = "Hurricane Shot",
	kr_name = "폭풍 사격",
	type = {"technique/skirmisher-slings", 3},
	require = techs_dex_req3,
	points = 5,
	no_energy = "fake",
	random_ego = "attack",
	tactical = {ATTACKALL = {weapon = 3}},
	range = 0,
	radius = archery_range,
	cooldown = 7,
	stamina = 45,
	requires_target = true,
	target = function(self, t)
		return {
			type = "cone",
			range = self:getTalentRange(t),
			radius = self:getTalentRadius(t),
			selffire = false,
			talent = t,
			--cone_angle = 50, -- degrees
		}
	end,
	on_pre_use = function(self, t, silent) return sling_equipped(self, silent) end,
	damage_multiplier = function(self, t)
		return self:combatTalentWeaponDamage(t, 0.2, 0.8)
	end,
	-- Maximum number of shots fired.
	limit_shots = function(self, t)
		return math.floor(self:combatTalentScale(t, 6, 11, "log"))
	end,
	action = function(self, t)
		-- Get list of possible targets, possibly doubled.
		local double = self:getTalentLevel(t) >= 3
		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
		if not x or not y then return end
		local targets = {}
		local add_target = function(x, y)
			local target = game.level.map(x, y, game.level.map.ACTOR)
			if target and self:reactionToward(target) < 0 and self:canSee(target) then
				targets[#targets + 1] = target
				if double then targets[#targets + 1] = target end
			end
		end
		self:project(tg, x, y, add_target)
		if #targets == 0 then return end

		table.shuffle(targets)

		-- Fire each shot individually.
		local old_target_forced = game.target.forced
		local limit_shots = t.limit_shots(self, t)
		local shot_params_base = {mult = t.damage_multiplier(self, t), phasing = true}
		local fired = nil -- If we've fired at least one shot.
		for i = 1, math.min(limit_shots, #targets) do
			local target = targets[i]
			game.target.forced = {target.x, target.y, target}
			local targets = self:archeryAcquireTargets({type = "hit", speed = 200}, {one_shot=true, no_energy = fired})
			if targets then
				local params = table.clone(shot_params_base)
				local target = targets.dual and targets.main[1] or targets[1]
				params.phase_target = game.level.map(target.x, target.y, game.level.map.ACTOR)
				self:archeryShoot(targets, t, {type = "hit", speed = 200}, params)
				fired = true
			else
				-- If no target that means we're out of ammo.
				break
			end
		end

		game.target.forced = old_target_forced
		return fired
	end,
	info = function(self, t)
		return ([[조준한 뒤, 최대 %d 발의 탄환을 원뿔 모양 공격 범위 내의 모든 적들에게 동시에 발사하여 %d%% 무기 피해를 가합니다. 각각의 적은 한 발의 탄환만 맞게 됩니다. (기술 레벨이 3 이상일 경우, 한 명의 적이 2 발까지 맞게 됩니다) 속사를 사용하면 기술의 재사용 대기 시간이 추가로 1 턴 줄어듭니다.]])
			:format(t.limit_shots(self, t),
							t.damage_multiplier(self, t) * 100)
	end,
}

-- The cost on this is extreme because its a completely ridiculous talent
-- We don't have any other talents like this, really, that are incredibly hard to use for much of anything until late.  Should be interesting.
newTalent {
	short_name = "SKIRMISHER_BOMBARDMENT",
	name = "Bombardment",
	kr_name = "탄환 폭격",
	type = {"technique/skirmisher-slings", 4},
	require = techs_dex_req4,
	points = 5,
	mode = "sustained",
	no_energy = true,
	tactical = { BUFF = 2 },
	on_pre_use = function(self, t, silent) return sling_equipped(self, silent) end,
	cooldown = function(self, t)
		return 10
	end,
	bullet_count = function(self, t)
		return 3
	end,
	shot_stamina = function(self, t)
		return 25 * (1 + self:combatFatigue() * 0.01)
	end,
	damage_multiplier = function(self, t)
		return self:combatTalentWeaponDamage(t, 0.1, 0.6)
	end,
	activate = function(self, t) return {} end,
	deactivate = function(self, t, p) return true end,
	info = function(self, t)
		return ([[기술이 유지되는 동안, 기본 사격 기술이 %d 발의 탄환을 발사하게 됩니다. 대신 각각의 탄환은 %d%% 무기 피해를 가하게 되며, 매 공격마다 %d 체력을 소모하게 됩니다.]])
		:format(t.bullet_count(self, t), t.damage_multiplier(self, t) * 100, t.shot_stamina(self, t))
	end,
}
