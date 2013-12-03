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

require "engine.krtrUtils"

newTalent{
	name = "Bone Spear",
	kr_name = "뼈의 창",
	type = {"corruption/bone", 1},
	require = corrs_req1,
	points = 5,
	vim = 13,
	cooldown = 4,
	range = 10,
	random_ego = "attack",
	tactical = { ATTACK = {PHYSICAL = 2} },
	direct_hit = true,
	requires_target = true,
	target = function(self, t)
		return {type="beam", range=self:getTalentRange(t), talent=t}
	end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		self:project(tg, x, y, DamageType.PHYSICAL, self:spellCrit(self:combatTalentSpellDamage(t, 20, 200)), {type="bones"})
		game:playSoundNear(self, "talents/arcane")
		return true
	end,
	info = function(self, t)
		return ([[뼈로 창을 만들어, 발사 궤도 상의 모든 적들에게 %0.2f 물리 피해를 줍니다.
		피해량은 주문력의 영향을 받아 증가합니다.]]):format(damDesc(self, DamageType.PHYSICAL, self:combatTalentSpellDamage(t, 20, 200)))
	end,
}

newTalent{
	name = "Bone Grab",
	kr_name = "뼈의 속박",
	type = {"corruption/bone", 2},
	require = corrs_req2,
	points = 5,
	vim = 28,
	cooldown = 15,
	range = 7,
	tactical = { DISABLE = 1, CLOSEIN = 3 },
	requires_target = true,
	getDuration = function(self, t) return math.floor(self:combatTalentScale(t, 4, 8)) end,
	action = function(self, t)
		local tg = {type="bolt", range=self:getTalentRange(t), talent=t}
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end

		local dam = self:spellCrit(self:combatTalentSpellDamage(t, 5, 140))

		self:project(tg, x, y, function(px, py)
			local target = game.level.map(px, py, engine.Map.ACTOR)
			if not target then return end

			target:pull(self.x, self.y, tg.range)

			DamageType:get(DamageType.PHYSICAL).projector(self, target.x, target.y, DamageType.PHYSICAL, dam)
			if target:canBe("pin") then
				target:setEffect(target.EFF_PINNED, t.getDuration(self, t), {apply_power=self:combatSpellpower()})
			else
				game.logSeen(target, "%s 뼈의 속박을 저항했습니다!", (target.kr_name or target.name):capitalize():addJosa("가"))
			end
		end)
		game:playSoundNear(self, "talents/arcane")

		return true
	end,
	info = function(self, t)
		return ([[대상을 붙잡아 시전자의 근처로 순간이동시킨 뒤, 발 밑에 뼈를 솟아나오게 하여 대상을 %d 턴 동안 속박하고 %0.2f 물리 피해를 줍니다.
		피해량은 주문력의 영향을 받아 증가합니다.]]):
		format(t.getDuration(self, t), damDesc(self, DamageType.PHYSICAL, self:combatTalentSpellDamage(t, 5, 140)))
	end,
}

newTalent{
	name = "Bone Nova",
	kr_name = "뼈의 파동",
	type = {"corruption/bone", 3},
	require = corrs_req3,
	points = 5,
	vim = 25,
	cooldown = 12,
	tactical = { ATTACKAREA = {PHYSICAL = 2} },
	random_ego = "attack",
	radius = function(self, t) return math.floor(self:combatTalentScale(t, 1, 5)) end,
	target = function(self, t)
		return {type="ball", radius=self:getTalentRadius(t), selffire=false, talent=t}
	end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		self:project(tg, self.x, self.y, DamageType.PHYSICAL, self:spellCrit(self:combatTalentSpellDamage(t, 8, 180)), {type="bones"})
		game:playSoundNear(self, "talents/arcane")
		return true
	end,
	info = function(self, t)
		return ([[뼈의 창을 모든 방향에 동시에 발사하여, 주변 %d 칸 반경의 적들에게 %0.2f 물리 피해를 줍니다.
		피해량은 주문력의 영향을 받아 증가합니다.]]):format(self:getTalentRadius(t), damDesc(self, DamageType.PHYSICAL, self:combatTalentSpellDamage(t, 8, 180)))
	end,
}

newTalent{
	name = "Bone Shield",
	kr_name = "뼈의 방패",
	type = {"corruption/bone", 4},
	points = 5,
	mode = "sustained", no_sustain_autoreset = true,
	require = corrs_req4,
	cooldown = 30,
	sustain_vim = 50,
	tactical = { DEFEND = 4 },
	direct_hit = true,
	getNb = function(self, t) return math.floor(self:combatTalentScale(t, 1, 5)) end,
	getRegen = function(self, t) return math.max(math.floor(30 / t.getNb(self, t)), 3) end,
	callbackOnRest = function(self, t)
		local nb = t.getNb(self, t)
		local p = self.sustain_talents[t.id]
		if not p or #p.particles < nb then return true end
	end,
	callbackOnActBase = function(self, t)
		local p = self.sustain_talents[t.id]
		p.next_regen = (p.next_regen or 1) - 1
		if p.next_regen <= 0 then
			p.next_regen = p.between_regens or 10

			if #p.particles < t.getNb(self, t) then
				p.particles[#p.particles+1] = self:addParticles(Particles.new("bone_shield", 1))
				game.logSeen(self, "A part of %s's bone shield regenerates.", self.name)
			end
		end
	end,
	absorb = function(self, t, p)
		local pid = table.remove(p.particles)
		if pid then
			game.logPlayer(self, "뼈의 방패가 피해를 흡수했습니다!")
			self:removeParticles(pid)
		end
		return pid
	end,
	activate = function(self, t)
		local nb = t.getNb(self, t)

		local ps = {}
		for i = 1, nb do ps[#ps+1] = self:addParticles(Particles.new("bone_shield", 1)) end

		game:playSoundNear(self, "talents/spell_generic2")
		return {
			particles = ps,
			next_regen = t.getRegen(self, t),
			between_regens = t.getRegen(self, t),
		}
	end,
	deactivate = function(self, t, p)
		for i, particle in ipairs(p.particles) do self:removeParticles(particle) end
		return true
	end,
	info = function(self, t)
		return ([[뼈의 방패가 시전자 주변을 돌면서, 공격을 완전히 막아냅니다.
		하나의 방패는 한 번의 공격을 막아내며, 처음 주문을 시전하면 %d 개의 방패가 생겨납니다.
		이후 방패의 개수가 줄어들었을 경우, %d 턴 마다 하나씩 방패가 재생됩니다.]]): 
		format(t.getNb(self, t), t.getRegen(self, t))
	end,
}
