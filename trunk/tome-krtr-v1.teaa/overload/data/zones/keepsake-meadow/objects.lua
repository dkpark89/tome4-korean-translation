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

require "engine.krtrUtils"

load("/data/general/objects/objects.lua")

newEntity{ base = "BASE_LORE",
	define_as = "BANDERS_NOTES",
	name = "folded up piece of paper",
	kr_display_name = "접힌 종이", 
	lore="keepsake-banders-notes",
	desc = [[몇가지 기록이 적혀있는 접힌 종이입니다.]],
	rarity = false,
	encumberance = 0,
}

newEntity{
	define_as = "IRON_ACORN_BASIC",
	name = "Iron Acorn",
	kr_display_name = "무쇠 도토리",
	type = "misc", subtype="trinket",
	display = "*", color=colors.SLATE, image = "object/iron_acorn.png",
	quest=true,
	unique = true,
	identified = true,
	rarity = false,
	power_source = {technique=true},
	cost = 1,
	material_level = 1,
	encumber = 0,
	not_in_stores = true,
	desc = [[무쇠로 조잡하게 만들어진 작은 도토리입니다.]],
	on_pickup = function(self, who)
		if who.player then
			who:hasQuest("keepsake"):on_pickup_acorn(who)
		end
	end,
	on_drop = function(self, who)
		if who.player then
			game.logPlayer(who, "당신은 %s 버릴 수 없습니다.", self:getName():addJosa("를"))
			return true
		end
	end,
}

newEntity{
	define_as = "IRON_ACORN_GOOD",
	name = "Iron Acorn",
	kr_display_name = "무쇠 도토리",
	type = "misc", subtype="trinket",
	display = "*", color=colors.SLATE, image = "object/iron_acorn.png",
	quest=true,
	unique = true,
	identified = true,
	rarity = false,
	power_source = {psionic=true},
	cost = 1,
	material_level = 1,
	encumber = 0,
	not_in_stores = true,
	desc = [[무쇠로 조잡하게 만들어진 작은 도토리입니다. 한 때 밴더의 것이었지만, 이제는 당신의 것입니다. 당신은 정신을 안정시키고 다가올 시련을 준비하기 위해, 도토리를 가진 이들을 도와줄 방법을 찾아야 합니다.]],
	carrier = {
		resists={[DamageType.MIND] = 30, [DamageType.PHYSICAL] = 8,},
		combat_mindpower = 15,
		max_life = 40
	},
	on_drop = function(self, who)
		if who.player then
			game.logPlayer(who, "당신은 %s 버릴 수 없습니다.", self:getName():addJosa("를"))
			return true
		end
	end,
}

newEntity{
	define_as = "IRON_ACORN_EVIL",
	name = "Cold Iron Acorn",
	kr_display_name = "차가운 무쇠 도토리",
	type = "misc", subtype="trinket",
	display = "*", color=colors.SLATE, image = "object/iron_acorn.png",
	quest=true,
	unique = true,
	identified = true,
	rarity = false,
	power_source = {psionic=true},
	cost = 1,
	material_level = 1,
	encumber = 0,
	not_in_stores = true,
	desc = [[무쇠로 조잡하게 만들어진 작은 도토리입니다. 한 때 밴더의 것이었지만, 이제는 당신의 것입니다. 이 도토리는 당신이 누구이며 무엇을 하고 있었는지를 기억하게 만들어 줍니다.]],
	carrier = {
		resists={[DamageType.MIND] = 30,},
		inc_damage = { [DamageType.PHYSICAL] = 12 },
		movement_speed = 0.2
	},
	on_drop = function(self, who)
		if who.player then
			game.logPlayer(who, "당신은 %s 버릴 수 없습니다.", self:getName():addJosa("를"))
			return true
		end
	end,
}

for i = 1, 4 do
	newEntity{ base = "BASE_LORE",
		define_as = "KYLESS_JOURNAL_"..i,
		name = "journal page", lore="keepsake-kyless-journal-"..i,
		kr_display_name = "여행 일지",
		desc = [[킬레스의 일지에 있던, 출입 방법이 적힌 종이입니다.]],
		rarity = false,
		is_magic_device = false,
		encumberance = 0,
	}
end

newEntity{
	define_as = "KYLESS_BOOK",
	name = "Kyless' Book",
	kr_display_name = "킬레스의 책",
	type = "misc", subtype="trinket",
	display = "%", color=colors.SLATE, image = "object/spellbook.png",
	quest=true,
	unique = true,
	identified = true,
	rarity = false,
	power_source = {psionic=true},
	cost = 1,
	material_level = 1,
	encumber = 5,
	not_in_stores = true,
	desc = [[이것이 킬레스에게 힘을 주고 마침내 그를 파멸로 이끈 책입니다. 아무런 표시도 없는 가죽 표지에, 그 내용은 모두 텅 비어 있습니다.]],
}


