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

----------------------------------------------------
-- Active techniques
----------------------------------------------------
newTalent{
	name = "Rush",
	kr_name = "돌진",
	type = {"technique/combat-techniques-active", 1},
	message = "@Source1@ 돌진합니다!",
	require = techs_strdex_req1,
	points = 5,
	random_ego = "attack",
	stamina = function(self, t) return self:knowTalent(self.T_STEAMROLLER) and 2 or 22 end,
	cooldown = function(self, t) return math.ceil(self:combatTalentLimit(t, 0, 36, 20)) end, --Limit to >0
	tactical = { ATTACK = { weapon = 1, stun = 1 }, CLOSEIN = 3 },
	requires_target = true,
	is_melee = true,
	target = function(self, t) return {type="hit", range=self:getTalentRange(t)} end,
	range = function(self, t) return math.floor(self:combatTalentScale(t, 6, 10)) end,
	on_pre_use = function(self, t)
		if self:attr("never_move") then return false end
		return true
	end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y, target = self:getTarget(tg)
		if not target or not self:canProject(tg, x, y) then return nil end

		local block_actor = function(_, bx, by) return game.level.map:checkEntity(bx, by, Map.TERRAIN, "block_move", self) end
		local linestep = self:lineFOV(x, y, block_actor)

		local tx, ty, lx, ly, is_corner_blocked
		repeat  -- make sure each tile is passable
			tx, ty = lx, ly
			lx, ly, is_corner_blocked = linestep:step()
		until is_corner_blocked or not lx or not ly or game.level.map:checkAllEntities(lx, ly, "block_move", self)
		if not tx or core.fov.distance(self.x, self.y, tx, ty) < 1 then
			game.logPlayer(self, "너무 가까이 있어서 돌진할 힘이 붙지 않습니다!")
			return
		end
		if not tx or not ty or core.fov.distance(x, y, tx, ty) > 1 then return nil end

		local ox, oy = self.x, self.y
		self:move(tx, ty, true)
		if config.settings.tome.smooth_move > 0 then
			self:resetMoveAnim()
			self:setMoveAnim(ox, oy, 8, 5)
		end
		-- Attack ?
		if core.fov.distance(self.x, self.y, x, y) == 1 then
			if self:knowTalent(self.T_STEAMROLLER) then
				target:setEffect(target.EFF_STEAMROLLER, 2, {src=self})
				self:setEffect(self.EFF_STEAMROLLER_USER, 2, {buff=20})
			end

			if self:attackTarget(target, nil, 1.2, true) and target:canBe("stun") then
				-- Daze, no save
				target:setEffect(target.EFF_DAZED, 3, {})
			end
		end

		return true
	end,
	info = function(self, t)
		return ([[엄청난 속도로 대상에게 돌진합니다. 대상에게 성공적으로 도달했을 경우 120% 의 무기 피해를 주며, 대상을 3 턴 동안 혼절시킵니다.
		대상과 딱 붙어있을 경우, 돌진할 수 없습니다.최소 2 타일의 거리가 필요합니다.]])
	end,
}

newTalent{
	name = "Precise Strikes",
	kr_name = "정밀 타격",
	type = {"technique/combat-techniques-active", 2},
	mode = "sustained",
	points = 5,
	require = techs_strdex_req2,
	cooldown = 30,
	sustain_stamina = 30,
	tactical = { BUFF = 1 },
	getAtk = function(self, t) return self:combatScale(self:getTalentLevel(t) * self:getDex(), 4, 0, 37, 500) end,
	getCrit = function(self, t)
		local dex = self:combatStatScale("dex", 10/25, 100/25, 0.75)
		return (self:combatTalentScale(t, dex, dex*5, 0.5, 4))
	end,
	activate = function(self, t)
		return {
			speed = self:addTemporaryValue("combat_physspeed", -0.10),
			atk = self:addTemporaryValue("combat_atk", t.getAtk(self, t)),
			crit = self:addTemporaryValue("combat_physcrit", t.getCrit(self, t)),
		}
	end,
	deactivate = function(self, t, p)
		self:removeTemporaryValue("combat_physspeed", p.speed)
		self:removeTemporaryValue("combat_physcrit", p.crit)
		self:removeTemporaryValue("combat_atk", p.atk)
		return true
	end,
	info = function(self, t)
		return ([[적을 공격할 때 더 집중합니다. 공격 속도가 %d%% 감소하는 대신, 정확도가 %d / 치명타율이 %d%% 상승합니다.
		정밀 타격으로 인해 얻는 긍정적 효과들은 민첩 능력치의 영향을 받아 증가합니다.]]):
		format(10, t.getAtk(self, t), t.getCrit(self, t))
	end,
}

