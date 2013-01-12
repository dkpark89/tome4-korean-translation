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

newEntity{
	define_as = "BASE_SCROLL",
	type = "scroll", subtype="scroll",
	unided_name = "scroll", id_by_type = true,
	kr_unided_name = "두루마리",
	display = "?", color=colors.WHITE, image="object/scroll.png",
	encumber = 0.1,
	stacking = true,
	use_sound = "actions/read",
	use_no_blind = true,
	use_no_silence = true,
	fire_destroy = {{10,1}, {20,2}, {40,5}, {60,10}, {120,20}},
	desc = [[마법의 두루마리는 여러가지 다른 효과를 가질 수 있습니다! 대부분은 마법 능력치가 높을수록 더 높은 효과를 보입니다.]],
	egos = "/data/general/objects/egos/scrolls.lua", egos_chance = resolvers.mbonus(10, 5),
}

newEntity{
	define_as = "BASE_INFUSION",
	type = "scroll", subtype="infusion", add_name = " (#INSCRIPTION#)",
	unided_name = "infusion", id_by_type = true,
	kr_unided_name = "주입물",
	display = "?", color=colors.LIGHT_GREEN, image="object/rune_green.png",
	encumber = 0.1,
	use_sound = "actions/read",
	use_no_blind = true,
	use_no_silence = true,
	fire_destroy = {{100,1}, {200,2}, {400,5}, {600,10}, {1200,20}},
	desc = [[자연적 주입물을 당신의 육체로 이식하여, 필요한 기술을 가질 수 있습니다.]],
	egos = "/data/general/objects/egos/infusions.lua", egos_chance = resolvers.mbonus(30, 5),
	material_level_min_only = true,

	power_source = {nature=true},
	use_simple = { name="inscribe your skin with the infusion.", kr_display_name = "주입물을 피부에 새김", use = function(self, who, inven, item)
		if who:setInscription(nil, self.inscription_talent, self.inscription_data, true, true, {obj=self, inven=inven, item=item}) then
			return {used=true, id=true, destroy=true}
		end
	end}
}

newEntity{
	define_as = "BASE_RUNE",
	type = "scroll", subtype="rune", add_name = " (#INSCRIPTION#)",
	unided_name = "rune", id_by_type = true,
	kr_unided_name = "룬",
	display = "?", color=colors.LIGHT_BLUE, image="object/rune_red.png",
	encumber = 0.1,
	use_sound = "actions/read",
	use_no_blind = true,
	use_no_silence = true,
	fire_destroy = {{10,1}, {20,2}, {40,5}, {60,10}, {120,20}},
	desc = [[마법의 룬을 당신의 육체에 새겨, 필요한 기술을 가질 수 있습니다.]],
	egos = "/data/general/objects/egos/infusions.lua", egos_chance = resolvers.mbonus(30, 5),
	material_level_min_only = true,

	power_source = {arcane=true},
	use_simple = { name="inscribe your skin with the rune.", kr_display_name = "룬을 피부에 새김", use = function(self, who, inven, item)
		if who:setInscription(nil, self.inscription_talent, self.inscription_data, true, true, {obj=self, inven=inven, item=item}) then
			return {used=true, id=true, destroy=true}
		end
	end}
}

newEntity{
	define_as = "BASE_TAINT",
	type = "scroll", subtype="taint", add_name = " (#INSCRIPTION#)",
	unided_name = "taint", id_by_type = true,
	kr_unided_name = "오염",
	display = "?", color=colors.LIGHT_BLUE, image="object/rune_yellow.png",
	encumber = 0.1,
	use_sound = "actions/read",
	use_no_blind = true,
	use_no_silence = true,
	fire_destroy = {{10,1}, {20,2}, {40,5}, {60,10}, {120,20}},
	desc = [[타락한 오염을 당신의 육체에 새겨, 필요한 기술을 가질 수 있습니다.]],
	egos = "/data/general/objects/egos/infusions.lua", egos_chance = resolvers.mbonus(30, 5),

	power_source = {arcane=true},
	use_simple = { name="inscribe your skin with the taint.", kr_display_name = "오염을 피부에 새김", use = function(self, who, inven, item)
		if who:setInscription(nil, self.inscription_talent, self.inscription_data, true, true, {obj=self, inven=inven, item=item}) then
			return {used=true, id=true, destroy=true}
		end
	end}
}

