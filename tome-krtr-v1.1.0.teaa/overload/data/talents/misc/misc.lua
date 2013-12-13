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

-- race & classes
newTalentType{ type="base/class", name = "class", hide = true, description = "각 직업들의 기본적인 기술들입니다." }
newTalentType{ type="base/race", name = "race", hide = true, description = "다양한 종족적 특성들입니다." }
newTalentType{ is_nature = true, type="inscriptions/infusions", name = "infusions", hide = true, description = "주입은 자연적으로 얻을 수 있는 특성이 아니며, 기술을 사용하기 위해서는 그 수단을 찾거나 다른 사람들에게 배워야합니다." }
newTalentType{ is_spell=true, no_silence=true, type="inscriptions/runes", name = "runes", hide = true, description = "룬은 자연적으로 얻을 수 있는 특성이 아니며, 기술을 사용하기 위해서는 그 수단을 찾거나 다른 사람들에게 배워야합니다." }
newTalentType{ is_spell=true, no_silence=true, type="inscriptions/taints", name = "taints", hide = true, description = "감염은 자연적으로 얻을 수 있는 특성이 아니며, 기술을 사용하기 위해서는 그 수단을 찾거나 다른 사람들에게 배워야합니다." }

-- Load other misc things
load("/data/talents/misc/objects.lua")
load("/data/talents/misc/inscriptions.lua")
load("/data/talents/misc/npcs.lua")
load("/data/talents/misc/horrors.lua")
load("/data/talents/misc/races.lua")
load("/data/talents/misc/tutorial.lua")

-- Default melee attack
newTalent{
	name = "Attack",
	kr_name = "공격",
	type = {"base/class", 1},
	no_energy = "fake",
	hide = "always",
	innate = true,
	points = 1,
	range = 1,
	message = false,
	no_break_stealth = true, -- stealth is broken in attackTarget
	requires_target = true,
	target = {type="hit", range=1},
	tactical = { ATTACK = { PHYSICAL = 1 } },
	no_unlearn_last = true,
	ignored_by_hotkeyautotalents = true,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
		if not x then return end
		local _ _, x, y = self:canProject(tg, x, y)
		if not x then return end
		local target = game.level.map(x, y, engine.Map.ACTOR)
		if not target then return end

		local double_strike = false
		if self:knowTalent(self.T_DOUBLE_STRIKE) and self:isTalentActive(self.T_STRIKING_STANCE) then
			local t = self:getTalentFromId(self.T_DOUBLE_STRIKE)
			if not self:isTalentCoolingDown(t) then
				double_strike = true
			end
		end
		-- if double strike isn't on cooldown, throw a double strike; quality of life hack
		if double_strike then
			self:forceUseTalent(self.T_DOUBLE_STRIKE, {force_target=target}) -- uses energy because attack is 'fake'
		else
			self:attackTarget(target)
		end

		if config.settings.tome.smooth_move > 0 and config.settings.tome.twitch_move then
			self:setMoveAnim(self.x, self.y, config.settings.tome.smooth_move, blur, util.getDir(x, y, self.x, self.y), 0.2)
		end

		return true
	end,
	info = function(self, t)
		return ([[모든 것을 파.괴.한.다!]])
	end,
}

--mindslayer resource
newTalent{
	name = "Psi Pool",
	type = {"base/class", 1},
	info = "Allows you to have an energy pool. Energy is used to perform psionic manipulations.",
	mode = "passive",
	hide = "always",
	no_unlearn_last = true,
}

newTalent{
	name = "Feedback Pool",
	type = {"base/class", 1},
	info = "Allows you to have a Feedback pool. Feedback is used to power feedback and discharge talents.",
	mode = "passive",
	hide = "always",
	-- Adjust feedback ratio with character level to reflect the degree of "pain" received
	-- Called in function _M:onTakeHit in mod.class.Actor.lua
	getFeedbackRatio = function(self, t, raw)
		local ratio = self:combatLimit(self.level, 0, 0.5, 1, 0.2, 50)  -- Limit >0% damage taken, 50% @ level 1, 20% @ level 50
		local mult = 1 + (not raw and self:callTalent(self.T_AMPLIFICATION, "getFeedbackGain") or 0)
		return ratio*mult
	end,
	no_unlearn_last = true,
	on_learn = function(self, t)
		if self:getMaxFeedback() <= 0 then
--			self:incMaxFeedback(100)
			self:incMaxFeedback(100 - self:getMaxFeedback())
		end
		return true
	end,
}

