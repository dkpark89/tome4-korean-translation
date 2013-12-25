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

--[[
Torques
*psionic shield
*psychoportation
*clear mind
*mind wave
]]

newEntity{
	name = " of psychoportation", addon=true, instant_resolve=true,
	kr_name = "시공간 변화의 ",
	keywords = {psyport=true},
	level_range = {15, 50},
	rarity = 10,

	charm_power_def = {add=15, max=60, floor=true},
	resolvers.charm("임의의 위치로 순간이동 (주변 %d 칸 반경)", 30, function(self, who)
		game.level.map:particleEmitter(who.x, who.y, 1, "teleport")
		who:teleportRandom(who.x, who.y, self:getCharmPower(who))
		game.level.map:particleEmitter(who.x, who.y, 1, "teleport")
		game.logSeen(who, "%s %s 사용합니다!", (who.kr_name or who.name):capitalize():addJosa("가"), self:getName{no_count=true}:addJosa("를"))
		return {id=true, used=true}
	end),
}

newEntity{
	name = " of kinetic psionic shield", addon=true, instant_resolve=true,
	kr_name = "동역학적 보호막의 ",
	keywords = {kinshield=true},
	level_range = {1, 50},
	rarity = 7,

	charm_power_def = {add=3, max=200, floor=true},
	resolvers.charm("보호막을 만들어내, 6 턴간 모든 물리나 산성 피해를 %d 만큼 감소", 20, function(self, who)
		who:setEffect(who.EFF_PSIONIC_SHIELD, 6, {kind="kinetic", power=self:getCharmPower(who)})
		game.logSeen(who, "%s %s 사용합니다!", (who.kr_name or who.name):capitalize():addJosa("가"), self:getName{no_count=true}:addJosa("를"))
		return {id=true, used=true}
	end),
}

newEntity{
	name = " of thermal psionic shield", addon=true, instant_resolve=true,
	kr_name = "열역학적 보호막의 ",
	keywords = {thermshield=true},
	level_range = {1, 50},
	rarity = 7,

	charm_power_def = {add=3, max=200, floor=true},
	resolvers.charm("보호막을 만들어내, 6 턴간 모든 화염이나 냉기 피해를 %d 만큼 감소", 20, function(self, who)
		who:setEffect(who.EFF_PSIONIC_SHIELD, 6, {kind="thermal", power=self:getCharmPower(who)})
		game.logSeen(who, "%s %s 사용합니다!", (who.kr_name or who.name):capitalize():addJosa("가"), self:getName{no_count=true}:addJosa("를"))
		return {id=true, used=true}
	end),
}

newEntity{
	name = " of charged psionic shield", addon=true, instant_resolve=true,
	kr_name = "전하적 보호막의 ",
	keywords = {chargedshield=true},
	level_range = {10, 50},
	rarity = 8,

	charm_power_def = {add=3, max=200, floor=true},
	resolvers.charm("보호막을 만들어내, 6 턴간 모든 전기나 황폐 피해를 %d 만큼 감소", 20, function(self, who)
		who:setEffect(who.EFF_PSIONIC_SHIELD, 6, {kind="charged", power=self:getCharmPower(who)})
		game.logSeen(who, "%s %s 사용합니다!", (who.kr_name or who.name):capitalize():addJosa("가"), self:getName{no_count=true}:addJosa("를"))
		return {id=true, used=true}
	end),
}

newEntity{
	name = " of clear mind", addon=true, instant_resolve=true,
	kr_name = "맑은 정신의 ",
	keywords = {clearmind=true},
	level_range = {15, 50},
	rarity = 12,

	charm_power_def = {add=1, max=5, floor=true},
	resolvers.charm("다음 10 턴 동안, 최대 %d 개의 나쁜 정신적 상태효과를 방어", 20, function(self, who)
		who:setEffect(who.EFF_CLEAR_MIND, 10, {power=self:getCharmPower(who)})
		game.logSeen(who, "%s %s 사용합니다!", (who.kr_name or who.name):capitalize():addJosa("가"), self:getName{no_count=true}:addJosa("를"))
		return {id=true, used=true}
	end),
}

newEntity{
	name = " of mindblast", addon=true, instant_resolve=true,
	kr_name = "염동력 폭발의 ",
	keywords = {mindblast=true},
	level_range = {15, 50},
	rarity = 8,

	charm_power_def = {add=45, max=400, floor=true},
	resolvers.charm(function(self) return ("염동력을 모아서, 관통하는 화살 형태로 발사 (%d - %d 피해)"):format(self:getCharmPower(who)/2, self:getCharmPower(who)) end, 6, function(self, who)
		local tg = {type="beam", range=6 + who:getWil(4)}
		local x, y = who:getTarget(tg)
		if not x or not y then return nil end
		local dam = self:getCharmPower(who)
		who:project(tg, x, y, engine.DamageType.MIND, rng.avg(dam / 2, dam, 3), {type="mind"})
		game.logSeen(who, "%s %s 사용합니다!", (who.kr_name or who.name):capitalize():addJosa("가"), self:getName{no_count=true}:addJosa("를"))
		return {id=true, used=true}
	end),
}