newEntity{
	define_as = "BASE_LORE",
	type = "lore", subtype="lore", not_in_stores=true, no_unique_lore=true,
	unided_name = "scroll", identified=true,
	kr_unided_name = "두루마리",
	display = "?", color=colors.ANTIQUE_WHITE, image="object/scroll-lore.png",
	encumber = 0,
	checkFilter = function(self) if self.lore and game.party.lore_known and game.party.lore_known[self.lore] then print('[LORE] refusing', self.lore) return false else return true end end,
	desc = [[이 양피지는 어떤 지식을 담고 있습니다.]],
}

newEntity{
	define_as = "BASE_LORE_RANDOM",
	type = "lore", subtype="lore", not_in_stores=true, no_unique_lore=true,
	unided_name = "scroll", identified=true,
	kr_unided_name = "두루마리",
	display = "?", color=colors.ANTIQUE_WHITE, image="object/scroll.png",
	encumber = 0,
	checkFilter = function(self) if self.lore and game.party.lore_known and game.party.lore_known[self.lore] then print('[LORE] refusing', self.lore) return false else return true end end,
	desc = [[이 양피지는 어떤 지식을 담고 있습니다.]],
}

-----------------------------------------------------------
-- Infusions
-----------------------------------------------------------
newEntity{ base = "BASE_INFUSION",
	name = "healing infusion",
	kr_display_name = "치료 주입물",
	level_range = {7, 50},
	rarity = 16,
	cost = 10,
	material_level = 1,

	inscription_kind = "heal",
	inscription_data = {
		cooldown = resolvers.rngrange(12, 17),
		heal = resolvers.mbonus_level(400, 40, function(e, v) return v * 0.06 end),
		use_stat_mod = 2.7,
	},
	inscription_talent = "INFUSION:_HEALING",
}

newEntity{ base = "BASE_INFUSION",
	name = "regeneration infusion",
	kr_display_name = "재생 주입물",
	level_range = {1, 50},
	rarity = 15,
	cost = 10,
	material_level = 1,

	inscription_kind = "heal",
	inscription_data = {
		cooldown = resolvers.rngrange(12, 17),
		dur = 5,
		heal = resolvers.mbonus_level(550, 60, function(e, v) return v * 0.06 end),
		use_stat_mod = 3.4,
	},
	inscription_talent = "INFUSION:_REGENERATION",
}

newEntity{ base = "BASE_INFUSION",
	name = "wild infusion",
	kr_display_name = "야생성 주입물",
	level_range = {1, 50},
	rarity = 13,
	cost = 20,
	material_level = 1,

	inscription_kind = "protect",
	inscription_data = resolvers.generic(function(e)
		local what = {}
		local effects = {physical=true, mental=true, magical=true}
		local eff1 = rng.tableIndex(effects)
		what[eff1] = true
		local two = rng.percent(20) and true or false
		if two then
			local eff2 = rng.tableIndex(effects, {eff1})
			what[eff2] = true
		end
		return {
			cooldown = rng.range(12, 17),
			dur = rng.mbonus(4, resolvers.current_level, resolvers.mbonus_max_level) + 4,
			power = rng.mbonus(20, resolvers.current_level, resolvers.mbonus_max_level) + 10,
			use_stat_mod = 0.1,
			what=what,
		}
	end),
	inscription_talent = "INFUSION:_WILD",
}

newEntity{ base = "BASE_INFUSION",
	name = "movement infusion",
	kr_display_name = "이동 주입물",
	level_range = {10, 50},
	rarity = 15,
	cost = 30,
	material_level = 3,

	inscription_kind = "movement",
	inscription_data = {
		cooldown = resolvers.rngrange(13, 20),
		dur = resolvers.mbonus_level(5, 4, function(e, v) return v * 1 end),
		speed = resolvers.mbonus_level(700, 500, function(e, v) return v * 0.001 end),
		use_stat_mod = 3,
	},
	inscription_talent = "INFUSION:_MOVEMENT",
}

newEntity{ base = "BASE_INFUSION",
	name = "sun infusion",
	kr_display_name = "태양 주입물",
	level_range = {1, 50},
	rarity = 13,
	cost = 10,
	material_level = 1,

	inscription_kind = "attack",
	inscription_data = {
		cooldown = resolvers.rngrange(9, 15),
		range = resolvers.mbonus_level(5, 5, function(e, v) return v * 0.1 end),
		turns = resolvers.rngrange(3, 5),
		power = resolvers.mbonus_level(5, 20, function(e, v) return v * 0.1 end),
		use_stat_mod = 1.2,
	},
	inscription_talent = "INFUSION:_SUN",
}

