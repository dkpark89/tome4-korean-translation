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

-- Physical combat
newTalentType{ allow_random=true, type="technique/2hweapon-offense", name = "two-handed weapons", description = "양손무기에 특화된 공격기술입니다." }
newTalentType{ allow_random=true, type="technique/2hweapon-cripple", name = "two-handed maiming", description = "양손무기에 특화된 무력화 기술입니다." }
newTalentType{ allow_random=true, type="technique/shield-offense", name = "shield offense", description = "무기와 방패를 드는 전투방법에 특화된 공격기술입니다." }
newTalentType{ allow_random=true, type="technique/shield-defense", name = "shield defense", description = "무기와 방패를 드는 전투방법에 특화된 방어기술입니다." }
newTalentType{ allow_random=true, type="technique/dualweapon-training", name = "dual weapons", description = "두 개의 무기를 동시에 사용하는 전투방법을 수련합니다." }
newTalentType{ allow_random=true, type="technique/dualweapon-attack", name = "dual techniques", description = "두 개의 무기를 동시에 사용하는 전투방법에 특화된 공격기술입니다." }
newTalentType{ allow_random=true, type="technique/archery-base", name = "archery - base", description = "원거리 무기를 사용하는 기본기술입니다." }
newTalentType{ allow_random=true, type="technique/archery-bow", name = "archery - bows", description = "활을 사용하는 전투방법에 특화된 공격기술입니다." }
newTalentType{ allow_random=true, type="technique/archery-sling", name = "archery - slings", description = "투석구를 사용하는 전투방법에 특화된 공격기술입니다." }
newTalentType{ allow_random=true, type="technique/archery-training", name = "archery training", description = "원거리 무기에 공통적으로 사용되는 기술입니다." }
newTalentType{ allow_random=true, type="technique/archery-utility", name = "archery prowess", description = "원거리 무기를 사용해서 적을 무력화시키는 공격기술입니다." }
newTalentType{ allow_random=true, type="technique/superiority", name = "superiority", min_lev = 10, description = "다수의 적들 사이에서 벌어지는 전투에 특화된 기술입니다." }
newTalentType{ allow_random=true, type="technique/battle-tactics", name = "battle tactics", min_lev = 10, description = "전략적인 전투를 위한 기술입니다." }
newTalentType{ allow_random=true, type="technique/warcries", name = "warcries", no_silence = true, min_lev = 10, description = "자신을 강화하고 적을 약화시키는 전투 함성을 수련합니다." }
newTalentType{ allow_random=true, type="technique/bloodthirst", name = "bloodthirst", min_lev = 10, description = "광란의 전투를 통해, 낭자한 선혈과 전투의 희열을 느낍니다." }
newTalentType{ allow_random=true, type="technique/field-control", name = "field control", generic = true, description = "다양한 행동으로 전장을 제어하는 기술입니다." }
newTalentType{ allow_random=true, type="technique/combat-techniques-active", name = "combat techniques", description = "공통적으로 활용되는 기본 전투기술입니다." }
newTalentType{ allow_random=true, type="technique/combat-techniques-passive", name = "combat veteran", description = "지치지 않고 오랫동안 전투를 지속할 수 있는 기술입니다." }
newTalentType{ allow_random=true, type="technique/combat-training", name = "combat training", generic = true, description = "다양한 무기와 방어구, 그리고 기본 체력을 수련합니다." }
newTalentType{ allow_random=true, type="technique/magical-combat", name = "magical combat", description = "마법과 무기기술을 혼합한 전투방법을 수련합니다." }
newTalentType{ allow_random=true, type="technique/mobility", name = "mobility", generic = true, description = "기동성에 중점을 둔, 전장에서의 행동기술입니다." }
newTalentType{ allow_random=true, type="technique/thuggery", name = "thuggery", description = "수단과 방법을 가리지 않는, 난폭한 전투기술입니다." }

-- Unarmed Combat
newTalentType{ is_unarmed=true, allow_random=true, type="technique/pugilism", name = "pugilism", description = "판갑, 무기, 방패 어느 것도 사용하지 않는 비무장 상태에서의 타격 기술입니다." }
newTalentType{ is_unarmed=true, allow_random=true, type="technique/finishing-moves", name = "finishing moves", description = "판갑, 무기, 방패 어느 것도 사용하지 않는 비무장 상태에서, 연계 점수를 사용하는 마무리 공격입니다." }
newTalentType{ is_unarmed=true, allow_random=true, type="technique/grappling", name = "grappling", description = "판갑, 무기, 방패 어느 것도 사용하지 않는 비무장 상태에서의 잡기 기술입니다." }
newTalentType{ is_unarmed=true, allow_random=true, type="technique/unarmed-discipline", name = "unarmed discipline", description = "판갑, 무기, 방패 어느 것도 사용하지 않는 비무장 상태의, 발차기와 던지기를 포함한 기본기술입니다." }
newTalentType{ is_unarmed=true, allow_random=true, type="technique/unarmed-training", name = "unarmed training", description = "판갑, 무기, 방패 어느 것도 사용하지 않는 비무장 상태에서의 전투 기술을 수련합니다." }
newTalentType{ allow_random=true, type="technique/conditioning", name = "conditioning", generic = true, description = "전투 지속 능력을 위한 신체 조절법입니다." }

