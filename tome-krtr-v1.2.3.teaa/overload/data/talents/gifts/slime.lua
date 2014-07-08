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

newTalent{
	name = "Slime Spit",
	kr_name = "슬라임 뱉기",
	type = {"wild-gift/slime", 1},
	require = gifts_req1,
	points = 5,
	random_ego = "attack",
	equilibrium = 4,
	cooldown = 5,
	tactical = { ATTACK = { NATURE = 2}, DISABLE = 1 },
	range = 10,
	proj_speed = 6,
	requires_target = true,
	getTargetCount = function(self, t) return math.floor(self:combatTalentScale(t, 1, 5, "log")) end,
	bouncePercent = function(self, t) return self:combatTalentLimit(t, 100, 50, 60) end, --Limit < 100%
	action = function(self, t)
		local tg = {type="bolt", range=self:getTalentRange(t), selffire=false, talent=t, display={particle="bolt_slime"}, name = t.name, speed = t.proj_speed}
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		self:projectile(tg, x, y, DamageType.BOUNCE_SLIME, {nb=t.getTargetCount(self, t), dam=self:mindCrit(self:combatTalentMindDamage(t, 30, 250)), bounce_factor=t.bouncePercent(self, t)/100}, {type="slime"})
		game:playSoundNear(self, "talents/slime")
		return true
	end,
	info = function(self, t)
		return ([[슬라임 덩어리를 대상에게 뱉어, %0.2f 자연 피해를 주고 3 턴 동안 대상을 30%% 감속시킵니다.
		슬라임은 적들 사이를 튕겨다니면서, 최대 %d 명의 적을 공격합니다.
		이를 위해서는 다른 적이 6 칸 이내의 위치에 있어야 하며, 공격이 튕겨질 때마다 피해량이 %0.1f%% 감소하게 됩니다.
		피해량은 정신력의 영향을 받아 증가합니다.]]):format(damDesc(self, DamageType.NATURE, self:combatTalentMindDamage(t, 30, 250)), t.getTargetCount(self, t), 100-t.bouncePercent(self, t)) 
	end,
}

newTalent{
	name = "Poisonous Spores",
	kr_name = "중독성 포자",
	type = {"wild-gift/slime", 2},
	require = gifts_req2,
	random_ego = "attack",
	points = 5,
	message = "@Source1@ @target@에게 중독성 포자를 뿌립니다!",
	equilibrium = 2,
	cooldown = 10,
	range = 10,
	tactical = { ATTACKAREA = { NATURE = 2 }, DISABLE = 1 },
	radius = function(self, t) return math.floor(self:combatTalentScale(t, 1, 2.7)) end,
	getDamage = function(self, t) return self:combatTalentMindDamage(t, 30, 390) end,
	critPower = function(self, t) return self:combatTalentMindDamage(t, 10, 40) end,
	requires_target = true,
	action = function(self, t)
		local tg = {type="ball", range=self:getTalentRange(t), radius=self:getTalentRadius(t), friendlyfire=false}
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		local dam = self:mindCrit(t.getDamage(self, t), 0, t.critPower(self, t)/100)
		self:project(tg, x, y, function(px, py)
			local target = game.level.map(px, py, Map.ACTOR)
			if target and self:reactionToward(target) < 0 and target:canBe("poison") then
				local poison = rng.table{target.EFF_SPYDRIC_POISON, target.EFF_INSIDIOUS_POISON, target.EFF_CRIPPLING_POISON, target.EFF_NUMBING_POISON}
				target:setEffect(poison, 10, {src=self, power=dam/10, 
				reduce=self:combatTalentLimit(t, 100, 12, 20), 
				fail=math.ceil(self:combatTalentLimit(t, 100, 6, 10)),
				heal_factor=self:combatTalentLimit(t, 100, 24, 40)})
			end
		end, 0, {type="slime"})

		game:playSoundNear(self, "talents/slime")
		return true
	end,
	info = function(self, t)
		return ([[주변 %d 칸 반경에 중독성 포자를 뿌려, 적에게 무작위한 독을 걸고 10 턴 동안 총 %0.1f 자연 피해를 나눠서 줍니다.
		이 공격은 치명타가 발생할 수 있으며, %d%% 더 높은 치명타 피해를 입힙니다.
		피해량과 치명타 피해 증가량은 정신력의 영향을 받아 증가합니다.]]):format(self:getTalentRadius(t), damDesc(self, DamageType.NATURE, t.getDamage(self, t)), t.critPower(self, t)) 
	end,
}

