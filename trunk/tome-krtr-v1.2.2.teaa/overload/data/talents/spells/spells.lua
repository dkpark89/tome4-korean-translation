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

-- Archmage spells
newTalentType{ allow_random=true, no_silence=true, is_spell=true, mana_regen=true, type="spell/arcane", name = "arcane", description = "가공되지 않은 마력을 다뤄, 적들을 공격하고 자신을 보호하는 마법입니다." }
newTalentType{ allow_random=true, no_silence=true, is_spell=true, mana_regen=true, type="spell/aether", name = "aether", description = "마력의 정수라고 할 수 있는 에테르의 힘을 다뤄, 적들에게 파멸을 불러오는 마법입니다." }

-- Elemental spells
newTalentType{ allow_random=true, no_silence=true, is_spell=true, mana_regen=true, type="spell/fire", name = "fire", description = "불꽃의 힘을 활용하여, 적들을 불태우는 마법입니다." }
newTalentType{ allow_random=true, no_silence=true, is_spell=true, mana_regen=true, type="spell/wildfire", name = "wildfire", min_lev = 10, description = "맹화의 힘을 활용하여, 적들을 한 줌 재로 만들어버리는 마법입니다." }
newTalentType{ allow_random=true, no_silence=true, is_spell=true, mana_regen=true, type="spell/earth", name = "earth", description = "땅의 힘을 활용하여, 보호와 공격을 동시에 하는 마법입니다." }
newTalentType{ allow_random=true, no_silence=true, is_spell=true, mana_regen=true, type="spell/stone", name = "stone", min_lev = 10, description = "암석의 힘을 활용하여, 수호와 파괴를 동시에 하는 마법입니다." }
newTalentType{ allow_random=true, no_silence=true, is_spell=true, mana_regen=true, type="spell/water", name = "water", description = "물의 힘을 활용하여, 적들을 익사시키는 마법입니다." }
newTalentType{ allow_random=true, no_silence=true, is_spell=true, mana_regen=true, type="spell/ice", name = "ice", min_lev = 10, description = "얼음의 힘을 활용하여, 적들을 얼리고 부수는 마법입니다." }
newTalentType{ allow_random=true, no_silence=true, is_spell=true, mana_regen=true, type="spell/air", name = "air", description = "전기의 힘으로, 적을 튀겨버리는 마법입니다." }
newTalentType{ allow_random=true, no_silence=true, is_spell=true, mana_regen=true, type="spell/storm", name = "storm", min_lev = 10, description = "폭풍의 힘으로, 적들을 소각해버리는 마법입니다." }

-- Various other magic schools
newTalentType{ allow_random=true, no_silence=true, is_spell=true, mana_regen=true, type="spell/meta", name = "meta", description = "마법의 기초를 수련하여, 모든 마법을 강화합니다." }
newTalentType{ allow_random=true, no_silence=true, is_spell=true, mana_regen=true, type="spell/temporal", name = "temporal", description = "시간을 다루는 마법 학파입니다." }
newTalentType{ allow_random=true, no_silence=true, is_spell=true, mana_regen=true, type="spell/phantasm", name = "phantasm", description = "속임수와 환영을 다루는 마법 학파입니다." }
newTalentType{ allow_random=true, no_silence=true, is_spell=true, mana_regen=true, type="spell/enhancement", name = "enhancement", description = "마법을 이용한 신체 능력 향상법입니다." }
newTalentType{ allow_random=true, no_silence=true, is_spell=true, type="spell/conveyance", name = "conveyance", generic = true, description = "더 빨리 이동하고, 적을 추적하기 위한 마법 학파입니다." }
newTalentType{ allow_random=true, no_silence=true, is_spell=true, type="spell/divination", name = "divination", generic = true, description = "주변을 탐색하고, 숨겨진 것을 찾을 수 있는 마법 학파입니다." }
newTalentType{ allow_random=true, no_silence=true, is_spell=true, type="spell/aegis", name = "aegis", generic = true, description = "치료와 보호에 특화된 마법 학파입니다." }

