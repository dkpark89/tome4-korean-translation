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

-- Corruptions
newTalentType{ allow_random=true, no_silence=true, is_spell=true, type="celestial/guardian", name = "guardian", min_lev = 10, description = "태양의 힘에 대한 헌신을 통해, 한층 더 강력한 보호를 받게 됩니다." } 
22 newTalentType{ allow_random=true, no_silence=true, is_spell=true, type="celestial/chants", name = "chants", generic = true, description = "태양의 영광을 노래합니다." } 
23 newTalentType{ allow_random=true, no_silence=true, is_spell=true, type="celestial/light", name = "light", generic = true, description = "빛의 힘을 일으켜 치유와 보호의 힘을 얻습니다." } 
24 newTalentType{ allow_random=true, no_silence=true, is_spell=true, type="celestial/combat", name = "combat", description = "태양의 힘에 대한 헌신을 통해, 불굴의 의지를 가지고 적과 맞섭니다." } 
25 newTalentType{ allow_random=true, no_silence=true, is_spell=true, type="celestial/radiance", name = "radiance", description = "자신의 몸을 태양과 연결시켜 빛을 뿜어냅니다." }  
26 newTalentType{ allow_random=true, no_silence=true, is_spell=true, type="celestial/crusader", name = "crusader", description = "방패를 포기하는 대신, 강력한 양손 무기로 적을 분쇄합니다." }  
27 newTalentType{ allow_random=true, no_silence=true, is_spell=true, type="celestial/sunlight", name = "sunlight", description = "태양의 힘을 불러내, 적들을 불태웁니다." }  
28 newTalentType{ allow_random=true, no_silence=true, is_spell=true, type="celestial/sun", name = "sun", description = "태양의 힘으로 적을 불사릅니다." } 
29 newTalentType{ allow_random=true, no_silence=true, is_spell=true, type="celestial/glyphs", name = "glyphs", min_lev = 10, description = "문양에 힘을 불어넣어, 함정으로 사용합니다." } 
30 newTalentType{ allow_random=true, no_silence=true, is_spell=true, type="celestial/twilight", name = "twilight", description = "빛과 어둠의 사이에 서서, 두 힘을 동시에 다룹니다." } 
31 newTalentType{ allow_random=true, no_silence=true, is_spell=true, type="celestial/star-fury", name = "star fury", description = "별과 달의 분노를 통해, 적을 파괴합니다." } 
32 newTalentType{ allow_random=true, no_silence=true, is_spell=true, type="celestial/hymns", name = "hymns", generic = true, description = "달의 영광을 노래합니다." } 
33 newTalentType{ allow_random=true, no_silence=true, is_spell=true, type="celestial/circles", name = "circles", min_lev = 10, description = "발 아래의 땅에 태양과 달의 힘을 부여합니다." } 
34 newTalentType{ allow_random=true, no_silence=true, is_spell=true, type="celestial/eclipse", name = "eclipse", description = "태양과 달이 겹치는 금환식이 일어나면, 세계의 힘은 조화를 이루게 됩니다. 강력한 아노리실은 이 힘으로 압도적인 파괴를 일으킬 수 있습니다." } 
35 
 
newTalentType{ no_silence=true, is_spell=true, type="celestial/other", name = "other",  description = "천공 계열의 다양한 기술들입니다." } 
38 
-- Generic requires for corruptions based on talent level
divi_req1 = {
	stat = { mag=function(level) return 12 + (level-1) * 2 end },
	level = function(level) return 0 + (level-1)  end,
}
divi_req2 = {
	stat = { mag=function(level) return 20 + (level-1) * 2 end },
	level = function(level) return 4 + (level-1)  end,
}
divi_req3 = {
	stat = { mag=function(level) return 28 + (level-1) * 2 end },
	level = function(level) return 8 + (level-1)  end,
}
divi_req4 = {
	stat = { mag=function(level) return 36 + (level-1) * 2 end },
	level = function(level) return 12 + (level-1)  end,
}
divi_req5 = {
	stat = { mag=function(level) return 44 + (level-1) * 2 end },
	level = function(level) return 16 + (level-1)  end,
}
divi_req_high1 = {
	stat = { mag=function(level) return 22 + (level-1) * 2 end },
	level = function(level) return 10 + (level-1)  end,
}
divi_req_high2 = {
	stat = { mag=function(level) return 30 + (level-1) * 2 end },
	level = function(level) return 14 + (level-1)  end,
}
divi_req_high3 = {
	stat = { mag=function(level) return 38 + (level-1) * 2 end },
	level = function(level) return 18 + (level-1)  end,
}
divi_req_high4 = {
	stat = { mag=function(level) return 46 + (level-1) * 2 end },
	level = function(level) return 22 + (level-1)  end,
}
divi_req_high5 = {
	stat = { mag=function(level) return 54 + (level-1) * 2 end },
	level = function(level) return 26 + (level-1)  end,
}

load("/data/talents/celestial/chants.lua")
load("/data/talents/celestial/sunlight.lua")
load("/data/talents/celestial/sun.lua")
load("/data/talents/celestial/combat.lua")
load("/data/talents/celestial/light.lua")
load("/data/talents/celestial/glyphs.lua")
load("/data/talents/celestial/guardian.lua")
load("/data/talents/celestial/radiance.lua")
load("/data/talents/celestial/crusader.lua")

load("/data/talents/celestial/twilight.lua")
load("/data/talents/celestial/hymns.lua")
load("/data/talents/celestial/star-fury.lua")
load("/data/talents/celestial/eclipse.lua")
load("/data/talents/celestial/circles.lua")