newTalent{
	name = "Mana Pool",
	type = {"base/class", 1},
	info = "Allows you to have a mana pool. Mana is used to cast all spells.",
	mode = "passive",
	hide = "always",
	no_unlearn_last = true,
}
newTalent{
	name = "Soul Pool",
	type = {"base/class", 1},
	info = "Allows you to have a mana soul. Souls are used to cast necrotic spells.",
	mode = "passive",
	hide = "always",
	no_unlearn_last = true,
}
newTalent{
	name = "Vim Pool",
	type = {"base/class", 1},
	info = "Allows you to have a vim pool. Vim is used by corruptions.",
	mode = "passive",
	hide = "always",
	no_unlearn_last = true,
}
newTalent{
	name = "Stamina Pool",
	type = {"base/class", 1},
	info = "Allows you to have a stamina pool. Stamina is used to activate special combat attacks.",
	mode = "passive",
	hide = "always",
	no_unlearn_last = true,
}
newTalent{
	name = "Equilibrium Pool",
	type = {"base/class", 1},
	info = "Allows you to have an equilibrium pool. Equilibrium is used to measure your balance with nature and the use of wild gifts.",
	mode = "passive",
	hide = "always",
	no_unlearn_last = true,
}
newTalent{
	name = "Positive Pool",
	type = {"base/class", 1},
	info = "Allows you to have a positive energy pool.",
	mode = "passive",
	hide = "always",
	no_unlearn_last = true,
}
newTalent{
	name = "Negative Pool",
	type = {"base/class", 1},
	info = "Allows you to have a negative energy pool.",
	mode = "passive",
	hide = "always",
	no_unlearn_last = true,
}
newTalent{
	name = "Hate Pool",
	type = {"base/class", 1},
	info = "Allows you to have a hate pool.",
	mode = "passive",
	hide = "always",
	no_unlearn_last = true,
	updateRegen = function(self, t)
		-- hate loss speeds up as hate increases
		local hate = self:getHate()
		local hateChange
		if hate < self.baseline_hate then
			hateChange = 0
		else
			hateChange = -0.7 * math.pow(hate / 100, 1.5)
		end
		if hateChange < 0 then
			hateChange = math.min(0, math.max(hateChange, self.baseline_hate - hate))
		end

		self.hate_regen = self.hate_regen - (self.hate_decay or 0) + hateChange
		self.hate_decay = hateChange
	end,
	updateBaseline = function(self, t)
		self.baseline_hate = math.max(10, self:getHate() * 0.5)
	end,
	on_kill = function(self, t, target)
		local hateGain = self.hate_per_kill
		local hateMessage

		if target.level - 2 > self.level then
			-- level bonus
			hateGain = hateGain + math.ceil(self:combatTalentScale(target.level - 2 - self.level, 2, 10, "log", 0, 1))
			hateMessage = "#F53CBE#경험 많은 적의 생명을 취했습니다!"
		end

		if target.rank >= 4 then
			-- boss bonus
			hateGain = hateGain * 4
			hateMessage = "#F53CBE#그 어떤 강력한 적이라도, 나의 증오를 당해낼 수 없으리라!"
		elseif target.rank >= 3 then
			-- elite bonus
			hateGain = hateGain * 2
			hateMessage = "#F53CBE#정예 등급인 적의 생명을 취했습니다!"
		end
		hateGain = math.min(hateGain, 100)

		self.hate = math.min(self.max_hate, self.hate + hateGain)
		if hateMessage then
			game.logPlayer(self, hateMessage.." (+%d 증오)", hateGain - self.hate_per_kill)
		end
	end,
}

newTalent{
	name = "Paradox Pool",
	type = {"base/class", 1},
	info = "Allows you to have a paradox pool.",
	mode = "passive",
	hide = "always",
	no_unlearn_last = true,
}

-- Madness difficulty
newTalent{ --@@ 한글화 필요 : kr_name 추가, info 번역
	name = "Hunted!", short_name = "HUNTED_PLAYER",
	type = {"base/class", 1},
	mode = "passive",
	no_unlearn_last = true,
	callbackOnActBase = function(self, t)
		if not rng.percent(1 + self.level / 7) then return end

		local rad = math.ceil(10 + self.level / 5)
		for i = self.x - rad, self.x + rad do for j = self.y - rad, self.y + rad do if game.level.map:isBound(i, j) then
			local actor = game.level.map(i, j, game.level.map.ACTOR)
			if actor and self:reactionToward(actor) < 0 and not actor:attr("hunted_difficulty_immune") then
				actor:setEffect(actor.EFF_HUNTER_PLAYER, 6, {src=self})
			end
		end end end
	end,
	info = function(self, t) return ([[You are hunted!.
		There is %d%% chances each turn that all foes in a %d radius get a glimpse of your position for 6 turns.]]):
		format(1 + self.level / 7, 10 + self.level / 5)
	end,
}

