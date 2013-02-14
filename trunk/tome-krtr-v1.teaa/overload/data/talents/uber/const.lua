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

require "engine.krtrUtils"

uberTalent{
	name = "Draconic Body",
	kr_display_name = "용인의 육체",
	mode = "passive",
	cooldown = 40,
	require = { special={desc="용인들의 세계와 가까워질 것", fct=function(self) return game.state.birth.ignore_prodigies_special_reqs or (self:attr("drake_touched") and self:attr("drake_touched") >= 2) end} },
	trigger = function(self, t, value)
		if self.life - value < self.max_life * 0.3 and not self:isTalentCoolingDown(t) then
			self:heal(self.max_life * 0.4)
			self:startTalentCooldown(t)
			game.logSeen(self,"%s의 용인의 육체가 활성화되어, 생명력이 회복됩니다!",(self.kr_display_name or self.name) ) --I5 
		end
	end,
	info = function(self, t)
		return ([[현재 생명력이 최대 생명력의 30%% 까지 떨어지면, 용인의 힘이 발현하여 생명력이 40%% 회복됩니다.]])
		:format()
	end,
}

uberTalent{
	name = "Bloodspring",
	kr_display_name = "피분수",
	mode = "passive",
	cooldown = 12,
	require = { special={desc="멜린다가 희생되도록 놔둘 것", fct=function(self) return game.state.birth.ignore_prodigies_special_reqs or (self:hasQuest("kryl-feijan-escape") and self:hasQuest("kryl-feijan-escape"):isStatus(engine.Quest.FAILED)) end} },
	trigger = function(self, t)
		-- Add a lasting map effect
		game.level.map:addEffect(self,
			self.x, self.y, 4,
			DamageType.WAVE, {dam={dam=100 + self:getCon() * 3, healfactor=0.5}, x=self.x, y=self.y, st=DamageType.DRAINLIFE, power=50 + self:getCon() * 2},
			1,
			5, nil,
			engine.Entity.new{alpha=100, display='', color_br=200, color_bg=60, color_bb=20},
			function(e)
				e.radius = e.radius + 0.5
				return true
			end,
			false
		)
		game:playSoundNear(self, "talents/tidalwave")
		self:startTalentCooldown(t)
	end,
	info = function(self, t)
		return ([[한번에 최대 생명력의 20%% 이상에 해당하는 피해를 받을 경우, 몸에서 피가 끓어오릅니다. 그 결과 선혈의 급류가 몸에서 쏟아져나와 4 턴간 %0.2f 황폐 속성 피해를 주고 적들을 밀어내며, 피해량의 50%% 만큼 생명력을 회복합니다.
		피해량은 체격 능력치의 영향을 받아 증가합니다.]])
		:format(100 + self:getCon() * 3)
	end,
}

uberTalent{
	name = "Eternal Guard",
	kr_display_name = "영구적 보호",
	mode = "passive",
	require = { special={desc="방패 막기 기술을 알고 있을 것", fct=function(self) return self:knowTalent(self.T_BLOCK) end} },
	info = function(self, t)
		return ([[방패 막기의 지속시간이 1 턴 늘어나며, 피해를 입어도 방패 막기를 유지합니다.]])
		:format()
	end,
}

uberTalent{
	name = "Never Stop Running",
	kr_display_name = "멈추지 않는 자",
	mode = "sustained",
	cooldown = 20,
	sustain_stamina = 10,
	tactical = { CLOSEIN = 2, ESCAPE = 2 },
	require = { special={desc="체력을 소모하는 기술 레벨의 총 합이 20 이상일 것", fct=function(self) return knowRessource(self, "stamina", 20) end} },
	activate = function(self, t)
		local ret = {}
		self:talentTemporaryValue(ret, "move_stamina_instead_of_energy", 20)
		return ret
	end,
	deactivate = function(self, t, p)
		return true
	end,
	info = function(self, t)
		return ([[기술이 활성화되면, 턴 소모 없이 이동할 수 있게 됩니다. 하지만 이를 위해서는 엄청난 체력이 소모되며, 1 칸 이동할 때마다 체력을 20 소모하게 됩니다.]])
		:format()
	end,
}

