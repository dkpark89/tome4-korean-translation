-- ToME - Tales of Maj'Eyal
-- Copyright (C) 2009 - 2015 Nicolas Casalini
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

uberTalent{
	name = "Spectral Shield",
	kr_name = "7색의 방패",
	mode = "passive",
	require = { special={desc="막기 값이 200 이상인 방패 막기 기술을 알고 있으며, 마법을 100 번 이상 사용했을 것", fct=function(self)
		return self:knowTalent(self.T_BLOCK) and self:getTalentFromId(self.T_BLOCK).getBlockValue(self) >= 200 and self.talent_kind_log and self.talent_kind_log.spell and self.talent_kind_log.spell >= 100
	end} },
	on_learn = function(self, t)
		self:attr("spectral_shield", 1)
	end,
	on_unlearn = function(self, t)
		self:attr("spectral_shield", -1)
	end,
	info = function(self, t)
		return ([[방패에 순수한 마력을 주입하여, 그 어떤 공격 속성도 방패를 뚫지 못하게 만듭니다.]])
		:format()
	end,
}

uberTalent{
	name = "Aether Permeation",
	kr_name = "에테르 침투",
	mode = "passive",
	require = { special={desc="마법 피해 감소량이 25% 이상이며, 공허의 공간에 노출된 적이 있을 것", fct=function(self)
		return (game.state.birth.ignore_prodigies_special_reqs or self:attr("planetary_orbit")) and self:combatGetResist(DamageType.ARCANE) >= 25
	end} },
	on_learn = function(self, t)
		local ret = {}
		self:talentTemporaryValue(ret, "force_use_resist", DamageType.ARCANE)
		self:talentTemporaryValue(ret, "force_use_resist_percent", 66)
		return ret
	end,
	on_unlearn = function(self, t)
	end,
	info = function(self, t)
		return ([[주변에 에테르로 이루어진 얇은 막을 만들어, 이 막을 뚫고 들어오는 모든 공격을 마법 저항력으로 저항할 수 있게 됩니다.
		이 효과로, 전체 저항력이 마법 저항력의 66%% 에 해당하는 값을 가지게 됩니다.]])
		:format()
	end,
}

uberTalent{
	name = "Mystical Cunning", image = "talents/vulnerability_poison.png",
	kr_name = "교활한 마법사",
	mode = "passive",
	require = { special={desc="독이나 함정을 다룰 수 있을 것", fct=function(self)
		return self:knowTalent(self.T_VILE_POISONS) or self:knowTalent(self.T_TRAP_MASTERY)
	end} },
	on_learn = function(self, t)
		self:attr("combat_spellresist", 20)
		if self:knowTalent(self.T_VILE_POISONS) then self:learnTalent(self.T_VULNERABILITY_POISON, true, nil, {no_unlearn=true}) end
		if self:knowTalent(self.T_TRAP_MASTERY) then self:learnTalent(self.T_GRAVITIC_TRAP, true, nil, {no_unlearn=true}) end
	end,
	on_unlearn = function(self, t)
		self:attr("combat_spellresist", -20)
	end,
	info = function(self, t)
		return ([[마법에 대한 연구를 통해 주문 내성이 20 상승하며, 새로운 함정과 독을 개발할 수 있게 됩니다. (해당 도구에 대한 기본적인 지식이 있어야 사용할 수 있습니다)
		- 약화의 독 : 전체 저항력을 감소시키고, 마법 피해를 줍니다.
		- 중력 함정 : 매 턴마다, 주변 5 칸 반경의 적들이 함정 중심으로 당겨지며 시간 피해를 입습니다.]])
		:format()
	end,
}

uberTalent{
	name = "Arcane Might",
	kr_name = "마법 완력",
	mode = "passive",
	info = function(self, t)
		return ([[잠재된 마력을 방출하여, 무기에 실어낼 수 있게 됩니다.
		무장한 무기의 적용 능력치에 마법 능력치의 50%% 만큼이 추가됩니다.]])
		:format()
	end,
}

