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

local Object = require "engine.Object"

newTalent{
	name = "Stone Skin",
	kr_display_name = "단단한 피부",
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
		return {
			armor = self:addTemporaryValue("combat_armor", t.getArmor(self, t)),
			particle = self:addParticles(Particles.new("stone_skin", 1)),
		}
	end,
	deactivate = function(self, t, p)
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
	name = "Mudslide",
	kr_display_name = "산사태",
        type = {"spell/earth",2},
	require = spells_req2,
	points = 5,
	random_ego = "attack",
	mana = 40,
	cooldown = 12,
	direct_hit = true,
	tactical = { ATTACKAREA = { PHYSICAL = 2 }, DISABLE = { knockback = 2 }, ESCAPE = { knockback = 1 } },
	range = 0,
	radius = function(self, t) return 3 + self:getTalentLevelRaw(t) end,
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
		return ([[소규모 산사태를 만들어내, 주변 %d 칸 반경에 %0.2f 물리 피해를 줍니다. 산사태에 휩쓸린 적들은 밀려납니다.
		피해량은 주문력의 영향을 받아 증가합니다.]]):
		format(self:getTalentRadius(t), damDesc(self, DamageType.PHYSICAL, damage))
	end,
}

newTalent{
	name = "Dig",
	kr_display_name = "굴착",
	type = {"spell/earth",3},
	require = spells_req3,
	points = 5,
	random_ego = "utility",
	mana = 40,
	range = 10,
	reflectable = true,
	requires_target = true,
	no_npc_use = true,
	getRange = function(self, t) return self:getTalentLevelRaw(t) end,
	action = function(self, t)
		local tg = {type="bolt", range=self:getTalentRange(t), nolock=true, talent=t, display={particle="bolt_earth", trail="earthtrail"}}
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		for i = 1, t.getRange(self, t) do
			self:project(tg, x, y, DamageType.DIG, 1)
		end
		game:playSoundNear(self, "talents/earth")
		return true
	end,
	info = function(self, t)
		local range = t.getRange(self, t)
		return ([[벽, 나무 등 이동할 수 없는 지형을 %d 칸 굴착합니다.]]):
		format(range)
	end,
}

newTalent{
	name = "Stone Wall",
	kr_display_name = "이동식 요새",
	type = {"spell/earth",4},
	require = spells_req4,
	points = 5,
	cooldown = 50,
	mana = 70,
	range = 7,
	tactical = { DISABLE = 4, DEFEND = 3, PROTECT = 3, ESCAPE = 1 },
	reflectable = true,
	requires_target = function(self, t) return self:getTalentLevel(t) >= 4 end,
	getDuration = function(self, t) return 2 + self:combatTalentSpellDamage(t, 5, 12) end,
	action = function(self, t)
		local x, y = self.x, self.y
		if self:getTalentLevel(t) >= 4 then
			local tg = {type="bolt", nowarning=true, range=self:getTalentRange(t), nolock=true, talent=t}
			x, y = self:getTarget(tg)
			if not x or not y then return nil end
		end

		for i = -1, 1 do for j = -1, 1 do if game.level.map:isBound(x + i, y + j) then
			local oe = game.level.map(x + i, y + j, Map.TERRAIN)
			if oe and not oe:attr("temporary") and not game.level.map:checkAllEntities(x + i, y + j, "block_move") and not oe.special then
				-- Ok some explanation, we make a new *OBJECT* because objects can have energy and act
				-- it stores the current terrain in "old_feat" and restores it when it expires
				-- We CAN set an object as a terrain because they are all entities

				local e = Object.new{
					old_feat = oe,
					name = "summoned wall", image = "terrain/granite_wall1.png",
					kr_display_name = "소환된 벽",
					display = '#', color_r=255, color_g=255, color_b=255, back_color=colors.GREY,
					always_remember = true,
					can_pass = {pass_wall=1},
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
				game.level:addEntity(e)
				game.level.map(x + i, y + j, Map.TERRAIN, e)
			end
		end end end

		game:playSoundNear(self, "talents/earth")
		return true
	end,
	info = function(self, t)
		local duration = t.getDuration(self, t)
		return ([[시전자 주변에 암석 벽을 %d 턴 동안 만들어, 시전자를 보호합니다.
		기술 레벨이 4 이상이면, 암석 벽을 원하는 곳에 만들어낼 수 있습니다.
		마법의 지속시간은 주문력의 영향을 받아 증가합니다.]]):
		format(duration)
	end,
}
