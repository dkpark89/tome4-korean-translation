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
	name = "Skate",
	kr_name = "스케이트",
	type = {"psionic/augmented-mobility", 1},
	require = psi_wil_req1,
	points = 5,
	mode = "sustained",
	cooldown = 0,
	sustain_psi = 10,
	no_energy = true,
	tactical = { BUFF = 2 },
	getSpeed = function(self, t) return self:combatTalentScale(t, 0.2, 0.5, 0.75) end,
	getKBVulnerable = function(self, t) return self:combatTalentLimit(t, 1, 0.2, 0.8) end,
	activate = function(self, t)
		return {
			speed = self:addTemporaryValue("movement_speed", t.getSpeed(self, t)),
			knockback = self:addTemporaryValue("knockback_immune", -t.getKBVulnerable(self, t))
		}
	end,
	deactivate = function(self, t, p)
		self:removeTemporaryValue("movement_speed", p.speed)
		self:removeTemporaryValue("knockback_immune", p.knockback)
		return true
	end,
	info = function(self, t)
		return ([[염력을 사용해서 지면 위로 살짝 날아오릅니다.
		이를 통해 지면을 미끄러지듯 신속하게 움직일 수 있게 되어, 이동 속도가 %d%% 증가하게 됩니다.
		하지만 날아다니기 때문에, 보다 쉽게 밀려나게 됩니다. (밀어내기 면역력 -%d%%)]]): 
		format(t.getSpeed(self, t)*100, t.getKBVulnerable(self, t)*100) 
	end,
}

newTalent{
	name = "Quick as Thought",
	kr_name = "생각의 속도",
	type = {"psionic/augmented-mobility", 2},
	require = psi_wil_req2,
	points = 5,
	random_ego = "utility",
	cooldown = 20,
	psi = 30,
	no_energy = true,
	getDuration = function(self, t) return math.floor(self:combatLimit(self:combatMindpower(0.1), 10, 4, 0, 6, 6)) end, -- Limit < 10
	speed = function(self, t) return self:combatTalentScale(t, 0.1, 0.4, 0.75) end,
	getBoost = function(self, t)
		return self:combatScale(self:combatTalentMindDamage(t, 20, 60), 0, 0, 50, 100, 0.75)
	end,
	action = function(self, t)
		self:setEffect(self.EFF_QUICKNESS, t.getDuration(self, t), {power=t.speed(self, t)})
		self:setEffect(self.EFF_CONTROL, t.getDuration(self, t), {power=t.getBoost(self, t)})
		return true
	end,
	info = function(self, t)
		local inc = t.speed(self, t)
		local percentinc = 100 * inc
		local boost = t.getBoost(self, t)
		return ([[육체를 정신력으로 감싸, 신경과 근육을 통한 비효율적인 운동 방식을 제거하고 몸의 움직임을 극도로 효율적이게 만듭니다. 
		%d 턴 동안 정확도가 %d / 치명타율이 %0.1f%% / 전체 속도가 %d%% 증가합니다.
		기술의 지속 시간은 정신력의 영향을 받아 증가합니다.]]): 
		format(t.getDuration(self, t), boost, 0.5*boost, percentinc) --@ 변수 순서 조정
	end,
}

newTalent{
	name = "Mindhook",
	type = {"psionic/augmented-mobility", 3},
	require = psi_wil_req3,
	cooldown = function(self, t) return math.ceil(self:combatTalentLimit(t, 5, 18, 10)) end, -- Limit to >5
	psi = 10,
	points = 5,
	tactical = { CLOSEIN = 2 },
	range = function(self, t) return self:combatTalentLimit(t, 10, 3, 7) end, -- Limit base range to 10
	action = function(self, t)
		local tg = {type="bolt", range=self:getTalentRange(t)}
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		local _ _, x, y = self:canProject(tg, x, y)
		local target = game.level.map(x, y, engine.Map.ACTOR)
		if not target then
			game.logPlayer(self, "대상이 사거리 밖에 있습니다.")
			return
		end
		target:pull(self.x, self.y, tg.range)
		target:setEffect(target.EFF_DAZED, 1, {apply_power=self:combatMindpower()})
		game:playSoundNear(self, "talents/arcane")

		return true
	end,
	info = function(self, t)
		local range = self:getTalentRange(t)
		return ([[염력으로 대상을 붙잡아, 시전자가 있는 곳으로 끌어옵니다.
		%d 칸 이내에 있는 대상까지 끌어올 수 있습니다.
		기술 레벨이 증가할수록 재사용 대기시간이 줄어들고 최대 사거리가 늘어납니다.]]):
		format(range)
	end,
}

newTalent{
	name = "Telekinetic Leap",
	type = {"psionic/augmented-mobility", 4},
	require = psi_wil_req4,
	cooldown = 15,
	psi = 10,
	points = 5,
	tactical = { CLOSEIN = 2 },
	range = function(self, t)
		return math.floor(self:combatTalentLimit(t, 10, 2, 7.5)) -- Limit < 10
	end,
	action = function(self, t)
		local tg = {default_target=self, type="ball", nolock=true, pass_terrain=false, nowarning=true, range=self:getTalentRange(t), radius=0, requires_knowledge=false}
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		local _ _, x, y = self:canProject(tg, x, y)
		if not x or not y then return nil end

		local fx, fy = util.findFreeGrid(x, y, 5, true, {[Map.ACTOR]=true})
		if not fx then
			return
		end
		self:move(fx, fy, true)

		return true
	end,
	info = function(self, t)
		local range = self:getTalentRange(t)
		return ([[염동력을 이용해, 최대 %d 칸 까지 도약합니다.]]):
		format(range)
	end,
}