-- Boring, but disarm was way too far
-- Now that we have melee retaliation damage shown in tooltips its a little safer to raise the damage on this
newTalent{
	name = "Acidic Skin",
	kr_name = "산성 피부",
	type = {"wild-gift/slime", 3},
	require = gifts_req3,
	points = 5,
	mode = "sustained",
	message = "@Source@의 피부에서 산이 떨어지기 시작합니다.",
	sustain_equilibrium = 3,
	cooldown = 30,
	range = 1,
	requires_target = false,
	tactical = { DEFEND = 1 },
	getChance = function(self, t) return self:combatTalentLimit(t, 100, 7, 15) end, -- Limit < 100%
	getDamage = function(self, t) return self:combatTalentMindDamage(t, 10, 50) end,
	activate = function(self, t)
		game:playSoundNear(self, "talents/slime")
		local power = t.getDamage(self, t)
		return {
			onhit = self:addTemporaryValue("on_melee_hit", {[DamageType.ACID_DISARM]={dam=power, chance=t.getChance(self, t)}}),
		}
	end,
	deactivate = function(self, t, p)
		self:removeTemporaryValue("on_melee_hit", p.onhit)
		return true
	end,
	info = function(self, t)
		return ([[피부를 산성으로 만들어, 자신을 공격한 적에게 %0.1f 산성 피해를 줍니다.
		피해량은 정신력의 영향을 받아 증가합니다.]]):format(damDesc(self, DamageType.ACID, t.getDamage(self, t)))
	end,
}

newTalent{
	name = "Slime Roots",
	kr_name = "슬라임 뿌리",
	type = {"wild-gift/slime", 4},
	require = gifts_req4,
	points = 5,
	random_ego = "utility",
	equilibrium = 5,
	cooldown = 20,
	tactical = { CLOSEIN = 2, ESCAPE = 1 },
	requires_target = true,
	range = function(self, t)
		return math.floor(self:combatTalentScale(t,4.5,6.5))
	end,
	radius = function(self, t)
		return util.bound(4 - self:getTalentLevel(t) / 2, 1, 4)
	end,
	getNbTalents = function(self, t)
		if self:getTalentLevel(t) < 4 then return 1
		elseif self:getTalentLevel(t) < 7 then return 2
		else return 3
		end
	end,
	is_teleport = true,
	action = function(self, t)
		local range = self:getTalentRange(t)
		local radius = self:getTalentRadius(t)
		local tg = {type="ball", nolock=true, pass_terrain=true, nowarning=true, range=range, radius=radius, requires_knowledge=false}
		local x, y = self:getTarget(tg)
		if not x then return nil end
		-- Target code does not restrict the self coordinates to the range, it lets the project function do it
		-- but we cant ...
		local _, x, y = self:canProject(tg, x, y)
		if not x then return nil end
		local oldx, oldy = self.x, self.y
		if not self:teleportRandom(x, y, self:getTalentRadius(t)) then return nil end
		game.level.map:particleEmitter(oldx, oldy, 1, "slime")
		game.level.map:particleEmitter(self.x, self.y, 1, "slime")

		local nb = t.getNbTalents(self, t)

		local list = {}
		for tid, cd in pairs(self.talents_cd) do 
			local tt = self:getTalentFromId(tid)
			if tt.mode ~= "passive" and not tt.uber then list[#list+1] = tid end
		end
		while #list > 0 and nb > 0 do
			self.talents_cd[rng.tableRemove(list)] = nil
			nb = nb - 1
		end
		game:playSoundNear(self, "talents/slime")
		return true
	end,
	info = function(self, t)
		local range = self:getTalentRange(t)
		local radius = self:getTalentRadius(t)
		local talents = t.getNbTalents(self, t)
		return ([[슬라임 뿌리를 지면에 박아 원하는 위치까지 뻗어낸 다음, 그 뿌리를 이용하여 주변 %d 칸 반경을 순간이동합니다. (오차 범위 : %d 칸)
		이 기술은 자신의 신체 구조를 약간 변화시켜, 기술 %d 개의 재사용 대기시간을 사라지게 만듭니다.]]):format(range, radius, talents)
	end,
}