newEntity{ base = "BASE_INFUSION",
	name = "heroism infusion",
	kr_display_name = "영웅주의 주입물",
	level_range = {25, 50},
	rarity = 16,
	cost = 40,
	material_level = 3,

	inscription_kind = "utility",
	inscription_data = {
		cooldown = resolvers.rngrange(20, 30),
		dur = resolvers.mbonus_level(7, 7),
		power = resolvers.mbonus_level(4, 4, function(e, v) return v * 3 end),
		die_at = resolvers.mbonus_level(700, 100, function(e, v) return v * 0.2 end),
		use_stat_mod = 0.14,
	},
	inscription_talent = "INFUSION:_HEROISM",
}

newEntity{ base = "BASE_INFUSION",
	name = "insidious poison infusion",
	kr_display_name = "반회복형 중독 주입물",
	level_range = {10, 50},
	rarity = 16,
	cost = 20,
	material_level = 2,

	inscription_kind = "attack",
	inscription_data = {
		cooldown = resolvers.rngrange(15, 25),
		range = resolvers.mbonus_level(3, 3),
		heal_factor = resolvers.mbonus_level(50, 20, function(e, v) return v * 0.1 end),
		power = resolvers.mbonus_level(300, 70, function(e, v) return v * 0.1 end),
		use_stat_mod = 2,
	},
	inscription_talent = "INFUSION:_INSIDIOUS_POISON",
}

-----------------------------------------------------------
-- Runes
-----------------------------------------------------------
newEntity{ base = "BASE_RUNE",
	name = "phase door rune",
	kr_display_name = "근거리 순간이동 룬",
	level_range = {1, 50},
	rarity = 15,
	cost = 10,
	material_level = 1,

	inscription_kind = "teleport",
	inscription_data = {
		cooldown = resolvers.rngrange(8, 10),
		range = resolvers.mbonus_level(10, 5, function(e, v) return v * 1 end),
		use_stat_mod = 0.07,
	},
	inscription_talent = "RUNE:_PHASE_DOOR",
}

newEntity{ base = "BASE_RUNE",
	name = "controlled phase door rune",
	kr_display_name = "제어된 근거리 순간이동 룬",
	level_range = {35, 50},
	rarity = 17,
	cost = 50,
	material_level = 4,

	inscription_kind = "movement",
	inscription_data = {
		cooldown = resolvers.rngrange(10, 12),
		range = resolvers.mbonus_level(6, 5, function(e, v) return v * 3 end),
		use_stat_mod = 0.05,
	},
	inscription_talent = "RUNE:_CONTROLLED_PHASE_DOOR",
}

newEntity{ base = "BASE_RUNE",
	name = "teleportation rune",
	kr_display_name = "장거리 공간이동 룬",
	level_range = {10, 50},
	rarity = 15,
	cost = 10,
	material_level = 2,

	inscription_kind = "teleport",
	inscription_data = {
		cooldown = resolvers.rngrange(14, 19),
		range = resolvers.mbonus_level(100, 20, function(e, v) return v * 0.03 end),
		use_stat_mod = 1,
	},
	inscription_talent = "RUNE:_TELEPORTATION",
}

newEntity{ base = "BASE_RUNE",
	name = "shielding rune",
	kr_display_name = "보호막 룬",
	level_range = {5, 50},
	rarity = 15,
	cost = 20,
	material_level = 3,

	inscription_kind = "protect",
	inscription_data = {
		cooldown = resolvers.rngrange(14, 24),
		dur = resolvers.mbonus_level(5, 3),
		power = resolvers.mbonus_level(500, 50, function(e, v) return v * 0.06 end),
		use_stat_mod = 3,
	},
	inscription_talent = "RUNE:_SHIELDING",
}

newEntity{ base = "BASE_RUNE",
	name = "invisibility rune",
	kr_display_name = "투명화 룬",
	level_range = {18, 50},
	rarity = 19,
	cost = 40,
	material_level = 3,

	inscription_kind = "utility",
	inscription_data = {
		cooldown = resolvers.rngrange(14, 24),
		dur = resolvers.mbonus_level(9, 4, function(e, v) return v * 1 end),
		power = resolvers.mbonus_level(8, 7, function(e, v) return v * 1 end),
		use_stat_mod = 0.08,
	},
	inscription_talent = "RUNE:_INVISIBILITY",
}

