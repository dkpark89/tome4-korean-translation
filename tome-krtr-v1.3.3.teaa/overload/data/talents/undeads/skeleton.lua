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
	name = "Skeleton",
	kr_name = "스켈레톤",
	type = {"undead/skeleton", 1},
	mode = "passive",
	require = undeads_req1,
	points = 5,
	statBonus = function(self, t) return math.ceil(self:combatTalentScale(t, 2, 10, 0.75)) end,
	passives = function(self, t, p)
		self:talentTemporaryValue(p, "inc_stats", {[self.STAT_STR]=t.statBonus(self, t)})
		self:talentTemporaryValue(p, "inc_stats", {[self.STAT_DEX]=t.statBonus(self, t)})
	end,
	info = function(self, t)
		return ([[골격 상태를 개선하여, 힘과 민첩 능력치를 각각 %d 만큼 증가시킵니다.]]):
		format(t.statBonus(self, t))
	end,
}

newTalent{
	name = "Bone Armour",
	kr_name = "해골 갑옷",
	type = {"undead/skeleton", 2},
	require = undeads_req2,
	points = 5,
	cooldown = 30,
	tactical = { DEFEND = 2 },
	getShield = function(self, t)
		return 3.5*self:getDex()+self:combatTalentScale(t, 120, 400) + self:combatTalentLimit(t, 0.1, 0.01, 0.05)*self.max_life
	end,

	action = function(self, t)
		self:setEffect(self.EFF_DAMAGE_SHIELD, 10, {color={0xcb/255, 0xcb/255, 0xcb/255}, power=t.getShield(self, t)})
		return true
	end,
	info = function(self, t)
		return ([[해골 갑옷을 만들어 피해를 %d 만큼 흡수합니다. 이 효과는 10 턴 동안 유지됩니다.
		해골 갑옷이 흡수할 수 있는 최대 피해량은 민첩 능력치의 영향을 받아 증가합니다.]]):
		format(t.getShield(self, t))
	end,
}

newTalent{
	name = "Resilient Bones",
	kr_name = "재생하는 뼈",
	type = {"undead/skeleton", 3},
	require = undeads_req3,
	points = 5,
	mode = "passive",
	range = 1,
	-- called by _M:on_set_temporary_effect function in mod.class.Actor.lua
	durresist = function(self, t) return self:combatTalentLimit(t, 1, 0.1, 5/12) end, -- Limit < 100%
	info = function(self, t)
		return ([[죽음을 거스른 자의 뼈는 회복력이 뛰어나기 때문에, 모든 나쁜 상태효과의 지속시간을 최대 %d%% 까지 줄여줍니다.]]):
		format(100 * t.durresist(self, t))
	end,
}

newTalent{ short_name = "SKELETON_REASSEMBLE",
	name = "Re-assemble",
	kr_name = "재조합",
	type = {"undead/skeleton",4},
	require = undeads_req4,
	points = 5,
	cooldown = function(self, t) return math.ceil(self:combatTalentLimit(t, 10, 41, 25)) end, -- Limit cooldown >10
	getHeal = function(self, t)
		return self:combatTalentScale(t, 100, 500) + self:combatTalentLimit(t, 0.1, 0.01, 0.05)*self.max_life
	end,
	tactical = { HEAL = 2 },
	is_heal = true,
	on_learn = function(self, t)
		if self:getTalentLevelRaw(t) == 5 then
			self:attr("self_resurrect", 1)
		end
	end,
	on_unlearn = function(self, t)
		if self:getTalentLevelRaw(t) == 4 then
			self:attr("self_resurrect", -1)
		end
	end,
	action = function(self, t)
		self:attr("allow_on_heal", 1)
		self:heal(t.getHeal(self, t), t)
		self:attr("allow_on_heal", -1)
		if core.shader.active(4) then
			self:addParticles(Particles.new("shader_shield_temp", 1, {toback=true , size_factor=1.5, y=-0.3, img="healdark", life=25}, {type="healing", time_factor=6000, beamsCount=15, noup=2.0, beamColor1={0xcb/255, 0xcb/255, 0xcb/255, 1}, beamColor2={0x35/255, 0x35/255, 0x35/255, 1}}))
			self:addParticles(Particles.new("shader_shield_temp", 1, {toback=false, size_factor=1.5, y=-0.3, img="healdark", life=25}, {type="healing", time_factor=6000, beamsCount=15, noup=1.0, beamColor1={0xcb/255, 0xcb/255, 0xcb/255, 1}, beamColor2={0x35/255, 0x35/255, 0x35/255, 1}}))
		end
		game:playSoundNear(self, "talents/heal")
		return true
	end,
	info = function(self, t)
		return ([[뼈의 위치를 조금씩 조정하여, 생명력을 %d 만큼 회복합니다.
		기술 레벨이 5 가 되면, 파괴된 뼈의 완전한 재조합이 가능해집니다. (사망시 부활할 수 있으며, 한 번만 사용할 수 있습니다)]]):
		format(t.getHeal(self, t))
	end,
}
