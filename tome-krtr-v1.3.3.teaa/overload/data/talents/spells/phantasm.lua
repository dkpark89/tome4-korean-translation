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

newTalent{
	name = "Illuminate",
	kr_name = "광원",
	type = {"spell/phantasm",1},
	require = spells_req1,
	random_ego = "utility",
	points = 5,
	mana = 5,
	cooldown = 14,
	range = 0,
	radius = function(self, t) return math.floor(self:combatTalentScale(t, 6, 10)) end,
	tactical = { DISABLE = function(self, t)
			if self:getTalentLevel(t) >= 3 then
				return 2
			end
			return 0
		end,
		ATTACKAREA = function(self, t)
			if self:getTalentLevel(t) >= 4 then
				return { LIGHT = 2 }
			end
			return 0
		end,
	},
	getDamage = function(self, t) return self:combatTalentSpellDamage(t, 28, 180) end,
	getBlindPower = function(self, t) if self:getTalentLevel(t) >= 5 then return 4 else return 3 end end,
	requires_target = true,
	action = function(self, t)
		local tg = {type="ball", range=self:getTalentRange(t), selffire=true, radius=self:getTalentRadius(t), talent=t}
		self:project(tg, self.x, self.y, DamageType.LITE, 1)
		game.level.map:particleEmitter(self.x, self.y, tg.radius, "sunburst", {radius=tg.radius, grids=grids, tx=self.x, ty=self.y, max_alpha=80})
		if self:getTalentLevel(t) >= 3 then
			tg.selffire= false
			self:project(tg, self.x, self.y, DamageType.BLIND, t.getBlindPower(self, t))
		end
		if self:getTalentLevel(t) >= 4 then
			tg.selffire= false
			self:project(tg, self.x, self.y, DamageType.LIGHT, self:spellCrit(t.getDamage(self, t)))
		end
		game:playSoundNear(self, "talents/heal")
		return true
	end,
	info = function(self, t)
		local radius = self:getTalentRadius(t)
		local turn = t.getBlindPower(self, t)
		local dam = t.getDamage(self, t)
		return ([[순수한 빛의 구를 만들어내, 주변 %d 칸 반경을 밝게 비춥니다.
		기술 레벨이 3 이상이면, %d 턴 동안 적들을 실명시킬 수 있습니다.
		기술 레벨이 4 이상이면, 적들에게 추가로 %0.2f 빛 피해를 줍니다.]]):
		format(radius, turn, damDesc(self, DamageType.LIGHT, dam))
	end,
}

newTalent{
	name = "Blur Sight",
	kr_name = "신기루",
	type = {"spell/phantasm", 2},
	mode = "sustained",
	require = spells_req2,
	points = 5,
	sustain_mana = 30,
	cooldown = 10,
	tactical = { BUFF = 2 },
	getDefense = function(self, t) return self:combatScale(self:getTalentLevel(t)*self:combatSpellpower(), 0, 0, 28.6, 267, 0.75) end,
	activate = function(self, t)
		game:playSoundNear(self, "talents/heal")
		return {
			particle = self:addParticles(Particles.new("phantasm_shield", 1)),
			def = self:addTemporaryValue("combat_def", t.getDefense(self, t)),
		}
	end,
	deactivate = function(self, t, p)
		self:removeParticles(p.particle)
		self:removeTemporaryValue("combat_def", p.def)
		return true
	end,
	info = function(self, t)
		local defence = t.getDefense(self, t)
		return ([[시전자의 형상이 희미해져, 회피도가 %d 상승합니다.
		회피도 상승량은 주문력의 영향을 받아 상승합니다.]]):
		format(defence)
	end,
}

newTalent{
	name = "Phantasmal Shield",
	kr_name = "환영의 보호막",
	type = {"spell/phantasm", 3},
	mode = "sustained",
	require = spells_req3,
	points = 5,
	sustain_mana = 20,
	cooldown = 10,
	tactical = { BUFF = 2 },
	getDamage = function(self, t) return self:combatTalentSpellDamage(t, 20, 120) end,
	activate = function(self, t)
		game:playSoundNear(self, "talents/heal")
		return {
			particle = self:addParticles(Particles.new("phantasm_shield", 1)),
			onhit = self:addTemporaryValue("on_melee_hit", {[DamageType.LIGHT]=t.getDamage(self, t)}),
		}
	end,
	deactivate = function(self, t, p)
		self:removeParticles(p.particle)
		self:removeTemporaryValue("on_melee_hit", p.onhit)
		return true
	end,
	info = function(self, t)
		local damage = t.getDamage(self, t)
		return ([[시전자 주변에 환영의 보호막이 만들어집니다. 근접 공격을 받을 때마다, 환영의 보호막은 적에게 %d 빛 피해를 되돌려줍니다.
		피해량은 주문력의 영향을 받아 상승합니다.]]):
		format(damDesc(self, DamageType.LIGHT, damage))
	end,
}

newTalent{
	name = "Invisibility",
	kr_name = "투명화",
	type = {"spell/phantasm", 4},
	mode = "sustained",
	require = spells_req4,
	points = 5,
	sustain_mana = 150,
	cooldown = 30,
	tactical = { ESCAPE = 2, DEFEND = 2 },
	getInvisibilityPower = function(self, t) return self:combatTalentSpellDamage(t, 10, 50) end,
	activate = function(self, t)
		game:playSoundNear(self, "talents/heal")
		local ret = {
			invisible = self:addTemporaryValue("invisible", t.getInvisibilityPower(self, t)),
			invisible_damage_penalty = self:addTemporaryValue("invisible_damage_penalty", 0.7),
			drain = self:addTemporaryValue("mana_regen", -2),
		}
		if not self.shader then
			ret.set_shader = true
			self.shader = "invis_edge"
			self:removeAllMOs()
			game.level.map:updateMap(self.x, self.y)
		end
		self:resetCanSeeCacheOf()
		return ret
	end,
	deactivate = function(self, t, p)
		if p.set_shader then
			self.shader = nil
			self:removeAllMOs()
			game.level.map:updateMap(self.x, self.y)
		end
		self:removeTemporaryValue("invisible", p.invisible)
		self:removeTemporaryValue("invisible_damage_penalty", p.invisible_damage_penalty)
		self:removeTemporaryValue("mana_regen", p.drain)
		self:resetCanSeeCacheOf()
		return true
	end,
	info = function(self, t)
		local invisi = t.getInvisibilityPower(self, t)
		return ([[시전자가 적들의 시야에서 사라져, 투명 수치가 %d 상승합니다.
		투명화 중에는 현실 세계에서의 존재감이 옅어져, 적을 공격해도 원래 피해의 70%% 밖에 주지 못하게 됩니다.
		투명화 중에는 매 턴마다 마나가 2 씩 소진되며, 투명화 중에 등불 따위를 들고 있으면 투명화를 한 의미가 사실상 없어지게 됩니다.
		투명 수치는 주문력의 영향을 받아 상승합니다.]]):
		format(invisi)
	end,
}
