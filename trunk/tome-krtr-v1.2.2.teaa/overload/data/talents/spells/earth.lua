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

local Object = require "mod.class.Object"

newTalent{
	name = "Stone Skin",
	kr_name = "단단한 피부",
	type = {"spell/earth", 1},
	mode = "sustained",
	require = spells_req1,
	points = 5,
	sustain_mana = 30,
	cooldown = 10,
	tactical = { BUFF = 2 },
	getArmor = function(self, t) return self:combatTalentSpellDamage(t, 10, 23) end,
	activate = function(self, t)
		game:playSoundNear(self, "talents/earth")
		local ret = {
			armor = self:addTemporaryValue("combat_armor", t.getArmor(self, t)),
		}
		if not self:addShaderAura("stone_skin", "crystalineaura", {time_factor=1500, spikeOffset=0.123123, spikeLength=0.9, spikeWidth=3, growthSpeed=2, color={0xD7/255, 0x8E/255, 0x45/255}}, "particles_images/spikes.png") then
			ret.particle = self:addParticles(Particles.new("stone_skin", 1))
		end
		return ret
	end,
	deactivate = function(self, t, p)
		self:removeShaderAura("stone_skin")
		self:removeParticles(p.particle)
		self:removeTemporaryValue("combat_armor", p.armor)
		return true
	end,
	info = function(self, t)
		local armor = t.getArmor(self, t)
		return ([[시전자의 피부가 돌과 같이 단단해져, 방어도가 %d 상승합니다.
		방어도 상승량은 주문력의 영향을 받아 증가합니다.]]):
		format(armor)
	end,
}

newTalent{
	name = "Pulverizing Auger", short_name="DIG",
	kr_name = "파쇄용 시추 드릴",
	type = {"spell/earth",2},
	require = spells_req2,
	points = 5,
	mana = 15,
	cooldown = 6,
	range = function(self, t) return math.min(10, math.floor(self:combatTalentScale(t, 3, 7))) end,
	tactical = { ATTACK = {PHYSICAL = 2} },
	direct_hit = true,
	requires_target = true,
	getDigs = function(self, t) return math.floor(self:combatTalentScale(t, 1, 5, "log")) end,
	getDamage = function(self, t) return self:combatTalentSpellDamage(t, 30, 300) end,
	target = function(self, t)
		local tg = {type="beam", range=self:getTalentRange(t), talent=t}
		return tg
	end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end

		for i = 1, t.getDigs(self, t) do self:project(tg, x, y, DamageType.DIG, 1) end

		self:project(tg, x, y, DamageType.PHYSICAL, self:spellCrit(t.getDamage(self, t)), nil)
		local _ _, x, y = self:canProject(tg, x, y)
		game.level.map:particleEmitter(self.x, self.y, math.max(math.abs(x-self.x), math.abs(y-self.y)), "earth_beam", {tx=x-self.x, ty=y-self.y})
		game:playSoundNear(self, "talents/earth")
		return true
	end,
	info = function(self, t)
		local damage = t.getDamage(self, t)
		local nb = t.getDigs(self, t)
		return ([[강력한 파쇄용 암석 줄기를 발사하여, 벽을 %d 칸 굴착합니다.
		또한, 암석 줄기는 그 경로에 있는 모든 적들에게 %0.2f 물리 피해를 줍니다.
		피해량은 주문력의 영향을 받아 증가합니다.]]):
		format(nb, damDesc(self, DamageType.PHYSICAL, damage))
	end,
}

newTalent{
	name = "Mudslide",
	kr_name = "산사태",
	type = {"spell/earth",3},
	require = spells_req3,
	points = 5,
	random_ego = "attack",
	mana = 40,
	cooldown = 12,
	direct_hit = true,
	tactical = { ATTACKAREA = { PHYSICAL = 2 }, DISABLE = { knockback = 2 }, ESCAPE = { knockback = 1 } },
	range = 0,
	radius = function(self, t) return math.floor(self:combatTalentScale(t, 4, 8)) end,
	requires_target = true,
	target = function(self, t) return {type="cone", range=self:getTalentRange(t), radius=self:getTalentRadius(t), talent=t} end,
	getDamage = function(self, t) return self:combatTalentSpellDamage(t, 10, 250) end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		self:project(tg, x, y, DamageType.SPELLKNOCKBACK, {dist=4, dam=self:spellCrit(t.getDamage(self, t))})
		game.level.map:particleEmitter(self.x, self.y, tg.radius, "mudflow", {radius=tg.radius, tx=x-self.x, ty=y-self.y})
		game:playSoundNear(self, "talents/tidalwave")
		return true
	end,
	info = function(self, t)
		local damage = t.getDamage(self, t)
		local radius = self:getTalentRadius(t)
		return ([[소규모 산사태를 만들어내, 전방의 주변 %d 칸 반경에 %0.2f 물리 피해를 줍니다. 산사태에 휩쓸린 적들은 밀려납니다.
		피해량은 주문력의 영향을 받아 증가합니다.]]):
		format(self:getTalentRadius(t), damDesc(self, DamageType.PHYSICAL, damage)) --@ 변수 순서 조정
	end,
}