uberTalent{
	name = "Temporal Form",
	kr_name = "시간의 모습",
	cooldown = 30,
	require = { special={desc="마법을 1,000 번 이상 사용하였으며, 시간 밖의 공간을 방문한 적이 있을 것", fct=function(self) return
		self.talent_kind_log and self.talent_kind_log.spell and self.talent_kind_log.spell >= 1000 and (game.state.birth.ignore_prodigies_special_reqs or self:attr("temporal_touched"))
	end} },
	no_energy = true,
	is_spell = true,
	requires_target = true,
	range = 10,
	tactical = { BUFF = 2 },
	action = function(self, t)
		self:setEffect(self.EFF_TEMPORAL_FORM, 10, {})
		return true
	end,
	info = function(self, t)
		return ([[시간의 실로 몸을 감싸, 10 턴 동안 시간의 정령인 텔루그로스로 변신합니다.
		속박, 출혈, 실명, 기절 상태효과에 완전 면역이 되며, 시간 저항력이 30%% 증가하고, 가장 높은 추가 피해량 수치 + 30%% 만큼 시간 피해를 추가로 줄 수 있게 되며, 모든 공격의 50%%는 시간 속성의 피해로 변환되어 주게 되고, 적의 시간 저항력을 20%% 무시할 수 있게 됩니다.
		또한, 두 가지 특수한 현상을 일으킬 수 있습니다. (이상 현상 : 재배열, 이상 현상 : 시간의 폭풍)
		변신 중에는 괴리 수치가 400 증가하지만, 늘어난 괴리를 제어할 수 있을 정도로 의지 역시 400 만큼 증가합니다. 변신이 풀리면 이 효과들은 복구됩니다.]])
		:format()
	end,
}

