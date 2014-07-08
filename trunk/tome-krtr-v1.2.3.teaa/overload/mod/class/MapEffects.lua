-- TE4 - T-Engine 4
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

local Map = require "engine.Map"

local function getEffectName(self)
	local name = self.kr_name or self.name or self.damtype and (engine.DamageType.dam_def[self.damtype].kr_name or engine.DamageType.dam_def[self.damtype].name).." 지역 효과" or "지역 효과"
	if self.src then
		return (self.src.kr_name or self.src.name).."의 "..name
	else
		return name
	end
end

local function getOriEffectName(self) --@ 원문 이름 반환 함수 추가
	local name = self.name or self.damtype and engine.DamageType.dam_def[self.damtype].name.." area effect" or "area effect"
	if self.src then
		return self.src.name.."'s "..name
	else
		return name
	end
end

local function resolveSource(self)
	if self.src and self.src.resolveSource then
		return self.src:resolveSource()
	else
		return self
	end
end

local addEffect = Map.addEffect
Map.addEffect = function (...)
	local e = addEffect(...)
	if e then
		e.getName = getEffectName
		e.resolveSource = resolveSource
	end
	return e
end
