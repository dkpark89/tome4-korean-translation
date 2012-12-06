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

-- Archmage spells
newTalentType{ allow_random=true, no_silence=true, is_spell=true, mana_regen=true, type="spell/arcane", name = "arcane", description = "가공되지 않은 마법의 힘을 다뤄, 공격이나 수비적인 주문으로 변형한다." }
newTalentType{ allow_random=true, no_silence=true, is_spell=true, mana_regen=true, type="spell/aether", name = "aether", description = "마법의 정수인 에테르의 힘에 닿아, 적들을 유린하는 효과를 가져온다." }

-- Elemental spells
newTalentType{ allow_random=true, no_silence=true, is_spell=true, mana_regen=true, type="spell/fire", name = "fire", description = "불의 힘으로 적을 재가 될때까지 태운다." }
newTalentType{ allow_random=true, no_silence=true, is_spell=true, mana_regen=true, type="spell/wildfire", name = "wildfire", min_lev = 10, description = "야생의 불로 적을 재가 될때까지 태운다." }
newTalentType{ allow_random=true, no_silence=true, is_spell=true, mana_regen=true, type="spell/earth", name = "earth", description = "땅의 힘으로 보호하고 파괴한다." }
newTalentType{ allow_random=true, no_silence=true, is_spell=true, mana_regen=true, type="spell/stone", name = "stone", min_lev = 10, description = "돌의 힘으로 보호하고 파괴한다." }
newTalentType{ allow_random=true, no_silence=true, is_spell=true, mana_regen=true, type="spell/water", name = "water", description = "물의 힘으로 적을 익사시킨다." }
newTalentType{ allow_random=true, no_silence=true, is_spell=true, mana_regen=true, type="spell/ice", name = "ice", min_lev = 10, description = "얼음의 힘으로 적을 얼리고 부순다." }
newTalentType{ allow_random=true, no_silence=true, is_spell=true, mana_regen=true, type="spell/air", name = "air", description = "공기의 힘으로 적을 튀긴다." }
newTalentType{ allow_random=true, no_silence=true, is_spell=true, mana_regen=true, type="spell/storm", name = "storm", min_lev = 10, description = "폭풍의 힘으로 적을 소각한다." }

-- Various other magic schools
newTalentType{ allow_random=true, no_silence=true, is_spell=true, mana_regen=true, type="spell/meta", name = "meta", description = "메타 주문은 마법 그 자체에 적용되는 주문입니다." }
newTalentType{ allow_random=true, no_silence=true, is_spell=true, mana_regen=true, type="spell/temporal", name = "temporal", description = "시간을 다루는 주문 학파." }
newTalentType{ allow_random=true, no_silence=true, is_spell=true, mana_regen=true, type="spell/phantasm", name = "phantasm", description = "속임수와 환영의 힘을 조종한다." }
newTalentType{ allow_random=true, no_silence=true, is_spell=true, mana_regen=true, type="spell/enhancement", name = "enhancement", description = "마법적인 육체 능력 향상." }
newTalentType{ allow_random=true, no_silence=true, is_spell=true, type="spell/conveyance", name = "conveyance", generic = true, description = "전도는 이동에 관련된 주문입니다. 더 빠른 이동을 가능하게 만들어 주고 다른이를 추적해 줍니다." }
newTalentType{ allow_random=true, no_silence=true, is_spell=true, type="spell/divination", name = "divination", generic = true, description = "예견은 시전자가 주변의 숨겨진 것들을 느낄 수 있게 만들어 줍니다." }
newTalentType{ allow_random=true, no_silence=true, is_spell=true, type="spell/aegis", name = "aegis", generic = true, description = "마법의 힘으로 치료와 보호를 합니다." }

