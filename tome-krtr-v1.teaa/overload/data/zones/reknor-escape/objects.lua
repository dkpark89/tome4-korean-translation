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

load("/data/general/objects/objects-maj-eyal.lua")

newEntity{ base = "BASE_WARAXE",
	power_source = {arcane=true},
	define_as = "FAKE_SKULLCLEAVER",
	unided_name = "fake crimson waraxe",
	name = "Fake Skullcleaver", unique=true, image = "object/artifact/axe_skullcleaver.png",
	kr_display_name = "두개골 절단기 모조품", kr_unided_name = "피비린내 나는 전투도끼 모조품",
	desc = [[다듬어진 뼈 손잡이가 달린, 작지만 날카로운 도끼입니다. 그 날은 많은 두개골을 갈라놓았고, 짙은 피비린내로 얼룩져 있습니다.]],
	require = { stat = { str=18 }, },
	level_range = {5, 12},
	rarity = false,
	cost = 50,
	combat = {
		dam = 16,
		apr = 3,
		physcrit = 12,
		dammod = {str=1},
		melee_project={[DamageType.DRAINLIFE] = 10},
	},
	wielder = {
		inc_damage = { [DamageType.BLIGHT] = 8 },
	},
}
