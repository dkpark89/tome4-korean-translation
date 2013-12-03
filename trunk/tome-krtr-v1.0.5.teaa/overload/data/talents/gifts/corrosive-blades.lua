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

newTalent{
	name = "Acidbeam",
	kr_name = "산성 광선",
	type = {"wild-gift/corrosive-blades", 1},
	require = gifts_req_high1,
	points = 5,
	equilibrium = 4,
	cooldown = 3,
	tactical = { ATTACKAREA = {ACID=2} },
	on_pre_use = function(self, t)
		local main, off = self:hasPsiblades(true, true)
		return main and off
	end,
	range = 10,
	direct_hit = true,
	requires_target = true,
	target = function(self, t)
		return {type="beam", range=self:getTalentRange(t), friendlyfire=false, talent=t}
	end,
	getDamage = function(self, t) return self:combatTalentMindDamage(t, 20, 290) end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		local dam = self:mindCrit(t.getDamage(self, t))
		self:project(tg, x, y, DamageType.ACID, dam)
		local _ _, x, y = self:canProject(tg, x, y)
		game.level.map:particleEmitter(self.x, self.y, math.max(math.abs(x-self.x), math.abs(y-self.y)), "ooze_beam", {tx=x-self.x, ty=y-self.y})
		game:playSoundNear(self, "talents/slime")
		return true
	end,
	info = function(self, t)
		local dam = t.getDamage(self, t)
		return ([[염동 칼날을 통해 산성 물질을 내뿜어, 순간적으로 기다란 광선을 만들어냅니다. 
		이 광선은 적들을 관통하며, %0.2f 산성 피해를 줍니다.
		피해량은 정신력의 영향을 받아 증가합니다.]]):
		format(damDesc(self, DamageType.ACID, dam))
	end,
}

newTalent{
	name = "Corrosive Nature",
	kr_name = "부식성 자연",
	type = {"wild-gift/corrosive-blades", 2},
	require = gifts_req_high2,
	points = 5,
	mode = "passive",
	cooldown = function(self, t) return math.ceil(self:combatTalentLimit(t, 8, 30, 14)) end,
	getResist = function(self, t) return 10 + self:combatTalentMindDamage(t, 10, 70) end,
	info = function(self, t)
		local res = t.getResist(self, t)
		return ([[당신이 적에게 자연 속성 피해를 줄 때마다, 적의 산성 저항력이 2 턴 동안 %d%% 감소하게 됩니다.
		저항력 감소치는 정신력의 영향을 받아 증가합니다.
		This effect can only happen at most once every %d turns.]]): --@@ 한글화 필요
		format(res, self:getTalentCooldown(t))
	end,
}

local basetrap = function(self, t, x, y, dur, add)
	local Trap = require "mod.class.Trap"
	local trap = {
		id_by_type=true, unided_name = "trap",
		kr_unided_name = "함정",
		display = '^',
		faction = self.faction,
		summoner = self, summoner_gain_exp = true,
		temporary = dur,
		x = x, y = y,
		canAct = false,
		energy = {value=0},
		inc_damage = table.clone(self.inc_damage or {}, true),
		act = function(self)
			self:useEnergy()
			self.temporary = self.temporary - 1
			if self.temporary <= 0 then
				if game.level.map(self.x, self.y, engine.Map.TRAP) == self then	game.level.map:remove(self.x, self.y, engine.Map.TRAP) end
				game.level:removeEntity(self)
			end
		end,
	}
	table.merge(trap, add)
	return Trap.new(trap)
end

