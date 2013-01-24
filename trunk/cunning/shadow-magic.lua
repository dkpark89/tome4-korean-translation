-- ToME - Tales of Maj'Eyal
-- Copyright (C) 2009, 2010, 2011, 2012 Nicolas Casalini
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
	name = "Shadow Combat",
	kr_display_name = "그림자 전투",
	type = {"cunning/shadow-magic", 1},
	mode = "sustained",
	points = 5,
	require = cuns_req1,
	sustain_stamina = 20,
	mana = 0,
	cooldown = 5,
	tactical = { BUFF = 2 },
	getDamage = function(self, t) return 2 + self:combatTalentSpellDamage(t, 2, 50) end,
	getManaCost = function(self, t) return 2 end,
	activate = function(self, t)
		return {}
	end,
	deactivate = function(self, t, p)
		return true
	end,
	info = function(self, t)
		local damage = t.getDamage(self, t)
		local manacost = t.getManaCost(self, t)
		return ([[근접 공격에 마력의 힘을 실어, 매 공격마다 %.2f 마나를 사용하여 %.2f 어둠 피해를 줄 수 있게 됩니다.
		피해량은 주문력 능력치의 영향을 받아 증가합니다.]]):
		format(manacost, damDesc(self, DamageType.DARKNESS, damage))
	end,
}

newTalent{
	name = "Shadow Cunning",
	kr_display_name = "교활한 그림자",
	type = {"cunning/shadow-magic", 2},
	mode = "passive",
	points = 5,
	require = cuns_req2,
	getSpellpower = function(self, t) return 15 + self:getTalentLevel(t) * 5 end,
	info = function(self, t)
		local spellpower = t.getSpellpower(self, t)
		return ([[준비를 통해, 마법적 능력을 높입니다. 교활함 수치의 %d%% 만큼 주문력이 상승하게 됩니다.]]):
		format(spellpower)
	end,
}

newTalent{
	name = "Shadow Feed",
	kr_display_name = "그림자 수급",
	type = {"cunning/shadow-magic", 3},
	mode = "sustained",
	points = 5,
	cooldown = 5,
	sustain_stamina = 40,
	require = cuns_req3,
	range = 10,
	tactical = { BUFF = 2 },
	getManaRegen = function(self, t) return self:getTalentLevel(t) / 14 end,
	activate = function(self, t)
		local speed = self:getTalentLevel(t) * 2.2 / 100
		return {
			regen = self:addTemporaryValue("mana_regen", t.getManaRegen(self, t)),
			ps = self:addTemporaryValue("combat_physspeed", speed),
			ss = self:addTemporaryValue("combat_spellspeed", speed),
		}
	end,
	deactivate = function(self, t, p)
		self:removeTemporaryValue("mana_regen", p.regen)
		self:removeTemporaryValue("combat_physspeed", p.ps)
		self:removeTemporaryValue("combat_spellspeed", p.ss)
		return true
	end,
	info = function(self, t)
		local manaregen = t.getManaRegen(self, t)
		return ([[그림자의 심연에서 힘을 끌어옵니다.
		기술이 유지되는 동안 매 턴마다 마나가 %0.2f 재생하며, 공격속도와 시전속도가 %d%% 상승하게 됩니다.]]):
		format(manaregen, 2.2 * self:getTalentLevel(t))
	end,
}

newTalent{
	name = "Shadowstep",
	kr_display_name = "그림자 걷기",
	type = {"cunning/shadow-magic", 4},
	points = 5,
	random_ego = "attack",
	cooldown = 6,
	stamina = 30,
	require = cuns_req4,
	tactical = { CLOSEIN = 2, DISABLE = { stun = 1 } },
	range = function(self, t) return math.floor(5 + self:getTalentLevel(t)) end,
	direct_hit = true,
	requires_target = true,
	getDuration = function(self, t) return math.min(5, 2 + math.ceil(self:getTalentLevel(t) / 2)) end,
	getDamage = function(self, t) return self:combatTalentWeaponDamage(t, 1.2, 2.5) end,
	action = function(self, t)
		if self:attr("never_move") then game.logPlayer(self, "지금은 그 기술을 사용할 수 없습니다.") return end

		local tg = {type="hit", range=self:getTalentRange(t)}
		local x, y, target = self:getTarget(tg)
		if not x or not y or not target then return nil end
		if core.fov.distance(self.x, self.y, x, y) > self:getTalentRange(t) then return nil end
		if not game.level.map.seens(x, y) then return nil end

		local tx, ty = util.findFreeGrid(x, y, 20, true, {[engine.Map.ACTOR]=true})
		self:move(tx, ty, true)

		-- Attack ?
		if core.fov.distance(self.x, self.y, x, y) == 1 then
			self:attackTarget(target, DamageType.DARKNESS, t.getDamage(self, t), true)
			if target:canBe("stun") then
				target:setEffect(target.EFF_DAZED, t.getDuration(self, t), {})
			else
				game.logSeen(target, "%s 혼절하지 않았습니다!", target.name:capitalize())
			end
		end
		return true
	end,
	info = function(self, t)
		local duration = t.getDuration(self, t)
		return ([[그림자를 통해 대상에게 다가가, %d 턴 동안 혼절시키고 %d%% 무기 피해를 어둠 속성으로 줍니다.
		그림자 걷기를 사용하기 위해서는, 우선 대상을 볼 수 있어야 합니다.]]):
		format(duration, t.getDamage(self, t) * 100)
	end,
}

