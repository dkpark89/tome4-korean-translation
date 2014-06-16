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

local isFF = function(self)
	if self:getTalentLevel(self.T_INVOKE_DARKNESS) >= 5 then return false
	else return true
	end
end

newTalent{
	name = "Invoke Darkness",
	kr_name = "어둠 화살",
	type = {"spell/nightfall",1},
	require = spells_req1,
	points = 5,
	random_ego = "attack",
	mana = 12,
	cooldown = 4,
	tactical = { ATTACK = { DARKNESS = 2 } },
	range = 10,
	reflectable = true,
	proj_speed = 20,
	requires_target = true,
	direct_hit = function(self, t) if self:getTalentLevel(t) >= 3 then return true else return false end end,
	target = function(self, t)
		local tg = {type="bolt", range=self:getTalentRange(t), friendlyfire=isFF(self), talent=t, display={particle="bolt_dark", trail="darktrail"}}
		if self:getTalentLevel(t) >= 3 then tg.type = "beam" end
		if necroEssenceDead(self, true) then tg.radius, tg.range = tg.range, 0 tg.type = "cone" tg.cone_angle = 25 end
		return tg
	end,
	getDamage = function(self, t) return self:combatTalentSpellDamage(t, 25, 230) end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		local empower = necroEssenceDead(self)
		if empower then
			self:project(tg, x, y, DamageType.DARKNESS, self:spellCrit(t.getDamage(self, t)))
			game.level.map:particleEmitter(self.x, self.y, tg.radius, "breath_shadow", {radius=tg.radius, tx=x-self.x, ty=y-self.y, spread=20})
			empower()
		elseif self:getTalentLevel(t) < 3 then
			self:projectile(tg, x, y, DamageType.DARKNESS, self:spellCrit(t.getDamage(self, t)), function(self, tg, x, y, grids)
				game.level.map:particleEmitter(x, y, 1, "dark")
			end)
		else
			self:project(tg, x, y, DamageType.DARKNESS, self:spellCrit(t.getDamage(self, t)))
			local _ _, x, y = self:canProject(tg, x, y)
			game.level.map:particleEmitter(self.x, self.y, tg.radius, "shadow_beam", {tx=x-self.x, ty=y-self.y})
		end

		game:playSoundNear(self, "talents/spell_generic")
		return true
	end,
	info = function(self, t)
		local damage = t.getDamage(self, t)
		return ([[어둠을 화살의 형태로 만들어, 대상에게 %0.2f 암흑 피해를 줍니다.
		기술 레벨이 3 이상이면, 어둠이 적들을 관통합니다.
		기술 레벨이 5 이상이면, 모든 주문 / 일몰 계열의 마법들이 언데드 추종자들에게 피해를 주지 않게 됩니다.
		피해량은 주문력의 영향을 받아 증가합니다.]]):
		format(damDesc(self, DamageType.DARKNESS, damage))
	end,
}

newTalent{
	name = "Circle of Death",
	kr_name = "죽음의 고리",
	type = {"spell/nightfall",2},
	require = spells_req2,
	points = 5,
	mana = 45,
	cooldown = 18,
	tactical = { ATTACKAREA = { DARKNESS = 2 }, DISABLE = { confusion = 1.5, blind = 1.5 } },
	range = 6,
	radius = 3,
	direct_hit = true,
	requires_target = true,
	target = function(self, t)
		return {type="ball", range=self:getTalentRange(t), radius=self:getTalentRadius(t)}
	end,
	getDamage = function(self, t) return self:combatTalentSpellDamage(t, 15, 40) end,
	getDuration = function(self, t) return 5 end,
	getBaneDur = function(self,t) return math.floor(self:combatTalentScale(t, 4.5, 6.5)) end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		local _ _, _, _, x, y = self:canProject(tg, x, y)
		-- Add a lasting map effect
		game.level.map:addEffect(self,
			x, y, t.getDuration(self, t),
			DamageType.CIRCLE_DEATH, {dam=self:spellCrit(t.getDamage(self, t)), dur=t.getBaneDur(self,t), ff=isFF(self)},
			self:getTalentRadius(t),
			5, nil,
			{type="circle_of_death", overlay_particle={zdepth=6, only_one=true, type="circle", args={oversize=1, a=100, appear=8, speed=-0.05, img="necromantic_circle", radius=self:getTalentRadius(t)}}},
--			{zdepth=6, only_one=true, type="circle", args={oversize=1, a=130, appear=8, speed=-0.03, img="arcane_circle", radius=self:getTalentRadius(t)}},
			nil, false
		)

		game:playSoundNear(self, "talents/fire")
		return true
	end,
	info = function(self, t)
		local damage = t.getDamage(self, t)
		return ([[5 턴 동안 대지에서 어둠의 구름을 불러냅니다. 구름에 들어간 적에게는 혼란의 표식이나 실명의 표식 중 하나가 새겨지며, 해당 상태효과를 일으킵니다.
		표식은 %d 턴 동안 유지되며, 매 턴마다 %0.2f 암흑 피해를 줍니다.
		피해량은 주문력의 영향을 받아 증가합니다.]]):
		format(t.getBaneDur(self,t), damDesc(self, DamageType.DARKNESS, damage))
	end,
}

