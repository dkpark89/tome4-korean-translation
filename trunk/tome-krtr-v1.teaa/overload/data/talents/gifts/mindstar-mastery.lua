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

function get_mindstar_power_mult(self, div)
	local main, off = self:hasPsiblades(true, true)
	if not main or not off then return 1 end

	local mult = 1 + (main.combat.dam + off.combat.dam) / (div or 40)
	return mult
end

newTalent{
	name = "Psiblades",
	kr_display_name = "염동 칼날",
	type = {"wild-gift/mindstar-mastery", 1},
	require = gifts_req1,
	points = 5,
	mode = "sustained",
	sustain_equilibrium = 18,
	cooldown = 6,
	tactical = { BUFF = 4 },
	getStatmult = function(self,t,level) return 1.076 + 0.324*(level or self:getTalentLevel(t))^.5 end, --I5
	getAPRmult = function(self,t,level) return 0.65 + 0.51*(level or self:getTalentLevel(t))^.5 end, -- I5
	getDamage = function(self, t) return self:getTalentLevel(t) * 10 end,
	getPercentInc = function(self, t) return math.sqrt(self:getTalentLevel(t) / 5) / 2 end,
	activate = function(self, t)
		local r = {
			tmpid = self:addTemporaryValue("psiblades_active", self:getTalentLevel(t)),
		}

		for i, o in ipairs(self:getInven("MAINHAND") or {}) do self:checkMindstar(o) end
		for i, o in ipairs(self:getInven("OFFHAND") or {}) do self:checkMindstar(o) end
		self:updateModdableTile()

		return r
	end,
	deactivate = function(self, t, p)
		self:removeTemporaryValue("psiblades_active", p.tmpid)

		for i, o in ipairs(self:getInven("MAINHAND") or {}) do self:checkMindstar(o) end
		for i, o in ipairs(self:getInven("OFFHAND") or {}) do self:checkMindstar(o) end
		self:updateModdableTile()

		return true
	end,
	info = function(self, t)
		local damage = t.getDamage(self, t)
		local inc = t.getPercentInc(self, t)
		return ([[마석에 정신력을 집중해, 염동 칼날을 만들어냅니다.
		생성된 염동 칼날은 일반적으로 마석을 들었을 때보다 적용 능력치가 %0.2f, 방어도 관통력이 %0.2f 만큼 더 곱해집니다.
		또한 물리력이 %d 만큼, 무기 피해량이 %d%% 만큼 상승합니다.]]):
		format(t.getStatmult(self, t), t.getAPRmult(self, t), damage, 100 * inc) --I5
	end,
}

newTalent{
	name = "Thorn Grab",
	kr_display_name = "가시덩굴 붙잡기",
	type = {"wild-gift/mindstar-mastery", 2},
	require = gifts_req2,
	points = 5,
	equilibrium = 7,
	cooldown = 15,
	no_energy = true,
	range = 1,
	tactical = { ATTACK = 2, DISABLE = 2 },
	on_pre_use = function(self, t, silent) if not self:hasPsiblades(true, false) then if not silent then game.logPlayer(self, "이 기술을 사용하려면 염동 칼날을 주무기로 쓰고 있어야 합니다.") end return false end return true end,
	action = function(self, t)
		local tg = {type="hit", range=self:getTalentRange(t)}
		local x, y, target = self:getTarget(tg)
		if not x or not y or not target then return nil end
		if core.fov.distance(self.x, self.y, x, y) > 1 then return nil end

		target:setEffect(target.EFF_THORN_GRAB, 10, {src=self, speed=1 - 1 / (1 + (20 + self:getTalentLevel(t) * 2) / 100), dam=self:mindCrit(self:combatTalentMindDamage(t, 15, 250) / 10 * get_mindstar_power_mult(self))})

		return true
	end,
	info = function(self, t)
		return ([[염동 칼날을 대상과 접촉시켜, 자연의 힘을 흘려보냅니다. 이를 통해 만들어진 가시덩굴이 대상을 휘감아, 대상을 10 턴 동안 %d%% 만큼 감속시키고 매 턴마다 %0.2f 자연 피해를 줍니다.
		피해량은 정신력와 마석의 위력에 따라 증가합니다. (양손에 마석을 들고 있어야 하며, 배율은 %2.f 입니다)]]):
		format(20 + self:getTalentLevel(t) * 2, damDesc(self, DamageType.NATURE, self:combatTalentMindDamage(t, 15, 250) / 10 * get_mindstar_power_mult(self)), get_mindstar_power_mult(self))
	end,
}

