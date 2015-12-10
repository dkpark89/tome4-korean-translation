-- ToME - Tales of Maj'Eyal
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

load("/data/general/objects/objects-far-east.lua")
load("/data/general/objects/lore/sunwall.lua")

for i = 1, 3 do
newEntity{ base = "BASE_LORE",
	define_as = "NOTE"..i,
	name = "diary page", lore="ardhungol-"..i,
	kr_name = "일기장",
	desc = [[일기장입니다.]],
	rarity = false,
	encumberance = 0,
}
end

newEntity{ base = "BASE_ROD",
	power_source = {nature=true},
	define_as = "ROD_SPYDRIC_POISON",
	unided_name = "poison dripping wand", image = "object/artifact/rod_of_spydric_poison.png",
	name = "Rod of Spydric Poison", color=colors.LIGHT_GREEN, unique=true,
	kr_name = "거미독의 마법봉", kr_unided_name = "독액이 흐르는 장대",
	desc = [[이 마법봉은, 끊임없이 독액이 흐르는 거대 거미의 이빨을 조각하여 만든 것입니다.]],
	cost = 50,
	elec_proof = true,

	max_power = 75, power_regen = 1,
		use_power = {
		name = function(self, who) return ("거미독의 화살을 쏘아내어 범위 %d 내의 적에게 %0.2f 의 자연 피해를 (마법 능력치에 비례) %d 턴에 걸쳐 입힙니다. 거미독에 당한 목표는 이동 할 수 없게 됩니다."):
			format(self.use_power.range, engine.interface.ActorTalents.damDesc(who, engine.DamageType.NATURE, self.use_power.damage(self, who)), self.use_power.duration)
		end,
		power = 25,
		damage = function(self, who) return 200 + who:getMag() * 4 end,
		duration = 6,
		range = 12,
		use = function(self, who)
			local tg = {type="bolt", range=self.use_power.range}
			local x, y = who:getTarget(tg)
			if not x or not y then return nil end
			who:project(tg, x, y, engine.DamageType.SPYDRIC_POISON, {dam=self.use_power.damage(self, who), dur=self.use_power.duration}, {type="slime"})
			return {id=true, used=true}
		end
	},
}
