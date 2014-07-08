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

local cooldown_bonus = function(self)
	local t = self:getTalentFromId("T_SKIRMISHER_SUPERB_AGILITY")
	return t.cooldown_bonus(self, t)
end

local stamina_bonus = function(self)
	local t = self:getTalentFromId("T_SKIRMISHER_SUPERB_AGILITY")
	return t.stamina_bonus(self, t)
end

newTalent {
	short_name = "SKIRMISHER_VAULT",
	name = "Vault",
	kr_name = "뛰어넘기",
	type = {"technique/acrobatics", 1},
	require = techs_dex_req1,
	points = 5,
	random_ego = "attack",
	cooldown = function(self, t) return 10 - cooldown_bonus(self) end,
	stamina = function(self, t) return math.max(0, 18 - stamina_bonus(self)) end,
	tactical = {ESCAPE = 2},
	on_pre_use = function(self, t)
		return not self:attr("never_move")
	end,
	range = function(self, t)
		return math.floor(self:combatTalentScale(t, 3, 8))
	end,
	target = function(self, t)
		return {type="beam", range=self:getTalentRange(t), talent=t, nolock=true}
	end,
	speed_bonus = function(self, t)
		return self:combatTalentScale(t, 0.6, 1.0, 0.75)
	end,
	action = function(self, t)
		-- Get Landing Point.
		local tg = self:getTalentTarget(t)
		local tx, ty, target = self:getTarget(tg)
		if not tx or not ty then return end
		if core.fov.distance(self.x, self.y, tx, ty) > self:getTalentRange(t) then return end
		if tx == self.x and ty == self.y then return end
		if target or
			game.level.map:checkEntity(tx, ty, Map.TERRAIN, "block_move", self)
		then
			game.logPlayer(self, "착지할 공간이 충분히 확보되지 않았습니다.")
			return
		end

		-- Get Launch target.
		local block_actor = function(_, bx, by)
			return game.level.map:checkEntity(bx, by, Map.TERRAIN, "block_move", self)
		end
		local line = self:lineFOV(tx, ty, block_actor)
		local lx, ly, is_corner_blocked = line:step()
		local launch_target = game.level.map(lx, ly, Map.ACTOR)
		if not launch_target then
			game.logPlayer(self, "발판으로 사용할 아군이나 적이 근처에 있어야 합니다.")
			return
		end

		local ox, oy = self.x, self.y
		self:move(tx, ty, true)

		local give_speed = function()
			self:setEffect(self.EFF_SKIRMISHER_DIRECTED_SPEED, 3, {
				 direction = math.atan2(ty - oy, tx - ox),
				 leniency = math.pi * 0.25, -- 90 degree cone
				 move_speed_bonus = t.speed_bonus(self, t),
				 compass = game.level.map:compassDirection(tx-ox, ty-oy)
			})
		end
		game:onTickEnd(give_speed)

		return true
	end,
	info = function(self, t)
		return ([[근처의 아군이나 적을 발판 삼아, 뛰어넘을 수 있게 됩니다.
		또한 그 탄력으로 인해 가속도가 붙어, 뛰어넘은 방향과 같은 방향으로 달릴 경우 3 턴 동안 이동 속도가 %d%% 빨라집니다.
		빨라진 속도는 이동 방향을 바꾸거나 이동을 멈출 경우 사라집니다.]]):format(t.speed_bonus(self, t) * 100)
	end,
}

newTalent {
	name = "Tumble",
	kr_name = "공중제비",
	short_name = "SKIRMISHER_CUNNING_ROLL",
	type = {"technique/acrobatics", 2},
	require = techs_dex_req2,
	points = 5,
	random_ego = "attack",
	cooldown = function(self, t) return 20 - cooldown_bonus(self) end,
	no_energy = true,
	stamina = function(self, t)
		return math.max(0, 20 - stamina_bonus(self))
	end,
	tactical = {ESCAPE = 2, BUFF = 1},
	range = function(self, t)
		return math.floor(self:combatTalentScale(t, 2, 4))
	end,
	target = function(self, t)
		return {type="beam", range=self:getTalentRange(t), talent=t}
	end,
	combat_physcrit = function(self, t)
		return self:combatTalentScale(t, 2.3, 7.5, 0.75)
	end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y, target = self:getTarget(tg)
		if not x or not y then return end
		if self.x == x and self.y == y then return end
		if core.fov.distance(self.x, self.y, x, y) > self:getTalentRange(t) then return end

		if target or game.level.map:checkEntity(x, y, Map.TERRAIN, "block_move", self) then
			game.logPlayer(self, "공중제비를 할 공간이 충분히 확보되지 않았습니다.")
			return false
		end

		self:move(x, y, true)
		local combat_physcrit = t.combat_physcrit(self, t)
		if combat_physcrit then
			-- Can't set to 0 duration directly, so set to 1 and then decrease by 1.
			self:setEffect("EFF_SKIRMISHER_TACTICAL_POSITION", 1, {combat_physcrit = combat_physcrit})
			local eff = self:hasEffect("EFF_SKIRMISHER_TACTICAL_POSITION")
			eff.dur = eff.dur - 1
		end

		return true
	end,
	info = function(self, t)
		return ([[지정한 곳으로 공중제비를 넘으며 이동합니다. 적들을 통과해서 이동할 수 있으며, 장애물이 있을 경우 돌아서 이동합니다.
		이를 통해 적들을 놀래키고 전술적 위치를 확보해, 1 턴 동안 물리 치명타 확률이 %d%% 상승하게 됩니다.]]):format(t.combat_physcrit(self, t))
	end
}

