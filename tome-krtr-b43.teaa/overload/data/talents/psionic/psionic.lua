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

-- Talent trees
newTalentType{ allow_random=true, type="psionic/absorption", name = "absorption", description = "데미지를 흡수하고 에너지를 얻는다." }
newTalentType{ allow_random=true, type="psionic/projection", name = "projection", description = "에너지를 발산하여 적에게 피해를 끼친다." }
newTalentType{ allow_random=true, type="psionic/psi-fighting", name = "psi-fighting", description = "정신력으로 조종하는 근접무기 착용." }
newTalentType{ allow_random=true, type="psionic/focus", name = "focus", description = "보석을 사용하여 에너지를 집중시킨다." }
newTalentType{ allow_random=true, type="psionic/augmented-mobility", name = "augmented mobility", min_lev = 10, description = "에너지를 이용하여 스스로를 움직이거나 다른 존재를 움직인다." }
newTalentType{ allow_random=true, type="psionic/voracity", generic = true, name = "voracity", description = "주위를 둘러싼 에너지를 가져온다." }
newTalentType{ allow_random=true, type="psionic/finer-energy-manipulations", min_lev = 10, generic = true, name = "finer energy manipulations", description = "염동적 기술을 이용한 미세작업." }
newTalentType{ allow_random=true, type="psionic/mental-discipline", generic = true, name = "mental discipline", description = "정신력과 끈기 그리고 유연성을 높인다." }
newTalentType{ type="psionic/other", name = "other", description = "여러가지 염동적 기술." }

-- Advanced Talent Trees
newTalentType{ allow_random=true, type="psionic/grip", name = "grip", min_lev = 10, description = "염동적 악력을 높인다." }
newTalentType{ allow_random=true, type="psionic/psi-archery", name = "psi-archery", min_lev = 10, description = "염동력을 이용하여 활을 쥐고, 그 치명적인 효과를 사용한다." }
newTalentType{ allow_random=true, type="psionic/greater-psi-fighting", name = "greater psi-fighting", description = "염동전투 기술의 숙련도를 서사적인 단계로 끄집어 올린다." }
newTalentType{ allow_random=true, type="psionic/brainstorm", name = "brainstorm", description = "Focus your telekinetic powers in ways undreamed of by most mindslayers." } --@@??

-- Solipsist Talent Trees
newTalentType{ allow_random=true, type="psionic/discharge", name = "discharge", description = "주변의 세상을 반작용으로 둘러싼다." }
newTalentType{ allow_random=true, type="psionic/distortion", name = "distortion", description = "정신의 힘으로 실제 세상을 왜곡시킨다." }
newTalentType{ allow_random=true, type="psionic/dream-forge", name = "Dream Forge", description = "강력한 갑옷을 만들고 그 효과를 볼 수 있는 꿈의 연마장을 다루는데 숙달한다." }
newTalentType{ allow_random=true, type="psionic/dream-smith", name = "Dream Smith", description = "꿈의 연마장에서 망치를 소환하여 적을 공격한다." }
newTalentType{ allow_random=true, type="psionic/nightmare", name = "nightmare", description = "적들을 악몽으로 이끈다." }
newTalentType{ allow_random=true, type="psionic/psychic-assault", name = "Psychic Assault", description = "상대방의 정신에 대한 직접적인 공격 기술." }
newTalentType{ allow_random=true, type="psionic/slumber", name = "slumber", description = "적들을 깊은 잠에 빠지게 만든다." }
newTalentType{ allow_random=true, type="psionic/solipsism", name = "solipsism", description = "스스로를 인지하기 위한 정신 능력 이외에는 아무것도 존재하지 않는다." }
newTalentType{ allow_random=true, type="psionic/thought-forms", name = "Thought-Forms", description = "생각만으로 염동체 소환수를 구현한다." }

-- Generic Solipsist Trees
newTalentType{ allow_random=true, type="psionic/dreaming", generic = true, name = "dreaming", description = "자신이나 적들의 수면 주기를 다룬다." }
newTalentType{ allow_random=true, type="psionic/mentalism", generic = true, name = "mentalism", description = "정신력에 기초한 여러가지 효과." }
newTalentType{ allow_random=true, type="psionic/feedback", generic = true, name = "feedback", description = "피해에 대한 반작용을 가지고 있다가 스스로의 보호나 치료에 사용한다." }
newTalentType{ allow_random=true, type="psionic/trance", generic = true, name = "trance", description = "정신을 깊은 최면의 세계로 인도한다." }

newTalentType{ allow_random=true, type="psionic/possession", name = "possession", description = "스스로의 육체를 벗어나는 방법을 배워, 다른 육체를 소유할 수 있게 된다." }


-- Level 0 wil tree requirements:
psi_absorb = {
	stat = { wil=function(level) return 12 + (level-1) * 8 end },
	level = function(level) return 0 + 5*(level-1)  end,
}
psi_wil_req1 = {
	stat = { wil=function(level) return 12 + (level-1) * 2 end },
	level = function(level) return 0 + (level-1)  end,
}
psi_wil_req2 = {
	stat = { wil=function(level) return 20 + (level-1) * 2 end },
	level = function(level) return 4 + (level-1)  end,
}
psi_wil_req3 = {
	stat = { wil=function(level) return 28 + (level-1) * 2 end },
	level = function(level) return 8 + (level-1)  end,
}
psi_wil_req4 = {
	stat = { wil=function(level) return 36 + (level-1) * 2 end },
	level = function(level) return 12 + (level-1)  end,
}

