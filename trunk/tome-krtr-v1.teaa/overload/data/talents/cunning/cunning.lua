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

-- Cunning talents
newTalentType{ allow_random=true, type="cunning/stealth-base", name = "stealth", description = "은신 상태로 들어설 수 있게 된다." }
newTalentType{ allow_random=true, type="cunning/stealth", name = "stealth", description = "은신 상태로 들어설 수 있게 된다." }
newTalentType{ allow_random=true, type="cunning/trapping", name = "trapping", description = "함정 설치와 함정 숨기기에 관련된 지식." }
newTalentType{ allow_random=true, type="cunning/traps", name = "traps", description = "함정 기술 모음" }
newTalentType{ allow_random=true, type="cunning/poisons", name = "poisons", min_lev = 10, description = "독물에 대한 지식과 그것들에서 '좋은' 효과를 볼 수 있는 방법." }
newTalentType{ allow_random=true, type="cunning/poisons-effects", name = "poisons", description = "독물 기술 모음" }
newTalentType{ allow_random=true, type="cunning/dirty", name = "dirty fighting", description = "적에게 장애를 유발하는 여러가지 기술." }
newTalentType{ allow_random=true, type="cunning/lethality", name = "lethality", description = "적이 고통을 느끼게 만드는 법." }
newTalentType{ allow_random=true, no_silence=true, is_spell=true, type="cunning/shadow-magic", name = "shadow magic", description = "마법과 그림자의 혼합." }
newTalentType{ allow_random=true, no_silence=true, is_spell=true, type="cunning/ambush", name = "ambush", min_lev = 10, description = "어둠을 이용하고, 그림자를 조종하는 약간의 마법." }
newTalentType{ allow_random=true, type="cunning/survival", name = "survival", generic = true, description = "세상의 위험에 관한 지식과, 그것들을 피하는 방법." }
newTalentType{ allow_random=true, type="cunning/tactical", name = "tactical", description = "전략적 전투 기술." }
newTalentType{ allow_random=true, type="cunning/scoundrel", name = "scoundrel", generic = true, description = "신사적이지 못한 기술들의 사용법." }

-- Generic requires for cunning based on talent level
cuns_req1 = {
	stat = { cun=function(level) return 12 + (level-1) * 2 end },
	level = function(level) return 0 + (level-1)  end,
}
cuns_req2 = {
	stat = { cun=function(level) return 20 + (level-1) * 2 end },
	level = function(level) return 4 + (level-1)  end,
}
cuns_req3 = {
	stat = { cun=function(level) return 28 + (level-1) * 2 end },
	level = function(level) return 8 + (level-1)  end,
}
cuns_req4 = {
	stat = { cun=function(level) return 36 + (level-1) * 2 end },
	level = function(level) return 12 + (level-1)  end,
}
cuns_req5 = {
	stat = { cun=function(level) return 44 + (level-1) * 2 end },
	level = function(level) return 16 + (level-1)  end,
}
cuns_req_high1 = {
	stat = { cun=function(level) return 22 + (level-1) * 2 end },
	level = function(level) return 10 + (level-1)  end,
}
cuns_req_high2 = {
	stat = { cun=function(level) return 30 + (level-1) * 2 end },
	level = function(level) return 14 + (level-1)  end,
}
cuns_req_high3 = {
	stat = { cun=function(level) return 38 + (level-1) * 2 end },
	level = function(level) return 18 + (level-1)  end,
}
cuns_req_high4 = {
	stat = { cun=function(level) return 46 + (level-1) * 2 end },
	level = function(level) return 22 + (level-1)  end,
}
cuns_req_high5 = {
	stat = { cun=function(level) return 54 + (level-1) * 2 end },
	level = function(level) return 26 + (level-1)  end,
}

load("/data/talents/cunning/stealth.lua")
load("/data/talents/cunning/traps.lua")
load("/data/talents/cunning/poisons.lua")
load("/data/talents/cunning/dirty.lua")
load("/data/talents/cunning/lethality.lua")
load("/data/talents/cunning/tactical.lua")
load("/data/talents/cunning/survival.lua")
load("/data/talents/cunning/shadow-magic.lua")
load("/data/talents/cunning/ambush.lua")
load("/data/talents/cunning/scoundrel.lua")