newTalent{
	name = "Corrosive Seeds",
	kr_name = "부식성 씨앗",
	type = {"wild-gift/corrosive-blades", 3},
	require = gifts_req_high3,
	points = 5,
	cooldown = 12,
	range = 8,
	equilibrium = 10,
	radius = function() return 2 end,
	direct_hit = true,
	requires_target = true,
	on_pre_use = function(self, t)
		local main, off = self:hasPsiblades(true, true)
		return main and off
	end,
	tactical = { ATTACKAREA = { ACID = 2 }, DISABLE = { knockback = 1 } },
	target = function(self, t) return {type="ball", radius=self:getTalentRadius(t), range=self:getTalentRange(t), talent=t} end,
	getDamage = function(self, t) return self:combatTalentMindDamage(t, 20, 290) end,
	getNb = function(self, t) local l = self:getTalentLevel(t) 
		if l < 3 then return 2
		elseif l < 5 then return 3
		else return 4
		end
	end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y, target = self:getTarget(tg)
		if not x or not y then return nil end
		local _ _, x, y = self:canProject(tg, x, y)
		if game.level.map(x, y, Map.TRAP) then game.logPlayer(self, "부식성 씨앗을 심는데 실패했습니다.") return nil end

		local tg = {type="ball", radius=self:getTalentRadius(t), range=self:getTalentRange(t)}
		local grids = {}
		self:project(tg, x, y, function(px, py) 
			if not game.level.map:checkEntity(px, py, Map.TERRAIN, "block_move") then grids[#grids+1] = {x=px, y=py} end
		end)

		for i = 1, t.getNb(self, t) do
			local spot = rng.tableRemove(grids)
			if not spot then break end
			local t = basetrap(self, t, spot.x, spot.y, 6, {
				type = "seed", name = "corrosive seed", color=colors.VIOLET, image = "trap/corrosive_seeds.png",
				kr_name = "부식성 씨앗",
				disarm_power = self:combatMindpower(),
				dam = self:mindCrit(t.getDamage(self, t)),
				triggered = function(self, x, y, who) return true, true end,
				combatMindpower = function(self) return self.summoner:combatMindpower() end,
				disarmed = function(self, x, y, who)
					game.level:removeEntity(self, true)
				end,
				knockx = self.x, knocky = self.y,
				triggered = function(self, x, y, who)
					self:project({type="ball", selffire=false, friendlyfire=false, x=x,y=y, radius=1}, x, y, engine.DamageType.WAVE, {x=self.knockx, y=self.knocky, st=engine.DamageType.ACID, dam=self.dam, dist=3, power=self:combatMindpower()})
					game.level.map:particleEmitter(x, y, 2, "acidflash", {radius=1, tx=x, ty=y})
					return true, true
				end,
			})
			t:identify(true)
			t:resolve() t:resolve(nil, true)
			t:setKnown(self, true)
			game.level:addEntity(t)
			game.zone:addEntity(game.level, t, "trap", spot.x, spot.y)
			game.level.map:particleEmitter(spot.x, spot.y, 1, "summon")
		end

		return true
	end,
	info = function(self, t)
		local dam = t.getDamage(self, t)
		local nb = t.getNb(self, t)
		return ([[당신은 목표 지점의 2 칸 반경 영역에 집중하여, 최대 %d 개의 부식성 씨앗이 나타나게 만듭니다.
		씨앗 위로 적이 지나가면 씨앗은 폭발하며, 대상에게 %0.2f 산성 피해를 주고 밀어냅니다.
		피해량은 정신력의 영향을 받아 증가합니다.]]):
		format(nb, damDesc(self, DamageType.ACID, dam))
	end,
}

newTalent{
	name = "Acidic Soil",
	kr_name = "산성 토양",
	type = {"wild-gift/corrosive-blades", 4},
	require = gifts_req_high4,
	mode = "sustained",
	points = 5,
	sustain_equilibrium = 20,
	cooldown = 30,
	tactical = { BUFF = 2 },
	on_pre_use = function(self, t)
		local main, off = self:hasPsiblades(true, true)
		return main and off
	end,
	getAcidDamageIncrease = function(self, t) return self:getTalentLevelRaw(t) * 2 end,
	getResistPenalty = function(self, t) return self:combatTalentLimit(t, 100, 17, 50) end, -- Limit < 100%
	getRegen = function(self, t) return self:combatTalentLimit(t, 50, 6.5, 32.5) end, -- Limit < 50%
	activate = function(self, t)
		game:playSoundNear(self, "talents/slime")

		local particle
		if core.shader.active(4) then
			particle = self:addParticles(Particles.new("shader_ring_rotating", 1, {additive=true, radius=1.1}, {type="flames", zoom=5, npow=2, time_factor=9000, color1={0.5,0.7,0,1}, color2={0.3,1,0.3,1}, hide_center=0, xy={self.x, self.y}}))
		else
			particle = self:addParticles(Particles.new("master_summoner", 1))
		end
		return {
			dam = self:addTemporaryValue("inc_damage", {[DamageType.ACID] = t.getAcidDamageIncrease(self, t)}),
			resist = self:addTemporaryValue("resists_pen", {[DamageType.ACID] = t.getResistPenalty(self, t)}),
			particle = particle,
		}
	end,
	deactivate = function(self, t, p)
		self:removeParticles(p.particle)
		self:removeTemporaryValue("inc_damage", p.dam)
		self:removeTemporaryValue("resists_pen", p.resist)
		return true
	end,
	info = function(self, t)
		local damageinc = t.getAcidDamageIncrease(self, t)
		local ressistpen = t.getResistPenalty(self, t)
		local regen = t.getRegen(self, t)
		return ([[스스로를 자연의 힘으로 둘러싸, 모든 산성 공격 피해량을 %d%% 증가시키고 산성 저항 관통력을 %d%% 올립니다.
		또한 이 힘은 당신의 진흙 덩어리들에게 영양분이 되어, 진흙 덩어리들에게 매 턴마다 최대 생명력의 %d%% 만큼을 재생할 수 있게 해줍니다.]])
		:format(damageinc, ressistpen, regen)
	end,
}
