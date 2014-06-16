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

uberTalent{
	name = "Fast As Lightning",
	kr_name = "번개보다 빠르게",
	mode = "passive",
	trigger = function(self, t, ox, oy)
		local dx, dy = (self.x - ox), (self.y - oy)
		if dx ~= 0 then dx = dx / math.abs(dx) end
		if dy ~= 0 then dy = dy / math.abs(dy) end
		local dir = util.coordToDir(dx, dy, 0)

		local eff = self:hasEffect(self.EFF_FAST_AS_LIGHTNING)
		if eff and eff.blink then
			if eff.dir ~= dir then
				self:removeEffect(self.EFF_FAST_AS_LIGHTNING)
			else
				return
			end
		end

		self:setEffect(self.EFF_FAST_AS_LIGHTNING, 1, {})
		eff = self:hasEffect(self.EFF_FAST_AS_LIGHTNING)

		if not eff.dir then eff.dir = dir eff.nb = 0 end

		if eff.dir ~= dir then
			self:removeEffect(self.EFF_FAST_AS_LIGHTNING)
			self:setEffect(self.EFF_FAST_AS_LIGHTNING, 1, {})
			eff = self:hasEffect(self.EFF_FAST_AS_LIGHTNING)
			eff.dir = dir eff.nb = 0
			game.logSeen(self, "#LIGHT_BLUE#%s의 초신속 상태가 해제됩니다!", (self.kr_name or self.name):capitalize())
		end

		eff.nb = eff.nb + 1

		if eff.nb >= 3 and not eff.blink then
			self:effectTemporaryValue(eff, "prob_travel", 5)
			game.logSeen(self, "#LIGHT_BLUE#%s 초신속 상태에 들어갑니다!", (self.kr_name or self.name):capitalize():addJosa("가"))
			local sx, sy = game.level.map:getTileToScreen(self.x, self.y)
			game.flyers:add(sx, sy, 30, rng.float(-3, -2), (rng.range(0,2)-1) * 0.5, "치명적 속도!", {0,128,255})
			eff.particle = self:addParticles(Particles.new("megaspeed", 1, {angle=util.dirToAngle((dir == 4 and 6) or (dir == 6 and 4 or dir))}))
			eff.blink = true
			game:playSoundNear(self, "talents/thunderstorm")
		end
	end,
	info = function(self, t)
		return ([[800%% 이상의 이동 속도로 3 턴 동안 같은 방향으로 이동하게 되면, 초신속 상태가 되어 지형지물을 통과할 수 있게 됩니다.
		이동 방향을 바꾸면 효과가 사라집니다.]])
		:format()
	end,
}

uberTalent{
	name = "Tricky Defenses",
	kr_name = "교묘한 방어",
	mode = "passive",
	require = { special={desc="마법을 증오할 것", fct=function(self) return self:knowTalentType("wild-gift/antimagic") end} },
	-- called by getMax function in Antimagic shield talent definition mod.data.talents.gifts.antimagic.lua
	shieldmult = function(self) return self:combatStatScale("cun", 0.1, 0.5) end,
	info = function(self, t)
		return ([[속임수와 각종 기술의 달인이 되어, 반마법 보호막이 %d%% 더 많은 피해량을 흡수하게 됩니다.
		피해 흡수량은 교활함 능력치의 영향을 받아 증가합니다.]])
		:format(t.shieldmult(self)*100)
	end,
}

