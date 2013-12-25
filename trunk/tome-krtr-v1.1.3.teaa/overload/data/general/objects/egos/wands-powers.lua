﻿-- ToME - Tales of Maj'Eyal
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
Wands
*detection
*light
*trap destruction
*firewall
*lightning
*conjuration
]]

newEntity{
	name = " of detection", addon=true, instant_resolve=true,
	kr_name = "탐정의 ",
	keywords = {detect=true},
	level_range = {1, 50},
	rarity = 8,

	charm_power_def = {add=5, max=10, floor=true},
	resolvers.charm("주변의 생명체 탐지 (반경 %d)", 15, function(self, who)
		local rad = self:getCharmPower(who)
		who:setEffect(who.EFF_SENSE, 2, {
			range = rad,
			actor = 1,
		})
		game.logSeen(who, "%s %s 사용합니다!", (who.kr_name or who.name):capitalize():addJosa("가"), self:getName{no_count=true}:addJosa("를"))
		return {id=true, used=true}
	end),
}

newEntity{
	name = " of illumination", addon=true, instant_resolve=true,
	kr_name = "조명의 ",
	keywords = {illuminate=true},
	level_range = {1, 50},
	rarity = 8,

	charm_power_def = {add=4, max=15, floor=true},
	resolvers.charm("주변 밝히기 (주변 %d 칸 반경)", 5, function(self, who)
		who:project({type="ball", range=0, selffire=true, radius=self:getCharmPower(who)}, who.x, who.y, engine.DamageType.LITE, 1)
		game.logSeen(who, "%s %s 사용합니다!", (who.kr_name or who.name):capitalize():addJosa("가"), self:getName{no_count=true}:addJosa("를"))
		return {id=true, used=true}
	end),
}

newEntity{
	name = " of trap destruction", addon=true, instant_resolve=true,
	kr_name = "함정 파괴의 ",
	keywords = {trap=true},
	level_range = {1, 50},
	rarity = 14,

	charm_power_def = {add=resolvers.genericlast(function(e) return e.material_level * 8 end), max=100, floor=true},
	resolvers.charm("직선 방향의 함정 해체 시도 (해체력 %d)", 15, function(self, who)
		local tg = {type="beam", range=2 + who:getMag(2)}
		local x, y = who:getTarget(tg)
		if not x or not y then return nil end
		who:project(tg, x, y, function(px, py)
			local trap = game.level.map(px, py, engine.Map.TRAP)
			if not trap then return end
			local inc = self:getCharmPower(who)
			who:attr("can_disarm", 1)
			who:attr("disarm_bonus", inc)

			trap:disarm(px, py, who)

			who:attr("disarm_bonus", -inc)
			who:attr("can_disarm", -1)
		end)
		game.logSeen(who, "%s %s 사용합니다!", (who.kr_name or who.name):capitalize():addJosa("가"), self:getName{no_count=true}:addJosa("를"))
		return {id=true, used=true}
	end),
}

newEntity{
	name = " of lightning", addon=true, instant_resolve=true,
	kr_name = "뇌전의 ",
	keywords = {lightning=true},
	level_range = {15, 50},
	rarity = 10,

	charm_power_def = {add=45, max=300, floor=true},
	resolvers.charm(function(self) return ("전격 발사 (%d - %d 피해)"):format(self:getCharmPower(who)/3, self:getCharmPower(who)) end, 6, function(self, who)
		local tg = {type="beam", range=6 + who:getMag(4)}
		local x, y = who:getTarget(tg)
		if not x or not y then return nil end
		local dam = self:getCharmPower(who)
		who:project(tg, x, y, engine.DamageType.LIGHTNING, rng.avg(dam / 3, dam, 3))
		local _ _, x, y = who:canProject(tg, x, y)
		game.level.map:particleEmitter(who.x, who.y, math.max(math.abs(x-who.x), math.abs(y-who.y)), "lightning", {tx=x-who.x, ty=y-who.y})
		game:playSoundNear(who, "talents/lightning")
		game.logSeen(who, "%s %s 사용합니다!", (who.kr_name or who.name):capitalize():addJosa("가"), self:getName{no_count=true}:addJosa("를"))
		return {id=true, used=true}
	end),
}

newEntity{
	name = " of firewall", addon=true, instant_resolve=true,
	kr_name = "화염 장벽의 ",
	keywords = {firewall=true},
	level_range = {15, 50},
	rarity = 10,

	charm_power_def = {add=25, max=400, floor=true},
	resolvers.charm("4 턴간 유지되는 화염 장벽 생성 (총 피해량 %d)", 6, function(self, who)
		local tg = {type="wall", range=5, halflength=3, halfmax_spots=3+1}
		local x, y = who:getTarget(tg)
		if not x or not y then return nil end
		local dam = self:getCharmPower(who)
		who:project(tg, x, y, function(px, py)
			game.level.map:addEffect(who, px, py, 4, engine.DamageType.FIRE, dam / 4, 0, 5, nil, {type="inferno"}, nil, true)
		end)
		game:playSoundNear(who, "talents/fire")
		game.logSeen(who, "%s %s 사용합니다!", (who.kr_name or who.name):capitalize():addJosa("가"), self:getName{no_count=true}:addJosa("를"))
		return {id=true, used=true}
	end),
}

newEntity{
	name = " of conjuration", addon=true, instant_resolve=true,
	kr_name = "요술의 ",
	keywords = {conjure=true},
	level_range = {6, 50},
	rarity = 6,

	charm_power_def = {add=25, max=600, floor=true},
	resolvers.charm(function(self) return ("임의의 원소 속성 탄환을 발사 (%d - %d 피해)"):format(self:getCharmPower(who)/2, self:getCharmPower(who)) end, 6, function(self, who)
		local tg = {type="bolt", range=10 + who:getMag(10)}
		local x, y = who:getTarget(tg)
		if not x or not y then return nil end
		local dam = self:getCharmPower(who)
		local elem = rng.table{
			{engine.DamageType.FIRE, "flame"},
			{engine.DamageType.COLD, "freeze"},
			{engine.DamageType.LIGHTNING, "lightning_explosion"},
			{engine.DamageType.ACID, "acid"},
			{engine.DamageType.NATURE, "slime"},
			{engine.DamageType.BLIGHT, "slime"},
		}
		who:project(tg, x, y, elem[1], rng.avg(dam / 2, dam, 3), {type=elem[2]})
		game:playSoundNear(who, "talents/fire")
		game.logSeen(who, "%s %s 사용합니다!", (who.kr_name or who.name):capitalize():addJosa("가"), self:getName{no_count=true}:addJosa("를"))
		return {id=true, used=true}
	end),
}
