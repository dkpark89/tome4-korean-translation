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

newTalent{
	name = "Blurred Mortality",
	kr_name = "희미해진 필멸성",
	type = {"spell/necrosis",1},
	require = spells_req1,
	mode = "sustained",
	points = 5,
	sustain_mana = 30,
	cooldown = 30,
	tactical = { BUFF = 2 },
	activate = function(self, t)
		if self.player and not self:hasQuest("lichform") and not self:attr("undead") then
			self:grantQuest("lichform")
			if game.state.birth.campaign_name ~= "maj-eyal" then self:setQuestStatus("lichform", engine.Quest.DONE) end
			require("engine.ui.Dialog"):simplePopup("Lichform", "죽음을 극복하는 첫걸음을 성공적으로 내딛었지만, 진정한 불사는 이 마법으로 달성할 수 없습니다 : 오직 리치가 되는 것만이 진정한 불멸자가 되는 방법입니다!")
		end

		local ret = {
			die_at = self:addTemporaryValue("die_at", -50 * self:getTalentLevelRaw(t)),
		}
		return ret
	end,
	deactivate = function(self, t, p)
		self:removeTemporaryValue("die_at", p.die_at)
		return true
	end,
	info = function(self, t)
		return ([[삶과 죽음의 경계가 모호해져, 생명력이 -%d 까지 떨어져야 사망합니다.
		하지만 생명력이 0 이하로 떨어지면, 현재 생명력을 확인할 수 없게 됩니다.]]):
		format(50 * self:getTalentLevelRaw(t))
	end,
}

newTalent{
	name = "Impending Doom",
	kr_name = "임박한 종말",
	type = {"spell/necrosis",2},
	require = spells_req2,
	points = 5,
	mana = 70,
	cooldown = 30,
	tactical = { ATTACK = { ARCANE = 3 }, DISABLE = 2 },
	range = 7,
	requires_target = true,
	getMax = function(self, t) return 200 + self:combatTalentSpellDamage(t, 28, 850) end,
	getDamage = function(self, t) return 50 + self:combatTalentSpellDamage(t, 10, 100) end,
	action = function(self, t)
		local tg = {type="hit", range=self:getTalentRange(t), talent=t}
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		self:project(tg, x, y, function(px, py)
			local target = game.level.map(px, py, Map.ACTOR)
			if not target then return end
			local dam = target.life * t.getDamage(self, t) / 100
			dam = math.min(dam, t.getMax(self, t))
			target:setEffect(target.EFF_IMPENDING_DOOM, 10, {apply_power=self:combatSpellpower(), dam=dam/10, src=self})
		end, 1, {type="freeze"})
		return true
	end,
	info = function(self, t)
		return ([[대상의 종말을 앞당깁니다. 대상은 치유 효율이 100%% 감소하며, 10 턴 동안 남은 생명력의 %d%% 에 해당하는 마법 피해 또는 %0.2f 마법 피해를 나눠서 입게 됩니다. (둘 중 더 작은 쪽)
		피해량은 주문력의 영향을 받아 증가합니다.]]):
		format(t.getDamage(self, t), t.getMax(self, t))
	end,
}

newTalent{
	name = "Undeath Link",
	kr_name = "불사의 연결고리",
	type = {"spell/necrosis",3},
	require = spells_req3,
	points = 5,
	random_ego = "attack",
	mana = 35,
	cooldown = 20,
	tactical = { HEAL = 2 },
	is_heal = true,
	getHeal = function(self, t) return 20 + self:combatTalentSpellDamage(t, 10, 70) end,
	on_pre_use = function(self, t)
		if game.party and game.party:hasMember(self) then
			for act, def in pairs(game.party.members) do
				if act.summoner and act.summoner == self and act.necrotic_minion then
					return true
				end
			end
		else
			for uid, act in pairs(game.level.entities) do
				if act.summoner and act.summoner == self and act.necrotic_minion then
					return true
				end
			end
		end
		return false
	end,
	action = function(self, t)
		local heal = t.getHeal(self, t)
		if game.party and game.party:hasMember(self) then
			for act, def in pairs(game.party.members) do
				if act.summoner and act.summoner == self and act.necrotic_minion then
					act:takeHit(act.max_life * heal / 100, self)
				end
			end
		else
			for uid, act in pairs(game.level.entities) do
				if act.summoner and act.summoner == self and act.necrotic_minion then
					act:takeHit(act.max_life * heal / 100, self)
				end
			end
		end
		self:attr("allow_on_heal", 1)
		self:heal(self.max_life * heal / 100)
		self:attr("allow_on_heal", -1)
		game:playSoundNear(self, "talents/ice")
		return true
	end,
	info = function(self, t)
		local heal = t.getHeal(self, t)
		return ([[모든 언데드 추종자로부터 최대 생명력의 %d%% 만큼 생명력을 흡수합니다. 그리고 이를 이용하여, 시전자의 생명력을 최대 생명력의 %d%% 만큼 회복합니다.
		언데드 추종자는 이 흡수로 인해 파괴될 수도 있으며, 치유량은 주문력의 영향을 받아 증가합니다.]]):
		format(heal, heal)
	end,
}

