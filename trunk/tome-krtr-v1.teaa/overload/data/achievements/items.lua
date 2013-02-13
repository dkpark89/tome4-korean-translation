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

newAchievement{
	name = "Deus Ex Machina",
	kr_display_name = "데우스 Ex 마키나",
	desc = [[끊임없이 다시 차오르는 포션(ever-refilling potion)과 블러드 오브 라이프(blood of life)를 찾았다.]],
	mode = "player",
	can_gain = function(self, who, obj)
		if (obj:getName{force_id=true} == "Blood of Life" or obj.name == "Blood of Life") then self.blood = true end --@@ 원래이름도 비교되도록 코드 수정
		if (obj:getName{force_id=true} == "Ever-Refilling Potion of Healing" or obj.name == "Ever-Refilling Potion of Healing") then self.life = true end --@@ 원래이름도 비교되도록 코드 수정
		return self.blood and self.life
	end
}

newAchievement{
	name = "Treasure Hunter",
	kr_display_name = "보물 사냥꾼",
	image = "object/money_large.png",
	show = "name",
	desc = [[1000개의 골드 조각을 모음.]],
	can_gain = function(self, who)
		return who.money >= 1000
	end,
}

newAchievement{
	name = "Treasure Hoarder",
	kr_display_name = "보물 비축자",
	image = "object/money_large.png",
	show = "name",
	desc = [[3000개의 골드 조각을 모음.]],
	can_gain = function(self, who)
		return who.money >= 3000
	end,
}

newAchievement{ id = "DRAGON_GREED",
	name = "Dragon's Greed",
	kr_display_name = "드래곤의 탐욕",
	image = "object/money_large.png",
	show = "name",
	desc = [[8000개의 골드 조각을 모음.]],
	can_gain = function(self, who)
		return who.money >= 8000
	end,
}