newTalent{
	name = "Perfect Strike",
	kr_name = "완벽한 공격",
	type = {"technique/combat-techniques-active", 3},
	points = 5,
	random_ego = "attack",
	cooldown = 25,
	stamina = 10,
	require = techs_strdex_req3,
	no_energy = true,
	tactical = { ATTACK = 4 },
	getDuration = function(self, t) return math.floor(self:combatTalentLimit(t, 25, 2, 6)) end, -- Limit < 25
	getAtk = function(self, t) return self:combatTalentScale(t, 40, 100, 0.75) end,
	action = function(self, t)
		self:setEffect(self.EFF_ATTACK, t.getDuration(self, t), {power = t.getAtk(self, t)})
		return true
	end,
	info = function(self, t)
		return ([[고도의 집중력을 발휘하여, %d 턴 동안 근접, 원거리 물리 공격의 정확도를 %d 증가시킵니다. 
		또한 지속시간 동안, 보이지 않는 적을 공격할 때 생기는 불리함을 무시할 수 있게 됩니다.]]):format(t.getDuration(self, t), t.getAtk(self, t))
	end,
}

newTalent{
	name = "Blinding Speed",
	kr_name = "눈부신 속도",
	type = {"technique/combat-techniques-active", 4},
	points = 5,
	random_ego = "utility",
	cooldown = 55,
	stamina = 25,
	no_energy = true,
	require = techs_strdex_req4,
	tactical = { BUFF = 2, CLOSEIN = 2, ESCAPE = 2 },
	getSpeed = function(self, t) return self:combatTalentScale(t, 0.14, 0.45, 0.75) end,
	action = function(self, t)
		self:setEffect(self.EFF_SPEED, 5, {power=t.getSpeed(self, t)})
		return true
	end,
	info = function(self, t)
		return ([[혹독한 훈련을 통해, 일시적으로 몸의 잠재력을 끌어올립니다.
		5 턴 동안 전체 속도가 %d%% 증가합니다.]]):format(100*t.getSpeed(self, t))
	end,
}

----------------------------------------------------
-- Passive techniques
----------------------------------------------------
newTalent{
	name = "Quick Recovery",
	kr_name = "빠른 회복",
	type = {"technique/combat-techniques-passive", 1},
	require = techs_strdex_req1,
	mode = "passive",
	points = 5,
	getStamRecover = function(self, t) return self:combatTalentScale(t, 0.6, 2.5, 0.75) end,
	passives = function(self, t, p)
		self:talentTemporaryValue(p, "stamina_regen", t.getStamRecover(self, t))
	end,
	info = function(self, t)
		return ([[숙련된 전투 경험을 통해, 체력을 보다 효율적으로 회복합니다. (체력 +%0.2f/턴)]]):format(t.getStamRecover(self, t))
	end,
}

newTalent{
	name = "Fast Metabolism",
	kr_name = "빠른 신진대사",
	type = {"technique/combat-techniques-passive", 2},
	require = techs_strdex_req2,
	mode = "passive",
	points = 5,
	getRegen = function(self, t) return self:combatTalentScale(t, 3, 7.5, 0.75) end,
	passives = function(self, t, p)
		self:talentTemporaryValue(p, "life_regen", t.getRegen(self, t))
	end,
	info = function(self, t)
		return ([[신진대사를 가속시켜, 생명력을 보다 빠르게 회복합니다. (생명력 +%0.2f/턴)]]):format(t.getRegen(self, t))
	end,
}

newTalent{
	name = "Spell Shield",
	kr_name = "주문 방어",
	type = {"technique/combat-techniques-passive", 3},
	require = techs_strdex_req3,
	mode = "passive",
	points = 5,
	passives = function(self, t, p)
		self:talentTemporaryValue(p, "combat_spellresist", self:getTalentLevel(t) * 9)
	end,
	info = function(self, t)
		return ([[혹독한 훈련을 통해, 적의 주문에 대한 내성을 올립니다. (주문 내성 %d 상승)]]):format(self:getTalentLevel(t) * 9)
	end,
}

newTalent{
	name = "Unending Frenzy",
	kr_name = "끝나지 않는 광란",
	type = {"technique/combat-techniques-passive", 4},
	require = techs_strdex_req4,
	mode = "passive",
	-- called by mod.class.Actor:die
	getStamRecover = function(self, t) return self:combatTalentScale(t, 5, 20, 0.5) end, -- Lower scaling than other recovery talents because it effectively scales with character speed and can trigger more than once a turn
	points = 5,
	info = function(self, t)
		return ([[적의 죽음에 고무되어, 당신이 적을 죽일 때마다 체력이 %d 씩 회복됩니다.]]):format(t.getStamRecover(self, t))
	end,
}