-- Alchemist spells
newTalentType{ allow_random=true, no_silence=true, is_spell=true, mana_regen=true, type="spell/explosives", name = "explosive admixtures", description = "보석을 폭발하는 마법적 폭탄으로 바꾸고, 그것을 다루게 해 줍니다." }
newTalentType{ allow_random=true, no_silence=true, is_spell=true, mana_regen=true, type="spell/infusion", name = "infusion", description = "보석 폭탄에 여러가지 엘리먼트의 힘을 주입합니다." }
newTalentType{ allow_random=true, no_silence=true, is_spell=true, mana_regen=true, type="spell/golemancy-base", name = "golemancy", hide = true, description = "골렘을 만들고 향상시키는 방법을 배웁니다." }
newTalentType{ allow_random=true, no_silence=true, is_spell=true, mana_regen=true, type="spell/golemancy", name = "golemancy", description = "골렘을 만들고 향상시키는 방법을 배웁니다." }
newTalentType{ allow_random=true, no_silence=true, is_spell=true, mana_regen=true, type="spell/advanced-golemancy", name = "advanced-golemancy", min_lev = 10, description = "고급 골렘 기술." }
newTalentType{ allow_random=true, no_silence=true, is_spell=true, mana_regen=true, type="spell/fire-alchemy", name = "fire alchemy", description = "불에 대한 연금술적 제어." }
newTalentType{ allow_random=true, no_silence=true, is_spell=true, type="spell/stone-alchemy-base", name = "stone alchemy", hide = true, description = "보석을 다루고, 물체에 그 힘을 불어넣는다." }
newTalentType{ allow_random=true, no_silence=true, is_spell=true, type="spell/stone-alchemy", name = "stone alchemy", generic = true, description = "돌과 보석에 대한 연금술적 제어." }
newTalentType{ allow_random=true, no_silence=true, is_spell=true, type="spell/staff-combat", name = "staff combat", generic = true, description = "마법 지팡이의 힘을 이용한다." }
newTalentType{ type="golem/fighting", name = "fighting", description = "Golem melee capacity." }
newTalentType{ type="golem/arcane", no_silence=true, is_spell=true, name = "arcane", description = "Golem arcane capacity." }
newTalentType{ type="golem/golem", name = "golem", description = "Golem basic capacity." }

-- Necromancer spells
newTalentType{ allow_random=true, no_silence=true, is_spell=true, mana_regen=true, type="spell/necrotic-minions", name = "necrotic minions", description = "언데드 추종자를 만들고 힘을 주는 법." }
newTalentType{ allow_random=true, no_silence=true, is_spell=true, mana_regen=true, type="spell/advanced-necrotic-minions", name = "advanced necrotic minions", min_lev = 10, description = "언데드 추종자를 만들고 힘을 주는 법." }
newTalentType{ allow_random=true, no_silence=true, is_spell=true, mana_regen=true, type="spell/nightfall", name = "nightfall", description = "적을 죽이기 위해 어둠 그 자체를 다루는 방법" }
newTalentType{ allow_random=true, no_silence=true, is_spell=true, mana_regen=true, type="spell/shades", name = "shades", min_lev = 10, description = "그늘을 조종하고 불러오는 방법." }
newTalentType{ allow_random=true, no_silence=true, is_spell=true, mana_regen=true, type="spell/necrosis", name = "necrosis", description = "죽음을 넘어선 제어술, 최종적으로는 리치가 되는 법까지." }
newTalentType{ allow_random=true, no_silence=true, is_spell=true, mana_regen=true, type="spell/grave", name = "grave", description = "무덤에서 썩는 차가운 운명을 이용하여 적들을 나락으로 떨어뜨리는 방법." }

