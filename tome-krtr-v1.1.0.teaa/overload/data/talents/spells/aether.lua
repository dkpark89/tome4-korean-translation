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
		act = function(self)
			self:realact()
			self:useEnergy()
			self.temporary = self.temporary - 1
			if self.temporary <= 0 then
				if game.level.map(self.x, self.y, engine.Map.TRAP) == self then game.level.map:remove(self.x, self.y, engine.Map.TRAP) end
				game.level:removeEntity(self, true)
			end
		end,
	}
	table.merge(trap, add)
	return Trap.new(trap)
end

newTalent{
	name = "Aether Beam",
	kr_name = "에테르 소용돌이",
	type = {"spell/aether", 1},
	require = spells_req_high1,
	mana = 20,
	points = 5,
	cooldown = 12,
	use_only_arcane = 1,
	direct_hit = true,
	range = 6,
	requires_target = true,
	tactical = { ATTACKAREA = { ARCANE = 2 }, DISABLE = { silence = 1 } },
	target = function(self, t) return {type="hit", range=self:getTalentRange(t), talent=t} end,
	getDamage = function(self, t) return self:combatTalentSpellDamage(t, 20, 150) end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y, target = self:getTarget(tg)
		if not x or not y then return nil end
		local _ _, x, y = self:canProject(tg, x, y)
		if game.level.map(x, y, Map.TRAP) then game.logPlayer(self, "해당 지역의 에테르 제어에 실패했습니다.") return nil end
		if game.level.map:checkEntity(x, y, Map.TERRAIN, "block_move") then game.logPlayer(self, "You somehow fail to set the aether beam.") return nil end --@@ 한글화 필요

		local t = basetrap(self, t, x, y, 44, {
			type = "aether", name = "aether beam", color=colors.VIOLET, image = "trap/trap_glyph_explosion_01_64.png",
			kr_name = "에테르 소용돌이", 
			dam = self:spellCrit(t.getDamage(self, t)),
			triggered = function(self, x, y, who) return true, true end,
			combatSpellpower = function(self) return self.summoner:combatSpellpower() end,
			rad = 3,
			energy = {value=0, mod=16},
			on_added = function(self, level, x, y)
				self.x, self.y = x, y
				local tries = {}
				local list = {i=1}
				local sa = rng.range(0, 359)
				local dir = rng.percent(50) and 1 or -1
				for a = sa, sa + 359 * dir, dir do
					local rx, ry = math.floor(math.cos(math.rad(a)) * self.rad), math.floor(math.sin(math.rad(a)) * self.rad)
					if not tries[rx] or not tries[rx][ry] then
						tries[rx] = tries[rx] or {}
						tries[rx][ry] = true
						list[#list+1] = {x=rx+x, y=ry+y}
					end
				end
				self.list = list
				self.on_added = nil
			end,
			disarmed = function(self, x, y, who)
				game.level:removeEntity(self, true)
			end,
			realact = function(self)
				if game.level.map(self.x, self.y, engine.Map.TRAP) ~= self then game.level:removeEntity(self, true) return end

				local x, y = self.list[self.list.i].x, self.list[self.list.i].y
				self.list.i = util.boundWrap(self.list.i + 1, 1, #self.list)

				local tg = {type="beam", x=self.x, y=self.y, range=self.rad, selffire=self.summoner:spellFriendlyFire()}
				self.summoner.__project_source = self
				self.summoner:project(tg, x, y, engine.DamageType.ARCANE_SILENCE, {dam=self.dam, chance=25}, nil)
				self.summoner:project(tg, self.x, self.y, engine.DamageType.ARCANE, self.dam/10, nil)
				self.summoner.__project_source = nil
				local _ _, x, y = self:canProject(tg, x, y)
				game.level.map:particleEmitter(self.x, self.y, math.max(math.abs(x-self.x), math.abs(y-self.y)), "mana_beam", {tx=x-self.x, ty=y-self.y})
			end,
		})
		t:identify(true)

		t:resolve() t:resolve(nil, true)
		t:setKnown(self, true)
		game.level:addEntity(t)
		game.zone:addEntity(game.level, t, "trap", x, y)
		game.level.map:particleEmitter(x, y, 1, "summon")

		return true
	end,
	info = function(self, t)
		local dam = t.getDamage(self, t)
		return ([[해당 지점의 에테르로 세 갈래의 빔으로 이루어진 마법 소용돌이를 만들어내, 주변에 %0.2f 마법 피해를 주고 25%% 확률로 침묵 상태효과를 겁니다.
		회전의 중심은 주변 피해의 10%% 만을 입으며, 침묵 상태효과도 걸리지 않습니다.
		소용돌이는 아주 빠른 속도로 회전합니다. (1600%% 속도).
		피해량은 주문력의 영향을 받아 증가합니다.]]):
		format(damDesc(self, DamageType.ARCANE, dam))
	end,
}

newTalent{
	name = "Aether Breach",
	kr_name = "에테르 파괴",
	type = {"spell/aether", 2},
	require = spells_req_high2,
	points = 5,
	random_ego = "attack",
	mana = 50,
	cooldown = 8,
	use_only_arcane = 1,
	tactical = { ATTACK = { ARCANE = 2 } },
	range = 7,
	radius = 2,
	direct_hit = function(self, t) if self:getTalentLevel(t) >= 3 then return true else return false end end,
	reflectable = true,
	requires_target = true,
	target = function(self, t)
		local tg = {type="ball", range=self:getTalentRange(t), radius=self:getTalentRadius(t), talent=t}
		return tg
	end,
	getNb = function(self, t) return math.floor(self:combatTalentScale(t, 3.3, 4.7)) end,
	getDamage = function(self, t) return self:combatTalentSpellDamage(t, 20, 180) end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		local list = {}
		self:project(tg, x, y, function(px, py) list[#list+1] = {x=px, y=py} end)

		self:setEffect(self.EFF_AETHER_BREACH, t.getNb(self, t), {src = self, list=list, level=game.zone.short_name.."-"..game.level.level, dam=self:spellCrit(t.getDamage(self, t))})

		game:playSoundNear(self, "talents/arcane")
		return true
	end,
	info = function(self, t)
		local damage = t.getDamage(self, t)
		return ([[에테르가 지나가는 통로를 일시적으로 파괴하여, 대상 지역 근처에 %d 번의 마법 폭발을 무작위로 일으킵니다.
		각각의 폭발은 주변 2 칸 반경에 %0.2f 마법 피해를 주고, 1 턴 당 1 번의 폭발만 일어납니다.
		피해량은 주문력의 영향을 받아 증가합니다.]]):
		format(t.getNb(self, t), damDesc(self, DamageType.ARCANE, damage))
	end,
}

newTalent{
	name = "Aether Avatar",
	kr_name = "에테르의 화신",
	type = {"spell/aether", 3},
	require = spells_req_high3,
	points = 5,
	mana = 60,
	cooldown = function(self, t)
		local rcd = math.ceil(self:combatTalentLimit(t, 15, 37, 25)) -- Limit > 15
		return self:attr("arcane_cooldown_divide") and rcd * self.arcane_cooldown_divide or rcd 
	end,
	range = 10,
	direct_hit = true,
	use_only_arcane = 1,
	requires_target = true,
	no_energy = true,
	tactical = { BUFF = 2 },
	getNb = function(self, t) return math.floor(self:combatTalentLimit(t, 15, 5, 9)) end, -- Limit duration < 15	
	action = function(self, t)
		self:setEffect(self.EFF_AETHER_AVATAR, t.getNb(self, t), {})
		game:playSoundNear(self, "talents/arcane")
		return true
	end,
	info = function(self, t)
		return ([[몸에 에테르의 힘을 주입시켜, %d 턴 동안 에테르의 화신이 됩니다.
		지속시간 동안 비술 계열과 에테르 계열의 마법만을 사용할 수 있지만, 그 대신 모든 마법의 지연시간이 66%% 감소하고 피해량이 25%% 증가합니다. 
		또한 불안정한 보호막을 언제나 활성화시킬 수 있으며, 최대 마나량이 33%% 증가합니다.]]):
		format(t.getNb(self, t))
	end,
}

newTalent{
	name = "Pure Aether",
	kr_name = "순수한 에테르",
	type = {"spell/aether",4},
	require = spells_req_high4,
	points = 5,
	mode = "sustained",
	sustain_mana = 50,
	cooldown = 30,
	use_only_arcane = 1,
	tactical = { BUFF = 2 },
	getDamageIncrease = function(self, t) return self:getTalentLevelRaw(t) * 2 end,
	getResistPenalty = function(self, t) return self:combatTalentLimit(t, 100, 17, 50, true) end, -- Limit < 100%	
	activate = function(self, t)
		game:playSoundNear(self, "talents/arcane")

		local particle
		local ret = {
			dam = self:addTemporaryValue("inc_damage", {[DamageType.ARCANE] = t.getDamageIncrease(self, t)}),
			resist = self:addTemporaryValue("resists_pen", {[DamageType.ARCANE] = t.getResistPenalty(self, t)}),
		}
		if core.shader.active(4) then
			ret.particle = self:addParticles(Particles.new("shader_ring_rotating", 1, {toback=true, rotation=0, radius=2, img="arcanegeneric", a=0.7}, {type="sunaura", time_factor=5000}))
--			particle = self:addParticles(Particles.new("shader_ring_rotating", 1, {radius=1.1}, {type="flames", hide_center=0, time_factor=1700, zoom=0.3, npow=1, color1={0.6, 0.3, 0.8, 1}, color2={0.8, 0, 0.8, 1}, xy={self.x, self.y}}))
		else
			ret.particle = self:addParticles(Particles.new("ultrashield", 1, {rm=180, rM=220, gm=10, gM=50, bm=190, bM=220, am=120, aM=200, radius=0.4, density=100, life=8, instop=20}))
		end
		return ret
	end,
	deactivate = function(self, t, p)
		self:removeParticles(p.particle)
		self:removeTemporaryValue("inc_damage", p.dam)
		self:removeTemporaryValue("resists_pen", p.resist)
		return true
	end,
	info = function(self, t)
		local damageinc = t.getDamageIncrease(self, t)
		local ressistpen = t.getResistPenalty(self, t)
		return ([[시전자의 주변을 순수한 에테르의 힘으로 둘러싸, 마법 속성 피해량을 %d%% 증가시키고 적의 마법 속성 저항력을 %d%% 무시합니다.
		기술 레벨이 5 이상이면, '수호' 마법을 에테르의 화신 상태에서도 사용할 수 있게 됩니다.]])
		:format(damageinc, ressistpen)
	end,
}
