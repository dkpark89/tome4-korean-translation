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

local Object = require "mod.class.Object"

newTalent{
	name = "Ice Claw",
	kr_name = "얼음 발톱",
	type = {"wild-gift/cold-drake", 1},
	require = gifts_req1,
	points = 5,
	random_ego = "attack",
	equilibrium = 3,
	cooldown = 7,
	range = 0,
	radius = function(self, t) return math.floor(self:combatTalentScale(t, 1, 3)) end,
	direct_hit = true,
	requires_target = true,
	tactical = { ATTACK = { COLD = 2 } },
	is_melee = true,
	on_learn = function(self, t)
		self.combat_physresist = self.combat_physresist + 4
		self.combat_spellresist = self.combat_spellresist + 4
		self.combat_mentalresist = self.combat_mentalresist + 4
		self.resists[DamageType.COLD] = (self.resists[DamageType.COLD] or 0) + 1
	end,
	on_unlearn = function(self, t)
		self.combat_physresist = self.combat_physresist - 4
		self.combat_spellresist = self.combat_spellresist - 4
		self.combat_mentalresist = self.combat_mentalresist - 4
		self.resists[DamageType.COLD] = (self.resists[DamageType.COLD] or 0) - 1
	end,
	damagemult = function(self, t) return self:combatTalentScale(t, 1.6, 2.3) end,
	target = function(self, t)
		return {type="cone", range=self:getTalentRange(t), selffire=false, radius=self:getTalentRadius(t)}
	end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		self:project(tg, x, y, function(px, py, tg, self)
			local target = game.level.map(px, py, Map.ACTOR)
			if target and target ~= self then
				local hit = self:attackTarget(target, DamageType.ICE, self:combatTalentWeaponDamage(t, 1.6, 2.3), true)
			end
		end)
		game:playSoundNear(self, "talents/breath")
		return true
	end,
	info = function(self, t)
		return ([[냉기 드레이크의 강력한 얼음 발톱을 불러내, 얼음 속성의 %d%% 무기 피해를 %d 범위의 원뿔 형으로 줍니다. 얼음 속성의 피해는 적을 얼릴 수 있습니다.
		얼음 발톱의 레벨이 오를 때마다 당신의 물리, 정신, 주문 내성이 4 씩 추가됩니다.
		이 카테고리의 기술들은 기술 레벨을 투자 할 때마다, 냉기 저항력이 1%% 상승합니다.
		]]):format(100 * t.damagemult(self, t), self:getTalentRadius(t))
	end,
}

newTalent{
	name = "Icy Skin",
	kr_name = "얼음 피부",
	type = {"wild-gift/cold-drake", 2},
	require = gifts_req2,
	mode = "sustained",
	points = 5,
	cooldown = 10,
	sustain_equilibrium = 10,
	range = 10,
	tactical = { ATTACK = { COLD = 1 }, DEFEND = 2 },
	on_learn = function(self, t) self.resists[DamageType.COLD] = (self.resists[DamageType.COLD] or 0) + 1 end,
	on_unlearn = function(self, t) self.resists[DamageType.COLD] = (self.resists[DamageType.COLD] or 0) - 1 end,
	getArmor = function(self, t) return self:combatTalentMindDamage(t, 5, 25) end,
	getLifePct = function(self, t) return self:combatTalentLimit(t, 1, 0.02, 0.10) end, -- Limit < 100% bonus
	getDamageOnMeleeHit = function(self, t) return 10 +  self:combatTalentMindDamage(t, 10, 30) end,
	activate = function(self, t)
		return {
			onhit = self:addTemporaryValue("on_melee_hit", {[DamageType.COLD]=t.getDamageOnMeleeHit(self, t)}),
			life = self:addTemporaryValue("max_life", t.getLifePct(self, t)*self.max_life),
			armor = self:addTemporaryValue("combat_armor", t.getArmor(self, t)),
		}
	end,
	deactivate = function(self, t, p)
		self:removeTemporaryValue("max_life", p.life)
		self:removeTemporaryValue("combat_armor", p.armor)
		self:removeTemporaryValue("on_melee_hit", p.onhit)
		return true
	end,
	info = function(self, t)
		local life = t.getLifePct(self, t)
		return ([[당신의 피부는 얼음 비늘에 감싸이고 튼튼해졌습니다. 당신의 최대 생명력을 %d%% 만큼 상승시키고, 방어도를 %d 만큼 올립니다.
		또한 당신을 공격 하는 적에게 %0.2f 냉기 피해를 가합니다.
		이 카테고리의 기술들은 기술 레벨을 투자 할 때마다, 냉기 저항력이 1%% 상승합니다.
		생명력 상승률은 기술 레벨에 비례하고, 방어도와 반사 피해는 정신력에 비례하여 상승합니다.]]):format(life * 100, t.getArmor(self, t), damDesc(self, DamageType.COLD, t.getDamageOnMeleeHit(self, t)))
	end,
}