-- Mages class talent, teleport to angolwen
newTalent{
	short_name = "TELEPORT_ANGOLWEN",
	name = "Teleport: Angolwen",
	kr_name = "순간이동 : 앙골웬",
	type = {"base/class", 1},
	cooldown = 400,
	no_npc_use = true,
	no_unlearn_last = true,
	no_silence=true, is_spell=true,
	action = function(self, t)
		if not self:canBe("worldport") or self:attr("never_move") then
			game.logPlayer(self, "주문이 헛나갔습니다...")
			return
		end

		local seen = false
		-- Check for visible monsters, only see LOS actors, so telepathy wont prevent it
		core.fov.calc_circle(self.x, self.y, game.level.map.w, game.level.map.h, 20, function(_, x, y) return game.level.map:opaque(x, y) end, function(_, x, y)
			local actor = game.level.map(x, y, game.level.map.ACTOR)
			if actor and actor ~= self then seen = true end
		end, nil)
		if seen then
			game.log("누군가 당신을 보고 있습니다. 섣부른 순간이동으로 앙골웬 마을의 위치를 노출시킬 수는 없습니다.")
			return
		end

		self:setEffect(self.EFF_TELEPORT_ANGOLWEN, 40, {})
		return true
	end,
	info = [[모든 마법사들의 성지, 앙골웬 마을로 순간이동합니다.
	앙골웬에서 마법을 배운 모든 마법사들은 반드시 이 마법을 배우게 됩니다.
	누구에게도 이 순간이동 마법을 알려주어서는 안되며, 아무도 없는 곳에서만 사용해야 합니다.
	마법 발동을 위해서는 시간이 약간 필요합니다.]]
}

-- Chronomancer class talent, teleport to Point Zero
newTalent{
	short_name = "TELEPORT_POINT_ZERO",
	name = "Timeport: Point Zero",
	kr_name = "시공간이동 : 영점",
	type = {"base/class", 1},
	cooldown = 400,
	no_npc_use = true,
	no_unlearn_last = true,
	no_silence=true, is_spell=true,
	action = function(self, t)
		if not self:canBe("worldport") or self:attr("never_move") then
			game.logPlayer(self, "주문이 헛나갔습니다...")
			return
		end

		local seen = false
		-- Check for visible monsters, only see LOS actors, so telepathy wont prevent it
		core.fov.calc_circle(self.x, self.y, game.level.map.w, game.level.map.h, 20, function(_, x, y) return game.level.map:opaque(x, y) end, function(_, x, y)
			local actor = game.level.map(x, y, game.level.map.ACTOR)
			if actor and actor ~= self then seen = true end
		end, nil)
		if seen then
			game.log("누군가 당신을 보고 있습니다. 섣부른 시공간이동으로 영점의 위치를 노출시킬 수는 없습니다.")
			return
		end

		self:setEffect(self.EFF_TELEPORT_POINT_ZERO, 40, {})
		self:attr("temporal_touched", 1)
		self:attr("time_travel_times", 1)
		return true
	end,
	info = [[모든 시공 제어사들의 성지, '영점' 으로 시공간이동합니다.
	영점에서 온 모든 시공 제어사들은 언제든지 이곳으로 돌아갈 수 있습니다.
	단 누구에게도 이 순간이동 마법을 알려주어서는 안되며, 아무도 없는 곳에서만 사용해야 합니다.
	마법 발동을 위해서는 시간이 약간 필요합니다.]]
}