newTalentType{ is_unarmed=true, type="technique/unarmed-other", name = "unarmed other", generic = true, description = "기본적인 맨손 전투기술과 자세입니다." }



-- Generic requires for techs based on talent level
-- Uses STR
techs_req1 = function(self, t) local stat = "str"; return {
	stat = { [stat]=function(level) return 12 + (level-1) * 2 end },
	level = function(level) return 0 + (level-1)  end,
} end
techs_req2 = function(self, t) local stat = "str"; return {
	stat = { [stat]=function(level) return 20 + (level-1) * 2 end },
	level = function(level) return 4 + (level-1)  end,
} end
techs_req3 = function(self, t) local stat = "str"; return {
	stat = { [stat]=function(level) return 28 + (level-1) * 2 end },
	level = function(level) return 8 + (level-1)  end,
} end
techs_req4 = function(self, t) local stat = "str"; return {
	stat = { [stat]=function(level) return 36 + (level-1) * 2 end },
	level = function(level) return 12 + (level-1)  end,
} end
techs_req5 = function(self, t) local stat = "str"; return {
	stat = { [stat]=function(level) return 44 + (level-1) * 2 end },
	level = function(level) return 16 + (level-1)  end,
} end
techs_req_high1 = function(self, t) local stat = "str"; return {
	stat = { [stat]=function(level) return 22 + (level-1) * 2 end },
	level = function(level) return 10 + (level-1)  end,
} end
techs_req_high2 = function(self, t) local stat = "str"; return {
	stat = { [stat]=function(level) return 30 + (level-1) * 2 end },
	level = function(level) return 14 + (level-1)  end,
} end
techs_req_high3 = function(self, t) local stat = "str"; return {
	stat = { [stat]=function(level) return 38 + (level-1) * 2 end },
	level = function(level) return 18 + (level-1)  end,
} end
techs_req_high4 = function(self, t) local stat = "str"; return {
	stat = { [stat]=function(level) return 46 + (level-1) * 2 end },
	level = function(level) return 22 + (level-1)  end,
} end
techs_req_high5 = function(self, t) local stat = "str"; return {
	stat = { [stat]=function(level) return 54 + (level-1) * 2 end },
	level = function(level) return 26 + (level-1)  end,
} end

-- Generic requires for techs_dex based on talent level
techs_dex_req1 = {
	stat = { dex=function(level) return 12 + (level-1) * 2 end },
	level = function(level) return 0 + (level-1)  end,
}
techs_dex_req2 = {
	stat = { dex=function(level) return 20 + (level-1) * 2 end },
	level = function(level) return 4 + (level-1)  end,
}
techs_dex_req3 = {
	stat = { dex=function(level) return 28 + (level-1) * 2 end },
	level = function(level) return 8 + (level-1)  end,
}
techs_dex_req4 = {
	stat = { dex=function(level) return 36 + (level-1) * 2 end },
	level = function(level) return 12 + (level-1)  end,
}
techs_dex_req5 = {
	stat = { dex=function(level) return 44 + (level-1) * 2 end },
	level = function(level) return 16 + (level-1)  end,
}

-- Generic rquires based either on str or dex
techs_strdex_req1 = function(self, t) local stat = self:getStr() >= self:getDex() and "str" or "dex"; return {
	stat = { [stat]=function(level) return 12 + (level-1) * 2 end },
	level = function(level) return 0 + (level-1)  end,
} end
techs_strdex_req2 = function(self, t) local stat = self:getStr() >= self:getDex() and "str" or "dex"; return {
	stat = { [stat]=function(level) return 20 + (level-1) * 2 end },
	level = function(level) return 4 + (level-1)  end,
} end
techs_strdex_req3 = function(self, t) local stat = self:getStr() >= self:getDex() and "str" or "dex"; return {
	stat = { [stat]=function(level) return 28 + (level-1) * 2 end },
	level = function(level) return 8 + (level-1)  end,
} end
techs_strdex_req4 = function(self, t) local stat = self:getStr() >= self:getDex() and "str" or "dex"; return {
	stat = { [stat]=function(level) return 36 + (level-1) * 2 end },
	level = function(level) return 12 + (level-1)  end,
} end
techs_strdex_req5 = function(self, t) local stat = self:getStr() >= self:getDex() and "str" or "dex"; return {
	stat = { [stat]=function(level) return 44 + (level-1) * 2 end },
	level = function(level) return 16 + (level-1)  end,
} end