uberTalent{
	name = "Endless Woes",
	kr_name = "끝없는 고통",
	mode = "passive",
	require = { special={desc="산성, 황폐, 암흑, 시간, 정신 속성 중 하나로 적에게 총 50,000 이상의 피해를 줄 것", fct=function(self) return 
		self.damage_log and (
			(self.damage_log[DamageType.ACID] and self.damage_log[DamageType.ACID] >= 50000) or
			(self.damage_log[DamageType.BLIGHT] and self.damage_log[DamageType.BLIGHT] >= 50000) or
			(self.damage_log[DamageType.DARKNESS] and self.damage_log[DamageType.DARKNESS] >= 50000) or
			(self.damage_log[DamageType.MIND] and self.damage_log[DamageType.MIND] >= 50000) or
			(self.damage_log[DamageType.TEMPORAL] and self.damage_log[DamageType.TEMPORAL] >= 50000)
		)
	end} },
	cunmult = function(self) return self:combatStatScale("cun", 0.15, 1) end,
	trigger = function(self, t, target, damtype, dam)
		if dam < 150 then return end
		if damtype == DamageType.ACID and rng.percent(20) then
			target:setEffect(target.EFF_ACID_SPLASH, 5, {src=self, dam=(dam * t.cunmult(self) / 2.5) / 5, atk=self:getCun() / 2, apply_power=math.max(self:combatSpellpower(), self:combatMindpower())})
		elseif damtype == DamageType.BLIGHT and target:canBe("disease") and rng.percent(20) then
			local diseases = {{self.EFF_WEAKNESS_DISEASE, "str"}, {self.EFF_ROTTING_DISEASE, "con"}, {self.EFF_DECREPITUDE_DISEASE, "dex"}}
			local disease = rng.table(diseases)
			target:setEffect(disease[1], 5, {src=self, dam=(dam * t.cunmult(self)/ 2.5) / 5, [disease[2]]=self:getCun() / 3, apply_power=math.max(self:combatSpellpower(), self:combatMindpower())})
		elseif damtype == DamageType.DARKNESS and target:canBe("blind") and rng.percent(20) then
			target:setEffect(target.EFF_BLINDED, 5, {apply_power=math.max(self:combatSpellpower(), self:combatMindpower())})
		elseif damtype == DamageType.TEMPORAL and target:canBe("slow") and rng.percent(20) then
			target:setEffect(target.EFF_SLOW, 5, {apply_power=math.max(self:combatSpellpower(), self:combatMindpower()), power=0.3})
		elseif damtype == DamageType.MIND and target:canBe("confusion") and rng.percent(20) then
			target:setEffect(target.EFF_CONFUSED, 5, {apply_power=math.max(self:combatSpellpower(), self:combatMindpower()), power=20})
		end
	end,
	info = function(self, t)
		return ([[사악한 기운이 온몸을 흐르기 시작합니다.
		- 모든 산성 피해가 20%% 확률로 지속성 산성을 묻혀, 원래 피해량의 %d%% 만큼 추가 피해를 주고 5 턴 동안 정확도를 %d 감소시킵니다.
		- 모든 황폐 피해가 20%% 확률로 추가적인 황폐화를 일으켜, 원래 피해량의 %d%% 만큼 추가 피해를 주고 5 턴 동안 능력치 하나를 %d 감소시킵니다.
		- 모든 암흑 피해가 20%% 확률로 5 턴 동안 적을 실명시킵니다.
		- 모든 시간 피해가 20%% 확률로 5 턴 동안 적을 30%% 감속시킵니다.
		- 모든 정신 피해가 20%% 확률로 5 턴 동안 적을 20%% 혼란시킵니다.
		모든 효과는 150 이상의 피해량을 줬을 경우에만 발동합니다.
		모든 피해량은 교활함 능력치의 영향을 받아 증가합니다.]])
		:format(100*t.cunmult(self) / 2.5, self:getCun() / 2, 100*t.cunmult(self) / 2.5, self:getCun() / 3)
	end,
}