newTalent {
	short_name = "SKIRMISHER_TRAINED_REACTIONS",
	name = "Trained Reactions",
	kr_name = "훈련된 반사반응",
	type = {"technique/acrobatics", 3},
	mode = "sustained",
	points = 5,
	cooldown = function(self, t) return 10 - cooldown_bonus(self) end,
	stamina_per_use = function(self, t) return 30 - stamina_bonus(self) end,
	sustain_stamina = 10,
	require = techs_dex_req3,
	tactical = { BUFF = 2 },
	activate = function(self, t)
		return {}
	end,
	deactivate = function(self, t, p)
		return true
	end,
	getLifeTrigger = function(self, t)
		return self:combatTalentLimit(t, 10, 40, 24)
	end,
	getReduction = function(self, t)
		return self:combatTalentLimit(t, 60, 10, 30)
	end,
	-- called by mod/Actor.lua, although it could be a callback one day
	onHit = function(self, t, damage)
		-- Don't have trigger cooldown.
		-- if self:hasEffect("EFF_SKIRMISHER_TRAINED_REACTIONS_COOLDOWN") then return damage end

		local cost = t.stamina_per_use(self, t)
		if damage >= self.max_life * t.getLifeTrigger(self, t) * 0.01 then
			
			local nx, ny = util.findFreeGrid(self.x, self.y, 1, true, {[Map.ACTOR]=true})
			if nx and ny and use_stamina(self, cost) then

				-- Apply effect with duration 0.
				self:setEffect("EFF_SKIRMISHER_DEFENSIVE_ROLL", 1, {reduce = t.getReduction(self, t)})
				local eff = self:hasEffect("EFF_SKIRMISHER_DEFENSIVE_ROLL")
				eff.dur = eff.dur - 1

				-- Try to apply bonus effect from Superb Agility.
				local agility = self:getTalentFromId("T_SKIRMISHER_SUPERB_AGILITY")
				local speed = agility.speed_buff(self, agility)
				if speed then
					self:setEffect("EFF_SKIRMISHER_SUPERB_AGILITY", speed.duration, speed)
				end

				return damage * (100-t.getReduction(self, t)) / 100
			end
		end
		return damage
	end,

	info = function(self, t)
		local trigger = t.getLifeTrigger(self, t)
		local reduce = t.getReduction(self, t)
		local cost = t.stamina_per_use(self, t) * (1 + self:combatFatigue() * 0.01)
		return ([[이 기술이 유지 중인 동안에는, 치명적 공격을 예상하고 대비하게 됩니다.
		한 번의 타격으로 생명력의 %d%% 이상을 잃게 될 경우, 잽싸게 몸을 굴려 방어적 자세를 취합니다.
		이를 통해 해당 턴에 가해지는 모든 피해량을 %d%% 감소시킵니다.
		회피 동작에는 %0.1f 체력이 소모되며, 근처에 빈 공간이 있어야 회피 동작을 취할 수 있습니다. (실제로 회피 동작을 통해 이동을 하지는 않습니다)]])
		:format(trigger, reduce, cost)
	end,
}

newTalent {
	short_name = "SKIRMISHER_SUPERB_AGILITY",
	name = "Superb Agility",
	kr_name = "기막힌 몸놀림",
	type = {"technique/acrobatics", 4},
	require = techs_dex_req4,
	mode = "passive",
	points = 5,
	stamina_bonus = function(self, t) return self:combatTalentLimit(t, 18, 3, 10) end, --Limit < 18
	cooldown_bonus = function(self, t) return math.floor(math.max(0, self:combatTalentLimit(t, 10, 1, 5))) end, --Limit < 10
	speed_buff = function(self, t)
		local level = self:getTalentLevel(t)
		if level >= 5 then return {global_speed_add = 0.2, duration = 2} end
		if level >= 3 then return {global_speed_add = 0.1, duration = 1} end
	end,
	info = function(self, t)
		return ([[곡예 실력이 더욱 향상되어, 뛰어넘기, 공중제비, 훈련된 반사반응의 재사용 대기 시간이 %d 턴 / 체력 소모량이 %0.1f 감소합니다.
		기술 레벨이 3 이상일 경우, 훈련된 반사반응으로 회피 동작을 취한 이후 1 턴 동안 전체 속도가 10%% 증가합니다.
		기술 레벨이 5 이상일 경우, 전체 속도 증가량이 20%% 로 상승하고 2 턴 동안 지속됩니다.]])
		:format(t.cooldown_bonus(self, t), t.stamina_bonus(self, t))
	end,
}