--Level 10 wil tree requirements:
psi_wil_high1 = {
	stat = { wil=function(level) return 22 + (level-1) * 2 end },
	level = function(level) return 10 + (level-1)  end,
}
psi_wil_high2 = {
	stat = { wil=function(level) return 30 + (level-1) * 2 end },
	level = function(level) return 14 + (level-1)  end,
}
psi_wil_high3 = {
	stat = { wil=function(level) return 38 + (level-1) * 2 end },
	level = function(level) return 18 + (level-1)  end,
}
psi_wil_high4 = {
	stat = { wil=function(level) return 46 + (level-1) * 2 end },
	level = function(level) return 22 + (level-1)  end,
}

--Level 20 wil tree requirements:
psi_wil_20_1 = {
	stat = { wil=function(level) return 32 + (level-1) * 2 end },
	level = function(level) return 20 + (level-1)  end,
}
psi_wil_20_2 = {
	stat = { wil=function(level) return 36 + (level-1) * 2 end },
	level = function(level) return 24 + (level-1)  end,
}
psi_wil_20_3 = {
	stat = { wil=function(level) return 42 + (level-1) * 2 end },
	level = function(level) return 28 + (level-1)  end,
}
psi_wil_20_4 = {
	stat = { wil=function(level) return 48 + (level-1) * 2 end },
	level = function(level) return 32 + (level-1)  end,
}

-- Level 0 cun tree requirements:
psi_cun_req1 = {
	stat = { cun=function(level) return 12 + (level-1) * 2 end },
	level = function(level) return 0 + (level-1)  end,
}
psi_cun_req2 = {
	stat = { cun=function(level) return 20 + (level-1) * 2 end },
	level = function(level) return 4 + (level-1)  end,
}
psi_cun_req3 = {
	stat = { cun=function(level) return 28 + (level-1) * 2 end },
	level = function(level) return 8 + (level-1)  end,
}
psi_cun_req4 = {
	stat = { cun=function(level) return 36 + (level-1) * 2 end },
	level = function(level) return 12 + (level-1)  end,
}


-- Level 10 cun tree requirements:
psi_cun_high1 = {
	stat = { cun=function(level) return 22 + (level-1) * 2 end },
	level = function(level) return 10 + (level-1)  end,
}
psi_cun_high2 = {
	stat = { cun=function(level) return 30 + (level-1) * 2 end },
	level = function(level) return 14 + (level-1)  end,
}
psi_cun_high3 = {
	stat = { cun=function(level) return 38 + (level-1) * 2 end },
	level = function(level) return 18 + (level-1)  end,
}
psi_cun_high4 = {
	stat = { cun=function(level) return 46 + (level-1) * 2 end },
	level = function(level) return 22 + (level-1)  end,
}


-- Useful definitions for psionic talents
function getGemLevel(self)
	local gem_level = 0
	if self:getInven("PSIONIC_FOCUS") then
		local tk_item = self:getInven("PSIONIC_FOCUS")[1]
		if tk_item and ((tk_item.type == "gem") or (tk_item.subtype == "mindstar") or tk_item.combat.is_psionic_focus == true) then
			gem_level = tk_item.material_level or 5
		end
	end
	if self:knowTalent(self.T_GREATER_TELEKINETIC_GRASP) and gem_level > 0 then
		if self:getTalentLevelRaw(self.T_GREATER_TELEKINETIC_GRASP) >= 5 then
			gem_level = gem_level + 1
		end
	end
	return gem_level
end

-- Cancel Thought Forms, we do this here because we use it for dreamscape and projection as well as thought-forms
function cancelThoughtForms(self, id)
	local forms = {self.T_TF_DEFENDER, self.T_TF_WARRIOR, self.T_TF_BOWMAN}
	for i, t in ipairs(forms) do
		if self:isTalentActive(t) then
			self:forceUseTalent(t, {ignore_energy=true})
		end
		-- Put other thought-forms on cooldown; checks for id to prevent dreamscape putting all thought-forms on cooldown
		if id and id ~= t then
			if self:knowTalent(t) then
				local t = self:getTalentFromId(t)
				self:startTalentCooldown(t)
			end	
		end
	end
end

load("/data/talents/psionic/absorption.lua")
load("/data/talents/psionic/finer-energy-manipulations.lua")
load("/data/talents/psionic/mental-discipline.lua")
load("/data/talents/psionic/projection.lua")
load("/data/talents/psionic/psi-fighting.lua")
load("/data/talents/psionic/voracity.lua")
load("/data/talents/psionic/augmented-mobility.lua")
load("/data/talents/psionic/focus.lua")
load("/data/talents/psionic/other.lua")

load("/data/talents/psionic/psi-archery.lua")
load("/data/talents/psionic/grip.lua")

-- Solipsist
load("/data/talents/psionic/discharge.lua")
load("/data/talents/psionic/distortion.lua")
load("/data/talents/psionic/dream-forge.lua")
load("/data/talents/psionic/dream-smith.lua")
load("/data/talents/psionic/dreaming.lua")
load("/data/talents/psionic/mentalism.lua")
load("/data/talents/psionic/feedback.lua")
load("/data/talents/psionic/nightmare.lua")
load("/data/talents/psionic/psychic-assault.lua")
load("/data/talents/psionic/slumber.lua")
load("/data/talents/psionic/solipsism.lua")
load("/data/talents/psionic/thought-forms.lua")
--load("/data/talents/psionic/trance.lua")


load("/data/talents/psionic/possession.lua")

