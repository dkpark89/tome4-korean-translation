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
local Chat = require "engine.Chat"

newTalent{
	name = "Life Tap", short_name = "GOLEMANCY_LIFE_TAP",
	kr_name = "생명력 전이",
	type = {"spell/advanced-golemancy", 1},
	require = {
		special = { desc="연금술 골렘을 보유하고 있을 것", fct=function(self, t) return self.alchemy_golem end},
		stat = { mag=function(level) return 22 + (level-1) * 2 end },
		level = function(level) return 10 + (level-1)  end,
	},
	points = 5,
	mana = 25,
	cooldown = 12,
	tactical = { HEAL = 2 },
	is_heal = true,
	getPower = function(self, t) return 70 + self:combatTalentSpellDamage(t, 15, 450) end,
	action = function(self, t)
		local mover, golem = getGolem(self)
		if not golem then
			game.logPlayer(self, "당신의 골렘은 비활성화 상태입니다.")
			return
		end

		local power = math.min(t.getPower(self, t), golem.life)
		golem.life = golem.life - power -- Direct hit, bypass all checks
		golem.changed = true
		self:attr("allow_on_heal", 1)
		self:heal(power)
		self:attr("allow_on_heal", -1)
		game:playSoundNear(self, "talents/arcane")
		return true
	end,
	info = function(self, t)
		local power=t.getPower(self, t)
		return ([[골렘의 생명력을 이용해서 자신의 생명력을 회복합니다. %d 생명력을 흡수합니다.]]):
		format(power)
	end,
}

newTalent{
	name = "Gem Golem",
	kr_name = "보석 골렘",
	type = {"spell/advanced-golemancy",2},
	require = spells_req_high2,
	mode = "passive",
	points = 5,
	info = function(self, t)
		return ([[골렘에 보석을 장착하여, 보석의 특수 효과를 적용시키고 골렘의 근접 공격 속성을 변화시킵니다. 
		보석은 필요에 따라 다른 보석으로 바꿔서 장착할 수 있으며, 이 때 전에 장착시켰던 보석은 파괴되지 않고 원형 그대로 재사용할 수 있습니다.
		가능한 보석의 수준 : %d 단계
		보석 교체는 골렘을 정비할 때 할 수 있습니다. (골렘의 생명력이 가득 찬 상태에서 '골렘 정비' 기술 사용)]]):format(self:getTalentLevelRaw(t))
	end,
}

newTalent{
	name = "Supercharge Golem",
	kr_name = "과충전된 골렘",
	type = {"spell/advanced-golemancy", 3},
	require = spells_req_high3,
	points = 5,
	mana = 20,
	cooldown = function(self, t) return math.floor(25 - self:getTalentLevel(t)) end,
	tactical = { DEFEND = 1, ATTACK=1 },
	getPower = function(self, t) return (60 + self:combatTalentSpellDamage(t, 15, 450)) / 7, 7, 20 + self:getTalentLevel(t) * 7 end,
	action = function(self, t)
		local regen, dur, hp = t.getPower(self, t)

		-- ressurect the golem
		if not game.level:hasEntity(self.alchemy_golem) or self.alchemy_golem.dead then
			self.alchemy_golem.dead = nil
			self.alchemy_golem.life = self.alchemy_golem.max_life / 100 * hp

			-- Find space
			local x, y = util.findFreeGrid(self.x, self.y, 5, true, {[Map.ACTOR]=true})
			if not x then
				game.logPlayer(self, "골렘을 재기동시킬 자리가 없습니다!")
				return
			end
			game.zone:addEntity(game.level, self.alchemy_golem, "actor", x, y)
			self.alchemy_golem:setTarget(nil)
			self.alchemy_golem.ai_state.tactic_leash_anchor = self
			self.alchemy_golem:removeAllEffects()
		end

		local mover, golem = getGolem(self)
		if not golem then
			game.logPlayer(self, "당신의 골렘은 비활성화 상태입니다.")
			return
		end

		golem:setEffect(golem.EFF_SUPERCHARGE_GOLEM, dur, {regen=regen})

		game:playSoundNear(self, "talents/arcane")
		return true
	end,
	info = function(self, t)
		local regen, turns, life = t.getPower(self, t)
		return ([[골렘을 과충전시켜, 턴 당 생명력 회복량을 %0.2f 증가시킵니다. (지속시간 : %d 턴)
		골렘이 파괴된 상태였다면 즉시 재기동에 들어가며, 최대 생명력의 %d%% 에 해당하는 생명력이 회복됩니다.
		과충전된 동안에는, 골렘이 더 강력해져 피해량이 25%% 증가합니다.]]):
		format(regen, turns, life)
	end,
}



newTalent{
	name = "Runic Golem",
	kr_name = "룬 골렘",
	type = {"spell/advanced-golemancy",4},
	require = spells_req_high4,
	mode = "passive",
	points = 5,
	no_npc_use = true,
	on_learn = function(self, t)
		self.alchemy_golem.life_regen = self.alchemy_golem.life_regen + 1
		self.alchemy_golem.mana_regen = self.alchemy_golem.mana_regen + 1
		self.alchemy_golem.stamina_regen = self.alchemy_golem.stamina_regen + 1
		local lev = self:getTalentLevelRaw(t)
		if lev == 1 or lev == 3 or lev == 5 then
			self.alchemy_golem.max_inscriptions = self.alchemy_golem.max_inscriptions + 1
			self.alchemy_golem.inscriptions_slots_added = self.alchemy_golem.inscriptions_slots_added + 1
		end
	end,
	on_unlearn = function(self, t)
		self.alchemy_golem.life_regen = self.alchemy_golem.life_regen - 1
		self.alchemy_golem.mana_regen = self.alchemy_golem.mana_regen - 1
		self.alchemy_golem.stamina_regen = self.alchemy_golem.stamina_regen - 1
		local lev = self:getTalentLevelRaw(t)
		if lev == 0 or lev == 2 or lev == 4 then
			self.alchemy_golem.max_inscriptions = self.alchemy_golem.max_inscriptions - 1
			self.alchemy_golem.inscriptions_slots_added = self.alchemy_golem.inscriptions_slots_added - 1
		end
	end,
	info = function(self, t)
		return ([[골렘의 턴 당 생명력, 마나, 체력 회복량을 %0.2f 증가시킵니다.
		또한, 룬 골렘 기술이 1, 3, 5 레벨에 도달할 때마다 골렘의 룬 슬롯이 하나씩 늘어납니다.
		이 기술이 없더라도, 골렘은 기본적으로 3 개의 룬 슬롯을 사용할 수 있습니다.]]):
		format(self:getTalentLevelRaw(t))
	end,
}