newTalent{
	name = "Lichform",
	kr_name = "리치 변신",
	type = {"spell/necrosis",4},
	require = {
		stat = { mag=function(level) return 40 + (level-1) * 2 end },
		level = function(level) return 20 + (level-1)  end,
		special = { desc="'죽음에서, 삶으로' 퀘스트를 완료하였으며, 리치가 아닐 것", fct=function(self, t) return not self:attr("undead") and self:isQuestStatus("lichform", engine.Quest.DONE) end},
	},
	mode = "sustained",
	points = 5,
	sustain_mana = 150,
	cooldown = 30,
	no_unlearn_last = true,
	no_npc_use = true,
	becomeLich = function(self, t)
		self.has_used_lichform = true
		self.descriptor.race = "Undead"
		self.descriptor.subrace = "Lich"
		if not self.has_custom_tile then
			self.moddable_tile = "skeleton"
			self.moddable_tile_nude = true
			self.moddable_tile_base = "base_lich_01.png"
			self.moddable_tile_ornament = nil
		end
		self.blood_color = colors.GREY
		self:attr("poison_immune", 1)
		self:attr("disease_immune", 0.5)
		self:attr("stun_immune", 0.5)
		self:attr("cut_immune", 1)
		self:attr("fear_immune", 1)
		self:attr("no_breath", 1)
		self:attr("undead", 1)
		self.resists[DamageType.COLD] = (self.resists[DamageType.COLD] or 0) + 20
		self.resists[DamageType.DARKNESS] = (self.resists[DamageType.DARKNESS] or 0) + 20
		self.inscription_restrictions = self.inscription_restrictions or {}
		self.inscription_restrictions["inscriptions/runes"] = true
		self.inscription_restrictions["inscriptions/taints"] = true

		local level = self:getTalentLevel(t)
		if level < 2 then
			self:incIncStat("mag", -3) self:incIncStat("wil", -3)
			self.resists.all = (self.resists.all or 0) - 10
		elseif level < 3 then
			-- nothing
		elseif level < 4 then
			self:incIncStat("mag", 3) self:incIncStat("wil", 3)
			self.life_rating = self.life_rating + 1
		elseif level < 5 then
			self:incIncStat("mag", 3) self:incIncStat("wil", 3)
			self:attr("combat_spellresist", 10) self:attr("combat_mentalresist", 10)
			self.life_rating = self.life_rating + 2
			self:learnTalentType("celestial/star-fury", true)
			self:setTalentTypeMastery("celestial/star-fury", self:getTalentTypeMastery("celestial/star-fury") - 0.3)
			self.negative_regen = self.negative_regen + 0.2 + 0.1
		elseif level < 6 then
			self:incIncStat("mag", 5) self:incIncStat("wil", 5)
			self:attr("combat_spellresist", 10) self:attr("combat_mentalresist", 10)
			self.resists_cap.all = (self.resists_cap.all or 0) + 10
			self.life_rating = self.life_rating + 2
			self:learnTalentType("celestial/star-fury", true)
			self:setTalentTypeMastery("celestial/star-fury", self:getTalentTypeMastery("celestial/star-fury") - 0.1)
			self.negative_regen = self.negative_regen + 0.2 + 0.5
		else
			self:incIncStat("mag", 6) self:incIncStat("wil", 6) self:incIncStat("cun", 6)
			self:attr("combat_spellresist", 15) self:attr("combat_mentalresist", 15)
			self.resists_cap.all = (self.resists_cap.all or 0) + 15
			self.life_rating = self.life_rating + 3
			self:learnTalentType("celestial/star-fury", true)
			self:setTalentTypeMastery("celestial/star-fury", self:getTalentTypeMastery("celestial/star-fury") + 0.1)
			self.negative_regen = self.negative_regen + 0.2 + 1
		end

		if self:attr("blood_life") then
			self.blood_life = nil
			game.log("#GREY#강력한 언데드로 변신하자, 당신의 육체가 떨리면서 생명의 피를 거부하는 것을 느낍니다.")
		end

		require("engine.ui.Dialog"):simplePopup("리치 변신", "#GREY#당신의 생명력이 빠져나가고, 순수한 마법의 힘이 그 자리를 대신합니다! 당신의 살은 썩어 뼈만 남고, 눈이 떨어져 나가면서 리치로 다시 태어났습니다!")

		game.level.map:particleEmitter(self.x, self.y, 1, "demon_teleport")
	end,
	on_pre_use = function(self, t)
		if self:attr("undead") then return false else return true end
	end,
	activate = function(self, t)
		local ret = {
			mana = self:addTemporaryValue("mana_regen", -4),
		}
		return ret
	end,
	deactivate = function(self, t, p)
		self:removeTemporaryValue("mana_regen", p.mana)
		return true
	end,
	info = function(self, t)
		return ([[모든 사령술사들의 꿈이자 진정한 목표, 영원히 죽지 않는 리치가 됩니다!
		이 기술을 활성화시킨 상태에서 죽으면, 마력이 육신을 강제로 재구성하여 그렇게 염원하던 리치가 될 수 있습니다.
		리치가 되면 기본적으로 다음과 같은 특성을 얻게 됩니다.
		- 중독, 출혈, 공포 상태효과 완전 면역
		- 기절, 질병 면역력 50%% 증가
		- 냉기, 어둠 저항력 20%% 증가
		- 호흡이 필요없어짐
		- 주입물 사용 불가
		그리고 기술 레벨에 따라, 다음과 같은 특성을 얻습니다. (이 특성들은 누적되지 않습니다!)
		기술 레벨 1 : 모든 능력치가 3 감소하며, 전체 저항력이 10%% 감소합니다. 허약한 리치로군요!
		기술 레벨 2 : 능력치 증감 효과가 없습니다.
		기술 레벨 3 : 마법과 의지 능력치가 3 증가하고, 1 번 부활할 수 있게 됩니다.
		기술 레벨 4 : 마법과 의지 능력치가 3 증가하고, 2 번 부활할 수 있게 됩니다. 주문 내성과 정신 내성이 10 증가합니다. 천공 / 별의 분노 계열을 (x0.7) 적성으로 사용할 수 있게 되며, 턴 당 음기 재생이 0.1 증가합니다.
		기술 레벨 5 : 마법과 의지 능력치가 5 증가하고, 2 번 부활할 수 있게 됩니다. 주문 내성과 정신 내성이 10 증가하며, 전체 저항력의 최대치가 10%% 증가합니다. 천공 / 별의 분노 계열을 (x0.9) 적성으로 사용할 수 있게 되며, 턴 당 음기 재생이 0.5 증가합니다.
		기술 레벨 6 : 마법과 의지 능력치가 6 증가하고, 3 번 부활할 수 있게 됩니다. 주문 내성과 정신 내성이 15 증가하며, 전체 저항력의 최대치가 15%% 증가합니다. 천공 / 별의 분노 계열을 (x1.1) 적성으로 사용할 수 있게 되며, 턴 당 음기 재생이 1.0 증가합니다. 나의 힘 앞에 무릎 꿇으라!
		언데드 종족은 리치가 될 수 없습니다.
		이 기술을 활성화시키면, 턴 당 마나가 4 소진됩니다.
		한번 죽어서 리치로 변하면, 이 기술을 더 이상 강화시킬 수 없게 됩니다.]]):
		format()
	end,
}