newTalent{
	name = "Ice Wall",
	kr_name = "얼음 벽",
	type = {"wild-gift/cold-drake", 3},
	require = gifts_req3,
	points = 5,
	random_ego = "defensive",
	equilibrium = 10,
	cooldown = function(self, t) return math.ceil(self:combatTalentLimit(t, 10, 30, 15)) end,
	range = 10,
	tactical = { DISABLE = 2 },
	requires_target = true,
	target = function(self, t)
		local halflength = math.floor(t.getLength(self,t)/2)
		local block = function(_, lx, ly)
			return game.level.map:checkAllEntities(lx, ly, "block_move")
		end
		return {type="wall", range=self:getTalentRange(t), halflength=halflength, talent=t, halfmax_spots=halflength+1, block_radius=block} 
	end,
	on_learn = function(self, t) self.resists[DamageType.COLD] = (self.resists[DamageType.COLD] or 0) + 1 end,
	on_unlearn = function(self, t) self.resists[DamageType.COLD] = (self.resists[DamageType.COLD] or 0) - 1 end,
	getDuration = function(self, t) return math.floor(self:combatTalentScale(t, 4, 8)) end,
	getLength = function(self, t) return 1 + math.floor(self:combatTalentScale(t, 3, 7)/2)*2 end,
	getIceDamage = function(self, t) return self:combatTalentMindDamage(t, 3, 15) end,
	getIceRadius = function(self, t) return math.floor(self:combatTalentScale(t, 1, 2)) end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		local ice_damage = self:mindCrit(t.getIceDamage(self, t))
		local ice_radius = t.getIceRadius(self, t)
		local _ _, _, _, x, y = self:canProject(tg, x, y)
		if game.level.map:checkEntity(x, y, Map.TERRAIN, "block_move") then return nil end

		self:project(tg, x, y, function(px, py, tg, self)
			local oe = game.level.map(px, py, Map.TERRAIN)
			if not oe or oe.special then return end
			if not oe or oe:attr("temporary") or game.level.map:checkAllEntities(px, py, "block_move") then return end
			local e = Object.new{
				old_feat = oe,
				name = "ice wall", image = "npc/iceblock.png",
				desc = "소환된 투명한 얼음 벽.",
				type = "wall",
				display = '#', color=colors.LIGHT_BLUE, back_color=colors.BLUE,
				always_remember = true,
				can_pass = {pass_wall=1},
				does_block_move = true,
				show_tooltip = true,
				block_move = true,
				block_sight = false,
				temporary = 4 + self:getTalentLevel(t),
				x = px, y = py,
				canAct = false,
				dam = ice_damage,
				radius = ice_radius,
				act = function(self)
					local t = self.summoner:getTalentFromId(self.T_ICE_WALL)
					local tg = {type="ball", range=0, radius=self.radius, friendlyfire=false, talent=t, x=self.x, y=self.y}
					self.summoner.__project_source = self
					self.summoner:project(tg, self.x, self.y, engine.DamageType.ICE, self.dam)
					self.summoner.__project_source = nil
					self:useEnergy()
					self.temporary = self.temporary - 1
					if self.temporary <= 0 then
						game.level.map(self.x, self.y, engine.Map.TERRAIN, self.old_feat)
						game.level:removeEntity(self)
						game.level.map:updateMap(self.x, self.y)
						game.nicer_tiles:updateAround(game.level, self.x, self.y)
					end
				end,
				dig = function(src, x, y, old)
					game.level:removeEntity(old, true)
					return nil, old.old_feat
				end,
				summoner_gain_exp = true,
				summoner = self,
			}
			e.tooltip = mod.class.Grid.tooltip
			game.level:addEntity(e)
			game.level.map(px, py, Map.TERRAIN, e)
		--	game.nicer_tiles:updateAround(game.level, px, py)
		--	game.level.map:updateMap(px, py)
		end)
		return true
	end,
	info = function(self, t)
		local icerad = t.getIceRadius(self, t)
		local icedam = t.getIceDamage(self, t)
		return ([[%d 칸 길이의 얼음 벽을 %d 턴 동안 소환합니다. 얼음 벽은 투명하지만, 투사체와 적들을 막습니다.
		얼음 벽은 또한 강력한 추위를 발생시켜, %0.2f 의 피해를 %d 범위 내의 적에게 가하고, 25%%의 확률로 적을 얼립니다. 이 추위는 기술 사용자나 그의 동료에게 피해를 끼치지 않습니다.
		이 카테고리의 기술들은 기술 레벨을 투자 할 때마다, 냉기 저항력이 1%% 상승합니다.]]):format(3 + math.floor(self:getTalentLevel(t) / 2) * 2, t.getDuration(self, t), damDesc(self, DamageType.COLD, icedam),  icerad)
	end,
}