newEntity{ base = "BASE_RUNE",
	name = "vision rune",
	kr_display_name = "심안 룬",
	level_range = {15, 50},
	rarity = 16,
	cost = 30,
	material_level = 2,

	inscription_kind = "detection",
	inscription_data = {
		cooldown = resolvers.rngrange(20, 30),
		range = resolvers.mbonus_level(10, 8),
		dur = resolvers.mbonus_level(20, 12),
		power = resolvers.mbonus_level(20, 10, function(e, v) return v * 0.3 end),
		use_stat_mod = 0.14,
	},
	inscription_talent = "RUNE:_VISION",
}

newEntity{ base = "BASE_RUNE",
	name = "heat beam rune",
	kr_display_name = "열기의 빔 룬",
	level_range = {25, 50},
	rarity = 16,
	cost = 20,
	material_level = 3,

	inscription_kind = "attack",
	inscription_data = {
		cooldown = resolvers.rngrange(15, 25),
		range = resolvers.mbonus_level(5, 4),
		power = resolvers.mbonus_level(300, 60, function(e, v) return v * 0.1 end),
		use_stat_mod = 1.8,
	},
	inscription_talent = "RUNE:_HEAT_BEAM",
}

newEntity{ base = "BASE_RUNE",
	name = "frozen spear rune",
	kr_display_name = "빙결의 창 룬",
	level_range = {25, 50},
	rarity = 16,
	cost = 20,
	material_level = 3,

	inscription_kind = "attack",
	inscription_data = {
		cooldown = resolvers.rngrange(15, 25),
		range = resolvers.mbonus_level(5, 4),
		power = resolvers.mbonus_level(300, 60, function(e, v) return v * 0.1 end),
		use_stat_mod = 1.8,
	},
	inscription_talent = "RUNE:_FROZEN_SPEAR",
}

newEntity{ base = "BASE_RUNE",
	name = "acid wave rune",
	kr_display_name = "산성 파동 룬",
	level_range = {25, 50},
	rarity = 16,
	cost = 20,
	material_level = 3,

	inscription_kind = "attack",
	inscription_data = {
		cooldown = resolvers.rngrange(15, 25),
		range = resolvers.mbonus_level(3, 2),
		power = resolvers.mbonus_level(250, 40, function(e, v) return v * 0.1 end),
		use_stat_mod = 1.8,
	},
	inscription_talent = "RUNE:_ACID_WAVE",
}

newEntity{ base = "BASE_RUNE",
	name = "lightning rune",
	kr_display_name = "전격 룬",
	level_range = {25, 50},
	rarity = 16,
	cost = 20,
	material_level = 3,

	inscription_kind = "attack",
	inscription_data = {
		cooldown = resolvers.rngrange(15, 25),
		range = resolvers.mbonus_level(5, 4),
		power = resolvers.mbonus_level(280, 50, function(e, v) return v * 0.1 end),
		use_stat_mod = 1.8,
	},
	inscription_talent = "RUNE:_LIGHTNING",
}

newEntity{ base = "BASE_RUNE",
	name = "manasurge rune",
	kr_display_name = "마나집중 룬",
	level_range = {1, 50},
	rarity = 22,
	cost = 10,
	material_level = 1,

	inscription_kind = "utility",
	inscription_data = {
		cooldown = resolvers.rngrange(20, 30),
		dur = 10,
		mana = resolvers.mbonus_level(1200, 600, function(e, v) return v * 0.003 end),
		use_stat_mod = 4,
	},
	inscription_talent = "RUNE:_MANASURGE",
}

-----------------------------------------------------------
-- Taints
-----------------------------------------------------------
--[[
newEntity{ base = "BASE_TAINT",
	name = "taint of the devourer",
	kr_display_name = "먹깨비 오염",
	level_range = {1, 50},
	rarity = 15,
	cost = 10,
	material_level = 1,

	inscription_kind = "heal",
	inscription_data = {
		cooldown = resolvers.rngrange(12, 17),
		effects = resolvers.mbonus_level(3, 2, function(e, v) return v * 0.06 end),
		heal = resolvers.mbonus_level(70, 40, function(e, v) return v * 0.06 end),
		use_stat_mod = 0.6,
	},
	inscription_talent = "TAINT:_DEVOURER",
}
]]
