﻿-- ToME - Tales of Maj'Eyal
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
	name = " of clairvoyance", addon=true, instant_resolve=true,
	--kr_name = "의 ", --@@ 한글화 필요
	keywords = {clairvoyance=true},
	level_range = {1, 50},
	rarity = 8,

	charm_power_def = {add=8, max=10, floor=true},
	resolvers.charm("reveal the area around you dispelling darkness and detecting the presence of nearby creatures (rad %d)", 6, function(self, who) --@@ 한글화 필요
		local rad = self:getCharmPower(who)
		who:setEffect(who.EFF_SENSE, 3, {
			range = rad,
			actor = 1,
		})
		who:project({type="ball", range=0, selffire=true, radius=self:getCharmPower(who)}, who.x, who.y, engine.DamageType.LITE, 1)
		game.logSeen(who, "%s %s 사용했습니다!", (who.kr_name or who.name):capitalize():addJosa("가"), self:getName{no_count=true}:addJosa("를"))
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
	resolvers.charm(function(self) return ("임의의 원소 속성 탄환을 발사 (%d - %d 피해)"):format(self:getCharmPower(who)/2, self:getCharmPower(who)) end, 10, function(self, who)
		local tg = {type="bolt", range=8}
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
