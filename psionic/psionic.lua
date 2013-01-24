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
newTalentType{ allow_random=true, is_mind=true, autolearn_mindslayer=true, type="psionic/absorption", name = "absorption", description = "피해를 흡수하고, 그 피해를 염력으로 전환하는 기술입니다." }
newTalentType{ allow_random=true, is_mind=true, autolearn_mindslayer=true, type="psionic/projection", name = "projection", description = "오러를 발산하여 적에게 피해를 주는 기술입니다." }
newTalentType{ allow_random=true, is_mind=true, autolearn_mindslayer=true, type="psionic/psi-fighting", name = "psi-fighting", description = "염력을 이용하여 근접무기를 다루는 기술입니다." }
newTalentType{ allow_random=true, is_mind=true, autolearn_mindslayer=true, type="psionic/focus", name = "focus", description = "보석과 마석으로 염력을 집중시키는 기술입니다." }
newTalentType{ allow_random=true, is_mind=true, autolearn_mindslayer=true, type="psionic/augmented-mobility", name = "augmented mobility", min_lev = 10, description = "염력을 이용하여 빠르게 움직이고, 적을 끌어오는 기술입니다." }
newTalentType{ allow_random=true, is_mind=true, autolearn_mindslayer=true, type="psionic/voracity", generic = true, name = "voracity", description = "주변의 에너지를 흡수하는 기술입니다." }
newTalentType{ allow_random=true, is_mind=true, autolearn_mindslayer=true, type="psionic/finer-energy-manipulations", min_lev = 10, generic = true, name = "finer energy manipulations", description = "염동력을 이용한 미세 조작 기술입니다." }
newTalentType{ allow_random=true, is_mind=true, autolearn_mindslayer=true, type="psionic/mental-discipline", generic = true, name = "mental discipline", description = "정신력과 끈기를 수련합니다." }
newTalentType{ is_mind=true, type="psionic/other", name = "other", description = "여러 가지 염동적 기술입니다." }

-- Advanced Talent Trees
newTalentType{ allow_random=true, is_mind=true, autolearn_mindslayer=true, type="psionic/grip", name = "grip", min_lev = 10, description = "염동적 악력을 높이는 기술입니다." }
newTalentType{ allow_random=true, is_mind=true, autolearn_mindslayer=true, type="psionic/psi-archery", name = "psi-archery", min_lev = 10, description = "염동력으로 활을 사용해, 강력한 능력을 발휘하는 기술입니다." }
newTalentType{ allow_random=true, is_mind=true, autolearn_mindslayer=true, type="psionic/greater-psi-fighting", name = "greater psi-fighting", description = "염동전투 능력을 전설의 수준으로 끌어올리는 기술입니다." }
newTalentType{ allow_random=true, is_mind=true, autolearn_mindslayer=true, type="psionic/brainstorm", name = "brainstorm", description = "대부분의 정신 파괴자들이 꿈도 꾸지 못한 방법으로 염동력을 다루는 기술입니다." }

-- Solipsist Talent Trees
newTalentType{ allow_random=true, is_mind=true, type="psionic/discharge", name = "discharge", description = "주변에 반작용의 힘을 불러내는 기술입니다." }
newTalentType{ allow_random=true, is_mind=true, type="psionic/distortion", name = "distortion", description = "정신의 힘으로 주변을 왜곡시키는 기술입니다." }
newTalentType{ allow_random=true, is_mind=true, type="psionic/dream-forge", name = "Dream Forge", description = "꿈 속 대장간을 통해, 강력한 갑옷과 다양한 효과를 만들어내는 기술입니다." }
newTalentType{ allow_random=true, is_mind=true, type="psionic/dream-smith", name = "Dream Smith", description = "꿈 속 대장간에서 망치를 만들어내, 적을 공격하는 기술입니다." }
newTalentType{ allow_random=true, is_mind=true, type="psionic/nightmare", name = "nightmare", description = "적들을 악몽으로 이끄는 기술입니다.." }
newTalentType{ allow_random=true, is_mind=true, type="psionic/psychic-assault", name = "Psychic Assault", description = "상대방의 정신을 직접 공격하는 기술입니다." }
newTalentType{ allow_random=true, is_mind=true, type="psionic/slumber", name = "slumber", description = "적들을 깊은 잠에 빠뜨리는 기술입니다." }
newTalentType{ allow_random=true, is_mind=true, type="psionic/solipsism", name = "solipsism", description = "내가 인지했다. 고로 저것은 존재한다." }
newTalentType{ allow_random=true, is_mind=true, type="psionic/thought-forms", name = "Thought-Forms", description = "생각을 구현하여, 동료를 소환하는 기술입니다." }

-- Generic Solipsist Trees
newTalentType{ allow_random=true, is_mind=true, type="psionic/dreaming", generic = true, name = "dreaming", description = "자신과 적들의 꿈을 다루는 기술입니다." }
newTalentType{ allow_random=true, is_mind=true, type="psionic/mentalism", generic = true, name = "mentalism", description = "정신력에 기초하여 다양한 효과를 일으키는 기술입니다." }
newTalentType{ allow_random=true, is_mind=true, type="psionic/feedback", generic = true, name = "feedback", description = "피해에 대한 반작용을 축적하여, 스스로의 보호와 치료에 사용하는 기술입니다." }
newTalentType{ allow_random=true, is_mind=true, type="psionic/trance", generic = true, name = "trance", description = "최면 상태에 빠져, 잠재력을 끌어올리는 기술입니다." }

newTalentType{ allow_random=true, is_mind=true, type="psionic/possession", name = "possession", description = "스스로의 육체를 벗어나, 다른 육체를 소유할 수 있는 기술입니다." }


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

