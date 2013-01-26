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
	name = "Arcane Eye",
	kr_display_name = "마법의 눈",
	type = {"spell/divination", 1},
	require = spells_req1,
	points = 5,
	mana = 15,
	cooldown = 10,
	no_energy = true,
	no_npc_use = true,
	requires_target = true,
	getDuration = function(self, t) return math.floor(10 + self:getTalentLevel(t) * 3) end,
	getRadius = function(self, t) return math.floor(4 + self:getTalentLevel(t)) end,
	action = function(self, t)
		local tg = {type="hit", nolock=true, pass_terrain=true, nowarning=true, range=100, requires_knowledge=false}
		x, y = self:getTarget(tg)
		if not x then return nil end
		-- Target code does not restrict the target coordinates to the range, it lets the project function do it
		-- but we cant ...
		local _ _, x, y = self:canProject(tg, x, y)

		self:setEffect(self.EFF_ARCANE_EYE, t.getDuration(self, t), {x=x, y=y, track=(self:getTalentLevel(t) >= 4) and game.level.map(x, y, Map.ACTOR) or nil, radius=t.getRadius(self, t), true_seeing=self:getTalentLevel(t) >= 5})
		game:playSoundNear(self, "talents/spell_generic")
		return true
	end,
	info = function(self, t)
		local radius = t.getRadius(self, t)
		local duration = t.getDuration(self, t)
		return ([[지정한 곳에 %d 턴 동안 마법의 눈을 소환합니다.
		마법의 눈은 발각되거나 공격받지 않으며, 주변 %d 칸 반경의 시야를 제공합니다.
		빛이 없어도 시야 제공이 되지만, 벽에 가려진 부분은 볼 수 없습니다.
		마법의 눈은 시전시간 없이 즉시 소환할 수 있습니다.
		한번에 여러 개의 눈은 소환할 수 없습니다.
		기술 레벨이 4 이상이면, 시전자를 포함한 특정 대상에 마법의 눈을 소환하여 따라다니게 할 수 있습니다.
		기술 레벨이 5 이상이면, 투명하거나 은신 중인 적에 표식을 남겨 해당 효과를 무효화시킬 수 있습니다.]]):
		format(duration, radius)
	end,
}

newTalent{
	name = "Keen Senses",
	kr_display_name = "예리한 감각",
	type = {"spell/divination", 2},
	require = spells_req2,
	mode = "sustained",
	points = 5,
	sustain_mana = 40,
	tactical = { BUFF = 2 },
	cooldown = 30,
	getSeeInvisible = function(self, t) return self:combatTalentSpellDamage(t, 2, 45) end,
	getSeeStealth = function(self, t) return self:combatTalentSpellDamage(t, 2, 20) end,
	getCriticalChance = function(self, t) return self:combatTalentSpellDamage(t, 2, 12) end,
	activate = function(self, t)
		game:playSoundNear(self, "talents/spell_generic")
		return {
			invis = self:addTemporaryValue("see_invisible", t.getSeeInvisible(self, t)),
			stealth = self:addTemporaryValue("see_stealth", t.getSeeStealth(self, t)),
			crit = self:addTemporaryValue("combat_spellcrit", t.getCriticalChance(self, t)),
		}
	end,
	deactivate = function(self, t, p)
		self:removeTemporaryValue("see_invisible", p.invis)
		self:removeTemporaryValue("see_stealth", p.stealth)
		self:removeTemporaryValue("combat_spellcrit", p.crit)
		return true
	end,
	info = function(self, t)
		local seeinvisible = t.getSeeInvisible(self, t)
		local seestealth = t.getSeeStealth(self, t)
		local criticalchance = t.getCriticalChance(self, t)
		return ([[마력으로 감각을 곤두세워, 주변의 적에 대한 정보를 파악합니다.
		투명체 감지력이 %d, 은신 감지력이 %d 상승하며, 주문 치명타율이 %d%% 상승합니다.
		상승 효과들은 주문력의 영향을 받아 증가합니다.]]):
		format(seeinvisible, seestealth, criticalchance)
	end,
}

newTalent{
	name = "Vision",
	kr_display_name = "심안",
	type = {"spell/divination", 3},
	require = spells_req3,
	points = 5,
	random_ego = "utility",
	mana = 20,
	cooldown = 20,
	no_npc_use = true,
	getRadius = function(self, t) return 5 + self:combatTalentSpellDamage(t, 2, 12) end,
	action = function(self, t)
		self:magicMap(t.getRadius(self, t))
		game:playSoundNear(self, "talents/spell_generic")
		return true
	end,
	info = function(self, t)
		local radius = t.getRadius(self, t)
		return ([[주변 %d 칸 반경의 지형을 탐지합니다.]]):
		format(radius)
	end,
}

newTalent{
	name = "Premonition",
	kr_display_name = "예감",
	type = {"spell/divination", 4},
	mode = "sustained",
	require = spells_req4,
	points = 5,
	sustain_mana = 120,
	cooldown = 30,
	tactical = { BUFF = 2 },
	getResist = function(self, t) return 10 + self:combatTalentSpellDamage(t, 2, 25) end,
	on_damage = function(self, t, damtype)
		if damtype == DamageType.PHYSICAL then return end

		if not self:hasEffect(self.EFF_PREMONITION_SHIELD) then
			self:setEffect(self.EFF_PREMONITION_SHIELD, 5, {damtype=damtype, resist=t.getResist(self, t)})
			game.logPlayer(self, "#OLIVE_DRAB#공격을 예측하여, 피해를 입기 전에 저항력을 끌어올렸습니다!")
		end
	end,
	activate = function(self, t)
		game:playSoundNear(self, "talents/spell_generic")
		return {
		}
	end,
	deactivate = function(self, t, p)
		return true
	end,
	info = function(self, t)
		local resist = t.getResist(self, t)
		return ([[미래의 편린들이 눈에 보여, 앞으로 다가올 공격을 예측할 수 있게 됩니다.
		시전자에게 가해지는 공격이 물리 공격이 아니라면, 공격을 받기 전에 순간적으로 저항력을 끌어올려 해당 공격 속성의 저항력을 %d%% 올립니다.
		한번 끌어올린 저항력은 5 턴 동안 사라지지 않으며, 그동안 다른 속성의 저항력은 올릴 수 없습니다.
		저항력 상승량은 주문력의 영향을 받아 증가합니다.]]):format(resist)
	end,
}
