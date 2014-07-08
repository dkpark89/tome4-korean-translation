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

-- Baseline blind because the class has a lot of trouble with CC early game and rushing TL4 isn't reasonable
newTalent{
	name = "Sun Ray", short_name = "SUN_BEAM",
	kr_name = "태양 광선",
	type = {"celestial/sun", 1},
	require = divi_req1,
	random_ego = "attack",
	points = 5,
	cooldown = 9,
	positive = -16,
	range = 7,
	tactical = { ATTACK = {LIGHT = 2} },
	no_energy = function(self, t) return self:attr("amplify_sun_beam") and true or false end,
	direct_hit = true,
	reflectable = true,
	requires_target = true,
	getDamage = function(self, t)
		local mult = 1
		if self:attr("amplify_sun_beam") then mult = 1 + self:attr("amplify_sun_beam") / 100 end
		return self:combatTalentSpellDamage(t, 20, 220) * mult
	end,
	getDuration = function(self, t) return math.floor(self:combatTalentScale(t, 2, 4)) end,
	action = function(self, t)
		local tg = {type="hit", range=self:getTalentRange(t), talent=t}
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		self:project(tg, x, y, DamageType.LIGHT, self:spellCrit(t.getDamage(self, t)), {type="light"})

		if self:getTalentLevel(t) >= 3 then
			local _ _, x, y = self:canProject(tg, x, y)
			self:project({type="ball", x=x, y=y, radius=2, selffire=false}, x, y, DamageType.BLIND, t.getDuration(self, t), {type="light"})
		end

		-- Delay removal of the effect so its still there when no_energy checks
		game:onTickEnd(function()
			self:removeEffect(self.EFF_SUN_VENGEANCE)
		end)

		game:playSoundNear(self, "talents/flame")
		return true
	end,
	info = function(self, t)
		local damage = t.getDamage(self, t)
		return ([[태양으로부터 빛의 힘을 끌어와, 대상에게 %0.1f 빛 피해를 줍니다.
		기술 레벨이 3 이상일 경우, 강렬한 빛이 대상과 주변 2 칸 반경의 모두를 %d 턴 동안 실명시키게 됩니다.
		피해량은 주문력의 영향을 받아 증가합니다.]]):
		format(damDesc(self, DamageType.LIGHT, damage), t.getDuration(self, t))
	end,
}

newTalent{
	name = "Path of the Sun",
	kr_name = "태양의 길",
	type = {"celestial/sun", 2},
	require = divi_req2,
	points = 5,
	cooldown = 15,
	positive = -20,
	tactical = { ATTACKAREA = {LIGHT = 2}, CLOSEIN = 2 },
	range = function(self, t) return math.floor(self:combatTalentLimit(t, 10, 4, 9)) end,
	direct_hit = true,
	target = function(self, t)
		return {type="beam", range=self:getTalentRange(t), talent=t}
	end,
	getDamage = function(self, t) return self:combatTalentSpellDamage(t, 10, 310) end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end

		local dam = self:spellCrit(t.getDamage(self, t))
		local grids = self:project(tg, x, y, function() end)
		grids[self.x] = grids[self.x] or {}
		grids[self.x][self.y] = true
		local _ _, x, y = self:canProject(tg, x, y)
		game.level.map:addEffect(self, self.x, self.y, 5, DamageType.SUN_PATH, dam / 5, 0, 5, grids, MapEffect.new{color_br=255, color_bg=249, color_bb=60, alpha=100, effect_shader="shader_images/sun_effect.png"}, nil, true)
		game.level.map:addEffect(self, self.x, self.y, 5, DamageType.COSMETIC, 0      , 0, 5, grids, {type="sun_path", args={tx=x-self.x, ty=y-self.y}, only_one=true}, nil, true)

		self:setEffect(self.EFF_PATH_OF_THE_SUN, 5, {})

		game:playSoundNear(self, "talents/fireflash")
		return true
	end,
	info = function(self, t)
		local radius = self:getTalentRadius(t)
		local damage = t.getDamage(self, t)
		return ([[태양의 길이 시전자를 중심으로 5 턴 동안 생겨납니다. 태양의 길에 서있는 모든 적들은 매 턴마다 %0.1f 빛 피해를 받게 됩니다.
		또한 시전자는 태양의 길에 서있는 한, 이동할 때 시간이 소모되지 않고 함정을 발동시키지 않게 됩니다.
		피해량은 주문력의 영향을 받아 증가합니다.]]):format(damDesc(self, DamageType.LIGHT, damage / 5), radius)
	end,
}

