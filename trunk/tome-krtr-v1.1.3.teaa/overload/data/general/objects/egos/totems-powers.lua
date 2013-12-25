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
Totems
*healing
*cure illness
*cure poisons
*thorny skin
]]

newEntity{
	name = " of cure illness", addon=true, instant_resolve=true,
	kr_name = "질병 치료의 ",
	keywords = {cureill=true},
	level_range = {15, 50},
	rarity = 8,

	charm_power_def = {add=1, max=5, floor=true},
	resolvers.charm("대상의 질병을 제거 (최대 %d 개 까지)", 20, function(self, who)
		local tg = {default_target=who, type="hit", nowarning=true, range=6 + who:getWil(4), first_target="friend"}
		local x, y = who:getTarget(tg)
		if not x or not y then return nil end
		local nb = self:getCharmPower(who)
		who:project(tg, x, y, function(px, py)
			local target = game.level.map(px, py, engine.Map.ACTOR)
			if not target then return end
			local effs = {}

			-- Go through all temporary effects
			for eff_id, p in pairs(target.tmp) do
				local e = target.tempeffect_def[eff_id]
				if e.subtype.disease then
					effs[#effs+1] = {"effect", eff_id}
				end
			end

			for i = 1, nb do
				if #effs == 0 then break end
				local eff = rng.tableRemove(effs)

				if eff[1] == "effect" then
					target:removeEffect(eff[2])
				end
			end
		end)
		game:playSoundNear(who, "talents/heal")
		game.logSeen(who, "%s %s 사용합니다!", (who.kr_name or who.name):capitalize():addJosa("가"), self:getName{no_count=true}:addJosa("를"))
		return {id=true, used=true}
	end),
}

newEntity{
	name = " of cure poisons", addon=true, instant_resolve=true,
	kr_name = "중독 치료의 ",
	keywords = {curepoison=true},
	level_range = {1, 50},
	rarity = 8,

	charm_power_def = {add=1, max=5, floor=true},
	resolvers.charm("대상의 독을 제거(최대 %d 개 까지)", 20, function(self, who)
		local tg = {default_target=who, type="hit", nowarning=true, range=6 + who:getWil(4), first_target="friend"}
		local x, y = who:getTarget(tg)
		if not x or not y then return nil end
		local nb = self:getCharmPower(who)
		who:project(tg, x, y, function(px, py)
			local target = game.level.map(px, py, engine.Map.ACTOR)
			if not target then return end
			local effs = {}

			-- Go through all temporary effects
			for eff_id, p in pairs(target.tmp) do
				local e = target.tempeffect_def[eff_id]
				if e.subtype.poison then
					effs[#effs+1] = {"effect", eff_id}
				end
			end

			for i = 1, nb do
				if #effs == 0 then break end
				local eff = rng.tableRemove(effs)

				if eff[1] == "effect" then
					target:removeEffect(eff[2])
				end
			end
		end)
		game:playSoundNear(who, "talents/heal")
		game.logSeen(who, "%s %s 사용합니다!", (who.kr_name or who.name):capitalize():addJosa("가"), self:getName{no_count=true}:addJosa("를"))
		return {id=true, used=true}
	end),
}

newEntity{
	name = " of thorny skin", addon=true, instant_resolve=true,
	kr_name = "가시돋은 피부의 ",
	keywords = {thorny=true},
	level_range = {1, 50},
	rarity = 6,

	charm_power_def = {add=5, max=100, floor=true},
	resolvers.charm(function(self) return ("6 턴간 피부를 단단하게 만들어, 방어도 %d / 방어효율 %d%%%% 증가"):format(self:getCharmPower(who), 20 + self.material_level * 10) end, 20, function(self, who)
		who:setEffect(who.EFF_THORNY_SKIN, 6, {ac=self:getCharmPower(who), hard=20 + self.material_level * 10})
		game:playSoundNear(who, "talents/heal")
		game.logSeen(who, "%s %s 사용합니다!", (who.kr_name or who.name):capitalize():addJosa("가"), self:getName{no_count=true}:addJosa("를"))
		return {id=true, used=true}
	end),
}

newEntity{
	name = " of healing", addon=true, instant_resolve=true,
	kr_name = "치료의 ",
	keywords = {heal=true},
	level_range = {25, 50},
	rarity = 20,

	charm_power_def = {add=50, max=250, floor=true},
	resolvers.charm("대상의 생명력 %d 치료", 35, function(self, who)
		local tg = {default_target=who, type="hit", nowarning=true, range=6 + who:getWil(4), first_target="friend"}
		local x, y = who:getTarget(tg)
		if not x or not y then return nil end
		local dam = self:getCharmPower(who)
		who:project(tg, x, y, engine.DamageType.HEAL, dam)
		game:playSoundNear(who, "talents/heal")
		game.logSeen(who, "%s %s 사용합니다!", (who.kr_name or who.name):capitalize():addJosa("가"), self:getName{no_count=true}:addJosa("를"))
		return {id=true, used=true}
	end),
}