uberTalent{
	name = "Secrets of Telos",
	kr_name = "텔로스의 비밀",
	mode = "passive",
	require = { special={desc="부서진 텔로스 지팡이 (상단), 부서진 텔로스 지팡이 (하단), 텔로스 지팡이의 수정을 모두 가지고 있을 것", fct=function(self)
		local o1 = self:findInAllInventoriesBy("define_as", "GEM_TELOS")
		local o2 = self:findInAllInventoriesBy("define_as", "TELOS_TOP_HALF")
		local o3 = self:findInAllInventoriesBy("define_as", "TELOS_BOTTOM_HALF")
		return o1 and o2 and o3
	end} },
	on_learn = function(self, t)
		local list = mod.class.Object:loadList("/data/general/objects/special-artifacts.lua")
		local o = game.zone:makeEntityByName(game.level, list, "TELOS_SPIRE", true)
		if o then
			o:identify(true)
			self:addObject(self.INVEN_INVEN, o)

			local o1, item1, inven1 = self:findInAllInventoriesBy("define_as", "GEM_TELOS")
			self:removeObject(inven1, item1, true)
			local o2, item2, inven2 = self:findInAllInventoriesBy("define_as", "TELOS_TOP_HALF")
			self:removeObject(inven2, item2, true)
			local o3, item3, inven3 = self:findInAllInventoriesBy("define_as", "TELOS_BOTTOM_HALF")
			self:removeObject(inven3, item3, true)

			self:sortInven()

			game.logSeen(self, "#VIOLET#%s %s 조립했습니다!", (self.kr_name or self.name):capitalize():addJosa("가"), o:getName{do_colour=true, no_count=true}:addJosa("를"))
		end
	end,
	info = function(self, t)
		return ([[세 가지 텔로스와 관련된 부품을 모아 신중하게 연구한 결과, 복원이 가능하다는 사실을 깨달았습니다. 하나의 강력한 지팡이를 복원해냅니다.]])
		:format()
	end,
}

