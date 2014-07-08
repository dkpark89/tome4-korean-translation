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

load("/data/general/objects/objects-maj-eyal.lua")

newEntity{ base = "BASE_GEM",
	define_as = "ATAMATHON_RUBY_EYE",
	subtype = "red",
	name = "Atamathon's Ruby Eye", color=colors.VIOLET, quest=true, unique=true, identified=true, image="object/artifact/atamathons_lost_ruby_eye.png",
	kr_name = "아타마쏜의 루비 눈",
	desc = [[전설적인 거대 골렘 아타마쏜의 한 쪽 눈입니다.
장작더미의 시대에, 하플링이 오크에 대항하기 위한 무기로 이 골렘을 만들었다고 알려져 있습니다. 하지만, 오크들의 지도자인 포식자 가르쿨의 목숨을 건 공격을 받아 파괴되었다고 합니다.]],
	material_level = 5,
	cost = 100,
	wielder = {
		inc_damage = {[DamageType.FIRE]=20},
		on_melee_hit={[DamageType.FIRE]=100},
		lite = 2,
		max_life = 60,
		pin_immune = 0.5,
	},
	imbue_powers = {
		inc_damage = {[DamageType.FIRE]=20},
		on_melee_hit={[DamageType.FIRE]=100},
		lite = 2,
		max_life = 60,
		pin_immune = 0.5,
	},
}