newTalent{
	name = "Leaves Tide",
	kr_display_name = "잎사귀 물결",
	type = {"wild-gift/mindstar-mastery", 3},
	require = gifts_req3,
	points = 5,
	equilibrium = 20,
	cooldown = 25,
	tactical = { ATTACK = 2, DEFEND=3 },
	getDamage = function(self, t) return 5 + self:combatTalentMindDamage(t, 5, 35) * get_mindstar_power_mult(self) end,
	getChance = function(self, t) return util.bound(10 + self:combatTalentMindDamage(t, 5, 35), 10, 40) * get_mindstar_power_mult(self, 90) end,
	on_pre_use = function(self, t, silent) if not self:hasPsiblades(true, true) then if not silent then game.logPlayer(self, "이 기술을 사용하려면 두 손에 각각 염동 칼날을 잡고 있어야 합니다.") end return false end return true end,
	action = function(self, t)
		-- Add a lasting map effect
		game.level.map:addEffect(self,
			self.x, self.y, 7,
			DamageType.LEAVES, {dam=self:mindCrit(t.getDamage(self, t)), chance=t.getChance(self, t)},
			3,
			5, nil,
			{type="leavestide", only_one=true},
			function(e)
				e.x = e.src.x
				e.y = e.src.y
				return true
			end,
			true
		)
		game:playSoundNear(self, "talents/icestorm")
		return true
	end,
	info = function(self, t)
		local dam = t.getDamage(self, t)
		local c = t.getChance(self, t)
		return ([[염동 칼날로 지면을 후려쳐, 결정화된 잎사귀들을 만들어냅니다. 이 잎사귀들은 7 턴 동안 주변 3 칸 반경에서 회전합니다.
		잎사귀에 스친 적들은 매 턴마다 %0.2f 출혈 피해를 입으며, 이 피해는 중첩됩니다.
		동료들에게는 잎사귀가 보호막 역할을 해, %d%% 확률로 피해를 무시할 수 있게 됩니다.
		피해량과 회피율은 정신력 수치와 마석의 위력에 따라 증가합니다. (양손에 마석을 들고 있어야 하며, 배율은 %2.f 입니다)]]):
		format(dam, c, get_mindstar_power_mult(self))
	end,
}

newTalent{
	name = "Nature's Equilibrium",
	kr_display_name = "자연의 평정",
	type = {"wild-gift/mindstar-mastery", 4},
	require = gifts_req4,
	points = 5,
	equilibrium = 5,
	cooldown = 15,
	range = 1,
	tactical = { ATTACK = 1, HEAL = 1, EQUILIBRIUM = 1 },
	direct_hit = true,
	requires_target = true,
	on_pre_use = function(self, t, silent) if not self:hasPsiblades(true, true) then if not silent then game.logPlayer(self, "이 기술을 사용하려면 두 손에 각각 염동 칼날을 잡고 있어야 합니다.") end return false end return true end,
	getMaxDamage = function(self, t) return 50 + self:combatTalentMindDamage(t, 5, 250) * get_mindstar_power_mult(self) end,
	action = function(self, t)
		local main, off = self:hasPsiblades(true, true)

		local tg = {type="hit", range=self:getTalentRange(t)}
		local x, y, target = self:getTarget(tg)
		if not x or not y or not target then return nil end
		if core.fov.distance(self.x, self.y, x, y) > 1 then return nil end

		local ol = target.life
		local speed, hit = self:attackTargetWith(target, main.combat, nil, self:combatTalentWeaponDamage(t, 2.5, 4))
		local dam = util.bound(ol - target.life, 0, t.getMaxDamage(self, t))

		while hit do -- breakable if
			local tg = {default_target=self, type="hit", nowarning=true, range=1, first_target="friend"}
			local x, y, target = self:getTarget(tg)
			if not x or not y or not target then break end
			if core.fov.distance(self.x, self.y, x, y) > 1 then break end

			target:attr("allow_on_heal", 1)
			target:heal(dam)
			target:attr("allow_on_heal", -1)
			target:incEquilibrium(-dam / 10)
			break
		end

		game:playSoundNear(self, "talents/spell_generic2")
		return true
	end,
	info = function(self, t)
		return ([[주무기인 염동 칼날로 적을 공격해 %d%% 무기 피해를 주고, 그 피해를 보조무기를 통해 동료에게 전달하여 생명력을 회복합니다.
		최대 생명력 회복량은 %d 이며, 생명력이 회복된 대상은 그만큼 평정을 찾게 됩니다.
		최대 생명력 회복량은 정신력 수치와 마석의 위력에 따라 증가합니다. (양손에 마석을 들고 있어야 하며, 배율은 %2.f 입니다)]]):
		format(self:combatTalentWeaponDamage(t, 2.5, 4) * 100, t.getMaxDamage(self, t), get_mindstar_power_mult(self))
	end,
}