uberTalent{
	name = "Elemental Surge",
	kr_name = "속성 고조",
	mode = "passive",
	cooldown = 12,
	require = { special={desc="마법, 화염, 냉기, 전기, 빛, 자연 속성 중 하나로 적에게 총 50,000 이상의 피해를 줄 것", fct=function(self) return 
		self.damage_log and (
			(self.damage_log[DamageType.ARCANE] and self.damage_log[DamageType.ARCANE] >= 50000) or
			(self.damage_log[DamageType.FIRE] and self.damage_log[DamageType.FIRE] >= 50000) or
			(self.damage_log[DamageType.COLD] and self.damage_log[DamageType.COLD] >= 50000) or
			(self.damage_log[DamageType.LIGHTNING] and self.damage_log[DamageType.LIGHTNING] >= 50000) or
			(self.damage_log[DamageType.LIGHT] and self.damage_log[DamageType.LIGHT] >= 50000) or
			(self.damage_log[DamageType.NATURE] and self.damage_log[DamageType.NATURE] >= 50000)
		)
	end} },
	getThreshold = function(self, t) return 4*self.level end,
	getColdEffects = function(self, t)
		return {physresist = 30,
		armor = self:combatStatScale("cun", 20, 50, 0.75),
		dam = math.max(100, self:getCun()),
		}
	end,
	getShield = function(self, t) return 100 + 2*self:getCun() end,
	-- triggered in default projector in mod.data.damage_types.lua
	trigger = function(self, t, target, damtype, dam)
		if dam < t.getThreshold(self, t) then return end
		
		local ok = false
		if damtype == DamageType.ARCANE and rng.percent(30) then ok=true self:setEffect(self.EFF_ELEMENTAL_SURGE_ARCANE, 5, {})
		elseif damtype == DamageType.FIRE and rng.percent(30) then ok=true self:removeEffectsFilter{type="magical", status="detrimental"} self:removeEffectsFilter{type="physical", status="detrimental"} game.logSeen(self, "#CRIMSON#%s 정화의 불꽃을 소환하여 공격했습니다!", (self.kr_name or self.name):capitalize():addJosa("가"))
		elseif damtype == DamageType.COLD and rng.percent(30) then
			-- EFF_ELEMENTAL_SURGE_COLD in mod.data.timed_effect.magical.lua holds the parameters
			ok=true self:setEffect(self.EFF_ELEMENTAL_SURGE_COLD, 5, t.getColdEffects(self, t))
		elseif damtype == DamageType.LIGHTNING and rng.percent(30) then ok=true self:setEffect(self.EFF_ELEMENTAL_SURGE_LIGHTNING, 5, {})
		elseif damtype == DamageType.LIGHT and rng.percent(30) and not self:hasEffect(self.EFF_DAMAGE_SHIELD) then
			ok=true
			self:setEffect(self.EFF_DAMAGE_SHIELD, 5, {power=t.getShield(self, t)})
		elseif damtype == DamageType.NATURE and rng.percent(30) then ok=true self:setEffect(self.EFF_ELEMENTAL_SURGE_NATURE, 5, {})
		end

		if ok then self:startTalentCooldown(t) end
	end,
	info = function(self, t)
		local cold = t.getColdEffects(self, t)
		return ([[원소의 기운이 온몸을 흐르기 시작합니다. 다양한 속성의 공격으로 치명타를 발생시킬 때마다, 특수한 효과가 일어납니다.
		- 공격이 마법 속성이었을 경우, 30%% 확률로 주문시전 속도를 5 턴 동안 20%% 증가시킵니다.
		- 공격이 화염 속성이었을 경우, 30%% 확률로 자신에게 걸린 모든 해로운 물리적, 마법적 상태효과를 없애버립니다.
		- 공격이 냉기 속성이었을 경우, 30%% 확률로 5 턴 동안 피부가 얼음이 되어 물리 피해를 %d%% 덜 받게 되며, 방어도가 %d 상승하고, 적에게 %d 냉기 피해를 돌려줍니다.
		- 공격이 전기 속성이었을 경우, 30%% 확률로 5 턴 동안 순수한 전격의 존재가 되어 받은 피해를 무효화하고 근처로 순간이동합니다. (한 턴에 한 번만 가능합니다)
		- 공격이 빛 속성이었을 경우, 30%% 확률로 보호막을 만들어 5 턴 동안 %d 피해를 흡수합니다.
		- 공격이 자연 속성이었을 경우, 30%% 확률로 신체가 강화되어 5 턴 동안 해로운 마법적 상태효과에 걸리지 않게 됩니다.
		냉기와 빛 속성의 효과는 교활함 능력치의 영향을 받아 증가합니다.
		모든 효과는 %d 이상의 피해를 줬을 경우에만 발동합니다 (이는 캐릭터 레벨의 영향을 받습니다).]])
		:format(cold.physresist, cold.armor, cold.dam, t.getShield(self, t), t.getThreshold(self, t))
	end,
}

