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

require "engine.krtrUtils"

newTalent{
	name = "Slumber",
	kr_display_name = "숙면",
	type = {"psionic/slumber", 1},
	points = 5,
	require = psi_wil_req1,
	cooldown = 8,
	psi = 10,
	tactical = { DISABLE = {sleep = 2} },
	direct_hit = true,
	requires_target = true,
	range = 7,
	target = function(self, t) return {type="hit", range=self:getTalentRange(t), talent=t} end,
	getDuration = function(self, t) return 2 + math.ceil(self:getTalentLevel(t)/2) end,
	getInsomniaPower = function(self, t)
		local t = self:getTalentFromId(self.T_SANDMAN)
		local reduction = t.getInsomniaPower(self, t)
		return 20 - reduction
	end,
	getSleepPower = function(self, t)
		local power = self:combatTalentMindDamage(t, 10, 100)
		if self:knowTalent(self.T_SANDMAN) then
			local t = self:getTalentFromId(self.T_SANDMAN)
			power = power * t.getSleepPowerBonus(self, t)
		end
		return math.ceil(power)
	end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y, target = self:getTarget(tg)
		if not x or not y then return nil end
		local _ _, x, y = self:canProject(tg, x, y)
		target = game.level.map(x, y, Map.ACTOR)
		if not target then return nil end

		--Restless?
		local is_waking =0
		if self:knowTalent(self.T_RESTLESS_NIGHT) then
			local t = self:getTalentFromId(self.T_RESTLESS_NIGHT)
			is_waking = t.getDamage(self, t)
		end

		local power = self:mindCrit(t.getSleepPower(self, t))
		if target:canBe("sleep") then
			target:setEffect(target.EFF_SLUMBER, t.getDuration(self, t), {src=self, power=power, waking=is_waking, insomnia=t.getInsomniaPower(self, t), no_ct_effect=true, apply_power=self:combatMindpower()})
			game.level.map:particleEmitter(target.x, target.y, 1, "generic_charge", {rm=180, rM=200, gm=100, gM=120, bm=30, bM=50, am=70, aM=180})
		else
			game.logSeen(self, "%s 잠들지 않았습니다!", (target.kr_display_name or target.name):capitalize():addJosa("가"))
		end
		game:playSoundNear(self, "talents/dispel")
		return true
	end,
	info = function(self, t)
		local duration = t.getDuration(self, t)
		local power = t.getSleepPower(self, t)
		local insomnia = t.getInsomniaPower(self, t)
		return([[대상을 %d 턴 동안 재웁니다. 수면 중에는 행동할 수 없게 되며, %d 피해를 받을 때마다 수면의 지속시간이 1 턴씩 줄어들게 됩니다.
		수면이 끝나면, 대상은 불면증 상태가 되어 잠들었던 시간만큼 %d%% 수면 저항력을 얻게 됩니다. (최대 10 턴)
		피해 한계량은 정신력의 영향을 받아 증가합니다.]]):format(duration, power, insomnia)
	end,
}

newTalent{
	name = "Restless Night",
	kr_display_name = "쉴 수 없는 밤",
	type = {"psionic/slumber", 2},
	points = 5,
	require = psi_wil_req2,
	mode = "passive",
	getDamage = function(self, t) return self:combatTalentMindDamage(t, 5, 40) end,
	doRestlessNight = function (self, target, damage)
		local dam = self:mindCrit(damage)
		target:setEffect(target.EFF_RESTLESS_NIGHT, 5, {power=dam, src=self, no_ct_effect=true})
		game.level.map:particleEmitter(target.x, target.y, 1, "generic_discharge", {rm=180, rM=200, gm=100, gM=120, bm=30, bM=50, am=70, aM=180})
	end,
	info = function(self, t)
		local damage = t.getDamage(self, t)
		return([[잠에서 깨어난 대상이 5 턴 동안 매 턴마다 %0.2f 정신 피해를 받게 됩니다.
		피해량은 정신력의 영향을 받아 증가합니다.]]):format(damDesc(self, DamageType.MIND, (damage)))
	end,
}

newTalent{
	name = "Sandman",
	kr_display_name = "잠귀신",
	type = {"psionic/slumber", 3},
	points = 5,
	require = psi_wil_req3,
	mode = "passive",
	getSleepPowerBonus = function(self, t) return 1 + math.min(1, self:getTalentLevel(t)/10) end,
	getInsomniaPower = function(self, t) return math.min(10, self:getTalentLevelRaw(t) * 2) end,
	info = function(self, t)
		local power_bonus = t.getSleepPowerBonus(self, t) - 1
		local insomnia = t.getInsomniaPower(self, t)
		return([[수면의 지속시간이 줄어드는 피해 한계량이 %d%% 증가하여, 더 많은 피해를 줘도 적의 수면 상태가 풀리지 않게 됩니다.
		그리고, 적이 불면증 상태가 되었을 때 얻는 수면 저항력이 %d%% 감소합니다.
		따로 계산할 필요 없이, 이 효과들이 모두 적용된 수치가 다른 기술들의 설명에 표시됩니다.
		피해 한계량은 정신력의 영향을 받아 증가합니다.]]):format(power_bonus * 100, insomnia)
	end,
}