uberTalent{
	name = "Blighted Summoning",
	kr_name = "폐허의 소환술",
	mode = "passive",
	require = { special={desc="연금술사의 골렘을 다룰 수 있거나, 소환을 100 번 이상 해봤을 것", fct=function(self)
		return self:attr("summoned_times") and self:attr("summoned_times") >= 100
	end} },
	on_learn = function(self, t)
		local golem = self.alchemy_golem
		if not golem then return end
		golem:learnTalentType("corruption/reaving-combat", true)
		golem:learnTalent(golem.T_CORRUPTED_STRENGTH, true, 3)
	end,
	bonusTalentLevel = function(self, t) return math.ceil(3*self.level/50) end, -- Talent level for summons
	-- called by _M:addedToLevel and by _M:levelup in mod.class.Actor.lua
	doBlightedSummon = function(self, t, who)
		if not self:knowTalent(self.T_BLIGHTED_SUMMONING) then return false end
		if who.necrotic_minion then who:incIncStat("mag", self:getMag()) end
		local tlevel = self:callTalent(self.T_BLIGHTED_SUMMONING, "bonusTalentLevel")
		-- learn specified talent if present
		if who.blighted_summon_talent then 
			who:learnTalent(who.blighted_summon_talent, true, tlevel)
			if who.talents_def[who.blighted_summon_talent].mode == "sustained" then -- Activate sustained talents by default
				who:forceUseTalent(who.blighted_summon_talent, {ignore_energy=true})
			end 
		elseif who.name == "war hound" then
			who:learnTalent(who.T_CURSE_OF_DEFENSELESSNESS,true,tlevel)
		elseif who.subtype == "jelly" then
			who:learnTalent(who.T_VIMSENSE,true,tlevel)
		elseif who.subtype == "minotaur" then
			who:learnTalent(who.T_LIFE_TAP,true,tlevel)
		elseif who.name == "stone golem" then
			who:learnTalent(who.T_BONE_SPEAR,true,tlevel)
		elseif who.subtype == "ritch" then
			who:learnTalent(who.T_DRAIN,true,tlevel)
		elseif who.type =="hydra" then
			who:learnTalent(who.T_BLOOD_SPRAY,true,tlevel)
		elseif who.name == "rimebark" then
			who:learnTalent(who.T_POISON_STORM,true,tlevel)	
		elseif who.name == "treant" then
			who:learnTalent(who.T_CORROSIVE_WORM,true,tlevel)
		elseif who.name == "fire drake" then
			who:learnTalent(who.T_DARKFIRE,true,tlevel)
		elseif who.name == "turtle" then
			who:learnTalent(who.T_CURSE_OF_IMPOTENCE,true,tlevel)
		elseif who.subtype == "spider" then
			who:learnTalent(who.T_CORROSIVE_WORM,true,tlevel)
		elseif who.subtype == "skeleton" then
			who:learnTalent(who.T_BONE_GRAB,true,tlevel)
		elseif who.subtype == "giant" and who.undead then
			who:learnTalent(who.T_BONE_SHIELD,true,tlevel)
		elseif who.subtype == "ghoul" then
				who:learnTalent(who.T_BLOOD_LOCK,true,tlevel)
		elseif who.subtype == "vampire" or who.subtype == "lich" then
			who:learnTalent(who.T_DARKFIRE,true,tlevel)
		elseif who.subtype == "ghost" or who.subtype == "wight" then
			who:learnTalent(who.T_BLOOD_BOIL,true,tlevel)
		elseif who.subtype == "shadow" then
			local tl = who:getTalentLevelRaw(who.T_EMPATHIC_HEX)
			tl = tlevel-tl
			if tl > 0 then who:learnTalent(who.T_EMPATHIC_HEX, true, tl) end		
		elseif who.type == "thought-form" then
			who:learnTalent(who.T_FLAME_OF_URH_ROK,true,tlevel)
		elseif who.subtype == "yeek" then
			who:learnTalent(who.T_DARK_PORTAL, true, tlevel)
		elseif who.name == "bloated ooze" then
			who:learnTalent(who.T_BONE_SHIELD,true,math.ceil(tlevel*2/3))
		elseif who.name == "mucus ooze" then
			who:learnTalent(who.T_VIRULENT_DISEASE,true,tlevel)
		elseif who.name == "temporal hound" then
			who:learnTalent(who.T_ELEMENTAL_DISCORD,true,tlevel)
		else
--			print("Error: attempting to apply talent Blighted Summoning to incorrect creature type")
			return false
		end
		return true
	end,
	info = function(self, t)
		local tl = t.bonusTalentLevel(self, t)
		return ([[모든 소환수들에게 황폐의 힘을 주입하여, 새로운 기술을 사용할 수 있게 만듭니다 (기술 레벨 %d).
		- 전투견 : 무저항의 저주
		- 젤리 : 원혼의 기운
		- 미노타우르스 : 생명의 힘
		- 골렘 : 뼈의 창
		- 연금술 골렘 : 오염된 힘(레벨 3)과 오염된 전투 기술 계열
		- 불꽃뿜는 릿치 : 흡수
		- 히드라 : 피 뿌리기
		- 서리나무 : 독성 폭풍
		- 화염 드레이크 : 어둠의 불꽃
		- 거북이 : 무기력의 저주
		- 거미 : 부식성 벌레
		- 스켈레톤 : 뼈의 속박 혹은 뼈의 창
		- 해골 거인 : 뼈의 방패
		- 구울 : 피의 고정
		- 동료 구울 : 분쇄
		- 흡혈귀 / 리치 : 어둠의 불꽃
		- 유령 / 와이트 : 끓어오르는 피
		- 그림자 : 공감의 매혹술
		- 생각의 구현 : 울흐'록의 불꽃
		- 나무 정령 : 부식성 벌레
		- 이크 '한길'의 일원 : 어둠의 문
		- 진흙 덩어리 : 뼈의 방패 (레벨 %d)
		- 점액 덩어리 : 악성 질병
		또한, 어둠의 추종자들과 야생의 소환수들에게 시전자의 마법 능력치만큼 마법 능력치를 부여합니다.
		소환수들의 기술 레벨은 시전자의 레벨에 따라 증가하며, 종족이나 도구를 통한 소환물 역시 이 기술의 영향을 받습니다.
		]]):format(tl,math.ceil(tl*2/3))
	end,
-- Note: Choker of Dread Vampire, and Mummified Egg-sac of Ungol?spiders handled by default
-- Crystal Shard summons use specified talent
}

