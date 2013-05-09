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

newAchievement{
	name = "Deus Ex Machina",
	kr_name = "데우스 엑스 마키나",
	desc = [[끊임없는 생명력의 물약과 생명의 피 발견.]],
	mode = "player",
	can_gain = function(self, who, obj)
		if (obj:getName{force_id=true} == "Blood of Life" or obj:getOriName{force_id=true} == "Blood of Life") then self.blood = true end
		if (obj:getName{force_id=true} == "Ever-Refilling Potion of Healing" or obj:getOriName{force_id=true} == "Ever-Refilling Potion of Healing") then self.life = true end
		return self.blood and self.life
	end
}

newAchievement{
	name = "Treasure Hunter",
	kr_name = "보물 사냥꾼",
	image = "object/money_large.png",
	show = "name",
	desc = [[금화 1,000 개 이상 축적.]],
	can_gain = function(self, who)
		return who.money >= 1000
	end,
}

newAchievement{
	name = "Treasure Hoarder",
	kr_name = "보물 비축자",
	image = "object/money_large.png",
	show = "name",
	desc = [[금화 3,000 개 이상 축적.]],
	can_gain = function(self, who)
		return who.money >= 3000
	end,
}

newAchievement{ id = "DRAGON_GREED",
	name = "Dragon's Greed",
	kr_name = "용의 탐욕",
	image = "object/money_large.png",
	show = "name",
	desc = [[금화 8,000 개 이상 축적.]],
	can_gain = function(self, who)
		return who.money >= 8000
	end,
}