newTalent{
	name = "Ice Breath",
	kr_name = "냉기 브레스",
	type = {"wild-gift/cold-drake", 4},
	require = gifts_req4,
	points = 5,
	random_ego = "attack",
	equilibrium = 12,
	cooldown = 12,
	message = "@Source@ 냉기의 숨결을 뱉습니다!",
	tactical = { ATTACKAREA = { COLD = 2 }, DISABLE = { stun = 1 } },
	range = 0,
	radius = function(self, t) return math.floor(self:combatTalentScale(t, 5, 9)) end,
	direct_hit = true,
	requires_target = true,
	on_learn = function(self, t) self.resists[DamageType.COLD] = (self.resists[DamageType.COLD] or 0) + 1 end,
	on_unlearn = function(self, t) self.resists[DamageType.COLD] = (self.resists[DamageType.COLD] or 0) - 1 end,
	target = function(self, t)
		return {type="cone", range=self:getTalentRange(t), radius=self:getTalentRadius(t), selffire=false, talent=t}
	end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		self:project(tg, x, y, DamageType.ICE_SLOW, self:mindCrit(self:combatTalentStatDamage(t, "str", 30, 500)))
		game.level.map:particleEmitter(self.x, self.y, tg.radius, "breath_cold", {radius=tg.radius, tx=x-self.x, ty=y-self.y})
		game:playSoundNear(self, "talents/breath")

		if core.shader.active(4) then
			local bx, by = self:attachementSpot("back", true)
			self:addParticles(Particles.new("shader_wings", 1, {img="icewings", x=bx, y=by, life=18, fade=-0.006, deploy_speed=14}))
		end
		return true
	end,
	info = function(self, t)
		return ([[당신은 냉기의 숨결을 내뱉어 %d 범위의 원뿔 모양으로 발사합니다. 냉기의 숨결에 휩싸인 목표는 %0.2f 의 냉기 피해를 받고, 20%% 만큼 세 턴동안 느려집니다. 또한 25%% 확률로 몇 턴간 얼릴 수 있습니다. (높은 랭크의 적일 수록 더 적은 시간 동안 얼립니다)
		피해량은 당신의 힘 능력치에 비례하고, 치명타율은 정신 치명타율을 따릅니다.
		이 카테고리의 기술들은 기술 레벨을 투자 할 때마다, 냉기 저항력이 1%% 상승합니다.]]):format(self:getTalentRadius(t), damDesc(self, DamageType.COLD, self:combatTalentStatDamage(t, "str", 30, 500)))
	end,
}
