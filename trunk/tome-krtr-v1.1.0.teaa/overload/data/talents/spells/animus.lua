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

local Object = require "mod.class.Object"

newTalent{
	name = "Consume Soul",
	kr_name = "영혼 흡수",
	type = {"spell/animus",1},
	require = spells_req1,
	points = 5,
	soul = 1,
	cooldown = 10,
	tactical = { HEAL = 1, MANA = 1 },
	getHeal = function(self, t) return (40 + self:combatTalentSpellDamage(t, 10, 520)) * (necroEssenceDead(self, true) and 1.5 or 1) end,
	is_heal = true,
	action = function(self, t)
		self:attr("allow_on_heal", 1)
		self:heal(self:spellCrit(t.getHeal(self, t)), self)
		self:attr("allow_on_heal", -1)
		self:incMana(self:spellCrit(t.getHeal(self, t)) / 3, self)
		if core.shader.active(4) then
			self:addParticles(Particles.new("shader_shield_temp", 1, {toback=true , size_factor=1.5, y=-0.3, img="healdark", life=25}, {type="healing", time_factor=6000, beamsCount=15, noup=2.0, beamColor1={0xcb/255, 0xcb/255, 0xcb/255, 1}, beamColor2={0x35/255, 0x35/255, 0x35/255, 1}}))
			self:addParticles(Particles.new("shader_shield_temp", 1, {toback=false, size_factor=1.5, y=-0.3, img="healdark", life=25}, {type="healing", time_factor=6000, beamsCount=15, noup=1.0, beamColor1={0xcb/255, 0xcb/255, 0xcb/255, 1}, beamColor2={0x35/255, 0x35/255, 0x35/255, 1}}))
		end
		game:playSoundNear(self, "talents/heal")
		if necroEssenceDead(self, true) then necroEssenceDead(self)() end
		return true
	end,
	info = function(self, t)
		local heal = t.getHeal(self, t)
		return ([[사로잡은 원혼 하나를 흡수하여 생명력을 %d 만큼, 마나를 %d 만큼 회복합니다.
		생명력과 마나 회복량은 주문력의 영향을 받아 증가합니다.]]):
		format(heal, heal / 3)
	end,
}

newTalent{
	name = "Animus Hoarder",
	kr_name = "원한 수집가",
	type = {"spell/animus",2},
	require = spells_req2,
	mode = "sustained",
	points = 5,
	sustain_mana = 50,
	cooldown = 30,
	tactical = { BUFF = 3 },
	getMax = function(self, t) return math.floor(self:combatTalentScale(t, 2, 8)) end,
	getChance = function(self, t) return math.floor(self:combatTalentScale(t, 10, 80)) end,
	activate = function(self, t)
		local ret = {}
		self:talentTemporaryValue(ret, "max_soul", t.getMax(self, t))
		self:talentTemporaryValue(ret, "extra_soul_chance", t.getChance(self, t))
		return ret
	end,
	deactivate = function(self, t, p)
		return true
	end,
	info = function(self, t)
		local max, chance = t.getMax(self, t), t.getChance(self, t)
		return ([[영혼에 대한 당신의 갈망이 더 강해집니다. 적을 살해할 때마다 적의 원한을 끄집어내, %d%% 확률로 하나의 원혼을 더 얻을 수 있게 됩니다.
		또한, 최대로 소유할 수 있는 원혼이 %d 개 늘어나게 됩니다.]]):
		format(chance, max)
	end,
}