-- Can someone put a really obvious visual on this?
newTalent{
	name = "Sun's Vengeance", short_name = "SUN_VENGEANCE",
	kr_name = "태양의 복수",
	type = {"celestial/sun",3},
	require = divi_req3,
	mode = "passive",
	points = 5,
	getCrit = function(self, t) return self:combatTalentScale(t, 2, 10, 0.75) end,
	getProcChance = function(self, t) return self:combatTalentLimit(t, 100, 30, 75) end,
	passives = function(self, t, p)
		self:talentTemporaryValue(p, "combat_spellcrit", t.getCrit(self, t))
		self:talentTemporaryValue(p, "combat_physcrit", t.getCrit(self, t))
	end,
	callbackOnCrit = function(self, t, kind, dam, chance)
		if kind ~= "spell" and kind ~= "physical" then return end
		if not rng.percent(t.getProcChance(self, t)) then return end
		if self.turn_procs.sun_vengeance then return end --Note: this will trigger a lot since it get's multiple chances a turn
		self.turn_procs.sun_vengeance = true

		if self:isTalentCoolingDown(self.T_SUN_BEAM) then
			self.talents_cd[self.T_SUN_BEAM] = self.talents_cd[self.T_SUN_BEAM] - 1
			if self.talents_cd[self.T_SUN_BEAM] <= 0 then self.talents_cd[self.T_SUN_BEAM] = nil end
		else
			self:setEffect(self.EFF_SUN_VENGEANCE, 2, {})
		end
	end,
	info = function(self, t)
		local crit = t.getCrit(self, t)
		local chance = t.getProcChance(self, t)
		return ([[태양의 타오르는 분노를 몸에 주입시켜, 물리 치명타율과 주문 치명타율을 %d%% 상승시킵니다.
		그리고 물리 혹은 주문 치명타를 발생시킬 때마다, %d%% 확률로 태양의 복수 효과가 2 턴 동안 발동됩니다.
		태양의 복수 효과가 지속되는 동안에는, 태양 광선 기술을 사용할 때 시간이 소모되지 않으며 25%% 더 많은 피해를 입힐 수 있게 됩니다.
		만약 태양 광선 기술이 재사용 대기 중일 경우, 기존 효과 대신 태양 광선의 재사용 대기 시간이 1 턴 줄어들게 됩니다.
		이 효과는 한 턴에 1 번까지만 나타납니다.]]):
		format(crit, chance)
	end,
}

-- Core class defense to be compared with Bone Shield, Aegis, Indiscernable Anatomy, etc
-- Moderate offensive scaler
-- The CD reduction effects more abilities on the class than it doesn't
-- Banned from NPCs due to sheer scaling insanity
newTalent{
	name = "Suncloak",
	kr_name = "태양 망토",
	type = {"celestial/sun", 4},
	require = divi_req4,
	points = 5,
	cooldown = 15, -- 20 was accounting for it buffing itself
	fixed_cooldown = true,
	positive = -15,
	tactical = { BUFF = 2 },
	direct_hit = true,
	no_npc_use = true,
	requires_target = true,
	range = 10,
	getCap = function(self, t) return self:combatTalentLimit(t, 30, 90, 70) end,
	getHaste = function(self, t) return math.min(0.5, self:combatTalentSpellDamage(t, 0.1, 0.4)) end,
	getCD = function(self, t) return self:combatLimit(self:combatTalentSpellDamage(t, 5, 450), 0.5, .03, 32, .35, 350) end, -- Limit < 50% cooldown reduction
	action = function(self, t)
		self:setEffect(self.EFF_SUNCLOAK, 6, {cap=t.getCap(self, t), haste=t.getHaste(self, t), cd=t.getCD(self, t)})
		game:playSoundNear(self, "talents/flame")
		return true
	end,
	info = function(self, t)
		return ([[스스로를 햇빛 망토로 둘러싸, 6 턴 동안 마력을 강화시키고 몸을 보호합니다.
		태양 망토 효과가 유지되는 동안, 주문 시전 속도는 %d%% 증가하며 주문의 재사용 대기 시간은 %d%% 감소합니다. 그리고 한번의 타격에 최대 생명력의 %d%% 이상은 절대 피해를 받지 않게 됩니다.
		기술의 효과는 주문력의 영향을 받아 증가합니다.]]):
		format(t.getHaste(self, t)*100, t.getCD(self, t)*100, t.getCap(self, t))
   end,
}