-- Alchemist spells
newTalentType{ allow_random=true, no_silence=true, is_spell=true, mana_regen=true, type="spell/explosives", name = "explosive admixtures", description = "연금술로 보석을 폭탄으로 바꾸고, 그것을 다루는 방법입니다." }
newTalentType{ allow_random=true, no_silence=true, is_spell=true, mana_regen=true, type="spell/infusion", name = "infusion", description = "연금술 폭탄에 다양한 속성의 힘을 주입하는 방법입니다." }
newTalentType{ allow_random=true, no_silence=true, is_spell=true, mana_regen=true, type="spell/golemancy-base", name = "golemancy", hide = true, description = "골렘을 만드는 기초적인 방법입니다." }
newTalentType{ allow_random=true, no_silence=true, is_spell=true, mana_regen=true, type="spell/golemancy", name = "golemancy", description = "골렘을 만들고, 수리하고, 강화하는 방법입니다." }
newTalentType{ allow_random=true, no_silence=true, is_spell=true, mana_regen=true, type="spell/advanced-golemancy", name = "advanced-golemancy", min_lev = 10, description = "더 강력한 골렘을 만들고, 조작하는 방법입니다." }
newTalentType{ allow_random=true, no_silence=true, is_spell=true, mana_regen=true, type="spell/war-alchemy", name = "fire alchemy", description = "Alchemical spells designed to wage war." } --@ 원래 이름이 "war alchemy"가 아님 --@@ 한글화 필요
newTalentType{ allow_random=true, no_silence=true, is_spell=true, mana_regen=true, type="spell/fire-alchemy", name = "fire alchemy", description = "연금술을 이용하여 불을 다루는 방법입니다." }
newTalentType{ allow_random=true, no_silence=true, is_spell=true, mana_regen=true, type="spell/acid-alchemy", name = "acid alchemy", description = "Alchemical control over acid." } --@@ 한글화 필요
newTalentType{ allow_random=true, no_silence=true, is_spell=true, mana_regen=true, type="spell/frost-alchemy", name = "frost alchemy", description = "Alchemical control over frost." } --@@ 한글화 필요
newTalentType{ allow_random=true, no_silence=true, is_spell=true, mana_regen=true, type="spell/energy-alchemy", name = "energy alchemy", min_lev = 10, description = "Alchemical control over lightning energies." } --@@ 한글화 필요
newTalentType{ allow_random=true, no_silence=true, is_spell=true, type="spell/stone-alchemy-base", name = "stone alchemy", hide = true, description = "보석을 다루고, 그 힘을 이용하는 기초적인 방법입니다." }
newTalentType{ allow_random=true, no_silence=true, is_spell=true, type="spell/stone-alchemy", name = "stone alchemy", generic = true, description = "다양한 보석을 다루고, 그 힘을 이용하는 방법입니다." }
newTalentType{ allow_random=true, no_silence=true, is_spell=true, type="spell/staff-combat", name = "staff combat", generic = true, description = "마법 지팡이의 힘을 이용하는 방법입니다." }
newTalentType{ type="golem/fighting", name = "fighting", description = "골렘의 전투 능력입니다." }
newTalentType{ type="golem/arcane", no_silence=true, is_spell=true, name = "arcane", description = "골렘의 마법 능력입니다." }
newTalentType{ type="golem/golem", name = "golem", description = "골렘의 기본 능력입니다." }
newTalentType{ type="golem/drolem", name = "drolem", description = "드롤렘의 기본 능력입니다." } 