-- Generic requires for spells based on talent level
spells_req1 = {
	stat = { mag=function(level) return 12 + (level-1) * 2 end },
	level = function(level) return 0 + (level-1)  end,
}
spells_req2 = {
	stat = { mag=function(level) return 20 + (level-1) * 2 end },
	level = function(level) return 4 + (level-1)  end,
}
spells_req3 = {
	stat = { mag=function(level) return 28 + (level-1) * 2 end },
	level = function(level) return 8 + (level-1)  end,
}
spells_req4 = {
	stat = { mag=function(level) return 36 + (level-1) * 2 end },
	level = function(level) return 12 + (level-1)  end,
}
spells_req5 = {
	stat = { mag=function(level) return 44 + (level-1) * 2 end },
	level = function(level) return 16 + (level-1)  end,
}
spells_req_high1 = {
	stat = { mag=function(level) return 22 + (level-1) * 2 end },
	level = function(level) return 10 + (level-1)  end,
}
spells_req_high2 = {
	stat = { mag=function(level) return 30 + (level-1) * 2 end },
	level = function(level) return 14 + (level-1)  end,
}
spells_req_high3 = {
	stat = { mag=function(level) return 38 + (level-1) * 2 end },
	level = function(level) return 18 + (level-1)  end,
}
spells_req_high4 = {
	stat = { mag=function(level) return 46 + (level-1) * 2 end },
	level = function(level) return 22 + (level-1)  end,
}
spells_req_high5 = {
	stat = { mag=function(level) return 54 + (level-1) * 2 end },
	level = function(level) return 26 + (level-1)  end,
}

-------------------------------------------
-- Necromancer minions
function necroGetNbSummon(self)
	local nb = 0
	if not game.party or not game.party:hasMember(self) then return 0 end
	-- Count party members
	for act, def in pairs(game.party.members) do
		if act.summoner and act.summoner == self and act.necrotic_minion then nb = nb + 1 end
	end
	return nb
end

function necroSetupSummon(self, m, x, y, level, no_control, no_decay)
	m.faction = self.faction
	m.summoner = self
	m.summoner_gain_exp = true
	m.necrotic_minion = true
	m.exp_worth = 0
	m.life_regen = 0
	m.unused_stats = 0
	m.unused_talents = 0
	m.unused_generics = 0
	m.unused_talents_types = 0
	m.silent_levelup = true
	m.no_points_on_levelup = true
	m.ai_state = m.ai_state or {}
	m.ai_state.tactic_leash = 100
	-- Try to use stored AI talents to preserve tweaking over multiple summons
	m.ai_talents = self.stored_ai_talents and self.stored_ai_talents[m.name] or {}
	m.inc_damage = table.clone(self.inc_damage, true)
	m.no_breath = 1

	if self:knowTalent(self.T_DARK_EMPATHY) then
		local t = self:getTalentFromId(self.T_DARK_EMPATHY)
		local perc = t.getPerc(self, t)
		for k, e in pairs(self.resists) do
			m.resists[k] = (m.resists[k] or 0) + e * perc / 100
		end
		m.combat_physresist = m.combat_physresist + self:combatPhysicalResist() * perc / 100
		m.combat_spellresist = m.combat_spellresist + self:combatSpellResist() * perc / 100
		m.combat_mentalresist = m.combat_mentalresist + self:combatMentalResist() * perc / 100

		m.poison_immune = (m.poison_immune or 0) + (self:attr("poison_immune") or 0) * perc / 100
		m.disease_immune = (m.disease_immune or 0) + (self:attr("disease_immune") or 0) * perc / 100
		m.cut_immune = (m.cut_immune or 0) + (self:attr("cut_immune") or 0) * perc / 100
		m.confusion_immune = (m.confusion_immune or 0) + (self:attr("confusion_immune") or 0) * perc / 100
		m.blind_immune = (m.blind_immune or 0) + (self:attr("blind_immune") or 0) * perc / 100
		m.silence_immune = (m.silence_immune or 0) + (self:attr("silence_immune") or 0) * perc / 100
		m.disarm_immune = (m.disarm_immune or 0) + (self:attr("disarm_immune") or 0) * perc / 100
		m.pin_immune = (m.pin_immune or 0) + (self:attr("pin_immune") or 0) * perc / 100
		m.stun_immune = (m.stun_immune or 0) + (self:attr("stun_immune") or 0) * perc / 100
		m.fear_immune = (m.fear_immune or 0) + (self:attr("fear_immune") or 0) * perc / 100
		m.knockback_immune = (m.knockback_immune or 0) + (self:attr("knockback_immune") or 0) * perc / 100
		m.stone_immune = (m.stone_immune or 0) + (self:attr("stone_immune") or 0) * perc / 100
		m.teleport_immune = (m.teleport_immune or 0) + (self:attr("teleport_immune") or 0) * perc / 100
	end

	if game.party:hasMember(self) then
		local can_control = not no_control

		m.remove_from_party_on_death = true
		game.party:addMember(m, {
			control=can_control and "full" or "no",
			type="minion",
			title="Necrotic Minion",
			orders = {target=true},
		})
	end
	m:resolve() m:resolve(nil, true)
	m.max_level = self.level + (level or 0)
	m:forceLevelup(math.max(1, self.level + (level or 0)))
	game.zone:addEntity(game.level, m, "actor", x, y)
	game.level.map:particleEmitter(x, y, 1, "summon")

	-- Summons decay
	if not no_decay then
		m.on_act = function(self)
			local src = self.summoner
			local p = src:isTalentActive(src.T_NECROTIC_AURA)
			if p and self.x and self.y and not src.dead and src.x and src.y and core.fov.distance(self.x, self.y, src.x, src.y) <= self.summoner.necrotic_aura_radius then return end

			self.life = self.life - self.max_life * (p and p.necrotic_aura_decay or 10) / 100
			self.changed = true
			if self.life <= 0 then
				game.logSeen(self, "#{bold}#%s decays into a pile of ash!#{normal}#", self.name:capitalize())
				local t = src:getTalentFromId(src.T_NECROTIC_AURA)
				t.die_speach(self, t)
				self:die(self)
			end
		end
	end

	m.on_die = function(self, killer)
		local src = self.summoner
		local w = src:isTalentActive(src.T_WILL_O__THE_WISP)
		local p = src:isTalentActive(src.T_NECROTIC_AURA)
		if not w or not p or not self.x or not self.y or not src.x or not src.y or core.fov.distance(self.x, self.y, src.x, src.y) > self.summoner.necrotic_aura_radius then return end
		if not rng.percent(w.chance) then return end

		local t = src:getTalentFromId(src.T_WILL_O__THE_WISP)
		t.summon(src, t, w.dam, self, killer)
	end

	-- Summons never flee
	m.ai_tactic = m.ai_tactic or {}
	m.ai_tactic.escape = 0

	self:attr("summoned_times", 1)
