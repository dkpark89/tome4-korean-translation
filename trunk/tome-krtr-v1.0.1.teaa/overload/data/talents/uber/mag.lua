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

uberTalent{
	name = "Spectral Shield",
	kr_name = "7색의 방패",
	mode = "passive",
	require = { special={desc="방패 막기 기술을 알고 있으며, 방패로 200 회 이상의 공격을 막았으며, 마법을 100 번 이상 사용했을 것", fct=function(self)
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
		self:learnTalent(self.T_VULNERABILITY_POISON, true, nil, {no_unlearn=true})
		self:learnTalent(self.T_GRAVITIC_TRAP, true, nil, {no_unlearn=true})
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
		무기의 적용 능력치에 마법 능력치의 50%% 만큼이 추가됩니다.]])
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
		속박, 출혈, 실명, 기절 상태효과에 완전 면역이 되며, 시간 저항력이 30%% 증가하고, 가장 높은 추가 피해량 수치 + 30%% 만큼 시간 피해를 추가로 줄 수 있게 되며, 모든 공격이 시간 피해를 주게 되고, 적의 시간 저항력을 20%% 무시할 수 있게 됩니다.
		또한, 두 가지 특수한 현상을 일으킬 수 있습니다. (이상 현상 : 재배열, 이상 현상 : 시간의 폭풍)
		변신 중에는 괴리 수치가 600 증가하지만, 늘어난 괴리를 제어할 수 있을 정도로 의지 역시 증가합니다. 변신이 풀리면 이 효과들은 복구됩니다.]])
		:format()
	end,
}

uberTalent{
	name = "Blighted Summoning",
	kr_name = "폐허의 소환술",
	mode = "passive",
	on_learn = function(self, t)
		if self.alchemy_golem then 
			self.alchemy_golem:learnTalent(self.alchemy_golem.T_CORRUPTED_STRENGTH, true, 1, {no_unlearn=true})
			self.alchemy_golem:learnTalentType("corruption/reaving-combat", true)
		end
	end,
	require = { special={desc="연금술사의 골렘을 다룰 수 있거나, 소환을 100 번 이상 해봤을 것", fct=function(self)
		return self:attr("summoned_times") and self:attr("summoned_times") >= 100
	end} },
	info = function(self, t)
		return ([[모든 소환수들에게 황폐의 힘을 주입하여, 새로운 기술을 사용할 수 있게 만듭니다.
		- 전투견 : 무저항의 저주
		- 젤리 : 원혼의 기운
		- 미노타우르스 : 생명의 힘
		- 골렘 : 뼈의 창
		- 불꽃뿜는 릿치 : 흡수
		- 히드라 : 피 뿌리기
		- 서리나무 : 독성 폭풍
		- 화염 드레이크 : 어둠의 불꽃
		- 거북이 : 무기력의 저주
		- 거미 : 부식성 벌레
		- 스켈레톤 : 뼈의 속박
		- 해골 거인 : 뼈의 방패
		- 구울 : 피의 고정
		- 흡혈귀 / 리치 : 어둠의 불꽃
		- 유령 / 와이트 : 끓어오르는 피
		- 연금술 골렘 : 오염된 힘과 오염된 전투 기술 계열
		- 그림자 : 공감의 매혹술
		- 생각의 구현 : 울흐'록의 불꽃
		- 나무 정령 : 부식성 벌레
		- 이크 '한길'의 일원 : 어둠의 문
		- 동료 구울 : 분쇄
		- 진흙 덩어리 : 뼈의 방패
		- 점액 덩어리 : 악성 질병
		- 기타 다른 소환수일 경우에도, 이 기술의 영향을 받습니다.
		]]):format()
	end,
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
			self:setEffect(self.EFF_REVISIONIST_HISTORY, 9, {})
		end)
		return nil -- We do not start the cooldown!
	end,
	info = function(self, t)
		return ([[얼마 전의 과거를 조작할 수 있게 되어, 10 턴의 시간 조작 효과를 얻게 됩니다.
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

		self:setEffect(self.EFF_CAUTERIZE, 8, {dam=value/10})
		return true
	end,
	info = function(self, t)
		return ([[내면에 불꽃을 키워, 시전자의 목숨을 끊어버릴 일격이 날아오기 직전에 몸을 불태웁니다.
		불꽃은 상처를 급속도로 지져 해당 턴에 받은 피해를 무효화시키지만, 8 턴 동안 상처가 불타올라 매 턴마다 무효화시킨 피해량의 10% 에 해당하는 피해를 줍니다. (저항력이나 불에 대한 친화력을 무시합니다)
		유용하지만, 맹신할 수는 없습니다. '과격한' 응급치료일 뿐이고, 재사용 대기시간도 있으니까요.]])
	end,
}
