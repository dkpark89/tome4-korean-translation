-- TE4 - T-Engine 4
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
require "engine.class"

--- Handles activable objects, much more simple than actor's resource
-- It can define simple activations, complex ones that use power and it can also activate talent (ActorTalents interface must also be used on the Object class in this case)
module(..., package.seeall, class.make)

function _M:init(t)
	if t.max_power then
		self.power = t.max_power
		self.max_power = t.max_power
		self.power_regen = t.power_regen or 0
	end
end

--- Regen resources, shout be called in your actor's act() method
function _M:regenPower()
	if self.power_regen then
	self.power = util.bound(self.power + self.power_regen, 0, self.max_power) end
end

function _M:canUseObject()
	if self.use_simple or self.use_power or self.use_talent then
		return true
	end
end

function _M:getUseDesc()
	if self.use_power then
		if self.show_charges then
			return ("%s에 사용 가능 : 사용 가능 횟수 %d / %d."):format((self.use_power.kr_name or self.use_power.name):capitalize(), math.floor(self.power / self.use_power.power), math.floor(self.max_power / self.use_power.power))
		else
			return ("%s에 사용 가능 : 소모력 %d, 현재 보유력 %d / %d."):format((self.use_power.kr_name or self.use_power.name):capitalize(), self.use_power.power, self.power, self.max_power)
		end
	elseif self.use_simple then
		return ("%s 사용 가능"):format((self.use_simple.kr_name or self.use_simple.name):capitalize():addJosa("로"))
	elseif self.use_talent then
		local stn = self:getTalentFromId(self.use_talent.id).kr_name or self:getTalentFromId(self.use_talent.id).name --@@ 세줄뒤, 다섯줄뒤 사용 : 너무 길어져서 변수로 뺌 
		if not self.use_talent.power then
			return ("사용시 기술 발동 : %s (레벨 %d)."):format(stn, self.use_talent.level)
		else
			return ("사용시 기술 발동 : %s (레벨 %d), 소모력 %d, 현재 보유력 %d / %d."):format(stn, self.use_talent.level, self.use_talent.power, self.power, self.max_power)
		end
	end
end

function _M:useObject(who, ...)
	-- Make sure the object is registered with the game, if need be
	if not game:hasEntity(self) then game:addEntity(self) end

	local reduce = 100 - util.bound(who:attr("use_object_cooldown_reduce") or 0, 0, 100)
	local usepower = function(power) return math.ceil(power * reduce / 100) end

	if self.use_power then
		if (self.talent_cooldown and not who:isTalentCoolingDown(self.talent_cooldown)) or (not self.talent_cooldown and self.power >= usepower(self.use_power.power)) then
		
			local ret = self.use_power.use(self, who, ...) or {}
			local no_power = not ret.used or ret.no_power
			if not no_power then 
				if self.talent_cooldown then
					who.talents_cd[self.talent_cooldown] = usepower(self.use_power.power)
				else
					self.power = self.power - usepower(self.use_power.power)
				end
			end
			return ret
		else
			if self.talent_cooldown or (self.power_regen and self.power_regen ~= 0) then
				game.logPlayer(who, "%s 아직 충전 중입니다.", self:getName{no_count=true}:addJosa("는"))
			else
				game.logPlayer(who, "%s 더 이상 사용할 수 없습니다.", self:getName{no_count=true}:addJosa("는"))
			end
			return {}
		end
	elseif self.use_simple then
		return self.use_simple.use(self, who, ...) or {}
	elseif self.use_talent then
		if (self.talent_cooldown and not who:isTalentCoolingDown(self.talent_cooldown)) or (not self.talent_cooldown and (not self.use_talent.power or self.power >= usepower(self.use_talent.power))) then
		
			local id = self.use_talent.id
			local ab = self:getTalentFromId(id)
			local old_level = who.talents[id]; who.talents[id] = self.use_talent.level
			local ret = ab.action(who, ab)
			who.talents[id] = old_level

			if ret then 
				if self.talent_cooldown then
					who.talents_cd[self.talent_cooldown] = usepower(self.use_talent.power)
				else
					self.power = self.power - usepower(self.use_talent.power)
				end
			end

			return {used=ret}
		else
			if self.talent_cooldown or (self.power_regen and self.power_regen ~= 0) then
				game.logPlayer(who, "%s 아직 충전 중입니다.", self:getName{no_count=true}:addJosa("는"))
			else
				game.logPlayer(who, "%s 더 이상 사용할 수 없습니다.", self:getName{no_count=true}:addJosa("는"))
			end
			return {}
		end
	end
end
