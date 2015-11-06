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
	name = "Celerity",
	kr_name = "민첩함",
	type = {"chronomancy/speed-control", 1},
	require = chrono_req1,
	points = 5,
	mode = "passive",
	getSpeed = function(self, t) return self:combatTalentScale(t, 10, 30)/100 end,
	getDuration = function(self, t) return getExtensionModifier(self, t, math.floor(self:combatTalentScale(t, 1, 2))) end,
	callbackOnMove = function(self, t, moved, force, ox, oy)
		if moved and not force and ox and oy and (ox ~= self.x or oy ~= self.y) then
			if self.turn_procs.celerity then return end
			local speed = t.getSpeed(self, t)
			self:setEffect(self.EFF_CELERITY, t.getDuration(self, t), {speed=speed, charges=1, max_charges=3})
			self.turn_procs.celerity = true
		end
	end,
	info = function(self, t)
		local speed = t.getSpeed(self, t) * 100
		local duration = t.getDuration(self, t)
		return ([[당신이 이동하였을 때, %d%% 만큼의 이동 속도를 %d 턴 동안 추가합니다. 이 효과는 세 번 중첩되지만 한 턴에 한 번만 일어납니다.]]):format(speed, duration)
	end,
}

newTalent{
	name = "Time Dilation",
	kr_name = "시간 확장",
	type = {"chronomancy/speed-control",2},
	require = chrono_req2,
	points = 5,
	mode = "passive",
	getSpeed = function(self, t) return self:combatTalentScale(t, 10, 30)/200 end,
	getDuration = function(self, t) return getExtensionModifier(self, t, math.floor(self:combatTalentScale(t, 1, 2))) end,
	callbackOnTalentPost = function(self, t,  ab)
		if ab.type[1]:find("^chronomancy/") and not ab.no_energy then
			if self.turn_procs.time_dilation then return end
			local speed = t.getSpeed(self, t)
			self:setEffect(self.EFF_TIME_DILATION, t.getDuration(self, t), {speed=speed, charges=1, max_charges=3})
			self.turn_procs.time_dilation = true
		end
	end,
	info = function(self, t)
		local speed = t.getSpeed(self, t) * 100
		local duration = t.getDuration(self, t)
		return ([[당신이 턴을 소모하는 시공 계열 마법을 사용 할 때, %d%% 만큼의 공격, 시전, 사고 속도를 %d 턴간 추가합니다. 이 효과는 세 번 중첩되지만 한 턴에 한 번만 일어납니다.]]):format(speed, duration)
	end,
}

newTalent{
	name = "Haste",
	kr_name = "가속",
	type = {"chronomancy/speed-control", 3},
	require = chrono_req3,
	points = 5,
	paradox = function (self, t) return getParadoxCost(self, t, 20) end,
	cooldown = 24,
	tactical = { BUFF = 2, CLOSEIN = 2, ESCAPE = 2 },
	getSpeed = function(self, t) return self:combatTalentScale(t, 10, 30)/100 end,
	getDuration = function(self, t) return getExtensionModifier(self, t, 6) end,
	no_energy = true,
	action = function(self, t)
		self:setEffect(self.EFF_HASTE, t.getDuration(self, t), {power=t.getSpeed(self, t)})
		
		game:playSoundNear(self, "talents/heal")
		return true
	end,
	info = function(self, t)
		local duration = t.getDuration(self, t)
		local speed = t.getSpeed(self, t) * 100
		return ([[당신의 전체 속도를 %d%% 만큼 %d 게임 턴 동안 늘립니다.]]):format(speed, duration)
	end,
}

newTalent{
	name = "Time Stop",
	kr_name = "시간 정지",
	type = {"chronomancy/speed-control", 4},
	require = chrono_req4,
	points = 5,
	paradox = function (self, t) return getParadoxCost(self, t, 48) end,
	cooldown = function(self, t) return math.ceil(self:combatTalentLimit(t, 10, 45, 25)) end, -- Limit >10
	tactical = { BUFF = 2, CLOSEIN = 2, ESCAPE = 2 },
	no_energy = true,
	no_npc_use = true,
	getReduction = function(self, t) return 100 end,
	getDuration = function(self, t) return getExtensionModifier(self, t, math.floor(self:combatTalentLimit(t, 4, 1, 3))) end,
	action = function(self, t)
		game:onTickEnd(function()
			self.energy.value = self.energy.value + (t.getDuration(self, t) * 1000)
			self:setEffect(self.EFF_TIME_STOP, 1, {power=100})
			
			game.logSeen(self, "#STEEL_BLUE#%s 가 시간을 멈추었다!#LAST#", self.name:capitalize())
			game:playSoundNear(self, "talents/heal")
		end)
		return true
	end,
	info = function(self, t)
		local duration = t.getDuration(self, t)
		local reduction = t.getReduction(self, t)
		return ([[%d 턴을 얻습니다. 이 시간 동안 당신의 모든 피해량은 %d%% 만큼 줄어듭니다.]]):format(duration, reduction)
	end,
}