-- Generic requires for techs_con based on talent level
techs_con_req1 = {
	stat = { con=function(level) return 12 + (level-1) * 2 end },
	level = function(level) return 0 + (level-1)  end,
}
techs_con_req2 = {
	stat = { con=function(level) return 20 + (level-1) * 2 end },
	level = function(level) return 4 + (level-1)  end,
}
techs_con_req3 = {
	stat = { con=function(level) return 28 + (level-1) * 2 end },
	level = function(level) return 8 + (level-1)  end,
}
techs_con_req4 = {
	stat = { con=function(level) return 36 + (level-1) * 2 end },
	level = function(level) return 12 + (level-1)  end,
}
techs_con_req5 = {
	stat = { con=function(level) return 44 + (level-1) * 2 end },
	level = function(level) return 16 + (level-1)  end,
}

-- Generic requires for techs_cun based on talent level
techs_cun_req1 = {
	stat = { cun=function(level) return 12 + (level-1) * 2 end },
	level = function(level) return 0 + (level-1)  end,
}
techs_cun_req2 = {
	stat = { cun=function(level) return 20 + (level-1) * 2 end },
	level = function(level) return 4 + (level-1)  end,
}
techs_cun_req3 = {
	stat = { cun=function(level) return 28 + (level-1) * 2 end },
	level = function(level) return 8 + (level-1)  end,
}
techs_cun_req4 = {
	stat = { cun=function(level) return 36 + (level-1) * 2 end },
	level = function(level) return 12 + (level-1)  end,
}
techs_cun_req5 = {
	stat = { cun=function(level) return 44 + (level-1) * 2 end },
	level = function(level) return 16 + (level-1)  end,
}

-- Archery range talents
archery_range = function(self, t)
	local weapon = self:hasArcheryWeapon()
	if not weapon or not weapon.combat then return 1 end
	return weapon.combat.range or 6
end

-- Unarmed stance changes and stance damage bonuses
getStrikingStyle = function(self, dam)
	local dam = 0
	if self:isTalentActive(self.T_STRIKING_STANCE) then
		local t = self:getTalentFromId(self.T_STRIKING_STANCE)
		dam = t.getDamage(self, t)
	end
	return dam / 100
end

-- Used for grapples and other unarmed attacks that don't rely on glove or gauntlet damage
getUnarmedTrainingBonus = function(self)
	local t = self:getTalentFromId(self.T_UNARMED_MASTERY)
	local damage = t.getPercentInc(self, t) or 0
	return damage + 1
end
	
cancelStances = function(self)
	if self.cancelling_stances then return end
	local stances = {self.T_STRIKING_STANCE, self.T_GRAPPLING_STANCE}
	self.cancelling_stances = true
	for i, t in ipairs(stances) do
		if self:isTalentActive(t) then
			self:forceUseTalent(t, {ignore_energy=true, ignore_cd=true})
		end
	end
	self.cancelling_stances = nil
end

load("/data/talents/techniques/2hweapon.lua")
load("/data/talents/techniques/dualweapon.lua")
load("/data/talents/techniques/weaponshield.lua")
load("/data/talents/techniques/superiority.lua")
load("/data/talents/techniques/warcries.lua")
load("/data/talents/techniques/bloodthirst.lua")
load("/data/talents/techniques/battle-tactics.lua")
load("/data/talents/techniques/field-control.lua")
load("/data/talents/techniques/combat-techniques.lua")
load("/data/talents/techniques/combat-training.lua")
load("/data/talents/techniques/bow.lua")
load("/data/talents/techniques/sling.lua")
load("/data/talents/techniques/archery.lua")
load("/data/talents/techniques/magical-combat.lua")
load("/data/talents/techniques/mobility.lua")
load("/data/talents/techniques/thuggery.lua")

load("/data/talents/techniques/pugilism.lua")
load("/data/talents/techniques/unarmed-discipline.lua")
load("/data/talents/techniques/finishing-moves.lua")
load("/data/talents/techniques/grappling.lua")
load("/data/talents/techniques/unarmed-training.lua")
load("/data/talents/techniques/conditioning.lua")