uberTalent{
	name = "Revisionist History",
	kr_name = "수정론자의 역사 기록법",
	cooldown = 30,
	no_energy = true,
	is_spell = true,
	no_npc_use = true,
	require = { special={desc="시간 여행을 경험해볼 것", fct=function(self) return game.state.birth.ignore_prodigies_special_reqs or (self:attr("time_travel_times") and self:attr("time_travel_times") >= 1) end} },
	action = function(self, t)
		if game._chronoworlds and game._chronoworlds.revisionist_history then
			self:hasEffect(self.EFF_REVISIONIST_HISTORY).back_in_time = true
			self:removeEffect(self.EFF_REVISIONIST_HISTORY)
			return nil -- the effect removal starts the cooldown
		end

		if checkTimeline(self) == true then return end

		game:onTickEnd(function()
			game:chronoClone("revisionist_history")
			self:setEffect(self.EFF_REVISIONIST_HISTORY, 19, {})
		end)
		return nil -- We do not start the cooldown!
	end,
	info = function(self, t)
		return ([[얼마 전의 과거를 조작할 수 있게 되어, 20 턴의 시간 조작 효과를 얻게 됩니다.
		이 기술을 사용하면, 기술이 지속되는 동안 이 기술을 다시 사용하여 언제든지 처음 기술을 사용한 순간으로 돌아올 수 있게 됩니다.
		이 기술은 시간의 흐름을 분절시키며, 효과의 지속시간 동안 시간의 흐름을 나누는 다른 마법은 사용할 수 없습니다.]])
		:format()
	end,
}
newTalent{
	name = "Unfold History", short_name = "REVISIONIST_HISTORY_BACK",
	kr_name = "역사 펼치기",
	type = {"uber/other",1},
	cooldown = 30,
	no_energy = true,
	is_spell = true,
	no_npc_use = true,
	action = function(self, t)
		if game._chronoworlds and game._chronoworlds.revisionist_history then
			self:hasEffect(self.EFF_REVISIONIST_HISTORY).back_in_time = true
			self:removeEffect(self.EFF_REVISIONIST_HISTORY)
			return nil -- the effect removal starts the cooldown
		end
		return nil -- We do not start the cooldown!
	end,
	info = function(self, t)
		return ([['수정론자의 역사 기록법' 이 지속되는 동안 사용할 수 있으며, 기술을 처음 사용한 순간으로 돌아가 역사를 다시 쓸 수 있게 됩니다.]])
		:format()
	end,
}

uberTalent{
	name = "Cauterize",
	kr_name = "과격한 응급치료",
	mode = "passive",
	cooldown = 12,
	require = { special={desc="총 7,500 이상의 화염 피해를 받았으며, 마법을 1,000 번 이상 사용했을 것", fct=function(self) return
		self.talent_kind_log and self.talent_kind_log.spell and self.talent_kind_log.spell >= 1000 and self.damage_intake_log and self.damage_intake_log[DamageType.FIRE] and self.damage_intake_log[DamageType.FIRE] >= 7500
	end} },
	trigger = function(self, t, value)
		self:startTalentCooldown(t)

		if self.player then world:gainAchievement("AVOID_DEATH", self) end
		self:setEffect(self.EFF_CAUTERIZE, 8, {dam=value/10})
		return true
	end,
	info = function(self, t)
		return ([[내면에 불꽃을 키워, 시전자의 목숨을 끊어버릴 일격이 날아오기 직전에 몸을 불태웁니다.
		불꽃은 상처를 급속도로 지져 해당 턴에 받은 피해를 무효화시키지만, 8 턴 동안 상처가 불타올라 매 턴마다 무효화시킨 피해량의 10% 에 해당하는 피해를 줍니다. 이 피해는 저항력이나 불에 대한 친화력을 무시합니다.
		유용하지만, 맹신할 수는 없습니다. '과격한' 응급치료일 뿐이고, 재사용 대기시간도 있으니까요.]])
	end,
}

