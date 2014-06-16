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

require "engine.krtrUtils"

local Map = require "engine.Map"

newTalent{
	name = "Skullcracker",
	kr_name = "박치기",
	type = {"technique/thuggery", 1},
	points = 5,
	cooldown = 12,
	stamina = 20,
	tactical = { DISABLE = { confusion = 2 }, ATTACK = { PHYSICAL = 1 } },
	require = techs_req1,
	requires_target = true,
	getDuration = function(self, t) return math.ceil(self:combatTalentScale(t, 3.2, 5.3)) end,
	getConfusion = function(self, t) return self:combatStatLimit("dex", 50, 25, 45) end, --Limit < 50%
	getDamage = function(self, t)
		local o = self:getInven(self.INVEN_HEAD) and self:getInven(self.INVEN_HEAD)[1]

		local add = 0
		if o then
			add = 15 + o:getPriceFlags() * 0.3 * math.sqrt(o:getPowerRank() + 1) * (o:attr("metallic") and 1 or 0.5) * (o.skullcracker_mult or 1)
		end

		local totstat = self:getStat("str")
		local talented_mod = math.sqrt((self:getTalentLevel(t) + (o and o.material_level or 1)) / 10) + 1
		local power = math.max(self.combat_dam + add, 1)
		power = (math.sqrt(power / 10) - 1) * 0.8 + 1
--		print(("[COMBAT HEAD DAMAGE] power(%f) totstat(%f) talent_mod(%f)"):format(power, totstat, talented_mod))
		return self:rescaleDamage(totstat / 1.5 * power * talented_mod)
	end,
	action = function(self, t)
		local tg = {type="hit", range=self:getTalentRange(t)}
		local x, y, target = self:getTarget(tg)
		if not x or not y or not target then return nil end
		if core.fov.distance(self.x, self.y, x, y) > 1 then return nil end

		local dam = t.getDamage(self, t)

		local _, hitted = self:attackTargetWith(target, nil, nil, nil, dam)

		if hitted then
			if target:canBe("confusion") then
				target:setEffect(target.EFF_CONFUSED, t.getDuration(self, t), {power=t.getConfusion(self, t), apply_power=self:combatAttack()})
			else
				game.logSeen(target, "%s 박치기에 맞고도 멀쩡합니다!", (target.kr_name or target.name):capitalize():addJosa("가"))
			end
			if target:attr("dead") then
				world:gainAchievement("HEADBANG", self, target)
			end
		end

		return true
	end,
	info = function(self, t)
		local dam = damDesc(self, DamageType.PHYSICAL, t.getDamage(self, t))
		local duration = t.getDuration(self, t)
		return ([[대상의 머리 (혹은 약점으로 보이는 어딘가) 에 박치기를 해서, %0.1f 의 물리 피해를 줍니다. 
		공격이 명중하면, 대상은 %d%% 의 확률로 %d 턴 동안 혼란 상태에 빠집니다.
		물리 피해량은 투구의 품질, 힘, 물리력의 영향을 받아 증가합니다.
		혼란 효과와 확률은 민첩과 정확도 능력치의 영향을 받아 증가합니다.]]):
		format(dam, t.getConfusion(self, t), duration)
	end,
}

newTalent{
	name = "Riot-born",
	kr_name = "폭도의 피",
	type = {"technique/thuggery", 2},
	mode = "passive",
	points = 5,
	require = techs_req2,
	getImmune = function(self, t) return self:combatTalentLimit(t, 1, 0.15, 0.5) end,
	passives = function(self, t, p)
		local immune = t.getImmune(self, t)
		self:talentTemporaryValue(p, "stun_immune", immune)
		self:talentTemporaryValue(p, "confusion_immune", immune)
	end,
	info = function(self, t)
		return ([[폭력에 익숙해져, 기절과 혼란 상태에 대한 면역력이 %d%% 올라갑니다.]]):
		format(t.getImmune(self, t)*100)
	end,
}
newTalent{
	name = "Vicious Strikes",
	kr_name = "잔인한 타격",
	type = {"technique/thuggery", 3},
	mode = "passive",
	points = 5,
	require = techs_req3,
	critpower = function(self, t) return self:combatTalentScale(t, 6, 25, 0.75) end,
	getAPR = function(self, t) return self:combatTalentScale(t, 5, 20, 0.75) end,
	passives = function(self, t, p)
		self:talentTemporaryValue(p, "combat_critical_power", t.critpower(self, t))
		self:talentTemporaryValue(p, "combat_apr", t.getAPR(self, t))
	end,
	info = function(self, t)
		return ([[대상의 급소를 정확히 공격할 수 있게 됩니다. 치명타 배율이 %d%% 증가하며, 방어도 관통력이 %d 증가합니다.]]):
		format(t.critpower(self, t), t.getAPR(self, t))
	end,
}

newTalent{
	name = "Total Thuggery",
	kr_name = "총공격",
	type = {"technique/thuggery", 4},
	points = 5,
	mode = "sustained",
	cooldown = 30,
	sustain_stamina = 40,
	no_energy = true,
	require = techs_req4,
	requires_target = true,
	range = 1,
	tactical = { DISABLE = 2, ATTACK = 2 },
	getCrit = function(self, t) return self:combatTalentStatDamage(t, "dex", 10, 50) / 1.5 end,
	getPen = function(self, t) return self:combatLimit(self:combatTalentStatDamage(t, "str", 10, 50), 100, 0, 0, 35.7, 35.7) end, -- Limit to <100%
	getDrain = function(self, t) return self:combatTalentLimit(t, 0, 11, 6) end, -- Limit to >0 stam
	activate = function(self, t)
		local ret = {
			crit = self:addTemporaryValue("combat_physcrit", t.getCrit(self, t)),
			pen = self:addTemporaryValue("resists_pen", {[DamageType.PHYSICAL] = t.getPen(self, t)}),
			drain = self:addTemporaryValue("stamina_regen_on_hit", - t.getDrain(self, t)),
		}
		return ret
	end,
	deactivate = function(self, t, p)
		self:removeTemporaryValue("combat_physcrit", p.crit)
		self:removeTemporaryValue("resists_pen", p.pen)
		self:removeTemporaryValue("stamina_regen_on_hit", p.drain)
		return true
	end,
	info = function(self, t)
		return ([[전력을 다해 적을 부숴버립니다. 모든 공격의 치명타율이 %d%% 증가하며 물리 저항력을 %d%% 관통하게 되지만, 매 공격마다 체력이 %0.1f 감소하게 됩니다.]]):
		format(t.getCrit(self, t), t.getPen(self, t), t.getDrain(self, t))
	end,
}

