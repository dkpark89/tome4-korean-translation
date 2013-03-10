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

load("/data/general/objects/objects-maj-eyal.lua")

newEntity{ base = "BASE_SCROLL", define_as = "NOTE_FROM_LAST_HOPE",
	name = "Sealed Scroll of Last Hope", identified=true, unique=true, no_unique_lore=true,
	kr_display_name = "마지막 희망의 봉인된 두루마리",
	image = "object/letter1.png",
	fire_proof = true,

	use_simple = { name="open the seal and read the message", kr_display_name="봉인을 풀고 전언 읽기", use = function(self, who)
		game:registerDialog(require("engine.dialogs.ShowText").new(self:getName{do_color=true}, "message-last-hope", {playername=who.name}, game.w * 0.6))
		return {used=true, id=true}
	end}
}

newEntity{ base = "BASE_GEM",
	define_as = "RESONATING_DIAMOND_WEST",
	name = "Resonating Diamond", color=colors.VIOLET, quest=true, unique="Resonating Diamond West", identified=true, no_unique_lore=true,
	kr_display_name = "공명하는 다이아몬드",
	image = "object/artifact/resonating_diamond.png",
	material_level = 5,

	on_drop = function(self, who)
		if who == game.player then
			game.logPlayer(who, "당신은 %s 버릴 수 없습니다", self:getName():addJosa("를"))
			return true
		end
	end,
}

newEntity{ define_as = "ATHAME_WEST",
	quest=true, unique="Blood-Runed Athame West", identified=true, no_unique_lore=true,
	type = "misc", subtype="misc",
	unided_name = "athame",
	name = "Blood-Runed Athame", image = "object/artifact/blood_runed_athame.png",
	kr_display_name = "피의 룬 제례단검", kr_unided_name = "제례단검",
	level_range = {50, 50},
	display = "|", color=colors.VIOLET,
	encumber = 1,
	desc = [[피의 룬이 새겨진 제례단검입니다. 힘을 내뿜고 있습니다.]],

	on_drop = function(self, who)
		if who == game.player then
			game.logPlayer(who, "당신은 %s 버릴 수 없습니다", self:getName():addJosa("를"))
			return true
		end
	end,
}

for i = 1, 4 do
newEntity{ base = "BASE_LORE",
	define_as = "IRON_THRONE_PROFIT"..i,
	name = "Iron Throne Profits History", lore="iron-throne-profits-"..i,
	kr_display_name = "철의 왕좌의 손익 역사",
	desc = [[철의 왕좌 드워프들의 손익에 관한 역사가 적힌 잡지입니다.]],
	rarity = false,
	encumberance = 0,
}
end

newEntity{ base = "BASE_LORE",
	define_as = "IRON_THRONE_LEDGER",
	name = "Iron Throne trade ledger", lore="iron-throne-trade-ledger",
	kr_display_name = "철의 왕좌 거래 대장",
	desc = [[철의 왕좌 드워프들의 거래 대장입니다.]],
	rarity = false,
	encumberance = 0,
}

newEntity{ base = "BASE_LORE",
	define_as = "IRON_THRONE_LAST_WORDS",
	name = "Iron Throne Reknor expedition, last words", lore="iron-throne-last-words",
	kr_display_name = "철의 왕좌의 레크놀 탐험대가 남긴 유언",
	desc = [[레크놀의 안전을 위한 드워프 탐험대의 유언입니다.]],
	rarity = false,
	encumberance = 0,
}