newTalent{
	name = "Animus Purge",
	kr_name = "영혼 제거",
	type = {"spell/animus",3},
	require = spells_req3,
	points = 5,
	mana = 50,
	soul = 4,
	cooldown = 15,
	range = 6,
	proj_speed = 20,
	requires_target = true,
	no_npc_use = true,
	direct_hit = function(self, t) if self:getTalentLevel(t) >= 3 then return true else return false end end,
	target = function(self, t)
		local tg = {type="hit", range=self:getTalentRange(t), talent=t}
		return tg
	end,
	getMaxLife = function(self, t) return self:combatTalentLimit(t, 50, 10, 25) end,
	getDamage = function(self, t) return self:combatTalentSpellDamage(t, 35, 330) end,
	on_pre_use = function(self, t)
		if game.party and game.party:hasMember(self) then
			for act, def in pairs(game.party.members) do
				if act.summoner and act.summoner == self then
					if act.type == "undead" and act.subtype == "husk" then return false end
				end
			end
			return true
		else return false end
	end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		self:project(tg, x, y, function(px, py)
			local m = game.level.map(px, py, Map.ACTOR)
			if not m or not m.max_life or not m.life then return end
			local dam = self:spellCrit(t.getDamage(self, t))
			local olddie = rawget(m, "die")
			m.die = function() end
			DamageType:get(DamageType.DARKNESS).projector(self, px, py, DamageType.DARKNESS, dam)
			m.die = olddie
			game.level.map:particleEmitter(px, py, 1, "dark")
			if 100 * m.life / m.max_life <= t.getMaxLife(self, t) and self:checkHit(self:combatSpellpower(), m:combatSpellResist()) and m:canBe("instakill") and m.rank <= 3.2 and not m:attr("undead") and not m.summoner and not m.summon_time then
				m.type = "undead"
				m.subtype = "husk"
				m:attr("no_life_regen", 1)
				m:attr("no_healing", 1)
				m.ai_state.tactic_leash = 100
				m.remove_from_party_on_death = true
				m.no_inventory_access = true
				m.no_party_reward = true
				m.life = m.max_life
				m.move_others = true
				m.summoner = self
				m.summoner_gain_exp = true
				m.unused_stats = 0
				m.dead = nil
				m.undead = 1
				m.no_breath = 1
				m.unused_talents = 0
				m.unused_generics = 0
				m.unused_talents_types = 0
				m.silent_levelup = true
				m.clone_on_hit = nil
				if m:knowTalent(m.T_BONE_SHIELD) then m:unlearnTalent(m.T_BONE_SHIELD, m:getTalentLevelRaw(m.T_BONE_SHIELD)) end
				if m:knowTalent(m.T_MULTIPLY) then m:unlearnTalent(m.T_MULTIPLY, m:getTalentLevelRaw(m.T_MULTIPLY)) end
				if m:knowTalent(m.T_SUMMON) then m:unlearnTalent(m.T_SUMMON, m:getTalentLevelRaw(m.T_SUMMON)) end
				m.no_points_on_levelup = true
				m.faction = self.faction

				m.on_act = function(self)
					if game.player ~= self then return end
					if not self.summoner.dead and not self:hasLOS(self.summoner.x, self.summoner.y) then
						if not self:hasEffect(self.EFF_HUSK_OFS) then
							self:setEffect(self.EFF_HUSK_OFS, 3, {})
						end
					else
						if self:hasEffect(self.EFF_HUSK_OFS) then
							self:removeEffect(self.EFF_HUSK_OFS)
						end
					end
				end

				m.on_can_control = function(self, vocal)
					if not self:hasLOS(self.summoner.x, self.summoner.y) then
						if vocal then game.logPlayer(game.player, "하수인이 시야에서 벗어났습니다. 하수인을 직접 조종할 수 없게 됩니다.") end
						return false
					end
					return true
				end

				m:removeEffectsFilter({status="detrimental"}, nil, true)
				game.level.map:particleEmitter(px, py, 1, "demon_teleport")

				applyDarkEmpathy(self, m)

				game.party:addMember(m, {
					control="full",
					type="husk",
					title="Lifeless Husk",
					orders = {leash=true, follow=true},
					on_control = function(self)
						self:hotkeyAutoTalents()
					end,
				})
				game:onTickEnd(function() self:incSoul(2) end)

				self:logCombat(m, "#GREY##Source# 이(가) #target# 의 영혼을 제거하여, 언데드 하수인으로 만들었습니다.")
			end
		end)

		game:playSoundNear(self, "talents/spell_generic")
		return true
	end,
	info = function(self, t)
		local damage = t.getDamage(self, t)
		return ([[적의 영혼을 부숴, %0.2f 암흑 피해를 줍니다. (이 공격으로는 대상을 죽일 수 없습니다)
		만약 대상의 생명력이 %d%% 이하가 된다면, 대상의 육신을 자신의 것으로 만들 수 있는 기회가 생기게 됩니다.
		성공할 경우 원혼을 2 얻게 되며, 대상은 당신의 (사령술의 기운에 영향을 받지 않는) 영구적인 하수인이 됩니다.
		대상의 육신은 생전의 능력을 그대로 사용할 수 있으며, 어둠의 공감 기술 역시 적용됩니다.
		대상의 육신을 하수인으로 만들면 대상의 생명력이 완전히 회복되지만, 이후 어떤 방법으로도 대상의 생명력은 회복되지 않습니다.
		한번에 하나의 육신만을 조종할 수 있습니다.
		보스, 언데드, 소환된 적은 조종할 수 없습니다.
		피해량과 성공 확률은 주문력의 영향을 받아 증가합니다.]]):
		format(damDesc(self, DamageType.DARKNESS, damage), t.getMaxLife(self, t))
	end,
}

newTalent{
	name = "Essence of the Dead",
	kr_name = "죽은 자의 정수",
	type = {"spell/animus",4},
	require = spells_req4,
	points = 5,
	mana = 20,
	soul = 2,
	cooldown = 20,
	tactical = { BUFF = 3 },
	getnb = function(self, t) return math.floor(self:combatTalentScale(t, 1, 5)) end,
	action = function(self, t)
		self:setEffect(self.EFF_ESSENCE_OF_THE_DEAD, 1, {nb=t.getnb(self, t)})
		return true
	end,
	info = function(self, t)
		local nb = t.getnb(self, t)
		return ([[사로잡은 원혼 두 개를 흡수하여, 다음에 사용하는 주문 %d 개를 강화시킵니다.
		이 기술에 영향을 받는 주문은 다음과 같습니다.
		- 불사의 연결고리 : 생명력 흡수량의 절반만큼 보호막이 추가로 생성됩니다.
		- 추종자 생성 : 추종자를 2 마리 추가로 소환할 수 있게 됩니다.
		- 결합 : 두 번째 해골 거인을 소환할 수 있게 됩니다.
		- 어둠 화살 : 어둠이 전방의 모든 적에게 피해를 주게 됩니다.
		- 그림자 통로 : 순간이동한 추종자들이 최대 생명력의 30%% 만큼 생명력을 회복하게 됩니다.
		- 차가운 불꽃 : 빙결 시도 확률이 100%% 가 됩니다.
		- 얼음 파편 : 각각의 파편들이 적을 관통할 수 있게 됩니다.
		- 영혼 흡수 : 회복 효율이 50%% 증가하게 됩니다.]]):
		format(nb)
	end,
}