end
-------------------------------------------


load("/data/talents/spells/arcane.lua")
load("/data/talents/spells/aether.lua")
load("/data/talents/spells/fire.lua")
load("/data/talents/spells/wildfire.lua")
load("/data/talents/spells/earth.lua")
load("/data/talents/spells/stone.lua")
load("/data/talents/spells/water.lua")
load("/data/talents/spells/ice.lua")
load("/data/talents/spells/air.lua")
load("/data/talents/spells/storm.lua")
load("/data/talents/spells/conveyance.lua")
load("/data/talents/spells/aegis.lua")
load("/data/talents/spells/meta.lua")
load("/data/talents/spells/divination.lua")
load("/data/talents/spells/temporal.lua")
load("/data/talents/spells/phantasm.lua")
load("/data/talents/spells/enhancement.lua")

load("/data/talents/spells/explosives.lua")
load("/data/talents/spells/infusion.lua")
load("/data/talents/spells/golemancy.lua")
load("/data/talents/spells/advanced-golemancy.lua")
load("/data/talents/spells/staff-combat.lua")
load("/data/talents/spells/fire-alchemy.lua")
load("/data/talents/spells/stone-alchemy.lua")
load("/data/talents/spells/golem.lua")

load("/data/talents/spells/necrotic-minions.lua")
load("/data/talents/spells/advanced-necrotic-minions.lua")
load("/data/talents/spells/nightfall.lua")
load("/data/talents/spells/shades.lua")
load("/data/talents/spells/necrosis.lua")
load("/data/talents/spells/grave.lua")