uberTalent{
	name = "Eye of the Tiger",
	kr_name = "호랑이의 눈",
	mode = "passive",
	trigger = function(self, t, kind)
		if self.turn_procs.eye_tiger then return end

		local tids = {}

		for tid, _ in pairs(self.talents_cd) do
			local t = self:getTalentFromId(tid)
			if 
				(kind == "physical" and
					(
						t.type[1]:find("^technique/") or
						t.type[1]:find("^cunning/")
					)
				) or
				(kind == "spell" and
					(
						t.type[1]:find("^spell/") or
						t.type[1]:find("^corruption/") or
						t.type[1]:find("^celestial/") or
						t.type[1]:find("^chronomancy/")
					)
				) or
				(kind == "mind" and
					(
						t.type[1]:find("^wild%-gift/") or
						t.type[1]:find("^cursed/") or
						t.type[1]:find("^psionic/")
					)
				)
				then
				tids[#tids+1] = tid
			end
		end
		if #tids == 0 then return end
		local tid = rng.table(tids)
		self.talents_cd[tid] = self.talents_cd[tid] - (kind == "spell" and 1 or 2)
		if self.talents_cd[tid] <= 0 then self.talents_cd[tid] = nil end
		self.changed = true
		self.turn_procs.eye_tiger = true
	end,
	info = function(self, t)
		return ([[물리 치명타를 입힐 때마다, 물리 혹은 교활 계통의 무작위한 기술 하나를 골라 재사용 대기시간을 2 줄입니다.
		주문 치명타를 입힐 때마다, 무작위한 주문 하나를 골라 재사용 대기시간을 1 줄입니다.
		정신 치명타를 입힐 때마다, 자연의 힘 / 초능력 / 고통 계열의 무작위한 기술 하나를 골라 재사용 대기시간을 2 줄입니다.
		한 턴에 한 번만 효과가 발생하며, 지속형 기술에는 영향을 주지 않습니다.]])
		:format()
	end,
}

uberTalent{
	name = "Worldly Knowledge",
	kr_name = "세상의 모든 지식",
	mode = "passive",
	on_learn = function(self, t, kind)
		local Chat = require "engine.Chat"
		local chat = Chat.new("worldly-knowledge", {name="Worldly Knowledge", kr_name="세상의 모든 지식"}, self)
		chat:invoke()
	end,
	info = function(self, t)
		return ([[새로운 기술 계열을 기술 숙련도 0.9 의 배율로 습득합니다. 
		제한 없이 배울 수 있는 기술 계열 :
		- 물리 / 신체 조절
		- 교활 / 생존
		마법이나 룬을 사용하지 않는 경우에만 배울 수 있는 기술 계열 :
		- 물리 / 기동성
		- 물리 / 전장 제어
		- 자연의 권능 / 자연의 부름
		- 자연의 권능 / 마석 수련
		- 초능력 / 꿈
		지구르의 추종자가 아닐 경우에만 배울 수 있는 기술 계열 :
		- 주문 / 예견
		- 주문 / 지팡이 전투기술
		- 주문 / 연금술 : 암석
		- 천공 / 찬가
		- 천공 / 빛
		- 시공 / 시공]])
		:format()
	end,
}

uberTalent{
	name = "Tricks of the Trade",
	kr_name = "뒷세계의 거래",
	mode = "passive",
	require = { special={desc="암살단 단장 편에 설 것", fct=function(self) return game.state.birth.ignore_prodigies_special_reqs or (self:isQuestStatus("lost-merchant", engine.Quest.COMPLETED, "evil")) end} },
	on_learn = function(self, t) 
		if self:knowTalentType("cunning/stealth") then
			self:setTalentTypeMastery("cunning/stealth", self:getTalentTypeMastery("cunning/stealth") + 0.2)
		elseif self:knowTalentType("cunning/stealth") == false then
			self:learnTalentType("cunning/stealth", true)
		end
		if self:knowTalentType("cunning/scoundrel") then
			self:setTalentTypeMastery("cunning/scoundrel", self:getTalentTypeMastery("cunning/scoundrel") + 0.1)
		else
			self:learnTalentType("cunning/scoundrel", true)
			self:setTalentTypeMastery("cunning/scoundrel", 0.9)
		end
		self.invisible_damage_penalty_divisor = (self.invisible_damage_penalty_divisor or 0) + 2
	end,
	info = function(self, t)
		return ([[지하 세력과 친분을 맺어, 뒷세계의 기술들을 전수받습니다.
		교활/은신 기술 계열의 숙련도가 0.2 상승하며, 기술 계열이 없다면 기술 계열의 잠금이 해제됩니다. (이 경우, 교활/은신 기술 계열을 사용하기 위해서는 기술 계열 점수를 추가로 투자해야 합니다)
		그리고 교활/무뢰배 기술 계열의 숙련도가 0.1 상승하며, 기술 계열이 없다면 0.9 의 숙련도를 가진 채로 기술 계열을 사용할 수 있게 됩니다.
		또한, 투명 상태일 때 받는 피해량 감소 효과가 절반으로 줄어듭니다.]]):
		format()
	end,
}
