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

load("/data/general/objects/objects-maj-eyal.lua")
load("/data/general/objects/mummy-wrappings.lua")

for i = 1, 3 do
newEntity{ base = "BASE_LORE",
	define_as = "NOTE"..i,
	name = "ancient papyrus scroll", lore="ancient-elven-ruins-note-"..i,
	kr_name = "고대의 파피루스 두루마리",
	desc = [[위대한 샬로레 마법사의 마지막 나날들을 엿볼 수 있는 글입니다.]],
	rarity = false,
}
end

local Stats = require "engine.interface.ActorStats"
local Talents = require "engine.interface.ActorTalents"

newEntity{ base = "BASE_MUMMY_WRAPPING", define_as = "BINDINGS_ETERNAL_NIGHT",
	power_source = {arcane=true},
	unique = true,
	name = "Bindings of Eternal Night", image = "object/artifact/bindings_of_eternal_night.png",
	unided_name = "blackened, slithering mummy wrappings",
	kr_name = "영원한 밤의 붕대", kr_unided_name = "검고 미끌미끌한 미이라 붕대",
	desc = [[역생의 마법으로 짜여진 이 붕대는, 붕대에 닿는 모든 빛과 생명력을 흡수합니다. 붕대를 걸친 사람은, 곧 삶과 죽음 사이에 존재하는 악몽과도 같은 연옥에 매달린 자신을 발견하게 될 것입니다.]],
	color = colors.DARK_GREY,
	level_range = {1, 50},
	rarity = 20,
	cost = 200,
	material_level = 3,
	wielder = {
		combat_armor = 12,
		combat_def = 12,
		inc_stats = { [Stats.STAT_WIL] = 5, [Stats.STAT_MAG] = 5, },
		resists = {
			[DamageType.BLIGHT] = 30,
			[DamageType.DARKNESS] = 30,
			[DamageType.LIGHT] = -10,
			[DamageType.FIRE] = -10,
		},
		inc_damage={[DamageType.DARKNESS] = 20},
		on_melee_hit={[DamageType.DARKNESS] = 10},
		life_regen = 1,
		lite = -1,
		poison_immune = 1,
		disease_immune = 1,
		undead = 1,
		forbid_nature = 1,
	},
	max_power = 80, power_regen = 1,

	set_list = { {"define_as","CROWN_ETERNAL_NIGHT"} },
	on_set_complete = function(self, who)
		self.use_talent = { id = "T_ABYSSAL_SHROUD", level = 2, power = 47 }
	end,
	on_set_broken = function(self, who)
		self.use_talent = nil
	end,
}

newEntity{ base = "BASE_LEATHER_CAP", define_as = "CROWN_ETERNAL_NIGHT",
	power_source = {arcane=true},
	unique = true,
	name = "Crown of Eternal Night", image = "object/artifact/crown_of_eternal_night.png",
	unided_name = "blackened crown",
	kr_name = "영원한 밤의 왕관", kr_unided_name = "검은 왕관",
	desc = [[겉보기에는 쓸모 없는 왕관이지만, 아직 그 안에 엮여 있는 역생의 마법을 느낄 수 있습니다. 사용할 수는 있을 것 같습니다.]],
	color = colors.DARK_GREY,
	level_range = {1, 50},
	cost = 100,
	rarity = 20,
	material_level = 3,
	wielder = {
		combat_armor = 3,
		fatigue = 3,
		inc_damage = {},
		melee_project = {},
		flat_damage_armor = {all=10},
	},
	max_power = 80, power_regen = 1,

	set_list = { {"define_as","BINDINGS_ETERNAL_NIGHT"} },
	on_set_complete = function(self, who)
		self:specialSetAdd({"wielder","lite"}, -1)
		self:specialSetAdd({"wielder","confusion_immune"}, 0.3)
		self:specialSetAdd({"wielder","knockback_immune"}, 0.3)
		self:specialSetAdd({"wielder","combat_mentalresist"}, 15)
		self:specialSetAdd({"wielder","combat_spellresist"}, 15)
		self:specialSetAdd({"wielder","flat_damage_armor"}, {all=20})
		self:specialSetAdd({"wielder","inc_stats"}, {[who.STAT_CUN]=10})
		self:specialSetAdd({"wielder","melee_project"}, {[engine.DamageType.DARKNESS]=40})
		self:specialSetAdd({"wielder","inc_damage"}, {[engine.DamageType.DARKNESS]=20})
		self:specialSetAdd({"wielder","talents_types_mastery"}, {["cunning/stealth"] = 0.1,})
		self.use_talent = { id = "T_RETCH", level = 2, power = 47 }
		game.logSeen(who, "#ANTIQUE_WHITE#영원한 밤의 왕관이 붕대와 서로 반응하기 시작합니다. 어마어마한 어둠의 힘이 느껴집니다.")
	end,
	on_set_broken = function(self, who)
		game.logPlayer(who, "#ANTIQUE_WHITE#강력한 어둠의 힘이 사라졌습니다.")
		self.use_talent = nil
	end,
}