uberTalent{
	name = "Armour of Shadows",
	kr_display_name = "그림자 갑옷",
	mode = "passive",
	require = { special={desc="적에게 총 50,000 이상의 암흑 피해를 가할 것", fct=function(self) return
		self.damage_log and (
			(self.damage_log[DamageType.DARKNESS] and self.damage_log[DamageType.DARKNESS] >= 50000)
		)
	end} },
	on_learn = function(self, t)
		self:attr("darkness_darkens", 1)
	end,
	on_unlearn = function(self, t)
		self:attr("darkness_darkens", -1)
	end,
	info = function(self, t)
		return ([[가장 어두운 그림자로 자신을 보호합니다. 불빛이 없는 곳에 있으면, 방어도가 30 증가하고 방어 효율이 50%% 증가합니다.
		그리고 적에게 암흑 피해를 줄 때마다, 자신이 있는 곳과 대상 지역의 불빛을 없애버립니다.]])
		:format()
	end,
}

uberTalent{
	name = "Spine of the World",
	kr_display_name = "세계 최강의 척추",
	mode = "passive",
	trigger = function(self, t)
		if self:hasEffect(self.EFF_SPINE_OF_THE_WORLD) then return end
		self:setEffect(self.EFF_SPINE_OF_THE_WORLD, 4, {})
	end,
	info = function(self, t)
		return ([[물리적 상태효과의 영향을 받을 때마다 척추신경이 반응하여, 다른 물리적 상태효과에 5 턴 동안 완전한 면역됩니다.]])
		:format()
	end,
}

uberTalent{
	name = "Fungal Blood",
	kr_display_name = "혈관 속 미생물",
	require = { special={desc="능력 주입을 사용할 수 있을 것", fct=function(self) return not self.inscription_restrictions or self.inscription_restrictions['inscriptions/infusions'] end} },
	tactical = { HEAL = function(self) return not self:hasEffect(self.EFF_FUNGAL_BLOOD) and 0 or math.ceil(self:hasEffect(self.EFF_FUNGAL_BLOOD).power / 150) end },
	on_pre_use = function(self, t) return self:hasEffect(self.EFF_FUNGAL_BLOOD) and self:hasEffect(self.EFF_FUNGAL_BLOOD).power > 0 and not self:attr("undead") end,
	trigger = function(self, t)
		if self.inscription_restrictions and not self.inscription_restrictions['inscriptions/infusions'] then return end
		self:setEffect(self.EFF_FUNGAL_BLOOD, 6, {power=self:getCon() * 1.5})
	end,
	action = function(self, t)
		local eff = self:hasEffect(self.EFF_FUNGAL_BLOOD)
		self:heal(math.min(eff.power, self:getCon() * self.max_life / 100))
		self:removeEffect(self.EFF_FUNGAL_BLOOD)
		return true
	end,
	info = function(self, t)
		return ([[미생물 포자들이 혈관 속에 기생하여, 주입된 능력을 사용할 때마다 미생물 수치가 %d 상승합니다.
		이 미생물 수치를 이용하여 생명력을 회복할 수 있습니다. (%d 이상의 생명력은 회복할 수 없습니다)
		미생물 수치는 6 턴 동안 유지되며, 매 턴마다 그 효능이 10 씩 떨어집니다.
		상승되는 미생물 수치와 생명력 회복량은 체격 능력치의 영향을 받아 증가합니다.]])
		:format(self:getCon() * 1.5, self:getCon() * self.max_life / 100)
	end,
}

uberTalent{
	name = "Corrupted Shell",
	kr_display_name = "완전한 타락",
	mode = "passive",
	require = { special={desc="총 50,000 이상의 황폐화 피해를 받았으며, '위대한 타락자' 와 함께 지구르를 파괴할 것", fct=function(self) return
		(self.damage_intake_log and self.damage_intake_log[DamageType.BLIGHT] and self.damage_intake_log[DamageType.BLIGHT] >= 50000) and
		(game.state.birth.ignore_prodigies_special_reqs or (
			self:hasQuest("anti-antimagic") and 
			self:hasQuest("anti-antimagic"):isStatus(engine.Quest.DONE) and
			not self:hasQuest("anti-antimagic"):isStatus(engine.Quest.COMPLETED, "grand-corruptor-treason")
		))
	end} },
	on_learn = function(self, t)
		self.max_life = self.max_life + 150
	end,
	info = function(self, t)
		return ([[타락에 대한 새로운 지식 덕분에, 육신을 조작하여 더 강력해지는 방법을 알게 되었습니다... 변화로 인해 몸에 가해질 부담감을 이겨낼 수 있다면요.
		맷집과 반응속도가 크게 증가하여, 최대 생명력이 150 증가하고 회피도가 %d, 모든 내성이 %d 상승합니다.
		회피도와 내성 상승량은 체격 능력치의 영향을 받아 증가합니다.]])
		:format(self:getCon() / 3, self:getCon() / 3)
	end,
}
