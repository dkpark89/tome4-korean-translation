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

-- Corruptions
newTalentType{ allow_random=true, no_silence=true, is_spell=true, type="corruption/sanguisuge", name = "sanguisuge", description = "생명을 다뤄 어둠의 힘을 가진다." }
newTalentType{ allow_random=true, no_silence=true, is_spell=true, type="corruption/torment", name = "torment", generic = true, description = "적을 고문하는 모든 도구." }
newTalentType{ allow_random=true, no_silence=true, is_spell=true, type="corruption/vim", name = "vim", description = "희생자의 액기스만 짜내는 손길." }
newTalentType{ allow_random=true, no_silence=true, is_spell=true, type="corruption/bone", name = "bone", description = "뼈의 힘을 이용한다." }
newTalentType{ allow_random=true, no_silence=true, is_spell=true, type="corruption/hexes", name = "hexes", generic = true, description = "매혹술을 걸어, 적들을 방해하고 장애를 유발한다." }
newTalentType{ allow_random=true, no_silence=true, is_spell=true, type="corruption/curses", name = "curses", generic = true, description = "저주를 걸어, 적들을 방해하고 장애를 유발한다." }
newTalentType{ allow_random=true, no_silence=true, is_spell=true, type="corruption/plague", name = "plague", description = "적들에게 질병을 퍼뜨린다." }
newTalentType{ allow_random=true, no_silence=true, is_spell=true, type="corruption/scourge", name = "scourge", description = "고통을 가져오고 세상을 파괴한다." }
newTalentType{ allow_random=true, no_silence=true, is_spell=true, type="corruption/reaving-combat", name = "reaving combat", description = "어둠의 기술로 근접 공격력을 높인다." }
newTalentType{ allow_random=true, no_silence=true, is_spell=true, type="corruption/blood", name = "blood", description = "피의 힘을 이용한다, 자신의 것이든 남의 것이든." }
newTalentType{ allow_random=true, no_silence=true, is_spell=true, type="corruption/blight", name = "blight", description = "상대하는 모두를 타락시키고 부패하게 만든다." }
newTalentType{ allow_random=true, no_silence=true, is_spell=true, type="corruption/shadowflame", name = "Shadowflame", description = "악마같은 어둠의 화염의 힘을 이용한다." }

-- Generic requires for corruptions based on talent level
corrs_req1 = {
	stat = { mag=function(level) return 12 + (level-1) * 2 end },
	level = function(level) return 0 + (level-1)  end,
}
corrs_req2 = {
	stat = { mag=function(level) return 20 + (level-1) * 2 end },
	level = function(level) return 4 + (level-1)  end,
}
corrs_req3 = {
	stat = { mag=function(level) return 28 + (level-1) * 2 end },
	level = function(level) return 8 + (level-1)  end,
}
corrs_req4 = {
	stat = { mag=function(level) return 36 + (level-1) * 2 end },
	level = function(level) return 12 + (level-1)  end,
}
corrs_req5 = {
	stat = { mag=function(level) return 44 + (level-1) * 2 end },
	level = function(level) return 16 + (level-1)  end,
}
str_corrs_req1 = {
	stat = { str=function(level) return 12 + (level-1) * 2 end },
	level = function(level) return 0 + (level-1)  end,
}
str_corrs_req2 = {
	stat = { str=function(level) return 20 + (level-1) * 2 end },
	level = function(level) return 4 + (level-1)  end,
}
str_corrs_req3 = {
	stat = { str=function(level) return 28 + (level-1) * 2 end },
	level = function(level) return 8 + (level-1)  end,
}
str_corrs_req4 = {
	stat = { str=function(level) return 36 + (level-1) * 2 end },
	level = function(level) return 12 + (level-1)  end,
}
str_corrs_req5 = {
	stat = { str=function(level) return 44 + (level-1) * 2 end },
	level = function(level) return 16 + (level-1)  end,
}

load("/data/talents/corruptions/sanguisuge.lua")
load("/data/talents/corruptions/scourge.lua")
load("/data/talents/corruptions/plague.lua")
load("/data/talents/corruptions/reaving-combat.lua")
load("/data/talents/corruptions/bone.lua")
load("/data/talents/corruptions/curses.lua")
load("/data/talents/corruptions/hexes.lua")
load("/data/talents/corruptions/blood.lua")
load("/data/talents/corruptions/blight.lua")
load("/data/talents/corruptions/shadowflame.lua")
load("/data/talents/corruptions/vim.lua")
load("/data/talents/corruptions/torment.lua")