newTalent{
	name = "Stone Wall",
	kr_name = "암석의 벽",
	type = {"spell/earth",4},
	require = spells_req4,
	points = 5,
	cooldown = 40,
	mana = 50,
	range = 7,
	tactical = { ATTACKAREA = {PHYSICAL = 2}, DISABLE = 4, DEFEND = 3, PROTECT = 3, ESCAPE = 1 },
	target = function(self, t) return {type="ball", nowarning=true, selffire=false, friendlyfire=false, range=self:getTalentRange(t), radius=1, talent=t} end,
	getDamage = function(self, t) return self:combatTalentSpellDamage(t, 20, 250) end,
	requires_target = function(self, t) return self:getTalentLevel(t) >= 4 end,
		getDuration = function(self, t) return util.bound(2 + self:combatTalentSpellDamage(t, 5, 12), 2, 25) end,
	action = function(self, t)
		local x, y = self.x, self.y
		local tg = self:getTalentTarget(t)
		if self:getTalentLevel(t) >= 4 then
			x, y = self:getTarget(tg)
			if not x or not y then return nil end
			local _ _, _, _, x, y = self:canProject(tg, x, y)
		end
		
		self:project(tg, x, y, DamageType.PHYSICAL, self:spellCrit(t.getDamage(self, t)))

		for i = -1, 1 do for j = -1, 1 do if game.level.map:isBound(x + i, y + j) then
			local oe = game.level.map(x + i, y + j, Map.TERRAIN)
			if oe and not oe:attr("temporary") and not game.level.map:checkAllEntities(x + i, y + j, "block_move") and not oe.special then
				-- Ok some explanation, we make a new *OBJECT* because objects can have energy and act
				-- it stores the current terrain in "old_feat" and restores it when it expires
				-- We CAN set an object as a terrain because they are all entities

				local e = Object.new{
					old_feat = oe,
					name = "stone wall", image = "terrain/granite_wall1.png",
					kr_name = "암석의 벽",
					display = '#', color_r=255, color_g=255, color_b=255, back_color=colors.GREY,
					desc = "소환된 암석 벽", 
					type = "wall", --subtype = "floor",
					always_remember = true,
					can_pass = {pass_wall=1},
					does_block_move = true,
					show_tooltip = true,
					block_move = true,
					block_sight = true,
					temporary = t.getDuration(self, t),
					x = x + i, y = y + j,
					canAct = false,
					act = function(self)
						self:useEnergy()
						self.temporary = self.temporary - 1
						if self.temporary <= 0 then
							game.level.map(self.x, self.y, engine.Map.TERRAIN, self.old_feat)
							game.nicer_tiles:updateAround(game.level, self.x, self.y)
							game.level:removeEntity(self)
--							game.level.map:redisplay()
						end
					end,
					dig = function(src, x, y, old)
						game.level:removeEntity(old)
--						game.level.map:redisplay()
						return nil, old.old_feat
					end,
					summoner_gain_exp = true,
					summoner = self,
				}
				e.tooltip = mod.class.Grid.tooltip
				game.level:addEntity(e)
				game.level.map(x + i, y + j, Map.TERRAIN, e)
			end
		end end end

		game:playSoundNear(self, "talents/earth")
		return true
	end,
	info = function(self, t)
		local duration = t.getDuration(self, t)
		local damage = t.getDamage(self, t)
		return ([[시전자 주변에 암석의 벽을 %d 턴 동안 만들어, 시전자를 보호합니다.
		기술 레벨이 4 이상이면, 암석의 벽을 원하는 곳에 만들어낼 수 있습니다.
		암석의 벽을 만들 때, 범위 내에 있는 적들에게는 %0.2f 물리 피해를 줄 수 있습니다.
		벽의 유지시간과 피해량은 주문력의 영향을 받아 증가합니다.]]):
		format(duration, damDesc(self, DamageType.PHYSICAL, damage))
	end,
}