newTalent{
	name = "Fear the Night",
	kr_name = "밤의 공포",
	type = {"spell/nightfall",3},
	require = spells_req3,
	points = 5,
	random_ego = "attack",
	mana = 40,
	cooldown = 12,
	direct_hit = true,
	tactical = { ATTACKAREA = { DARKNESS = 2 }, DISABLE = { knockback = 2 }, ESCAPE = { knockback = 1 } },
	range = 0,
	radius = function(self, t) return math.floor(self:combatTalentScale(t, 4, 8)) end,
	requires_target = true,
	target = function(self, t) return {type="cone", range=self:getTalentRange(t), radius=self:getTalentRadius(t), friendlyfire=isFF(self), talent=t} end,
	getDamage = function(self, t) return self:combatTalentSpellDamage(t, 10, 230) end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		self:project(tg, x, y, DamageType.DARKKNOCKBACK, {dist=4, dam=self:spellCrit(t.getDamage(self, t))})
		game.level.map:particleEmitter(self.x, self.y, tg.radius, "breath_dark", {radius=tg.radius, tx=x-self.x, ty=y-self.y})
		game:playSoundNear(self, "talents/fire")
		return true
	end,
	info = function(self, t)
		local damage = t.getDamage(self, t)
		local radius = self:getTalentRadius(t)
		return ([[전방 %d 칸 반경에 %0.2f 암흑 피해를 주고, 범위 내의 적들에게 밤의 공포를 심어줍니다. 대상의 정신 내성 능력치에 따라 저항할 확률이 달라지며, 저항에 실패할 경우 대상은 4 칸 뒤로 도망치게 됩니다.
		피해량은 주문력의 영향을 받아 증가합니다.]]):
		format(self:getTalentRadius(t), damDesc(self, DamageType.DARKNESS, damage)) --@ 변수 순서 조정
	end,
}

newTalent{
	name = "Rigor Mortis",
	kr_name = "사후 경직",
	type = {"spell/nightfall",4},
	require = spells_req4,
	points = 5,
	mana = 60,
	cooldown = 20,
	tactical = { ATTACKAREA = 3 },
	range = 7,
	radius = 1,
	direct_hit = true,
	requires_target = true,
	target = function(self, t) return {type="ball", range=self:getTalentRange(t), radius=self:getTalentRadius(t), friendlyfire=isFF(self), talent=t, display={particle="bolt_dark", trail="darktrail"}} end,
	getDamage = function(self, t) return self:combatTalentSpellDamage(t, 28, 280) end,
	getMinion = function(self, t) return 10 + self:combatTalentSpellDamage(t, 10, 30) end,
	getDur = function(self, t) return math.floor(self:combatTalentScale(t, 3.6, 6.3)) end,
	getSpeed = function(self, t) return math.min(self:getTalentLevel(t) * 0.065, 0.5) end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		self:projectile(tg, x, y, DamageType.RIGOR_MORTIS, {dam=self:spellCrit(t.getDamage(self, t)), minion=t.getMinion(self, t), speed=t.getSpeed(self, t), dur=t.getDur(self, t)}, {type="dark"})
		game:playSoundNear(self, "talents/fireflash")
		return true
	end,
	info = function(self, t)
		local damage = t.getDamage(self, t)
		local speed = t.getSpeed(self, t) * 100
		local dur = t.getDur(self, t)
		local minion = t.getMinion(self, t)
		return ([[암흑의 구를 만들어내 주변 %d 칸 반경에 %0.2f 암흑 피해를 주고, %d 턴 동안 적들의 죽음을 앞당겨 전체 속도를 %d%% 감소시킵니다. 
		죽음이 앞당겨진 적들은 언데드 추종자들에게 %d%% 더 많은 피해를 입습니다.
		피해량과 언데드 추종자들의 추가 피해량은 주문력의 영향을 받아 증가합니다.]]):
		format(self:getTalentRadius(t), damDesc(self, DamageType.DARKNESS, damage), dur, speed, minion) --@ 변수 순서 조정
	end,
}