-- Necromancer spells
newTalentType{ allow_random=true, no_silence=true, is_spell=true, mana_regen=true, type="spell/necrotic-minions", name = "necrotic minions", description = "언데드 추종자를 만들고 다루는 법입니다." }
newTalentType{ allow_random=true, no_silence=true, is_spell=true, mana_regen=true, type="spell/advanced-necrotic-minions", name = "advanced necrotic minions", min_lev = 10, description = "강력한 언데드 추종자를 만들고 다루는 법입니다." }
newTalentType{ allow_random=true, no_silence=true, is_spell=true, mana_regen=true, type="spell/nightfall", name = "nightfall", description = "적을 죽이기 위해, 어둠 그 자체를 다루는 마법입니다." }
newTalentType{ allow_random=true, no_silence=true, is_spell=true, mana_regen=true, type="spell/shades", name = "shades", min_lev = 10, description = "그림자를 조종하고 불러오는 마법입니다." }
newTalentType{ allow_random=true, no_silence=true, is_spell=true, mana_regen=true, type="spell/necrosis", name = "necrosis", description = "죽음을 넘어, 최종적으로는 리치가 되는 사령술입니다." }
newTalentType{ allow_random=true, no_silence=true, is_spell=true, mana_regen=true, type="spell/grave", name = "grave", description = "묘지의 차갑고 절망적인 기운을 이용하여, 적들을 나락으로 떨어뜨리는 마법입니다." }
newTalentType{ allow_random=true, no_silence=true, is_spell=true, mana_regen=true, type="spell/animus", name = "animus", description = "적의 영혼을 부숴, 자신을 강화시키는 마법입니다." } 

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

function applyDarkEmpathy(self, m)
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

		m.necrotic_minion_be_nice = self:getTalentLevelRaw(self.T_DARK_EMPATHY) * 0.2
	end
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

	applyDarkEmpathy(self, m)

	if game.party:hasMember(self) then
		local can_control = not no_control

		m.remove_from_party_on_death = true
		game.party:addMember(m, {
			control=can_control and "full" or "no",
			type="minion",
			title="Necrotic Minion", kr_title="언데드 추종자",
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
		m.necrotic_aura_decaying = self.necrotic_aura_decay
		m.on_act = function(self)
			local src = self.summoner
			if src and self.necrotic_aura_decaying and self.x and self.y and not src.dead and src.x and src.y and core.fov.distance(self.x, self.y, src.x, src.y) <= (src.necrotic_aura_radius or 0) then return end

			self.life = self.life - self.max_life * (self.necrotic_aura_decaying or 10) / 100
			self.changed = true
			if self.life <= 0 then
				game.logSeen(self, "#{bold}#%s 부패하여 잿덩이로 변했습니다!#{normal}#", (self.kr_name or self.name):capitalize():addJosa("가"))
				if src then
					local t = src:getTalentFromId(src.T_NECROTIC_AURA)
					t.die_speach(self, t)
				end
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

function necroEssenceDead(self, checkonly)
	local eff = self:hasEffect(self.EFF_ESSENCE_OF_THE_DEAD)
	if not eff then return false end
	if checkonly then return true end
	return function()
		eff.nb = eff.nb - 1
		if eff.nb <= 0 then self:removeEffect(self.EFF_ESSENCE_OF_THE_DEAD, true) end
	end
end
-------------------------------------------

function cancelAlchemyInfusions(self)
	local chants = {self.T_FIRE_INFUSION, self.T_FROST_INFUSION, self.T_ACID_INFUSION, self.T_LIGHTNING_INFUSION}
	for i, t in ipairs(chants) do
		if self:isTalentActive(t) then
			self:forceUseTalent(t, {ignore_energy=true})
		end
	end
end


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
load("/data/talents/spells/golemancy.lua")
load("/data/talents/spells/advanced-golemancy.lua")
load("/data/talents/spells/staff-combat.lua")
load("/data/talents/spells/war-alchemy.lua")
load("/data/talents/spells/fire-alchemy.lua")
load("/data/talents/spells/frost-alchemy.lua")
load("/data/talents/spells/acid-alchemy.lua")
load("/data/talents/spells/energy-alchemy.lua")
load("/data/talents/spells/stone-alchemy.lua")
load("/data/talents/spells/golem.lua")

load("/data/talents/spells/necrotic-minions.lua")
load("/data/talents/spells/advanced-necrotic-minions.lua")
load("/data/talents/spells/nightfall.lua")
load("/data/talents/spells/shades.lua")
load("/data/talents/spells/necrosis.lua")
load("/data/talents/spells/grave.lua")
load("/data/talents/spells/animus.lua")