newTalent{
	name = "Dreamscape",
	kr_display_name = "꿈 속 여행",
	type = {"psionic/slumber", 4},
	points = 5,
	require = psi_wil_req4,
	cooldown = 24,
	psi = 40,
	random_boss_rarity = 10,
	tactical = { DISABLE = function(self, t, target) if target and target.game_ender and target:attr("sleep") then return 4 else return 0 end end},
	direct_hit = true,
	requires_target = true,
	range = 7,
	target = function(self, t) return {type="hit", range=self:getTalentRange(t), talent=t} end,
	getDuration = function(self, t) return 4 + math.ceil(self:getTalentLevel(t) * 2) end,
	getPower = function(self, t) return self:combatTalentMindDamage(t, 10, 100) end,
	on_pre_use = function(self, t, silent) if self:attr("is_psychic_projection") then if not silent then game.logPlayer(self, "이런 무방비한 상태로 꿈 속을 여행하는 것은 좋지 않습니다.") end return false end return true end,
	action = function(self, t)
		if game.zone.is_dream_scape then
			game.logPlayer(self, "이 기술은 꿈 속을 여행하는 동안에는 사용할 수 없습니다.")
			return
		end
		if game.zone.no_planechange then
			game.logPlayer(self, "이 기술은 여기서 사용할 수 없습니다.")
			return
		end

		local tg = {type="hit", range=self:getTalentRange(t), talent=t}
		local tx, ty, target = self:getTarget(tg)
		if not tx or not ty or not target then return nil end
		local _ _, tx, ty = self:canProject(tg, tx, ty)
		if not tx or not ty or not target then return nil end
		target = game.level.map(tx, ty, Map.ACTOR)
		if not tx or not ty or not target then return nil end
		if not (target.player and target.game_ender) and not (self.player and self.game_ender) then return nil end
		if target == self then return end
		if target:attr("negative_status_effect_immune") or target:attr("status_effect_immune") then return nil end

		if not self:canBe("planechange") or target.summon_time or target.summon then
			game.logPlayer(self, "마법이 실패했습니다...")
			return
		end

		if not (target and target:attr("sleep")) then
			game.logPlayer(self, "꿈 속에 들어가기 위해서는, 우선 대상을 잠재워야 합니다.")
			return nil
		end
		if self:reactionToward(target) >= 0 then
			game.logPlayer(self, "아군에게는 사용할 수 없습니다.")
			return nil
		end

		game:onTickEnd(function()
			if self:attr("dead") then return end
			local oldzone = game.zone
			local oldlevel = game.level

			-- Clean up thought-forms
			cancelThoughtForms(self)

			-- Remove them before making the new elvel, this way party memebrs are not removed from the old
			if oldlevel:hasEntity(self) then oldlevel:removeEntity(self) end
			if oldlevel:hasEntity(target) then oldlevel:removeEntity(target) end

			oldlevel.no_remove_entities = true
			local zone = mod.class.Zone.new("dreamscape-talent")
			local level = zone:getLevel(game, 1, 0)
			oldlevel.no_remove_entities = nil

			level:addEntity(self)
			level:addEntity(target)

			level.source_zone = oldzone
			level.source_level = oldlevel
			game.zone = zone
			game.level = level
			game.zone_name_s = nil

			local x1, y1 = util.findFreeGrid(4, 6, 20, true, {[Map.ACTOR]=true})
			if x1 then
				self:move(x1, y1, true)
				game.level.map:particleEmitter(x1, y1, 1, "generic_teleport", {rm=0, rM=0, gm=180, gM=255, bm=180, bM=255, am=35, aM=90})
			end
			local x2, y2 = util.findFreeGrid(8, 6, 20, true, {[Map.ACTOR]=true})
			if x2 then
				target:move(x2, y2, true)
			end

			target:setTarget(self)
			target.dream_plane_trapper = self
			target.dream_plane_on_die = target.on_die
			target.on_die = function(self, ...)
				self.dream_plane_trapper:removeEffect(self.EFF_DREAMSCAPE)
				local args = {...}
				game:onTickEnd(function()
					if self.dream_plane_on_die then self:dream_plane_on_die(unpack(args)) end
					self.on_die, self.dream_plane_on_die = self.dream_plane_on_die, nil
				end)
			end

			self.dream_plane_on_die = self.on_die
			self.on_die = function(self, ...)
				self:removeEffect(self.EFF_DREAMSCAPE)
				local args = {...}
				game:onTickEnd(function()
					if self.dream_plane_on_die then self:dream_plane_on_die(unpack(args)) end
					self.on_die, self.dream_plane_on_die = self.dream_plane_on_die, nil
				--	if not game.party:hasMember(self) then world:gainAchievement("FEARSCAPE", game:getPlayer(true)) end
				end)
			end

			game.logPlayer(game.player, "#LIGHT_BLUE#꿈 속에서 튕겨져 나왔습니다!")

			if game.party:hasMember(target) then game.party:learnLore("dreamscape-entry") end
		end)

		local power = self:mindCrit(t.getPower(self, t))
		self:setEffect(self.EFF_DREAMSCAPE, t.getDuration(self, t), {target=target, power=power, projections_killed=0, x=self.x, y=self.y, tx=target.x, ty=target.y})
		game:playSoundNear(self, "talents/teleport")
		return true
	end,
	info = function(self, t)
		local duration = t.getDuration(self, t)
		local power = t.getPower(self, t)
		return([[%d 턴 동안 수면 중인 대상의 꿈 속으로 들어갑니다. 꿈 속에서는 무적 상태의 잠든 대상을 만날 수 있으며, 대상이 자신의 정신을 보호하기 위해 만든 투영체가 계속 생성됩니다.
		대상이 자각몽 상태가 아닌 한, 투영체는 기본적으로 본체보다 50%% 더 적은 피해만을 입힐 수 있으며 반대로 자신은 투영체에게 %d%% 더 강력한 공격을 할 수 있습니다.
		꿈 속 여행이 끝나면 파괴된 투영체 1 개마다 대상의 생명력이 최대 생명력의 10%% 만큼 감소하며, 1 턴 동안 정신 잠금에 걸립니다.
		피해량 증가는 정신력의 영향을 받아 증가합니다.]]):format(duration, power)
	end,
}