newTalent{
	name = "Relentless Pursuit",
	kr_name = "끈질긴 추구",
	type = {"base/class", 1},
	points = 5,
	no_energy = true,
	cooldown = function(self, t) return 55 - self:getTalentLevel(t) * 5 end,
	tactical = { CURE = function(self, t, target)
		local nb = 0
		for eff_id, p in pairs(self.tmp) do
			local e = self.tempeffect_def[eff_id]
			if e.status == "detrimental" then nb = nb + 1 end
		end
		return nb
	end},
	action = function(self, t)
		local target = self
		local todel = {}

		local save_for_effects = {
			magical = "combatSpellResist",
			mental = "combatMentalResist",
			physical = "combatPhysicalResist",
		}
		for eff_id, p in pairs(target.tmp) do
			local e = target.tempeffect_def[eff_id]
			if e.status == "detrimental" and save_for_effects[e.type] then
				local save = self[save_for_effects[e.type]](self, true)
				local decrease = math.floor(save/5)
				print("About to reduce duration of... %s. Will use %s. Reducing duration by %d", e.desc, save_for_effects[e.type])
				p.dur = p.dur - decrease
				if p.dur <= 0 then todel[#todel+1] = eff_id end
			end
		end
		while #todel > 0 do
			target:removeEffect(table.remove(todel))
		end
		game:playSoundNear(self, "talents/spell_generic")
		return true
	end,
	info = function(self, t)
		local physical_reduction = math.floor(self:combatPhysicalResist(true)/5)
		local spell_reduction = math.floor(self:combatSpellResist(true)/5)
		local mental_reduction = math.floor(self:combatMentalResist(true)/5)
		return ([['주인'도, 타락한 레크놀의 오크들도, 레크놀의 차원 관문 저 너머의 알 수 없는 존재들이라 해도, 당신이 흡수의 지팡이를 뒤쫒는 것을 방해하지 못할 것입니다. 
		바로 이 세계의 아이들이, 대를 이어 전해지는 노래를 통해 당신이 끈질기게 추구했던 것들을 듣고 기억할 것입니다.
		기술을 발동하면, 모든 나쁜 상태효과의 지속시간이 해당 상태효과를 방어하는 내성 수치에 따라 줄어듭니다.
		물리적 상태효과의 지속시간은 %d 턴, 마법적 상태효과의 지속시간은 %d 턴, 정신적 상태효과의 지속시간은 %d 턴 줄어듭니다.]]):
		format(physical_reduction, spell_reduction, mental_reduction)
	end,
}

newTalent{
	short_name = "SHERTUL_FORTRESS_GETOUT",
	name = "Teleport to the ground",
	kr_name = "지표면으로 순간이동",
	type = {"base/race", 1},
	no_npc_use = true,
	no_unlearn_last = true,
	on_pre_use = function(self, t) return not game.zone.stellar_map end,
	action = function(self, t)
		if game.level.map:checkAllEntities(self.x, self.y, "block_move") then game.log("여기서는 순간이동할 수 없습니다.") return true end
		game:onTickEnd(function()
			game.party:removeMember(self, true)
			game.party:findSuitablePlayer()
			game.player.dont_act = nil
			game.player:move(self.x, self.y, true)
		end)
		return true
	end,
	info = [[특수한 단거리 순간이동 마법으로, 지표면으로 돌아갈 수 있습니다.
	Requires being in flight above the ground of a planet.]] --@@ 한글화 필요
}

newTalent{
	short_name = "SHERTUL_FORTRESS_BEAM",
	name = "Fire a blast of energy",
	kr_name = "에너지탄 발사",
	type = {"base/race", 1},
	fortress_energy = 10,
	no_npc_use = true,
	no_unlearn_last = true,
	on_pre_use = function(self, t) return not game.zone.stellar_map end,
	action = function(self, t)
		for i = 1, 5 do
			local rad = rng.float(0.5, 1)
			local bx = rng.range(-12, 12)
			local by = rng.range(-12, 12)

			if core.shader.active(4) then game.level.map:particleEmitter(self.x, self.y, 1, "shader_ring", {radius=rad * 2, life=12, x=bx, y=by}, {type="sparks", zoom=1, time_factor=400, hide_center=0, color1={0.6, 0.3, 0.8, 1}, color2={0.8, 0, 0.8, 1}})
			else game.level.map:particleEmitter(self.x, self.y, 1, "generic_ball", {rm=150, rM=180, gm=20, gM=60, bm=180, bM=200, am=80, aM=150, radius=rad, x=bx, y=by})
			end
		end

		local target = game.level.map(self.x, self.y, Map.ACTOR)
		if target and target.takePowerHit then
			target:takePowerHit(20, self)
		end

		game:playSoundNear(self, "talents/arcane")
		return true
	end,
	info = [[요새 에너지를 10 사용하여, 지면에 강력한 에너지탄을 발사합니다. 에너지탄에 휩쓸린 모든 적들은 큰 피해를 입습니다.
	Requires being in flight above the ground of a planet.]] --@@ 한글화 필요
}

newTalent{ --@@ 한글화 필요 : kr_name 추가, info 번역 
	short_name = "SHERTUL_FORTRESS_ORBIT",
	name = "High Planetary Orbit",
	type = {"base/race", 1},
	fortress_energy = 100,
	no_npc_use = true,
	no_unlearn_last = true,
	no_energy = true,
	on_pre_use = function(self, t) return not game.zone.stellar_map end,
	action = function(self, t)
		game:changeLevelReal(1, "stellar-system-shandral", {})
		game:playSoundNear(self, "talents/arcane")

		return true
	end,
	info = [[Activate the powerful flight engines of the Fortress, propelling it fast into high planetary orbit.
	Requires being in flight above the ground of a planet.]]
}
