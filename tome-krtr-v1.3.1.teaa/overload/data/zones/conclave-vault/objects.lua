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

local Stats = require "engine.interface.ActorStats"
local Talents = require "engine.interface.ActorTalents"

load("/data/general/objects/objects-maj-eyal.lua")

for i = 1, 4 do
newEntity{ base = "BASE_LORE",
	define_as = "NOTE"..i,
	name = "log of healer Astelrid", lore="conclave-vault-"..i,
	desc = [[A very faded note, nearly unreadable.]],
	rarity = false,
	encumberance = 0,
}
end
newEntity{ base = "BASE_LORE",
	define_as = "LORE_SONG",
	name = "investigator Churrack note", lore="conclave-vault-song",
	desc = [[A very faded note, nearly unreadable.]],
	rarity = false,
	encumberance = 0,
}

newEntity{ base = "BASE_GREATMAUL", define_as = "ASTELRID_CLUBSTAFF",
	power_source = {arcane=true},
	name = "Astelrid's Clubstaff", color = colors.GREEN, image = "object/artifact/astelrids_clubstaff.png",
	unided_name = "huge maul", unique = true,
	moddable_tile = "special/%s_astelrids_clubstaff",
	desc = [[Like its former owner, this was once an instrument of altruistic healing, before fury and fear caused its twisting into a sadistic weapon.  Surges of restorative magic can be faintly felt under the layers of plaster and sharp surgical equipment.]],
	level_range = {20, 30},
	require = { stat = { str=23 }, },
	cost = 650,
	rarity = false,
	material_level = 3,
	combat = {
		dam = 45,
		apr = 4,
		physcrit = 8,
		dammod = {str=1, mag=0.4},
	},
	wielder = {
		inc_damage= {[DamageType.NATURE] = 25},
		inc_stats = {[Stats.STAT_MAG] = 4},
		combat_spellpower = 15,
		healing_factor = 0.25,
		inscriptions_stat_multiplier = 0.15,
	},
	special_desc = function(self) return "Improves the contribution of primary stats on infusions and runes by 15%" end,
}
