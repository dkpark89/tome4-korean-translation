﻿-- ToME - Tales of Maj'Eyal
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

load("/data/general/objects/objects-maj-eyal.lua")

for i = 1, 4 do
newEntity{ base = "BASE_LORE",
	define_as = "NOTE"..i,
	name = "research log of halfling mage Hompalan", lore="halfling-research-note-"..i,
	kr_name = "하플링 마법사 홈팔란의 연구 기록",
	desc = [[매우 희미해져 거의 읽는 것이 불가능한 연구 기록입니다.]],
	rarity = false,
	encumberance = 0,
}
end

newEntity{ base = "BASE_CLOTH_ARMOR",
	power_source = {psionic=true},
	unique = true,
	name = "Yeek-fur Robe", color = colors.WHITE, image = "object/artifact/yeek_fur_robe.png",
	unided_name = "sleek fur robe",
	kr_name = "이크 가죽 로브", kr_unided_name = "매끈한 가죽 로브",
	desc = [[훌륭한 재질의 흰 털가죽으로 만들어진, 아름답고 부드러운 로브입니다. 단을 따라 화려한 사파이어가 붙어있는 것으로 보아, 하플링 귀족을 위해 만들어진 것으로 보입니다. 넋을 잃을 만큼 매혹적이지만, 이것을 입으면 약간 메스꺼운 느낌이 납니다.]],
	level_range = {12, 22},
	rarity = 20,
	cost = 250,
	material_level = 2,
	wielder = {
		combat_def = 9,
		combat_armor = 3,
		combat_mindpower = 5,
		combat_mentalresist = 10,
		inc_damage={[DamageType.MIND] = 5},
		resists={[DamageType.COLD] = 20},
	},
	on_wear = function(self, who)
		if who.descriptor and who.descriptor.race == "Yeek" then
			local Talents = require "engine.interface.ActorStats"
			self:specialWearAdd({"wielder","combat_mindpower"}, -15)
			self:specialWearAdd({"wielder","combat_mentalresist"}, -25)
			game.logPlayer(who, "#RED#당신은 이것을 건드리기만 해도 메스꺼움을 느낍니다!")
		end
		if who.descriptor and who.descriptor.race == "Halfling" then
			local Talents = require "engine.interface.ActorStats"
			self:specialWearAdd({"wielder","resists"}, {[engine.DamageType.MIND] = 15,})
			self:specialWearAdd({"wielder","combat_mentalresist"}, 10)
			game.logPlayer(who, "#LIGHT_BLUE#이 로브는 당신을 위해 만들어진 것 같습니다!")
		end
	end,
}
