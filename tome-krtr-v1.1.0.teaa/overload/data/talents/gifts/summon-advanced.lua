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
	name = "Master Summoner",
	kr_name = "최고의 소환술사",
	type = {"wild-gift/summon-advanced", 1},
	require = gifts_req_high1,
	mode = "sustained",
	points = 5,
	sustain_equilibrium = 20,
	cooldown = 10,
	range = 10,
	tactical = { BUFF = 2 },
	getCooldownReduction = function(self, t) return util.bound(self:getTalentLevelRaw(t) / 15, 0.05, 0.3) end,
	activate = function(self, t)
		game:playSoundNear(self, "talents/heal")
		local particle
		if self:addShaderAura("master_summoner", "awesomeaura", {time_factor=6200, alpha=0.7, flame_scale=0.8}, "particles_images/naturewings.png") then
			--
		elseif core.shader.active(4) then
			particle = self:addParticles(Particles.new("shader_ring_rotating", 1, {radius=1.1}, {type="flames", zoom=2, npow=4, time_factor=4000, color1={0.2,0.7,0,1}, color2={0,1,0.3,1}, hide_center=0, xy={self.x, self.y}}))
		else
			particle = self:addParticles(Particles.new("master_summoner", 1))
		end
		return {
			cd = self:addTemporaryValue("summon_cooldown_reduction", t.getCooldownReduction(self, t)),
			particle = particle,
		}
	end,
	deactivate = function(self, t, p)
		self:removeShaderAura("master_summoner")
		self:removeParticles(p.particle)
		self:removeTemporaryValue("summon_cooldown_reduction", p.cd)
		return true
	end,
	info = function(self, t)
		local cooldownred = t.getCooldownReduction(self, t)
		return ([[모든 소환술의 재사용 대기시간이 %d%% 줄어듭니다.]]):
		format(cooldownred * 100)
	end,
}

newTalent{
	name = "Grand Arrival",
	kr_name = "웅대한 도달",
	type = {"wild-gift/summon-advanced", 2},
	require = gifts_req_high2,
	points = 5,
	mode = "passive",
	radius = function(self, t) return math.floor(self:combatTalentScale(t, 1.3, 3.7, "log")) end,
	effectDuration = function(self, t) return math.floor(self:combatTalentScale(t, 5, 9)) end,
	nbEscorts = function(self, t) return math.max(1,math.floor(self:combatTalentScale(t, 0.3, 2.7, "log"))) end,
	info = function(self, t)
		local radius = self:getTalentRadius(t)
		return ([['최고의 소환술사' 기술이 유지되는 동안, 소환수 주변에 특수한 효과가 나타나게 됩니다.
		- 불꽃뿜는 리치 : 적들의 화염 저항력을 감소시킵니다.
		- 히드라 : 독구름을 만들어냅니다.
		- 서리나무 : 적들의 냉기 저항력을 감소시킵니다.
		- 화염 드레이크 : 어린 화염 드레이크가 %d 마리 더 나타납니다.
		- 전투견 : 적들의 물리 저항력을 감소시킵니다.
		- 젤리 : 적들의 자연 저항력을 감소시킵니다.
		- 미노타우르스 : 적들의 이동속도를 감소시킵니다.
		- 암석 골렘 : 적들을 혼절시킵니다.
		- 거북이 : 아군을 회복시켜줍니다.
		- 거미 : 적들이 근처에 오지 않으려 하게 됩니다.
		기술의 효과는 의지 능력치의 영향을 받아 증가합니다.
		Radius for effects is %d, and the duration of each lasting effect is %d turns.
		The effects improve with your Willpower.]]):format(t.nbEscorts(self, t), radius, t.effectDuration(self, t)) --@@ 한글화 필요 : 윗줄~현재줄
	end,
}

newTalent{
	name = "Nature's Cycle", short_name = "NATURE_CYCLE",
	kr_name = "자연의 주기",
	type = {"wild-gift/summon-advanced", 3},
	require = gifts_req_high3,
	mode = "passive",
	points = 5,
	getChance = function(self, t) return math.min(100, 30 + self:getTalentLevel(t) * 15) end,
	getReduction = function(self, t) return math.floor(self:combatTalentLimit(t, 5, 1, 3.1)) end, -- Limit < 5
	info = function(self, t)
		return ([['최고의 소환술사' 기술이 유지되는 동안, 소환을 할 때마다 %d%% 확률로 분노, 소환수 폭발, 야생의 소환수 기술의 재사용 대기시간이 %d 턴 줄어들게 됩니다.]]):format(t.getChance(self, t), t.getReduction(self, t))
	end,
}

newTalent{
	name = "Wild Summon",
	kr_name = "야생의 소환수",
	type = {"wild-gift/summon-advanced", 4},
	require = gifts_req_high4,
	points = 5,
	equilibrium = 9,
	cooldown = 25,
	range = 10,
	tactical = { BUFF = 5 },
	no_energy = true,
	on_pre_use = function(self, t, silent)
		return self:isTalentActive(self.T_MASTER_SUMMONER)
	end,
	duration = function(self, t) return  math.floor(self:combatTalentLimit(t, 25, 1, 5)) end, -- Limit <25
	action = function(self, t)
		self:setEffect(self.EFF_WILD_SUMMON, t.duration(self,t), {chance=100})
		game:playSoundNear(self, "talents/teleport")
		return true
	end,
	info = function(self, t)
		return ([[%d 턴 동안, 100%% 확률로 야생의 소환수를 소환합니다.
		시간이 지날수록 이 확률은 점차 감소합니다.
		야생의 소환수는 일반 소환수보다 하나 더 많은 기술을 가지고 있습니다.
		- 불꽃뿜는 리치 : 화염 폭발을 일으켜, 적들을 밀어냅니다.
		- 히드라 : 근접전이 벌어지면 후퇴합니다.
		- 서리나무 : 마법 저항력이 증가합니다.
		- 화염 드레이크 : 강렬한 외침으로 적들을 침묵시킵니다.
		- 전투견 : 분노하여 치명타율과 방어도 관통력을 증가시킵니다.
		- 젤리 : 빈사 상태의 적을 집어삼키고, 이를 통해 평정을 회복합니다.
		- 미노타우르스 : 적에게 돌진합니다.
		- 암석 골렘 : 근접공격이 주변에까지 피해를 줍니다.
		- 거북이 : 적들을 자기 옆으로 불러들입니다.
		- 거미 : 적에게 독을 뱉어 생명력 회복 효율을 감소시킵니다.
		이 기술은 '최고의 소환술사' 기술이 유지되는 동안에만 사용할 수 있습니다.]]):format(t.duration(self,t))
	end,
}
